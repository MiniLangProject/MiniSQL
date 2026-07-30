package minisql.catalog.schema_history

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
const MAX_SCHEMA_BYTES = 1048576

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

struct ColumnRule
  columnName
  defaultSql
  identity
end struct

struct ConstraintDefinition
  name
  kind
  columns
  expressionSql
  referenceTable
  referenceColumns
  onDelete
  onUpdate
  indexId
  indexName
end struct

struct TableSchema
  tableId
  schemaVersion
  columnRules
  constraints
end struct

struct ViewDefinition
  viewId
  name
  sqlText
  columnNames
end struct

struct SequenceDefinition
  sequenceId
  name
  startValue
  incrementValue
  minimumValue
  maximumValue
  lastValue
  hasValue
  cycle
  ownedTableId
  ownedColumnName
end struct

struct GeneratedColumnDefinition
  tableId
  columnName
  expressionSql
  stored
end struct

struct TriggerDefinition
  triggerId
  name
  tableId
  timing
  eventType
  targetColumn
  expressionSql
  enabled
end struct

struct SchemaState
  databaseId
  generation
  tables
  views
  sequences
  generatedColumns
  triggers
end struct

struct DdlAction
  kind
  payload
end struct

struct DdlTransaction
  database
  state
  actions
  active
end struct

struct CreateFilePlan
  temporaryPath
  finalPath
  fileKind
  fileId
  unique
end struct

struct BackupPlan
  originalPath
  backupPath
end struct

struct PreparedDdl
  newMetadata
  newCatalog
  newState
  createFiles
  backups
end struct

struct DdlJournal
  status
  schemaExisted
  oldMeta
  oldCatalog
  oldSchema
  temporaryPaths
  finalPaths
  backupOriginals
  backupPaths
end struct

struct MaintenanceJournal
  status
  originalPath
  temporaryPath
  backupPath
end struct

struct DecodedString
  value
  nextOffset
end struct

// Generic cursor result used by the schema-extension decoder. Keeping each
// record decoder in its own function avoids a large lexical block with many
// temporary locals retaining and later clearing the shared payload reference.
struct DecodedExtensionEntry
  value
  nextOffset
end struct

function fail(code, operation, message)
  return error(code, "catalog.schema_history." + operation + ": " + message)
end function

function schemaMagic()
  return bytes("MSSCHEM1")
end function

function journalMagic()
  return bytes("MSDDLJ01")
end function

function maintenanceMagic()
  return bytes("MSMAINT1")
end function

function extensionMagic()
  return bytes("MSEXT001")
end function

function schemaPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "schema.history")
end function

function journalPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "ddl.pending")
end function

function maintenancePath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "maintenance.pending")
end function

function extensionPath(databasePath)
  return catalog.joinPath(catalog.joinPath(databasePath, "catalog"), "schema.extensions")
end function

function indexFilePath(databasePath, indexId)
  return catalog.joinPath(catalog.joinPath(databasePath, "indexes"), "i" + indexId + ".idx")
end function

function isSchemaState(value)
  return value is SchemaState
end function

function isConstraintDefinition(value)
  return value is ConstraintDefinition
end function

function isTableSchema(value)
  return value is TableSchema
end function

function isDdlTransaction(value)
  return value is DdlTransaction
end function

function isViewDefinition(value)
  return value is ViewDefinition
end function

function isSequenceDefinition(value)
  return value is SequenceDefinition
end function

function isGeneratedColumnDefinition(value)
  return value is GeneratedColumnDefinition
end function

function isTriggerDefinition(value)
  return value is TriggerDefinition
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

function readWhole(path)
  file = file_api.openRead(path)
  length = file_api.size(file)
  if length > MAX_SCHEMA_BYTES * 4 then file_api.close(file); return fail(CORRUPT_DATA, "readWhole", "file exceeds safety limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(file, 0, output, 0, length) end if
  file_api.close(file)
  return output
end function

function writeWhole(path, data)
  if typeof(data) != "bytes" then return fail(INVALID_ARGUMENT, "writeWhole", "data must be bytes") end if
  file = file_api.create(path)
  if len(data) > 0 then file_api.writeAt(file, 0, data, 0, len(data)) end if
  file_api.truncate(file, len(data))
  file_api.flush(file)
  file_api.close(file)
  return true
end function

function writeAtomic(path, data)
  temporary = path + ".new"
  if file_api.pathExists(temporary) then file_api.deletePath(temporary) end if
  writeWhole(temporary, data)
  file_api.movePath(temporary, path, true)
  return true
end function

function stringSize(value)
  if value is void then return 4 end if
  if typeof(value) != "string" then return fail(INVALID_ARGUMENT, "stringSize", "value must be string or void") end if
  return 4 + len(bytes(value))
end function

function writeString(output, offset, value)
  data = bytes()
  if value is not void then data = bytes(value) end if
  endian.writeU32LE(output, offset, len(data))
  if len(data) > 0 then copyExact(output, offset + 4, data, 0, len(data)) end if
  return offset + 4 + len(data)
end function

function readString(source, offset, operation)
  if offset < 0 or offset > len(source) - 4 then return fail(CORRUPT_DATA, operation, "string length exceeds payload") end if
  length = endian.readU32LE(source, offset)
  if length > len(source) - offset - 4 then return fail(CORRUPT_DATA, operation, "string exceeds payload") end if
  value = ""
  if length > 0 then value = decode(slice(source, offset + 4, length)) end if
  return DecodedString(value, offset + 4 + length)
end function

function stringArraySize(values)
  if typeof(values) != "array" then return fail(INVALID_ARGUMENT, "stringArraySize", "values must be array") end if
  total = 4
  for each value in values
    total = total + stringSize(value)
  end for
  return total
end function

function writeStringArray(output, offset, values)
  endian.writeU32LE(output, offset, len(values))
  offset = offset + 4
  for each value in values
    offset = writeString(output, offset, value)
  end for
  return offset
end function

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

function viewDefinition(viewId, name, sqlText, columnNames)
  if typeof(viewId) != "int" or viewId < 0 or typeof(name) != "string" or len(name) == 0 or typeof(sqlText) != "string" or len(sqlText) == 0 or typeof(columnNames) != "array" then return fail(INVALID_ARGUMENT, "viewDefinition", "invalid view definition") end if
  return ViewDefinition(viewId, name, sqlText, columnNames)
end function

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

function generatedColumnDefinition(tableId, columnName, expressionSql, stored)
  if typeof(tableId) != "int" or tableId < 0 or typeof(columnName) != "string" or len(columnName) == 0 or typeof(expressionSql) != "string" or len(expressionSql) == 0 or typeof(stored) != "bool" then return fail(INVALID_ARGUMENT, "generatedColumnDefinition", "invalid generated column") end if
  return GeneratedColumnDefinition(tableId, columnName, expressionSql, stored)
end function

function triggerDefinition(triggerId, name, tableId, timing, eventType, targetColumn, expressionSql, enabled)
  if typeof(triggerId) != "int" or triggerId < 0 or typeof(name) != "string" or len(name) == 0 or typeof(tableId) != "int" or tableId < 0 or (timing != TRIGGER_BEFORE and timing != TRIGGER_AFTER) or (eventType < TRIGGER_INSERT or eventType > TRIGGER_DELETE) or typeof(targetColumn) != "string" or typeof(expressionSql) != "string" or typeof(enabled) != "bool" then return fail(INVALID_ARGUMENT, "triggerDefinition", "invalid trigger") end if
  return TriggerDefinition(triggerId, name, tableId, timing, eventType, targetColumn, expressionSql, enabled)
end function

function columnRule(columnName, defaultSql, identity)
  if typeof(columnName) != "string" or len(columnName) == 0 or (defaultSql is not void and typeof(defaultSql) != "string") or typeof(identity) != "bool" then return fail(INVALID_ARGUMENT, "columnRule", "invalid column rule") end if
  return ColumnRule(columnName, defaultSql, identity)
end function

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

function tableSchema(tableId, schemaVersion, columnRules, constraints)
  if typeof(tableId) != "int" or tableId < 0 or typeof(schemaVersion) != "int" or schemaVersion <= 0 or typeof(columnRules) != "array" or typeof(constraints) != "array" then return fail(INVALID_ARGUMENT, "tableSchema", "invalid table schema") end if
  return TableSchema(tableId, schemaVersion, columnRules, constraints)
end function

function encodedRuleSize(rule)
  return 4 + stringSize(rule.columnName) + stringSize(rule.defaultSql)
end function

function encodedConstraintSize(value)
  return 24 + stringSize(value.name) + stringArraySize(value.columns) + stringSize(value.expressionSql) + stringSize(value.referenceTable) + stringArraySize(value.referenceColumns) + stringSize(value.onDelete) + stringSize(value.onUpdate) + stringSize(value.indexName)
end function

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

function encode(state)
  if state is not SchemaState then return fail(INVALID_ARGUMENT, "encode", "state must be SchemaState") end if
  total = 32
  for each table in state.tables
    if table is not TableSchema then return fail(INVALID_ARGUMENT, "encode", "invalid table schema") end if
    total = total + encodedTableSize(table)
  end for
  if total > MAX_SCHEMA_BYTES then return fail(INVALID_ARGUMENT, "encode", "schema history exceeds 1 MiB") end if
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

function decodeNative(words, operation, name)
  endian.validateUInt64Words(words, "catalog.schema_history." + operation + "." + name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

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
function decode(encoded)
  return decodeState(encoded)
end function

function save(databasePath, state)
  writeAtomic(schemaPath(databasePath), encode(state))
  saveExtensions(databasePath, state)
  return true
end function

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

function findTableSchema(state, tableId)
  if state is not SchemaState then return fail(INVALID_ARGUMENT, "findTableSchema", "state must be SchemaState") end if
  for each table in state.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

function findConstraint(tableSchemaValue, name)
  if tableSchemaValue is not TableSchema then return fail(INVALID_ARGUMENT, "findConstraint", "tableSchema must be TableSchema") end if
  for each value in tableSchemaValue.constraints
    if value.name == name then return value end if
  end for
  return void
end function

function cloneMetadata(value)
  return metadata.decodeDatabase(metadata.encodeDatabase(value))
end function

function cloneCatalog(value)
  return metadata.decodeCatalog(metadata.encodeCatalog(value))
end function

function cloneState(value)
  cloned = decodeState(encode(value))
  extension = decodeExtensions(encodeExtensions(value), value.databaseId)
  cloned.views = extension.views
  cloned.sequences = extension.sequences
  cloned.generatedColumns = extension.generatedColumns
  cloned.triggers = extension.triggers
  return cloned
end function

function removeAt(values, index)
  output = []
  if len(values) > 1 then
    for i = 0 to len(values) - 1
      if i != index then output = output + [values[i]] end if
    end for
  end if
  return output
end function

function tableIndexByName(catalogState, name)
  if len(catalogState.tables) > 0 then
    for index = 0 to len(catalogState.tables) - 1
      if catalogState.tables[index].name == name then return index end if
    end for
  end if
  return -1
end function

function tableSchemaIndex(state, tableId)
  if len(state.tables) > 0 then
    for index = 0 to len(state.tables) - 1
      if state.tables[index].tableId == tableId then return index end if
    end for
  end if
  return -1
end function

function allocateId(preparedMetadata)
  value = preparedMetadata.nextObjectId
  if value >= endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "allocateId", "object ID space exhausted") end if
  preparedMetadata.nextObjectId = value + 1
  return value
end function

function generatedConstraintName(prefix, tableName, suffix)
  return prefix + "_" + tableName + "_" + suffix
end function

function columnExists(table, name)
  for each column in table.columns
    if column.name == name then return true end if
  end for
  return false
end function

function uniqueConstraintForColumns(tableSchemaValue, columns)
  if tableSchemaValue is void then return false end if
  for each value in tableSchemaValue.constraints
    if value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE then
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

function appendConstraint(preparedMetadata, tableName, tableSchemaValue, value)
  if value.kind == CONSTRAINT_PRIMARY_KEY or value.kind == CONSTRAINT_UNIQUE or value.kind == CONSTRAINT_INDEX then
    value.indexId = allocateId(preparedMetadata)
    if len(value.indexName) == 0 then value.indexName = generatedConstraintName("idx", tableName, "" + value.indexId) end if
  end if
  tableSchemaValue.constraints = tableSchemaValue.constraints + [value]
  return value
end function

function catalogTableById(catalogState, tableId)
  for each table in catalogState.tables
    if table.tableId == tableId then return table end if
  end for
  return void
end function

function columnIndexByName(table, name)
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      if table.columns[index].name == name then return index end if
    end for
  end if
  return -1
end function

function stringArrayReplace(values, oldValue, newValue)
  output = []
  for each value in values
    if value == oldValue then output = output + [newValue] else output = output + [value] end if
  end for
  return output
end function

function renameExpression(expression, oldName, newName)
  if ast.isColumnExpression(expression) then
    if expression.qualifier is void and expression.name == oldName then return ast.columnExpression(void, newName) end if
    return expression
  end if
  if ast.isLiteralExpression(expression) or ast.isStarExpression(expression) or ast.isParameterExpression(expression) then return expression end if
  if ast.isUnaryExpression(expression) then return ast.unaryExpression(expression.operator, renameExpression(expression.operand, oldName, newName)) end if
  if ast.isBinaryExpression(expression) then return ast.binaryExpression(expression.operator, renameExpression(expression.left, oldName, newName), renameExpression(expression.right, oldName, newName)) end if
  if ast.isIsNullExpression(expression) then return ast.isNullExpression(renameExpression(expression.operand, oldName, newName), expression.negated) end if
  if ast.isFunctionExpression(expression) then
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [renameExpression(argument, oldName, newName)]
    end for
    return ast.functionExpression(expression.name, arguments, expression.distinct)
  end if
  return expression
end function

function renameExpressionSql(sqlText, oldName, newName)
  if typeof(sqlText) != "string" or len(sqlText) == 0 then return sqlText end if
  return ast.formatExpression(renameExpression(parser.parseExpressionText(sqlText), oldName, newName))
end function

function sameStringArray(left, right)
  if typeof(left) != "array" or typeof(right) != "array" or len(left) != len(right) then return false end if
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      if left[index] != right[index] then return false end if
    end for
  end if
  return true
end function

function constraintNameExists(tableSchemaValue, name)
  for each value in tableSchemaValue.constraints
    if value.name == name or (len(value.indexName) > 0 and value.indexName == name) then return true end if
  end for
  return false
end function

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

function buildAlterTable(prepared, databasePath, bound)
  statement = bound.statement
  table = catalogTableById(prepared.newCatalog, bound.table.tableId)
  if table is void then return fail(OBJECT_NOT_FOUND, "buildAlterTable", "table no longer exists") end if
  tableSchemaValue = ensurePreparedTableSchema(prepared, table)
  if statement.action == ast.ALTER_TABLE_ADD_COLUMN then
    definition = statement.columnDefinition
    if columnIndexByName(table, definition.name) >= 0 then return fail(OBJECT_EXISTS, "buildAlterTable", "column already exists: " + definition.name) end if
    typeInfo = bound.columnType
    columnId = allocateId(prepared.newMetadata)
    table.columns = table.columns + [metadata.createColumn(columnId, definition.name, typeInfo.kind, typeInfo.nullable, typeInfo.length, typeInfo.precision, typeInfo.scale)]
    table.schemaVersion = table.schemaVersion + 1
    tableSchemaValue.schemaVersion = table.schemaVersion
    defaultSql = void
    if definition.defaultExpression is not void then defaultSql = ast.formatExpression(definition.defaultExpression) end if
    tableSchemaValue.columnRules = tableSchemaValue.columnRules + [columnRule(definition.name, defaultSql, false)]
    if definition.generatedExpression is not void then
      prepared.newState.generatedColumns = prepared.newState.generatedColumns + [generatedColumnDefinition(table.tableId, definition.name, ast.formatExpression(definition.generatedExpression), definition.generatedStored)]
    end if
    return true
  end if
  if statement.action == ast.ALTER_TABLE_RENAME_COLUMN then
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
          value.columns = stringArrayReplace(value.columns, statement.oldName, statement.newName)
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
  end if
  if statement.action == ast.ALTER_TABLE_RENAME_TABLE then
    if tableIndexByName(prepared.newCatalog, statement.newName) >= 0 then return fail(OBJECT_EXISTS, "buildAlterTable", "table already exists: " + statement.newName) end if
    oldName = table.name
    table.name = statement.newName
    for each schemaValue in prepared.newState.tables
      for each value in schemaValue.constraints
        if value.referenceTable == oldName then value.referenceTable = statement.newName end if
      end for
    end for
    return true
  end if
  if statement.action == ast.ALTER_TABLE_ADD_CONSTRAINT then
    source = statement.constraint
    if source.kind == CONSTRAINT_FOREIGN_KEY then
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
    end if
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
  end if
  if statement.action == ast.ALTER_TABLE_DROP_CONSTRAINT then
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
  end if
  return fail(UNSUPPORTED_SQL, "buildAlterTable", "unsupported ALTER TABLE action")
end function

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
  value = constraint(bound.statement.name, kind, bound.statement.columns, "", "", [], "NO ACTION", "NO ACTION", allocateId(prepared.newMetadata), bound.statement.name)
  schema.constraints = schema.constraints + [value]
  indexFinal = indexFilePath(databasePath, value.indexId)
  prepared.createFiles = prepared.createFiles + [CreateFilePlan(indexFinal + ".ddl.new", indexFinal, superblock.FILE_TYPE_INDEX, value.indexId, bound.statement.unique)]
  return true
end function

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

function begin(database)
  if not catalog.isDatabaseHandle(database) then return fail(INVALID_ARGUMENT, "begin", "database must be DatabaseHandle") end if
  if database.closed then return fail(CLOSED_HANDLE, "begin", "database is closed") end if
  return DdlTransaction(database, loadOrCreate(database.path, database.metadata.databaseId), [], true)
end function

function validateTransaction(transaction, operation)
  if transaction is not DdlTransaction then return fail(INVALID_ARGUMENT, operation, "transaction must be DdlTransaction") end if
  if not transaction.active then return fail(DDL_STATE, operation, "DDL transaction is not active") end if
  return true
end function

function stageCreateTable(transaction, bound)
  validateTransaction(transaction, "stageCreateTable")
  if not binder.isBoundCreateTable(bound) then return fail(INVALID_ARGUMENT, "stageCreateTable", "bound statement must be BoundCreateTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_CREATE_TABLE, bound)]
  return true
end function

function stageCreateIndex(transaction, bound)
  validateTransaction(transaction, "stageCreateIndex")
  if not binder.isBoundCreateIndex(bound) then return fail(INVALID_ARGUMENT, "stageCreateIndex", "bound statement must be BoundCreateIndex") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_CREATE_INDEX, bound)]
  return true
end function

function stageDropTable(transaction, bound)
  validateTransaction(transaction, "stageDropTable")
  if not binder.isBoundDropTable(bound) then return fail(INVALID_ARGUMENT, "stageDropTable", "bound statement must be BoundDropTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_DROP_TABLE, bound)]
  return true
end function

function stageAlterTable(transaction, bound)
  validateTransaction(transaction, "stageAlterTable")
  if not binder.isBoundAlterTable(bound) then return fail(INVALID_ARGUMENT, "stageAlterTable", "bound statement must be BoundAlterTable") end if
  transaction.actions = transaction.actions + [DdlAction(ACTION_ALTER_TABLE, bound)]
  return true
end function

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

function journalArraySize(values)
  total = 4
  for each value in values
    total = total + stringSize(value)
  end for
  return total
end function

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

function writeJournal(databasePath, value)
  writeAtomic(journalPath(databasePath), encodeJournal(value))
  return true
end function

function isMaintenanceJournal(value)
  return value is MaintenanceJournal
end function

function encodeMaintenance(value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "encodeMaintenance", "value must be MaintenanceJournal") end if
  if value.status != MAINTENANCE_PREPARED and value.status != MAINTENANCE_COMMITTED then return fail(INVALID_ARGUMENT, "encodeMaintenance", "invalid status") end if
  total = 8 + stringSize(value.originalPath) + stringSize(value.temporaryPath) + stringSize(value.backupPath)
  if total > MAX_SCHEMA_BYTES then return fail(INVALID_ARGUMENT, "encodeMaintenance", "maintenance journal is too large") end if
  payload = bytes(total, 0)
  endian.writeU32LE(payload, 0, value.status)
  endian.writeU32LE(payload, 4, 0)
  offset = 8
  offset = writeString(payload, offset, value.originalPath)
  offset = writeString(payload, offset, value.temporaryPath)
  offset = writeString(payload, offset, value.backupPath)
  return checksum.encodeEnvelope(maintenanceMagic(), FORMAT_VERSION, MAINTENANCE_KIND, 0, payload)
end function

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

function writeMaintenance(databasePath, value)
  writeAtomic(maintenancePath(databasePath), encodeMaintenance(value))
  return true
end function

function beginMaintenance(databasePath, originalPath, temporaryPath, backupPath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 or typeof(originalPath) != "string" or len(originalPath) == 0 or typeof(temporaryPath) != "string" or len(temporaryPath) == 0 or typeof(backupPath) != "string" or len(backupPath) == 0 then return fail(INVALID_ARGUMENT, "beginMaintenance", "paths must be non-empty strings") end if
  value = MaintenanceJournal(MAINTENANCE_PREPARED, originalPath, temporaryPath, backupPath)
  writeMaintenance(databasePath, value)
  return value
end function

function markMaintenanceCommitted(databasePath, value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "markMaintenanceCommitted", "value must be MaintenanceJournal") end if
  value.status = MAINTENANCE_COMMITTED
  writeMaintenance(databasePath, value)
  return true
end function

function finishMaintenance(databasePath, value)
  if value is not MaintenanceJournal then return fail(INVALID_ARGUMENT, "finishMaintenance", "value must be MaintenanceJournal") end if
  deleteIfExists(value.temporaryPath)
  deleteIfExists(value.backupPath)
  deleteIfExists(maintenancePath(databasePath))
  return true
end function

function recoverMaintenance(databasePath)
  path = maintenancePath(databasePath)
  if not file_api.fileExists(path) then return true end if
  value = decodeMaintenance(readWhole(path))
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

function deleteIfExists(path)
  if file_api.pathExists(path) then file_api.deletePath(path) end if
  return true
end function

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
  end if
  deleteIfExists(path)
  return true
end function

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

function cleanupCommitted(prepared, databasePath)
  for each plan in prepared.backups
    deleteIfExists(plan.backupPath)
  end for
  for each plan in prepared.createFiles
    deleteIfExists(plan.temporaryPath)
  end for
  deleteIfExists(journalPath(databasePath))
  return true
end function

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
  oldMeta = paged_file.snapshotDurableBytes(transaction.database.metaFile, MAX_SCHEMA_BYTES * 4)
  oldCatalog = paged_file.snapshotDurableBytes(transaction.database.catalogFile, MAX_SCHEMA_BYTES * 4)
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

function commit(transaction)
  return commitInternal(transaction, 0)
end function

function commitStoppingAfter(transaction, phase)
  // Test-only crash-injection seam. The caller exits without normal cleanup and
  // the next database_manager.open invokes recoverPending().
  return commitInternal(transaction, phase)
end function

function rollback(transaction)
  validateTransaction(transaction, "rollback")
  transaction.actions = []
  transaction.active = false
  return true
end function

function constraintsFor(databasePath, databaseId, tableId)
  state = loadOrCreate(databasePath, databaseId)
  table = findTableSchema(state, tableId)
  if table is void then return [] end if
  return table.constraints
end function

// ---------------------------------------------------------------------------
// M43-M45 schema extension sidecar
// ---------------------------------------------------------------------------

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
  if total > MAX_SCHEMA_BYTES then return fail(INVALID_ARGUMENT, "encodeExtensions", "schema extensions exceed 1 MiB") end if
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

function saveExtensions(databasePath, state)
  return writeAtomic(extensionPath(databasePath), encodeExtensions(state))
end function

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

function findView(state, name)
  for each view in state.views
    if view.name == name then return view end if
  end for
  return void
end function

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

function findSequence(state, name)
  for each sequence in state.sequences
    if sequence.name == name then return sequence end if
  end for
  return void
end function

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

function generatedForTable(state, tableId)
  output = []
  for each generated in state.generatedColumns
    if generated.tableId == tableId then output = output + [generated] end if
  end for
  return output
end function

function triggersForTable(state, tableId, eventType)
  output = []
  for each trigger in state.triggers
    if trigger.tableId == tableId and trigger.eventType == eventType and trigger.enabled then output = output + [trigger] end if
  end for
  return output
end function

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

function componentName()
  return "catalog.schema_history"
end function

function targetMilestone()
  return "M14"
end function

function isImplemented()
  return true
end function
