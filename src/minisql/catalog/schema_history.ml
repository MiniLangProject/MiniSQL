package minisql.catalog.schema_history
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.sql.ast as ast
import minisql.sql.binder as binder
import minisql.sql.parser as parser
import minisql.storage.btree as btree
import minisql.storage.checksum as checksum
import minisql.storage.heap_file as heap_file
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock

// Durable schema/constraint sidecar and transactional DDL journal.
//
// The M8 bootstrap catalog intentionally remains format v1. M14 adds richer
// schema information in catalog/schema.history, protected by a CRC envelope.
// DDL uses a before-image journal. Recovery before catalog.openDatabase either
// restores the old metadata (PREPARED) or keeps the published generation
// (COMMITTED). This allows CREATE TABLE/INDEX and DROP TABLE to be atomic across
// catalog metadata and physical files without changing accepted M8 formats.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const IO_FAILURE = 9005
const CLOSED_HANDLE = 9008
const OBJECT_EXISTS = 9013
const OBJECT_NOT_FOUND = 9014
const BINDING_ERROR = 9020
const CONSTRAINT_VIOLATION = 9021
const DDL_STATE = 9023
const UNSUPPORTED_SQL = 9025

const FORMAT_VERSION = 1
const SCHEMA_KIND = 40
const JOURNAL_KIND = 41
const MAINTENANCE_KIND = 42
const EXTENSION_KIND = 43
const JOURNAL_PREPARED = 1
const JOURNAL_COMMITTED = 2
const MAINTENANCE_PREPARED = 1
const MAINTENANCE_COMMITTED = 2

const CONSTRAINT_PRIMARY_KEY = 1
const CONSTRAINT_UNIQUE = 2
const CONSTRAINT_CHECK = 3
const CONSTRAINT_FOREIGN_KEY = 4
const CONSTRAINT_INDEX = 5

const ACTION_CREATE_TABLE = 1
const ACTION_CREATE_INDEX = 2
const ACTION_DROP_TABLE = 3
const ACTION_ALTER_TABLE = 4
const ACTION_CREATE_VIEW = 5
const ACTION_DROP_VIEW = 6
const ACTION_CREATE_SEQUENCE = 7
const ACTION_DROP_SEQUENCE = 8
const ACTION_CREATE_TRIGGER = 9
const ACTION_DROP_TRIGGER = 10

const SCHEMA_EXTENSION_VERSION = 1
const TRIGGER_BEFORE = 1
const TRIGGER_AFTER = 2
const TRIGGER_INSERT = 1
const TRIGGER_UPDATE = 2
const TRIGGER_DELETE = 3

const SCHEMA_MARKER_PREFIX = "__minisql_schema__"
const PROCEDURE_MARKER_PREFIX = "__minisql_procedure__"

// Defines the column rule record used by this module.
struct ColumnRule
  // Column name field of the column rule.
  columnName
  // Default sql field of the column rule.
  defaultSql
  // Identity field of the column rule.
  identity
end struct

// Defines the constraint definition record used by this module.
struct ConstraintDefinition
  // Name field of the constraint definition.
  name
  // Kind field of the constraint definition.
  kind
  // Columns field of the constraint definition.
  columns
  // CHECK expression or partial-index predicate in canonical SQL form.
  expressionSql
  // Reference table field of the constraint definition.
  referenceTable
  // Referenced columns for foreign keys. For index-backed local constraints,
  // this backwards-compatible extension slot stores ordered INCLUDE columns.
  referenceColumns
  // On delete field of the constraint definition.
  onDelete
  // On update field of the constraint definition.
  onUpdate
  // Index id field of the constraint definition.
  indexId
  // Index name field of the constraint definition.
  indexName
end struct

// Defines the table schema record used by this module.
struct TableSchema
  // Table id field of the table schema.
  tableId
  // Schema version field of the table schema.
  schemaVersion
  // Column rules field of the table schema.
  columnRules
  // Constraints field of the table schema.
  constraints
end struct

// Defines the view definition record used by this module.
struct ViewDefinition
  // View id field of the view definition.
  viewId
  // Name field of the view definition.
  name
  // Sql text field of the view definition.
  sqlText
  // Column names field of the view definition.
  columnNames
end struct

// Defines the sequence definition record used by this module.
struct SequenceDefinition
  // Sequence id field of the sequence definition.
  sequenceId
  // Name field of the sequence definition.
  name
  // Start value field of the sequence definition.
  startValue
  // Increment value field of the sequence definition.
  incrementValue
  // Minimum value field of the sequence definition.
  minimumValue
  // Maximum value field of the sequence definition.
  maximumValue
  // Last value field of the sequence definition.
  lastValue
  // Has value field of the sequence definition.
  hasValue
  // Cycle field of the sequence definition.
  cycle
  // Owned table id field of the sequence definition.
  ownedTableId
  // Owned column name field of the sequence definition.
  ownedColumnName
end struct

// Defines the generated column definition record used by this module.
struct GeneratedColumnDefinition
  // Table id field of the generated column definition.
  tableId
  // Column name field of the generated column definition.
  columnName
  // Expression sql field of the generated column definition.
  expressionSql
  // Stored field of the generated column definition.
  stored
end struct

// Defines the trigger definition record used by this module.
struct TriggerDefinition
  // Trigger id field of the trigger definition.
  triggerId
  // Name field of the trigger definition.
  name
  // Table id field of the trigger definition.
  tableId
  // Timing field of the trigger definition.
  timing
  // Event type field of the trigger definition.
  eventType
  // Target column field of the trigger definition.
  targetColumn
  // Expression sql field of the trigger definition.
  expressionSql
  // Enabled field of the trigger definition.
  enabled
end struct

// Defines the schema state record used by this module.
struct SchemaState
  // Database id field of the schema state.
  databaseId
  // Generation field of the schema state.
  generation
  // Tables field of the schema state.
  tables
  // Views field of the schema state.
  views
  // Sequences field of the schema state.
  sequences
  // Generated columns field of the schema state.
  generatedColumns
  // Triggers field of the schema state.
  triggers
end struct

// Defines the ddl action record used by this module.
struct DdlAction
  // Kind field of the ddl action.
  kind
  // Payload field of the ddl action.
  payload
end struct

// Defines the ddl transaction record used by this module.
struct DdlTransaction
  // Database field of the ddl transaction.
  database
  // State field of the ddl transaction.
  state
  // Actions field of the ddl transaction.
  actions
  // Active field of the ddl transaction.
  active
end struct

// Defines the create file plan record used by this module.
struct CreateFilePlan
  // Temporary path field of the create file plan.
  temporaryPath
  // Final path field of the create file plan.
  finalPath
  // File kind field of the create file plan.
  fileKind
  // File id field of the create file plan.
  fileId
  // Unique field of the create file plan.
  unique
end struct

// Defines the backup plan record used by this module.
struct BackupPlan
  // Original path field of the backup plan.
  originalPath
  // Backup path field of the backup plan.
  backupPath
end struct

// Defines the prepared ddl record used by this module.
struct PreparedDdl
  // New metadata field of the prepared ddl.
  newMetadata
  // New catalog field of the prepared ddl.
  newCatalog
  // New state field of the prepared ddl.
  newState
  // Create files field of the prepared ddl.
  createFiles
  // Backups field of the prepared ddl.
  backups
end struct

// Defines the ddl journal record used by this module.
struct DdlJournal
  // Status field of the ddl journal.
  status
  // Schema existed field of the ddl journal.
  schemaExisted
  // Old meta field of the ddl journal.
  oldMeta
  // Old catalog field of the ddl journal.
  oldCatalog
  // Old schema field of the ddl journal.
  oldSchema
  // Temporary paths field of the ddl journal.
  temporaryPaths
  // Final paths field of the ddl journal.
  finalPaths
  // Backup originals field of the ddl journal.
  backupOriginals
  // Backup paths field of the ddl journal.
  backupPaths
end struct

// Defines the maintenance journal record used by this module.
struct MaintenanceJournal
  // Status field of the maintenance journal.
  status
  // Original path field of the maintenance journal.
  originalPath
  // Temporary path field of the maintenance journal.
  temporaryPath
  // Backup path field of the maintenance journal.
  backupPath
end struct

// Defines the decoded string record used by this module.
struct DecodedString
  // Value field of the decoded string.
  value
  // Next offset field of the decoded string.
  nextOffset
end struct

// Generic cursor result used by the schema-extension decoder. Keeping each
// record decoder in its own function avoids a large lexical block with many
// temporary locals retaining and later clearing the shared payload reference.
// Defines the decoded extension entry record used by this module.
struct DecodedExtensionEntry
  // Value field of the decoded extension entry.
  value
  // Next offset field of the decoded extension entry.
  nextOffset
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "catalog.schema_history." + operation + ": " + message)
end function

// Returns a fresh copy of the schema-history magic bytes.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function schemaMagic()
  return bytes("MSSCHEM1")
end function

// Returns a fresh copy of the DDL-journal magic bytes.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function journalMagic()
  return bytes("MSDDLJ01")
end function

// Returns a fresh copy of the maintenance-journal magic bytes.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function maintenanceMagic()
  return bytes("MSMAINT1")
end function

// Performs the extension magic operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function extensionMagic()
  return bytes("MSEXT001")
end function

// Performs the schema path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function schemaPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "schema.history")
end function

// Performs the journal path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function journalPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "ddl.pending")
end function

// Performs the maintenance path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function maintenancePath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "maintenance.pending")
end function

// Performs the extension path operation for this module.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function extensionPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "schema.extensions")
end function

// Performs the index file path operation for this module.
// Inputs: `databasePath`, `indexId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function indexFilePath(databasePath, indexId)
  return catalog.joinPath(catalog.joinPath(databasePath, "indexes"), "i" + indexId + ".idx")
end function

// Evaluates whether the supplied input satisfies the schema state predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isSchemaState(value)
  return value is SchemaState
end function

// Evaluates whether the supplied input satisfies the constraint definition predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isConstraintDefinition(value)
  return value is ConstraintDefinition
end function

// Evaluates whether the supplied input satisfies the table schema predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isTableSchema(value)
  return value is TableSchema
end function

// Evaluates whether the supplied input satisfies the ddl transaction predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isDdlTransaction(value)
  return value is DdlTransaction
end function

// Evaluates whether the supplied input satisfies the view definition predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isViewDefinition(value)
  return value is ViewDefinition
end function

// Evaluates whether the supplied input satisfies the sequence definition predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isSequenceDefinition(value)
  return value is SequenceDefinition
end function

// Evaluates whether the supplied input satisfies the generated column definition predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isGeneratedColumnDefinition(value)
  return value is GeneratedColumnDefinition
end function

// Evaluates whether the supplied input satisfies the trigger definition predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isTriggerDefinition(value)
  return value is TriggerDefinition
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

// Copies the exact.
// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count <= 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

// Reads the whole.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readWhole(path)
  file = file_api.openRead(path)
  length = file_api.size(file)
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(file, 0, output, 0, length) end if
  file_api.close(file)
  return output
end function

// Writes the whole.
// Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeWhole(path, data)
  if typeof(data) != "bytes" then return fail(INVALID_ARGUMENT, "writeWhole", "data must be bytes") end if
  file = file_api.create(path)
  if len(data) > 0 then file_api.writeAt(file, 0, data, 0, len(data)) end if
  file_api.truncate(file, len(data))
  file_api.flush(file)
  file_api.close(file)
  return true
end function

// Writes the atomic.
// Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeAtomic(path, data)
  temporary = path + ".new"
  if file_api.pathExists(temporary) then file_api.deletePath(temporary) end if
  writeWhole(temporary, data)
  file_api.movePath(temporary, path, true)
  return true
end function

// Performs the string size operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stringSize(value)
  if value is void then return 4 end if
  if typeof(value) != "string" then return fail(INVALID_ARGUMENT, "stringSize", "value must be string or void") end if
  return 4 + len(bytes(value))
end function

// Writes the string.
// Inputs: `output`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeString(output, offset, value)
  data = bytes()
  if value is not void then data = bytes(value) end if
  endian.writeU32LE(output, offset, len(data))
  if len(data) > 0 then copyExact(output, offset + 4, data, 0, len(data)) end if
  return offset + 4 + len(data)
end function

// Reads the string.
// Inputs: `source`, `offset`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readString(source, offset, operation)
  if offset < 0 or offset > len(source) - 4 then return fail(CORRUPT_DATA, operation, "string length exceeds payload") end if
  length = endian.readU32LE(source, offset)
  if length > len(source) - offset - 4 then return fail(CORRUPT_DATA, operation, "string exceeds payload") end if
  value = ""
  if length > 0 then value = decode(slice(source, offset + 4, length)) end if
  return DecodedString(value, offset + 4 + length)
end function

// Performs the string array size operation for this module.
// Inputs: `values`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stringArraySize(values)
  if typeof(values) != "array" then return fail(INVALID_ARGUMENT, "stringArraySize", "values must be array") end if
  total = 4
  for each value in values
    total = total + stringSize(value)
  end for
  return total
end function

// Writes the string array.
// Inputs: `output`, `offset`, `values`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeStringArray(output, offset, values)
  endian.writeU32LE(output, offset, len(values))
  offset = offset + 4
  for each value in values
    offset = writeString(output, offset, value)
  end for
  return offset
end function

// Reads the string array.
// Inputs: `source`, `offset`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readStringArray(source, offset, operation)
  if offset < 0 or offset > len(source) - 4 then return fail(CORRUPT_DATA, operation, "array count exceeds payload") end if
  count = endian.readU32LE(source, offset)
  offset = offset + 4
  output = []
  if count > 0 then
    for index = 0 to count - 1
      decoded = readString(source, offset, operation)
      output = output + [decoded.value]
      offset = decoded.nextOffset
    end for
  end if
  return [output, offset]
end function

// Creates the state.
// Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createState(databaseId)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "createState", "databaseId must be 16 bytes") end if

  // Materialize every heap-backed constructor argument before the constructor
  // call. A nested bytes copy followed by several array-literal allocations can
  // otherwise make the first argument dependent on native call evaluation and
  // temporary-root lifetime.
  databaseIdCopy = bytes(databaseId)
  tables = []
  views = []
  sequences = []
  generatedColumns = []
  triggers = []
  return SchemaState(databaseIdCopy, 1, tables, views, sequences, generatedColumns, triggers)
end function

// Performs the view definition operation for this module.
// Inputs: `viewId`, `name`, `sqlText`, `columnNames`. Returns the produced value or propagates a structured error from validation or delegated operations.
function viewDefinition(viewId, name, sqlText, columnNames)
  if typeof(viewId) != "int" or viewId < 0 or typeof(name) != "string" or len(name) == 0 or typeof(sqlText) != "string" or len(sqlText) == 0 or typeof(columnNames) != "array" then return fail(INVALID_ARGUMENT, "viewDefinition", "invalid view definition") end if
  return ViewDefinition(viewId, name, sqlText, columnNames)
end function

// Performs the sequence definition operation for this module.
// Inputs: `sequenceId`, `name`, `startValue`, `incrementValue`, `minimumValue`, `maximumValue`, `lastValue`, `hasValue`, `cycle`, `ownedTableId`, `ownedColumnName`. Returns the produced value or propagates a structured error from validation or delegated operations.
function sequenceDefinition(sequenceId, name, startValue, incrementValue, minimumValue, maximumValue, lastValue, hasValue, cycle, ownedTableId, ownedColumnName)
  if typeof(sequenceId) != "int" or sequenceId < 0 or typeof(name) != "string" or len(name) == 0 then return fail(INVALID_ARGUMENT, "sequenceDefinition", "invalid sequence identity") end if
  endian.validateInt64Words(startValue, "catalog.schema_history.sequenceDefinition.startValue")
  endian.validateInt64Words(incrementValue, "catalog.schema_history.sequenceDefinition.incrementValue")
  endian.validateInt64Words(minimumValue, "catalog.schema_history.sequenceDefinition.minimumValue")
  endian.validateInt64Words(maximumValue, "catalog.schema_history.sequenceDefinition.maximumValue")
  endian.validateInt64Words(lastValue, "catalog.schema_history.sequenceDefinition.lastValue")
  if endian.int64Equals(incrementValue, endian.int64FromInt(0)) then return fail(INVALID_ARGUMENT, "sequenceDefinition", "increment must not be zero") end if
  if typeof(hasValue) != "bool" or typeof(cycle) != "bool" or typeof(ownedTableId) != "int" or ownedTableId < 0 or typeof(ownedColumnName) != "string" then return fail(INVALID_ARGUMENT, "sequenceDefinition", "invalid sequence options") end if
  return SequenceDefinition(sequenceId, name, startValue, incrementValue, minimumValue, maximumValue, lastValue, hasValue, cycle, ownedTableId, ownedColumnName)
end function

// Performs the generated column definition operation for this module.
// Inputs: `tableId`, `columnName`, `expressionSql`, `stored`. Returns the produced value or propagates a structured error from validation or delegated operations.
function generatedColumnDefinition(tableId, columnName, expressionSql, stored)
  if typeof(tableId) != "int" or tableId < 0 or typeof(columnName) != "string" or len(columnName) == 0 or typeof(expressionSql) != "string" or len(expressionSql) == 0 or typeof(stored) != "bool" then return fail(INVALID_ARGUMENT, "generatedColumnDefinition", "invalid generated column") end if
  return GeneratedColumnDefinition(tableId, columnName, expressionSql, stored)
end function

// Performs the trigger definition operation for this module.
// Inputs: `triggerId`, `name`, `tableId`, `timing`, `eventType`, `targetColumn`, `expressionSql`, `enabled`. Returns the produced value or propagates a structured error from validation or delegated operations.
function triggerDefinition(triggerId, name, tableId, timing, eventType, targetColumn, expressionSql, enabled)
  if typeof(triggerId) != "int" or triggerId < 0 or typeof(name) != "string" or len(name) == 0 or typeof(tableId) != "int" or tableId < 0 or (timing != TRIGGER_BEFORE and timing != TRIGGER_AFTER) or (eventType < TRIGGER_INSERT or eventType > TRIGGER_DELETE) or typeof(targetColumn) != "string" or typeof(expressionSql) != "string" or typeof(enabled) != "bool" then return fail(INVALID_ARGUMENT, "triggerDefinition", "invalid trigger") end if
  return TriggerDefinition(triggerId, name, tableId, timing, eventType, targetColumn, expressionSql, enabled)
end function

// Performs the column rule operation for this module.
// Inputs: `columnName`, `defaultSql`, `identity`. Returns the produced value or propagates a structured error from validation or delegated operations.
function columnRule(columnName, defaultSql, identity)
  if typeof(columnName) != "string" or len(columnName) == 0 or (defaultSql is not void and typeof(defaultSql) != "string") or typeof(identity) != "bool" then return fail(INVALID_ARGUMENT, "columnRule", "invalid column rule") end if
  return ColumnRule(columnName, defaultSql, identity)
end function

// Performs the constraint operation for this module.
// Inputs: `name`, `kind`, `columns`, `expressionSql`, `referenceTable`, `referenceColumns`, `onDelete`, `onUpdate`, `indexId`, `indexName`. Returns the produced value or propagates a structured error from validation or delegated operations.
function constraint(name, kind, columns, expressionSql, referenceTable, referenceColumns, onDelete, onUpdate, indexId, indexName)
  if name is void then name = "" end if
  if expressionSql is void then expressionSql = "" end if
  if referenceTable is void then referenceTable = "" end if
  if indexName is void then indexName = "" end if
  if typeof(name) != "string" or typeof(kind) != "int" or kind < 1 or kind > 5 or typeof(columns) != "array" or typeof(expressionSql) != "string" or typeof(referenceTable) != "string" or typeof(referenceColumns) != "array" or typeof(onDelete) != "string" or typeof(onUpdate) != "string" or typeof(indexId) != "int" or indexId < 0 or typeof(indexName) != "string" then
    return fail(INVALID_ARGUMENT, "constraint", "invalid constraint metadata")
  end if
  return ConstraintDefinition(name, kind, columns, expressionSql, referenceTable, referenceColumns, onDelete, onUpdate, indexId, indexName)
end function

// Performs the table schema operation for this module.
// Inputs: `tableId`, `schemaVersion`, `columnRules`, `constraints`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tableSchema(tableId, schemaVersion, columnRules, constraints)
  if typeof(tableId) != "int" or tableId < 0 or typeof(schemaVersion) != "int" or schemaVersion <= 0 or typeof(columnRules) != "array" or typeof(constraints) != "array" then return fail(INVALID_ARGUMENT, "tableSchema", "invalid table schema") end if
  return TableSchema(tableId, schemaVersion, columnRules, constraints)
end function

// Encodes the d rule size.
// Inputs: `rule`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodedRuleSize(rule)
  return 4 + stringSize(rule.columnName) + stringSize(rule.defaultSql)
end function

// Encodes the d constraint size.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodedConstraintSize(value)
  return 24 + stringSize(value.name) + stringArraySize(value.columns) + stringSize(value.expressionSql) + stringSize(value.referenceTable) + stringArraySize(value.referenceColumns) + stringSize(value.onDelete) + stringSize(value.onUpdate) + stringSize(value.indexName)
end function

// Encodes the d table size.
// Inputs: `table`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodedTableSize(table)
  total = 24
  for each rule in table.columnRules
    total = total + encodedRuleSize(rule)
  end for
  for each value in table.constraints
    total = total + encodedConstraintSize(value)
  end for
  return total
end function

// Encodes the requested value.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encode(state)
  if state is not SchemaState then return fail(INVALID_ARGUMENT, "encode", "state must be SchemaState") end if
  total = 32
  for each table in state.tables
    if table is not TableSchema then return fail(INVALID_ARGUMENT, "encode", "invalid table schema") end if
    total = total + encodedTableSize(table)
  end for
  payload = bytes(total, 0)
  copyExact(payload, 0, state.databaseId, 0, 16)
  endian.writeU64LE(payload, 16, endian.uint64FromInt(state.generation))
  endian.writeU32LE(payload, 24, len(state.tables))
  endian.writeU32LE(payload, 28, 0)
  offset = 32
  for each table in state.tables
    endian.writeU64LE(payload, offset, endian.uint64FromInt(table.tableId))
    endian.writeU32LE(payload, offset + 8, table.schemaVersion)
    endian.writeU32LE(payload, offset + 12, len(table.columnRules))
    endian.writeU32LE(payload, offset + 16, len(table.constraints))
    endian.writeU32LE(payload, offset + 20, 0)
    offset = offset + 24
    for each rule in table.columnRules
      flags = 0
      if rule.identity then flags = 1 end if
      endian.writeU32LE(payload, offset, flags)
      offset = offset + 4
      offset = writeString(payload, offset, rule.columnName)
      offset = writeString(payload, offset, rule.defaultSql)
    end for
    for each value in table.constraints
      endian.writeU16LE(payload, offset, value.kind)
      endian.writeU16LE(payload, offset + 2, 0)
      endian.writeU32LE(payload, offset + 4, 0)
      endian.writeU64LE(payload, offset + 8, endian.uint64FromInt(value.indexId))
      endian.writeU64LE(payload, offset + 16, endian.makeUInt64(0, 0))
      offset = offset + 24
      offset = writeString(payload, offset, value.name)
      offset = writeStringArray(payload, offset, value.columns)
      offset = writeString(payload, offset, value.expressionSql)
      offset = writeString(payload, offset, value.referenceTable)
      offset = writeStringArray(payload, offset, value.referenceColumns)
      offset = writeString(payload, offset, value.onDelete)
      offset = writeString(payload, offset, value.onUpdate)
      offset = writeString(payload, offset, value.indexName)
    end for
  end for
  if offset != len(payload) then return fail(CORRUPT_DATA, "encode", "internal schema size mismatch") end if
  return checksum.encodeEnvelope(schemaMagic(), FORMAT_VERSION, SCHEMA_KIND, 0, payload)
end function

// Decodes the native.
// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeNative(words, operation, name)
  endian.validateUInt64Words(words, "catalog.schema_history." + operation + "." + name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

// Decodes the state.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeState(encoded)
  envelope = checksum.decodeEnvelope(encoded, schemaMagic(), FORMAT_VERSION, SCHEMA_KIND)
  payload = envelope.payload
  if len(payload) < 32 then return fail(CORRUPT_DATA, "decode", "schema payload too short") end if
  if endian.readU32LE(payload, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved schema field is non-zero") end if
  state = SchemaState(slice(payload, 0, 16), decodeNative(endian.readU64LE(payload, 16), "decode", "generation"), [], [], [], [], [])
  tableCount = endian.readU32LE(payload, 24)
  offset = 32
  if tableCount > 0 then
    for tableIndex = 0 to tableCount - 1
      if offset > len(payload) - 24 then return fail(CORRUPT_DATA, "decode", "table header exceeds payload") end if
      tableId = decodeNative(endian.readU64LE(payload, offset), "decode", "tableId")
      schemaVersion = endian.readU32LE(payload, offset + 8)
      ruleCount = endian.readU32LE(payload, offset + 12)
      constraintCount = endian.readU32LE(payload, offset + 16)
      if endian.readU32LE(payload, offset + 20) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved table field is non-zero") end if
      offset = offset + 24
      rules = []
      if ruleCount > 0 then
        for ruleIndex = 0 to ruleCount - 1
          if offset > len(payload) - 4 then return fail(CORRUPT_DATA, "decode", "column rule exceeds payload") end if
          flags = endian.readU32LE(payload, offset)
          if (flags & 0xFFFFFFFE) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "unknown column rule flags") end if
          offset = offset + 4
          nameValue = readString(payload, offset, "decode")
          offset = nameValue.nextOffset
          defaultValue = readString(payload, offset, "decode")
          offset = defaultValue.nextOffset
          defaultSql = defaultValue.value
          if len(defaultSql) == 0 then defaultSql = void end if
          rules = rules + [columnRule(nameValue.value, defaultSql, (flags & 1) != 0)]
        end for
      end if
      constraints = []
      if constraintCount > 0 then
        for constraintIndex = 0 to constraintCount - 1
          if offset > len(payload) - 24 then return fail(CORRUPT_DATA, "decode", "constraint header exceeds payload") end if
          kind = endian.readU16LE(payload, offset)
          if endian.readU16LE(payload, offset + 2) != 0 or endian.readU32LE(payload, offset + 4) != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved constraint fields are non-zero") end if
          indexId = decodeNative(endian.readU64LE(payload, offset + 8), "decode", "indexId")
          reserved = endian.readU64LE(payload, offset + 16)
          if reserved.high != 0 or reserved.low != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved constraint value is non-zero") end if
          offset = offset + 24
          nameValue = readString(payload, offset, "decode"); offset = nameValue.nextOffset
          columnsValue = readStringArray(payload, offset, "decode"); columns = columnsValue[0]; offset = columnsValue[1]
          expressionValue = readString(payload, offset, "decode"); offset = expressionValue.nextOffset
          referenceValue = readString(payload, offset, "decode"); offset = referenceValue.nextOffset
          referenceColumnsValue = readStringArray(payload, offset, "decode"); referenceColumns = referenceColumnsValue[0]; offset = referenceColumnsValue[1]
          deleteValue = readString(payload, offset, "decode"); offset = deleteValue.nextOffset
          updateValue = readString(payload, offset, "decode"); offset = updateValue.nextOffset
          indexNameValue = readString(payload, offset, "decode"); offset = indexNameValue.nextOffset
          constraints = constraints + [constraint(nameValue.value, kind, columns, expressionValue.value, referenceValue.value, referenceColumns, deleteValue.value, updateValue.value, indexId, indexNameValue.value)]
        end for
      end if
      state.tables = state.tables + [tableSchema(tableId, schemaVersion, rules, constraints)]
    end for
  end if
  if offset != len(payload) then return fail(CORRUPT_DATA, "decode", "trailing schema bytes") end if
  return state
end function

// Keep the qualified public API schema_history.decode(...), while all internal
// calls use an unambiguous helper. MiniLang also has a builtin decode(bytes).
// Decodes the requested value.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decode(encoded)
  return decodeState(encoded)
end function

// Persists the requested value.
// Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function save(databasePath, state)
  writeAtomic(schemaPath(databasePath), encode(state))
  saveExtensions(databasePath, state)
  return true
end function

// Loads the or create.
// Inputs: `databasePath`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function loadOrCreate(databasePath, databaseId)
  path = schemaPath(databasePath)
  if not file_api.fileExists(path) then
    state = createState(databaseId)
    save(databasePath, state)
    return state
  end if
  state = decodeState(readWhole(path))
  if not bytesEqual(state.databaseId, databaseId) then return fail(CORRUPT_DATA, "loadOrCreate", "schema belongs to another database") end if
  loadExtensionsInto(databasePath, state)
  return state
end function

// Finds the table schema.
// Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findTableSchema(state, tableId)
  if state is not SchemaState then return fail(INVALID_ARGUMENT, "findTableSchema", "state must be SchemaState") end if
  for each table in state.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

// Finds the constraint.
// Inputs: `tableSchemaValue`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findConstraint(tableSchemaValue, name)
  if tableSchemaValue is not TableSchema then return fail(INVALID_ARGUMENT, "findConstraint", "tableSchema must be TableSchema") end if
  for each value in tableSchemaValue.constraints
    if value.name == name then return value end if
  end for
  return void
end function

// Clones the metadata.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cloneMetadata(value)
  return metadata.decodeDatabase(metadata.encodeDatabase(value))
end function

// Clones the catalog.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cloneCatalog(value)
  return metadata.decodeCatalog(metadata.encodeCatalog(value))
end function

// Clones the state.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cloneState(value)
  cloned = decodeState(encode(value))
  extension = decodeExtensions(encodeExtensions(value), value.databaseId)
  cloned.views = extension.views
  cloned.sequences = extension.sequences
  cloned.generatedColumns = extension.generatedColumns
  cloned.triggers = extension.triggers
  return cloned
end function

// Removes the at.
// Inputs: `values`, `index`. Returns the produced value or propagates a structured error from validation or delegated operations.
function removeAt(values, index)
  output = []
  if len(values) > 1 then
    for i = 0 to len(values) - 1
      if i != index then output = output + [values[i]] end if
    end for
  end if
  return output
end function

// Performs the table index by name operation for this module.
// Inputs: `catalogState`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tableIndexByName(catalogState, name)
  if len(catalogState.tables) > 0 then
    for index = 0 to len(catalogState.tables) - 1
      if catalogState.tables[index].name == name then return index end if
    end for
  end if
  return -1
end function

// Performs the table schema index operation for this module.
// Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tableSchemaIndex(state, tableId)
  if len(state.tables) > 0 then
    for index = 0 to len(state.tables) - 1
      if state.tables[index].tableId == tableId then return index end if
    end for
  end if
  return -1
end function

// Allocates the id.
// Inputs: `preparedMetadata`. Returns the produced value or propagates a structured error from validation or delegated operations.
function allocateId(preparedMetadata)
  value = preparedMetadata.nextObjectId
  if value >= endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "allocateId", "object ID space exhausted") end if
  preparedMetadata.nextObjectId = value + 1
  return value
end function

// Performs the generated constraint name operation for this module.
// Inputs: `prefix`, `tableName`, `suffix`. Returns the produced value or propagates a structured error from validation or delegated operations.
function generatedConstraintName(prefix, tableName, suffix)
  return prefix + "_" + tableName + "_" + suffix
end function

// Performs the column exists operation for this module.
// Inputs: `table`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function columnExists(table, name)
  for each column in table.columns
    if column.name == name then return true end if
  end for
  return false
end function

// Performs the unique constraint for columns operation for this module.
// Inputs: `tableSchemaValue`, `columns`. Returns the produced value or propagates a structured error from validation or delegated operations.
function uniqueConstraintForColumns(tableSchemaValue, columns)
  if tableSchemaValue is void then return false end if
  for each value in tableSchemaValue.constraints
    // A partial unique index does not prove uniqueness for rows outside its
    // predicate and therefore cannot back a foreign-key target.
    if (value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE) and len(value.expressionSql) == 0 then
      if len(value.columns) == len(columns) then
        same = true
        if len(columns) > 0 then
          for index = 0 to len(columns) - 1
            if value.columns[index] != columns[index] then same = false end if
          end for
        end if
        if same then return true end if
      end if
    end if
  end for
  return false
end function

// Appends the constraint.
// Inputs: `preparedMetadata`, `tableName`, `tableSchemaValue`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendConstraint(preparedMetadata, tableName, tableSchemaValue, value)
  if value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE or value.kind == CONSTRAINT_INDEX then
    value.indexId = allocateId(preparedMetadata)
    if len(value.indexName) == 0 then value.indexName = generatedConstraintName("idx", tableName, "" + value.indexId) end if
  end if
  tableSchemaValue.constraints = tableSchemaValue.constraints + [value]
  return value
end function

// Performs the catalog table by id operation for this module.
// Inputs: `catalogState`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function catalogTableById(catalogState, tableId)
  for each table in catalogState.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

// Performs the column index by name operation for this module.
// Inputs: `table`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function columnIndexByName(table, name)
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      if table.columns[index].name == name then return index end if
    end for
  end if
  return -1
end function

// Performs the string array replace operation for this module.
// Inputs: `values`, `oldValue`, `newValue`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stringArrayReplace(values, oldValue, newValue)
  output = []
  for each value in values
    if value == oldValue then output = output + [newValue] else output = output + [value] end if
  end for
  return output
end function

// Returns a binary catalog marker that cannot collide with a SQL identifier
// accepted from normal text input. Keeping the marker out of the schema format
// itself preserves v1 compatibility for older column-only index histories.
function indexExpressionPrefix()
  return decode(bytes([0, 77, 83, 73, 88, 1]))
end function

// Encodes a canonical expression in the backwards-compatible index key array.
function indexExpressionKey(sqlText)
  if typeof(sqlText) != "string" or len(sqlText) == 0 then return fail(INVALID_ARGUMENT, "indexExpressionKey", "expression SQL must be non-empty") end if
  return indexExpressionPrefix() + sqlText
end function

// Reports whether one persisted index key is a canonical expression marker.
function isIndexExpressionKey(value)
  prefix = indexExpressionPrefix()
  if typeof(value) != "string" or len(value) < len(prefix) then return false end if
  return slice(bytes(value), 0, len(prefix)) == bytes(prefix)
end function

// Returns canonical SQL from an expression key or an empty string otherwise.
function indexExpressionSql(value)
  if not isIndexExpressionKey(value) then return "" end if
  prefixLength = len(indexExpressionPrefix())
  return decode(slice(bytes(value), prefixLength, len(bytes(value)) - prefixLength))
end function

// Returns the user-facing key text without the internal compatibility marker.
function indexKeyDisplay(value)
  if isIndexExpressionKey(value) then return indexExpressionSql(value) end if
  return value
end function

// Performs the rename expression operation for this module.
// Inputs: `expression`, `oldName`, `newName`. Returns the produced value or propagates a structured error from validation or delegated operations.
function renameExpression(expression, oldName, newName)
  if ast.isColumnExpression(expression) then
    if expression.qualifier is void and expression.name == oldName then return ast.columnExpression(void, newName) end if
    return expression
  end if
  if ast.isLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, renameExpression(expression.operand, oldName, newName)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, renameExpression(expression.left, oldName, newName), renameExpression(expression.right, oldName, newName)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(renameExpression(expression.operand, oldName, newName), expression.negated) end if
  if ast.isCastExpression(expression) then return ast.castExpression(renameExpression(expression.operand, oldName, newName), expression.targetType) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [renameExpression(argument, oldName, newName)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  return expression
end function

// Performs the rename expression sql operation for this module.
// Inputs: `sqlText`, `oldName`, `newName`. Returns the produced value or propagates a structured error from validation or delegated operations.
function renameExpressionSql(sqlText, oldName, newName)
  if typeof(sqlText) != "string" or len(sqlText) == 0 then return sqlText end if
  return ast.formatExpression(renameExpression(parser.parseExpressionText(sqlText), oldName, newName))
end function

// Reports whether a persisted row expression refers to one unqualified column.
function expressionReferencesColumn(expression, columnName)
  if ast.isColumnExpression(expression) then return expression.qualifier is void and expression.name == columnName end if
  if ast.isLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return false end if
  if ast.isUnaryExpression(expression) or ast.isIsNullExpression(expression) then return expressionReferencesColumn(expression.operand, columnName) end if
  if ast.isBinaryExpression(expression) then return expressionReferencesColumn(expression.left, columnName) or expressionReferencesColumn(expression.right, columnName) end if
  if ast.isCastExpression(expression) then return expressionReferencesColumn(expression.operand, columnName) end if
  if ast.isFunctionExpression(expression) then
    for each argument in expression.arguments
      if expressionReferencesColumn(argument, columnName) then return true end if
    end for
  end if
  return false
end function

// Parses canonical SQL before checking a partial-index column dependency.
function expressionSqlReferencesColumn(sqlText, columnName)
  if typeof(sqlText) != "string" or len(sqlText) == 0 then return false end if
  return expressionReferencesColumn(parser.parseExpressionText(sqlText), columnName)
end function

// Compares the string array.
// Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function sameStringArray(left, right)
  if typeof(left) != "array" or typeof(right) != "array" or len(left) != len(right) then return false end if
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      if left[index] != right[index] then return false end if
    end for
  end if
  return true
end function

// Returns whether the supplied string array contains an exact identifier.
function stringArrayContains(values, name)
  for each value in values
    if value == name then return true end if
  end for
  return false
end function

// Performs the constraint name exists operation for this module.
// Inputs: `tableSchemaValue`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function constraintNameExists(tableSchemaValue, name)
  for each value in tableSchemaValue.constraints
    if value.name == name or (len(value.indexName) > 0 and value.indexName == name) then return true end if
  end for
  return false
end function

// Ensures the prepared table schema.
// Inputs: `prepared`, `table`. Returns success after all invariants hold; violations are reported as structured errors.
function ensurePreparedTableSchema(prepared, table)
  schemaIndex = tableSchemaIndex(prepared.newState, table.tableId)
  if schemaIndex < 0 then
    rules = []
    for each column in table.columns
      rules = rules + [columnRule(column.name, void, false)]
    end for
    prepared.newState.tables = prepared.newState.tables + [tableSchema(table.tableId, table.schemaVersion, rules, [])]
    schemaIndex = len(prepared.newState.tables) - 1
  end if
  return prepared.newState.tables[schemaIndex]
end function

// Performs the constraint from ast operation for this module.
// Inputs: `prepared`, `table`, `tableSchemaValue`, `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
function constraintFromAst(prepared, table, tableSchemaValue, source)
  name = source.name
  if name is void or len(name) == 0 then name = generatedConstraintName("constraint", table.name, "" + (len(tableSchemaValue.constraints) + 1)) end if
  if constraintNameExists(tableSchemaValue, name) then return fail(OBJECT_EXISTS, "constraintFromAst", "constraint already exists: " + name) end if
  expressionSql = ""
  if source.expression is not void then expressionSql = ast.formatExpression(source.expression) end if
  value = constraint(name, source.kind, source.columns, expressionSql, source.referencesTable, source.referencesColumns, source.onDelete, source.onUpdate, 0, "")
  if source.kind == CONSTRAINT_PRIMARY_KEY or source.kind == CONSTRAINT_UNIQUE then appendConstraint(prepared.newMetadata, table.name, tableSchemaValue, value) else tableSchemaValue.constraints = tableSchemaValue.constraints + [value] end if
  return value
end function

/// Advances the schema generation shared by catalog metadata and schema rules.
/// @param table Mutable catalog table whose schema version advances.
/// @param tableSchemaValue Mutable persisted schema rules for the same table.
function advanceSchemaVersion(table, tableSchemaValue)
  table.schemaVersion = table.schemaVersion + 1
  tableSchemaValue.schemaVersion = table.schemaVersion
  return true
end function

/// Applies ALTER TABLE ADD COLUMN without mixing its invariants with other DDL actions.
/// @param prepared Transactional schema-change state being updated.
/// @param table Mutable catalog table receiving the new column.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed ALTER TABLE statement.
/// @param bound Bound type and expression information for the statement.
function applyAlterAddColumn(prepared, table, tableSchemaValue, statement, bound)
  definition = statement.columnDefinition
  if columnIndexByName(table, definition.name) >= 0 then return fail(OBJECT_EXISTS, "buildAlterTable", "column already exists: " + definition.name) end if
  typeInfo = bound.columnType
  columnId = allocateId(prepared.newMetadata)
  table.columns = table.columns + [metadata.createColumn(columnId, definition.name, typeInfo.kind, typeInfo.nullable, typeInfo.length, typeInfo.precision, typeInfo.scale)]
  advanceSchemaVersion(table, tableSchemaValue)
  defaultSql = void
  if definition.defaultExpression is not void then defaultSql = ast.formatExpression(definition.defaultExpression) end if
  tableSchemaValue.columnRules = tableSchemaValue.columnRules + [columnRule(definition.name, defaultSql, false)]
  if definition.generatedExpression is not void then
    prepared.newState.generatedColumns = prepared.newState.generatedColumns + [generatedColumnDefinition(table.tableId, definition.name, ast.formatExpression(definition.generatedExpression), definition.generatedStored)]
  end if
  return true
end function

/// Rewrites every catalog dependency affected by an ALTER TABLE RENAME COLUMN.
/// @param prepared Transactional schema-change state being updated.
/// @param table Mutable catalog table containing the renamed column.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed rename-column action and names.
function applyAlterRenameColumn(prepared, table, tableSchemaValue, statement)
  columnIndex = columnIndexByName(table, statement.oldName)
  if columnIndex < 0 then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "column not found: " + statement.oldName) end if
  if columnIndexByName(table, statement.newName) >= 0 then return fail(OBJECT_EXISTS, "buildAlterTable", "column already exists: " + statement.newName) end if
  table.columns[columnIndex].name = statement.newName
  for each rule in tableSchemaValue.columnRules
    if rule.columnName == statement.oldName then rule.columnName = statement.newName end if
  end for
  for each schemaValue in prepared.newState.tables
    for each value in schemaValue.constraints
      if schemaValue.tableId == table.tableId then
        renamedKeys = []
        for each keyValue in value.columns
          if value.indexId > 0 and isIndexExpressionKey(keyValue) then
            renamedKeys = renamedKeys + [indexExpressionKey(renameExpressionSql(indexExpressionSql(keyValue), statement.oldName, statement.newName))]
          else if keyValue == statement.oldName then
            renamedKeys = renamedKeys + [statement.newName]
          else
            renamedKeys = renamedKeys + [keyValue]
          end if
        end for
        value.columns = renamedKeys
        if value.indexId > 0 then value.referenceColumns = stringArrayReplace(value.referenceColumns, statement.oldName, statement.newName) end if
        if value.indexId > 0 and len(value.expressionSql) > 0 then value.expressionSql = renameExpressionSql(value.expressionSql, statement.oldName, statement.newName) end if
        if value.kind == CONSTRAINT_CHECK then value.expressionSql = renameExpressionSql(value.expressionSql, statement.oldName, statement.newName) end if
      end if
      if value.referenceTable == table.name then value.referenceColumns = stringArrayReplace(value.referenceColumns, statement.oldName, statement.newName) end if
    end for
  end for
  for each generated in prepared.newState.generatedColumns
    if generated.tableId == table.tableId then
      if generated.columnName == statement.oldName then generated.columnName = statement.newName end if
      generated.expressionSql = renameExpressionSql(generated.expressionSql, statement.oldName, statement.newName)
    end if
  end for
  for each trigger in prepared.newState.triggers
    if trigger.tableId == table.tableId and trigger.targetColumn == statement.oldName then trigger.targetColumn = statement.newName end if
  end for
  return true
end function

/// Applies a table rename and updates incoming foreign-key references.
/// @param prepared Transactional schema-change state being updated.
/// @param table Mutable catalog table being renamed.
/// @param statement Parsed rename-table action and destination name.
function applyAlterRenameTable(prepared, table, statement)
  if tableIndexByName(prepared.newCatalog, statement.newName) >= 0 then return fail(OBJECT_EXISTS, "buildAlterTable", "table already exists: " + statement.newName) end if
  oldName = table.name
  table.name = statement.newName
  for each schemaValue in prepared.newState.tables
    for each value in schemaValue.constraints
      if value.referenceTable == oldName then value.referenceTable = statement.newName end if
    end for
  end for
  return true
end function

/// Validates the relational side of a new foreign-key constraint.
/// @param prepared Transactional schema-change state used for catalog lookup.
/// @param table Source table that owns the foreign key.
/// @param source Parsed foreign-key constraint definition.
function validateAlterForeignKey(prepared, table, source)
  referenceIndex = tableIndexByName(prepared.newCatalog, source.referencesTable)
  if referenceIndex < 0 then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "referenced table does not exist: " + source.referencesTable) end if
  referenceTable = prepared.newCatalog.tables[referenceIndex]
  referenceSchema = findTableSchema(prepared.newState, referenceTable.tableId)
  if len(source.columns) == 0 or len(source.columns) != len(source.referencesColumns) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "foreign-key column count mismatch") end if
  if not uniqueConstraintForColumns(referenceSchema, source.referencesColumns) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "foreign key target must be PRIMARY KEY or UNIQUE") end if
  for pairIndex = 0 to len(source.columns) - 1
    localIndex = columnIndexByName(table, source.columns[pairIndex])
    remoteIndex = columnIndexByName(referenceTable, source.referencesColumns[pairIndex])
    if localIndex < 0 or remoteIndex < 0 then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "foreign-key column is missing") end if
    if table.columns[localIndex].typeCode != referenceTable.columns[remoteIndex].typeCode then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "foreign-key column types differ") end if
  end for
  return true
end function

/// Adds one table constraint and schedules any physical index it owns.
/// @param prepared Transactional schema-change state being updated.
/// @param databasePath Database directory used for new backing files.
/// @param table Mutable catalog table receiving the constraint.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed ADD CONSTRAINT action.
function applyAlterAddConstraint(prepared, databasePath, table, tableSchemaValue, statement)
  source = statement.constraint
  if source.kind == CONSTRAINT_FOREIGN_KEY then validateAlterForeignKey(prepared, table, source) end if
  if source.kind == CONSTRAINT_PRIMARY_KEY then
    for each existing in tableSchemaValue.constraints
      if existing.kind == CONSTRAINT_PRIMARY_KEY then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "table already has a PRIMARY KEY") end if
    end for
  end if
  value = constraintFromAst(prepared, table, tableSchemaValue, source)
  if value.kind == CONSTRAINT_PRIMARY_KEY then
    for each columnName in value.columns
      index = columnIndexByName(table, columnName)
      if index >= 0 then table.columns[index].nullable = false end if
    end for
  end if
  if value.indexId > 0 then
    finalPath = indexFilePath(databasePath, value.indexId)
    prepared.createFiles = prepared.createFiles + [CreateFilePlan(finalPath + ".ddl.new", finalPath, superblock.FILE_TYPE_INDEX, value.indexId, value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE)]
  end if
  return true
end function

/// Removes a constraint only after proving that no foreign key depends on it.
/// @param prepared Transactional schema-change state being updated.
/// @param databasePath Database directory containing backing files.
/// @param table Mutable catalog table losing the constraint.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed DROP CONSTRAINT action.
function applyAlterDropConstraint(prepared, databasePath, table, tableSchemaValue, statement)
  found = -1
  if len(tableSchemaValue.constraints) > 0 then
    for index = 0 to len(tableSchemaValue.constraints) - 1
      value = tableSchemaValue.constraints[index]
      if value.name == statement.constraintName or value.indexName == statement.constraintName then found = index end if
    end for
  end if
  if found < 0 then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "constraint not found: " + statement.constraintName) end if
  removed = tableSchemaValue.constraints[found]
  if removed.kind == CONSTRAINT_PRIMARY_KEY or removed.kind == CONSTRAINT_UNIQUE then
    for each schemaValue in prepared.newState.tables
      for each dependent in schemaValue.constraints
        if dependent.kind == CONSTRAINT_FOREIGN_KEY and dependent.referenceTable == table.name and sameStringArray(dependent.referenceColumns, removed.columns) then
          return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "constraint is referenced by foreign key " + dependent.name)
        end if
      end for
    end for
  end if
  tableSchemaValue.constraints = removeAt(tableSchemaValue.constraints, found)
  if removed.indexId > 0 then
    original = indexFilePath(databasePath, removed.indexId)
    prepared.backups = prepared.backups + [BackupPlan(original, original + ".ddl.old")]
  end if
  return true
end function

/// Rejects a column drop while any schema object still depends on that column.
/// @param prepared Transactional schema-change state used for dependency lookup.
/// @param table Table from which the column would be removed.
/// @param columnName Exact column name being checked.
function validateAlterDropColumnDependencies(prepared, table, columnName)
  for each schemaValue in prepared.newState.tables
    for each value in schemaValue.constraints
      if schemaValue.tableId == table.tableId then
        if value.kind == CONSTRAINT_CHECK then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "drop CHECK constraints before dropping a column") end if
        if stringArrayContains(value.columns, columnName) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "column is used by constraint " + value.name) end if
        if value.indexId > 0 then
          for each keyValue in value.columns
            if isIndexExpressionKey(keyValue) and expressionSqlReferencesColumn(indexExpressionSql(keyValue), columnName) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "column is referenced by expression index " + value.indexName) end if
          end for
        end if
        if value.indexId > 0 and stringArrayContains(value.referenceColumns, columnName) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "column is included by index " + value.indexName) end if
        if value.indexId > 0 and expressionSqlReferencesColumn(value.expressionSql, columnName) then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "column is referenced by partial index " + value.indexName) end if
      end if
      if value.kind == CONSTRAINT_FOREIGN_KEY and value.referenceTable == table.name and stringArrayContains(value.referenceColumns, columnName) then
        return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "column is referenced by foreign key " + value.name)
      end if
    end for
  end for
  return true
end function

/// Applies a metadata-only column drop after dependency and ownership validation.
/// @param prepared Transactional schema-change state being updated.
/// @param table Mutable catalog table losing the column.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed DROP COLUMN action.
function applyAlterDropColumn(prepared, table, tableSchemaValue, statement)
  columnIndex = columnIndexByName(table, statement.oldName)
  if columnIndex < 0 then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "column not found: " + statement.oldName) end if
  if len(table.columns) <= 1 then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "a table must retain at least one column") end if
  // The executor separately requires an empty heap, so no stored row needs a
  // physical rewrite under the shorter schema.
  validateAlterDropColumnDependencies(prepared, table, statement.oldName)
  generatedIndex = -1
  if len(prepared.newState.generatedColumns) > 0 then
    for index = 0 to len(prepared.newState.generatedColumns) - 1
      generated = prepared.newState.generatedColumns[index]
      if generated.tableId == table.tableId then
        if generated.columnName == statement.oldName then generatedIndex = index else return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "drop generated columns before dropping a source column") end if
      end if
    end for
  end if
  for each trigger in prepared.newState.triggers
    if trigger.tableId == table.tableId then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "drop table triggers before dropping a column") end if
  end for
  ruleIndex = -1
  if len(tableSchemaValue.columnRules) > 0 then
    for index = 0 to len(tableSchemaValue.columnRules) - 1
      if tableSchemaValue.columnRules[index].columnName == statement.oldName then
        if tableSchemaValue.columnRules[index].identity then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "identity column cannot be dropped while its sequence is owned") end if
        ruleIndex = index
      end if
    end for
  end if
  table.columns = removeAt(table.columns, columnIndex)
  if ruleIndex >= 0 then tableSchemaValue.columnRules = removeAt(tableSchemaValue.columnRules, ruleIndex) end if
  if generatedIndex >= 0 then prepared.newState.generatedColumns = removeAt(prepared.newState.generatedColumns, generatedIndex) end if
  return advanceSchemaVersion(table, tableSchemaValue)
end function

/// Applies SET/DROP DEFAULT while preserving identity-column ownership.
/// @param table Catalog table used to validate the target column.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed default-changing action.
function applyAlterDefault(table, tableSchemaValue, statement)
  columnIndex = columnIndexByName(table, statement.oldName)
  if columnIndex < 0 then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "column not found: " + statement.oldName) end if
  ruleIndex = -1
  if len(tableSchemaValue.columnRules) > 0 then
    for index = 0 to len(tableSchemaValue.columnRules) - 1
      if tableSchemaValue.columnRules[index].columnName == statement.oldName then ruleIndex = index end if
    end for
  end if
  if ruleIndex < 0 then
    tableSchemaValue.columnRules = tableSchemaValue.columnRules + [columnRule(statement.oldName, void, false)]
    ruleIndex = len(tableSchemaValue.columnRules) - 1
  end if
  if tableSchemaValue.columnRules[ruleIndex].identity then return fail(CONSTRAINT_VIOLATION, "buildAlterTable", "identity column default is sequence-owned") end if
  if statement.action == ast.ALTER_TABLE_SET_DEFAULT then tableSchemaValue.columnRules[ruleIndex].defaultSql = ast.formatExpression(statement.columnDefinition) else tableSchemaValue.columnRules[ruleIndex].defaultSql = void end if
  return advanceSchemaVersion(table, tableSchemaValue)
end function

/// Applies SET/DROP NOT NULL to one existing column.
/// @param table Mutable catalog table containing the target column.
/// @param tableSchemaValue Mutable schema rules associated with the table.
/// @param statement Parsed nullability-changing action.
function applyAlterNullability(table, tableSchemaValue, statement)
  columnIndex = columnIndexByName(table, statement.oldName)
  if columnIndex < 0 then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "column not found: " + statement.oldName) end if
  table.columns[columnIndex].nullable = statement.action == ast.ALTER_TABLE_DROP_NOT_NULL
  return advanceSchemaVersion(table, tableSchemaValue)
end function

/// Dispatches ALTER TABLE to one action-specific handler.
/// @param prepared Transactional schema-change state being updated.
/// @param databasePath Database directory used for physical schema changes.
/// @param bound Bound ALTER TABLE statement and resolved table metadata.
function buildAlterTable(prepared, databasePath, bound)
  statement = bound.statement
  table = catalogTableById(prepared.newCatalog, bound.table.tableId)
  if table is void then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "table no longer exists") end if
  tableSchemaValue = ensurePreparedTableSchema(prepared, table)
  if statement.action == ast.ALTER_TABLE_ADD_COLUMN then return applyAlterAddColumn(prepared, table, tableSchemaValue, statement, bound) end if
  if statement.action == ast.ALTER_TABLE_RENAME_COLUMN then return applyAlterRenameColumn(prepared, table, tableSchemaValue, statement) end if
  if statement.action == ast.ALTER_TABLE_RENAME_TABLE then return applyAlterRenameTable(prepared, table, statement) end if
  if statement.action == ast.ALTER_TABLE_ADD_CONSTRAINT then return applyAlterAddConstraint(prepared, databasePath, table, tableSchemaValue, statement) end if
  if statement.action == ast.ALTER_TABLE_DROP_CONSTRAINT then return applyAlterDropConstraint(prepared, databasePath, table, tableSchemaValue, statement) end if
  if statement.action == ast.ALTER_TABLE_DROP_COLUMN then return applyAlterDropColumn(prepared, table, tableSchemaValue, statement) end if
  if statement.action == ast.ALTER_TABLE_SET_DEFAULT or statement.action == ast.ALTER_TABLE_DROP_DEFAULT then return applyAlterDefault(table, tableSchemaValue, statement) end if
  if statement.action == ast.ALTER_TABLE_SET_NOT_NULL or statement.action == ast.ALTER_TABLE_DROP_NOT_NULL then return applyAlterNullability(table, tableSchemaValue, statement) end if
  return fail(UNSUPPORTED_SQL, "buildAlterTable", "unsupported ALTER TABLE action")
end function

// Builds the create table.
// Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function buildCreateTable(prepared, databasePath, bound)
  statement = bound.statement
  if tableIndexByName(prepared.newCatalog, statement.name) >= 0 then
    if statement.ifNotExists then return true end if
    return fail(OBJECT_EXISTS, "buildCreateTable", "table already exists: " + statement.name)
  end if
  tableId = allocateId(prepared.newMetadata)
  columns = []
  rules = []
  if len(statement.columns) > 0 then
    for index = 0 to len(statement.columns) - 1
      definition = statement.columns[index]
      typeInfo = bound.columnTypes[index]
      columnId = allocateId(prepared.newMetadata)
      columns = columns + [metadata.createColumn(columnId, definition.name, typeInfo.kind, typeInfo.nullable, typeInfo.length, typeInfo.precision, typeInfo.scale)]
      defaultSql = void
      if definition.defaultExpression is not void then defaultSql = ast.formatExpression(definition.defaultExpression) end if
      rules = rules + [columnRule(definition.name, defaultSql, definition.identity)]
    end for
  end if
  table = metadata.createTable(tableId, statement.name, 1, columns)
  schema = tableSchema(tableId, 1, rules, [])
  if len(statement.columns) > 0 then
    for each definition in statement.columns
      if definition.generatedExpression is not void then
        prepared.newState.generatedColumns = prepared.newState.generatedColumns + [generatedColumnDefinition(tableId, definition.name, ast.formatExpression(definition.generatedExpression), definition.generatedStored)]
      end if
    end for
  end if
  primaryCount = 0
  for each definition in statement.columns
    if definition.primaryKey then
      primaryCount = primaryCount + 1
      appendConstraint(prepared.newMetadata, statement.name, schema, constraint(generatedConstraintName("pk", statement.name, definition.name), CONSTRAINT_PRIMARY_KEY, [definition.name], "", "", [], "NO ACTION", "NO ACTION", 0, ""))
    else if definition.unique then
      appendConstraint(prepared.newMetadata, statement.name, schema, constraint(generatedConstraintName("uq", statement.name, definition.name), CONSTRAINT_UNIQUE, [definition.name], "", "", [], "NO ACTION", "NO ACTION", 0, ""))
    end if
    if definition.checkExpression is not void then
      schema.constraints = schema.constraints + [constraint(generatedConstraintName("ck", statement.name, definition.name), CONSTRAINT_CHECK, [], ast.formatExpression(definition.checkExpression), "", [], "NO ACTION", "NO ACTION", 0, "")]
    end if
    if definition.referencesTable is not void then
      schema.constraints = schema.constraints + [constraint(generatedConstraintName("fk", statement.name, definition.name), CONSTRAINT_FOREIGN_KEY, [definition.name], "", definition.referencesTable, definition.referencesColumns, definition.onDelete, definition.onUpdate, 0, "")]
    end if
  end for
  for each source in statement.constraints
    name = source.name
    if name is void then name = generatedConstraintName("constraint", statement.name, "" + (len(schema.constraints) + 1)) end if
    expressionSql = ""
    if source.expression is not void then expressionSql = ast.formatExpression(source.expression) end if
    value = constraint(name, source.kind, source.columns, expressionSql, source.referencesTable, source.referencesColumns, source.onDelete, source.onUpdate, 0, "")
    if source.kind == CONSTRAINT_PRIMARY_KEY then primaryCount = primaryCount + 1 end if
    if source.kind == CONSTRAINT_PRIMARY_KEY or source.kind == CONSTRAINT_UNIQUE then
      appendConstraint(prepared.newMetadata, statement.name, schema, value)
    else
      schema.constraints = schema.constraints + [value]
    end if
  end for
  if primaryCount > 1 then return fail(CONSTRAINT_VIOLATION, "buildCreateTable", "table may have only one PRIMARY KEY") end if
  for each value in schema.constraints
    for each columnName in value.columns
      if not columnExists(table, columnName) then return fail(BINDING_ERROR, "buildCreateTable", "constraint references unknown column " + columnName) end if
    end for
    if value.kind == CONSTRAINT_PRIMARY_KEY then
      for each columnName in value.columns
        for each column in table.columns
          if column.name == columnName then column.nullable = false end if
        end for
      end for
    end if
    if value.kind == CONSTRAINT_FOREIGN_KEY then
      reference = void
      referenceSchema = void
      // A table may legally reference its own PRIMARY KEY/UNIQUE key. The new
      // table is not added to the prepared catalog until validation completes,
      // so resolve that case against the in-progress table and schema.
      if value.referenceTable == statement.name then
        reference = table
        referenceSchema = schema
      else
        referenceIndex = tableIndexByName(prepared.newCatalog, value.referenceTable)
        if referenceIndex < 0 then return fail(CONSTRAINT_VIOLATION, "buildCreateTable", "referenced table does not exist: " + value.referenceTable) end if
        reference = prepared.newCatalog.tables[referenceIndex]
        referenceSchema = findTableSchema(prepared.newState, reference.tableId)
      end if
      if len(value.columns) != len(value.referenceColumns) or len(value.columns) == 0 then return fail(CONSTRAINT_VIOLATION, "buildCreateTable", "foreign-key column count mismatch") end if
      for each referenceColumn in value.referenceColumns
        if not columnExists(reference, referenceColumn) then return fail(CONSTRAINT_VIOLATION, "buildCreateTable", "referenced column does not exist: " + referenceColumn) end if
      end for
      if not uniqueConstraintForColumns(referenceSchema, value.referenceColumns) then return fail(CONSTRAINT_VIOLATION, "buildCreateTable", "foreign key target must be PRIMARY KEY or UNIQUE") end if
    end if
  end for
  prepared.newCatalog.tables = prepared.newCatalog.tables + [table]
  prepared.newState.tables = prepared.newState.tables + [schema]
  tableFinal = catalog.tableFilePath(databasePath, tableId)
  tableTemporary = tableFinal + ".ddl.new"
  prepared.createFiles = prepared.createFiles + [CreateFilePlan(tableTemporary, tableFinal, superblock.FILE_TYPE_TABLE, tableId, false)]
  for each value in schema.constraints
    if value.indexId > 0 then
      indexFinal = indexFilePath(databasePath, value.indexId)
      uniqueIndex = value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE
      prepared.createFiles = prepared.createFiles + [CreateFilePlan(indexFinal + ".ddl.new", indexFinal, superblock.FILE_TYPE_INDEX, value.indexId, uniqueIndex)]
    end if
  end for
  return true
end function

// Builds the create index.
// Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function buildCreateIndex(prepared, databasePath, bound)
  if bound.table is void then return fail(OBJECT_NOT_FOUND, "buildCreateIndex", "table does not exist") end if
  tableIndex = tableIndexByName(prepared.newCatalog, bound.table.name)
  if tableIndex < 0 then return fail(OBJECT_NOT_FOUND, "buildCreateIndex", "table does not exist") end if
  schemaIndex = tableSchemaIndex(prepared.newState, bound.table.tableId)
  if schemaIndex < 0 then
    prepared.newState.tables = prepared.newState.tables + [tableSchema(bound.table.tableId, bound.table.schemaVersion, [], [])]
    schemaIndex = len(prepared.newState.tables) - 1
  end if
  schema = prepared.newState.tables[schemaIndex]
  for each existing in schema.constraints
    if existing.indexName == bound.statement.name or existing.name == bound.statement.name then
      if bound.statement.ifNotExists then return true end if
      return fail(OBJECT_EXISTS, "buildCreateIndex", "index already exists")
    end if
  end for
  kind = CONSTRAINT_INDEX
  if bound.statement.unique then kind = CONSTRAINT_UNIQUE end if
  predicateSql = ""
  if bound.statement.whereExpression is not void then predicateSql = ast.formatExpression(bound.statement.whereExpression) end if
  keyValues = []
  for each keyExpression in bound.statement.columns
    if ast.isColumnExpression(keyExpression) and keyExpression.qualifier is void then keyValues = keyValues + [keyExpression.name] else keyValues = keyValues + [indexExpressionKey(ast.formatExpression(keyExpression))] end if
  end for
  value = constraint(bound.statement.name, kind, keyValues, predicateSql, "", bound.statement.includeColumns, "NO ACTION", "NO ACTION", allocateId(prepared.newMetadata), bound.statement.name)
  schema.constraints = schema.constraints + [value]
  indexFinal = indexFilePath(databasePath, value.indexId)
  prepared.createFiles = prepared.createFiles + [CreateFilePlan(indexFinal + ".ddl.new", indexFinal, superblock.FILE_TYPE_INDEX, value.indexId, bound.statement.unique)]
  return true
end function

// Builds the drop table.
// Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function buildDropTable(prepared, databasePath, bound)
  if bound.table is void then return true end if
  tableIndex = tableIndexByName(prepared.newCatalog, bound.table.name)
  if tableIndex < 0 then return true end if
  schemaIndex = tableSchemaIndex(prepared.newState, bound.table.tableId)
  if schemaIndex >= 0 then
    schema = prepared.newState.tables[schemaIndex]
    for each value in schema.constraints
      if value.indexId > 0 then
        original = indexFilePath(databasePath, value.indexId)
        prepared.backups = prepared.backups + [BackupPlan(original, original + ".ddl.old")]
      end if
    end for
    prepared.newState.tables = removeAt(prepared.newState.tables, schemaIndex)
  end if
  remainingGenerated = []
  for each generated in prepared.newState.generatedColumns
    if generated.tableId != bound.table.tableId then remainingGenerated = remainingGenerated + [generated] end if
  end for
  prepared.newState.generatedColumns = remainingGenerated
  remainingTriggers = []
  for each trigger in prepared.newState.triggers
    if trigger.tableId != bound.table.tableId then remainingTriggers = remainingTriggers + [trigger] end if
  end for
  prepared.newState.triggers = remainingTriggers
  original = catalog.tableFilePath(databasePath, bound.table.tableId)
  prepared.backups = prepared.backups + [BackupPlan(original, original + ".ddl.old")]
  prepared.newCatalog.tables = removeAt(prepared.newCatalog.tables, tableIndex)
  return true
end function

// Begins the requested value.
// Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.
function begin(database)
  if not catalog.isDatabaseHandle(database) then return fail(INVALID_ARGUMENT, "begin", "database must be DatabaseHandle") end if
  if database.closed then return fail(CLOSED_HANDLE, "begin", "database is closed") end if
  return DdlTransaction(database, loadOrCreate(database.path, database.metadata.databaseId), [], true)
end function

// Validates the transaction.
// Inputs: `transaction`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateTransaction(transaction, operation)
  if transaction is not DdlTransaction then return fail(INVALID_ARGUMENT, operation, "transaction must be DdlTransaction") end if
  if not transaction.active then return fail(DDL_STATE, operation, "DDL transaction is not active") end if
  return true
end function

// Performs the stage create table operation for this module.
// Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stageCreateTable(transaction, bound)
  validateTransaction(transaction, "stageCreateTable")
  if not binder.isBoundCreateTable(bound) then return fail(INVALID_ARGUMENT, "stageCreateTable", "bound statement must be BoundCreateTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_CREATE_TABLE, bound)]
  return true
end function

// Performs the stage create index operation for this module.
// Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stageCreateIndex(transaction, bound)
  validateTransaction(transaction, "stageCreateIndex")
  if not binder.isBoundCreateIndex(bound) then return fail(INVALID_ARGUMENT, "stageCreateIndex", "bound statement must be BoundCreateIndex") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_CREATE_INDEX, bound)]
  return true
end function

// Performs the stage drop table operation for this module.
// Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stageDropTable(transaction, bound)
  validateTransaction(transaction, "stageDropTable")
  if not binder.isBoundDropTable(bound) then return fail(INVALID_ARGUMENT, "stageDropTable", "bound statement must be BoundDropTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_DROP_TABLE, bound)]
  return true
end function

// Performs the stage alter table operation for this module.
// Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.
function stageAlterTable(transaction, bound)
  validateTransaction(transaction, "stageAlterTable")
  if not binder.isBoundAlterTable(bound) then return fail(INVALID_ARGUMENT, "stageAlterTable", "bound statement must be BoundAlterTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_ALTER_TABLE, bound)]
  return true
end function

// Performs the prepare operation for this module.
// Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.
function prepare(transaction)
  validateTransaction(transaction, "prepare")
  prepared = PreparedDdl(cloneMetadata(transaction.database.metadata), cloneCatalog(transaction.database.catalog), cloneState(transaction.state), [], [])
  for each action in transaction.actions
    if action.kind == ACTION_CREATE_TABLE then
      buildCreateTable(prepared, transaction.database.path, action.payload)
    else if action.kind == ACTION_CREATE_INDEX then
      buildCreateIndex(prepared, transaction.database.path, action.payload)
    else if action.kind == ACTION_DROP_TABLE then
      buildDropTable(prepared, transaction.database.path, action.payload)
    else if action.kind == ACTION_ALTER_TABLE then
      buildAlterTable(prepared, transaction.database.path, action.payload)
    else
      return fail(DDL_STATE, "prepare", "unknown DDL action")
    end if
  end for
  prepared.newCatalog.nextObjectId = prepared.newMetadata.nextObjectId
  prepared.newState.generation = prepared.newState.generation + 1
  return prepared
end function

// Performs the journal array size operation for this module.
// Inputs: `values`. Returns the produced value or propagates a structured error from validation or delegated operations.
function journalArraySize(values)
  total = 4
  for each value in values
    total = total + stringSize(value)
  end for
  return total
end function

// Encodes the journal.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodeJournal(value)
  total = 40 + len(value.oldMeta) + len(value.oldCatalog) + len(value.oldSchema)
  total = total + journalArraySize(value.temporaryPaths) + journalArraySize(value.finalPaths) + journalArraySize(value.backupOriginals) + journalArraySize(value.backupPaths)
  payload = bytes(total, 0)
  endian.writeU32LE(payload, 0, value.status)
  schemaFlag = 0
  if value.schemaExisted then schemaFlag = 1 end if
  endian.writeU32LE(payload, 4, schemaFlag)
  endian.writeU32LE(payload, 8, len(value.oldMeta))
  endian.writeU32LE(payload, 12, len(value.oldCatalog))
  endian.writeU32LE(payload, 16, len(value.oldSchema))
  endian.writeU32LE(payload, 20, 0)
  endian.writeU64LE(payload, 24, endian.makeUInt64(0, 0))
  endian.writeU64LE(payload, 32, endian.makeUInt64(0, 0))
  offset = 40
  copyExact(payload, offset, value.oldMeta, 0, len(value.oldMeta)); offset = offset + len(value.oldMeta)
  copyExact(payload, offset, value.oldCatalog, 0, len(value.oldCatalog)); offset = offset + len(value.oldCatalog)
  copyExact(payload, offset, value.oldSchema, 0, len(value.oldSchema)); offset = offset + len(value.oldSchema)
  offset = writeStringArray(payload, offset, value.temporaryPaths)
  offset = writeStringArray(payload, offset, value.finalPaths)
  offset = writeStringArray(payload, offset, value.backupOriginals)
  offset = writeStringArray(payload, offset, value.backupPaths)
  if offset != len(payload) then return fail(CORRUPT_DATA, "encodeJournal", "internal journal size mismatch") end if
  return checksum.encodeEnvelope(journalMagic(), FORMAT_VERSION, JOURNAL_KIND, 0, payload)
end function

// Decodes the journal.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeJournal(encoded)
  envelope = checksum.decodeEnvelope(encoded, journalMagic(), FORMAT_VERSION, JOURNAL_KIND)
  payload = envelope.payload
  if len(payload) < 40 then return fail(CORRUPT_DATA, "decodeJournal", "journal payload too short") end if
  status = endian.readU32LE(payload, 0)
  schemaFlag = endian.readU32LE(payload, 4)
  if (status != JOURNAL_PREPARED and status != JOURNAL_COMMITTED) or schemaFlag > 1 or endian.readU32LE(payload, 20) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeJournal", "unsupported journal fields") end if
  reserved1 = endian.readU64LE(payload, 24)
  reserved2 = endian.readU64LE(payload, 32)
  if reserved1.high != 0 or reserved1.low != 0 or reserved2.high != 0 or reserved2.low != 0 then return fail(UNSUPPORTED_FORMAT, "decodeJournal", "reserved journal fields are non-zero") end if
  metaLength = endian.readU32LE(payload, 8)
  catalogLength = endian.readU32LE(payload, 12)
  schemaLength = endian.readU32LE(payload, 16)
  offset = 40
  combined = metaLength + catalogLength + schemaLength
  if combined > len(payload) - offset then return fail(CORRUPT_DATA, "decodeJournal", "before images exceed journal") end if
  oldMeta = slice(payload, offset, metaLength); offset = offset + metaLength
  oldCatalog = slice(payload, offset, catalogLength); offset = offset + catalogLength
  oldSchema = slice(payload, offset, schemaLength); offset = offset + schemaLength
  temporaryValue = readStringArray(payload, offset, "decodeJournal"); temporaryPaths = temporaryValue[0]; offset = temporaryValue[1]
  finalValue = readStringArray(payload, offset, "decodeJournal"); finalPaths = finalValue[0]; offset = finalValue[1]
  originalsValue = readStringArray(payload, offset, "decodeJournal"); originals = originalsValue[0]; offset = originalsValue[1]
  backupsValue = readStringArray(payload, offset, "decodeJournal"); backups = backupsValue[0]; offset = backupsValue[1]
  if offset != len(payload) or len(originals) != len(backups) then return fail(CORRUPT_DATA, "decodeJournal", "journal arrays are inconsistent") end if
  return DdlJournal(status, schemaFlag == 1, oldMeta, oldCatalog, oldSchema, temporaryPaths, finalPaths, originals, backups)
end function

// Writes the journal.
// Inputs: `databasePath`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeJournal(databasePath, value)
  writeAtomic(journalPath(databasePath), encodeJournal(value))
  return true
end function

// Evaluates whether the supplied input satisfies the maintenance journal predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isMaintenanceJournal(value)
  return value is MaintenanceJournal
end function

// Encodes the maintenance.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodeMaintenance(value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "encodeMaintenance", "value must be MaintenanceJournal") end if
  if value.status != MAINTENANCE_PREPARED and value.status != MAINTENANCE_COMMITTED then return fail(INVALID_ARGUMENT, "encodeMaintenance", "invalid status") end if
  total = 8 + stringSize(value.originalPath) + stringSize(value.temporaryPath) + stringSize(value.backupPath)
  payload = bytes(total, 0)
  endian.writeU32LE(payload, 0, value.status)
  endian.writeU32LE(payload, 4, 0)
  offset = 8
  offset = writeString(payload, offset, value.originalPath)
  offset = writeString(payload, offset, value.temporaryPath)
  offset = writeString(payload, offset, value.backupPath)
  return checksum.encodeEnvelope(maintenanceMagic(), FORMAT_VERSION, MAINTENANCE_KIND, 0, payload)
end function

// Decodes the maintenance.
// Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeMaintenance(encoded)
  envelope = checksum.decodeEnvelope(encoded, maintenanceMagic(), FORMAT_VERSION, MAINTENANCE_KIND)
  payload = envelope.payload
  if len(payload) < 20 then return fail(CORRUPT_DATA, "decodeMaintenance", "maintenance payload is too short") end if
  status = endian.readU32LE(payload, 0)
  if (status != MAINTENANCE_PREPARED and status != MAINTENANCE_COMMITTED) or endian.readU32LE(payload, 4) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeMaintenance", "unsupported maintenance fields") end if
  first = readString(payload, 8, "decodeMaintenance")
  second = readString(payload, first.nextOffset, "decodeMaintenance")
  third = readString(payload, second.nextOffset, "decodeMaintenance")
  if third.nextOffset != len(payload) or len(first.value) == 0 or len(second.value) == 0 or len(third.value) == 0 then return fail(CORRUPT_DATA, "decodeMaintenance", "maintenance paths are invalid") end if
  return MaintenanceJournal(status, first.value, second.value, third.value)
end function

// Writes the maintenance.
// Inputs: `databasePath`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeMaintenance(databasePath, value)
  writeAtomic(maintenancePath(databasePath), encodeMaintenance(value))
  return true
end function

// Begins the maintenance.
// Inputs: `databasePath`, `originalPath`, `temporaryPath`, `backupPath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function beginMaintenance(databasePath, originalPath, temporaryPath, backupPath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 or typeof(originalPath) != "string" or len(originalPath) == 0 or typeof(temporaryPath) != "string" or len(temporaryPath) == 0 or typeof(backupPath) != "string" or len(backupPath) == 0 then return fail(INVALID_ARGUMENT, "beginMaintenance", "paths must be non-empty strings") end if
  value = MaintenanceJournal(MAINTENANCE_PREPARED, originalPath, temporaryPath, backupPath)
  writeMaintenance(databasePath, value)
  return value
end function

// Marks the maintenance committed.
// Inputs: `databasePath`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function markMaintenanceCommitted(databasePath, value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "markMaintenanceCommitted", "value must be MaintenanceJournal") end if
  value.status = MAINTENANCE_COMMITTED
  writeMaintenance(databasePath, value)
  return true
end function

// Performs the finish maintenance operation for this module.
// Inputs: `databasePath`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function finishMaintenance(databasePath, value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "finishMaintenance", "value must be MaintenanceJournal") end if
  deleteIfExists(value.temporaryPath)
  deleteIfExists(value.backupPath)
  deleteIfExists(maintenancePath(databasePath))
  return true
end function

// Recovers the maintenance.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function recoverMaintenance(databasePath)
  path = maintenancePath(databasePath)
  if not file_api.fileExists(path) then return true end if
  value = decodeMaintenance(readWhole(path))
  // Maintenance may restore either generation of the authoritative table.
  // Discard the derived physical-page map before choosing that generation.
  heap_file.invalidatePageDirectory(value.originalPath)
  if value.status == MAINTENANCE_PREPARED then
    if file_api.pathExists(value.backupPath) then
      deleteIfExists(value.originalPath)
      file_api.movePath(value.backupPath, value.originalPath, true)
    else if not file_api.pathExists(value.originalPath) then
      return fail(CORRUPT_DATA, "recoverMaintenance", "both original and backup are missing")
    end if
    deleteIfExists(value.temporaryPath)
  else
    if not file_api.pathExists(value.originalPath) then
      if file_api.pathExists(value.temporaryPath) then
        file_api.movePath(value.temporaryPath, value.originalPath, true)
      else
        return fail(CORRUPT_DATA, "recoverMaintenance", "committed replacement is missing")
      end if
    end if
    deleteIfExists(value.temporaryPath)
    deleteIfExists(value.backupPath)
  end if
  deleteIfExists(path)
  return true
end function

// Deletes the if exists.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function deleteIfExists(path)
  if file_api.pathExists(path) then file_api.deletePath(path) end if
  return true
end function

// Recovers the pending.
// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function recoverPending(databasePath)
  path = journalPath(databasePath)
  if not file_api.fileExists(path) then return true end if
  value = decodeJournal(readWhole(path))
  if value.status == JOURNAL_PREPARED then
    writeAtomic(catalog.joinPath(databasePath, "db.meta"), value.oldMeta)
    writeAtomic(catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "catalog.tbl"), value.oldCatalog)
    if value.schemaExisted then
      writeAtomic(schemaPath(databasePath), value.oldSchema)
    else
      deleteIfExists(schemaPath(databasePath))
    end if
    for each temporary in value.temporaryPaths
      deleteIfExists(temporary)
    end for
    for each finalPath in value.finalPaths
      deleteIfExists(finalPath)
    end for
    if len(value.backupPaths) > 0 then
      for index = 0 to len(value.backupPaths) - 1
        if file_api.pathExists(value.backupPaths[index]) then
          deleteIfExists(value.backupOriginals[index])
          file_api.movePath(value.backupPaths[index], value.backupOriginals[index], true)
        end if
      end for
    end if
  else
    for each temporary in value.temporaryPaths
      deleteIfExists(temporary)
    end for
    for each backup in value.backupPaths
      deleteIfExists(backup)
    end for
    // A committed DROP/replace can leave only derived metadata next to the old
    // path when recovery performs the cleanup after a crash.
    for each original in value.backupOriginals
      ignoredDirectory = try(heap_file.invalidatePageDirectory(original))
    end for
  end if
  deleteIfExists(path)
  return true
end function

// Creates the planned files.
// Inputs: `transaction`, `prepared`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createPlannedFiles(transaction, prepared)
  for each plan in prepared.createFiles
    deleteIfExists(plan.temporaryPath)
    if plan.fileKind == superblock.FILE_TYPE_TABLE then
      file = paged_file.create(plan.temporaryPath, transaction.database.metadata.pageSize, superblock.FILE_TYPE_TABLE, plan.fileId, transaction.database.metadata.databaseId)
      paged_file.close(file)
    else
      tree = btree.create(plan.temporaryPath, transaction.database.metadata.pageSize, plan.fileId, transaction.database.metadata.databaseId, plan.unique)
      btree.close(tree)
    end if
  end for
  return true
end function

// Performs the publish file moves operation for this module.
// Inputs: `prepared`. Returns the produced value or propagates a structured error from validation or delegated operations.
function publishFileMoves(prepared)
  for each plan in prepared.createFiles
    if file_api.pathExists(plan.finalPath) then return fail(OBJECT_EXISTS, "publishFileMoves", "target already exists: " + plan.finalPath) end if
    file_api.movePath(plan.temporaryPath, plan.finalPath, false)
  end for
  for each plan in prepared.backups
    deleteIfExists(plan.backupPath)
    if file_api.pathExists(plan.originalPath) then file_api.movePath(plan.originalPath, plan.backupPath, false) end if
  end for
  return true
end function

// Performs the cleanup committed operation for this module.
// Inputs: `prepared`, `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function cleanupCommitted(prepared, databasePath)
  for each plan in prepared.backups
    deleteIfExists(plan.backupPath)
    ignoredDirectory = try(heap_file.invalidatePageDirectory(plan.originalPath))
  end for
  for each plan in prepared.createFiles
    deleteIfExists(plan.temporaryPath)
  end for
  deleteIfExists(journalPath(databasePath))
  return true
end function

// Commits the internal.
// Inputs: `transaction`, `stopPhase`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function commitInternal(transaction, stopPhase)
  validateTransaction(transaction, "commit")
  if typeof(stopPhase) != "int" or stopPhase < 0 or stopPhase > 3 then return fail(INVALID_ARGUMENT, "commit", "invalid stop phase") end if
  prepared = prepare(transaction)
  databasePath = transaction.database.path
  // schema.extensions is a separate durable sidecar. Include it in the same
  // before-image publication protocol as table/index files so extension
  // metadata is atomic with schema.history and db.meta.
  extensionFile = extensionPath(databasePath)
  extensionExisted = file_api.fileExists(extensionFile)
  if extensionExisted then
    prepared.backups = prepared.backups + [BackupPlan(extensionFile, extensionFile + ".ddl.old")]
  end if
  schemaExists = file_api.fileExists(schemaPath(databasePath))
  oldSchema = bytes()
  if schemaExists then oldSchema = readWhole(schemaPath(databasePath)) end if
  temporaryPaths = []
  finalPaths = []
  backupOriginals = []
  backupPaths = []
  for each plan in prepared.createFiles
    temporaryPaths = temporaryPaths + [plan.temporaryPath]
    finalPaths = finalPaths + [plan.finalPath]
  end for
  // If no extension sidecar existed before this DDL transaction, PREPARED
  // recovery removes the newly created sidecar instead of restoring a backup.
  if not extensionExisted then finalPaths = finalPaths + [extensionFile] end if
  for each plan in prepared.backups
    backupOriginals = backupOriginals + [plan.originalPath]
    backupPaths = backupPaths + [plan.backupPath]
  end for
  // Snapshot the two locked paged files through their existing owner handles.
  // Reopening their paths would violate the exclusive LockFileEx ranges held by
  // transaction.database.metaFile and transaction.database.catalogFile.
  oldMeta = paged_file.snapshotDurableBytes(transaction.database.metaFile, endian.MAX_MINILANG_INT)
  oldCatalog = paged_file.snapshotDurableBytes(transaction.database.catalogFile, endian.MAX_MINILANG_INT)
  journal = DdlJournal(JOURNAL_PREPARED, schemaExists, oldMeta, oldCatalog, oldSchema, temporaryPaths, finalPaths, backupOriginals, backupPaths)
  writeJournal(databasePath, journal)
  if stopPhase == 1 then return 1 end if
  createPlannedFiles(transaction, prepared)
  publishFileMoves(prepared)
  if stopPhase == 2 then return 2 end if

  oldMetadata = transaction.database.metadata
  oldCatalog = transaction.database.catalog
  transaction.database.metadata = prepared.newMetadata
  transaction.database.catalog = prepared.newCatalog
  persisted = try(catalog.persistMetadata(transaction.database))
  if typeof(persisted) == "error" then
    transaction.database.metadata = oldMetadata
    transaction.database.catalog = oldCatalog
    return persisted
  end if
  save(databasePath, prepared.newState)
  transaction.state = prepared.newState
  if stopPhase == 3 then return 3 end if
  journal.status = JOURNAL_COMMITTED
  writeJournal(databasePath, journal)
  cleanupCommitted(prepared, databasePath)
  transaction.active = false
  return true
end function

// Commits the requested value.
// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function commit(transaction)
  return commitInternal(transaction, 0)
end function

// Commits the stopping after.
// Inputs: `transaction`, `phase`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function commitStoppingAfter(transaction, phase)
  // Test-only crash-injection seam. The caller exits without normal cleanup and
  // the next database_manager.open invokes recoverPending().
  return commitInternal(transaction, phase)
end function

// Rolls back the requested value.
// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function rollback(transaction)
  validateTransaction(transaction, "rollback")
  transaction.actions = []
  transaction.active = false
  return true
end function

// Performs the constraints for operation for this module.
// Inputs: `databasePath`, `databaseId`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function constraintsFor(databasePath, databaseId, tableId)
  state = loadOrCreate(databasePath, databaseId)
  table = findTableSchema(state, tableId)
  if table is void then return [] end if
  return table.constraints
end function

// ---------------------------------------------------------------------------
// M43-M45 schema extension sidecar
// ---------------------------------------------------------------------------

// Performs the extension record size operation for this module.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function extensionRecordSize(state)
  total = 48
  for each view in state.views
    total = total + 8 + stringSize(view.name) + stringSize(view.sqlText) + stringArraySize(view.columnNames)
  end for
  for each sequence in state.sequences
    total = total + 60 + stringSize(sequence.name) + stringSize(sequence.ownedColumnName)
  end for
  for each generated in state.generatedColumns
    total = total + 12 + stringSize(generated.columnName) + stringSize(generated.expressionSql)
  end for
  for each trigger in state.triggers
    total = total + 24 + stringSize(trigger.name) + stringSize(trigger.targetColumn) + stringSize(trigger.expressionSql)
  end for
  return total
end function

// Encodes the extensions.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodeExtensions(state)
  if state is not SchemaState then return fail(INVALID_ARGUMENT, "encodeExtensions", "state must be SchemaState") end if
  if typeof(state.databaseId) != "bytes" or len(state.databaseId) != 16 then return fail(INVALID_ARGUMENT, "encodeExtensions", "state databaseId must be 16 bytes") end if

  // Snapshot the 16-byte identity into scalar words before extension sizing or
  // payload allocation. This avoids retaining a heap-backed field access across
  // allocation-heavy calls in the native MiniLang backend.
  databaseIdWord0 = endian.readU32LE(state.databaseId, 0)
  databaseIdWord1 = endian.readU32LE(state.databaseId, 4)
  databaseIdWord2 = endian.readU32LE(state.databaseId, 8)
  databaseIdWord3 = endian.readU32LE(state.databaseId, 12)

  total = extensionRecordSize(state)
  payload = bytes(total, 0)
  endian.writeU32LE(payload, 0, databaseIdWord0)
  endian.writeU32LE(payload, 4, databaseIdWord1)
  endian.writeU32LE(payload, 8, databaseIdWord2)
  endian.writeU32LE(payload, 12, databaseIdWord3)
  endian.writeU64LE(payload, 16, endian.uint64FromInt(state.generation))
  endian.writeU32LE(payload, 24, len(state.views))
  endian.writeU32LE(payload, 28, len(state.sequences))
  endian.writeU32LE(payload, 32, len(state.generatedColumns))
  endian.writeU32LE(payload, 36, len(state.triggers))
  endian.writeU64LE(payload, 40, endian.makeUInt64(0, 0))
  offset = 48
  for each view in state.views
    if view is not ViewDefinition then return fail(INVALID_ARGUMENT, "encodeExtensions", "invalid view") end if
    endian.writeU64LE(payload, offset, endian.uint64FromInt(view.viewId)); offset = offset + 8
    offset = writeString(payload, offset, view.name)
    offset = writeString(payload, offset, view.sqlText)
    offset = writeStringArray(payload, offset, view.columnNames)
  end for
  for each sequence in state.sequences
    if sequence is not SequenceDefinition then return fail(INVALID_ARGUMENT, "encodeExtensions", "invalid sequence") end if
    endian.writeU64LE(payload, offset, endian.uint64FromInt(sequence.sequenceId))
    endian.writeI64LE(payload, offset + 8, sequence.startValue)
    endian.writeI64LE(payload, offset + 16, sequence.incrementValue)
    endian.writeI64LE(payload, offset + 24, sequence.minimumValue)
    endian.writeI64LE(payload, offset + 32, sequence.maximumValue)
    endian.writeI64LE(payload, offset + 40, sequence.lastValue)
    flags = 0
    if sequence.hasValue then flags = flags | 1 end if
    if sequence.cycle then flags = flags | 2 end if
    endian.writeU32LE(payload, offset + 48, flags)
    endian.writeU64LE(payload, offset + 52, endian.uint64FromInt(sequence.ownedTableId))
    offset = offset + 60
    offset = writeString(payload, offset, sequence.name)
    offset = writeString(payload, offset, sequence.ownedColumnName)
  end for
  for each generated in state.generatedColumns
    if generated is not GeneratedColumnDefinition then return fail(INVALID_ARGUMENT, "encodeExtensions", "invalid generated column") end if
    endian.writeU64LE(payload, offset, endian.uint64FromInt(generated.tableId))
    flags = 0
    if generated.stored then flags = 1 end if
    endian.writeU32LE(payload, offset + 8, flags)
    offset = offset + 12
    offset = writeString(payload, offset, generated.columnName)
    offset = writeString(payload, offset, generated.expressionSql)
  end for
  for each trigger in state.triggers
    if trigger is not TriggerDefinition then return fail(INVALID_ARGUMENT, "encodeExtensions", "invalid trigger") end if
    endian.writeU64LE(payload, offset, endian.uint64FromInt(trigger.triggerId))
    endian.writeU64LE(payload, offset + 8, endian.uint64FromInt(trigger.tableId))
    endian.writeU16LE(payload, offset + 16, trigger.timing)
    endian.writeU16LE(payload, offset + 18, trigger.eventType)
    flags = 0
    if trigger.enabled then flags = 1 end if
    endian.writeU32LE(payload, offset + 20, flags)
    offset = offset + 24
    offset = writeString(payload, offset, trigger.name)
    offset = writeString(payload, offset, trigger.targetColumn)
    offset = writeString(payload, offset, trigger.expressionSql)
  end for
  if offset != len(payload) then return fail(CORRUPT_DATA, "encodeExtensions", "extension size mismatch") end if
  return checksum.encodeEnvelope(extensionMagic(), SCHEMA_EXTENSION_VERSION, EXTENSION_KIND, 0, payload)
end function

// Appends the extension value.
// Inputs: `values`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendExtensionValue(values, value)
  if typeof(values) != "array" then return fail(INVALID_ARGUMENT, "appendExtensionValue", "values must be array") end if
  count = len(values)
  output = array(count + 1)
  if count > 0 then
    for index = 0 to count - 1
      output[index] = values[index]
    end for
  end if
  output[count] = value
  return output
end function

// Decodes the view extension entry.
// Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeViewExtensionEntry(payload, offset, payloadLength)
  if offset < 0 or offset > payloadLength - 8 then return fail(CORRUPT_DATA, "decodeExtensions", "view header exceeds payload") end if
  viewId = decodeNative(endian.readU64LE(payload, offset), "decodeExtensions", "viewId")
  nextOffset = offset + 8
  nameValue = readString(payload, nextOffset, "decodeExtensions")
  sqlValue = readString(payload, nameValue.nextOffset, "decodeExtensions")
  columnsValue = readStringArray(payload, sqlValue.nextOffset, "decodeExtensions")
  value = viewDefinition(viewId, nameValue.value, sqlValue.value, columnsValue[0])
  nextOffset = columnsValue[1]
  return DecodedExtensionEntry(value, nextOffset)
end function

// Decodes the sequence extension entry.
// Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeSequenceExtensionEntry(payload, offset, payloadLength)
  if offset < 0 or offset > payloadLength - 60 then return fail(CORRUPT_DATA, "decodeExtensions", "sequence header exceeds payload") end if
  sequenceId = decodeNative(endian.readU64LE(payload, offset), "decodeExtensions", "sequenceId")
  startValue = endian.readI64LE(payload, offset + 8)
  incrementValue = endian.readI64LE(payload, offset + 16)
  minimumValue = endian.readI64LE(payload, offset + 24)
  maximumValue = endian.readI64LE(payload, offset + 32)
  lastValue = endian.readI64LE(payload, offset + 40)
  flags = endian.readU32LE(payload, offset + 48)
  if (flags & 0xFFFFFFFC) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeExtensions", "unknown sequence flags") end if
  ownedTableId = decodeNative(endian.readU64LE(payload, offset + 52), "decodeExtensions", "ownedTableId")
  nameValue = readString(payload, offset + 60, "decodeExtensions")
  ownedValue = readString(payload, nameValue.nextOffset, "decodeExtensions")
  value = sequenceDefinition(sequenceId, nameValue.value, startValue, incrementValue, minimumValue, maximumValue, lastValue, (flags & 1) != 0, (flags & 2) != 0, ownedTableId, ownedValue.value)
  return DecodedExtensionEntry(value, ownedValue.nextOffset)
end function

// Decodes the generated extension entry.
// Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeGeneratedExtensionEntry(payload, offset, payloadLength)
  if offset < 0 or offset > payloadLength - 12 then return fail(CORRUPT_DATA, "decodeExtensions", "generated-column header exceeds payload") end if
  tableId = decodeNative(endian.readU64LE(payload, offset), "decodeExtensions", "generatedTableId")
  flags = endian.readU32LE(payload, offset + 8)
  if (flags & 0xFFFFFFFE) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeExtensions", "unknown generated-column flags") end if
  nameValue = readString(payload, offset + 12, "decodeExtensions")
  sqlValue = readString(payload, nameValue.nextOffset, "decodeExtensions")
  value = generatedColumnDefinition(tableId, nameValue.value, sqlValue.value, (flags & 1) != 0)
  return DecodedExtensionEntry(value, sqlValue.nextOffset)
end function

// Decodes the trigger extension entry.
// Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeTriggerExtensionEntry(payload, offset, payloadLength)
  if offset < 0 or offset > payloadLength - 24 then return fail(CORRUPT_DATA, "decodeExtensions", "trigger header exceeds payload") end if
  triggerId = decodeNative(endian.readU64LE(payload, offset), "decodeExtensions", "triggerId")
  tableId = decodeNative(endian.readU64LE(payload, offset + 8), "decodeExtensions", "triggerTableId")
  timing = endian.readU16LE(payload, offset + 16)
  eventType = endian.readU16LE(payload, offset + 18)
  flags = endian.readU32LE(payload, offset + 20)
  if (flags & 0xFFFFFFFE) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeExtensions", "unknown trigger flags") end if
  nameValue = readString(payload, offset + 24, "decodeExtensions")
  targetValue = readString(payload, nameValue.nextOffset, "decodeExtensions")
  sqlValue = readString(payload, targetValue.nextOffset, "decodeExtensions")
  value = triggerDefinition(triggerId, nameValue.value, tableId, timing, eventType, targetValue.value, sqlValue.value, (flags & 1) != 0)
  return DecodedExtensionEntry(value, sqlValue.nextOffset)
end function

// Decodes the extensions.
// Inputs: `encoded`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeExtensions(encoded, databaseId)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, "decodeExtensions", "databaseId must be 16 bytes") end if

  // Keep the expected identity in four scalar words before decoding the
  // envelope. The decoder allocates a payload copy, so comparing heap-backed
  // arguments in one nested expression is intentionally avoided.
  expectedDatabaseIdWord0 = endian.readU32LE(databaseId, 0)
  expectedDatabaseIdWord1 = endian.readU32LE(databaseId, 4)
  expectedDatabaseIdWord2 = endian.readU32LE(databaseId, 8)
  expectedDatabaseIdWord3 = endian.readU32LE(databaseId, 12)

  envelope = checksum.decodeEnvelope(encoded, extensionMagic(), SCHEMA_EXTENSION_VERSION, EXTENSION_KIND)
  payload = envelope.payload
  if typeof(payload) != "bytes" then return fail(CORRUPT_DATA, "decodeExtensions", "extension payload must be bytes") end if
  payloadLength = len(payload)
  if payloadLength < 48 then return fail(CORRUPT_DATA, "decodeExtensions", "extension payload too short") end if
  if endian.readU32LE(payload, 0) != expectedDatabaseIdWord0 or endian.readU32LE(payload, 4) != expectedDatabaseIdWord1 or endian.readU32LE(payload, 8) != expectedDatabaseIdWord2 or endian.readU32LE(payload, 12) != expectedDatabaseIdWord3 then return fail(CORRUPT_DATA, "decodeExtensions", "extensions belong to another database") end if

  verifiedDatabaseId = bytes(16, 0)
  endian.writeU32LE(verifiedDatabaseId, 0, expectedDatabaseIdWord0)
  endian.writeU32LE(verifiedDatabaseId, 4, expectedDatabaseIdWord1)
  endian.writeU32LE(verifiedDatabaseId, 8, expectedDatabaseIdWord2)
  endian.writeU32LE(verifiedDatabaseId, 12, expectedDatabaseIdWord3)

  reserved = endian.readU64LE(payload, 40)
  if reserved.high != 0 or reserved.low != 0 then return fail(UNSUPPORTED_FORMAT, "decodeExtensions", "reserved field is non-zero") end if
  state = createState(verifiedDatabaseId)
  state.generation = decodeNative(endian.readU64LE(payload, 16), "decodeExtensions", "generation")
  viewCount = endian.readU32LE(payload, 24)
  sequenceCount = endian.readU32LE(payload, 28)
  generatedCount = endian.readU32LE(payload, 32)
  triggerCount = endian.readU32LE(payload, 36)
  offset = 48
  if viewCount > 0 then
    for index = 0 to viewCount - 1
      decodedEntry = decodeViewExtensionEntry(payload, offset, payloadLength)
      state.views = appendExtensionValue(state.views, decodedEntry.value)
      offset = decodedEntry.nextOffset
    end for
  end if
  if sequenceCount > 0 then
    for index = 0 to sequenceCount - 1
      decodedEntry = decodeSequenceExtensionEntry(payload, offset, payloadLength)
      state.sequences = appendExtensionValue(state.sequences, decodedEntry.value)
      offset = decodedEntry.nextOffset
    end for
  end if
  if generatedCount > 0 then
    for index = 0 to generatedCount - 1
      decodedEntry = decodeGeneratedExtensionEntry(payload, offset, payloadLength)
      state.generatedColumns = appendExtensionValue(state.generatedColumns, decodedEntry.value)
      offset = decodedEntry.nextOffset
    end for
  end if
  if triggerCount > 0 then
    for index = 0 to triggerCount - 1
      decodedEntry = decodeTriggerExtensionEntry(payload, offset, payloadLength)
      state.triggers = appendExtensionValue(state.triggers, decodedEntry.value)
      offset = decodedEntry.nextOffset
    end for
  end if
  if offset != payloadLength then return fail(CORRUPT_DATA, "decodeExtensions", "trailing extension bytes") end if
  return state
end function

// Persists the extensions.
// Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function saveExtensions(databasePath, state)
  return writeAtomic(extensionPath(databasePath), encodeExtensions(state))
end function

// Loads the extensions into.
// Inputs: `databasePath`, `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function loadExtensionsInto(databasePath, state)
  path = extensionPath(databasePath)
  if not file_api.fileExists(path) then return state end if
  extension = decodeExtensions(readWhole(path), state.databaseId)
  state.views = extension.views
  state.sequences = extension.sequences
  state.generatedColumns = extension.generatedColumns
  state.triggers = extension.triggers
  if extension.generation > state.generation then state.generation = extension.generation end if
  return state
end function

// Performs the next extension id operation for this module.
// Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.
function nextExtensionId(state)
  maximum = 0
  for each view in state.views
    if view.viewId > maximum then maximum = view.viewId end if
  end for
  for each sequence in state.sequences
    if sequence.sequenceId > maximum then maximum = sequence.sequenceId end if
  end for
  for each trigger in state.triggers
    if trigger.triggerId > maximum then maximum = trigger.triggerId end if
  end for
  return maximum + 1
end function

// Finds the view.
// Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findView(state, name)
  for each view in state.views
    if view.name == name then return view end if
  end for
  return void
end function

// Encodes a durable schema namespace as an internal extension entry.
function schemaMarkerName(name)
  return SCHEMA_MARKER_PREFIX + name
end function

// Returns whether a persisted view entry is an internal schema marker.
function isSchemaMarkerName(name)
  raw = bytes(name)
  prefix = bytes(SCHEMA_MARKER_PREFIX)
  if len(raw) <= len(prefix) then return false end if
  for index = 0 to len(prefix) - 1
    if raw[index] != prefix[index] then return false end if
  end for
  return true
end function

// Encodes a stored procedure in the durable extension namespace.
function procedureMarkerName(name)
  return PROCEDURE_MARKER_PREFIX + name
end function

// Returns whether a view extension entry stores procedure metadata.
function isProcedureMarkerName(name)
  raw = bytes(name)
  prefix = bytes(PROCEDURE_MARKER_PREFIX)
  if len(raw) <= len(prefix) then return false end if
  for index = 0 to len(prefix) - 1
    if raw[index] != prefix[index] then return false end if
  end for
  return true
end function

// Decodes the SQL-visible procedure name from an internal marker.
function procedureObjectName(markerName)
  if not isProcedureMarkerName(markerName) then return "" end if
  raw = bytes(markerName)
  prefixLength = len(bytes(PROCEDURE_MARKER_PREFIX))
  return decode(slice(raw, prefixLength, len(raw) - prefixLength))
end function

// Returns whether a view extension entry is internal rather than SQL-visible.
function isInternalExtensionViewName(name)
  return isSchemaMarkerName(name) or isProcedureMarkerName(name)
end function

// Returns true when an object name starts with the exact `schema.` prefix.
function objectInSchema(objectName, schemaName)
  prefix = schemaName + "."
  objectRaw = bytes(objectName)
  prefixRaw = bytes(prefix)
  if len(objectRaw) <= len(prefixRaw) then return false end if
  for index = 0 to len(prefixRaw) - 1
    if objectRaw[index] != prefixRaw[index] then return false end if
  end for
  return true
end function

// Returns whether a schema is built in or durably registered.
function schemaExists(state, name)
  if name == "public" or name == "information_schema" then return true end if
  return findView(state, schemaMarkerName(name)) is not void
end function

// Returns all SQL-visible schemas while hiding internal persistence markers.
function schemaNames(state)
  output = ["public", "information_schema"]
  for each view in state.views
    raw = bytes(view.name)
    prefix = bytes(SCHEMA_MARKER_PREFIX)
    if len(raw) > len(prefix) then
      matches = true
      for index = 0 to len(prefix) - 1
        if raw[index] != prefix[index] then matches = false end if
      end for
      if matches then output = output + [decode(slice(raw, len(prefix), len(raw) - len(prefix)))] end if
    end if
  end for
  return output
end function

// Creates a durable empty schema namespace using the extension sidecar.
function putSchema(databasePath, databaseId, name, ifNotExists)
  if name == "public" or name == "information_schema" then
    if ifNotExists then return false end if
    return fail(OBJECT_EXISTS, "putSchema", "schema already exists: " + name)
  end if
  state = loadOrCreate(databasePath, databaseId)
  if schemaExists(state, name) then
    if ifNotExists then return false end if
    return fail(OBJECT_EXISTS, "putSchema", "schema already exists: " + name)
  end if
  putView(databasePath, databaseId, schemaMarkerName(name), "SELECT 1", ["schema_marker"], false)
  return true
end function

// Drops an empty user schema and rejects built-in or populated namespaces.
function dropSchema(databasePath, databaseId, name, ifExists)
  if name == "public" or name == "information_schema" then return fail(CONSTRAINT_VIOLATION, "dropSchema", "built-in schema cannot be dropped: " + name) end if
  state = loadOrCreate(databasePath, databaseId)
  if not schemaExists(state, name) then
    if ifExists then return false end if
    return fail(OBJECT_NOT_FOUND, "dropSchema", "schema not found: " + name)
  end if
  for each view in state.views
    visibleName = view.name
    if isProcedureMarkerName(view.name) then visibleName = procedureObjectName(view.name) end if
    if view.name != schemaMarkerName(name) and objectInSchema(visibleName, name) then return fail(CONSTRAINT_VIOLATION, "dropSchema", "schema is not empty: " + name) end if
  end for
  for each sequence in state.sequences
    if objectInSchema(sequence.name, name) then return fail(CONSTRAINT_VIOLATION, "dropSchema", "schema is not empty: " + name) end if
  end for
  for each trigger in state.triggers
    if objectInSchema(trigger.name, name) then return fail(CONSTRAINT_VIOLATION, "dropSchema", "schema is not empty: " + name) end if
  end for
  for each table in state.tables
    for each value in table.constraints
      if objectInSchema(value.name, name) or objectInSchema(value.indexName, name) then return fail(CONSTRAINT_VIOLATION, "dropSchema", "schema is not empty: " + name) end if
    end for
  end for
  dropView(databasePath, databaseId, schemaMarkerName(name), false)
  return true
end function

// Performs the put view operation for this module.
// Inputs: `databasePath`, `databaseId`, `name`, `sqlText`, `columnNames`, `replace`. Returns the produced value or propagates a structured error from validation or delegated operations.
function putView(databasePath, databaseId, name, sqlText, columnNames, replace)
  state = loadOrCreate(databasePath, databaseId)
  existingIndex = -1
  if len(state.views) > 0 then
    for index = 0 to len(state.views) - 1
      if state.views[index].name == name then existingIndex = index end if
    end for
  end if
  if existingIndex >= 0 and not replace then return fail(OBJECT_EXISTS, "putView", "view already exists: " + name) end if
  value = viewDefinition(nextExtensionId(state), name, sqlText, columnNames)
  if existingIndex >= 0 then value.viewId = state.views[existingIndex].viewId; state.views[existingIndex] = value else state.views = state.views + [value] end if
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return value
end function

// Drops the view.
// Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function dropView(databasePath, databaseId, name, ifExists)
  state = loadOrCreate(databasePath, databaseId)
  index = -1
  if len(state.views) > 0 then
    for position = 0 to len(state.views) - 1
      if state.views[position].name == name then index = position end if
    end for
  end if
  if index < 0 then
    if ifExists then return false end if
    return fail(OBJECT_NOT_FOUND, "dropView", "view not found: " + name)
  end if
  state.views = removeAt(state.views, index)
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return true
end function

// Finds a persisted stored procedure by its SQL-visible name.
function findProcedure(state, name)
  return findView(state, procedureMarkerName(name))
end function

// Creates or replaces a stored procedure body and ordered parameter names.
function putProcedure(databasePath, databaseId, name, bodySql, parameterNames, replace)
  return putView(databasePath, databaseId, procedureMarkerName(name), bodySql, parameterNames, replace)
end function

// Drops a stored procedure without exposing its internal extension marker.
function dropProcedure(databasePath, databaseId, name, ifExists)
  return dropView(databasePath, databaseId, procedureMarkerName(name), ifExists)
end function

// Finds the sequence.
// Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findSequence(state, name)
  for each sequence in state.sequences
    if sequence.name == name then return sequence end if
  end for
  return void
end function

// Performs the put sequence operation for this module.
// Inputs: `databasePath`, `databaseId`, `name`, `startValue`, `incrementValue`, `minimumValue`, `maximumValue`, `cycle`, `ifNotExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function putSequence(databasePath, databaseId, name, startValue, incrementValue, minimumValue, maximumValue, cycle, ifNotExists)
  state = loadOrCreate(databasePath, databaseId)
  existing = findSequence(state, name)
  if existing is not void then
    if ifNotExists then return existing end if
    return fail(OBJECT_EXISTS, "putSequence", "sequence already exists: " + name)
  end if
  value = sequenceDefinition(nextExtensionId(state), name, endian.int64FromInt(startValue), endian.int64FromInt(incrementValue), endian.int64FromInt(minimumValue), endian.int64FromInt(maximumValue), endian.int64FromInt(startValue), false, cycle, 0, "")
  state.sequences = state.sequences + [value]
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return value
end function

// Drops the sequence.
// Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function dropSequence(databasePath, databaseId, name, ifExists)
  state = loadOrCreate(databasePath, databaseId)
  index = -1
  if len(state.sequences) > 0 then
    for position = 0 to len(state.sequences) - 1
      if state.sequences[position].name == name then index = position end if
    end for
  end if
  if index < 0 then
    if ifExists then return false end if
    return fail(OBJECT_NOT_FOUND, "dropSequence", "sequence not found: " + name)
  end if
  state.sequences = removeAt(state.sequences, index)
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return true
end function

// Performs the next sequence operation for this module.
// Inputs: `databasePath`, `databaseId`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function nextSequence(databasePath, databaseId, name)
  state = loadOrCreate(databasePath, databaseId)
  sequence = findSequence(state, name)
  if sequence is void then return fail(OBJECT_NOT_FOUND, "nextSequence", "sequence not found: " + name) end if
  current = endian.int64ToInt(sequence.startValue)
  if sequence.hasValue then current = endian.int64ToInt(sequence.lastValue) + endian.int64ToInt(sequence.incrementValue) end if
  minimum = endian.int64ToInt(sequence.minimumValue)
  maximum = endian.int64ToInt(sequence.maximumValue)
  if current < minimum or current > maximum then
    if not sequence.cycle then return fail(CONSTRAINT_VIOLATION, "nextSequence", "sequence exhausted: " + name) end if
    if endian.int64ToInt(sequence.incrementValue) > 0 then current = minimum else current = maximum end if
  end if
  sequence.lastValue = endian.int64FromInt(current)
  sequence.hasValue = true
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return sequence.lastValue
end function

// Performs the generated for table operation for this module.
// Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function generatedForTable(state, tableId)
  output = []
  for each generated in state.generatedColumns
    if generated.tableId == tableId then output = output + [generated] end if
  end for
  return output
end function

// Performs the triggers for table operation for this module.
// Inputs: `state`, `tableId`, `eventType`. Returns the produced value or propagates a structured error from validation or delegated operations.
function triggersForTable(state, tableId, eventType)
  output = []
  for each trigger in state.triggers
    if trigger.tableId == tableId and trigger.eventType == eventType and trigger.enabled then output = output + [trigger] end if
  end for
  return output
end function

// Performs the put trigger operation for this module.
// Inputs: `databasePath`, `databaseId`, `name`, `tableId`, `timing`, `eventType`, `targetColumn`, `expressionSql`, `ifNotExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function putTrigger(databasePath, databaseId, name, tableId, timing, eventType, targetColumn, expressionSql, ifNotExists)
  state = loadOrCreate(databasePath, databaseId)
  for each existing in state.triggers
    if existing.name == name then
      if ifNotExists then return existing end if
      return fail(OBJECT_EXISTS, "putTrigger", "trigger already exists: " + name)
    end if
  end for
  value = triggerDefinition(nextExtensionId(state), name, tableId, timing, eventType, targetColumn, expressionSql, true)
  state.triggers = state.triggers + [value]
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return value
end function

// Drops the trigger.
// Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.
function dropTrigger(databasePath, databaseId, name, ifExists)
  state = loadOrCreate(databasePath, databaseId)
  index = -1
  if len(state.triggers) > 0 then
    for position = 0 to len(state.triggers) - 1
      if state.triggers[position].name == name then index = position end if
    end for
  end if
  if index < 0 then
    if ifExists then return false end if
    return fail(OBJECT_NOT_FOUND, "dropTrigger", "trigger not found: " + name)
  end if
  state.triggers = removeAt(state.triggers, index)
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return true
end function

// Persists the enabled state of an existing trigger definition.
function setTriggerEnabled(databasePath, databaseId, name, enabled)
  if typeof(enabled) != "bool" then return fail(INVALID_ARGUMENT, "setTriggerEnabled", "enabled must be bool") end if
  state = loadOrCreate(databasePath, databaseId)
  found = false
  for each trigger in state.triggers
    if trigger.name == name then trigger.enabled = enabled; found = true end if
  end for
  if not found then return fail(OBJECT_NOT_FOUND, "setTriggerEnabled", "trigger not found: " + name) end if
  state.generation = state.generation + 1
  saveExtensions(databasePath, state)
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "catalog.schema_history"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M14"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
