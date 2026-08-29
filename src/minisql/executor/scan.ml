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
import minisql.storage.buffer_pool as buffer_pool
import minisql.storage.heap_file as heap_file
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.row_codec as row_codec
import minisql.storage.slotted_page as slotted_page
import minisql.transaction.transaction as transaction
import std.ds.list as list

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
  // Optional database-owned concurrent read cache.
  readCache
  // Indicates whether the closed condition is active.
  closed
end struct

// Holds a forward-only live-row scan. The cursor retains one heap page and one
// decoded row at a time; callers can therefore validate or consume tables whose
// total payload is much larger than the MiniLang heap.
struct TableRowCursor
  // Reader that supplies transaction visibility, schema, and overflow access.
  reader
  // Optional column mask used to avoid unrelated overflow payload reads.
  requiredColumns
  // Persistent-directory result containing physical heap page numbers only.
  heapPages
  // Index of the heap page currently being visited.
  pageIndex
  // Exclusive heap-page index at which this cursor stops. Keeping the bound in
  // the cursor lets independent read-only workers scan disjoint page ranges.
  endPageIndex
  // Checksummed bytes for the current heap page, or void between pages.
  pageBytes
  // Next slot to inspect within pageBytes.
  slotId
  // Indicates that every page and slot has been consumed.
  finished
end struct

// Bounded group of rows transferred between streaming physical operators.
// The batch itself owns no storage handles; rows remain ordinary ScannedRow
// values and may safely outlive the cursor.
struct RowBatch
  // Ordered rows contained in this bounded transfer unit.
  rows
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

// Returns whether value is a forward-only table row cursor.
function isTableRowCursor(value)
  return value is TableRowCursor
end function

// Reports whether a value is a bounded RowBatch.
function isRowBatch(value)
  return value is RowBatch
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
function openCached(databasePath, table, pageTransaction, readCache)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "open", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "open", "table must be TableMetadata") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.open") end if
  tablePath = catalog.tableFilePath(databasePath, table.tableId)
  file = try(paged_file.openReadOnly(tablePath))
  if typeof(file) == "error" then return fail(file.code, "open", "cannot open table file " + tablePath + ": " + file.message) end if
  state = try(schema_history.loadOrCreate(databasePath, file.databaseId))
  if typeof(state) == "error" then
    ignoredClose = try(paged_file.close(file))
    return fail(state.code, "open", "cannot load schema history: " + state.message)
  end if
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, true, readCache, false)
end function

// Opens a table using a database-owned immutable schema snapshot. Managed
// query execution uses this variant so point lookups do not reopen and verify
// schema.history. The paged table itself is still opened and validated here.
function openCachedWithSchema(databasePath, table, pageTransaction, readCache, state)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "openWithSchema", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "openWithSchema", "table must be TableMetadata") end if
  if not schema_history.isSchemaState(state) then return fail(INVALID_ARGUMENT, "openWithSchema", "state must be SchemaState") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.openWithSchema") end if
  tablePath = catalog.tableFilePath(databasePath, table.tableId)
  file = try(paged_file.openReadOnly(tablePath))
  if typeof(file) == "error" then return fail(file.code, "openWithSchema", "cannot open table file " + tablePath + ": " + file.message) end if
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, true, readCache, false)
end function

// Opens a table without a shared cache for storage tools and direct tests.
function open(databasePath, table, pageTransaction)
  return openCached(databasePath, table, pageTransaction, void)
end function

// Opens existing using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function openExistingCached(databasePath, file, table, pageTransaction, readCache)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "openExisting", "databasePath must be non-empty") end if
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "openExisting", "table must be TableMetadata") end if
  paged_file.validateOpen(file, "executor.scan.openExisting")
  if file.fileId != table.tableId then return fail(INVALID_ARGUMENT, "openExisting", "file/table identity mismatch") end if
  if pageTransaction is not void then transaction.validateTransaction(pageTransaction, "executor.scan.openExisting") end if
  state = schema_history.loadOrCreate(databasePath, file.databaseId)
  tableSchemaValue = schema_history.findTableSchema(state, table.tableId)
  generatedColumns = schema_history.generatedForTable(state, table.tableId)
  return TableReader(databasePath, table, tableSchemaValue, generatedColumns, file, schemaForTable(table), pageTransaction, false, readCache, false)
end function

// Opens a caller-owned file without a shared cache.
function openExisting(databasePath, file, table, pageTransaction)
  return openExistingCached(databasePath, file, table, pageTransaction, void)
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
  if reader.readCache is not void then return buffer_pool.readCached(reader.readCache, reader.file, pageNumber) end if
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

// Decodes one record while materializing only columns required by the query.
// Unused values retain a correctly typed SQL NULL placeholder so bound column
// indexes remain stable, but external TEXT/BLOB payloads are never fetched.
// Generated columns conservatively use the full decoder because their stored
// expressions may depend on columns that are not explicit in the SELECT list.
function decodeRecordColumns(reader, encoded, requiredColumns)
  if requiredColumns is void or len(reader.generatedColumns) > 0 then return decodeRecord(reader, encoded) end if
  if typeof(requiredColumns) != "array" or len(requiredColumns) != len(reader.table.columns) then return fail(INVALID_ARGUMENT, "decodeRecordColumns", "required column mask must match the table") end if
  decoded = row_codec.decodeCompatible(reader.rowSchema, encoded)
  storedCount = len(decoded.values)
  if storedCount > len(reader.table.columns) then return fail(CORRUPT_DATA, "decodeRecordColumns", "stored row has more columns than the catalog") end if
  output = array(len(reader.table.columns))
  if storedCount > 0 then
    for index = 0 to storedCount - 1
      column = reader.table.columns[index]
      if requiredColumns[index] then
        output[index] = materializeStoredValue(reader, index, decoded.values[index])
      else
        output[index] = values.nullValue(column.typeCode)
      end if
    end for
  end if
  if storedCount < len(reader.table.columns) then
    for index = storedCount to len(reader.table.columns) - 1
      column = reader.table.columns[index]
      if requiredColumns[index] then
        output[index] = evaluateDefault(findColumnRule(reader, column.name), column)
      else
        output[index] = values.nullValue(column.typeCode)
      end if
    end for
  end if
  return output
end function

// Creates a forward-only cursor over live rows. Heap-page discovery uses the
// persistent sidecar index, while each selected heap page is still checksum
// verified before any slot or overflow pointer is trusted.
function openCursor(reader, requiredColumns)
  validateOpen(reader, "openCursor")
  if requiredColumns is not void and (typeof(requiredColumns) != "array" or len(requiredColumns) != len(reader.table.columns)) then return fail(INVALID_ARGUMENT, "openCursor", "required column mask must match the table") end if
  heapPages = heap_file.heapPageNumbers(reader.file)
  return TableRowCursor(reader, requiredColumns, heapPages, 0, len(heapPages), void, 0, false)
end function

// Returns the number of physical heap pages advertised by the persistent page
// directory. Parallel operators use this metadata-only count to choose ranges.
function heapPageCount(reader)
  validateOpen(reader, "heapPageCount")
  return len(heap_file.heapPageNumbers(reader.file))
end function

// Creates a cursor over the half-open physical heap-page range [first, end).
// The range addresses entries in the persistent heap-page directory rather
// than raw file page numbers, so overflow and metadata pages are never scanned.
function openCursorRange(reader, requiredColumns, firstPageIndex, endPageIndex)
  validateOpen(reader, "openCursorRange")
  if requiredColumns is not void and (typeof(requiredColumns) != "array" or len(requiredColumns) != len(reader.table.columns)) then return fail(INVALID_ARGUMENT, "openCursorRange", "required column mask must match the table") end if
  heapPages = heap_file.heapPageNumbers(reader.file)
  if typeof(firstPageIndex) != "int" or typeof(endPageIndex) != "int" or firstPageIndex < 0 or endPageIndex < firstPageIndex or endPageIndex > len(heapPages) then return fail(INVALID_ARGUMENT, "openCursorRange", "page range is outside the heap-page directory") end if
  return TableRowCursor(reader, requiredColumns, heapPages, firstPageIndex, endPageIndex, void, 0, firstPageIndex == endPageIndex)
end function

// Returns the next live row or void at end-of-table. Advancing before returning
// makes repeated calls deterministic even when the caller immediately discards
// a multi-megabyte decoded payload.
function nextRow(cursor)
  if cursor is not TableRowCursor then return fail(INVALID_ARGUMENT, "nextRow", "cursor must be TableRowCursor") end if
  validateOpen(cursor.reader, "nextRow")
  if cursor.finished then return void end if
  while cursor.pageIndex < cursor.endPageIndex
    if cursor.pageBytes is void then
      pageNumber = cursor.heapPages[cursor.pageIndex]
      encoded = visiblePage(cursor.reader, pageNumber)
      header = page.verify(encoded)
      if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "nextRow", "table page has wrong type") end if
      cursor.pageBytes = encoded
      cursor.slotId = 0
    end if

    count = slotted_page.slotCount(cursor.pageBytes)
    while cursor.slotId < count
      currentSlot = cursor.slotId
      cursor.slotId = cursor.slotId + 1
      current = slotted_page.entry(cursor.pageBytes, currentSlot)
      if current.flags == slotted_page.SLOT_FLAG_LIVE then
        pageNumber = cursor.heapPages[cursor.pageIndex]
        rowValues = decodeRecordColumns(cursor.reader, slotted_page.read(cursor.pageBytes, currentSlot), cursor.requiredColumns)
        return ScannedRow(RowReference(pageNumber, currentSlot, current.generation), rowValues)
      end if
    end while

    cursor.pageIndex = cursor.pageIndex + 1
    cursor.pageBytes = void
    cursor.slotId = 0
  end while
  cursor.finished = true
  return void
end function

// Reads at most maximumRows from a forward-only cursor. A void result denotes
// end-of-input; every non-void batch contains at least one row.
function nextBatch(cursor, maximumRows)
  if cursor is not TableRowCursor or typeof(maximumRows) != "int" or maximumRows <= 0 then return fail(INVALID_ARGUMENT, "nextBatch", "invalid arguments") end if
  output = list.List.new()
  while output.len() < maximumRows
    row = try(nextRow(cursor))
    if typeof(row) == "error" then return row end if
    if row is void then break end if
    output.add(row)
  end while
  if output.len() == 0 then return void end if
  return RowBatch(output.toArray())
end function

// Fully decodes and validates every live row while retaining only one row. This
// includes external TEXT/BLOB chains, UTF-8 conversion, schema compatibility,
// generated/default column handling, page checksums, and slot generations.
function verifyAndCount(reader)
  validateOpen(reader, "verifyAndCount")
  cursor = openCursor(reader, void)
  rowCount = 0
  while true
    row = try(nextRow(cursor))
    if typeof(row) == "error" then return row end if
    if row is void then break end if
    rowCount = rowCount + 1
  end while
  return rowCount
end function

// Counts live slots without decoding row values. Every heap page still passes
// through transaction visibility, the shared cache, and page checksum checks;
// only row allocation, schema conversion, and overflow payload reads are skipped.
function countLiveRows(reader)
  validateOpen(reader, "countLiveRows")
  rowCount = 0
  heapPages = heap_file.heapPageNumbers(reader.file)
  for each pageNumber in heapPages
    pageBytes = visiblePage(reader, pageNumber)
    header = page.decodePageHeader(pageBytes)
    if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "countLiveRows", "table page has wrong type") end if
    count = slotted_page.slotCount(pageBytes)
    if count > 0 then
      for slotId = 0 to count - 1
        if slotted_page.entry(pageBytes, slotId).flags == slotted_page.SLOT_FLAG_LIVE then rowCount = rowCount + 1 end if
      end for
    end if
  end for
  return rowCount
end function

// Decodes at most `maximumRows` uniformly spaced live rows while visiting each
// heap page once. ANALYZE obtains the exact population from slot headers first,
// then uses this pass to bound external-value I/O and retained memory.
function sampleRows(reader, populationRows, maximumRows)
  validateOpen(reader, "sampleRows")
  if typeof(populationRows) != "int" or populationRows < 0 or typeof(maximumRows) != "int" or maximumRows <= 0 then return fail(INVALID_ARGUMENT, "sampleRows", "invalid arguments") end if
  if populationRows == 0 then return [] end if
  stride = 1
  spacingRemainder = 0
  spacingError = 0
  if populationRows > maximumRows then
    stride = populationRows / maximumRows
    spacingRemainder = populationRows - stride * maximumRows
  end if
  output = list.List.new()
  visibleIndex = 0
  nextSample = 0
  heapPages = heap_file.heapPageNumbers(reader.file)
  for each pageNumber in heapPages
    encoded = visiblePage(reader, pageNumber)
    header = page.verify(encoded)
    if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "sampleRows", "table page has wrong type") end if
    count = slotted_page.slotCount(encoded)
    if count > 0 then
      for slotId = 0 to count - 1
        current = slotted_page.entry(encoded, slotId)
        if current.flags == slotted_page.SLOT_FLAG_LIVE then
          if visibleIndex == nextSample and output.len() < maximumRows then
            rowValues = decodeRecord(reader, slotted_page.read(encoded, slotId))
            output.add(ScannedRow(RowReference(pageNumber, slotId, current.generation), rowValues))
            nextSample = nextSample + stride
            spacingError = spacingError + spacingRemainder
            if spacingError >= maximumRows then nextSample = nextSample + 1; spacingError = spacingError - maximumRows end if
          end if
          visibleIndex = visibleIndex + 1
        end if
      end for
    end if
  end for
  return output.toArray()
end function

// Opens, streams, and closes one table for the offline consistency checker.
function verifyTable(databasePath, table, pageTransaction)
  reader = open(databasePath, table, pageTransaction)
  if typeof(reader) == "error" then return reader end if
  result = try(verifyAndCount(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Implements all for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function allRangeColumns(reader, offset, limit, requiredColumns)
  validateOpen(reader, "allRangeColumns")
  if typeof(offset) != "int" or offset < 0 then return fail(INVALID_ARGUMENT, "allRange", "offset must be non-negative") end if
  if typeof(limit) != "int" or limit < -1 then return fail(INVALID_ARGUMENT, "allRange", "limit must be -1 or non-negative") end if
  if requiredColumns is not void and (typeof(requiredColumns) != "array" or len(requiredColumns) != len(reader.table.columns)) then return fail(INVALID_ARGUMENT, "allRange", "required column mask must match the table") end if
  if limit == 0 then return [] end if
  if reader.file.pageCount == 0 then return [] end if
  // A growable buffer keeps appends amortized O(1) while allowing each page to
  // be read and checksum-verified only once. The former exact pre-count pass
  // doubled I/O and CRC work for every sequential SELECT.
  output = list.List.new()
  visibleRows = 0
  // The persistent directory contains only physical heap pages. Large TEXT/BLOB
  // overflow regions therefore no longer consume one read and CRC verification
  // per page during every table scan.
  heapPages = heap_file.heapPageNumbers(reader.file)
  for each pageNumber in heapPages
    pageBytes = visiblePage(reader, pageNumber)
    header = page.decodePageHeader(pageBytes)
    if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "all", "table page has wrong type") end if
    count = slotted_page.slotCount(pageBytes)
    if count > 0 then
      for slotId = 0 to count - 1
        current = slotted_page.entry(pageBytes, slotId)
        if current.flags == slotted_page.SLOT_FLAG_LIVE then
          if visibleRows >= offset then
            rowValues = decodeRecordColumns(reader, slotted_page.read(pageBytes, slotId), requiredColumns)
            output.add(ScannedRow(RowReference(pageNumber, slotId, current.generation), rowValues))
            if limit >= 0 and output.len() >= limit then return output.toArray() end if
          end if
          visibleRows = visibleRows + 1
        end if
      end for
    end if
  end for
  return output.toArray()
end function

// Scans a physical live-row range and materializes all columns.
function allRange(reader, offset, limit)
  return allRangeColumns(reader, offset, limit, void)
end function

// Materializes every live row. The range implementation is shared with
// LIMIT/OFFSET scans so checksum verification and transaction visibility have
// one implementation.
function all(reader)
  return allRange(reader, 0, -1)
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

// Scans only a physical live-row range and stops as soon as the requested
// number of rows has been decoded. This bounds memory for simple paginated
// SELECT statements and avoids reading overflow values outside the page.
function scanTableRange(databasePath, table, pageTransaction, offset, limit)
  reader = open(databasePath, table, pageTransaction)
  result = try(allRange(reader, offset, limit))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Scans a range while fetching only columns referenced by the bound query.
function scanTableRangeColumns(databasePath, table, pageTransaction, offset, limit, requiredColumns)
  reader = open(databasePath, table, pageTransaction)
  result = try(allRangeColumns(reader, offset, limit, requiredColumns))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Uses the database-owned concurrent page cache together with range and
// projection pushdown. The reader handle remains short-lived; cache frames are
// keyed only by stable path and page number.
function scanTableRangeColumnsCached(databasePath, table, pageTransaction, offset, limit, requiredColumns, readCache)
  reader = openCached(databasePath, table, pageTransaction, readCache)
  result = try(allRangeColumns(reader, offset, limit, requiredColumns))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Opens a short-lived cached reader and returns only its number of visible rows.
function countTableRowsCached(databasePath, table, pageTransaction, readCache)
  tablePath = catalog.tableFilePath(databasePath, table.tableId)
  if pageTransaction is void and readCache is not void then
    cached = try(buffer_pool.cachedRowCount(readCache, tablePath))
    if typeof(cached) == "error" then return cached end if
    if typeof(cached) == "int" then return cached end if
  end if
  reader = openCached(databasePath, table, pageTransaction, readCache)
  result = try(countLiveRows(reader))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  if pageTransaction is void and readCache is not void then
    remembered = try(buffer_pool.rememberRowCount(readCache, tablePath, result))
    if typeof(remembered) == "error" then return remembered end if
  end if
  return result
end function

// Opens one cached reader for the bounded ANALYZE sampling pass.
function sampleTableRowsCached(databasePath, table, populationRows, maximumRows, readCache)
  reader = openCached(databasePath, table, void, readCache)
  result = try(sampleRows(reader, populationRows, maximumRows))
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

// Applies a bounded range scan to a caller-owned paged file.
function scanExistingRange(databasePath, file, table, pageTransaction, offset, limit)
  reader = openExisting(databasePath, file, table, pageTransaction)
  result = try(allRange(reader, offset, limit))
  closeResult = try(close(reader))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Applies both range and column pushdown to a caller-owned paged file.
function scanExistingRangeColumns(databasePath, file, table, pageTransaction, offset, limit, requiredColumns)
  reader = openExisting(databasePath, file, table, pageTransaction)
  result = try(allRangeColumns(reader, offset, limit, requiredColumns))
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

// Selects the bounded scan implementation for an optional caller-owned file.
function scanUsingRange(databasePath, table, pageTransaction, existingFile, offset, limit)
  if existingFile is void then return scanTableRange(databasePath, table, pageTransaction, offset, limit) end if
  if existingFile.fileId == table.tableId then return scanExistingRange(databasePath, existingFile, table, pageTransaction, offset, limit) end if
  return scanTableRange(databasePath, table, pageTransaction, offset, limit)
end function

// Scans all rows but materializes only the supplied table-column mask.
function scanUsingColumns(databasePath, table, pageTransaction, existingFile, requiredColumns)
  if existingFile is void then return scanTableRangeColumns(databasePath, table, pageTransaction, 0, -1, requiredColumns) end if
  if existingFile.fileId == table.tableId then return scanExistingRangeColumns(databasePath, existingFile, table, pageTransaction, 0, -1, requiredColumns) end if
  return scanTableRangeColumns(databasePath, table, pageTransaction, 0, -1, requiredColumns)
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
