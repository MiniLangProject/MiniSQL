package minisql.catalog.catalog
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.metadata as metadata
import minisql.common.endian as endian
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import minisql.transaction.checkpoint as checkpoint
import minisql.transaction.wal as wal

// Database catalog lifecycle and durable bootstrap layout. Opening a database
// validates all format identities before exposing handles; creation publishes
// fully initialized metadata, WAL, and checkpoint state as one logical unit.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const OBJECT_EXISTS = 9013
const OBJECT_NOT_FOUND = 9014
const SECURITY_STATE = 9030

const DATABASE_META_FILE_ID = 1
const CATALOG_FILE_ID = 2
const SECURITY_FILE_ID = 0
const BLOB_LENGTH_OFFSET = 64
const BLOB_DATA_OFFSET = 68

// Defines the database handle record used by this module.
struct DatabaseHandle
  // Path field of the database handle.
  path
  // Meta file field of the database handle.
  metaFile
  // Catalog file field of the database handle.
  catalogFile
  // Security file field of the database handle.
  securityFile
  // Metadata field of the database handle.
  metadata
  // Catalog field of the database handle.
  catalog
  // Security field of the database handle.
  security
  // Security failed field of the database handle.
  securityFailed
  // Closed field of the database handle.
  closed
end struct

// Evaluates whether the supplied input satisfies the database handle predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isDatabaseHandle(value)
  return value is DatabaseHandle
end function

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "catalog.catalog." + operation + ": " + message)
end function

// Performs the join path operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function joinPath(left, right)
  if len(left) == 0 then return right end if
  last = bytes(left)[len(bytes(left)) - 1]
  if last == 92 or last == 47 then return left + right end if
  return left + "\\" + right
end function

// Performs the table file name operation for this module.
// Inputs: `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tableFileName(tableId)
  if typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "tableFileName", "tableId must be non-negative") end if
  return "t" + tableId + ".tbl"
end function

// Performs the table file path operation for this module.
// Inputs: `databasePath`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tableFilePath(databasePath, tableId)
  return joinPath(joinPath(databasePath, "tables"), tableFileName(tableId))
end function

// Performs the security file path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function securityFilePath(databasePath)
  return joinPath(joinPath(databasePath, "catalog"), "security.tbl")
end function

// Validates the name.
// Inputs: `name`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateName(name, operation)
  if typeof(name) != "string" or len(name) == 0 or len(bytes(name)) > 128 then return fail(INVALID_ARGUMENT, operation, "name must be 1..128 UTF-8 bytes") end if
  raw = bytes(name)
  for each value in raw
    allowed = (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or (value >= 48 and value <= 57) or value == 95 or value == 45
    if not allowed then return fail(INVALID_ARGUMENT, operation, "name contains a path or unsupported character") end if
  end for
  return true
end function

// Performs the bytes equal operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

// Writes the blob page.
// Inputs: `pagedFile`, `pageNumber`, `encoded`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeBlobPage(pagedFile, pageNumber, encoded)
  if typeof(encoded) != "bytes" then return fail(INVALID_ARGUMENT, "writeBlobPage", "encoded value must be bytes") end if
  if len(encoded) > pagedFile.pageSize - BLOB_DATA_OFFSET then return fail(INVALID_ARGUMENT, "writeBlobPage", "metadata does not fit in one page") end if
  pageBytes = page.create(pagedFile.pageSize, page.TYPE_CATALOG, pagedFile.fileId, pageNumber)
  endian.writeU32LE(pageBytes, BLOB_LENGTH_OFFSET, len(encoded))
  if len(encoded) > 0 then copyBytes(pageBytes, BLOB_DATA_OFFSET, encoded, 0, len(encoded)) end if
  page.reseal(pageBytes)
  if pageNumber == pagedFile.pageCount then
    paged_file.appendPage(pagedFile, pageBytes)
  else
    paged_file.writePage(pagedFile, pageNumber, pageBytes)
    paged_file.flush(pagedFile)
  end if
  return true
end function

// Reads the blob page.
// Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readBlobPage(pagedFile, pageNumber)
  pageBytes = paged_file.readPage(pagedFile, pageNumber)
  header = page.verify(pageBytes)
  if header.pageType != page.TYPE_CATALOG then return fail(CORRUPT_DATA, "readBlobPage", "metadata page has wrong type") end if
  length = endian.readU32LE(pageBytes, BLOB_LENGTH_OFFSET)
  if length > pagedFile.pageSize - BLOB_DATA_OFFSET then return fail(CORRUPT_DATA, "readBlobPage", "metadata length exceeds page") end if
  return slice(pageBytes, BLOB_DATA_OFFSET, length)
end function

// Ensures the layout.
// Inputs: `root`. Returns success after all invariants hold; violations are reported as structured errors.
function ensureLayout(root)
  file_api.createDirectory(root)
  file_api.createDirectory(joinPath(root, "catalog"))
  file_api.createDirectory(joinPath(root, "tables"))
  file_api.createDirectory(joinPath(root, "indexes"))
  file_api.createDirectory(joinPath(root, "wal"))
  file_api.createDirectory(joinPath(root, "tmp"))
  return true
end function

// Creates the database.
// Inputs: `dataRoot`, `name`, `defaults`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createDatabase(dataRoot, name, defaults)
  if typeof(dataRoot) != "string" or len(dataRoot) == 0 then return fail(INVALID_ARGUMENT, "createDatabase", "dataRoot must be non-empty") end if
  validateName(name, "createDatabase")
  if not config_model.isDatabaseDefaults(defaults) then return fail(INVALID_ARGUMENT, "createDatabase", "defaults must be DatabaseDefaults") end if
  file_api.createDirectory(dataRoot)
  databaseId = uuid.create()
  identity = uuid.toHex(databaseId)
  temporaryPath = joinPath(dataRoot, ".db_" + identity + ".creating")
  finalPath = joinPath(dataRoot, "db_" + identity)
  if file_api.pathExists(temporaryPath) or file_api.pathExists(finalPath) then return fail(OBJECT_EXISTS, "createDatabase", "generated database path already exists") end if
  ensureLayout(temporaryPath)

  databaseMetadata = metadata.createDatabase(
    name,
    databaseId,
    defaults.pageSize,
    defaults.walSegmentBytes,
    defaults.databaseFormatVersion,
    defaults.tableFileFormatVersion,
    defaults.indexFileFormatVersion,
    defaults.walFormatVersion,
    defaults.rowFormatVersion
  )
  catalogState = metadata.createCatalog(databaseId, databaseMetadata.nextObjectId)

  metaPath = joinPath(temporaryPath, "db.meta")
  metaFile = paged_file.create(metaPath, defaults.pageSize, superblock.FILE_TYPE_DATABASE_META, DATABASE_META_FILE_ID, databaseId)
  writeBlobPage(metaFile, 0, metadata.encodeDatabase(databaseMetadata))
  paged_file.close(metaFile)

  catalogPath = joinPath(joinPath(temporaryPath, "catalog"), "catalog.tbl")
  catalogFile = paged_file.create(catalogPath, defaults.pageSize, superblock.FILE_TYPE_TABLE, CATALOG_FILE_ID, databaseId)
  writeBlobPage(catalogFile, 0, metadata.encodeCatalog(catalogState))
  paged_file.close(catalogFile)

  securityPath = securityFilePath(temporaryPath)
  securityFile = paged_file.create(securityPath, defaults.pageSize, superblock.FILE_TYPE_TABLE, SECURITY_FILE_ID, databaseId)
  currentSecurity = metadata.createSecurity(databaseId)
  previousSecurity = metadata.createSecurity(databaseId)
  previousSecurity.generation = 0
  writeBlobPage(securityFile, 0, metadata.encodeSecurity(currentSecurity))
  writeBlobPage(securityFile, 1, metadata.encodeSecurity(previousSecurity))
  paged_file.close(securityFile)

  walFile = wal.create(joinPath(joinPath(temporaryPath, "wal"), "wal.log"), defaults.walSegmentBytes)
  wal.close(walFile)
  checkpointFile = checkpoint.create(joinPath(joinPath(temporaryPath, "wal"), "checkpoint.meta"), databaseId)
  checkpoint.close(checkpointFile)
  lockFile = file_api.create(joinPath(temporaryPath, "db.lock"))
  file_api.close(lockFile)

  file_api.movePath(temporaryPath, finalPath, false)
  return openDatabase(finalPath)
end function

// Validates the catalog semantics.
// Inputs: `databaseMetadata`, `catalogState`. Returns success after all invariants hold; violations are reported as structured errors.
function validateCatalogSemantics(databaseMetadata, catalogState)
  if catalogState.nextObjectId > databaseMetadata.nextObjectId then return fail(CORRUPT_DATA, "validateCatalogSemantics", "catalog nextObjectId exceeds durable database allocator") end if
  seenIds = []
  seenNames = []
  for each table in catalogState.tables
    if table.tableId <= CATALOG_FILE_ID or table.tableId >= databaseMetadata.nextObjectId then return fail(CORRUPT_DATA, "validateCatalogSemantics", "table ID is outside allocated range") end if
    for each existingId in seenIds
      if existingId == table.tableId then return fail(CORRUPT_DATA, "validateCatalogSemantics", "duplicate table ID") end if
    end for
    for each existingName in seenNames
      if existingName == table.name then return fail(CORRUPT_DATA, "validateCatalogSemantics", "duplicate table name") end if
    end for
    seenIds = seenIds + [table.tableId]
    seenNames = seenNames + [table.name]
    columnNames = []
    for each column in table.columns
      if column.columnId <= table.tableId or column.columnId >= databaseMetadata.nextObjectId then return fail(CORRUPT_DATA, "validateCatalogSemantics", "column ID is outside allocated range") end if
      for each existingId in seenIds
        if existingId == column.columnId then return fail(CORRUPT_DATA, "validateCatalogSemantics", "duplicate global object ID") end if
      end for
      for each existingName in columnNames
        if existingName == column.name then return fail(CORRUPT_DATA, "validateCatalogSemantics", "duplicate column name") end if
      end for
      seenIds = seenIds + [column.columnId]
      columnNames = columnNames + [column.name]
    end for
  end for
  return true
end function

// Validates the table files.
// Inputs: `path`, `databaseMetadata`, `catalogState`. Returns success after all invariants hold; violations are reported as structured errors.
function validateTableFiles(path, databaseMetadata, catalogState)
  for each table in catalogState.tables
    tablePath = tableFilePath(path, table.tableId)
    opened = try(paged_file.open(tablePath))
    if typeof(opened) == "error" then return fail(CORRUPT_DATA, "validateTableFiles", "table file is missing or unreadable for table " + table.name) end if
    valid = opened.fileType == superblock.FILE_TYPE_TABLE and opened.fileId == table.tableId and opened.pageSize == databaseMetadata.pageSize and bytesEqual(opened.databaseId, databaseMetadata.databaseId)
    paged_file.close(opened)
    if not valid then return fail(CORRUPT_DATA, "validateTableFiles", "table file identity mismatch for table " + table.name) end if
  end for
  return true
end function

// Opens the database.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function openDatabase(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "openDatabase", "path must be non-empty") end if
  metaFile = paged_file.open(joinPath(path, "db.meta"))
  if metaFile.fileType != superblock.FILE_TYPE_DATABASE_META or metaFile.fileId != DATABASE_META_FILE_ID or metaFile.pageCount != 1 then
    paged_file.close(metaFile)
    return fail(CORRUPT_DATA, "openDatabase", "invalid db.meta identity")
  end if
  databaseMetadata = metadata.decodeDatabase(readBlobPage(metaFile, 0))
  if databaseMetadata.pageSize != metaFile.pageSize or not bytesEqual(databaseMetadata.databaseId, metaFile.databaseId) then
    paged_file.close(metaFile)
    return fail(CORRUPT_DATA, "openDatabase", "db.meta payload disagrees with persisted superblock")
  end if

  catalogFile = try(paged_file.open(joinPath(joinPath(path, "catalog"), "catalog.tbl")))
  if typeof(catalogFile) == "error" then paged_file.close(metaFile); return catalogFile end if
  if catalogFile.fileType != superblock.FILE_TYPE_TABLE or catalogFile.fileId != CATALOG_FILE_ID or catalogFile.pageSize != databaseMetadata.pageSize or not bytesEqual(catalogFile.databaseId, databaseMetadata.databaseId) then
    paged_file.close(catalogFile)
    paged_file.close(metaFile)
    return fail(CORRUPT_DATA, "openDatabase", "catalog file identity mismatch")
  end if
  catalogState = metadata.decodeCatalog(readBlobPage(catalogFile, 0))
  if not bytesEqual(catalogState.databaseId, databaseMetadata.databaseId) then
    paged_file.close(catalogFile)
    paged_file.close(metaFile)
    return fail(CORRUPT_DATA, "openDatabase", "catalog belongs to another database")
  end if
  semantics = try(validateCatalogSemantics(databaseMetadata, catalogState))
  if typeof(semantics) == "error" then paged_file.close(catalogFile); paged_file.close(metaFile); return semantics end if
  filesValid = try(validateTableFiles(path, databaseMetadata, catalogState))
  if typeof(filesValid) == "error" then paged_file.close(catalogFile); paged_file.close(metaFile); return filesValid end if

  securityPath = securityFilePath(path)
  if not file_api.fileExists(securityPath) then
    // M20 databases are upgraded under the caller's exclusive database lock.
    // Build both generations under a temporary name, close/flush the paged file,
    // and publish it atomically. A crash can therefore leave only a removable
    // temporary file; it can never expose a one-page or torn security catalog.
    bootstrapPath = securityPath + ".creating"
    if file_api.fileExists(bootstrapPath) then
      removedBootstrap = try(file_api.deletePath(bootstrapPath))
      if typeof(removedBootstrap) == "error" then paged_file.close(catalogFile); paged_file.close(metaFile); return removedBootstrap end if
    end if
    bootstrapFile = try(paged_file.create(bootstrapPath, databaseMetadata.pageSize, superblock.FILE_TYPE_TABLE, SECURITY_FILE_ID, databaseMetadata.databaseId))
    if typeof(bootstrapFile) == "error" then paged_file.close(catalogFile); paged_file.close(metaFile); return bootstrapFile end if
    bootstrapCurrent = metadata.createSecurity(databaseMetadata.databaseId)
    bootstrapPrevious = metadata.createSecurity(databaseMetadata.databaseId)
    bootstrapPrevious.generation = 0
    firstWritten = try(writeBlobPage(bootstrapFile, 0, metadata.encodeSecurity(bootstrapCurrent)))
    secondWritten = void
    if typeof(firstWritten) != "error" then secondWritten = try(writeBlobPage(bootstrapFile, 1, metadata.encodeSecurity(bootstrapPrevious))) end if
    closedBootstrap = try(paged_file.close(bootstrapFile))
    if typeof(firstWritten) == "error" then ignoredDelete = try(file_api.deletePath(bootstrapPath)); paged_file.close(catalogFile); paged_file.close(metaFile); return firstWritten end if
    if typeof(secondWritten) == "error" then ignoredDelete = try(file_api.deletePath(bootstrapPath)); paged_file.close(catalogFile); paged_file.close(metaFile); return secondWritten end if
    if typeof(closedBootstrap) == "error" then ignoredDelete = try(file_api.deletePath(bootstrapPath)); paged_file.close(catalogFile); paged_file.close(metaFile); return closedBootstrap end if
    published = try(file_api.movePath(bootstrapPath, securityPath, false))
    if typeof(published) == "error" then ignoredDelete = try(file_api.deletePath(bootstrapPath)); paged_file.close(catalogFile); paged_file.close(metaFile); return published end if
  end if
  securityFile = try(paged_file.open(securityPath))
  if typeof(securityFile) == "error" then paged_file.close(catalogFile); paged_file.close(metaFile); return securityFile end if
  if securityFile.fileType != superblock.FILE_TYPE_TABLE or securityFile.fileId != SECURITY_FILE_ID or securityFile.pageSize != databaseMetadata.pageSize or not bytesEqual(securityFile.databaseId, databaseMetadata.databaseId) or securityFile.pageCount != 2 then
    paged_file.close(securityFile); paged_file.close(catalogFile); paged_file.close(metaFile)
    return fail(CORRUPT_DATA, "openDatabase", "security catalog file identity mismatch")
  end if
  securityState = try(loadSecurityState(securityFile, databaseMetadata.databaseId))
  if typeof(securityState) == "error" then paged_file.close(securityFile); paged_file.close(catalogFile); paged_file.close(metaFile); return securityState end if
  securityValid = try(validateSecuritySemantics(securityState, databaseMetadata.databaseId, catalogState.tables))
  if typeof(securityValid) == "error" then paged_file.close(securityFile); paged_file.close(catalogFile); paged_file.close(metaFile); return securityValid end if

  // db.meta is the authoritative high-water mark. A crash after publishing it
  // but before the catalog page may leave a harmless ID gap; never move the
  // allocator backwards and risk reusing an object ID.
  catalogState.nextObjectId = databaseMetadata.nextObjectId
  return DatabaseHandle(path, metaFile, catalogFile, securityFile, databaseMetadata, catalogState, securityState, false, false)
end function

// Validates the open.
// Inputs: `database`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateOpen(database, operation)
  if database is not DatabaseHandle then return fail(INVALID_ARGUMENT, operation, "database must be DatabaseHandle") end if
  if database.closed then return fail(CLOSED_HANDLE, operation, "database is closed") end if
  return true
end function

// Performs the persist metadata operation for this module.
// Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.
function persistMetadata(database)
  validateOpen(database, "persistMetadata")
  database.catalog.nextObjectId = database.metadata.nextObjectId
  writeBlobPage(database.metaFile, 0, metadata.encodeDatabase(database.metadata))
  writeBlobPage(database.catalogFile, 0, metadata.encodeCatalog(database.catalog))
  return true
end function

// Finds the table.
// Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findTable(database, name)
  validateOpen(database, "findTable")
  for each table in database.catalog.tables
    if table.name == name then return table end if
  end for
  return void
end function

// Finds the table by id.
// Inputs: `database`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findTableById(database, tableId)
  validateOpen(database, "findTableById")
  if typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "findTableById", "tableId must be non-negative") end if
  for each table in database.catalog.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

// Performs the define column operation for this module.
// Inputs: `name`, `typeCode`, `nullable`, `maxLength`, `precision`, `scale`. Returns the produced value or propagates a structured error from validation or delegated operations.
function defineColumn(name, typeCode, nullable, maxLength, precision, scale)
  return metadata.createColumn(0, name, typeCode, nullable, maxLength, precision, scale)
end function

// Creates the table.
// Inputs: `database`, `name`, `definitions`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createTable(database, name, definitions)
  validateOpen(database, "createTable")
  validateName(name, "createTable")
  if typeof(definitions) != "array" or len(definitions) == 0 then return fail(INVALID_ARGUMENT, "createTable", "definitions must be a non-empty array") end if
  if findTable(database, name) is not void then return fail(OBJECT_EXISTS, "createTable", "table already exists") end if

  nextId = database.metadata.nextObjectId
  neededIds = len(definitions) + 1
  if nextId > endian.MAX_MINILANG_INT - neededIds then return fail(INVALID_ARGUMENT, "createTable", "object ID space is exhausted") end if
  tableId = nextId
  nextId = nextId + 1
  columns = []
  names = []
  for each definition in definitions
    if not metadata.isColumnMetadata(definition) then return fail(INVALID_ARGUMENT, "createTable", "invalid column definition") end if
    for each existingName in names
      if existingName == definition.name then return fail(OBJECT_EXISTS, "createTable", "duplicate column name") end if
    end for
    columns = columns + [metadata.createColumn(nextId, definition.name, definition.typeCode, definition.nullable, definition.maxLength, definition.precision, definition.scale)]
    names = names + [definition.name]
    nextId = nextId + 1
  end for
  table = metadata.createTable(tableId, name, 1, columns)
  physicalPath = tableFilePath(database.path, tableId)
  if file_api.pathExists(physicalPath) then return fail(OBJECT_EXISTS, "createTable", "table file already exists") end if

  physical = paged_file.create(physicalPath, database.metadata.pageSize, superblock.FILE_TYPE_TABLE, tableId, database.metadata.databaseId)
  paged_file.close(physical)

  oldTables = database.catalog.tables
  database.metadata.nextObjectId = nextId
  database.catalog.tables = oldTables + [table]
  persisted = try(persistMetadata(database))
  if typeof(persisted) == "error" then
    // Object IDs are durable high-water marks and must never move backwards.
    // Keep the newly allocated range reserved and leave the physical file as an
    // orphan for a later consistency/cleanup pass; deleting it could be unsafe
    // if the catalog page reached disk before an I/O error was reported.
    database.metadata.nextObjectId = nextId
    database.catalog.nextObjectId = nextId
    database.catalog.tables = oldTables
    ignored = try(writeBlobPage(database.metaFile, 0, metadata.encodeDatabase(database.metadata)))
    return persisted
  end if
  return table
end function

// Allocates the transaction id.
// Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.
function allocateTransactionId(database)
  validateOpen(database, "allocateTransactionId")
  value = database.metadata.nextTransactionId
  if value >= endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "allocateTransactionId", "transaction ID space is exhausted") end if
  database.metadata.nextTransactionId = value + 1
  writeBlobPage(database.metaFile, 0, metadata.encodeDatabase(database.metadata))
  return value
end function

// Closes the requested value.
// Inputs: `database`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(database)
  validateOpen(database, "close")
  paged_file.close(database.securityFile)
  paged_file.close(database.catalogFile)
  paged_file.close(database.metaFile)
  database.closed = true
  return true
end function

// ---------------------------------------------------------------------------
// M21 DCL, principals, roles and privileges
// ---------------------------------------------------------------------------

// Finds the principal by id in state.
// Inputs: `state`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findPrincipalByIdInState(state, principalId)
  if not metadata.isSecurityState(state) then return fail(INVALID_ARGUMENT, "findPrincipalByIdInState", "state must be SecurityState") end if
  for each principal in state.principals
    if principal.principalId == principalId then return principal end if
  end for
  return void
end function

// Finds the principal by name in state.
// Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findPrincipalByNameInState(state, name)
  if not metadata.isSecurityState(state) then return fail(INVALID_ARGUMENT, "findPrincipalByNameInState", "state must be SecurityState") end if
  for each principal in state.principals
    if principal.name == name then return principal end if
  end for
  return void
end function

// Finds the principal.
// Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findPrincipal(database, name)
  validateOpen(database, "findPrincipal")
  return findPrincipalByNameInState(database.security, name)
end function

// Performs the require principal operation for this module.
// Inputs: `database`, `name`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function requirePrincipal(database, name, operation)
  principal = findPrincipal(database, name)
  if principal is void then return fail(OBJECT_NOT_FOUND, operation, "principal does not exist: " + name) end if
  return principal
end function

// Performs the security array slice operation for this module.
// Inputs: `values`, `offset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function securityArraySlice(values, offset, count)
  if typeof(values) != "array" or typeof(offset) != "int" or typeof(count) != "int" or offset < 0 or count < 0 or offset > len(values) or count > len(values) - offset then return fail(INVALID_ARGUMENT, "securityArraySlice", "invalid array range") end if
  output = []
  if count > 0 then
    for index = offset to offset + count - 1
      output = output + [values[index]]
    end for
  end if
  return output
end function

// Performs the contains id operation for this module.
// Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.
function containsId(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Performs the effective principal ids in state operation for this module.
// Inputs: `state`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function effectivePrincipalIdsInState(state, principalId)
  if findPrincipalByIdInState(state, principalId) is void then return fail(OBJECT_NOT_FOUND, "effectivePrincipalIdsInState", "principal does not exist") end if
  result = [principalId]
  if principalId != metadata.PRINCIPAL_PUBLIC_ID then result = result + [metadata.PRINCIPAL_PUBLIC_ID] end if
  changed = true
  while changed
    changed = false
    for each membership in state.memberships
      if containsId(result, membership.memberId) and not containsId(result, membership.roleId) then
        result = result + [membership.roleId]
        changed = true
      end if
    end for
  end while
  return result
end function

// Validates the security semantics.
// Inputs: `state`, `databaseId`, `tables`. Returns success after all invariants hold; violations are reported as structured errors.
function validateSecuritySemantics(state, databaseId, tables)
  if not metadata.isSecurityState(state) then return fail(CORRUPT_DATA, "validateSecuritySemantics", "invalid security state") end if
  if not bytesEqual(state.databaseId, databaseId) then return fail(CORRUPT_DATA, "validateSecuritySemantics", "security catalog belongs to another database") end if
  if state.generation < 0 or state.nextPrincipalId < 3 then return fail(CORRUPT_DATA, "validateSecuritySemantics", "invalid security generation or allocator") end if
  ids = []
  names = []
  maximumId = 0
  for each principal in state.principals
    if not metadata.isPrincipalMetadata(principal) then return fail(CORRUPT_DATA, "validateSecuritySemantics", "invalid principal entry") end if
    validatedPrincipal = try(metadata.createPrincipal(principal.principalId, principal.name, principal.principalKind, principal.enabled, principal.canLogin, principal.superuser, principal.builtin, principal.salt, principal.iterations, principal.verifier))
    if typeof(validatedPrincipal) == "error" then return fail(CORRUPT_DATA, "validateSecuritySemantics", "invalid principal semantics") end if
    if typeof(validatedPrincipal.salt) == "bytes" then fillBytes(validatedPrincipal.salt, 0, len(validatedPrincipal.salt), 0) end if
    if typeof(validatedPrincipal.verifier) == "bytes" then fillBytes(validatedPrincipal.verifier, 0, len(validatedPrincipal.verifier), 0) end if
    if principal.builtin and principal.principalId != metadata.PRINCIPAL_ADMIN_ID and principal.principalId != metadata.PRINCIPAL_PUBLIC_ID then return fail(CORRUPT_DATA, "validateSecuritySemantics", "unknown built-in principal") end if
    if (principal.principalId == metadata.PRINCIPAL_ADMIN_ID or principal.principalId == metadata.PRINCIPAL_PUBLIC_ID) and not principal.builtin then return fail(CORRUPT_DATA, "validateSecuritySemantics", "reserved principal is not built-in") end if
    if containsId(ids, principal.principalId) then return fail(CORRUPT_DATA, "validateSecuritySemantics", "duplicate principal ID") end if
    for each existingName in names
      if existingName == principal.name then return fail(CORRUPT_DATA, "validateSecuritySemantics", "duplicate principal name") end if
    end for
    ids = ids + [principal.principalId]
    names = names + [principal.name]
    if principal.principalId > maximumId then maximumId = principal.principalId end if
  end for
  if state.nextPrincipalId <= maximumId then return fail(CORRUPT_DATA, "validateSecuritySemantics", "principal allocator moved backwards") end if
  administrator = findPrincipalByIdInState(state, metadata.PRINCIPAL_ADMIN_ID)
  publicRole = findPrincipalByIdInState(state, metadata.PRINCIPAL_PUBLIC_ID)
  if administrator is void or administrator.name != "admin" or administrator.principalKind != metadata.PRINCIPAL_USER or not administrator.enabled or not administrator.canLogin or not administrator.superuser or not administrator.builtin then
    return fail(CORRUPT_DATA, "validateSecuritySemantics", "built-in administrator is missing or invalid")
  end if
  if publicRole is void or publicRole.name != "public" or publicRole.principalKind != metadata.PRINCIPAL_ROLE or not publicRole.enabled or publicRole.canLogin or publicRole.superuser or not publicRole.builtin then
    return fail(CORRUPT_DATA, "validateSecuritySemantics", "built-in PUBLIC role is missing or invalid")
  end if
  membershipKeys = []
  for each membership in state.memberships
    if membership.roleId == membership.memberId then return fail(CORRUPT_DATA, "validateSecuritySemantics", "a role cannot contain itself") end if
    role = findPrincipalByIdInState(state, membership.roleId)
    member = findPrincipalByIdInState(state, membership.memberId)
    grantor = findPrincipalByIdInState(state, membership.grantorId)
    if role is void or member is void or grantor is void or role.principalKind != metadata.PRINCIPAL_ROLE then return fail(CORRUPT_DATA, "validateSecuritySemantics", "role membership references an invalid principal") end if
    key = membership.roleId + ":" + membership.memberId
    for each existingKey in membershipKeys
      if existingKey == key then return fail(CORRUPT_DATA, "validateSecuritySemantics", "duplicate role membership") end if
    end for
    membershipKeys = membershipKeys + [key]
  end for
  // Every role graph must be acyclic. An effective-role closure containing the
  // starting role through a non-zero path indicates a cycle.
  for each principal in state.principals
    if principal.principalKind == metadata.PRINCIPAL_ROLE then
      frontier = [principal.principalId]
      visited = []
      while len(frontier) > 0
        currentId = frontier[0]
        remaining = []
        if len(frontier) > 1 then remaining = securityArraySlice(frontier, 1, len(frontier) - 1) end if
        frontier = remaining
        for each membership in state.memberships
          if membership.memberId == currentId then
            if membership.roleId == principal.principalId and currentId != principal.principalId then return fail(CORRUPT_DATA, "validateSecuritySemantics", "role membership cycle") end if
            if not containsId(visited, membership.roleId) then frontier = frontier + [membership.roleId] end if
          end if
        end for
        visited = visited + [currentId]
      end while
    end if
  end for
  grantKeys = []
  for each grant in state.grants
    if findPrincipalByIdInState(state, grant.granteeId) is void or findPrincipalByIdInState(state, grant.grantorId) is void then return fail(CORRUPT_DATA, "validateSecuritySemantics", "privilege grant references an invalid principal") end if
    if not metadata.validPrivilege(grant.objectType, grant.privilege) then return fail(CORRUPT_DATA, "validateSecuritySemantics", "invalid privilege code") end if
    // Grants for a dropped table are harmless tombstones until the next DCL
    // cleanup pass. Object IDs are never reused, so they can never authorize a
    // future table accidentally.
    key = grant.granteeId + ":" + grant.objectType + ":" + grant.objectId + ":" + grant.privilege
    for each existingKey in grantKeys
      if existingKey == key then return fail(CORRUPT_DATA, "validateSecuritySemantics", "duplicate privilege grant") end if
    end for
    grantKeys = grantKeys + [key]
  end for
  return true
end function

// Loads the security state.
// Inputs: `securityFile`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function loadSecurityState(securityFile, databaseId)
  first = try(metadata.decodeSecurity(readBlobPage(securityFile, 0)))
  second = try(metadata.decodeSecurity(readBlobPage(securityFile, 1)))
  firstValid = typeof(first) != "error"
  secondValid = typeof(second) != "error"
  if not firstValid and not secondValid then return fail(CORRUPT_DATA, "loadSecurityState", "both security generations are invalid") end if
  selected = first
  if not firstValid then selected = second end if
  if firstValid and secondValid then
    if second.generation > first.generation then selected = second end if
    if first.generation == second.generation and hex(metadata.encodeSecurity(first)) != hex(metadata.encodeSecurity(second)) then return fail(CORRUPT_DATA, "loadSecurityState", "equal security generations disagree") end if
  end if
  if not bytesEqual(selected.databaseId, databaseId) then return fail(CORRUPT_DATA, "loadSecurityState", "security database identity mismatch") end if
  return selected
end function

// Clones the principal.
// Inputs: `principal`. Returns the produced value or propagates a structured error from validation or delegated operations.
function clonePrincipal(principal)
  return metadata.createPrincipal(principal.principalId, principal.name, principal.principalKind, principal.enabled, principal.canLogin, principal.superuser, principal.builtin, principal.salt, principal.iterations, principal.verifier)
end function

// Clones the membership.
// Inputs: `membership`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cloneMembership(membership)
  return metadata.createRoleMembership(membership.roleId, membership.memberId, membership.grantorId, membership.adminOption)
end function

// Clones the privilege grant.
// Inputs: `grant`. Returns the produced value or propagates a structured error from validation or delegated operations.
function clonePrivilegeGrant(grant)
  return metadata.createPrivilegeGrant(grant.granteeId, grant.grantorId, grant.objectType, grant.objectId, grant.privilege, grant.grantOption)
end function

// Clones the security state.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cloneSecurityState(state)
  if not metadata.isSecurityState(state) then return fail(INVALID_ARGUMENT, "cloneSecurityState", "state must be SecurityState") end if
  principals = []
  memberships = []
  grants = []
  for each principal in state.principals
    principals = principals + [clonePrincipal(principal)]
  end for
  for each membership in state.memberships
    memberships = memberships + [cloneMembership(membership)]
  end for
  for each grant in state.grants
    grants = grants + [clonePrivilegeGrant(grant)]
  end for
  return metadata.SecurityState(bytes(state.databaseId), state.generation, state.nextPrincipalId, principals, memberships, grants)
end function

// Validates the security writable.
// Inputs: `database`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateSecurityWritable(database, operation)
  validateOpen(database, operation)
  if database.securityFailed then return fail(SECURITY_STATE, operation, "security state is uncertain after an I/O failure; close and reopen the database") end if
  return true
end function

// Commits the security state.
// Inputs: `database`, `candidate`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function commitSecurityState(database, candidate)
  validateSecurityWritable(database, "commitSecurityState")
  if not metadata.isSecurityState(candidate) then return fail(INVALID_ARGUMENT, "commitSecurityState", "candidate must be SecurityState") end if
  oldGeneration = database.security.generation
  if oldGeneration >= endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "commitSecurityState", "security generation exhausted") end if
  candidate.generation = oldGeneration + 1
  semanticResult = try(validateSecuritySemantics(candidate, database.metadata.databaseId, database.catalog.tables))
  if typeof(semanticResult) == "error" then return semanticResult end if
  encoded = try(metadata.encodeSecurity(candidate))
  if typeof(encoded) == "error" then return encoded end if
  slot = (candidate.generation - 1) % 2
  written = try(writeBlobPage(database.securityFile, slot, encoded))
  fillBytes(encoded, 0, len(encoded), 0)
  if typeof(written) == "error" then
    // A failed write/flush has an ambiguous durability outcome. Do not permit
    // another DCL mutation in this process: reopening resolves the winner from
    // the two CRC-protected generations and prevents ID or grant reuse.
    database.securityFailed = true
    return fail(SECURITY_STATE, "commitSecurityState", "security persistence failed; close and reopen database: " + written.message)
  end if
  database.security = candidate
  return true
end function

// Performs the persist security operation for this module.
// Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.
function persistSecurity(database)
  return commitSecurityState(database, cloneSecurityState(database.security))
end function

// Allocates the principal id in state.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function allocatePrincipalIdInState(state)
  value = state.nextPrincipalId
  if value >= endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "allocatePrincipalIdInState", "principal ID space exhausted") end if
  state.nextPrincipalId = value + 1
  return value
end function

// Creates the user.
// Inputs: `database`, `name`, `password`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createUser(database, name, password)
  validateSecurityWritable(database, "createUser")
  metadata.validateSecurityName(name, "createUser")
  if findPrincipal(database, name) is not void then return fail(OBJECT_EXISTS, "createUser", "principal already exists") end if
  material = try(uuid.createPasswordMaterial(password))
  if typeof(material) == "error" then return material end if
  candidate = cloneSecurityState(database.security)
  principalId = allocatePrincipalIdInState(candidate)
  principal = try(metadata.createPrincipal(principalId, name, metadata.PRINCIPAL_USER, true, true, false, false, material.salt, material.iterations, material.verifier))
  if typeof(principal) == "error" then uuid.wipePasswordMaterial(material); return principal end if
  candidate.principals = candidate.principals + [principal]
  committed = try(commitSecurityState(database, candidate))
  uuid.wipePasswordMaterial(material)
  if typeof(committed) == "error" then
    fillBytes(principal.salt, 0, len(principal.salt), 0)
    fillBytes(principal.verifier, 0, len(principal.verifier), 0)
    return committed
  end if
  return findPrincipalByIdInState(database.security, principalId)
end function

// Creates the role.
// Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createRole(database, name)
  validateSecurityWritable(database, "createRole")
  metadata.validateSecurityName(name, "createRole")
  if findPrincipal(database, name) is not void then return fail(OBJECT_EXISTS, "createRole", "principal already exists") end if
  candidate = cloneSecurityState(database.security)
  principalId = allocatePrincipalIdInState(candidate)
  principal = metadata.createPrincipal(principalId, name, metadata.PRINCIPAL_ROLE, true, false, false, false, bytes(0), 0, bytes(0))
  candidate.principals = candidate.principals + [principal]
  commitSecurityState(database, candidate)
  return findPrincipalByIdInState(database.security, principalId)
end function

// Updates the user password.
// Inputs: `database`, `name`, `password`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function setUserPassword(database, name, password)
  validateSecurityWritable(database, "setUserPassword")
  current = requirePrincipal(database, name, "setUserPassword")
  if current.principalKind != metadata.PRINCIPAL_USER then return fail(INVALID_ARGUMENT, "setUserPassword", "principal is not a user") end if
  material = try(uuid.createPasswordMaterial(password))
  if typeof(material) == "error" then return material end if
  candidate = cloneSecurityState(database.security)
  principal = findPrincipalByIdInState(candidate, current.principalId)
  principal.salt = bytes(material.salt)
  principal.iterations = material.iterations
  principal.verifier = bytes(material.verifier)
  committed = try(commitSecurityState(database, candidate))
  uuid.wipePasswordMaterial(material)
  if typeof(committed) == "error" then
    fillBytes(principal.salt, 0, len(principal.salt), 0)
    fillBytes(principal.verifier, 0, len(principal.verifier), 0)
    return committed
  end if
  return findPrincipalByIdInState(database.security, current.principalId)
end function

// Updates the user password bytes.
// Inputs: `database`, `name`, `passwordBytes`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function setUserPasswordBytes(database, name, passwordBytes)
  validateSecurityWritable(database, "setUserPasswordBytes")
  current = requirePrincipal(database, name, "setUserPasswordBytes")
  if current.principalKind != metadata.PRINCIPAL_USER then return fail(INVALID_ARGUMENT, "setUserPasswordBytes", "principal is not a user") end if
  material = try(uuid.createPasswordMaterialBytes(passwordBytes))
  if typeof(material) == "error" then return material end if
  candidate = cloneSecurityState(database.security)
  principal = findPrincipalByIdInState(candidate, current.principalId)
  principal.salt = bytes(material.salt)
  principal.iterations = material.iterations
  principal.verifier = bytes(material.verifier)
  committed = try(commitSecurityState(database, candidate))
  uuid.wipePasswordMaterial(material)
  if typeof(committed) == "error" then
    fillBytes(principal.salt, 0, len(principal.salt), 0)
    fillBytes(principal.verifier, 0, len(principal.verifier), 0)
    return committed
  end if
  return findPrincipalByIdInState(database.security, current.principalId)
end function

// Updates the user enabled.
// Inputs: `database`, `name`, `enabled`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function setUserEnabled(database, name, enabled)
  validateSecurityWritable(database, "setUserEnabled")
  if typeof(enabled) != "bool" then return fail(INVALID_ARGUMENT, "setUserEnabled", "enabled must be bool") end if
  current = requirePrincipal(database, name, "setUserEnabled")
  if current.principalKind != metadata.PRINCIPAL_USER then return fail(INVALID_ARGUMENT, "setUserEnabled", "principal is not a user") end if
  if current.builtin and not enabled then return fail(INVALID_ARGUMENT, "setUserEnabled", "built-in administrator cannot be disabled") end if
  candidate = cloneSecurityState(database.security)
  principal = findPrincipalByIdInState(candidate, current.principalId)
  principal.enabled = enabled
  commitSecurityState(database, candidate)
  return findPrincipalByIdInState(database.security, current.principalId)
end function

// Drops the principal.
// Inputs: `database`, `name`, `expectedKind`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function dropPrincipal(database, name, expectedKind, ifExists)
  validateSecurityWritable(database, "dropPrincipal")
  principal = findPrincipal(database, name)
  if principal is void then
    if ifExists then return false end if
    return fail(OBJECT_NOT_FOUND, "dropPrincipal", "principal does not exist")
  end if
  if expectedKind != 0 and principal.principalKind != expectedKind then return fail(INVALID_ARGUMENT, "dropPrincipal", "principal kind does not match statement") end if
  if principal.builtin then return fail(INVALID_ARGUMENT, "dropPrincipal", "built-in principal cannot be dropped") end if
  for each grant in database.security.grants
    if grant.granteeId == principal.principalId and grant.privilege == metadata.PRIVILEGE_OWNER then return fail(INVALID_ARGUMENT, "dropPrincipal", "principal owns database objects") end if
  end for
  candidate = cloneSecurityState(database.security)
  principals = []
  for each current in candidate.principals
    if current.principalId != principal.principalId then principals = principals + [current] end if
  end for
  memberships = []
  for each membership in candidate.memberships
    if membership.roleId != principal.principalId and membership.memberId != principal.principalId then memberships = memberships + [membership] end if
  end for
  grants = []
  for each grant in candidate.grants
    if grant.granteeId != principal.principalId and grant.grantorId != principal.principalId then grants = grants + [grant] end if
  end for
  candidate.principals = principals
  candidate.memberships = memberships
  candidate.grants = grants
  commitSecurityState(database, candidate)
  return true
end function

// Performs the role would cycle operation for this module.
// Inputs: `state`, `roleId`, `memberId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function roleWouldCycle(state, roleId, memberId)
  member = findPrincipalByIdInState(state, memberId)
  if member is void or member.principalKind != metadata.PRINCIPAL_ROLE then return false end if
  effective = effectivePrincipalIdsInState(state, roleId)
  return containsId(effective, memberId)
end function

// Performs the grant role operation for this module.
// Inputs: `database`, `roleName`, `memberName`, `grantorId`, `adminOption`. Returns the produced value or propagates a structured error from validation or delegated operations.
function grantRole(database, roleName, memberName, grantorId, adminOption)
  validateSecurityWritable(database, "grantRole")
  role = requirePrincipal(database, roleName, "grantRole")
  member = requirePrincipal(database, memberName, "grantRole")
  if role.principalKind != metadata.PRINCIPAL_ROLE then return fail(INVALID_ARGUMENT, "grantRole", "granted principal is not a role") end if
  if role.builtin and role.principalId == metadata.PRINCIPAL_PUBLIC_ID then return fail(INVALID_ARGUMENT, "grantRole", "PUBLIC membership is implicit") end if
  if roleWouldCycle(database.security, role.principalId, member.principalId) then return fail(INVALID_ARGUMENT, "grantRole", "role membership would create a cycle") end if
  candidate = cloneSecurityState(database.security)
  for each membership in candidate.memberships
    if membership.roleId == role.principalId and membership.memberId == member.principalId then
      if adminOption and not membership.adminOption then
        membership.adminOption = true
        membership.grantorId = grantorId
        commitSecurityState(database, candidate)
      end if
      return membership
    end if
  end for
  membership = metadata.createRoleMembership(role.principalId, member.principalId, grantorId, adminOption)
  candidate.memberships = candidate.memberships + [membership]
  commitSecurityState(database, candidate)
  return membership
end function

// Performs the role cascade members operation for this module.
// Inputs: `state`, `roleId`, `rootMemberId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function roleCascadeMembers(state, roleId, rootMemberId)
  // The M30 security catalog stores one durable lineage per role membership.
  // A membership granted by a member that loses ADMIN OPTION depends on that
  // lineage. Build the transitive set without recursion so hostile catalogs
  // cannot exhaust the MiniLang call stack.
  grantors = [rootMemberId]
  descendants = []
  changed = true
  while changed
    changed = false
    for each membership in state.memberships
      if membership.roleId == roleId and containsId(grantors, membership.grantorId) and membership.memberId != rootMemberId and not containsId(grantors, membership.memberId) then
        grantors = grantors + [membership.memberId]
        descendants = descendants + [membership.memberId]
        changed = true
      end if
    end for
  end while
  return descendants
end function

// Performs the revoke role with behavior operation for this module.
// Inputs: `database`, `roleName`, `memberName`, `cascade`. Returns the produced value or propagates a structured error from validation or delegated operations.
function revokeRoleWithBehavior(database, roleName, memberName, cascade)
  validateSecurityWritable(database, "revokeRole")
  if typeof(cascade) != "bool" then return fail(INVALID_ARGUMENT, "revokeRole", "cascade must be bool") end if
  role = requirePrincipal(database, roleName, "revokeRole")
  member = requirePrincipal(database, memberName, "revokeRole")
  candidate = cloneSecurityState(database.security)
  found = false
  for each membership in candidate.memberships
    if membership.roleId == role.principalId and membership.memberId == member.principalId then found = true end if
  end for
  if not found then return fail(OBJECT_NOT_FOUND, "revokeRole", "role membership does not exist") end if
  descendants = roleCascadeMembers(candidate, role.principalId, member.principalId)
  if len(descendants) > 0 and not cascade then return fail(INVALID_ARGUMENT, "revokeRole", "dependent role grants exist; use CASCADE") end if
  output = []
  for each membership in candidate.memberships
    remove = membership.roleId == role.principalId and membership.memberId == member.principalId
    if cascade and membership.roleId == role.principalId and containsId(descendants, membership.memberId) then remove = true end if
    if not remove then output = output + [membership] end if
  end for
  candidate.memberships = output
  commitSecurityState(database, candidate)
  return true
end function

// M21 compatibility entry point: RESTRICT is the safe default.
// Performs the revoke role operation for this module.
// Inputs: `database`, `roleName`, `memberName`. Returns the produced value or propagates a structured error from validation or delegated operations.
function revokeRole(database, roleName, memberName)
  return revokeRoleWithBehavior(database, roleName, memberName, false)
end function

// Performs the effective principal ids operation for this module.
// Inputs: `database`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function effectivePrincipalIds(database, principalId)
  validateOpen(database, "effectivePrincipalIds")
  return effectivePrincipalIdsInState(database.security, principalId)
end function

// Evaluates whether the supplied input satisfies the superuser predicate.
// Inputs: `database`, `principalId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isSuperuser(database, principalId)
  validateOpen(database, "isSuperuser")
  principal = findPrincipalByIdInState(database.security, principalId)
  return principal is not void and principal.enabled and principal.superuser
end function

// Evaluates whether the supplied input satisfies the role admin option predicate.
// Inputs: `database`, `principalId`, `roleId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function hasRoleAdminOption(database, principalId, roleId)
  if isSuperuser(database, principalId) then return true end if
  effective = effectivePrincipalIds(database, principalId)
  for each membership in database.security.memberships
    if membership.roleId == roleId and membership.adminOption and containsId(effective, membership.memberId) then return true end if
  end for
  return false
end function

// Evaluates whether the supplied input satisfies the privilege predicate.
// Inputs: `database`, `principalId`, `objectType`, `objectId`, `privilege`, `requireGrantOption`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function hasPrivilege(database, principalId, objectType, objectId, privilege, requireGrantOption)
  validateOpen(database, "hasPrivilege")
  if isSuperuser(database, principalId) then return true end if
  effective = effectivePrincipalIds(database, principalId)
  for each grant in database.security.grants
    if containsId(effective, grant.granteeId) and grant.objectType == objectType and grant.objectId == objectId then
      if grant.privilege == privilege or (objectType == metadata.OBJECT_TABLE and grant.privilege == metadata.PRIVILEGE_OWNER) then
        if not requireGrantOption or grant.grantOption or grant.privilege == metadata.PRIVILEGE_OWNER then return true end if
      end if
    end if
  end for
  return false
end function

// Performs the contains privilege code operation for this module.
// Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.
function containsPrivilegeCode(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Performs the grant privileges operation for this module.
// Inputs: `database`, `granteeName`, `grantorId`, `objectType`, `objectId`, `privileges`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.
function grantPrivileges(database, granteeName, grantorId, objectType, objectId, privileges, grantOption)
  validateSecurityWritable(database, "grantPrivileges")
  if typeof(privileges) != "array" or len(privileges) == 0 then return fail(INVALID_ARGUMENT, "grantPrivileges", "privileges must be a non-empty array") end if
  grantee = requirePrincipal(database, granteeName, "grantPrivileges")
  candidate = cloneSecurityState(database.security)
  for each privilege in privileges
    if not metadata.validPrivilege(objectType, privilege) then return fail(INVALID_ARGUMENT, "grantPrivileges", "invalid privilege") end if
    existing = void
    for each current in candidate.grants
      if current.granteeId == grantee.principalId and current.objectType == objectType and current.objectId == objectId and current.privilege == privilege then existing = current end if
    end for
    if existing is void then
      candidate.grants = candidate.grants + [metadata.createPrivilegeGrant(grantee.principalId, grantorId, objectType, objectId, privilege, grantOption)]
    else if grantOption and not existing.grantOption then
      existing.grantOption = true
      existing.grantorId = grantorId
    end if
  end for
  commitSecurityState(database, candidate)
  return true
end function

// Performs the grant privilege operation for this module.
// Inputs: `database`, `granteeName`, `grantorId`, `objectType`, `objectId`, `privilege`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.
function grantPrivilege(database, granteeName, grantorId, objectType, objectId, privilege, grantOption)
  grantPrivileges(database, granteeName, grantorId, objectType, objectId, [privilege], grantOption)
  grantee = requirePrincipal(database, granteeName, "grantPrivilege")
  for each grant in database.security.grants
    if grant.granteeId == grantee.principalId and grant.objectType == objectType and grant.objectId == objectId and grant.privilege == privilege then return grant end if
  end for
  return fail(SECURITY_STATE, "grantPrivilege", "persisted grant is missing")
end function

// Performs the privilege cascade grantees operation for this module.
// Inputs: `state`, `rootGranteeId`, `objectType`, `objectId`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.
function privilegeCascadeGrantees(state, rootGranteeId, objectType, objectId, privilege)
  grantors = [rootGranteeId]
  descendants = []
  changed = true
  while changed
    changed = false
    for each grant in state.grants
      if grant.objectType == objectType and grant.objectId == objectId and grant.privilege == privilege and containsId(grantors, grant.grantorId) and grant.granteeId != rootGranteeId and not containsId(grantors, grant.granteeId) then
        grantors = grantors + [grant.granteeId]
        descendants = descendants + [grant.granteeId]
        changed = true
      end if
    end for
  end while
  return descendants
end function

// Performs the revoke privileges with behavior operation for this module.
// Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privileges`, `cascade`. Returns the produced value or propagates a structured error from validation or delegated operations.
function revokePrivilegesWithBehavior(database, granteeName, objectType, objectId, privileges, cascade)
  validateSecurityWritable(database, "revokePrivileges")
  if typeof(privileges) != "array" or len(privileges) == 0 then return fail(INVALID_ARGUMENT, "revokePrivileges", "privileges must be a non-empty array") end if
  if typeof(cascade) != "bool" then return fail(INVALID_ARGUMENT, "revokePrivileges", "cascade must be bool") end if
  grantee = requirePrincipal(database, granteeName, "revokePrivileges")
  candidate = cloneSecurityState(database.security)
  cascadePairs = []
  for each privilege in privileges
    found = false
    for each grant in candidate.grants
      if grant.granteeId == grantee.principalId and grant.objectType == objectType and grant.objectId == objectId and grant.privilege == privilege then found = true end if
    end for
    if not found then return fail(OBJECT_NOT_FOUND, "revokePrivileges", "privilege grant does not exist") end if
    descendants = privilegeCascadeGrantees(candidate, grantee.principalId, objectType, objectId, privilege)
    if len(descendants) > 0 and not cascade then return fail(INVALID_ARGUMENT, "revokePrivileges", "dependent privilege grants exist; use CASCADE") end if
    cascadePairs = cascadePairs + [[privilege, descendants]]
  end for
  output = []
  for each grant in candidate.grants
    remove = grant.granteeId == grantee.principalId and grant.objectType == objectType and grant.objectId == objectId and containsPrivilegeCode(privileges, grant.privilege)
    if cascade and not remove and grant.objectType == objectType and grant.objectId == objectId then
      for each pair in cascadePairs
        if grant.privilege == pair[0] and containsId(pair[1], grant.granteeId) then remove = true end if
      end for
    end if
    if not remove then output = output + [grant] end if
  end for
  candidate.grants = output
  commitSecurityState(database, candidate)
  return true
end function

// M21 compatibility entry point: RESTRICT is the safe default.
// Performs the revoke privileges operation for this module.
// Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privileges`. Returns the produced value or propagates a structured error from validation or delegated operations.
function revokePrivileges(database, granteeName, objectType, objectId, privileges)
  return revokePrivilegesWithBehavior(database, granteeName, objectType, objectId, privileges, false)
end function

// Performs the revoke privilege operation for this module.
// Inputs: `database`, `granteeName`, `objectType`, `objectId`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.
function revokePrivilege(database, granteeName, objectType, objectId, privilege)
  return revokePrivileges(database, granteeName, objectType, objectId, [privilege])
end function

// Performs the grant table owner operation for this module.
// Inputs: `database`, `tableId`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function grantTableOwner(database, tableId, principalId)
  validateSecurityWritable(database, "grantTableOwner")
  principal = findPrincipalByIdInState(database.security, principalId)
  if principal is void then return fail(OBJECT_NOT_FOUND, "grantTableOwner", "owner principal does not exist") end if
  return grantPrivilege(database, principal.name, principalId, metadata.OBJECT_TABLE, tableId, metadata.PRIVILEGE_OWNER, true)
end function

// Removes the table privileges.
// Inputs: `database`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function removeTablePrivileges(database, tableId)
  validateSecurityWritable(database, "removeTablePrivileges")
  candidate = cloneSecurityState(database.security)
  output = []
  changed = false
  for each grant in candidate.grants
    if grant.objectType == metadata.OBJECT_TABLE and grant.objectId == tableId then changed = true else output = output + [grant] end if
  end for
  if changed then
    candidate.grants = output
    commitSecurityState(database, candidate)
  end if
  return changed
end function

// Performs the authentication material operation for this module.
// Inputs: `database`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function authenticationMaterial(database, name)
  validateOpen(database, "authenticationMaterial")
  principal = findPrincipal(database, name)
  if principal is void or principal.principalKind != metadata.PRINCIPAL_USER or not principal.enabled or not principal.canLogin or len(principal.salt) != 16 or len(principal.verifier) != 32 then return void end if
  return principal
end function

// Performs the authenticate password operation for this module.
// Inputs: `database`, `name`, `password`. Returns the produced value or propagates a structured error from validation or delegated operations.
function authenticatePassword(database, name, password)
  principal = authenticationMaterial(database, name)
  if principal is void then return false end if
  return uuid.verifyPassword(password, principal.salt, principal.iterations, principal.verifier)
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "catalog.catalog"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M8"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
