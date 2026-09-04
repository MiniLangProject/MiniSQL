//! Provides minisql catalog metadata facilities for this project.

package minisql.catalog.metadata
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.storage.checksum as checksum

/// Versioned catalog metadata codecs. Decoders validate kind, version, bounds,

const INVALID_ARGUMENT = 9001
/// Defines the unsupported format constant used by the minisql catalog metadata module.
const UNSUPPORTED_FORMAT = 9003
/// Defines the corrupt data constant used by the minisql catalog metadata module.
const CORRUPT_DATA = 9004

/// Defines the database format version constant used by the minisql catalog metadata module.
const DATABASE_FORMAT_VERSION = 1
/// Defines the catalog format version constant used by the minisql catalog metadata module.
const CATALOG_FORMAT_VERSION = 1
/// Defines the database kind constant used by the minisql catalog metadata module.
const DATABASE_KIND = 1
/// Defines the catalog kind constant used by the minisql catalog metadata module.
const CATALOG_KIND = 2

/// Defines the database metadata record used by this module.
struct DatabaseMetadata
  /// Name field of the database metadata.
  name
  /// Database id field of the database metadata.
  databaseId
  /// Page size field of the database metadata.
  pageSize
  /// Wal segment bytes field of the database metadata.
  walSegmentBytes
  /// Database format version field of the database metadata.
  databaseFormatVersion
  /// Table file format version field of the database metadata.
  tableFileFormatVersion
  /// Index file format version field of the database metadata.
  indexFileFormatVersion
  /// Wal format version field of the database metadata.
  walFormatVersion
  /// Row format version field of the database metadata.
  rowFormatVersion
  /// Next object id field of the database metadata.
  nextObjectId
  /// Next transaction id field of the database metadata.
  nextTransactionId
  /// Checkpoint lsn field of the database metadata.
  checkpointLsn
end struct

/// Defines the column metadata record used by this module.
struct ColumnMetadata
  /// Column id field of the column metadata.
  columnId
  /// Name field of the column metadata.
  name
  /// Type code field of the column metadata.
  typeCode
  /// Nullable field of the column metadata.
  nullable
  /// Max length field of the column metadata.
  maxLength
  /// Precision field of the column metadata.
  precision
  /// Scale field of the column metadata.
  scale
end struct

/// Defines the table metadata record used by this module.
struct TableMetadata
  /// Table id field of the table metadata.
  tableId
  /// Name field of the table metadata.
  name
  /// Schema version field of the table metadata.
  schemaVersion
  /// Columns field of the table metadata.
  columns
end struct

/// Defines the catalog state record used by this module.
struct CatalogState
  /// Database id field of the catalog state.
  databaseId
  /// Next object id field of the catalog state.
  nextObjectId
  /// Tables field of the catalog state.
  tables
end struct

/// Evaluates whether the supplied input satisfies the table metadata predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isTableMetadata(value)
  return value is TableMetadata
end function

/// Evaluates whether the supplied input satisfies the catalog state predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isCatalogState(value)
  return value is CatalogState
end function

/// Evaluates whether the supplied input satisfies the column metadata predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isColumnMetadata(value)
  return value is ColumnMetadata
end function

/// Performs the fail operation for the minisql catalog metadata module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "catalog.metadata." + operation + ": " + message)
end function

/// Performs the database magic operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function databaseMagic()
  return bytes("MSDBM001")
end function

/// Performs the catalog magic operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function catalogMagic()
  return bytes("MSCAT001")
end function

/// Performs the copyExact operation for the minisql catalog metadata module.
/// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param destination destination value consumed by this operation.
/// @param destinationOffset destinationOffset value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param sourceOffset sourceOffset value consumed by this operation.
/// @param count Number of items or units to process.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

/// Validates the id.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateId(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

/// Validates the name.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateName(value, operation, name)
  if typeof(value) != "string" or len(value) == 0 or len(bytes(value)) > 255 then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-empty UTF-8 string of at most 255 bytes")
  end if
  return true
end function

/// Validates database id for the minisql catalog metadata workflow.
/// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
function validateDatabaseId(value, operation)
  if typeof(value) != "bytes" or len(value) != 16 then return fail(INVALID_ARGUMENT, operation, "databaseId must be 16 bytes") end if
  return true
end function

/// Creates the database.
/// Inputs: `name`, `databaseId`, `pageSize`, `walSegmentBytes`, `databaseFormatVersion`, `tableFileFormatVersion`, `indexFileFormatVersion`, `walFormatVersion`, `rowFormatVersion`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param name Name of the affected item.
/// @param databaseId Identifier of database.
/// @param pageSize pageSize value consumed by this operation.
/// @param walSegmentBytes walSegmentBytes value consumed by this operation.
/// @param databaseFormatVersion databaseFormatVersion value consumed by this operation.
/// @param tableFileFormatVersion tableFileFormatVersion value consumed by this operation.
/// @param indexFileFormatVersion indexFileFormatVersion value consumed by this operation.
/// @param walFormatVersion walFormatVersion value consumed by this operation.
/// @param rowFormatVersion rowFormatVersion value consumed by this operation.
function createDatabase(name, databaseId, pageSize, walSegmentBytes, databaseFormatVersion, tableFileFormatVersion, indexFileFormatVersion, walFormatVersion, rowFormatVersion)
  validateName(name, "createDatabase", "name")
  validateDatabaseId(databaseId, "createDatabase")
  if typeof(pageSize) != "int" or pageSize < 4096 or pageSize > 32768 then return fail(INVALID_ARGUMENT, "createDatabase", "invalid pageSize") end if
  if typeof(walSegmentBytes) != "int" or walSegmentBytes < 4096 then return fail(INVALID_ARGUMENT, "createDatabase", "invalid walSegmentBytes") end if
  if databaseFormatVersion != 1 or tableFileFormatVersion != 1 or indexFileFormatVersion != 1 or walFormatVersion != 1 or rowFormatVersion != 1 then
    return fail(UNSUPPORTED_FORMAT, "createDatabase", "only format version 1 is supported")
  end if
  return DatabaseMetadata(name, bytes(databaseId), pageSize, walSegmentBytes, databaseFormatVersion, tableFileFormatVersion, indexFileFormatVersion, walFormatVersion, rowFormatVersion, 3, 1, 0)
end function

/// Encodes the database.
/// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param value Value consumed or transformed by the operation.
function encodeDatabase(value)
  if value is not DatabaseMetadata then return fail(INVALID_ARGUMENT, "encodeDatabase", "value must be DatabaseMetadata") end if
  checked = createDatabase(value.name, value.databaseId, value.pageSize, value.walSegmentBytes, value.databaseFormatVersion, value.tableFileFormatVersion, value.indexFileFormatVersion, value.walFormatVersion, value.rowFormatVersion)
  validateId(value.nextObjectId, "encodeDatabase", "nextObjectId")
  validateId(value.nextTransactionId, "encodeDatabase", "nextTransactionId")
  validateId(value.checkpointLsn, "encodeDatabase", "checkpointLsn")
  nameBytes = bytes(value.name)
  payload = bytes(80 + len(nameBytes), 0)
  endian.writeU32LE(payload, 0, value.pageSize)
  endian.writeU32LE(payload, 4, value.walSegmentBytes)
  endian.writeU16LE(payload, 8, value.databaseFormatVersion)
  endian.writeU16LE(payload, 10, value.tableFileFormatVersion)
  endian.writeU16LE(payload, 12, value.indexFileFormatVersion)
  endian.writeU16LE(payload, 14, value.walFormatVersion)
  endian.writeU16LE(payload, 16, value.rowFormatVersion)
  endian.writeU16LE(payload, 18, 1)
  endian.writeU16LE(payload, 20, 1)
  endian.writeU16LE(payload, 22, len(nameBytes))
  endian.writeU64LE(payload, 24, endian.uint64FromInt(value.nextObjectId))
  endian.writeU64LE(payload, 32, endian.uint64FromInt(value.nextTransactionId))
  endian.writeU64LE(payload, 40, endian.uint64FromInt(value.checkpointLsn))
  copyExact(payload, 48, value.databaseId, 0, 16)
  endian.writeU32LE(payload, 64, 0)
  endian.writeU32LE(payload, 68, 0)
  endian.writeU64LE(payload, 72, endian.makeUInt64(0, 0))
  copyExact(payload, 80, nameBytes, 0, len(nameBytes))
  return checksum.encodeEnvelope(databaseMagic(), DATABASE_FORMAT_VERSION, DATABASE_KIND, 0, payload)
end function

/// Decodes native for the minisql catalog metadata workflow.
/// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param words words value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

/// Decodes the database.
/// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param encoded encoded value consumed by this operation.
function decodeDatabase(encoded)
  envelope = checksum.decodeEnvelope(encoded, databaseMagic(), DATABASE_FORMAT_VERSION, DATABASE_KIND)
  payload = envelope.payload
  if len(payload) < 80 then return fail(CORRUPT_DATA, "decodeDatabase", "database metadata payload too short") end if
  if endian.readU16LE(payload, 18) != 1 or endian.readU16LE(payload, 20) != 1 then return fail(UNSUPPORTED_FORMAT, "decodeDatabase", "unsupported encoding or collation") end if
  if endian.readU32LE(payload, 64) != 0 or endian.readU32LE(payload, 68) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeDatabase", "reserved fields are non-zero") end if
  nameLength = endian.readU16LE(payload, 22)
  if len(payload) != 80 + nameLength then return fail(CORRUPT_DATA, "decodeDatabase", "name length mismatch") end if
  metadata = createDatabase(
    decode(slice(payload, 80, nameLength)),
    slice(payload, 48, 16),
    endian.readU32LE(payload, 0),
    endian.readU32LE(payload, 4),
    endian.readU16LE(payload, 8),
    endian.readU16LE(payload, 10),
    endian.readU16LE(payload, 12),
    endian.readU16LE(payload, 14),
    endian.readU16LE(payload, 16)
  )
  metadata.nextObjectId = decodeNative(endian.readU64LE(payload, 24), "decodeDatabase", "nextObjectId")
  metadata.nextTransactionId = decodeNative(endian.readU64LE(payload, 32), "decodeDatabase", "nextTransactionId")
  metadata.checkpointLsn = decodeNative(endian.readU64LE(payload, 40), "decodeDatabase", "checkpointLsn")
  return metadata
end function

/// Creates the column.
/// Inputs: `columnId`, `name`, `typeCode`, `nullable`, `maxLength`, `precision`, `scale`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param columnId Identifier of column.
/// @param name Name of the affected item.
/// @param typeCode typeCode value consumed by this operation.
/// @param nullable nullable value consumed by this operation.
/// @param maxLength maxLength value consumed by this operation.
/// @param precision precision value consumed by this operation.
/// @param scale scale value consumed by this operation.
function createColumn(columnId, name, typeCode, nullable, maxLength, precision, scale)
  validateId(columnId, "createColumn", "columnId")
  validateName(name, "createColumn", "name")
  if typeof(typeCode) != "int" or typeCode < 1 or typeCode > 65535 then return fail(INVALID_ARGUMENT, "createColumn", "typeCode must fit U16") end if
  if typeof(nullable) != "bool" then return fail(INVALID_ARGUMENT, "createColumn", "nullable must be bool") end if
  if typeof(maxLength) != "int" or maxLength < 0 or maxLength > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "createColumn", "maxLength must fit U32") end if
  if typeof(precision) != "int" or precision < 0 or precision > 65535 or typeof(scale) != "int" or scale < 0 or scale > 65535 then
    return fail(INVALID_ARGUMENT, "createColumn", "precision and scale must fit U16")
  end if
  return ColumnMetadata(columnId, name, typeCode, nullable, maxLength, precision, scale)
end function

/// Creates the table.
/// Inputs: `tableId`, `name`, `schemaVersion`, `columns`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param tableId Identifier of table.
/// @param name Name of the affected item.
/// @param schemaVersion schemaVersion value consumed by this operation.
/// @param columns columns value consumed by this operation.
function createTable(tableId, name, schemaVersion, columns)
  validateId(tableId, "createTable", "tableId")
  validateName(name, "createTable", "name")
  if typeof(schemaVersion) != "int" or schemaVersion <= 0 or schemaVersion > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "createTable", "invalid schemaVersion") end if
  if typeof(columns) != "array" then return fail(INVALID_ARGUMENT, "createTable", "columns must be array") end if
  for each column in columns
    if column is not ColumnMetadata then return fail(INVALID_ARGUMENT, "createTable", "columns contain invalid value") end if
  end for
  return TableMetadata(tableId, name, schemaVersion, columns)
end function

/// Creates the catalog.
/// Inputs: `databaseId`, `nextObjectId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databaseId Identifier of database.
/// @param nextObjectId Identifier of next object.
function createCatalog(databaseId, nextObjectId)
  validateDatabaseId(databaseId, "createCatalog")
  validateId(nextObjectId, "createCatalog", "nextObjectId")
  return CatalogState(bytes(databaseId), nextObjectId, [])
end function

/// Encodes the d table size.
/// Inputs: `table`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param table table value consumed by this operation.
function encodedTableSize(table)
  size = 24 + len(bytes(table.name))
  for each column in table.columns
    size = size + 28 + len(bytes(column.name))
  end for
  return size
end function

/// Encodes the catalog.
/// Inputs: `catalog`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param catalog catalog value consumed by this operation.
function encodeCatalog(catalog)
  if catalog is not CatalogState then return fail(INVALID_ARGUMENT, "encodeCatalog", "value must be CatalogState") end if
  validateDatabaseId(catalog.databaseId, "encodeCatalog")
  validateId(catalog.nextObjectId, "encodeCatalog", "nextObjectId")
  total = 32
  for each table in catalog.tables
    if table is not TableMetadata then return fail(INVALID_ARGUMENT, "encodeCatalog", "invalid table metadata") end if
    total = total + encodedTableSize(table)
  end for
  payload = bytes(total, 0)
  copyExact(payload, 0, catalog.databaseId, 0, 16)
  endian.writeU64LE(payload, 16, endian.uint64FromInt(catalog.nextObjectId))
  endian.writeU32LE(payload, 24, len(catalog.tables))
  endian.writeU32LE(payload, 28, 0)
  offset = 32
  for each table in catalog.tables
    nameBytes = bytes(table.name)
    endian.writeU64LE(payload, offset, endian.uint64FromInt(table.tableId))
    endian.writeU32LE(payload, offset + 8, table.schemaVersion)
    endian.writeU32LE(payload, offset + 12, len(table.columns))
    endian.writeU16LE(payload, offset + 16, len(nameBytes))
    endian.writeU16LE(payload, offset + 18, 0)
    endian.writeU32LE(payload, offset + 20, 0)
    copyExact(payload, offset + 24, nameBytes, 0, len(nameBytes))
    offset = offset + 24 + len(nameBytes)
    for each column in table.columns
      columnName = bytes(column.name)
      endian.writeU64LE(payload, offset, endian.uint64FromInt(column.columnId))
      endian.writeU16LE(payload, offset + 8, column.typeCode)
      flags = 0
      if column.nullable then flags = 1 end if
      endian.writeU16LE(payload, offset + 10, flags)
      endian.writeU32LE(payload, offset + 12, column.maxLength)
      endian.writeU16LE(payload, offset + 16, column.precision)
      endian.writeU16LE(payload, offset + 18, column.scale)
      endian.writeU16LE(payload, offset + 20, len(columnName))
      endian.writeU16LE(payload, offset + 22, 0)
      endian.writeU32LE(payload, offset + 24, 0)
      copyExact(payload, offset + 28, columnName, 0, len(columnName))
      offset = offset + 28 + len(columnName)
    end for
  end for
  return checksum.encodeEnvelope(catalogMagic(), CATALOG_FORMAT_VERSION, CATALOG_KIND, 0, payload)
end function

/// Performs the require range operation for this module.
/// Inputs: `payload`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param payload payload value consumed by this operation.
/// @param offset Zero-based offset at which processing starts.
/// @param count Number of items or units to process.
/// @param operation operation value consumed by this operation.
function requireRange(payload, offset, count, operation)
  if offset < 0 or count < 0 or offset > len(payload) or count > len(payload) - offset then
    return fail(CORRUPT_DATA, operation, "catalog entry exceeds payload")
  end if
  return true
end function

/// Decodes the catalog.
/// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param encoded encoded value consumed by this operation.
function decodeCatalog(encoded)
  envelope = checksum.decodeEnvelope(encoded, catalogMagic(), CATALOG_FORMAT_VERSION, CATALOG_KIND)
  payload = envelope.payload
  if len(payload) < 32 then return fail(CORRUPT_DATA, "decodeCatalog", "catalog payload too short") end if
  if endian.readU32LE(payload, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeCatalog", "reserved catalog field is non-zero") end if
  catalog = createCatalog(slice(payload, 0, 16), decodeNative(endian.readU64LE(payload, 16), "decodeCatalog", "nextObjectId"))
  tableCount = endian.readU32LE(payload, 24)
  catalog.tables = array(tableCount)
  offset = 32
  if tableCount > 0 then
    for tableIndex = 0 to tableCount - 1
      requireRange(payload, offset, 24, "decodeCatalog")
      tableId = decodeNative(endian.readU64LE(payload, offset), "decodeCatalog", "tableId")
      schemaVersion = endian.readU32LE(payload, offset + 8)
      columnCount = endian.readU32LE(payload, offset + 12)
      nameLength = endian.readU16LE(payload, offset + 16)
      if endian.readU16LE(payload, offset + 18) != 0 or endian.readU32LE(payload, offset + 20) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeCatalog", "reserved table fields are non-zero") end if
      requireRange(payload, offset + 24, nameLength, "decodeCatalog")
      tableName = decode(slice(payload, offset + 24, nameLength))
      offset = offset + 24 + nameLength
      columns = array(columnCount)
      if columnCount > 0 then
        for columnIndex = 0 to columnCount - 1
          requireRange(payload, offset, 28, "decodeCatalog")
          columnId = decodeNative(endian.readU64LE(payload, offset), "decodeCatalog", "columnId")
          typeCode = endian.readU16LE(payload, offset + 8)
          flags = endian.readU16LE(payload, offset + 10)
          maxLength = endian.readU32LE(payload, offset + 12)
          precision = endian.readU16LE(payload, offset + 16)
          scale = endian.readU16LE(payload, offset + 18)
          columnNameLength = endian.readU16LE(payload, offset + 20)
          if endian.readU16LE(payload, offset + 22) != 0 or endian.readU32LE(payload, offset + 24) != 0 or (flags & 0xFFFE) != 0 then
            return fail(UNSUPPORTED_FORMAT, "decodeCatalog", "reserved column fields are non-zero")
          end if
          requireRange(payload, offset + 28, columnNameLength, "decodeCatalog")
          columnName = decode(slice(payload, offset + 28, columnNameLength))
          columns[columnIndex] = createColumn(columnId, columnName, typeCode, (flags & 1) != 0, maxLength, precision, scale)
          offset = offset + 28 + columnNameLength
        end for
      end if
      catalog.tables[tableIndex] = createTable(tableId, tableName, schemaVersion, columns)
    end for
  end if
  if offset != len(payload) then return fail(CORRUPT_DATA, "decodeCatalog", "trailing catalog bytes") end if
  return catalog
end function

/// M21 security catalog. The sidecar is a CRC-protected, self-identifying
const SECURITY_FORMAT_VERSION = 1
/// Defines the security kind constant used by the minisql catalog metadata module.
const SECURITY_KIND = 70

/// Defines the principal user constant used by the minisql catalog metadata module.
const PRINCIPAL_USER = 1
/// Defines the principal role constant used by the minisql catalog metadata module.
const PRINCIPAL_ROLE = 2
/// Defines the principal admin id constant used by the minisql catalog metadata module.
const PRINCIPAL_ADMIN_ID = 1
/// Defines the principal public id constant used by the minisql catalog metadata module.
const PRINCIPAL_PUBLIC_ID = 2

/// Defines the object database constant used by the minisql catalog metadata module.
const OBJECT_DATABASE = 1
/// Defines the object table constant used by the minisql catalog metadata module.
const OBJECT_TABLE = 2

/// Defines the privilege connect constant used by the minisql catalog metadata module.
const PRIVILEGE_CONNECT = 1
/// Defines the privilege create constant used by the minisql catalog metadata module.
const PRIVILEGE_CREATE = 2
/// Defines the privilege maintain constant used by the minisql catalog metadata module.
const PRIVILEGE_MAINTAIN = 3
/// Defines the privilege admin constant used by the minisql catalog metadata module.
const PRIVILEGE_ADMIN = 4
/// Defines the privilege select constant used by the minisql catalog metadata module.
const PRIVILEGE_SELECT = 10
/// Defines the privilege insert constant used by the minisql catalog metadata module.
const PRIVILEGE_INSERT = 11
/// Defines the privilege update constant used by the minisql catalog metadata module.
const PRIVILEGE_UPDATE = 12
/// Defines the privilege delete constant used by the minisql catalog metadata module.
const PRIVILEGE_DELETE = 13
/// Defines the privilege references constant used by the minisql catalog metadata module.
const PRIVILEGE_REFERENCES = 14
/// Defines the privilege index constant used by the minisql catalog metadata module.
const PRIVILEGE_INDEX = 15
/// Defines the privilege alter constant used by the minisql catalog metadata module.
const PRIVILEGE_ALTER = 16
/// Defines the privilege drop constant used by the minisql catalog metadata module.
const PRIVILEGE_DROP = 17
/// Defines the privilege owner constant used by the minisql catalog metadata module.
const PRIVILEGE_OWNER = 18

/// Defines the principal header bytes constant used by the minisql catalog metadata module.
const PRINCIPAL_HEADER_BYTES = 24
/// Defines the membership bytes constant used by the minisql catalog metadata module.
const MEMBERSHIP_BYTES = 32
/// Defines the privilege grant bytes constant used by the minisql catalog metadata module.
const PRIVILEGE_GRANT_BYTES = 40
/// Defines the security legacy header bytes constant used by the minisql catalog metadata module.
const SECURITY_LEGACY_HEADER_BYTES = 40
/// Defines the security header bytes constant used by the minisql catalog metadata module.
const SECURITY_HEADER_BYTES = 48
/// Defines the security extended counts flag constant used by the minisql catalog metadata module.
const SECURITY_EXTENDED_COUNTS_FLAG = 1

/// Defines the principal metadata record used by this module.
struct PrincipalMetadata
  /// Principal id field of the principal metadata.
  principalId
  /// Name field of the principal metadata.
  name
  /// Principal kind field of the principal metadata.
  principalKind
  /// Enabled field of the principal metadata.
  enabled
  /// Can login field of the principal metadata.
  canLogin
  /// Superuser field of the principal metadata.
  superuser
  /// Builtin field of the principal metadata.
  builtin
  /// Salt field of the principal metadata.
  salt
  /// Iterations field of the principal metadata.
  iterations
  /// Verifier field of the principal metadata.
  verifier
end struct

/// Defines the role membership record used by this module.
struct RoleMembership
  /// Role id field of the role membership.
  roleId
  /// Member id field of the role membership.
  memberId
  /// Grantor id field of the role membership.
  grantorId
  /// Admin option field of the role membership.
  adminOption
end struct

/// Defines the privilege grant record used by this module.
struct PrivilegeGrant
  /// Grantee id field of the privilege grant.
  granteeId
  /// Grantor id field of the privilege grant.
  grantorId
  /// Object type field of the privilege grant.
  objectType
  /// Object id field of the privilege grant.
  objectId
  /// Privilege field of the privilege grant.
  privilege
  /// Grant option field of the privilege grant.
  grantOption
end struct

/// Defines the security state record used by this module.
struct SecurityState
  /// Database id field of the security state.
  databaseId
  /// Generation field of the security state.
  generation
  /// Next principal id field of the security state.
  nextPrincipalId
  /// Principals field of the security state.
  principals
  /// Memberships field of the security state.
  memberships
  /// Grants field of the security state.
  grants
end struct

/// Performs the security magic operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function securityMagic()
  return bytes("MSSEC001")
end function

/// Evaluates whether the supplied input satisfies the principal metadata predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isPrincipalMetadata(value)
  return value is PrincipalMetadata
end function

/// Evaluates whether the supplied input satisfies the role membership predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isRoleMembership(value)
  return value is RoleMembership
end function

/// Evaluates whether the supplied input satisfies the privilege grant predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isPrivilegeGrant(value)
  return value is PrivilegeGrant
end function

/// Evaluates whether the supplied input satisfies the security state predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isSecurityState(value)
  return value is SecurityState
end function

/// Validates the security name.
/// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
function validateSecurityName(value, operation)
  if typeof(value) != "string" or len(bytes(value)) == 0 or len(bytes(value)) > 128 then
    return fail(INVALID_ARGUMENT, operation, "principal name must contain 1..128 UTF-8 bytes")
  end if
  raw = bytes(value)
  for each character in raw
    if character == 0 or character == 47 or character == 92 then
      return fail(INVALID_ARGUMENT, operation, "principal name contains an unsafe character")
    end if
  end for
  return true
end function

/// Creates the principal.
/// Inputs: `principalId`, `name`, `principalKind`, `enabled`, `canLogin`, `superuser`, `builtin`, `salt`, `iterations`, `verifier`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param principalId Identifier of principal.
/// @param name Name of the affected item.
/// @param principalKind principalKind value consumed by this operation.
/// @param enabled enabled value consumed by this operation.
/// @param canLogin canLogin value consumed by this operation.
/// @param superuser superuser value consumed by this operation.
/// @param builtin builtin value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param iterations iterations value consumed by this operation.
/// @param verifier verifier value consumed by this operation.
function createPrincipal(principalId, name, principalKind, enabled, canLogin, superuser, builtin, salt, iterations, verifier)
  validateId(principalId, "createPrincipal", "principalId")
  validateSecurityName(name, "createPrincipal")
  if principalKind != PRINCIPAL_USER and principalKind != PRINCIPAL_ROLE then return fail(INVALID_ARGUMENT, "createPrincipal", "invalid principal kind") end if
  if typeof(enabled) != "bool" or typeof(canLogin) != "bool" or typeof(superuser) != "bool" or typeof(builtin) != "bool" then
    return fail(INVALID_ARGUMENT, "createPrincipal", "principal flags must be bool")
  end if
  if typeof(salt) != "bytes" or typeof(verifier) != "bytes" or typeof(iterations) != "int" then return fail(INVALID_ARGUMENT, "createPrincipal", "password material is invalid") end if
  emptyMaterial = len(salt) == 0 and len(verifier) == 0 and iterations == 0
  if principalKind == PRINCIPAL_ROLE then
    if canLogin or superuser then return fail(INVALID_ARGUMENT, "createPrincipal", "roles cannot log in or be superusers") end if
    if not emptyMaterial then return fail(INVALID_ARGUMENT, "createPrincipal", "roles cannot contain password material") end if
    return PrincipalMetadata(principalId, name, principalKind, enabled, false, false, builtin, bytes(0), 0, bytes(0))
  end if
  if superuser and not canLogin then return fail(INVALID_ARGUMENT, "createPrincipal", "a superuser must be login-capable") end if
  if emptyMaterial then
    if canLogin and not builtin then return fail(INVALID_ARGUMENT, "createPrincipal", "a login user requires password material") end if
    return PrincipalMetadata(principalId, name, principalKind, enabled, canLogin, superuser, builtin, bytes(0), 0, bytes(0))
  end if
  if not canLogin then return fail(INVALID_ARGUMENT, "createPrincipal", "a non-login user cannot contain password material") end if
  if len(salt) != 16 or (len(verifier) != 32 and len(verifier) != 64) or iterations < 10000 or iterations > 5000000 then
    return fail(INVALID_ARGUMENT, "createPrincipal", "invalid PBKDF2 password material")
  end if
  return PrincipalMetadata(principalId, name, principalKind, enabled, canLogin, superuser, builtin, bytes(salt), iterations, bytes(verifier))
end function

/// Creates the role membership.
/// Inputs: `roleId`, `memberId`, `grantorId`, `adminOption`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param roleId Identifier of role.
/// @param memberId Identifier of member.
/// @param grantorId Identifier of grantor.
/// @param adminOption adminOption value consumed by this operation.
function createRoleMembership(roleId, memberId, grantorId, adminOption)
  validateId(roleId, "createRoleMembership", "roleId")
  validateId(memberId, "createRoleMembership", "memberId")
  validateId(grantorId, "createRoleMembership", "grantorId")
  if typeof(adminOption) != "bool" then return fail(INVALID_ARGUMENT, "createRoleMembership", "adminOption must be bool") end if
  if roleId == memberId then return fail(INVALID_ARGUMENT, "createRoleMembership", "a role cannot contain itself") end if
  return RoleMembership(roleId, memberId, grantorId, adminOption)
end function

/// Performs the valid object type operation for this module.
/// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param value Value consumed or transformed by the operation.
function validObjectType(value)
  return value == OBJECT_DATABASE or value == OBJECT_TABLE
end function

/// Performs the valid privilege operation for this module.
/// Inputs: `objectType`, `privilege`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param objectType objectType value consumed by this operation.
/// @param privilege privilege value consumed by this operation.
function validPrivilege(objectType, privilege)
  if objectType == OBJECT_DATABASE then
    return privilege == PRIVILEGE_CONNECT or privilege == PRIVILEGE_CREATE or privilege == PRIVILEGE_MAINTAIN or privilege == PRIVILEGE_ADMIN
  end if
  if objectType == OBJECT_TABLE then
    return privilege == PRIVILEGE_SELECT or privilege == PRIVILEGE_INSERT or privilege == PRIVILEGE_UPDATE or privilege == PRIVILEGE_DELETE or privilege == PRIVILEGE_REFERENCES or privilege == PRIVILEGE_INDEX or privilege == PRIVILEGE_ALTER or privilege == PRIVILEGE_DROP or privilege == PRIVILEGE_OWNER
  end if
  return false
end function

/// Creates the privilege grant.
/// Inputs: `granteeId`, `grantorId`, `objectType`, `objectId`, `privilege`, `grantOption`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param granteeId Identifier of grantee.
/// @param grantorId Identifier of grantor.
/// @param objectType objectType value consumed by this operation.
/// @param objectId Identifier of object.
/// @param privilege privilege value consumed by this operation.
/// @param grantOption grantOption value consumed by this operation.
function createPrivilegeGrant(granteeId, grantorId, objectType, objectId, privilege, grantOption)
  validateId(granteeId, "createPrivilegeGrant", "granteeId")
  validateId(grantorId, "createPrivilegeGrant", "grantorId")
  validateId(objectId, "createPrivilegeGrant", "objectId")
  if not validObjectType(objectType) or not validPrivilege(objectType, privilege) then return fail(INVALID_ARGUMENT, "createPrivilegeGrant", "invalid privilege target") end if
  if objectType == OBJECT_DATABASE and objectId != 0 then return fail(INVALID_ARGUMENT, "createPrivilegeGrant", "database objectId must be zero") end if
  if objectType == OBJECT_TABLE and objectId <= 0 then return fail(INVALID_ARGUMENT, "createPrivilegeGrant", "table objectId must be positive") end if
  if typeof(grantOption) != "bool" then return fail(INVALID_ARGUMENT, "createPrivilegeGrant", "grantOption must be bool") end if
  return PrivilegeGrant(granteeId, grantorId, objectType, objectId, privilege, grantOption)
end function

/// Creates the security.
/// Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databaseId Identifier of database.
function createSecurity(databaseId)
  validateDatabaseId(databaseId, "createSecurity")
  administrator = createPrincipal(PRINCIPAL_ADMIN_ID, "admin", PRINCIPAL_USER, true, true, true, true, bytes(0), 0, bytes(0))
  publicRole = createPrincipal(PRINCIPAL_PUBLIC_ID, "public", PRINCIPAL_ROLE, true, false, false, true, bytes(0), 0, bytes(0))
  return SecurityState(bytes(databaseId), 1, 3, [administrator, publicRole], [], [])
end function

/// Performs the principal encoded size operation for this module.
/// Inputs: `principal`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param principal principal value consumed by this operation.
function principalEncodedSize(principal)
  return PRINCIPAL_HEADER_BYTES + len(bytes(principal.name)) + len(principal.salt) + len(principal.verifier)
end function

/// Encodes the security.
/// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param state Mutable state inspected or updated by the operation.
function encodeSecurity(state)
  if state is not SecurityState then return fail(INVALID_ARGUMENT, "encodeSecurity", "state must be SecurityState") end if
  validateDatabaseId(state.databaseId, "encodeSecurity")
  validateId(state.generation, "encodeSecurity", "generation")
  validateId(state.nextPrincipalId, "encodeSecurity", "nextPrincipalId")
  if typeof(state.principals) != "array" or typeof(state.memberships) != "array" or typeof(state.grants) != "array" then return fail(INVALID_ARGUMENT, "encodeSecurity", "security collections must be arrays") end if
  // The envelope stays at format version 1 for on-disk compatibility. Flag 1
  // selects the extended header whose collection counts are U32 rather than
  // the legacy U16 fields, removing the old 65,535-object catalog ceiling.
  if len(state.principals) > endian.MAX_U32 or len(state.memberships) > endian.MAX_U32 or len(state.grants) > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodeSecurity", "security collection count exceeds the U32 representation") end if
  total = SECURITY_HEADER_BYTES + len(state.memberships) * MEMBERSHIP_BYTES + len(state.grants) * PRIVILEGE_GRANT_BYTES
  for each principal in state.principals
    if principal is not PrincipalMetadata then return fail(INVALID_ARGUMENT, "encodeSecurity", "invalid principal") end if
    total = total + principalEncodedSize(principal)
  end for
  payload = bytes(total, 0)
  copyExact(payload, 0, state.databaseId, 0, 16)
  endian.writeU64LE(payload, 16, endian.uint64FromInt(state.generation))
  endian.writeU64LE(payload, 24, endian.uint64FromInt(state.nextPrincipalId))
  endian.writeU32LE(payload, 32, len(state.principals))
  endian.writeU32LE(payload, 36, len(state.memberships))
  endian.writeU32LE(payload, 40, len(state.grants))
  endian.writeU32LE(payload, 44, 0)
  offset = SECURITY_HEADER_BYTES
  for each principal in state.principals
    validated = createPrincipal(principal.principalId, principal.name, principal.principalKind, principal.enabled, principal.canLogin, principal.superuser, principal.builtin, principal.salt, principal.iterations, principal.verifier)
    if typeof(validated.salt) == "bytes" then fillBytes(validated.salt, 0, len(validated.salt), 0) end if
    if typeof(validated.verifier) == "bytes" then fillBytes(validated.verifier, 0, len(validated.verifier), 0) end if
    nameBytes = bytes(principal.name)
    flags = 0
    if principal.enabled then flags = flags | 1 end if
    if principal.canLogin then flags = flags | 2 end if
    if principal.superuser then flags = flags | 4 end if
    if principal.builtin then flags = flags | 8 end if
    endian.writeU64LE(payload, offset, endian.uint64FromInt(principal.principalId))
    payload[offset + 8] = principal.principalKind
    payload[offset + 9] = flags
    endian.writeU16LE(payload, offset + 10, len(nameBytes))
    endian.writeU32LE(payload, offset + 12, principal.iterations)
    endian.writeU16LE(payload, offset + 16, len(principal.salt))
    endian.writeU16LE(payload, offset + 18, len(principal.verifier))
    endian.writeU32LE(payload, offset + 20, 0)
    copyExact(payload, offset + PRINCIPAL_HEADER_BYTES, nameBytes, 0, len(nameBytes))
    cursor = offset + PRINCIPAL_HEADER_BYTES + len(nameBytes)
    copyExact(payload, cursor, principal.salt, 0, len(principal.salt))
    cursor = cursor + len(principal.salt)
    copyExact(payload, cursor, principal.verifier, 0, len(principal.verifier))
    offset = cursor + len(principal.verifier)
  end for
  for each membership in state.memberships
    if membership is not RoleMembership then return fail(INVALID_ARGUMENT, "encodeSecurity", "invalid role membership") end if
    validatedMembership = createRoleMembership(membership.roleId, membership.memberId, membership.grantorId, membership.adminOption)
    endian.writeU64LE(payload, offset, endian.uint64FromInt(membership.roleId))
    endian.writeU64LE(payload, offset + 8, endian.uint64FromInt(membership.memberId))
    endian.writeU64LE(payload, offset + 16, endian.uint64FromInt(membership.grantorId))
    membershipFlags = 0
    if membership.adminOption then membershipFlags = 1 end if
    endian.writeU32LE(payload, offset + 24, membershipFlags)
    endian.writeU32LE(payload, offset + 28, 0)
    offset = offset + MEMBERSHIP_BYTES
  end for
  for each grant in state.grants
    if grant is not PrivilegeGrant then return fail(INVALID_ARGUMENT, "encodeSecurity", "invalid privilege grant") end if
    validatedGrant = createPrivilegeGrant(grant.granteeId, grant.grantorId, grant.objectType, grant.objectId, grant.privilege, grant.grantOption)
    endian.writeU64LE(payload, offset, endian.uint64FromInt(grant.granteeId))
    endian.writeU64LE(payload, offset + 8, endian.uint64FromInt(grant.grantorId))
    endian.writeU64LE(payload, offset + 16, endian.uint64FromInt(grant.objectId))
    endian.writeU16LE(payload, offset + 24, grant.objectType)
    endian.writeU16LE(payload, offset + 26, grant.privilege)
    grantFlags = 0
    if grant.grantOption then grantFlags = 1 end if
    endian.writeU32LE(payload, offset + 28, grantFlags)
    endian.writeU32LE(payload, offset + 32, 0)
    endian.writeU32LE(payload, offset + 36, 0)
    offset = offset + PRIVILEGE_GRANT_BYTES
  end for
  return checksum.encodeEnvelope(securityMagic(), SECURITY_FORMAT_VERSION, SECURITY_KIND, SECURITY_EXTENDED_COUNTS_FLAG, payload)
end function

/// Decodes the security.
/// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param encoded encoded value consumed by this operation.
function decodeSecurity(encoded)
  envelope = checksum.decodeEnvelope(encoded, securityMagic(), SECURITY_FORMAT_VERSION, SECURITY_KIND)
  payload = envelope.payload
  if envelope.flags != 0 and envelope.flags != SECURITY_EXTENDED_COUNTS_FLAG then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "security envelope flags are unsupported") end if
  headerBytes = SECURITY_LEGACY_HEADER_BYTES
  if envelope.flags == SECURITY_EXTENDED_COUNTS_FLAG then headerBytes = SECURITY_HEADER_BYTES end if
  if len(payload) < headerBytes then return fail(CORRUPT_DATA, "decodeSecurity", "security payload too short") end if
  databaseId = slice(payload, 0, 16)
  generation = decodeNative(endian.readU64LE(payload, 16), "decodeSecurity", "generation")
  nextPrincipalId = decodeNative(endian.readU64LE(payload, 24), "decodeSecurity", "nextPrincipalId")
  principalCount = endian.readU16LE(payload, 32)
  membershipCount = endian.readU16LE(payload, 34)
  grantCount = endian.readU16LE(payload, 36)
  if envelope.flags == SECURITY_EXTENDED_COUNTS_FLAG then
    principalCount = endian.readU32LE(payload, 32)
    membershipCount = endian.readU32LE(payload, 36)
    grantCount = endian.readU32LE(payload, 40)
    if endian.readU32LE(payload, 44) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "reserved security header is non-zero") end if
  else
    if endian.readU16LE(payload, 38) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "reserved security header is non-zero") end if
  end if
  state = SecurityState(databaseId, generation, nextPrincipalId, [], [], [])
  state.principals = array(principalCount)
  state.memberships = array(membershipCount)
  state.grants = array(grantCount)
  offset = headerBytes
  if principalCount > 0 then
    for principalIndex = 0 to principalCount - 1
      requireRange(payload, offset, PRINCIPAL_HEADER_BYTES, "decodeSecurity")
      principalId = decodeNative(endian.readU64LE(payload, offset), "decodeSecurity", "principalId")
      principalKind = payload[offset + 8]
      flags = payload[offset + 9]
      nameLength = endian.readU16LE(payload, offset + 10)
      iterations = endian.readU32LE(payload, offset + 12)
      saltLength = endian.readU16LE(payload, offset + 16)
      verifierLength = endian.readU16LE(payload, offset + 18)
      if endian.readU32LE(payload, offset + 20) != 0 or (flags & 0xF0) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "reserved principal fields are non-zero") end if
      variableLength = nameLength + saltLength + verifierLength
      requireRange(payload, offset + PRINCIPAL_HEADER_BYTES, variableLength, "decodeSecurity")
      cursor = offset + PRINCIPAL_HEADER_BYTES
      name = decode(slice(payload, cursor, nameLength))
      cursor = cursor + nameLength
      salt = slice(payload, cursor, saltLength)
      cursor = cursor + saltLength
      verifier = slice(payload, cursor, verifierLength)
      state.principals[principalIndex] = createPrincipal(principalId, name, principalKind, (flags & 1) != 0, (flags & 2) != 0, (flags & 4) != 0, (flags & 8) != 0, salt, iterations, verifier)
      offset = cursor + verifierLength
    end for
  end if
  if membershipCount > 0 then
    for membershipIndex = 0 to membershipCount - 1
      requireRange(payload, offset, MEMBERSHIP_BYTES, "decodeSecurity")
      flags = endian.readU32LE(payload, offset + 24)
      if endian.readU32LE(payload, offset + 28) != 0 or (flags & 0xFFFFFFFE) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "reserved membership fields are non-zero") end if
      state.memberships[membershipIndex] = createRoleMembership(
        decodeNative(endian.readU64LE(payload, offset), "decodeSecurity", "roleId"),
        decodeNative(endian.readU64LE(payload, offset + 8), "decodeSecurity", "memberId"),
        decodeNative(endian.readU64LE(payload, offset + 16), "decodeSecurity", "grantorId"),
        (flags & 1) != 0
      )
      offset = offset + MEMBERSHIP_BYTES
    end for
  end if
  if grantCount > 0 then
    for grantIndex = 0 to grantCount - 1
      requireRange(payload, offset, PRIVILEGE_GRANT_BYTES, "decodeSecurity")
      flags = endian.readU32LE(payload, offset + 28)
      if endian.readU32LE(payload, offset + 32) != 0 or endian.readU32LE(payload, offset + 36) != 0 or (flags & 0xFFFFFFFE) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSecurity", "reserved grant fields are non-zero") end if
      state.grants[grantIndex] = createPrivilegeGrant(
        decodeNative(endian.readU64LE(payload, offset), "decodeSecurity", "granteeId"),
        decodeNative(endian.readU64LE(payload, offset + 8), "decodeSecurity", "grantorId"),
        endian.readU16LE(payload, offset + 24),
        decodeNative(endian.readU64LE(payload, offset + 16), "decodeSecurity", "objectId"),
        endian.readU16LE(payload, offset + 26),
        (flags & 1) != 0
      )
      offset = offset + PRIVILEGE_GRANT_BYTES
    end for
  end if
  if offset != len(payload) then return fail(CORRUPT_DATA, "decodeSecurity", "trailing security bytes") end if
  return state
end function

/// Performs the componentName operation for the minisql catalog metadata module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "catalog.metadata"
end function

/// Performs the targetMilestone operation for the minisql catalog metadata module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M8"
end function

/// Returns whether implemented satisfies the condition required by the minisql catalog metadata module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
