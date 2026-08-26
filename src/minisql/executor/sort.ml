package minisql.executor.sort

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.executor.projection as projection
import minisql.platform.clock as clock
import minisql.platform.file as file_api
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.row_codec as row_codec

// Stable merge sorting for projected rows. M46 adds a correctness-first
// external-run path: initial sorted chunks are encoded with row_codec into
// durable temporary files and merged pairwise. The current pairwise merge reads
// two complete runs and the QueryResult contract materializes the final array,
// so this is not yet a hard total-memory bound or a fully streaming executor.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const SPILL_VERSION = 1
const SPILL_HEADER_SIZE = 16
const MAX_SPILL_FILE_BYTES = 268435456

spillNonce = 0

// Groups the spill run state and preserves the field relationships documented below.
struct SpillRun
  // Stores the filesystem path.
  path
  // Contains the ordered row schema collection.
  rowSchema
  // Stores the type kinds associated with this value.
  typeKinds
  // Tracks the value count numeric value.
  valueCount
  // Tracks the order count numeric value.
  orderCount
  // Tracks the row count numeric value.
  rowCount
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.sort." + operation + ": " + message)
end function

// Implements spill magic for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function spillMagic()
  return bytes("MSSPILL1")
end function

// Implements bytes equal for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

// Compares nullable using the supplied inputs.
// Returns the computed value or operation status.
// Does not modify its inputs.
function compareNullable(left, right, descending, nullsFirst, nullsSpecified)
  if not values.isSqlValue(left) or not values.isSqlValue(right) then return fail(INVALID_ARGUMENT, "compareNullable", "values must be SqlValue") end if
  if left.isNull or right.isNull then
    if left.isNull and right.isNull then return 0 end if
    first = nullsFirst
    if not nullsSpecified then first = descending end if
    result = 1
    if left.isNull then result = -1 end if
    if not first then result = 0 - result end if
    return result
  end if
  result = values.compareNonNull(left, right)
  if descending then result = 0 - result end if
  return result
end function

// Compares rows using the supplied inputs.
// Returns the computed value or operation status.
// Does not modify its inputs.
function compareRows(left, right, orderItems)
  if len(left.orderValues) != len(orderItems) or len(right.orderValues) != len(orderItems) then return fail(INVALID_ARGUMENT, "compareRows", "order value count mismatch") end if
  if len(orderItems) > 0 then
    for index = 0 to len(orderItems) - 1
      item = orderItems[index]
      result = compareNullable(left.orderValues[index], right.orderValues[index], item.descending, item.nullsFirst, item.nullsSpecified)
      if result != 0 then return result end if
    end for
  end if
  return 0
end function

// Implements merge for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function merge(left, right, orderItems)
  output = []
  leftIndex = 0
  rightIndex = 0
  while leftIndex < len(left) and rightIndex < len(right)
    if compareRows(left[leftIndex], right[rightIndex], orderItems) <= 0 then
      output = output + [left[leftIndex]]
      leftIndex = leftIndex + 1
    else
      output = output + [right[rightIndex]]
      rightIndex = rightIndex + 1
    end if
  end while
  while leftIndex < len(left)
    output = output + [left[leftIndex]]
    leftIndex = leftIndex + 1
  end while
  while rightIndex < len(right)
    output = output + [right[rightIndex]]
    rightIndex = rightIndex + 1
  end while
  return output
end function

// Sorts projected using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sortProjected(rows, orderItems)
  if typeof(rows) != "array" or typeof(orderItems) != "array" then return fail(INVALID_ARGUMENT, "sortProjected", "rows/orderItems must be arrays") end if
  if len(rows) <= 1 or len(orderItems) == 0 then return rows end if
  middle = len(rows) >> 1
  left = []
  right = []
  for index = 0 to len(rows) - 1
    if index < middle then left = left + [rows[index]] else right = right + [rows[index]] end if
  end for
  return merge(sortProjected(left, orderItems), sortProjected(right, orderItems), orderItems)
end function

// Retains only the best `count` rows in stable ORDER BY order. The optimizer
// limits this O(rows*count) implementation to small windows, avoiding external
// runs and a complete result sort for interactive ORDER BY ... LIMIT queries.
function topNProjected(rows, orderItems, count)
  if typeof(rows) != "array" or typeof(orderItems) != "array" or typeof(count) != "int" or count < 0 then return fail(INVALID_ARGUMENT, "topNProjected", "invalid arguments") end if
  if count == 0 or len(rows) == 0 then return [] end if
  if len(orderItems) == 0 then
    output = []
    for index = 0 to len(rows) - 1
      if index < count then output = output + [rows[index]] end if
    end for
    return output
  end if
  selected = []
  for each row in rows
    insertion = len(selected)
    if len(selected) > 0 then
      for index = 0 to len(selected) - 1
        if compareRows(row, selected[index], orderItems) < 0 then insertion = index; break end if
      end for
    end if
    if insertion < count then
      next = []
      inserted = false
      if len(selected) > 0 then
        for index = 0 to len(selected) - 1
          if not inserted and index == insertion then next = next + [row]; inserted = true end if
          if len(next) < count then next = next + [selected[index]] end if
        end for
      end if
      if not inserted and len(next) < count then next = next + [row] end if
      selected = next
    else if len(selected) < count then
      selected = selected + [row]
    end if
  end for
  return selected
end function

// Implements spill type for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function spillType(kind)
  if kind == types.SqlTypeKind.Char or kind == types.SqlTypeKind.VarChar then return types.SqlTypeKind.Text end if
  if kind == types.SqlTypeKind.Binary or kind == types.SqlTypeKind.VarBinary then return types.SqlTypeKind.Blob end if
  return kind
end function

// Implements spill spec for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function spillSpec(kind)
  stored = spillType(kind)
  precision = 0
  if stored == types.SqlTypeKind.Decimal then precision = 18 end if
  return row_codec.column(stored, true, 0, precision, 0)
end function

// Implements combined values for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function combinedValues(row)
  if not projection.isProjectedRow(row) then return fail(INVALID_ARGUMENT, "combinedValues", "row must be ProjectedRow") end if
  return row.values + row.orderValues
end function

// Implements spill schema for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function spillSchema(rows, valueCount, orderCount)
  if len(rows) == 0 then return fail(INVALID_ARGUMENT, "spillSchema", "run must contain rows") end if
  first = combinedValues(rows[0])
  if len(first) != valueCount + orderCount then return fail(INVALID_ARGUMENT, "spillSchema", "row shape mismatch") end if
  specs = []
  kinds = []
  for each value in first
    if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "spillSchema", "row contains non-SqlValue") end if
    specs = specs + [spillSpec(value.typeKind)]
    kinds = kinds + [value.typeKind]
  end for
  for each row in rows
    current = combinedValues(row)
    if len(current) != len(kinds) then return fail(INVALID_ARGUMENT, "spillSchema", "run rows have different shapes") end if
    if len(current) > 0 then
      for index = 0 to len(current) - 1
        if current[index].typeKind != kinds[index] then return fail(INVALID_ARGUMENT, "spillSchema", "run column type changed") end if
      end for
    end if
  end for
  return [row_codec.schema(1, specs), kinds]
end function

// Implements raw values for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rawValues(input)
  output = []
  for each value in input
    if value.isNull then output = output + [row_codec.nullValue()] else output = output + [value.value] end if
  end for
  return output
end function

// Encodes header using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function encodeHeader(valueCount, orderCount)
  output = bytes(SPILL_HEADER_SIZE, 0)
  copyBytes(output, 0, spillMagic(), 0, 8)
  endian.writeU16LE(output, 8, SPILL_VERSION)
  endian.writeU16LE(output, 10, valueCount)
  endian.writeU16LE(output, 12, orderCount)
  endian.writeU16LE(output, 14, 0)
  return output
end function

// Writes run using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function writeRun(path, rows, valueCount, orderCount)
  shaped = spillSchema(rows, valueCount, orderCount)
  schema = shaped[0]
  kinds = shaped[1]
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then return handle end if
  header = encodeHeader(valueCount, orderCount)
  written = try(file_api.writeAt(handle, 0, header, 0, len(header)))
  if typeof(written) == "error" then ignored = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(path)); return written end if
  cursor = len(header)
  for each row in rows
    encoded = try(row_codec.encode(schema, rawValues(combinedValues(row))))
    if typeof(encoded) == "error" then ignored = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(path)); return encoded end if
    if cursor > MAX_SPILL_FILE_BYTES - 4 - len(encoded) then
      ignored = try(file_api.close(handle))
      ignoredDelete = try(file_api.deletePath(path))
      return fail(INVALID_ARGUMENT, "writeRun", "spill run exceeds 256 MiB")
    end if
    lengthBytes = bytes(4, 0)
    endian.writeU32LE(lengthBytes, 0, len(encoded))
    wroteLength = try(file_api.writeAt(handle, cursor, lengthBytes, 0, 4))
    if typeof(wroteLength) == "error" then ignored = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(path)); return wroteLength end if
    cursor = cursor + 4
    wroteRow = try(file_api.writeAt(handle, cursor, encoded, 0, len(encoded)))
    if typeof(wroteRow) == "error" then ignored = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(path)); return wroteRow end if
    cursor = cursor + len(encoded)
  end for
  flushed = try(file_api.flush(handle))
  if typeof(flushed) == "error" then ignored = try(file_api.close(handle)); ignoredDelete = try(file_api.deletePath(path)); return flushed end if
  closed = try(file_api.close(handle))
  if typeof(closed) == "error" then ignoredDelete = try(file_api.deletePath(path)); return closed end if
  return SpillRun(path, schema, kinds, valueCount, orderCount, len(rows))
end function

// Decodes SQL value using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decodeSqlValue(kind, raw)
  if row_codec.isNull(raw) then return values.nullValue(kind) end if
  return values.of(kind, raw)
end function

// Reads run using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function readRun(run)
  if run is not SpillRun then return fail(INVALID_ARGUMENT, "readRun", "run must be SpillRun") end if
  handle = try(file_api.openRead(run.path))
  if typeof(handle) == "error" then return handle end if
  length = try(file_api.size(handle))
  if typeof(length) == "error" then ignored = try(file_api.close(handle)); return length end if
  if length < SPILL_HEADER_SIZE or length > MAX_SPILL_FILE_BYTES then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "spill file length is invalid") end if
  header = bytes(SPILL_HEADER_SIZE, 0)
  readHeader = try(file_api.readExactAt(handle, 0, header, 0, len(header)))
  if typeof(readHeader) == "error" then ignored = try(file_api.close(handle)); return readHeader end if
  if not bytesEqual(slice(header, 0, 8), spillMagic()) or endian.readU16LE(header, 8) != SPILL_VERSION then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "spill header mismatch") end if
  if endian.readU16LE(header, 10) != run.valueCount or endian.readU16LE(header, 12) != run.orderCount or endian.readU16LE(header, 14) != 0 then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "spill shape mismatch") end if
  cursor = SPILL_HEADER_SIZE
  output = []
  while cursor < length
    if length - cursor < 4 then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "truncated spill row length") end if
    lengthBytes = bytes(4, 0)
    readLength = try(file_api.readExactAt(handle, cursor, lengthBytes, 0, 4))
    if typeof(readLength) == "error" then ignored = try(file_api.close(handle)); return readLength end if
    rowLength = endian.readU32LE(lengthBytes, 0)
    cursor = cursor + 4
    if rowLength == 0 or rowLength > length - cursor then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "invalid spill row length") end if
    encoded = bytes(rowLength, 0)
    readRow = try(file_api.readExactAt(handle, cursor, encoded, 0, rowLength))
    if typeof(readRow) == "error" then ignored = try(file_api.close(handle)); return readRow end if
    cursor = cursor + rowLength
    decoded = try(row_codec.decodeRow(run.rowSchema, encoded))
    if typeof(decoded) == "error" then ignored = try(file_api.close(handle)); return decoded end if
    if len(decoded.values) != len(run.typeKinds) then ignored = try(file_api.close(handle)); return fail(CORRUPT_DATA, "readRun", "decoded spill row shape mismatch") end if
    sqlValues = []
    for index = 0 to len(decoded.values) - 1
      sqlValues = sqlValues + [decodeSqlValue(run.typeKinds[index], decoded.values[index])]
    end for
    projectedValues = []
    orderValues = []
    if run.valueCount > 0 then
      for index = 0 to run.valueCount - 1
        projectedValues = projectedValues + [sqlValues[index]]
      end for
    end if
    if run.orderCount > 0 then
      for index = run.valueCount to len(sqlValues) - 1
        orderValues = orderValues + [sqlValues[index]]
      end for
    end if
    output = output + [projection.ProjectedRow(void, projectedValues, orderValues)]
  end while
  closed = try(file_api.close(handle))
  if typeof(closed) == "error" then return closed end if
  if len(output) != run.rowCount then return fail(CORRUPT_DATA, "readRun", "spill row count mismatch") end if
  return output
end function

// Implements cleanup runs for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function cleanupRuns(runs)
  for each run in runs
    if run is SpillRun and file_api.fileExists(run.path) then ignored = try(file_api.deletePath(run.path)) end if
  end for
  return true
end function

// Generates a process-unique spill namespace under an intrinsic function lock.
// The synchronized modifier serializes nonce updates across parallel SELECT workers.
function synchronized nextSpillToken()
  global spillNonce
  spillNonce = spillNonce + 1
  if spillNonce > 2147483647 then spillNonce = 1 end if
  return "" + clock.monotonicMilliseconds() + "-" + spillNonce
end function

// Runs path using the supplied inputs.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function runPath(root, token, index)
  return file_api.joinPath(root, "sort-" + token + "-" + index + ".run")
end function

// Performs stable external merge sorting when rows exceed `threshold`.
// Sorted chunks are written as validated runs, then merged pairwise until one
// remains. Every success and failure path removes owned temporary files.
function sortProjectedWithSpill(rows, orderItems, temporaryRoot, threshold)
  if typeof(rows) != "array" or typeof(orderItems) != "array" or typeof(temporaryRoot) != "string" then return fail(INVALID_ARGUMENT, "sortProjectedWithSpill", "invalid arguments") end if
  if typeof(threshold) != "int" or threshold < 2 then return fail(INVALID_ARGUMENT, "sortProjectedWithSpill", "threshold must be at least two") end if
  if len(rows) <= threshold or len(orderItems) == 0 then return sortProjected(rows, orderItems) end if
  if not file_api.directoryExists(temporaryRoot) then
    created = try(file_api.createDirectory(temporaryRoot))
    if typeof(created) == "error" then return created end if
  end if
  valueCount = len(rows[0].values)
  orderCount = len(rows[0].orderValues)
  token = nextSpillToken()
  runs = []
  chunk = []
  sequence = 0
  for each row in rows
    chunk = chunk + [row]
    if len(chunk) >= threshold then
      sortedChunk = sortProjected(chunk, orderItems)
      createdRun = try(writeRun(runPath(temporaryRoot, token, sequence), sortedChunk, valueCount, orderCount))
      if typeof(createdRun) == "error" then cleanupRuns(runs); return createdRun end if
      runs = runs + [createdRun]
      sequence = sequence + 1
      chunk = []
    end if
  end for
  if len(chunk) > 0 then
    sortedChunk = sortProjected(chunk, orderItems)
    createdRun = try(writeRun(runPath(temporaryRoot, token, sequence), sortedChunk, valueCount, orderCount))
    if typeof(createdRun) == "error" then cleanupRuns(runs); return createdRun end if
    runs = runs + [createdRun]
    sequence = sequence + 1
  end if

  while len(runs) > 1
    nextRuns = []
    index = 0
    while index < len(runs)
      if index + 1 >= len(runs) then
        nextRuns = nextRuns + [runs[index]]
      else
        leftRows = try(readRun(runs[index]))
        if typeof(leftRows) == "error" then cleanupRuns(runs); cleanupRuns(nextRuns); return leftRows end if
        rightRows = try(readRun(runs[index + 1]))
        if typeof(rightRows) == "error" then cleanupRuns(runs); cleanupRuns(nextRuns); return rightRows end if
        merged = merge(leftRows, rightRows, orderItems)
        mergedRun = try(writeRun(runPath(temporaryRoot, token, sequence), merged, valueCount, orderCount))
        if typeof(mergedRun) == "error" then cleanupRuns(runs); cleanupRuns(nextRuns); return mergedRun end if
        ignoredLeft = try(file_api.deletePath(runs[index].path))
        ignoredRight = try(file_api.deletePath(runs[index + 1].path))
        nextRuns = nextRuns + [mergedRun]
        sequence = sequence + 1
      end if
      index = index + 2
    end while
    runs = nextRuns
  end while
  result = try(readRun(runs[0]))
  if typeof(result) == "error" then cleanupRuns(runs); return result end if
  cleanupRuns(runs)
  return result
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.sort"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M16"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
