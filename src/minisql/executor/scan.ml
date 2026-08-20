package minisql.executor.scan

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

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

// Groups the row reference state and preserves the field relationships documented below.
struct RowReference
  // Stores the page number associated with this value.
  pageNumber
  // Identifies the slot identifier.
  slotId
  // Stores the generation associated with this value.
  generation
end struct

// Groups the scanned row state and preserves the field relationships documented below.
struct ScannedRow
  // Stores the reference associated with this value.
  reference
  // Contains the ordered values collection.
  values
end struct

// Groups the table reader state and preserves the field relationships documented below.
struct TableReader
  // Stores the filesystem database path.
  databasePath
  // Stores the table associated with this value.
  table
  // Contains the ordered table schema collection.
  tableSchema
  // Stores the generated columns associated with this value.
  generatedColumns
  // Stores the filesystem file.
  file
  // Contains the ordered row schema collection.
  rowSchema
  // Stores the page transaction associated with this value.
  pageTransaction
  // Stores the filesystem owns file.
  ownsFile
  // Indicates whether the closed condition is active.
  closed
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.scan." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the row reference condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isRowReference(value)
  return value is RowReference
end function

// Returns whether the supplied value satisfies the scanned row condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isScannedRow(value)
  return value is ScannedRow
end function

// Returns whether the supplied value satisfies the table reader condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isTableReader(value)
  return value is TableReader
end function

// Appends array value using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements schema for table for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function schemaForTable(table)
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "schemaForTable", "table must be TableMetadata") end if
  specifications = []
  for each column in table.columns
    specification = row_codec.column(column.typeCode, column.nullable, column.maxLength, column.precision, column.scale)
    specifications = appendArrayValue(specifications, specification, "schemaForTable")
  end for
  return row_codec.schema(table.schemaVersion, specifications)
end function

// Opens open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function open(databasePath, table, pageTransaction)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "open", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "open", "table must be TableMetadata") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.open") end if
  file = paged_file.openReadOnly(catalog.tableFilePath(databasePath, table.tableId))
  state = schema_history.loadOrCreate(databasePath, file.databaseId)
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, true, false)
end function

// Opens existing using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
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

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function validateOpen(reader, operation)
  if reader is not TableReader then return fail(INVALID_ARGUMENT, operation, "reader must be TableReader") end if
  if reader.closed then return fail(CLOSED_HANDLE, operation, "reader is closed") end if
  paged_file.validateOpen(reader.file, "executor.scan." + operation)
  return true
end function

// Implements visible page for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function visiblePage(reader, pageNumber)
  validateOpen(reader, "visiblePage")
  if typeof(pageNumber) != "int" or pageNumber < 0 or pageNumber >= reader.file.pageCount then return fail(INVALID_ARGUMENT, "visiblePage", "page number is outside table") end if
  if reader.pageTransaction is not void then
    privatePage = transaction.readPrivatePage(reader.pageTransaction, reader.table.tableId, pageNumber)
    if privatePage is not void then return privatePage end if
  end if
  return paged_file.readPage(reader.file, pageNumber)
end function

// Finds column rule using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findColumnRule(reader, columnName)
  if reader.tableSchema is void then return void end if
  for each rule in reader.tableSchema.columnRules
    if rule.columnName == columnName then return rule end if
  end for
  return void
end function

// Evaluates default using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateDefault(rule, column)
  target = types.fromColumn(column)
  if rule is void or rule.defaultSql is void then return values.convert(values.nullValue(column.typeCode), target) end if
  expression = parser.parseExpressionText(rule.defaultSql)
  bound = binder.bindExpression(expression, void, void)
  return values.convert(expressions.evaluate(bound, expressions.rowContext([])), target)
end function

// Finds generated using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findGenerated(reader, columnName)
  for each generated in reader.generatedColumns
    if generated.columnName == columnName then return generated end if
  end for
  return void
end function

// Evaluates generated using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateGenerated(reader, generated, column, currentValues)
  expression = parser.parseExpressionText(generated.expressionSql)
  bound = binder.bindExpression(expression, reader.table, void)
  evaluated = expressions.evaluate(bound, expressions.rowContext(currentValues))
  return values.convert(evaluated, types.fromColumn(column))
end function

// Implements materialize stored value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Decodes record using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements all for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Reads reference using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Reads table reference using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function readTableReference(databasePath, table, pageTransaction, reference)
  reader = open(databasePath, table, pageTransaction)
  result = try(readReference(reader, reference))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Counts count using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function count(reader)
  return len(all(reader))
end function

// Closes close using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state and perform I/O through its dependencies.
function close(reader)
  validateOpen(reader, "close")
  if reader.ownsFile then paged_file.close(reader.file) end if
  reader.closed = true
  return true
end function

// Scans table using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function scanTable(databasePath, table, pageTransaction)
  reader = open(databasePath, table, pageTransaction)
  result = try(all(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Scans existing using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function scanExisting(databasePath, file, table, pageTransaction)
  reader = openExisting(databasePath, file, table, pageTransaction)
  result = try(all(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Scans using using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function scanUsing(databasePath, table, pageTransaction, existingFile)
  if existingFile is void then return scanTable(databasePath, table, pageTransaction) end if
  if existingFile.fileId == table.tableId then return scanExisting(databasePath, existingFile, table, pageTransaction) end if
  return scanTable(databasePath, table, pageTransaction)
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.scan"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M15"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
