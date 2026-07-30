package minisql.common.diagnostics

import minisql.common.endian as endian
import minisql.common.uuid as uuid
import minisql.platform.file as file_api

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const IO_FAILURE = 9005
const CLOSED_HANDLE = 9008

const AUDIT_VERSION = 1
const AUDIT_HEADER_BYTES = 120
const AUDIT_HASH_BYTES = 32
const AUDIT_KEY_BYTES = 32
const MAX_AUDIT_DETAIL_BYTES = 4096
const MAX_AUDIT_FILE_BYTES = 67108864

const AUDIT_LOGIN = 1
const AUDIT_LOGOUT = 2
const AUDIT_DDL = 3
const AUDIT_DCL = 4
const AUDIT_MAINTENANCE = 5
const AUDIT_BACKUP = 6
const AUDIT_RESTORE = 7
const AUDIT_REPLICATION = 8
const AUDIT_SERVER = 9
const AUDIT_ROTATION = 10

const AUDIT_FAILURE = 0
const AUDIT_SUCCESS = 1

extern function GetSystemTimeAsFileTime(fileTime as bytes) from "kernel32.dll" symbol "GetSystemTimeAsFileTime" returns void

struct Diagnostic
  code
  severity
  message
end struct

struct AuditScan
  recordCount
  lastSequence
  lastHash
  validBytes
end struct

struct AuditLog
  path
  file
  key
  nextSequence
  lastHash
  closed
end struct

function make(code, severity, message)
  return Diagnostic(code, severity, message)
end function

function fail(code, operation, message)
  return error(code, "common.diagnostics." + operation + ": " + message)
end function

function auditMagic()
  return bytes("MSAUD001")
end function

function zeroHash()
  return bytes(AUDIT_HASH_BYTES, 0)
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  difference = 0
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      difference = difference | (left[index] ^ right[index])
    end for
  end if
  return difference == 0
end function

function copyExact(destination, destinationOffset, source, sourceOffset, count)
  copyBytes(destination, destinationOffset, source, sourceOffset, count)
  return destinationOffset + count
end function

function readWhole(path, maximum)
  if not file_api.fileExists(path) then return bytes(0) end if
  file = file_api.openRead(path)
  length = file_api.size(file)
  if length > maximum then file_api.close(file); return fail(CORRUPT_DATA, "readWhole", "audit file exceeds safety limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(file, 0, output, 0, length) end if
  file_api.close(file)
  return output
end function

function writeWholeDurable(path, data)
  file = file_api.createDurable(path)
  if len(data) > 0 then file_api.writeAt(file, 0, data, 0, len(data)) end if
  file_api.flush(file)
  file_api.close(file)
  return true
end function

function validateDetail(detail, operation)
  if typeof(detail) != "string" then return fail(INVALID_ARGUMENT, operation, "detail must be string") end if
  raw = bytes(detail)
  if len(raw) > MAX_AUDIT_DETAIL_BYTES then return fail(INVALID_ARGUMENT, operation, "detail exceeds audit limit") end if
  for each value in raw
    if value == 0 then return fail(INVALID_ARGUMENT, operation, "detail must not contain NUL") end if
  end for
  return raw
end function

function recordDigest(key, header, detailBytes)
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "recordDigest", "audit key is invalid") end if
  material = bytes(88 + len(detailBytes), 0)
  copyExact(material, 0, header, 0, 88)
  if len(detailBytes) > 0 then copyExact(material, 88, detailBytes, 0, len(detailBytes)) end if
  digest = uuid.hmacSha256(key, material)
  uuid.wipeSecret(material)
  return digest
end function

function encodeAuditRecord(key, sequence, timestamp, eventType, outcome, sessionId, principalId, previousHash, detail)
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "audit key is invalid") end if
  if typeof(sequence) != "int" or sequence < 1 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "sequence must be positive") end if
  if typeof(timestamp) != "int" or timestamp < 0 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "timestamp is invalid") end if
  if typeof(eventType) != "int" or eventType < 1 or eventType > AUDIT_ROTATION then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "event type is invalid") end if
  if outcome != AUDIT_FAILURE and outcome != AUDIT_SUCCESS then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "outcome is invalid") end if
  if typeof(sessionId) != "int" or sessionId < 0 or typeof(principalId) != "int" or principalId < 0 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "identifiers are invalid") end if
  if typeof(previousHash) != "bytes" or len(previousHash) != AUDIT_HASH_BYTES then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "previous hash is invalid") end if
  detailBytes = validateDetail(detail, "encodeAuditRecord")
  output = bytes(AUDIT_HEADER_BYTES + len(detailBytes), 0)
  copyExact(output, 0, auditMagic(), 0, 8)
  endian.writeU16LE(output, 8, AUDIT_VERSION)
  endian.writeU16LE(output, 10, eventType)
  endian.writeU16LE(output, 12, outcome)
  endian.writeU16LE(output, 14, 0)
  endian.writeU64LE(output, 16, endian.uint64FromInt(sequence))
  endian.writeU64LE(output, 24, endian.uint64FromInt(timestamp))
  endian.writeU64LE(output, 32, endian.uint64FromInt(sessionId))
  endian.writeU64LE(output, 40, endian.uint64FromInt(principalId))
  endian.writeU32LE(output, 48, len(detailBytes))
  endian.writeU32LE(output, 52, 0)
  copyExact(output, 56, previousHash, 0, AUDIT_HASH_BYTES)
  digest = recordDigest(key, output, detailBytes)
  copyExact(output, 88, digest, 0, AUDIT_HASH_BYTES)
  if len(detailBytes) > 0 then copyExact(output, AUDIT_HEADER_BYTES, detailBytes, 0, len(detailBytes)) end if
  uuid.wipeSecret(digest)
  return output
end function

function scanAuditBytesFromSequence(source, key, expectedPreviousHash, expectedPreviousSequence, allowTornTail)
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "source must be bytes") end if
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "audit key is invalid") end if
  if typeof(expectedPreviousHash) != "bytes" or len(expectedPreviousHash) != AUDIT_HASH_BYTES then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "expected hash is invalid") end if
  if typeof(expectedPreviousSequence) != "int" or expectedPreviousSequence < 0 then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "expected previous sequence is invalid") end if
  if typeof(allowTornTail) != "bool" then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "allowTornTail must be bool") end if
  cursor = 0
  count = 0
  sequence = expectedPreviousSequence
  previous = bytes(expectedPreviousHash)
  while cursor < len(source)
    remaining = len(source) - cursor
    if remaining < AUDIT_HEADER_BYTES then
      if allowTornTail then break end if
      return fail(CORRUPT_DATA, "scanAuditBytes", "audit tail is truncated")
    end if
    header = slice(source, cursor, AUDIT_HEADER_BYTES)
    if not bytesEqual(slice(header, 0, 8), auditMagic()) then return fail(CORRUPT_DATA, "scanAuditBytes", "audit magic mismatch") end if
    if endian.readU16LE(header, 8) != AUDIT_VERSION or endian.readU16LE(header, 14) != 0 or endian.readU32LE(header, 52) != 0 then return fail(CORRUPT_DATA, "scanAuditBytes", "audit header is unsupported") end if
    eventType = endian.readU16LE(header, 10)
    outcome = endian.readU16LE(header, 12)
    if eventType < AUDIT_LOGIN or eventType > AUDIT_ROTATION then return fail(CORRUPT_DATA, "scanAuditBytes", "audit event type is invalid") end if
    if outcome != AUDIT_FAILURE and outcome != AUDIT_SUCCESS then return fail(CORRUPT_DATA, "scanAuditBytes", "audit outcome is invalid") end if
    detailLength = endian.readU32LE(header, 48)
    if detailLength > MAX_AUDIT_DETAIL_BYTES then return fail(CORRUPT_DATA, "scanAuditBytes", "audit detail exceeds limit") end if
    total = AUDIT_HEADER_BYTES + detailLength
    if remaining < total then
      if allowTornTail then break end if
      return fail(CORRUPT_DATA, "scanAuditBytes", "audit record is truncated")
    end if
    currentSequence = endian.uint64ToInt(endian.readU64LE(header, 16))
    if currentSequence != sequence + 1 then return fail(CORRUPT_DATA, "scanAuditBytes", "audit sequence is not continuous") end if
    if not bytesEqual(slice(header, 56, AUDIT_HASH_BYTES), previous) then return fail(CORRUPT_DATA, "scanAuditBytes", "audit hash chain is broken") end if
    detailBytes = slice(source, cursor + AUDIT_HEADER_BYTES, detailLength)
    expected = recordDigest(key, header, detailBytes)
    actual = slice(header, 88, AUDIT_HASH_BYTES)
    valid = bytesEqual(expected, actual)
    uuid.wipeSecret(expected)
    if not valid then return fail(CORRUPT_DATA, "scanAuditBytes", "audit record hash mismatch") end if
    uuid.wipeSecret(previous)
    previous = actual
    sequence = currentSequence
    count = count + 1
    cursor = cursor + total
  end while
  return AuditScan(count, sequence, previous, cursor)
end function

function scanAuditBytes(source, key, expectedPreviousHash, allowTornTail)
  return scanAuditBytesFromSequence(source, key, expectedPreviousHash, 0, allowTornTail)
end function

function ensureDirectory(path)
  if file_api.directoryExists(path) then return true end if
  return file_api.createDirectory(path)
end function

function auditKeyPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.key")
end function

function auditAnchorPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.anchor")
end function

function auditPreviousPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.previous")
end function

function auditPreviousAnchorPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.previous.anchor")
end function

function readAuditKey(databasePath)
  path = auditKeyPath(databasePath)
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "readAuditKey", "audit key is missing") end if
  key = readWhole(path, AUDIT_KEY_BYTES)
  if len(key) != AUDIT_KEY_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "readAuditKey", "audit key is invalid") end if
  return key
end function

function ensureAuditKey(databasePath)
  path = auditKeyPath(databasePath)
  if file_api.fileExists(path) then return readAuditKey(databasePath) end if
  key = uuid.randomBytes(AUDIT_KEY_BYTES)
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then uuid.wipeSecret(key); return handle end if
  written = try(file_api.writeAt(handle, 0, key, 0, len(key)))
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(written) == "error" then uuid.wipeSecret(key); return written end if
  if typeof(flushed) == "error" then uuid.wipeSecret(key); return flushed end if
  if typeof(closed) == "error" then uuid.wipeSecret(key); return closed end if
  return key
end function

function openAudit(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "openAudit", "databasePath must be non-empty") end if
  auditDirectory = file_api.joinPath(databasePath, "audit")
  ensureDirectory(auditDirectory)
  anchorPath = file_api.joinPath(auditDirectory, "audit.anchor")
  logPath = file_api.joinPath(auditDirectory, "audit.log")
  key = try(ensureAuditKey(databasePath))
  if typeof(key) == "error" then return key end if
  if not file_api.fileExists(anchorPath) then writeWholeDurable(anchorPath, zeroHash()) end if
  anchor = readWhole(anchorPath, AUDIT_HASH_BYTES)
  if len(anchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "openAudit", "audit anchor is invalid") end if
  if not file_api.fileExists(logPath) then writeWholeDurable(logPath, bytes(0)) end if
  source = readWhole(logPath, MAX_AUDIT_FILE_BYTES)
  scanned = try(scanAuditBytes(source, key, anchor, true))
  if typeof(scanned) == "error" then uuid.wipeSecret(key); return scanned end if
  if scanned.validBytes != len(source) then
    repair = file_api.openReadWrite(logPath, false)
    file_api.truncate(repair, scanned.validBytes)
    file_api.flush(repair)
    file_api.close(repair)
  end if
  file = file_api.openReadWrite(logPath, false)
  return AuditLog(logPath, file, key, scanned.lastSequence + 1, bytes(scanned.lastHash), false)
end function

function validateAuditOpen(log, operation)
  if log is not AuditLog then return fail(INVALID_ARGUMENT, operation, "log must be AuditLog") end if
  if log.closed then return fail(CLOSED_HANDLE, operation, "audit log is closed") end if
  return true
end function

function appendAudit(log, eventType, outcome, sessionId, principalId, detail)
  validateAuditOpen(log, "appendAudit")
  fileTime = bytes(8, 0)
  GetSystemTimeAsFileTime(fileTime)
  timestamp = endian.uint64ToInt(endian.readU64LE(fileTime, 0))
  encoded = encodeAuditRecord(log.key, log.nextSequence, timestamp, eventType, outcome, sessionId, principalId, log.lastHash, detail)
  // Validate the one-record suffix before publishing it. A full segment starts
  // at sequence 1, but an append suffix may start at any later sequence and must
  // therefore carry its predecessor sequence explicitly.
  scanned = scanAuditBytesFromSequence(encoded, log.key, log.lastHash, log.nextSequence - 1, false)
  offset = file_api.append(log.file, encoded, 0, len(encoded))
  file_api.flush(log.file)
  uuid.wipeSecret(log.lastHash)
  log.lastHash = bytes(scanned.lastHash)
  log.nextSequence = scanned.lastSequence + 1
  return offset
end function

function verifyAudit(databasePath)
  auditDirectory = file_api.joinPath(databasePath, "audit")
  anchorPath = auditAnchorPath(databasePath)
  logPath = file_api.joinPath(auditDirectory, "audit.log")
  if not file_api.fileExists(anchorPath) or not file_api.fileExists(logPath) then return fail(CORRUPT_DATA, "verifyAudit", "audit files are missing") end if
  key = try(readAuditKey(databasePath))
  if typeof(key) == "error" then return key end if
  anchor = readWhole(anchorPath, AUDIT_HASH_BYTES)
  if len(anchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "audit anchor is invalid") end if
  previousPath = auditPreviousPath(databasePath)
  previousAnchorPath = auditPreviousAnchorPath(databasePath)
  if file_api.fileExists(previousPath) then
    if not file_api.fileExists(previousAnchorPath) then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor is missing") end if
    previousAnchor = readWhole(previousAnchorPath, AUDIT_HASH_BYTES)
    if len(previousAnchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor is invalid") end if
    previous = try(scanAuditBytes(readWhole(previousPath, MAX_AUDIT_FILE_BYTES), key, previousAnchor, false))
    if typeof(previous) == "error" then uuid.wipeSecret(key); return previous end if
    if not bytesEqual(previous.lastHash, anchor) then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor mismatch") end if
  else if file_api.fileExists(previousAnchorPath) then
    uuid.wipeSecret(key)
    return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor exists without segment")
  end if
  result = try(scanAuditBytes(readWhole(logPath, MAX_AUDIT_FILE_BYTES), key, anchor, false))
  uuid.wipeSecret(key)
  if typeof(result) == "error" then return result end if
  return result
end function

function rotateAudit(log, databasePath, sessionId, principalId)
  validateAuditOpen(log, "rotateAudit")
  // Preserve the starting hash of the segment being rotated. After the second
  // and later rotation this is intentionally non-zero; assuming zero would make
  // an otherwise valid retained segment unverifiable.
  startingAnchor = readWhole(auditAnchorPath(databasePath), AUDIT_HASH_BYTES)
  if len(startingAnchor) != AUDIT_HASH_BYTES then return fail(CORRUPT_DATA, "rotateAudit", "current audit anchor is invalid") end if
  appendAudit(log, AUDIT_ROTATION, AUDIT_SUCCESS, sessionId, principalId, "audit rotation")
  finalHash = bytes(log.lastHash)
  file_api.close(log.file)
  log.closed = true
  previousPath = auditPreviousPath(databasePath)
  previousAnchorPath = auditPreviousAnchorPath(databasePath)
  if file_api.fileExists(previousPath) then file_api.deletePath(previousPath) end if
  if file_api.fileExists(previousAnchorPath) then file_api.deletePath(previousAnchorPath) end if
  file_api.movePath(log.path, previousPath, false)
  writeWholeDurable(previousAnchorPath, startingAnchor)
  writeWholeDurable(auditAnchorPath(databasePath), finalHash)
  writeWholeDurable(log.path, bytes(0))
  return openAudit(databasePath)
end function

function snapshotAuditBytes(log, maximum)
  validateAuditOpen(log, "snapshotAuditBytes")
  if typeof(maximum) != "int" or maximum < 0 or maximum > MAX_AUDIT_FILE_BYTES then return fail(INVALID_ARGUMENT, "snapshotAuditBytes", "maximum is invalid") end if
  file_api.flush(log.file)
  length = file_api.size(log.file)
  if length > maximum then return fail(CORRUPT_DATA, "snapshotAuditBytes", "audit file exceeds snapshot limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(log.file, 0, output, 0, length) end if
  return output
end function

function snapshotAuditKey(log)
  validateAuditOpen(log, "snapshotAuditKey")
  return bytes(log.key)
end function

function closeAudit(log)
  validateAuditOpen(log, "closeAudit")
  file_api.flush(log.file)
  file_api.close(log.file)
  uuid.wipeSecret(log.lastHash)
  uuid.wipeSecret(log.key)
  log.key = void
  log.closed = true
  return true
end function

function componentName()
  return "common.diagnostics"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
