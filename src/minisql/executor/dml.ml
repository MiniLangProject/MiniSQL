package minisql.executor.dml

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.ds.hashmap as hashmap
import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.executor.scan as scan
import minisql.sql.ast as ast
import minisql.sql.binder as binder
import minisql.sql.expressions as expressions
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.btree as btree
import minisql.storage.heap_file as heap_file
import minisql.storage.overflow as overflow
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.row_codec as row_codec
import minisql.storage.slotted_page as slotted_page
import minisql.transaction.checkpoint as checkpoint
import minisql.transaction.transaction as transaction
import minisql.transaction.wal as wal

// Basic transactional DML. Every changed heap page is private until the WAL
// commit succeeds. Publishing pages after commit is redo-safe: a publication
// failure is repaired by the already accepted M7 recovery path on next open.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const TRANSACTION_STATE = 9011
const READ_ONLY_VIOLATION = 9012
const OBJECT_NOT_FOUND = 9014
const PAGE_FULL = 9015
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020
const CONSTRAINT_VIOLATION = 9021
const DUPLICATE_KEY = 9022
const UNSUPPORTED_SQL = 9025

// Groups the DML result state and preserves the field relationships documented below.
struct DmlResult
  // Stores the affected rows associated with this value.
  affectedRows
  // Stores the references associated with this value.
  references
  // Contains the ordered rows collection.
  rows
  // Stores the old rows associated with this value.
  oldRows
  // Stores the new rows associated with this value.
  newRows
end struct

// Groups the conflict match state and preserves the field relationships documented below.
struct ConflictMatch
  // Stores the reference associated with this value.
  reference
  // Contains the ordered values collection.
  values
  // Stores the constraint associated with this value.
  constraint
end struct

// Tracks the last heap page considered by a statement-local bulk insert.
struct InsertCursor
  // First page that can still have capacity during the current insert batch.
  pageNumber
  // Maximum number of empty heap pages reserved by one durability barrier.
  allocationBatch
  // Rows not yet staged, used to avoid reserving unused tail pages.
  remainingRows
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.dml." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the DML result condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isDmlResult(value)
  return value is DmlResult
end function

// Returns whether the supplied value satisfies the conflict match condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isConflictMatch(value)
  return value is ConflictMatch
end function

// Implements same reference for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sameReference(left, right)
  if left is void or right is void then return false end if
  if not scan.isRowReference(left) or not scan.isRowReference(right) then return false end if
  return left.pageNumber == right.pageNumber and left.slotId == right.slotId and left.generation == right.generation
end function

// Implements visible page for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function visiblePage(pageTransaction, file, tableId, pageNumber)
  if pageTransaction is not void then
    privatePage = transaction.readPrivatePage(pageTransaction, tableId, pageNumber)
    if privatePage is not void then return privatePage end if
  end if
  return paged_file.readPage(file, pageNumber)
end function

// Scans rows using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function scanRows(database, table, pageTransaction, existingFile)
  if existingFile is not void and existingFile.fileId == table.tableId then
    return scan.scanUsing(database.path, table, pageTransaction, existingFile)
  end if
  return scan.scanTable(database.path, table, pageTransaction)
end function

// Scans rows while retaining only columns needed by a constraint check.
function scanRowsColumns(database, table, pageTransaction, existingFile, requiredColumns)
  return scan.scanUsingColumns(database.path, table, pageTransaction, existingFile, requiredColumns)
end function

// Builds a table-width mask for one or more unique constraints.
function constraintColumnMask(table, constraints)
  mask = array(len(table.columns), false)
  for each constraint in constraints
    for each columnName in constraint.columns
      index = binder.findColumnIndex(table, columnName)
      if index < 0 then return fail(CORRUPT_DATA, "constraintColumnMask", "constraint references missing column") end if
      mask[index] = true
    end for
  end for
  return mask
end function

// Implements storage row for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function storageRow(rowSchema, table, sqlValues, file, ownerId)
  raw = array(len(sqlValues))
  if len(sqlValues) > 0 then
    for index = 0 to len(sqlValues) - 1
      value = sqlValues[index]
      stored = values.toStorage(value)
      typeCode = table.columns[index].typeCode
      if not value.isNull and (typeCode == types.SqlTypeKind.Text or typeCode == types.SqlTypeKind.Blob) then
        data = stored
        if typeof(data) == "string" then data = bytes(data) end if
        if len(data) > (file.pageSize >> 2) then stored = overflow.toExternal(overflow.write(file, ownerId, data)) end if
      end if
      raw[index] = stored
    end for
  end if
  return row_codec.encodeRow(rowSchema, raw)
end function

// Implements stage insert for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function stageInsert(pageTransaction, file, table, encodedRow)
  if typeof(encodedRow) != "bytes" or len(encodedRow) == 0 then return fail(INVALID_ARGUMENT, "stageInsert", "encoded row must be non-empty bytes") end if
  heapPages = heap_file.heapPageNumbers(file)
  if len(heapPages) > 0 then
    for each pageNumber in heapPages
      working = bytes(visiblePage(pageTransaction, file, table.tableId, pageNumber))
      header = page.decodePageHeader(working)
      if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "stageInsert", "heap-page directory references a non-heap page") end if
      inserted = try(slotted_page.insert(working, encodedRow))
      if typeof(inserted) != "error" then
        transaction.stagePage(pageTransaction, table.tableId, pageNumber, working)
        generation = slotted_page.entryGeneration(working, inserted)
        return scan.RowReference(pageNumber, inserted, generation)
      end if
      if inserted.code != PAGE_FULL then return inserted end if
    end for
  end if
  pageNumber = paged_file.allocatePage(file, page.TYPE_HEAP)
  working = paged_file.readPage(file, pageNumber)
  slotId = slotted_page.insert(working, encodedRow)
  transaction.stagePage(pageTransaction, table.tableId, pageNumber, working)
  return scan.RowReference(pageNumber, slotId, slotted_page.entryGeneration(working, slotId))
end function

// Stages one row while advancing a statement-local heap cursor. Pages before
// the cursor were already proven full and cannot gain space during an insert-only
// batch, so each heap page is visited only a bounded number of times.
function stageInsertWithCursor(pageTransaction, file, table, encodedRow, cursor)
  if cursor is not InsertCursor then return fail(INVALID_ARGUMENT, "stageInsertWithCursor", "cursor must be InsertCursor") end if
  if typeof(encodedRow) != "bytes" or len(encodedRow) == 0 then return fail(INVALID_ARGUMENT, "stageInsertWithCursor", "encoded row must be non-empty bytes") end if
  startPage = cursor.pageNumber
  if startPage < 0 then startPage = 0 end if
  // The cursor normally names the current heap page, so try it before loading
  // or extending the persistent directory. Overflow writes may have grown the
  // physical file since the prior row while this page still has free space.
  if startPage < file.pageCount then
    working = bytes(visiblePage(pageTransaction, file, table.tableId, startPage))
    header = page.decodePageHeader(working)
    if header.pageType == page.TYPE_HEAP then
      inserted = try(slotted_page.insert(working, encodedRow))
      if typeof(inserted) != "error" then
        transaction.stagePage(pageTransaction, table.tableId, startPage, working)
        cursor.pageNumber = startPage
        cursor.remainingRows = cursor.remainingRows - 1
        return scan.RowReference(startPage, inserted, slotted_page.entryGeneration(working, inserted))
      end if
      if inserted.code != PAGE_FULL then return inserted end if
    end if
    startPage = startPage + 1
  end if
  heapPages = heap_file.heapPageNumbers(file)
  for each pageNumber in heapPages
    if pageNumber < startPage then continue end if
    working = bytes(visiblePage(pageTransaction, file, table.tableId, pageNumber))
    header = page.decodePageHeader(working)
    if header.pageType != page.TYPE_HEAP then return fail(CORRUPT_DATA, "stageInsertWithCursor", "heap-page directory references a non-heap page") end if
    inserted = try(slotted_page.insert(working, encodedRow))
    if typeof(inserted) != "error" then
      transaction.stagePage(pageTransaction, table.tableId, pageNumber, working)
      cursor.pageNumber = pageNumber
      cursor.remainingRows = cursor.remainingRows - 1
      return scan.RowReference(pageNumber, inserted, slotted_page.entryGeneration(working, inserted))
    end if
    if inserted.code != PAGE_FULL then return inserted end if
    cursor.pageNumber = pageNumber + 1
  end for
  allocationCount = cursor.allocationBatch
  if allocationCount > cursor.remainingRows then allocationCount = cursor.remainingRows end if
  if allocationCount < 1 then allocationCount = 1 end if
  pageNumber = paged_file.allocatePages(file, page.TYPE_HEAP, allocationCount)
  working = paged_file.readPage(file, pageNumber)
  slotId = slotted_page.insert(working, encodedRow)
  transaction.stagePage(pageTransaction, table.tableId, pageNumber, working)
  cursor.pageNumber = pageNumber
  cursor.remainingRows = cursor.remainingRows - 1
  return scan.RowReference(pageNumber, slotId, slotted_page.entryGeneration(working, slotId))
end function

// Implements stage delete for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function stageDelete(pageTransaction, file, table, reference)
  if not scan.isRowReference(reference) then return fail(INVALID_ARGUMENT, "stageDelete", "reference must be RowReference") end if
  working = bytes(visiblePage(pageTransaction, file, table.tableId, reference.pageNumber))
  current = slotted_page.entry(working, reference.slotId)
  if current.generation != reference.generation then return fail(CORRUPT_DATA, "stageDelete", "row generation changed") end if
  slotted_page.remove(working, reference.slotId)
  transaction.stagePage(pageTransaction, table.tableId, reference.pageNumber, working)
  return true
end function

// Implements stage update for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function stageUpdate(pageTransaction, file, table, reference, encodedRow)
  if not scan.isRowReference(reference) then return fail(INVALID_ARGUMENT, "stageUpdate", "reference must be RowReference") end if
  working = bytes(visiblePage(pageTransaction, file, table.tableId, reference.pageNumber))
  current = slotted_page.entry(working, reference.slotId)
  if current.generation != reference.generation then return fail(CORRUPT_DATA, "stageUpdate", "row generation changed") end if
  updated = try(slotted_page.update(working, reference.slotId, encodedRow))
  if typeof(updated) != "error" then
    transaction.stagePage(pageTransaction, table.tableId, reference.pageNumber, working)
    return reference
  end if
  if updated.code != PAGE_FULL then return updated end if
  slotted_page.remove(working, reference.slotId)
  transaction.stagePage(pageTransaction, table.tableId, reference.pageNumber, working)
  return stageInsert(pageTransaction, file, table, encodedRow)
end function

// Implements table schema state for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function tableSchemaState(database, table)
  state = schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
  return schema_history.findTableSchema(state, table.tableId)
end function

// Implements schema state for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function schemaState(database)
  return schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
end function

// Implements generated columns for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function generatedColumns(database, table)
  return schema_history.generatedForTable(schemaState(database), table.tableId)
end function

// Finds generated using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findGenerated(database, table, columnName)
  for each generated in generatedColumns(database, table)
    if generated.columnName == columnName then return generated end if
  end for
  return void
end function

// Applies generated using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function applyGenerated(database, table, row)
  for each generated in generatedColumns(database, table)
    columnIndex = binder.findColumnIndex(table, generated.columnName)
    if columnIndex < 0 then return fail(CORRUPT_DATA, "applyGenerated", "generated column is missing from table metadata") end if
    parsed = parser.parseExpressionText(generated.expressionSql)
    bound = binder.bindExpression(parsed, table, void)
    evaluated = expressions.evaluate(bound, expressions.rowContext(row))
    row[columnIndex] = values.convert(evaluated, types.fromColumn(table.columns[columnIndex]))
  end for
  return row
end function

// Finds rule using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findRule(tableSchemaValue, columnName)
  if tableSchemaValue is void then return void end if
  for each rule in tableSchemaValue.columnRules
    if rule.columnName == columnName then return rule end if
  end for
  return void
end function

// Evaluates constant SQL using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateConstantSql(sqlText)
  expression = parser.parseExpressionText(sqlText)
  bound = binder.bindExpression(expression, void, void)
  return expressions.evaluate(bound, expressions.rowContext([]))
end function

// Implements next identity for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nextIdentity(database, table, columnIndex, pageTransaction, file)
  rows = scan.scanUsing(database.path, table, pageTransaction, file)
  maximum = 0
  found = false
  for each row in rows
    candidate = row.values[columnIndex]
    if not candidate.isNull then
      scalar = values.asNumber(candidate)
      if not found or scalar > maximum then maximum = scalar; found = true end if
    end if
  end for
  nextValue = 1
  if found then nextValue = maximum + 1 end if
  return values.convert(values.integer(nextValue), types.fromColumn(table.columns[columnIndex]))
end function

// Implements initial row for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function initialRow(database, bound, boundRow, pageTransaction, file)
  table = bound.table
  row = array(len(table.columns))
  provided = array(len(table.columns), false)
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      row[index] = values.nullValue(table.columns[index].typeCode)
    end for
  end if
  if len(bound.columnIndexes) > 0 then
    for index = 0 to len(bound.columnIndexes) - 1
      columnIndex = bound.columnIndexes[index]
      if findGenerated(database, table, table.columns[columnIndex].name) is not void then return fail(CONSTRAINT_VIOLATION, "initialRow", "explicit value for generated column " + table.columns[columnIndex].name) end if
      target = types.fromColumn(table.columns[columnIndex])
      row[columnIndex] = values.convert(expressions.evaluate(boundRow[index], expressions.rowContext([])), target)
      provided[columnIndex] = true
    end for
  end if
  schema = tableSchemaState(database, table)
  if len(table.columns) > 0 then
    for index = 0 to len(table.columns) - 1
      rule = findRule(schema, table.columns[index].name)
      if rule is not void and rule.identity then
        if provided[index] then return fail(CONSTRAINT_VIOLATION, "initialRow", "explicit value for GENERATED ALWAYS identity column " + table.columns[index].name) end if
        row[index] = nextIdentity(database, table, index, pageTransaction, file)
      else if not provided[index] and rule is not void and rule.defaultSql is not void then
        row[index] = values.convert(evaluateConstantSql(rule.defaultSql), types.fromColumn(table.columns[index]))
      else if not provided[index] then
        row[index] = values.convert(values.nullValue(table.columns[index].typeCode), types.fromColumn(table.columns[index]))
      end if
    end for
  end if
  applyGenerated(database, table, row)
  return row
end function

// Implements constraint key for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function constraintKey(row, table, constraint)
  output = array(len(constraint.columns))
  if len(constraint.columns) > 0 then
    for keyIndex = 0 to len(constraint.columns) - 1
      index = binder.findColumnIndex(table, constraint.columns[keyIndex])
      if index < 0 then return fail(CORRUPT_DATA, "constraintKey", "constraint references missing column") end if
      output[keyIndex] = row[index]
    end for
  end if
  return output
end function

// Implements key has null for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function keyHasNull(key)
  for each value in key
    if value.isNull then return true end if
  end for
  return false
end function

// Implements keys equal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function keysEqual(left, right)
  if len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index].isNull or right[index].isNull then return false end if
    if values.compareNonNull(left[index], right[index]) != 0 then return false end if
  end for
  return true
end function

// Validates check using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateCheck(table, constraint, row)
  expression = parser.parseExpressionText(constraint.expressionSql)
  bound = binder.bindExpression(expression, table, void)
  if not expressions.checkPasses(bound, expressions.rowContext(row)) then return fail(CONSTRAINT_VIOLATION, "validateCheck", "CHECK constraint failed: " + constraint.name) end if
  return true
end function

// Validates unique using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateUnique(database, table, constraint, row, pageTransaction, excludedReference, file)
  key = constraintKey(row, table, constraint)
  if constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY and keyHasNull(key) then return fail(CONSTRAINT_VIOLATION, "validateUnique", "PRIMARY KEY contains NULL: " + constraint.name) end if
  if keyHasNull(key) then return true end if
  existingRows = scanRowsColumns(database, table, pageTransaction, file, constraintColumnMask(table, [constraint]))
  for each existing in existingRows
    if excludedReference is void or not sameReference(existing.reference, excludedReference) then
      if keysEqual(key, constraintKey(existing.values, table, constraint)) then return fail(DUPLICATE_KEY, "validateUnique", "duplicate key for " + constraint.name) end if
    end if
  end for
  return true
end function

// Validates foreign key using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateForeignKey(database, table, constraint, row, pageTransaction, file)
  key = constraintKey(row, table, constraint)
  if keyHasNull(key) then return true end if
  referencedTable = catalog.findTable(database.catalogHandle, constraint.referenceTable)
  if referencedTable is void then return fail(CORRUPT_DATA, "validateForeignKey", "referenced table is missing") end if
  referencedRows = scanRows(database, referencedTable, pageTransaction, file)
  for each referenced in referencedRows
    referencedKey = []
    for each columnName in constraint.referenceColumns
      index = binder.findColumnIndex(referencedTable, columnName)
      if index < 0 then return fail(CORRUPT_DATA, "validateForeignKey", "referenced column is missing") end if
      referencedKey = referencedKey + [referenced.values[index]]
    end for
    if keysEqual(key, referencedKey) then return true end if
  end for
  return fail(CONSTRAINT_VIOLATION, "validateForeignKey", "foreign key failed: " + constraint.name)
end function

// Validates row using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateRow(database, table, row, pageTransaction, excludedReference, file)
  if typeof(row) != "array" or len(row) != len(table.columns) then return fail(INVALID_ARGUMENT, "validateRow", "row shape mismatch") end if
  for index = 0 to len(table.columns) - 1
    // Conversion performs all type, length and NOT NULL checks.
    row[index] = values.convert(row[index], types.fromColumn(table.columns[index]))
  end for
  schema = tableSchemaState(database, table)
  if schema is void then return row end if
  for each constraint in schema.constraints
    if constraint.kind == schema_history.CONSTRAINT_CHECK then
      validateCheck(table, constraint, row)
    else if constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY or constraint.kind == schema_history.CONSTRAINT_UNIQUE then
      validateUnique(database, table, constraint, row, pageTransaction, excludedReference, file)
    else if constraint.kind == schema_history.CONSTRAINT_FOREIGN_KEY then
      validateForeignKey(database, table, constraint, row, pageTransaction, file)
    end if
  end for
  return row
end function

// Validates all unique keys for a statement from one stable table snapshot.
// Precomputed keys remove the repeated full heap scan previously performed for
// every inserted row while retaining SQL NULL and primary-key semantics.
function validateUniqueBatch(database, table, rows, pageTransaction, file)
  constraints = uniqueConstraints(database, table)
  if len(constraints) == 0 or len(rows) == 0 then return true end if
  existingRows = scanRowsColumns(database, table, pageTransaction, file, constraintColumnMask(table, constraints))
  for each constraint in constraints
    seen = hashmap.HashMap.new()
    if len(existingRows) > 0 then
      for existingIndex = 0 to len(existingRows) - 1
        existingKey = constraintKey(existingRows[existingIndex].values, table, constraint)
        if not keyHasNull(existingKey) then seen.set(encodeConstraintHashKey(existingKey), true) end if
      end for
    end if
    for rowIndex = 0 to len(rows) - 1
      key = constraintKey(rows[rowIndex], table, constraint)
      if constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY and keyHasNull(key) then return fail(CONSTRAINT_VIOLATION, "validateUniqueBatch", "PRIMARY KEY contains NULL: " + constraint.name) end if
      if not keyHasNull(key) then
        encoded = encodeConstraintHashKey(key)
        if seen.has(encoded) then return fail(DUPLICATE_KEY, "validateUniqueBatch", "duplicate key for " + constraint.name) end if
        seen.set(encoded, true)
      end if
    end for
  end for
  return true
end function

// Returns whether identity allocation requires sequential visibility of rows
// inserted earlier in the same statement.
function hasIdentityColumn(database, table)
  schema = tableSchemaState(database, table)
  if schema is void then return false end if
  for each rule in schema.columnRules
    if rule.identity then return true end if
  end for
  return false
end function

// Inserts a conflict-free batch using fixed-size result buffers and one unique
// snapshot. Other constraints are checked again in insertion order so foreign
// keys may still reference a preceding row from the same SQL statement.
function insertBatchWithoutConflict(database, bound, pageTransaction, file)
  preparedRows = array(len(bound.rows))
  if len(bound.rows) > 0 then
    for rowIndex = 0 to len(bound.rows) - 1
      row = initialRow(database, bound, bound.rows[rowIndex], pageTransaction, file)
      // Conversion and CHECK validation do not depend on insertion order.
      if typeof(row) != "array" or len(row) != len(bound.table.columns) then return fail(INVALID_ARGUMENT, "insertBatchWithoutConflict", "row shape mismatch") end if
      for columnIndex = 0 to len(bound.table.columns) - 1
        row[columnIndex] = values.convert(row[columnIndex], types.fromColumn(bound.table.columns[columnIndex]))
      end for
      schema = tableSchemaState(database, bound.table)
      if schema is not void then
        for each constraint in schema.constraints
          if constraint.kind == schema_history.CONSTRAINT_CHECK then validateCheck(bound.table, constraint, row) end if
        end for
      end if
      preparedRows[rowIndex] = row
    end for
  end if
  validateUniqueBatch(database, bound.table, preparedRows, pageTransaction, file)
  references = array(len(preparedRows))
  returnedRows = []
  if len(bound.returning) > 0 then returnedRows = array(len(preparedRows)) end if
  rowSchema = scan.schemaForTable(bound.table)
  cursorStart = 0
  allocationBatch = 1
  // Reserve heap pages in one durable allocation once a statement is large
  // enough to amortize the metadata barrier. A 32-row floor also benefits wide
  // rows that occupy one page each without changing small OLTP statements.
  if len(preparedRows) >= 32 then
    allocationBatch = 256
    cursorStart = file.pageCount - 1
    if cursorStart < 0 then cursorStart = 0 end if
  end if
  insertCursor = InsertCursor(cursorStart, allocationBatch, len(preparedRows))
  if len(preparedRows) > 0 then
    for rowIndex = 0 to len(preparedRows) - 1
      row = preparedRows[rowIndex]
      schema = tableSchemaState(database, bound.table)
      if schema is not void then
        for each constraint in schema.constraints
          if constraint.kind == schema_history.CONSTRAINT_FOREIGN_KEY then validateForeignKey(database, bound.table, constraint, row, pageTransaction, file) end if
        end for
      end if
      references[rowIndex] = stageInsertWithCursor(pageTransaction, file, bound.table, storageRow(rowSchema, bound.table, row, file, pageTransaction.transactionId), insertCursor)
      if len(bound.returning) > 0 then returnedRows[rowIndex] = evaluateReturning(bound.returning, row) end if
    end for
  end if
  return DmlResult(len(preparedRows), references, returnedRows, [], preparedRows)
end function

// Validates existing constraint using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateExistingConstraint(database, bound)
  if not binder.isBoundAlterTable(bound) or bound.statement.action != ast.ALTER_TABLE_ADD_CONSTRAINT then return true end if
  source = bound.statement.constraint
  name = source.name
  if name is void then name = "alter_constraint" end if
  expressionSql = ""
  if source.expression is not void then expressionSql = ast.formatExpression(source.expression) end if
  temporary = schema_history.constraint(name, source.kind, source.columns, expressionSql, source.referencesTable, source.referencesColumns, source.onDelete, source.onUpdate, 0, "")
  rows = scan.scanTable(database.path, bound.table, void)
  if source.kind == schema_history.CONSTRAINT_CHECK then
    for each row in rows
      validateCheck(bound.table, temporary, row.values)
    end for
    return true
  end if
  if source.kind == schema_history.CONSTRAINT_PRIMARY_KEY or source.kind == schema_history.CONSTRAINT_UNIQUE then
    if len(rows) > 0 then
      for leftIndex = 0 to len(rows) - 1
        leftKey = constraintKey(rows[leftIndex].values, bound.table, temporary)
        if source.kind == schema_history.CONSTRAINT_PRIMARY_KEY and keyHasNull(leftKey) then return fail(CONSTRAINT_VIOLATION, "validateExistingConstraint", "PRIMARY KEY contains NULL") end if
        if not keyHasNull(leftKey) and leftIndex + 1 < len(rows) then
          for rightIndex = leftIndex + 1 to len(rows) - 1
            if keysEqual(leftKey, constraintKey(rows[rightIndex].values, bound.table, temporary)) then return fail(DUPLICATE_KEY, "validateExistingConstraint", "existing rows violate new unique constraint") end if
          end for
        end if
      end for
    end if
    return true
  end if
  if source.kind == schema_history.CONSTRAINT_FOREIGN_KEY then
    for each row in rows
      validateForeignKey(database, bound.table, temporary, row.values, void, void)
    end for
  end if
  return true
end function

// Validates delete references using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateDeleteReferences(database, table, row, pageTransaction, file)
  state = schema_history.loadOrCreate(database.path, database.catalogHandle.metadata.databaseId)
  for each otherTable in database.catalogHandle.catalog.tables
    otherSchema = schema_history.findTableSchema(state, otherTable.tableId)
    if otherSchema is not void then
      for each constraint in otherSchema.constraints
        if constraint.kind == schema_history.CONSTRAINT_FOREIGN_KEY and constraint.referenceTable == table.name then
          referencedKey = []
          for each columnName in constraint.referenceColumns
            index = binder.findColumnIndex(table, columnName)
            if index < 0 then return fail(CORRUPT_DATA, "validateDeleteReferences", "referenced column missing") end if
            referencedKey = referencedKey + [row[index]]
          end for
          if not keyHasNull(referencedKey) then
            rows = scanRows(database, otherTable, pageTransaction, file)
            for each dependent in rows
              localKey = constraintKey(dependent.values, otherTable, constraint)
              if not keyHasNull(localKey) and keysEqual(localKey, referencedKey) then
                if constraint.onDelete == "CASCADE" or constraint.onDelete == "SET NULL" then
                  return fail(UNSUPPORTED_SQL, "validateDeleteReferences", "ON DELETE " + constraint.onDelete + " execution is introduced after the basic DML milestone")
                end if
                return fail(CONSTRAINT_VIOLATION, "validateDeleteReferences", "row is referenced by " + constraint.name)
              end if
            end for
          end if
        end if
      end for
    end if
  end for
  return true
end function

// Evaluates returning using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateReturning(returningItems, row)
  output = array(len(returningItems))
  if len(returningItems) == 0 then return output end if
  context = expressions.rowContext(row)
  for index = 0 to len(returningItems) - 1
    output[index] = expressions.evaluate(returningItems[index].expression, context)
  end for
  return output
end function

// Implements unique constraints for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function uniqueConstraints(database, table)
  schema = tableSchemaState(database, table)
  output = []
  if schema is void then return output end if
  for each constraint in schema.constraints
    if constraint.kind == schema_history.CONSTRAINT_PRIMARY_KEY or constraint.kind == schema_history.CONSTRAINT_UNIQUE then output = output + [constraint] end if
  end for
  return output
end function

// Finds conflict using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findConflict(database, bound, row, pageTransaction, file)
  constraints = []
  if bound.conflictConstraint is not void then constraints = [bound.conflictConstraint] else constraints = uniqueConstraints(database, bound.table) end if
  if len(constraints) == 0 then return void end if
  existingRows = scanRows(database, bound.table, pageTransaction, file)
  for each constraint in constraints
    key = constraintKey(row, bound.table, constraint)
    if not keyHasNull(key) then
      for each existing in existingRows
        if keysEqual(key, constraintKey(existing.values, bound.table, constraint)) then return ConflictMatch(existing.reference, existing.values, constraint) end if
      end for
    end if
  end for
  return void
end function

// Implements conflict update for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function conflictUpdate(database, bound, excludedRow, match, pageTransaction, file, rowSchema)
  if not isConflictMatch(match) then return fail(INVALID_ARGUMENT, "conflictUpdate", "match must be ConflictMatch") end if
  combined = []
  for each value in match.values
    combined = combined + [value]
  end for
  for each value in excludedRow
    combined = combined + [value]
  end for
  context = expressions.rowContext(combined)
  if bound.conflictWhere is not void and not expressions.predicatePasses(bound.conflictWhere, context) then return DmlResult(0, [], [], [], []) end if

  nextRow = []
  for each oldValue in match.values
    nextRow = nextRow + [oldValue]
  end for
  schema = tableSchemaState(database, bound.table)
  for each assignment in bound.conflictAssignments
    rule = findRule(schema, bound.table.columns[assignment.columnIndex].name)
    if rule is not void and rule.identity then return fail(CONSTRAINT_VIOLATION, "conflictUpdate", "identity column cannot be updated") end if
    if findGenerated(database, bound.table, bound.table.columns[assignment.columnIndex].name) is not void then return fail(CONSTRAINT_VIOLATION, "conflictUpdate", "generated column cannot be updated") end if
    evaluated = expressions.evaluate(assignment.expression, context)
    nextRow[assignment.columnIndex] = values.convert(evaluated, types.fromColumn(bound.table.columns[assignment.columnIndex]))
  end for
  applyGenerated(database, bound.table, nextRow)
  validateRow(database, bound.table, nextRow, pageTransaction, match.reference, file)
  nextReference = stageUpdate(pageTransaction, file, bound.table, match.reference, storageRow(rowSchema, bound.table, nextRow, file, pageTransaction.transactionId))
  returned = []
  if len(bound.returning) > 0 then returned = [evaluateReturning(bound.returning, nextRow)] end if
  return DmlResult(1, [nextReference], returned, [match.values], [nextRow])
end function

// Inserts inner using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function insertInner(database, bound, pageTransaction, file)
  if bound.statement.conflictAction == ast.CONFLICT_NONE and not hasIdentityColumn(database, bound.table) then
    return insertBatchWithoutConflict(database, bound, pageTransaction, file)
  end if
  references = []
  returnedRows = []
  oldRows = []
  newRows = []
  affected = 0
  rowSchema = scan.schemaForTable(bound.table)
  for each boundRow in bound.rows
    row = initialRow(database, bound, boundRow, pageTransaction, file)
    conflict = void
    if bound.statement.conflictAction != ast.CONFLICT_NONE then conflict = findConflict(database, bound, row, pageTransaction, file) end if
    if conflict is not void then
      if bound.statement.conflictAction == ast.CONFLICT_DO_UPDATE then
        updated = conflictUpdate(database, bound, row, conflict, pageTransaction, file, rowSchema)
        affected = affected + updated.affectedRows
        references = references + updated.references
        returnedRows = returnedRows + updated.rows
        oldRows = oldRows + updated.oldRows
        newRows = newRows + updated.newRows
      end if
    else
      validateRow(database, bound.table, row, pageTransaction, void, file)
      reference = stageInsert(pageTransaction, file, bound.table, storageRow(rowSchema, bound.table, row, file, pageTransaction.transactionId))
      references = references + [reference]
      affected = affected + 1
      newRows = newRows + [row]
      if len(bound.returning) > 0 then returnedRows = returnedRows + [evaluateReturning(bound.returning, row)] end if
    end if
  end for
  return DmlResult(affected, references, returnedRows, oldRows, newRows)
end function

// Inserts insert using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function insert(database, bound, pageTransaction)
  if not binder.isBoundInsert(bound) then return fail(INVALID_ARGUMENT, "insert", "bound must be BoundInsert") end if
  transaction.requireActive(pageTransaction, "executor.dml.insert")
  if pageTransaction.readOnly then return fail(READ_ONLY_VIOLATION, "insert", "transaction is read-only") end if
  file = paged_file.open(catalog.tableFilePath(database.path, bound.table.tableId))
  result = try(insertInner(database, bound, pageTransaction, file))
  closeResult = try(paged_file.close(file))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Implements update inner for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function updateInner(database, bound, pageTransaction, file)
  sourceRows = scan.scanUsing(database.path, bound.table, pageTransaction, file)
  affected = 0
  references = []
  returnedRows = []
  oldRows = []
  newRows = []
  rowSchema = scan.schemaForTable(bound.table)
  schema = tableSchemaState(database, bound.table)
  for each source in sourceRows
    if expressions.predicatePasses(bound.whereExpression, expressions.rowContext(source.values)) then
      nextRow = []
      for each oldValue in source.values
        nextRow = nextRow + [oldValue]
      end for
      for each assignment in bound.assignments
        rule = findRule(schema, bound.table.columns[assignment.columnIndex].name)
        if rule is not void and rule.identity then return fail(CONSTRAINT_VIOLATION, "update", "identity column cannot be updated") end if
        if findGenerated(database, bound.table, bound.table.columns[assignment.columnIndex].name) is not void then return fail(CONSTRAINT_VIOLATION, "update", "generated column cannot be updated") end if
        evaluated = expressions.evaluate(assignment.expression, expressions.rowContext(source.values))
        nextRow[assignment.columnIndex] = values.convert(evaluated, types.fromColumn(bound.table.columns[assignment.columnIndex]))
      end for
      applyGenerated(database, bound.table, nextRow)
      validateRow(database, bound.table, nextRow, pageTransaction, source.reference, file)
      nextReference = stageUpdate(pageTransaction, file, bound.table, source.reference, storageRow(rowSchema, bound.table, nextRow, file, pageTransaction.transactionId))
      references = references + [nextReference]
      oldRows = oldRows + [source.values]
      newRows = newRows + [nextRow]
      affected = affected + 1
      if len(bound.returning) > 0 then returnedRows = returnedRows + [evaluateReturning(bound.returning, nextRow)] end if
    end if
  end for
  return DmlResult(affected, references, returnedRows, oldRows, newRows)
end function

// Implements update for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function update(database, bound, pageTransaction)
  if not binder.isBoundUpdate(bound) then return fail(INVALID_ARGUMENT, "update", "bound must be BoundUpdate") end if
  transaction.requireActive(pageTransaction, "executor.dml.update")
  if pageTransaction.readOnly then return fail(READ_ONLY_VIOLATION, "update", "transaction is read-only") end if
  file = paged_file.open(catalog.tableFilePath(database.path, bound.table.tableId))
  result = try(updateInner(database, bound, pageTransaction, file))
  closeResult = try(paged_file.close(file))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Deletes inner using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function deleteInner(database, bound, pageTransaction, file)
  sourceRows = scan.scanUsing(database.path, bound.table, pageTransaction, file)
  affected = 0
  returnedRows = []
  oldRows = []
  for each source in sourceRows
    if expressions.predicatePasses(bound.whereExpression, expressions.rowContext(source.values)) then
      validateDeleteReferences(database, bound.table, source.values, pageTransaction, file)
      if len(bound.returning) > 0 then returnedRows = returnedRows + [evaluateReturning(bound.returning, source.values)] end if
      stageDelete(pageTransaction, file, bound.table, source.reference)
      oldRows = oldRows + [source.values]
      affected = affected + 1
    end if
  end for
  return DmlResult(affected, [], returnedRows, oldRows, [])
end function

// Deletes delete using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function delete(database, bound, pageTransaction)
  if not binder.isBoundDelete(bound) then return fail(INVALID_ARGUMENT, "delete", "bound must be BoundDelete") end if
  transaction.requireActive(pageTransaction, "executor.dml.delete")
  if pageTransaction.readOnly then return fail(READ_ONLY_VIOLATION, "delete", "transaction is read-only") end if
  file = paged_file.open(catalog.tableFilePath(database.path, bound.table.tableId))
  result = try(deleteInner(database, bound, pageTransaction, file))
  closeResult = try(paged_file.close(file))
  if typeof(result) == "error" then return result end if
  if typeof(closeResult) == "error" then return closeResult end if
  return result
end function

// Implements truncate for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function truncate(database, bound, pageTransaction)
  if not binder.isBoundTruncate(bound) then return fail(INVALID_ARGUMENT, "truncate", "bound must be BoundTruncate") end if
  transaction.requireActive(pageTransaction, "executor.dml.truncate")
  if pageTransaction.readOnly then return fail(READ_ONLY_VIOLATION, "truncate", "transaction is read-only") end if
  file = paged_file.open(catalog.tableFilePath(database.path, bound.table.tableId))
  rows = try(scan.scanUsing(database.path, bound.table, pageTransaction, file))
  if typeof(rows) == "error" then paged_file.close(file); return rows end if
  checked = true
  for each source in rows
    validation = try(validateDeleteReferences(database, bound.table, source.values, pageTransaction, file))
    if typeof(validation) == "error" then checked = validation; break end if
  end for
  if typeof(checked) == "error" then paged_file.close(file); return checked end if
  references = []
  for each source in rows
    stageDelete(pageTransaction, file, bound.table, source.reference)
    references = references + [source.reference]
  end for
  closeResult = try(paged_file.close(file))
  if typeof(closeResult) == "error" then return closeResult end if
  oldRows = []
  for each source in rows
    oldRows = oldRows + [source.values]
  end for
  return DmlResult(len(rows), references, [], oldRows, [])
end function

// Implements file for change for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function fileForChange(database, fileId)
  for each table in database.catalogHandle.catalog.tables
    if table.tableId == fileId then return paged_file.open(catalog.tableFilePath(database.path, table.tableId)) end if
  end for
  return fail(OBJECT_NOT_FOUND, "fileForChange", "committed page refers to unknown table")
end function

// Closes published files using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function closePublishedFiles(files)
  firstError = void
  for each file in files
    result = try(paged_file.close(file))
    if typeof(result) == "error" and firstError is void then firstError = result end if
  end for
  return firstError
end function

// Implements publish committed for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function publishCommitted(database, pageTransaction, commitLsn)
  if typeof(commitLsn) != "int" or commitLsn < 0 then return fail(INVALID_ARGUMENT, "publishCommitted", "commitLsn must be non-negative") end if
  // Do not remove the private committed page batch until every base file has
  // accepted and durably flushed its pages. If publication fails, M7 recovery
  // can redo from WAL and callers may also retry this operation safely.
  changes = transaction.committedPagesForPublication(pageTransaction)
  openedIds = []
  openedFiles = []
  operationError = void
  for each change in changes
    if operationError is void then
      fileIndex = -1
      if len(openedIds) > 0 then
        for index = 0 to len(openedIds) - 1
          if openedIds[index] == change.fileId then fileIndex = index end if
        end for
      end if
      if fileIndex < 0 then
        opened = try(fileForChange(database, change.fileId))
        if typeof(opened) == "error" then
          operationError = opened
        else
          openedIds = openedIds + [change.fileId]
          openedFiles = openedFiles + [opened]
          fileIndex = len(openedFiles) - 1
        end if
      end if
      if operationError is void then
        image = bytes(change.pageBytes)
        page.setLsn(image, endian.uint64FromInt(commitLsn))
        written = try(paged_file.writePage(openedFiles[fileIndex], change.pageNumber, image))
        if typeof(written) == "error" then operationError = written end if
      end if
    end if
  end for
  if operationError is void then
    for each file in openedFiles
      flushed = try(paged_file.flush(file))
      if typeof(flushed) == "error" and operationError is void then operationError = flushed end if
    end for
  end if
  closeError = closePublishedFiles(openedFiles)
  if operationError is not void then return operationError end if
  if closeError is not void then return closeError end if
  transaction.acknowledgeCommittedPages(pageTransaction)
  return len(changes)
end function

// ---------------------------------------------------------------------------
// M23 derived persistent index integration
// ---------------------------------------------------------------------------

// Appends key bytes using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function appendKeyBytes(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" then return fail(INVALID_ARGUMENT, "appendKeyBytes", "values must be bytes") end if
  return left + right
end function

// Implements escaped key bytes for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function escapedKeyBytes(source)
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "escapedKeyBytes", "source must be bytes") end if
  output = bytes()
  if len(source) > 0 then
    for index = 0 to len(source) - 1
      if source[index] == 0 then
        output = output + bytes([0, 255])
      else
        output = output + bytes([source[index]])
      end if
    end for
  end if
  return output + bytes([0, 0])
end function

// Implements index key part for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexKeyPart(value)
  if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "indexKeyPart", "value must be SqlValue") end if
  if value.isNull then return bytes([1]) end if
  if value.typeKind == types.SqlTypeKind.Boolean then
    byteValue = 0
    if value.value then byteValue = 1 end if
    return bytes([2, byteValue])
  end if
  if types.isIntegralKind(value.typeKind) or value.typeKind == types.SqlTypeKind.Decimal or value.typeKind == types.SqlTypeKind.Date or value.typeKind == types.SqlTypeKind.Time or value.typeKind == types.SqlTypeKind.Timestamp then
    words = values.asInt64(value)
    output = bytes(9, 0)
    output[0] = 3
    endian.writeU32BE(output, 1, words.high ^ 2147483648)
    endian.writeU32BE(output, 5, words.low)
    return output
  end if
  if value.typeKind == types.SqlTypeKind.Real or value.typeKind == types.SqlTypeKind.Double then
    return bytes([4]) + escapedKeyBytes(bytes("" + value.value))
  end if
  if types.isTextKind(value.typeKind) then return bytes([5]) + escapedKeyBytes(bytes(value.value)) end if
  if types.isBinaryKind(value.typeKind) then return bytes([6]) + escapedKeyBytes(value.value) end if
  return fail(TYPE_MISMATCH, "indexKeyPart", "unsupported index key type")
end function

// Encodes index key using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function encodeIndexKey(keyValues)
  if typeof(keyValues) != "array" or len(keyValues) == 0 then return fail(INVALID_ARGUMENT, "encodeIndexKey", "keyValues must be non-empty") end if
  output = bytes([127])
  for each value in keyValues
    output = appendKeyBytes(output, indexKeyPart(value))
    if len(output) > btree.MAX_KEY_BYTES then return fail(INVALID_ARGUMENT, "encodeIndexKey", "encoded key exceeds B+ tree limit") end if
  end for
  return output
end function

// Encodes an exact composite constraint key without the physical B+ tree size
// ceiling. The statement-local hash set uses this representation to validate
// arbitrarily large batches in linear expected time.
function encodeConstraintHashKey(keyValues)
  if typeof(keyValues) != "array" or len(keyValues) == 0 then return fail(INVALID_ARGUMENT, "encodeConstraintHashKey", "keyValues must be non-empty") end if
  output = bytes([127])
  for each value in keyValues
    normalized = value
    if (value.typeKind == types.SqlTypeKind.Real or value.typeKind == types.SqlTypeKind.Double) and value.value == 0 then normalized = values.of(value.typeKind, 0.0) end if
    output = appendKeyBytes(output, indexKeyPart(normalized))
  end for
  return output
end function

// Encodes row reference using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function encodeRowReference(tableId, reference)
  if typeof(tableId) != "int" or tableId < 0 or not scan.isRowReference(reference) then return fail(INVALID_ARGUMENT, "encodeRowReference", "invalid row reference") end if
  output = bytes(12, 0)
  endian.writeU32LE(output, 0, reference.pageNumber)
  endian.writeU16LE(output, 4, reference.slotId)
  endian.writeU16LE(output, 6, reference.generation)
  endian.writeU32LE(output, 8, tableId)
  return output
end function

// Decodes row reference using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decodeRowReference(tableId, encoded)
  if typeof(tableId) != "int" or typeof(encoded) != "bytes" or len(encoded) != 12 then return fail(CORRUPT_DATA, "decodeRowReference", "invalid index row reference") end if
  if endian.readU32LE(encoded, 8) != tableId then return fail(CORRUPT_DATA, "decodeRowReference", "index row reference belongs to another table") end if
  return scan.RowReference(endian.readU32LE(encoded, 0), endian.readU16LE(encoded, 4), endian.readU16LE(encoded, 6))
end function

// Implements indexed constraints for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexedConstraints(database, table)
  schema = tableSchemaState(database, table)
  if schema is void then return [] end if
  output = []
  for each value in schema.constraints
    if value.indexId > 0 then output = output + [value] end if
  end for
  return output
end function

// Returns whether the supplied value satisfies the unique index constraint condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isUniqueIndexConstraint(value)
  return value.kind == schema_history.CONSTRAINT_PRIMARY_KEY or value.kind == schema_history.CONSTRAINT_UNIQUE
end function

// Implements index path for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexPath(database, constraint)
  return schema_history.indexFilePath(database.path, constraint.indexId)
end function

// Opens an index for a read plan while retaining the concrete path in errors.
// This makes a missing or inaccessible derived file diagnosable without hiding
// corruption behind a generic native CreateFile failure.
function openReadOnlyIndex(database, constraint, operation)
  path = indexPath(database, constraint)
  tree = try(btree.openReadOnly(path))
  if typeof(tree) == "error" then return fail(tree.code, operation, "cannot open index file " + path + ": " + tree.message) end if
  return tree
end function

// Builds index entries using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function buildIndexEntries(database, table, constraint, pageTransaction)
  // Index construction needs only key columns plus the physical RowReference.
  // Avoid fetching unrelated external values during startup verification,
  // REINDEX, and VACUUM on wide multi-gigabyte tables.
  rows = scan.scanTableRangeColumns(database.path, table, pageTransaction, 0, -1, constraintColumnMask(table, [constraint]))
  entryCount = 0
  for each row in rows
    keyValues = constraintKey(row.values, table, constraint)
    // SQL UNIQUE permits multiple NULL keys. They are intentionally omitted
    // from unique indexes and remain visible through the heap scan.
    if not (isUniqueIndexConstraint(constraint) and keyHasNull(keyValues)) then entryCount = entryCount + 1 end if
  end for
  entries = array(entryCount)
  entryIndex = 0
  for each row in rows
    keyValues = constraintKey(row.values, table, constraint)
    if not (isUniqueIndexConstraint(constraint) and keyHasNull(keyValues)) then
      entries[entryIndex] = btree.entry(encodeIndexKey(keyValues), encodeRowReference(table.tableId, row.reference))
      entryIndex = entryIndex + 1
    end if
  end for
  return entries
end function

// Implements rebuild index for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function rebuildIndex(database, table, constraint)
  if constraint.indexId <= 0 then return fail(INVALID_ARGUMENT, "rebuildIndex", "constraint has no index") end if
  finalPath = indexPath(database, constraint)
  temporaryPath = finalPath + ".rebuild.new"
  if file_api.pathExists(temporaryPath) then file_api.deletePath(temporaryPath) end if
  tree = btree.create(temporaryPath, database.catalogHandle.metadata.pageSize, constraint.indexId, database.catalogHandle.metadata.databaseId, isUniqueIndexConstraint(constraint))
  result = try(btree.bulkLoad(tree, buildIndexEntries(database, table, constraint, void)))
  closeResult = try(btree.close(tree))
  if typeof(result) == "error" then
    ignoredDelete = try(file_api.deletePath(temporaryPath))
    return result
  end if
  if typeof(closeResult) == "error" then
    ignoredDelete = try(file_api.deletePath(temporaryPath))
    return closeResult
  end if
  file_api.movePath(temporaryPath, finalPath, true)
  return result
end function

// Implements rebuild indexes for table for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rebuildIndexesForTable(database, table)
  rebuilt = 0
  for each constraint in indexedConstraints(database, table)
    rebuildIndex(database, table, constraint)
    rebuilt = rebuilt + 1
  end for
  return rebuilt
end function

// Applies an insert-only statement delta to every derived index without
// rescanning unrelated table payload pages. The caller publishes the durable
// indexes.dirty marker before the heap commit; a crash or failed index write is
// therefore repaired by the ordinary startup path.
function applyInsertedIndexes(database, table, result)
  if not isDmlResult(result) or len(result.oldRows) != 0 or len(result.newRows) != len(result.references) then return fail(INVALID_ARGUMENT, "applyInsertedIndexes", "result is not an insert-only delta") end if
  updated = 0
  for each constraint in indexedConstraints(database, table)
    tree = try(btree.open(indexPath(database, constraint)))
    if typeof(tree) == "error" then return tree end if
    existing = try(btree.allEntries(tree))
    if typeof(existing) == "error" then btree.close(tree); return existing end if
    additions = 0
    if len(result.newRows) > 0 then
      for rowIndex = 0 to len(result.newRows) - 1
        keyValues = constraintKey(result.newRows[rowIndex], table, constraint)
        if not (isUniqueIndexConstraint(constraint) and keyHasNull(keyValues)) then additions = additions + 1 end if
      end for
    end if
    combined = array(len(existing) + additions)
    // MiniLang ranges are inclusive even when their upper bound is negative.
    // Guard empty arrays explicitly so an empty index cannot access element -1.
    if len(existing) > 0 then
      for index = 0 to len(existing) - 1
        combined[index] = existing[index]
      end for
    end if
    outputIndex = len(existing)
    if len(result.newRows) > 0 then
      for rowIndex = 0 to len(result.newRows) - 1
        keyValues = constraintKey(result.newRows[rowIndex], table, constraint)
        if not (isUniqueIndexConstraint(constraint) and keyHasNull(keyValues)) then
          combined[outputIndex] = btree.entry(encodeIndexKey(keyValues), encodeRowReference(table.tableId, result.references[rowIndex]))
          outputIndex = outputIndex + 1
        end if
      end for
    end if
    committed = try(btree.commitSorted(tree, btree.sortEntries(combined)))
    closed = try(btree.close(tree))
    if typeof(committed) == "error" then return committed end if
    if typeof(closed) == "error" then return closed end if
    updated = updated + 1
  end for
  return updated
end function

// Implements rebuild all indexes for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rebuildAllIndexes(database)
  rebuilt = 0
  for each table in database.catalogHandle.catalog.tables
    rebuilt = rebuilt + rebuildIndexesForTable(database, table)
  end for
  return rebuilt
end function

// Compares one derived index with the heap through forward-only row reads and
// logarithmic B+ tree membership probes. Count equality plus the presence of
// every unique row-reference entry proves that the tree has neither missing nor
// additional entries, without retaining either complete collection.
function verifyIndexStreaming(database, table, constraint, tree, reader)
  cursorResult = try(scan.openCursor(reader, constraintColumnMask(table, [constraint])))
  if typeof(cursorResult) == "error" then return cursorResult end if
  expectedCount = 0
  operationError = void
  finished = false
  while not finished and operationError is void
    row = try(scan.nextRow(cursorResult))
    if typeof(row) == "error" then
      operationError = row
    else if row is void then
      finished = true
    else
      keyValues = constraintKey(row.values, table, constraint)
      if not (isUniqueIndexConstraint(constraint) and keyHasNull(keyValues)) then
        expected = try(btree.entry(encodeIndexKey(keyValues), encodeRowReference(table.tableId, row.reference)))
        if typeof(expected) == "error" then
          operationError = expected
        else
          present = try(btree.containsEntry(tree, expected))
          if typeof(present) == "error" then operationError = present else if not present then operationError = fail(CORRUPT_DATA, "verifyIndex", "index entry is missing from derived tree") end if
        end if
        expectedCount = expectedCount + 1
      end if
    end if
  end while
  if operationError is not void then return operationError end if
  if expectedCount != btree.count(tree) then return fail(CORRUPT_DATA, "verifyIndex", "index entry count differs from heap") end if
  return true
end function

// Verifies one index while guaranteeing that both read-only handles are closed
// on comparison failures. B+ tree open already performs the streaming structural
// audit, and the explicit call documents that integrity is part of this API.
function verifyIndex(database, table, constraint)
  tree = try(btree.openReadOnly(indexPath(database, constraint)))
  if typeof(tree) == "error" then return tree end if
  reader = try(scan.open(database.path, table, void))
  if typeof(reader) == "error" then ignoredTreeClose = try(btree.close(tree)); return reader end if
  operationResult = try(btree.verify(tree))
  if typeof(operationResult) != "error" then operationResult = try(verifyIndexStreaming(database, table, constraint, tree, reader)) end if
  readerClose = try(scan.close(reader))
  treeClose = try(btree.close(tree))
  if typeof(operationResult) == "error" then return operationResult end if
  if typeof(readerClose) == "error" then return readerClose end if
  if typeof(treeClose) == "error" then return treeClose end if
  return true
end function

// Verifies all indexes using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function verifyAllIndexes(database)
  verified = 0
  for each table in database.catalogHandle.catalog.tables
    for each constraint in indexedConstraints(database, table)
      verifyIndex(database, table, constraint)
      verified = verified + 1
    end for
  end for
  return verified
end function

// Implements index dirty path for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexDirtyPath(database)
  return catalog.joinPath(catalog.joinPath(database.path, "catalog"), "indexes.dirty")
end function

// Implements indexes need repair for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function indexesNeedRepair(database)
  return file_api.fileExists(indexDirtyPath(database))
end function

// Detects missing derived index files without scanning any table heap. A clean
// dirty-marker state proves that committed index updates completed, but older
// databases or manual file loss may still leave an expected file absent.
function indexFilesMissing(database)
  for each table in database.catalogHandle.catalog.tables
    for each constraint in indexedConstraints(database, table)
      if not file_api.fileExists(indexPath(database, constraint)) then return true end if
    end for
  end for
  return false
end function

// Implements mark indexes dirty for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function markIndexesDirty(database)
  path = indexDirtyPath(database)
  file = file_api.createDurable(path)
  marker = bytes("MINISQL-INDEX-DIRTY-1")
  file_api.writeAt(file, 0, marker, 0, len(marker))
  file_api.truncate(file, len(marker))
  file_api.flush(file)
  file_api.close(file)
  return true
end function

// Implements clear indexes dirty for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function clearIndexesDirty(database)
  path = indexDirtyPath(database)
  if file_api.fileExists(path) then file_api.deletePath(path) end if
  return true
end function

// Ensures indexes using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function ensureIndexes(database)
  needsRebuild = indexesNeedRepair(database) or indexFilesMissing(database)
  // Every mutation durably creates indexes.dirty before its heap commit and
  // removes it only after the derived indexes are durable. Its absence is the
  // crash-safe fast path: re-verifying every heap after each server restart
  // turns an indexed point lookup into an unrelated multi-gigabyte scan.
  if not needsRebuild then return true end if
  rebuilt = try(rebuildAllIndexes(database))
  if typeof(rebuilt) == "error" then return rebuilt end if
  checked = try(verifyAllIndexes(database))
  if typeof(checked) == "error" then return checked end if
  clearIndexesDirty(database)
  return true
end function

// Implements constraint for single column for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function constraintForSingleColumn(database, table, columnIndex)
  if columnIndex < 0 or columnIndex >= len(table.columns) then return void end if
  columnName = table.columns[columnIndex].name
  for each constraint in indexedConstraints(database, table)
    if len(constraint.columns) == 1 and constraint.columns[0] == columnName then return constraint end if
  end for
  return void
end function

// Implements rows from index entries for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rowsFromIndexEntries(database, table, pageTransaction, entries)
  output = []
  for each value in entries
    reference = decodeRowReference(table.tableId, value.value)
    row = scan.readTableReference(database.path, table, pageTransaction, reference)
    if row is not void then output = output + [row] end if
  end for
  return output
end function

// Implements equality index rows for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function equalityIndexRows(database, table, columnIndex, literalValue, pageTransaction)
  constraint = constraintForSingleColumn(database, table, columnIndex)
  if constraint is void then return void end if
  converted = values.convert(literalValue, types.fromColumn(table.columns[columnIndex]))
  if converted.isNull then return [] end if
  tree = openReadOnlyIndex(database, constraint, "equalityIndexRows")
  found = try(btree.find(tree, encodeIndexKey([converted])))
  closeResult = try(btree.close(tree))
  if typeof(found) == "error" then return found end if
  if typeof(closeResult) == "error" then return closeResult end if
  entries = []
  for each rowValue in found
    entries = entries + [btree.entry(encodeIndexKey([converted]), rowValue)]
  end for
  return rowsFromIndexEntries(database, table, pageTransaction, entries)
end function

// Implements range index rows for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function rangeIndexRows(database, table, columnIndex, literalValue, operator, pageTransaction)
  constraint = constraintForSingleColumn(database, table, columnIndex)
  if constraint is void then return void end if
  converted = values.convert(literalValue, types.fromColumn(table.columns[columnIndex]))
  if converted.isNull then return [] end if
  if converted.typeKind == types.SqlTypeKind.Real or converted.typeKind == types.SqlTypeKind.Double then return void end if
  key = encodeIndexKey([converted])
  lower = void
  upper = void
  lowerInclusive = true
  upperInclusive = true
  if operator == ">" or operator == ">=" then
    lower = key
    lowerInclusive = operator == ">="
  else
    upper = key
    upperInclusive = operator == "<="
  end if
  tree = openReadOnlyIndex(database, constraint, "rangeIndexRows")
  found = try(btree.range(tree, lower, lowerInclusive, upper, upperInclusive, 0))
  closeResult = try(btree.close(tree))
  if typeof(found) == "error" then return found end if
  if typeof(closeResult) == "error" then return closeResult end if
  return rowsFromIndexEntries(database, table, pageTransaction, found)
end function

// Implements equality literal for column for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function equalityLiteralForColumn(expression, columnIndex)
  if expression is void or not expressions.isBaseBoundExpression(expression) then return [false, void] end if
  if expression.kind != expressions.BOUND_BINARY then return [false, void] end if
  if expression.operator == "AND" then
    left = equalityLiteralForColumn(expression.left, columnIndex)
    if left[0] then return left end if
    return equalityLiteralForColumn(expression.right, columnIndex)
  end if
  if expression.operator != "=" then return [false, void] end if
  if expression.left.kind == expressions.BOUND_COLUMN and expression.left.columnIndex == columnIndex and expression.right.kind == expressions.BOUND_LITERAL then return [true, expression.right.literal] end if
  if expression.right.kind == expressions.BOUND_COLUMN and expression.right.columnIndex == columnIndex and expression.left.kind == expressions.BOUND_LITERAL then return [true, expression.left.literal] end if
  return [false, void]
end function

// Implements composite equality index rows for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function compositeEqualityIndexRows(database, table, expression, pageTransaction)
  for each constraint in indexedConstraints(database, table)
    if len(constraint.columns) > 1 then
      keyValues = []
      complete = true
      for each columnName in constraint.columns
        columnIndex = binder.findColumnIndex(table, columnName)
        found = equalityLiteralForColumn(expression, columnIndex)
        if not found[0] then
          complete = false
        else
          converted = values.convert(found[1], types.fromColumn(table.columns[columnIndex]))
          if converted.isNull then return [] end if
          keyValues = keyValues + [converted]
        end if
      end for
      if complete then
        encodedKey = encodeIndexKey(keyValues)
        tree = openReadOnlyIndex(database, constraint, "compositeEqualityIndexRows")
        foundValues = try(btree.find(tree, encodedKey))
        closeResult = try(btree.close(tree))
        if typeof(foundValues) == "error" then return foundValues end if
        if typeof(closeResult) == "error" then return closeResult end if
        entries = []
        for each rowValue in foundValues
          entries = entries + [btree.entry(encodedKey, rowValue)]
        end for
        return rowsFromIndexEntries(database, table, pageTransaction, entries)
      end if
    end if
  end for
  return void
end function

// Implements index rows for bound for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexRowsForBound(database, bound, pageTransaction)
  if pageTransaction is not void and transaction.stagedPageCount(pageTransaction) > 0 then return void end if
  if not binder.isBoundSelect(bound) or len(bound.sources) != 1 or len(bound.joins) != 0 then return void end if
  expression = bound.whereExpression
  if expression is void or not expressions.isBaseBoundExpression(expression) then return void end if
  composite = compositeEqualityIndexRows(database, bound.sources[0].table, expression, pageTransaction)
  if composite is not void then return composite end if
  if expression.kind != expressions.BOUND_BINARY then return void end if
  columnExpression = void
  literalExpression = void
  operator = expression.operator
  if expression.left.kind == expressions.BOUND_COLUMN and expression.right.kind == expressions.BOUND_LITERAL then
    columnExpression = expression.left
    literalExpression = expression.right
  else if expression.right.kind == expressions.BOUND_COLUMN and expression.left.kind == expressions.BOUND_LITERAL then
    columnExpression = expression.right
    literalExpression = expression.left
    if operator == "<" then operator = ">" else if operator == "<=" then operator = ">=" else if operator == ">" then operator = "<" else if operator == ">=" then operator = "<=" end if
  end if
  if columnExpression is void or literalExpression is void then return void end if
  if operator == "=" then return equalityIndexRows(database, bound.sources[0].table, columnExpression.columnIndex, literalExpression.literal, pageTransaction) end if
  if operator == "<" or operator == "<=" or operator == ">" or operator == ">=" then return rangeIndexRows(database, bound.sources[0].table, columnExpression.columnIndex, literalExpression.literal, operator, pageTransaction) end if
  return void
end function

// Implements index access description for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indexAccessDescription(database, bound)
  indexed = indexRowsForBound(database, bound, void)
  if indexed is void then return void end if
  return "Index Seek rows=" + len(indexed)
end function

// Implements join index rows for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinIndexRows(database, source, condition, leftRow, pageTransaction)
  if pageTransaction is not void and transaction.stagedPageCount(pageTransaction) > 0 then return void end if
  if condition is void or not expressions.isBaseBoundExpression(condition) or condition.kind != expressions.BOUND_BINARY or condition.operator != "=" then return void end if
  leftColumn = void
  rightColumn = void
  if condition.left.kind == expressions.BOUND_COLUMN and condition.right.kind == expressions.BOUND_COLUMN then
    if condition.left.columnIndex < source.offset and condition.right.columnIndex >= source.offset then leftColumn = condition.left; rightColumn = condition.right end if
    if condition.right.columnIndex < source.offset and condition.left.columnIndex >= source.offset then leftColumn = condition.right; rightColumn = condition.left end if
  end if
  if leftColumn is void or rightColumn is void then return void end if
  localIndex = rightColumn.columnIndex - source.offset
  if localIndex < 0 or localIndex >= len(source.table.columns) or leftColumn.columnIndex >= len(leftRow.values) then return void end if
  return equalityIndexRows(database, source.table, localIndex, leftRow.values[leftColumn.columnIndex], pageTransaction)
end function

// ---------------------------------------------------------------------------
// M25 maintenance: VACUUM and REINDEX
// ---------------------------------------------------------------------------

// Implements vacuum storage values for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function vacuumStorageValues(heap, table, sqlValues, ownerId)
  output = []
  if len(sqlValues) > 0 then
    for index = 0 to len(sqlValues) - 1
      value = sqlValues[index]
      raw = values.toStorage(value)
      typeCode = table.columns[index].typeCode
      if not value.isNull and (typeCode == types.SqlTypeKind.Text or typeCode == types.SqlTypeKind.Blob) then
        data = raw
        if typeof(raw) == "string" then data = bytes(raw) end if
        threshold = heap.pagedFile.pageSize >> 2
        if len(data) > threshold then raw = overflow.toExternal(overflow.write(heap.pagedFile, ownerId, data)) end if
      end if
      output = output + [raw]
    end for
  end if
  return output
end function

// Writes rows to heap using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function writeRowsToHeap(path, pageSize, databaseId, table, rows)
  if typeof(path) != "string" or len(path) == 0 or typeof(pageSize) != "int" or typeof(databaseId) != "bytes" or len(databaseId) != 16 or not metadata.isTableMetadata(table) or typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "writeRowsToHeap", "invalid arguments") end if
  if file_api.pathExists(path) then file_api.deletePath(path) end if
  heap = heap_file.create(path, pageSize, table.tableId, databaseId)
  rowSchema = scan.schemaForTable(table)
  operationError = void
  if len(rows) > 0 then
    for index = 0 to len(rows) - 1
      if operationError is void then
        valuesForRow = rows[index]
        if scan.isScannedRow(valuesForRow) then valuesForRow = valuesForRow.values end if
        encoded = try(row_codec.encodeRow(rowSchema, vacuumStorageValues(heap, table, valuesForRow, index + 1)))
        if typeof(encoded) == "error" then
          operationError = encoded
        else
          inserted = try(heap_file.insert(heap, encoded))
          if typeof(inserted) == "error" then operationError = inserted end if
        end if
      end if
    end for
  end if
  closed = try(heap_file.close(heap))
  if operationError is not void then ignoredDelete = try(file_api.deletePath(path)); return operationError end if
  if typeof(closed) == "error" then ignoredDelete = try(file_api.deletePath(path)); return closed end if
  return len(rows)
end function

// Rewrites one table with memory bounded to one source page, one decoded row,
// and one target page. This is the VACUUM path for multi-gigabyte relations;
// retaining the complete live row set would otherwise scale heap usage with
// database size and fail long before the storage format reaches its limits.
function rewriteTableStreaming(databasePath, path, pageSize, databaseId, table)
  if typeof(databasePath) != "string" or len(databasePath) == 0 or typeof(path) != "string" or len(path) == 0 or not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "rewriteTableStreaming", "invalid arguments") end if
  if file_api.pathExists(path) then file_api.deletePath(path) end if
  reader = try(scan.open(databasePath, table, void))
  if typeof(reader) == "error" then return reader end if
  heap = try(heap_file.create(path, pageSize, table.tableId, databaseId))
  if typeof(heap) == "error" then scan.close(reader); return heap end if
  rowSchema = scan.schemaForTable(table)
  operationError = void
  written = 0
  heapPages = try(heap_file.heapPageNumbers(reader.file))
  if typeof(heapPages) == "error" then operationError = heapPages end if
  if operationError is void and len(heapPages) > 0 then
    for each pageNumber in heapPages
      if operationError is void then
        pageBytes = try(scan.visiblePage(reader, pageNumber))
        if typeof(pageBytes) == "error" then
          operationError = pageBytes
        else
          header = try(page.verify(pageBytes))
          if typeof(header) == "error" then
            operationError = header
          else if header.pageType == page.TYPE_HEAP then
            slotCount = slotted_page.slotCount(pageBytes)
            if slotCount > 0 then
              for slotId = 0 to slotCount - 1
                if operationError is void then
                  current = slotted_page.entry(pageBytes, slotId)
                  if current.flags == slotted_page.SLOT_FLAG_LIVE then
                    sqlValues = try(scan.decodeRecord(reader, slotted_page.read(pageBytes, slotId)))
                    if typeof(sqlValues) == "error" then
                      operationError = sqlValues
                    else
                      encoded = try(row_codec.encodeRow(rowSchema, vacuumStorageValues(heap, table, sqlValues, written + 1)))
                      if typeof(encoded) == "error" then
                        operationError = encoded
                      else
                        inserted = try(heap_file.insert(heap, encoded))
                        if typeof(inserted) == "error" then operationError = inserted else written = written + 1 end if
                        // Large values become unreachable after each iteration,
                        // but the runtime otherwise waits for heap pressure before
                        // collecting them. Periodic collection keeps physical
                        // memory near the one-row live-data invariant.
                        if operationError is void and (written % 8) == 0 then gc_collect() end if
                      end if
                    end if
                  end if
                end if
              end for
            end if
          else
            operationError = fail(CORRUPT_DATA, "rewriteTableStreaming", "heap-page directory references a non-heap source page")
          end if
        end if
      end if
    end for
  end if
  closedReader = try(scan.close(reader))
  closedHeap = try(heap_file.close(heap))
  if operationError is void and typeof(closedReader) == "error" then operationError = closedReader end if
  if operationError is void and typeof(closedHeap) == "error" then operationError = closedHeap end if
  if operationError is not void then ignoredDelete = try(file_api.deletePath(path)); return operationError end if
  return written
end function

// Resets WAL after vacuum using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state and perform I/O through its dependencies.
function resetWalAfterVacuum(database)
  // The replacement heap uses a new physical page layout. Old committed WAL
  // page images must never be replayed into that layout. VACUUM is autocommit-
  // only and owns the database process lock, so it can publish a zero redo
  // horizon after the replacement is durable.
  wal.flush(database.walWriter)
  wal.rewind(database.walWriter, 0)
  checkpoint.publish(database.checkpointFile, 0, 0, 0)
  database.catalogHandle.metadata.checkpointLsn = 0
  catalog.persistMetadata(database.catalogHandle)
  return true
end function

// Implements vacuum table for this module.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function vacuumTable(database, table)
  if not metadata.isTableMetadata(table) then return fail(INVALID_ARGUMENT, "vacuumTable", "table must be TableMetadata") end if
  finalPath = catalog.tableFilePath(database.path, table.tableId)
  temporaryPath = finalPath + ".vacuum.new"
  backupPath = finalPath + ".vacuum.old"
  if file_api.pathExists(temporaryPath) then file_api.deletePath(temporaryPath) end if
  if file_api.pathExists(backupPath) then file_api.deletePath(backupPath) end if
  written = rewriteTableStreaming(database.path, temporaryPath, database.catalogHandle.metadata.pageSize, database.catalogHandle.metadata.databaseId, table)
  // Invalidate before the replacement journal is published. A crash at any
  // later phase restores either old or new authoritative data and forces the
  // derived directory to rebuild against that exact file.
  heap_file.invalidatePageDirectory(finalPath)
  journal = schema_history.beginMaintenance(database.path, finalPath, temporaryPath, backupPath)
  file_api.movePath(finalPath, backupPath, false)
  file_api.movePath(temporaryPath, finalPath, false)
  resetWalAfterVacuum(database)
  schema_history.markMaintenanceCommitted(database.path, journal)
  schema_history.finishMaintenance(database.path, journal)
  return written
end function

// Implements vacuum for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function vacuum(database, tableName)
  tables = []
  if tableName is void then
    tables = database.catalogHandle.catalog.tables
  else
    table = catalog.findTable(database.catalogHandle, tableName)
    if table is void then return fail(OBJECT_NOT_FOUND, "vacuum", "table not found: " + tableName) end if
    tables = [table]
  end if
  markIndexesDirty(database)
  affected = 0
  for each table in tables
    affected = affected + vacuumTable(database, table)
    rebuildIndexesForTable(database, table)
  end for
  clearIndexesDirty(database)
  return affected
end function

// Implements reindex for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function reindex(database, name)
  if name is void then
    markIndexesDirty(database)
    rebuilt = rebuildAllIndexes(database)
    clearIndexesDirty(database)
    return rebuilt
  end if
  table = catalog.findTable(database.catalogHandle, name)
  if table is not void then
    markIndexesDirty(database)
    rebuilt = rebuildIndexesForTable(database, table)
    clearIndexesDirty(database)
    return rebuilt
  end if
  for each candidate in database.catalogHandle.catalog.tables
    for each value in indexedConstraints(database, candidate)
      if value.name == name or value.indexName == name then
        markIndexesDirty(database)
        rebuildIndex(database, candidate, value)
        clearIndexesDirty(database)
        return 1
      end if
    end for
  end for
  return fail(OBJECT_NOT_FOUND, "reindex", "table or index not found: " + name)
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.dml"
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
