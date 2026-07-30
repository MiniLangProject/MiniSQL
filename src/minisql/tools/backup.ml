package minisql.tools.backup

import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.catalog.statistics as statistics
import minisql.common.crc32c as crc32c
import minisql.common.diagnostics as diagnostics
import minisql.common.endian as endian
import minisql.common.version as version
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.storage.btree as btree
import minisql.storage.checksum as checksum
import minisql.storage.paged_file as paged_file
import minisql.transaction.wal as wal
import minisql.transaction.checkpoint as checkpoint

// M20 verified directory backup. A backup is a self-contained directory with
// byte-identical database files plus a CRC-protected manifest. The database-wide
// lock remains held while every owner-handle snapshot is taken.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const OBJECT_EXISTS = 9013

const FORMAT_VERSION = 1
const MANIFEST_KIND = 60
const MAX_PATH_BYTES = 240
const MAX_FILE_BYTES = 67108864
const MAX_TOTAL_BYTES = 268435456
const MAX_FILE_COUNT = 4096

struct CapturedFile
  relativePath
  data
end struct

struct BackupEntry
  relativePath
  length
  checksum
end struct

struct BackupManifest
  databaseId
  pageSize
  entries
end struct

struct BackupReport
  databaseId
  pageSize
  fileCount
  totalBytes
  path
end struct

struct RestoreReport
  databaseId
  pageSize
  fileCount
  totalBytes
  path
end struct

function fail(code, operation, message)
  return error(code, "tools.backup." + operation + ": " + message)
end function

function isBackupManifest(value)
  return value is BackupManifest
end function

function isBackupReport(value)
  return value is BackupReport
end function

function isRestoreReport(value)
  return value is RestoreReport
end function

function manifestMagic()
  return bytes("MSBKP001")
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count <= 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

function containsInt(values, expected)
  for each value in values
    if value == expected then return true end if
  end for
  return false
end function

function validateRelativePath(relativePath, operation)
  if typeof(relativePath) != "string" or len(relativePath) == 0 or len(bytes(relativePath)) > MAX_PATH_BYTES then return fail(INVALID_ARGUMENT, operation, "relative path length is invalid") end if
  raw = bytes(relativePath)
  if raw[0] == 92 or raw[0] == 47 then return fail(INVALID_ARGUMENT, operation, "absolute paths are forbidden") end if
  previousDot = false
  for each value in raw
    allowed = (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or (value >= 48 and value <= 57) or value == 95 or value == 45 or value == 46 or value == 92 or value == 47
    if not allowed then return fail(INVALID_ARGUMENT, operation, "relative path contains an unsupported character") end if
    if value == 58 then return fail(INVALID_ARGUMENT, operation, "drive paths are forbidden") end if
    if value == 46 and previousDot then return fail(INVALID_ARGUMENT, operation, "parent path components are forbidden") end if
    previousDot = value == 46
  end for
  return true
end function

function ensureDirectory(path)
  if file_api.directoryExists(path) then return true end if
  return file_api.createDirectory(path)
end function

function createLayout(root)
  ensureDirectory(root)
  ensureDirectory(file_api.joinPath(root, "catalog"))
  ensureDirectory(file_api.joinPath(root, "tables"))
  ensureDirectory(file_api.joinPath(root, "indexes"))
  ensureDirectory(file_api.joinPath(root, "wal"))
  ensureDirectory(file_api.joinPath(root, "audit"))
  ensureDirectory(file_api.joinPath(root, "tmp"))
  return true
end function

function readHandle(handle, maxBytes, operation)
  file_api.validateOpen(handle, "tools.backup." + operation)
  file_api.flush(handle)
  length = file_api.size(handle)
  if length < 0 or length > maxBytes then return fail(CORRUPT_DATA, operation, "file exceeds backup safety limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(handle, 0, output, 0, length) end if
  return output
end function

function readWhole(path, maxBytes)
  handle = try(file_api.openRead(path))
  if typeof(handle) == "error" then return handle end if
  length = try(file_api.size(handle))
  if typeof(length) == "error" then file_api.close(handle); return length end if
  if length < 0 or length > maxBytes then file_api.close(handle); return fail(CORRUPT_DATA, "readWhole", "file exceeds backup safety limit") end if
  output = bytes(length, 0)
  readResult = true
  if length > 0 then readResult = try(file_api.readExactAt(handle, 0, output, 0, length)) end if
  closeResult = try(file_api.close(handle))
  if typeof(readResult) == "error" then return readResult end if
  if typeof(closeResult) == "error" then return closeResult end if
  return output
end function

function writeWhole(path, data)
  if typeof(data) != "bytes" then return fail(INVALID_ARGUMENT, "writeWhole", "data must be bytes") end if
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then return handle end if
  writeResult = true
  if len(data) > 0 then writeResult = try(file_api.writeAt(handle, 0, data, 0, len(data))) end if
  flushResult = try(file_api.flush(handle))
  closeResult = try(file_api.close(handle))
  if typeof(writeResult) == "error" then return writeResult end if
  if typeof(flushResult) == "error" then return flushResult end if
  if typeof(closeResult) == "error" then return closeResult end if
  return true
end function

function addCapture(files, relativePath, data)
  validateRelativePath(relativePath, "addCapture")
  if typeof(data) != "bytes" or len(data) > MAX_FILE_BYTES then return fail(CORRUPT_DATA, "addCapture", "captured file exceeds safety limit") end if
  for each existing in files
    if existing.relativePath == relativePath then return fail(CORRUPT_DATA, "addCapture", "duplicate backup path") end if
  end for
  if len(files) >= MAX_FILE_COUNT then return fail(CORRUPT_DATA, "addCapture", "too many backup files") end if
  return files + [CapturedFile(relativePath, bytes(data))]
end function

function capturePath(files, databasePath, relativePath, required)
  fullPath = file_api.joinPath(databasePath, relativePath)
  if not file_api.fileExists(fullPath) then
    if required then return fail(CORRUPT_DATA, "capturePath", "required file is missing: " + relativePath) end if
    return files
  end if
  return addCapture(files, relativePath, readWhole(fullPath, MAX_FILE_BYTES))
end function

function indexIds(state)
  output = []
  for each table in state.tables
    for each constraint in table.constraints
      if constraint.indexId > 0 and not containsInt(output, constraint.indexId) then output = output + [constraint.indexId] end if
    end for
  end for
  return output
end function

function captureDatabase(database)
  files = []
  files = addCapture(files, "db.meta", paged_file.snapshotDurableBytes(database.catalogHandle.metaFile, MAX_FILE_BYTES))
  files = addCapture(files, "catalog\\catalog.tbl", paged_file.snapshotDurableBytes(database.catalogHandle.catalogFile, MAX_FILE_BYTES))
  files = addCapture(files, "catalog\\security.tbl", paged_file.snapshotDurableBytes(database.catalogHandle.securityFile, MAX_FILE_BYTES))
  files = capturePath(files, database.path, "catalog\\schema.history", true)
  files = capturePath(files, database.path, "catalog\\schema.extensions", false)
  files = capturePath(files, database.path, "catalog\\statistics.tbl", false)
  files = addCapture(files, "audit\\audit.key", diagnostics.snapshotAuditKey(database.auditLog))
  files = capturePath(files, database.path, "audit\\audit.anchor", true)
  files = addCapture(files, "audit\\audit.log", diagnostics.snapshotAuditBytes(database.auditLog, MAX_FILE_BYTES))
  files = capturePath(files, database.path, "audit\\audit.previous", false)
  files = capturePath(files, database.path, "audit\\audit.previous.anchor", false)

  wal.flush(database.walWriter)
  files = addCapture(files, "wal\\wal.log", readHandle(database.walWriter.file, MAX_FILE_BYTES, "captureWal"))
  files = addCapture(files, "wal\\checkpoint.meta", readHandle(database.checkpointFile.file, MAX_FILE_BYTES, "captureCheckpoint"))

  for each table in database.catalogHandle.catalog.tables
    relativePath = "tables\\" + catalog.tableFileName(table.tableId)
    tableFile = try(paged_file.open(catalog.tableFilePath(database.path, table.tableId)))
    if typeof(tableFile) == "error" then return tableFile end if
    image = try(paged_file.snapshotDurableBytes(tableFile, MAX_FILE_BYTES))
    closeResult = try(paged_file.close(tableFile))
    if typeof(image) == "error" then return image end if
    if typeof(closeResult) == "error" then return closeResult end if
    files = addCapture(files, relativePath, image)
  end for

  state = schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
  for each indexId in indexIds(state)
    relativePath = "indexes\\i" + indexId + ".idx"
    tree = try(btree.open(schema_history.indexFilePath(database.path, indexId)))
    if typeof(tree) == "error" then return tree end if
    verified = try(btree.verify(tree))
    image = true
    if typeof(verified) != "error" then image = try(paged_file.snapshotDurableBytes(tree.pagedFile, MAX_FILE_BYTES)) end if
    closeResult = try(btree.close(tree))
    if typeof(verified) == "error" then return verified end if
    if typeof(image) == "error" then return image end if
    if typeof(closeResult) == "error" then return closeResult end if
    files = addCapture(files, relativePath, image)
  end for
  return files
end function

function manifestFromFiles(databaseId, pageSize, files)
  entries = []
  total = 0
  for each file in files
    total = total + len(file.data)
    if total > MAX_TOTAL_BYTES then return fail(CORRUPT_DATA, "manifestFromFiles", "backup exceeds total safety limit") end if
    entries = entries + [BackupEntry(file.relativePath, len(file.data), crc32c.compute(file.data))]
  end for
  return BackupManifest(bytes(databaseId), pageSize, entries)
end function

function encodeManifest(manifest)
  if manifest is not BackupManifest then return fail(INVALID_ARGUMENT, "encodeManifest", "manifest must be BackupManifest") end if
  if typeof(manifest.databaseId) != "bytes" or len(manifest.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encodeManifest", "databaseId must be 16 bytes") end if
  if typeof(manifest.pageSize) != "int" or manifest.pageSize < 4096 or manifest.pageSize > 32768 then return fail(INVALID_ARGUMENT, "encodeManifest", "pageSize is invalid") end if
  if len(manifest.entries) > MAX_FILE_COUNT then return fail(INVALID_ARGUMENT, "encodeManifest", "too many entries") end if
  size = 32
  for each entry in manifest.entries
    validateRelativePath(entry.relativePath, "encodeManifest")
    if typeof(entry.length) != "int" or entry.length < 0 or entry.length > MAX_FILE_BYTES then return fail(INVALID_ARGUMENT, "encodeManifest", "entry length is invalid") end if
    if typeof(entry.checksum) != "int" or entry.checksum < 0 or entry.checksum > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodeManifest", "entry checksum is invalid") end if
    size = size + 20 + len(bytes(entry.relativePath))
  end for
  if size > 1048576 then return fail(INVALID_ARGUMENT, "encodeManifest", "manifest exceeds size limit") end if
  payload = bytes(size, 0)
  copyExact(payload, 0, manifest.databaseId, 0, 16)
  endian.writeU32LE(payload, 16, manifest.pageSize)
  endian.writeU32LE(payload, 20, len(manifest.entries))
  endian.writeU64LE(payload, 24, endian.makeUInt64(0, 0))
  cursor = 32
  for each entry in manifest.entries
    pathBytes = bytes(entry.relativePath)
    endian.writeU16LE(payload, cursor, len(pathBytes))
    endian.writeU16LE(payload, cursor + 2, 0)
    endian.writeU64LE(payload, cursor + 4, endian.uint64FromInt(entry.length))
    endian.writeU32LE(payload, cursor + 12, entry.checksum)
    endian.writeU32LE(payload, cursor + 16, 0)
    copyExact(payload, cursor + 20, pathBytes, 0, len(pathBytes))
    cursor = cursor + 20 + len(pathBytes)
  end for
  return checksum.encodeEnvelope(manifestMagic(), FORMAT_VERSION, MANIFEST_KIND, 0, payload)
end function

function decodeManifest(source)
  envelope = checksum.decodeEnvelope(source, manifestMagic(), FORMAT_VERSION, MANIFEST_KIND)
  payload = envelope.payload
  if len(payload) < 32 then return fail(CORRUPT_DATA, "decodeManifest", "manifest payload is truncated") end if
  if endian.readU64LE(payload, 24).high != 0 or endian.readU64LE(payload, 24).low != 0 then return fail(UNSUPPORTED_FORMAT, "decodeManifest", "reserved header is non-zero") end if
  pageSize = endian.readU32LE(payload, 16)
  if pageSize < 4096 or pageSize > 32768 then return fail(CORRUPT_DATA, "decodeManifest", "pageSize is invalid") end if
  count = endian.readU32LE(payload, 20)
  if count > MAX_FILE_COUNT then return fail(CORRUPT_DATA, "decodeManifest", "too many manifest entries") end if
  manifest = BackupManifest(slice(payload, 0, 16), pageSize, [])
  cursor = 32
  if count > 0 then
    for index = 0 to count - 1
      if cursor > len(payload) - 20 then return fail(CORRUPT_DATA, "decodeManifest", "entry header is truncated") end if
      pathLength = endian.readU16LE(payload, cursor)
      if pathLength == 0 or pathLength > MAX_PATH_BYTES or pathLength > len(payload) - cursor - 20 then return fail(CORRUPT_DATA, "decodeManifest", "entry path is truncated") end if
      if endian.readU16LE(payload, cursor + 2) != 0 or endian.readU32LE(payload, cursor + 16) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeManifest", "reserved entry fields are non-zero") end if
      words = endian.readU64LE(payload, cursor + 4)
      if words.high > endian.MAX_SCALAR_HIGH then return fail(CORRUPT_DATA, "decodeManifest", "entry length exceeds native range") end if
      length = endian.uint64ToInt(words)
      if length > MAX_FILE_BYTES then return fail(CORRUPT_DATA, "decodeManifest", "entry length exceeds safety limit") end if
      relativePath = decode(slice(payload, cursor + 20, pathLength))
      validateRelativePath(relativePath, "decodeManifest")
      for each existing in manifest.entries
        if existing.relativePath == relativePath then return fail(CORRUPT_DATA, "decodeManifest", "duplicate manifest path") end if
      end for
      manifest.entries = manifest.entries + [BackupEntry(relativePath, length, endian.readU32LE(payload, cursor + 12))]
      cursor = cursor + 20 + pathLength
    end for
  end if
  if cursor != len(payload) then return fail(CORRUPT_DATA, "decodeManifest", "trailing manifest bytes") end if
  return manifest
end function

function writeCapturedFiles(root, files)
  createLayout(root)
  for each file in files
    writeWhole(file_api.joinPath(root, file.relativePath), file.data)
  end for
  return true
end function

function verifyBackupFiles(backupPath, manifest)
  total = 0
  for each entry in manifest.entries
    fullPath = file_api.joinPath(backupPath, entry.relativePath)
    if not file_api.fileExists(fullPath) then return fail(CORRUPT_DATA, "verifyBackupFiles", "backup file is missing: " + entry.relativePath) end if
    data = readWhole(fullPath, MAX_FILE_BYTES)
    if len(data) != entry.length then return fail(CORRUPT_DATA, "verifyBackupFiles", "backup file length mismatch: " + entry.relativePath) end if
    if crc32c.compute(data) != entry.checksum then return fail(CORRUPT_DATA, "verifyBackupFiles", "backup file checksum mismatch: " + entry.relativePath) end if
    total = total + len(data)
    if total > MAX_TOTAL_BYTES then return fail(CORRUPT_DATA, "verifyBackupFiles", "backup exceeds total safety limit") end if
  end for
  return total
end function

function runOpen(database, backupPath)
  database_manager.validateOpen(database, "tools.backup.runOpen")
  if typeof(backupPath) != "string" or len(backupPath) == 0 then return fail(INVALID_ARGUMENT, "runOpen", "backupPath must be non-empty") end if
  if file_api.pathExists(backupPath) or file_api.pathExists(backupPath + ".new") then return fail(OBJECT_EXISTS, "runOpen", "backup destination already exists") end if
  files = captureDatabase(database)
  metadata = database.catalogHandle.metadata
  manifest = manifestFromFiles(metadata.databaseId, metadata.pageSize, files)
  temporary = backupPath + ".new"
  writeCapturedFiles(temporary, files)
  writeWhole(file_api.joinPath(temporary, "backup.manifest"), encodeManifest(manifest))
  file_api.movePath(temporary, backupPath, false)
  total = verifyBackupFiles(backupPath, manifest)
  return BackupReport(bytes(manifest.databaseId), manifest.pageSize, len(manifest.entries), total, backupPath)
end function

function run(databasePath, backupPath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 or typeof(backupPath) != "string" or len(backupPath) == 0 then return fail(INVALID_ARGUMENT, "run", "paths must be non-empty") end if
  database = void
  if file_api.fileExists(standbyStatePath(databasePath)) then database = try(database_manager.openStandby(databasePath)) else database = try(database_manager.open(databasePath)) end if
  if typeof(database) == "error" then return database end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_BACKUP, diagnostics.AUDIT_SUCCESS, 0, 1, "verified backup started"))
  report = try(runOpen(database, backupPath))
  closeResult = try(database_manager.close(database))
  if typeof(report) == "error" then return report end if
  if typeof(closeResult) == "error" then return closeResult end if
  return report
end function

function readManifest(backupPath)
  path = file_api.joinPath(backupPath, "backup.manifest")
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "readManifest", "backup.manifest is missing") end if
  return decodeManifest(readWhole(path, 1048704))
end function

function restore(backupPath, databasePath)
  if typeof(backupPath) != "string" or len(backupPath) == 0 or typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "restore", "paths must be non-empty") end if
  if not file_api.directoryExists(backupPath) then return fail(CORRUPT_DATA, "restore", "backup directory is missing") end if
  if file_api.pathExists(databasePath) or file_api.pathExists(databasePath + ".restore-new") then return fail(OBJECT_EXISTS, "restore", "database destination already exists") end if
  manifest = readManifest(backupPath)
  total = verifyBackupFiles(backupPath, manifest)
  temporary = databasePath + ".restore-new"
  createLayout(temporary)
  for each entry in manifest.entries
    data = readWhole(file_api.joinPath(backupPath, entry.relativePath), MAX_FILE_BYTES)
    writeWhole(file_api.joinPath(temporary, entry.relativePath), data)
  end for
  writeWhole(file_api.joinPath(temporary, "db.lock"), bytes())

  // Validate the complete restored tree while it still has its temporary name.
  database = void
  if file_api.fileExists(file_api.joinPath(temporary, "standby.state")) then database = try(database_manager.openStandby(temporary)) else database = try(database_manager.open(temporary)) end if
  if typeof(database) == "error" then return database end if
  if not bytesEqual(database.catalogHandle.metadata.databaseId, manifest.databaseId) or database.catalogHandle.metadata.pageSize != manifest.pageSize then
    database_manager.close(database)
    return fail(CORRUPT_DATA, "restore", "restored database identity mismatch")
  end if
  database_manager.close(database)
  file_api.movePath(temporary, databasePath, false)
  return RestoreReport(bytes(manifest.databaseId), manifest.pageSize, len(manifest.entries), total, databasePath)
end function


// M31 offline WAL archive and point-in-time recovery. Archive generations store
// complete, validated WAL prefixes. This is intentionally conservative: it
// trades archive space for simple continuity validation and deterministic PITR.
const ARCHIVE_FORMAT_VERSION = 1
const ARCHIVE_KIND = 80
const STANDBY_FORMAT_VERSION = 1
const STANDBY_KIND = 81
// Archive generations use an on-disk U32. M48 live shipping may run for a
// long-lived server, so the implementation accepts the full representable
// range instead of the original M31 test-oriented cap of 1024 snapshots.
const MAX_ARCHIVE_GENERATIONS = 4294967295

struct ArchiveManifest
  databaseId
  pageSize
  generation
  baseEndLsn
  latestEndLsn
  walFileName
  walLength
  walChecksum
end struct

struct ArchiveReport
  databaseId
  generation
  baseEndLsn
  latestEndLsn
  path
end struct

struct PitrReport
  databaseId
  targetLsn
  path
end struct

struct StandbyState
  databaseId
  archiveGeneration
  appliedLsn
end struct

struct StandbyReport
  databaseId
  archiveGeneration
  appliedLsn
  path
end struct

function isArchiveManifest(value)
  return value is ArchiveManifest
end function

function isArchiveReport(value)
  return value is ArchiveReport
end function

function isPitrReport(value)
  return value is PitrReport
end function

function isStandbyState(value)
  return value is StandbyState
end function

function isStandbyReport(value)
  return value is StandbyReport
end function

function archiveMagic()
  return bytes("MSARC001")
end function

function archiveManifestPath(archivePath)
  return file_api.joinPath(archivePath, "archive.manifest")
end function

function archiveWalDirectory(archivePath)
  return file_api.joinPath(archivePath, "wal")
end function

function archiveWalName(generation)
  return "wal-" + generation + ".log"
end function

function overwriteWhole(path, data)
  if typeof(data) != "bytes" then return fail(INVALID_ARGUMENT, "overwriteWhole", "data must be bytes") end if
  handle = try(file_api.createDurable(path))
  if typeof(handle) == "error" then return handle end if
  written = true
  if len(data) > 0 then written = try(file_api.writeAt(handle, 0, data, 0, len(data))) end if
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(written) == "error" then return written end if
  if typeof(flushed) == "error" then return flushed end if
  if typeof(closed) == "error" then return closed end if
  return true
end function

function replaceWholeAtomic(path, data)
  temporary = path + ".new"
  if file_api.fileExists(temporary) then file_api.deletePath(temporary) end if
  writeWhole(temporary, data)
  file_api.movePath(temporary, path, true)
  return true
end function

function encodeArchiveManifest(manifest)
  if manifest is not ArchiveManifest then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "manifest must be ArchiveManifest") end if
  if typeof(manifest.databaseId) != "bytes" or len(manifest.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "databaseId is invalid") end if
  if typeof(manifest.pageSize) != "int" or manifest.pageSize < 4096 or manifest.pageSize > 32768 then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "pageSize is invalid") end if
  if typeof(manifest.generation) != "int" or manifest.generation < 1 or manifest.generation > MAX_ARCHIVE_GENERATIONS then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "generation is invalid") end if
  if typeof(manifest.baseEndLsn) != "int" or manifest.baseEndLsn < 0 or typeof(manifest.latestEndLsn) != "int" or manifest.latestEndLsn < manifest.baseEndLsn then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "LSN range is invalid") end if
  if typeof(manifest.walLength) != "int" or manifest.walLength != manifest.latestEndLsn then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "WAL length mismatch") end if
  validateRelativePath(manifest.walFileName, "encodeArchiveManifest")
  nameBytes = bytes(manifest.walFileName)
  if len(nameBytes) > 128 then return fail(INVALID_ARGUMENT, "encodeArchiveManifest", "WAL file name is too long") end if
  payload = bytes(64 + len(nameBytes), 0)
  copyExact(payload, 0, manifest.databaseId, 0, 16)
  endian.writeU32LE(payload, 16, manifest.pageSize)
  endian.writeU32LE(payload, 20, manifest.generation)
  endian.writeU64LE(payload, 24, endian.uint64FromInt(manifest.baseEndLsn))
  endian.writeU64LE(payload, 32, endian.uint64FromInt(manifest.latestEndLsn))
  endian.writeU64LE(payload, 40, endian.uint64FromInt(manifest.walLength))
  endian.writeU32LE(payload, 48, manifest.walChecksum)
  endian.writeU32LE(payload, 52, 0)
  endian.writeU16LE(payload, 56, len(nameBytes))
  endian.writeU16LE(payload, 58, 0)
  endian.writeU32LE(payload, 60, 0)
  if len(nameBytes) > 0 then copyExact(payload, 64, nameBytes, 0, len(nameBytes)) end if
  return checksum.encodeEnvelope(archiveMagic(), ARCHIVE_FORMAT_VERSION, ARCHIVE_KIND, 0, payload)
end function

function decodeArchiveManifest(source)
  envelope = checksum.decodeEnvelope(source, archiveMagic(), ARCHIVE_FORMAT_VERSION, ARCHIVE_KIND)
  payload = envelope.payload
  if len(payload) < 64 then return fail(CORRUPT_DATA, "decodeArchiveManifest", "manifest payload is truncated") end if
  if endian.readU32LE(payload, 52) != 0 or endian.readU16LE(payload, 58) != 0 or endian.readU32LE(payload, 60) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeArchiveManifest", "reserved archive fields are non-zero") end if
  generation = endian.readU32LE(payload, 20)
  if generation < 1 or generation > MAX_ARCHIVE_GENERATIONS then return fail(CORRUPT_DATA, "decodeArchiveManifest", "generation is invalid") end if
  baseWords = endian.readU64LE(payload, 24)
  latestWords = endian.readU64LE(payload, 32)
  lengthWords = endian.readU64LE(payload, 40)
  if baseWords.high > endian.MAX_SCALAR_HIGH or latestWords.high > endian.MAX_SCALAR_HIGH or lengthWords.high > endian.MAX_SCALAR_HIGH then return fail(CORRUPT_DATA, "decodeArchiveManifest", "archive LSN exceeds native range") end if
  baseEnd = endian.uint64ToInt(baseWords)
  latestEnd = endian.uint64ToInt(latestWords)
  walLength = endian.uint64ToInt(lengthWords)
  if latestEnd < baseEnd or walLength != latestEnd or walLength > MAX_FILE_BYTES then return fail(CORRUPT_DATA, "decodeArchiveManifest", "archive LSN range is inconsistent") end if
  nameLength = endian.readU16LE(payload, 56)
  if nameLength == 0 or nameLength > 128 or len(payload) != 64 + nameLength then return fail(CORRUPT_DATA, "decodeArchiveManifest", "WAL file name is invalid") end if
  name = decode(slice(payload, 64, nameLength))
  validateRelativePath(name, "decodeArchiveManifest")
  pageSize = endian.readU32LE(payload, 16)
  if pageSize < 4096 or pageSize > 32768 then return fail(CORRUPT_DATA, "decodeArchiveManifest", "pageSize is invalid") end if
  return ArchiveManifest(slice(payload, 0, 16), pageSize, generation, baseEnd, latestEnd, name, walLength, endian.readU32LE(payload, 48))
end function

function readArchiveManifest(archivePath)
  path = archiveManifestPath(archivePath)
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "readArchiveManifest", "archive.manifest is missing") end if
  return decodeArchiveManifest(readWhole(path, 1048576))
end function

function backupEntryLength(manifest, relativePath)
  for each entry in manifest.entries
    if entry.relativePath == relativePath then return entry.length end if
  end for
  return fail(CORRUPT_DATA, "backupEntryLength", "backup entry is missing: " + relativePath)
end function

function snapshotWal(database)
  scanned = wal.scan(database.walWriter, true)
  file_api.flush(database.walWriter.file)
  output = bytes(scanned.validBytes, 0)
  if scanned.validBytes > 0 then file_api.readExactAt(database.walWriter.file, 0, output, 0, scanned.validBytes) end if
  return output
end function

function archiveWalPath(archivePath, manifest)
  return file_api.joinPath(archiveWalDirectory(archivePath), manifest.walFileName)
end function

function verifyWalSnapshot(manifest, walBytes)
  if typeof(walBytes) != "bytes" or len(walBytes) != manifest.walLength then return fail(CORRUPT_DATA, "verifyWalSnapshot", "WAL length mismatch") end if
  if crc32c.compute(walBytes) != manifest.walChecksum then return fail(CORRUPT_DATA, "verifyWalSnapshot", "WAL checksum mismatch") end if
  cursor = 0
  while cursor < len(walBytes)
    if len(walBytes) - cursor < wal.HEADER_SIZE then return fail(CORRUPT_DATA, "verifyWalSnapshot", "WAL header is truncated") end if
    total = endian.readU32LE(walBytes, cursor + 16)
    if total < wal.HEADER_SIZE or total > len(walBytes) - cursor then return fail(CORRUPT_DATA, "verifyWalSnapshot", "WAL record length is invalid") end if
    record = wal.decode(slice(walBytes, cursor, total))
    if record.lsn != cursor then return fail(CORRUPT_DATA, "verifyWalSnapshot", "WAL record LSN mismatch") end if
    cursor = cursor + total
  end while
  return true
end function

function verifyArchive(archivePath)
  if typeof(archivePath) != "string" or len(archivePath) == 0 or not file_api.directoryExists(archivePath) then return fail(CORRUPT_DATA, "verifyArchive", "archive directory is missing") end if
  manifest = readArchiveManifest(archivePath)
  baseManifest = readManifest(file_api.joinPath(archivePath, "base"))
  verifyBackupFiles(file_api.joinPath(archivePath, "base"), baseManifest)
  if not bytesEqual(baseManifest.databaseId, manifest.databaseId) or baseManifest.pageSize != manifest.pageSize then return fail(CORRUPT_DATA, "verifyArchive", "base backup identity mismatch") end if
  baseEnd = backupEntryLength(baseManifest, "wal\\wal.log")
  if baseEnd != manifest.baseEndLsn then return fail(CORRUPT_DATA, "verifyArchive", "base WAL boundary mismatch") end if
  walBytes = readWhole(archiveWalPath(archivePath, manifest), MAX_FILE_BYTES)
  verifyWalSnapshot(manifest, walBytes)
  return manifest
end function

function archiveInit(databasePath, archivePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 or typeof(archivePath) != "string" or len(archivePath) == 0 then return fail(INVALID_ARGUMENT, "archiveInit", "paths must be non-empty") end if
  if file_api.pathExists(archivePath) or file_api.pathExists(archivePath + ".new") then return fail(OBJECT_EXISTS, "archiveInit", "archive destination already exists") end if
  temporary = archivePath + ".new"
  ensureDirectory(temporary)
  ensureDirectory(archiveWalDirectory(temporary))
  database = try(database_manager.open(databasePath))
  if typeof(database) == "error" then return database end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_REPLICATION, diagnostics.AUDIT_SUCCESS, 0, 1, "WAL archive initialized"))
  baseReport = try(runOpen(database, file_api.joinPath(temporary, "base")))
  if typeof(baseReport) == "error" then database_manager.close(database); return baseReport end if
  walBytes = try(snapshotWal(database))
  metadata = database.catalogHandle.metadata
  closeResult = try(database_manager.close(database))
  if typeof(walBytes) == "error" then return walBytes end if
  if typeof(closeResult) == "error" then return closeResult end if
  baseManifest = readManifest(file_api.joinPath(temporary, "base"))
  baseEnd = backupEntryLength(baseManifest, "wal\\wal.log")
  if baseEnd != len(walBytes) then return fail(CORRUPT_DATA, "archiveInit", "database changed while the exclusive archive snapshot was being created") end if
  walName = archiveWalName(1)
  writeWhole(file_api.joinPath(archiveWalDirectory(temporary), walName), walBytes)
  manifest = ArchiveManifest(bytes(metadata.databaseId), metadata.pageSize, 1, baseEnd, len(walBytes), walName, len(walBytes), crc32c.compute(walBytes))
  writeWhole(archiveManifestPath(temporary), encodeArchiveManifest(manifest))
  file_api.movePath(temporary, archivePath, false)
  verifyArchive(archivePath)
  return ArchiveReport(bytes(manifest.databaseId), manifest.generation, manifest.baseEndLsn, manifest.latestEndLsn, archivePath)
end function

function prefixMatches(previous, current)
  if len(current) < len(previous) then return false end if
  if len(previous) == 0 then return true end if
  for index = 0 to len(previous) - 1
    if previous[index] != current[index] then return false end if
  end for
  return true
end function

function liveWalPath(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "liveWalPath", "databasePath must be non-empty") end if
  return file_api.joinPath(file_api.joinPath(databasePath, "wal"), "wal.log")
end function

function snapshotDurableWalLive(databasePath)
  walPath = liveWalPath(databasePath)
  durableLsn = wal.readDurableMarker(walPath)
  if durableLsn < 0 then return fail(CORRUPT_DATA, "snapshotDurableWalLive", "durable WAL marker is missing; open the database once with MiniSQL 1.0") end if
  if durableLsn > MAX_FILE_BYTES then return fail(CORRUPT_DATA, "snapshotDurableWalLive", "durable WAL exceeds archive safety limit") end if
  handle = try(file_api.openRead(walPath))
  if typeof(handle) == "error" then return handle end if
  currentSize = try(file_api.size(handle))
  if typeof(currentSize) == "error" then ignoredClose = try(file_api.close(handle)); return currentSize end if
  if durableLsn > currentSize then ignoredClose = try(file_api.close(handle)); return fail(CORRUPT_DATA, "snapshotDurableWalLive", "durable marker exceeds WAL file size") end if
  output = bytes(durableLsn, 0)
  readResult = true
  if durableLsn > 0 then readResult = try(file_api.readExactAt(handle, 0, output, 0, durableLsn)) end if
  closeResult = try(file_api.close(handle))
  if typeof(readResult) == "error" then return readResult end if
  if typeof(closeResult) == "error" then return closeResult end if
  scanned = wal.scanSnapshot(output)
  if scanned.truncatedTail or scanned.validBytes != durableLsn then return fail(CORRUPT_DATA, "snapshotDurableWalLive", "durable WAL marker is not a complete record boundary") end if
  return output
end function

function archiveWalLive(databasePath, archivePath)
  manifest = verifyArchive(archivePath)
  previous = readWhole(archiveWalPath(archivePath, manifest), MAX_FILE_BYTES)
  walBytes = snapshotDurableWalLive(databasePath)
  if not prefixMatches(previous, walBytes) then return fail(CORRUPT_DATA, "archiveWalLive", "live WAL continuity was lost; create a new base archive") end if
  if len(walBytes) == len(previous) then
    return ArchiveReport(bytes(manifest.databaseId), manifest.generation, manifest.baseEndLsn, manifest.latestEndLsn, archivePath)
  end if
  if manifest.generation >= MAX_ARCHIVE_GENERATIONS then return fail(UNSUPPORTED_FORMAT, "archiveWalLive", "archive generation limit reached") end if
  generation = manifest.generation + 1
  walName = archiveWalName(generation)
  writeWhole(file_api.joinPath(archiveWalDirectory(archivePath), walName), walBytes)
  next = ArchiveManifest(bytes(manifest.databaseId), manifest.pageSize, generation, manifest.baseEndLsn, len(walBytes), walName, len(walBytes), crc32c.compute(walBytes))
  replaceWholeAtomic(archiveManifestPath(archivePath), encodeArchiveManifest(next))
  verifyArchive(archivePath)
  return ArchiveReport(bytes(next.databaseId), next.generation, next.baseEndLsn, next.latestEndLsn, archivePath)
end function

function archiveWal(databasePath, archivePath)
  manifest = verifyArchive(archivePath)
  if manifest.generation >= MAX_ARCHIVE_GENERATIONS then return fail(UNSUPPORTED_FORMAT, "archiveWal", "archive generation limit reached") end if
  database = try(database_manager.open(databasePath))
  if typeof(database) == "error" then return database end if
  if not bytesEqual(database.catalogHandle.metadata.databaseId, manifest.databaseId) then database_manager.close(database); return fail(CORRUPT_DATA, "archiveWal", "source database identity mismatch") end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_REPLICATION, diagnostics.AUDIT_SUCCESS, 0, 1, "WAL archive generation captured"))
  walBytes = try(snapshotWal(database))
  closeResult = try(database_manager.close(database))
  if typeof(walBytes) == "error" then return walBytes end if
  if typeof(closeResult) == "error" then return closeResult end if
  previous = readWhole(archiveWalPath(archivePath, manifest), MAX_FILE_BYTES)
  if not prefixMatches(previous, walBytes) then return fail(CORRUPT_DATA, "archiveWal", "WAL continuity was lost; create a new base archive") end if
  generation = manifest.generation + 1
  walName = archiveWalName(generation)
  writeWhole(file_api.joinPath(archiveWalDirectory(archivePath), walName), walBytes)
  next = ArchiveManifest(bytes(manifest.databaseId), manifest.pageSize, generation, manifest.baseEndLsn, len(walBytes), walName, len(walBytes), crc32c.compute(walBytes))
  replaceWholeAtomic(archiveManifestPath(archivePath), encodeArchiveManifest(next))
  verifyArchive(archivePath)
  return ArchiveReport(bytes(next.databaseId), next.generation, next.baseEndLsn, next.latestEndLsn, archivePath)
end function

function walPrefixAt(walBytes, targetLsn)
  if typeof(targetLsn) != "int" or targetLsn < 0 or targetLsn > len(walBytes) then return fail(INVALID_ARGUMENT, "walPrefixAt", "target LSN is outside the archive") end if
  cursor = 0
  while cursor < targetLsn
    if targetLsn - cursor < wal.HEADER_SIZE then return fail(INVALID_ARGUMENT, "walPrefixAt", "target LSN is not a record boundary") end if
    total = endian.readU32LE(walBytes, cursor + 16)
    if total < wal.HEADER_SIZE or total > targetLsn - cursor then return fail(INVALID_ARGUMENT, "walPrefixAt", "target LSN is not a complete record boundary") end if
    record = wal.decode(slice(walBytes, cursor, total))
    if record.lsn != cursor then return fail(CORRUPT_DATA, "walPrefixAt", "WAL LSN mismatch") end if
    cursor = cursor + total
  end while
  if cursor != targetLsn then return fail(INVALID_ARGUMENT, "walPrefixAt", "target LSN is not a record boundary") end if
  return slice(walBytes, 0, targetLsn)
end function

function restoreToLsn(archivePath, databasePath, targetLsn)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "restoreToLsn", "databasePath must be non-empty") end if
  if file_api.pathExists(databasePath) or file_api.pathExists(databasePath + ".pitr-stage") then return fail(OBJECT_EXISTS, "restoreToLsn", "database destination already exists") end if
  manifest = verifyArchive(archivePath)
  if typeof(targetLsn) != "int" or targetLsn < manifest.baseEndLsn or targetLsn > manifest.latestEndLsn then return fail(INVALID_ARGUMENT, "restoreToLsn", "target must be between base and latest archived LSN") end if
  walBytes = readWhole(archiveWalPath(archivePath, manifest), MAX_FILE_BYTES)
  prefix = walPrefixAt(walBytes, targetLsn)
  stage = databasePath + ".pitr-stage"
  restored = restore(file_api.joinPath(archivePath, "base"), stage)
  overwriteWhole(file_api.joinPath(file_api.joinPath(stage, "wal"), "wal.log"), prefix)
  checkpointPath = file_api.joinPath(file_api.joinPath(stage, "wal"), "checkpoint.meta")
  checkpointFile = try(checkpoint.open(checkpointPath))
  if typeof(checkpointFile) == "error" then return checkpointFile end if
  resetCheckpoint = try(checkpoint.publish(checkpointFile, 0, 0, 0))
  closeCheckpoint = try(checkpoint.close(checkpointFile))
  if typeof(resetCheckpoint) == "error" then return resetCheckpoint end if
  if typeof(closeCheckpoint) == "error" then return closeCheckpoint end if
  database = try(database_manager.open(stage))
  if typeof(database) == "error" then return database end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_RESTORE, diagnostics.AUDIT_SUCCESS, 0, 1, "point-in-time restore completed at LSN " + targetLsn))
  if not bytesEqual(database.catalogHandle.metadata.databaseId, manifest.databaseId) then database_manager.close(database); return fail(CORRUPT_DATA, "restoreToLsn", "restored database identity mismatch") end if
  database_manager.close(database)
  file_api.movePath(stage, databasePath, false)
  return PitrReport(bytes(manifest.databaseId), targetLsn, databasePath)
end function

function restoreLatest(archivePath, databasePath)
  manifest = verifyArchive(archivePath)
  return restoreToLsn(archivePath, databasePath, manifest.latestEndLsn)
end function

function standbyMagic()
  return bytes("MSSTB001")
end function

function standbyStatePath(databasePath)
  return file_api.joinPath(databasePath, "standby.state")
end function

function standbyPromotedPath(databasePath)
  return file_api.joinPath(databasePath, "standby.promoted")
end function

function encodeStandbyState(state)
  if state is not StandbyState then return fail(INVALID_ARGUMENT, "encodeStandbyState", "state must be StandbyState") end if
  if typeof(state.databaseId) != "bytes" or len(state.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encodeStandbyState", "databaseId is invalid") end if
  if typeof(state.archiveGeneration) != "int" or state.archiveGeneration < 1 or state.archiveGeneration > MAX_ARCHIVE_GENERATIONS then return fail(INVALID_ARGUMENT, "encodeStandbyState", "archive generation is invalid") end if
  if typeof(state.appliedLsn) != "int" or state.appliedLsn < 0 then return fail(INVALID_ARGUMENT, "encodeStandbyState", "applied LSN is invalid") end if
  payload = bytes(40, 0)
  copyExact(payload, 0, state.databaseId, 0, 16)
  endian.writeU32LE(payload, 16, state.archiveGeneration)
  endian.writeU32LE(payload, 20, 0)
  endian.writeU64LE(payload, 24, endian.uint64FromInt(state.appliedLsn))
  endian.writeU64LE(payload, 32, endian.makeUInt64(0, 0))
  return checksum.encodeEnvelope(standbyMagic(), STANDBY_FORMAT_VERSION, STANDBY_KIND, 0, payload)
end function

function decodeStandbyState(source)
  envelope = checksum.decodeEnvelope(source, standbyMagic(), STANDBY_FORMAT_VERSION, STANDBY_KIND)
  payload = envelope.payload
  if len(payload) != 40 or endian.readU32LE(payload, 20) != 0 then return fail(CORRUPT_DATA, "decodeStandbyState", "standby state header is invalid") end if
  reserved = endian.readU64LE(payload, 32)
  if reserved.high != 0 or reserved.low != 0 then return fail(UNSUPPORTED_FORMAT, "decodeStandbyState", "standby state reserved field is non-zero") end if
  generation = endian.readU32LE(payload, 16)
  lsnWords = endian.readU64LE(payload, 24)
  if generation < 1 or generation > MAX_ARCHIVE_GENERATIONS or lsnWords.high > endian.MAX_SCALAR_HIGH then return fail(CORRUPT_DATA, "decodeStandbyState", "standby state values are invalid") end if
  return StandbyState(slice(payload, 0, 16), generation, endian.uint64ToInt(lsnWords))
end function

function readStandbyState(databasePath)
  path = standbyStatePath(databasePath)
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "readStandbyState", "standby.state is missing or standby is already promoted") end if
  return decodeStandbyState(readWhole(path, 1048576))
end function

function writeStandbyState(databasePath, state)
  return replaceWholeAtomic(standbyStatePath(databasePath), encodeStandbyState(state))
end function

function materializeStandby(archivePath, databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "materializeStandby", "databasePath must be non-empty") end if
  stage = databasePath + ".standby-stage"
  if file_api.pathExists(databasePath) or file_api.pathExists(stage) then return fail(OBJECT_EXISTS, "materializeStandby", "standby destination or staging path already exists") end if
  manifest = verifyArchive(archivePath)
  // Publish only after the standby marker is durable. A crash before the final
  // rename can leave a clearly named staging directory, but never an unmarked
  // writable database at the requested destination.
  restored = restoreLatest(archivePath, stage)
  state = StandbyState(bytes(manifest.databaseId), manifest.generation, manifest.latestEndLsn)
  writeStandbyState(stage, state)
  file_api.movePath(stage, databasePath, false)
  return StandbyReport(bytes(state.databaseId), state.archiveGeneration, state.appliedLsn, databasePath)
end function

function refreshStandby(archivePath, databasePath)
  manifest = verifyArchive(archivePath)
  state = readStandbyState(databasePath)
  if not bytesEqual(state.databaseId, manifest.databaseId) then return fail(CORRUPT_DATA, "refreshStandby", "standby and archive database identities differ") end if
  if manifest.generation < state.archiveGeneration or manifest.latestEndLsn < state.appliedLsn then return fail(CORRUPT_DATA, "refreshStandby", "archive is older than the standby") end if
  archiveWalBytes = readWhole(archiveWalPath(archivePath, manifest), MAX_FILE_BYTES)
  verifyWalSnapshot(manifest, archiveWalBytes)
  currentWalPath = file_api.joinPath(file_api.joinPath(databasePath, "wal"), "wal.log")
  currentWal = readWhole(currentWalPath, MAX_FILE_BYTES)
  if not prefixMatches(currentWal, archiveWalBytes) then return fail(CORRUPT_DATA, "refreshStandby", "standby WAL is not a prefix of the archive") end if
  replaceWholeAtomic(currentWalPath, archiveWalBytes)
  checkpointPath = file_api.joinPath(file_api.joinPath(databasePath, "wal"), "checkpoint.meta")
  checkpointFile = try(checkpoint.open(checkpointPath))
  if typeof(checkpointFile) == "error" then return checkpointFile end if
  resetCheckpoint = try(checkpoint.publish(checkpointFile, 0, 0, 0))
  closeCheckpoint = try(checkpoint.close(checkpointFile))
  if typeof(resetCheckpoint) == "error" then return resetCheckpoint end if
  if typeof(closeCheckpoint) == "error" then return closeCheckpoint end if
  database = try(database_manager.openStandby(databasePath))
  if typeof(database) == "error" then return database end if
  if not bytesEqual(database.catalogHandle.metadata.databaseId, manifest.databaseId) then database_manager.close(database); return fail(CORRUPT_DATA, "refreshStandby", "standby identity changed during recovery") end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_REPLICATION, diagnostics.AUDIT_SUCCESS, 0, 1, "standby refreshed to LSN " + manifest.latestEndLsn))
  closeResult = try(database_manager.close(database))
  if typeof(closeResult) == "error" then return closeResult end if
  next = StandbyState(bytes(manifest.databaseId), manifest.generation, manifest.latestEndLsn)
  writeStandbyState(databasePath, next)
  return StandbyReport(bytes(next.databaseId), next.archiveGeneration, next.appliedLsn, databasePath)
end function

function promoteStandby(databasePath)
  state = readStandbyState(databasePath)
  database = try(database_manager.openStandby(databasePath))
  if typeof(database) == "error" then return database end if
  if not bytesEqual(database.catalogHandle.metadata.databaseId, state.databaseId) then database_manager.close(database); return fail(CORRUPT_DATA, "promoteStandby", "standby identity mismatch") end if
  ignoredAudit = try(database_manager.audit(database, diagnostics.AUDIT_REPLICATION, diagnostics.AUDIT_SUCCESS, 0, 1, "standby promoted at LSN " + state.appliedLsn))
  closeResult = try(database_manager.close(database))
  if typeof(closeResult) == "error" then return closeResult end if
  marker = encodeStandbyState(state)
  replaceWholeAtomic(standbyPromotedPath(databasePath), marker)
  removed = try(file_api.deletePath(standbyStatePath(databasePath)))
  if typeof(removed) == "error" then return removed end if
  return StandbyReport(bytes(state.databaseId), state.archiveGeneration, state.appliedLsn, databasePath)
end function

function standbyStatus(databasePath)
  return readStandbyState(databasePath)
end function

function m0SelfTestLine()
  return "MiniSQL backup tool M0 self-test: SUCCESS"
end function

function versionLine()
  return version.versionLine("backup")
end function

function componentName()
  return "tools.backup"
end function

function targetMilestone()
  return "M20"
end function

function isImplemented()
  return true
end function
