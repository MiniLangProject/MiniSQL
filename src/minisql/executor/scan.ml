package minisql.executor.scan

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.sql.binder as binder
import minisql.sql.expressions as expressions
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.overflow as overflow
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.row_codec as row_codec
import minisql.storage.slotted_page as slotted_page
import minisql.transaction.transaction as transaction

// Transaction-aware sequential table scan for the first executable SQL engine.
// A scan always consults private transaction pages before the committed base
// file, giving the session read-your-writes semantics without exposing those
// pages to other sessions before WAL commit.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const UNSUPPORTED_SQL = 9025

struct RowReference
  pageNumber
  slotId
  generation
end struct

struct ScannedRow
  reference
  values
end struct

struct TableReader
  databasePath
  table
  tableSchema
  generatedColumns
  file
  rowSchema
  pageTransaction
  ownsFile
  closed
end struct

function fail(code, operation, message)
  return error(code, "executor.scan." + operation + ": " + message)
end function

function isRowReference(value)
  return value is RowReference
end function

function isScannedRow(value)
  return value is ScannedRow
end function

function isTableReader(value)
  return value is TableReader
end function

function appendArrayValue(source, item, operation)
  if typeof(source) != "array" then return fail(INVALID_ARGUMENT, operation, "source must be array") end if
  result = array(len(source) + 1)
  if len(source) > 0 then
    for index = 0 to len(source) - 1
      result[index] = source[index]
    end for
  end if
  result[len(source)] = item
  return result
end function

function schemaForTable(table)
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "schemaForTable", "table must be TableMetadata") end if
  specifications = []
  for each column in table.columns
    specification = row_codec.column(column.typeCode, column.nullable, column.maxLength, column.precision, column.scale)
    specifications = appendArrayValue(specifications, specification, "schemaForTable")
  end for
  return row_codec.schema(table.schemaVersion, specifications)
end function

function open(databasePath, table, pageTransaction)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "open", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "open", "table must be TableMetadata") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.open") end if
  file = paged_file.open(catalog.tableFilePath(databasePath, table.tableId))
  state = schema_history.loadOrCreate(databasePath, file.databaseId)
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, true, false)
end function

function openExisting(databasePath, file, table, pageTransaction)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "openExisting", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "openExisting", "table must be TableMetadata") end if
  paged_file.validateOpen(file, "executor.scan.openExisting")
  if file.fileId != table.tableId then return fail(INVALID_ARGUMENT, "openExisting", "file/table identity mismatch") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.openExisting") end if
  state = schema_history.loadOrCreate(databasePath, file.databaseId)
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, false, false)
end function

function validateOpen(reader, operation)
  if reader is not TableReader then return fail(INVALID_ARGUMENT, operation, "reader must be TableReader") end if
  if reader.closed then return fail(CLOSED_HANDLE, operation, "reader is closed") end if
  paged_file.validateOpen(reader.file, "executor.scan." + operation)
  return true
end function

function visiblePage(reader, pageNumber)
  validateOpen(reader, "visiblePage")
  if typeof(pageNumber) != "int" or pageNumber < 0 or pageNumber >= reader.file.pageCount then return fail(INVALID_ARGUMENT, "visiblePage", "page number is outside table") end if
  if reader.pageTransaction is not void then
    privatePage = transaction.readPrivatePage(reader.pageTransaction, reader.table.tableId, pageNumber)
    if privatePage is not void then return privatePage end if
  end if
  return paged_file.readPage(reader.file, pageNumber)
end function

function findColumnRule(reader, columnName)
  if reader.tableSchema is void then return void end if
  for each rule in reader.tableSchema.columnRules
    if rule.columnName == columnName then return rule end if
  end for
  return void
end function

function evaluateDefault(rule, column)
  target = types.fromColumn(column)
  if rule is void or rule.defaultSql is void then return values.convert(values.nullValue(column.typeCode), target) end if
  expression = parser.parseExpressionText(rule.defaultSql)
  bound = binder.bindExpression(expression, void, void)
  return values.convert(expressions.evaluate(bound, expressions.rowContext([])), target)
end function

function findGenerated(reader, columnName)
  for each generated in reader.generatedColumns
    if generated.columnName == columnName then return generated end if
  end for
  return void
end function

function evaluateGenerated(reader, generated, column, currentValues)
  expression = parser.parseExpressionText(generated.expressionSql)
  bound = binder.bindExpression(expression, reader.table, void)
  evaluated = expressions.evaluate(bound, expressions.rowContext(currentValues))
  return values.convert(evaluated, types.fromColumn(column))
end function

function materializeStoredValue(reader, index, raw)
  column = reader.table.columns[index]
  if row_codec.isExternalValue(raw) then
    pointer = overflow.fromExternal(raw)
    data = overflow.read(reader.file, pointer)
    if row_codec.isTextType(column.typeCode) then
      textValue = decode(data)
      if typeof(textValue) != "string" then return fail(CORRUPT_DATA, "materializeStoredValue", "external TEXT is not valid UTF-8") end if
      return values.fromStorage(column.typeCode, textValue)
    end if
    return values.fromStorage(column.typeCode, data)
  end if
  return values.fromStorage(column.typeCode, raw)
end function

function decodeRecord(reader, encoded)
  decoded = row_codec.decodeCompatible(reader.rowSchema, encoded)
  storedCount = len(decoded.values)
  output = array(storedCount)
  if storedCount > 0 then
    for index = 0 to storedCount - 1
      storedValue = materializeStoredValue(reader, index, decoded.values[index])
      output[index] = storedValue
    end for
  end if
  if storedCount < len(reader.table.columns) then
    for index = storedCount to len(reader.table.columns) - 1
      column = reader.table.columns[index]
      generated = findGenerated(reader, column.name)
      if generated is not void then
        generatedValue = evaluateGenerated(reader, generated, column, output)
        output = appendArrayValue(output, generatedValue, "decodeRecord")
      else
        defaultValue = evaluateDefault(findColumnRule(reader, column.name), column)
        output = appendArrayValue(output, defaultValue, "decodeRecord")
      end if
    end for
  end if
  return output
end function

function all(reader)
  validateOpen(reader, "all")
  output = []
  if reader.file.pageCount == 0 then return output end if
  for pageNumber = 0 to reader.file.pageCount - 1
    pageBytes = visiblePage(reader, pageNumber)
    header = page.verify(pageBytes)
    if header.pageType == page.TYPE_OVERFLOW or header.pageType == page.TYPE_FREE then continue end if
    if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "all", "table page has wrong type") end if
    count = slotted_page.slotCount(pageBytes)
    if count > 0 then
      for slotId = 0 to count - 1
        current = slotted_page.entry(pageBytes, slotId)
        if current.flags == slotted_page.SLOT_FLAG_LIVE then
          rowValues = decodeRecord(reader, slotted_page.read(pageBytes, slotId))
          scanned = ScannedRow(RowReference(pageNumber, slotId, current.generation), rowValues)
          output = appendArrayValue(output, scanned, "all")
        end if
      end for
    end if
  end for
  return output
end function

function readReference(reader, reference)
  validateOpen(reader, "readReference")
  if reference is not RowReference then return fail(INVALID_ARGUMENT, "readReference", "reference must be RowReference") end if
  if reference.pageNumber < 0 or reference.pageNumber >= reader.file.pageCount then return void end if
  pageBytes = visiblePage(reader, reference.pageNumber)
  header = page.verify(pageBytes)
  if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "readReference", "table page has wrong type") end if
  if reference.slotId < 0 or reference.slotId >= slotted_page.slotCount(pageBytes) then return void end if
  current = slotted_page.entry(pageBytes, reference.slotId)
  if current.flags != slotted_page.SLOT_FLAG_LIVE or current.generation != reference.generation then return void end if
  rowValues = decodeRecord(reader, slotted_page.read(pageBytes, reference.slotId))
  return ScannedRow(reference, rowValues)
end function

function readTableReference(databasePath, table, pageTransaction, reference)
  reader = open(databasePath, table, pageTransaction)
  result = try(readReference(reader, reference))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

function count(reader)
  return len(all(reader))
end function

function close(reader)
  validateOpen(reader, "close")
  if reader.ownsFile then paged_file.close(reader.file) end if
  reader.closed = true
  return true
end function

function scanTable(databasePath, table, pageTransaction)
  reader = open(databasePath, table, pageTransaction)
  result = try(all(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

function scanExisting(databasePath, file, table, pageTransaction)
  reader = openExisting(databasePath, file, table, pageTransaction)
  result = try(all(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

function scanUsing(databasePath, table, pageTransaction, existingFile)
  if existingFile is void then return scanTable(databasePath, table, pageTransaction) end if
  if existingFile.fileId == table.tableId then return scanExisting(databasePath, existingFile, table, pageTransaction) end if
  return scanTable(databasePath, table, pageTransaction)
end function

function componentName()
  return "executor.scan"
end function

function targetMilestone()
  return "M15"
end function

function isImplemented()
  return true
end function
