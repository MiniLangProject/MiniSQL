//! Provides minisql client formatter facilities for this project.

package minisql.client.formatter

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import std.ds.list as list
import std.string_builder as string_builder
import std.math as math
import minisql.executor.executor as executor
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.sql.values as values

/// Defines the invalid argument constant used by the minisql client formatter module.
const INVALID_ARGUMENT = 9001

/// Performs the fail operation for the minisql client formatter module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "client.formatter." + operation + ": " + message)
end function

/// Implements value text for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function valueText(value)
  if not values.isSqlValue(value) then return fail("valueText", "value must be SqlValue") end if
  if value.isNull then return "NULL" end if
  if typeof(value.value) == "string" then return value.value end if
  if typeof(value.value) == "bytes" then return "0x" + hex(value.value) end if
  if typeof(value.value) == "bool" then
    if value.value then return "TRUE" end if
    return "FALSE"
  end if
  if typeof(value.value) == "int" or typeof(value.value) == "float" then return "" + value.value end if
  if endian.isInt64Words(value.value) then
    native = try(endian.int64ToInt(value.value))
    if typeof(native) != "error" then return "" + native end if
    return "0x" + value.value.high + ":" + value.value.low
  end if
  return fail("valueText", "unsupported SQL value representation")
end function

/// Formats a signed 64-bit word pair without converting through a lossy float.
function wordIntegerText(value)
  high = value.high
  low = value.low
  negative = high >= 2147483648
  if negative then
    high = 4294967295 - high
    low = 4294967295 - low + 1
    if low >= 4294967296 then low = low - 4294967296; high = high + 1 end if
  end if
  text = ""
  while high != 0 or low != 0
    quotientHigh = math.floorInt(high / 10)
    combined = (high - quotientHigh * 10) * 4294967296 + low
    quotientLow = math.floorInt(combined / 10)
    digit = combined - quotientLow * 10
    text = "" + digit + text
    high = quotientHigh
    low = quotientLow
  end while
  if len(text) == 0 then text = "0" end if
  if negative then text = "-" + text end if
  return text
end function

/// Canonicalizes typed output text, including scaled decimals and full-width integers.
function outputValueText(value, scale)
  text = valueText(value)
  if endian.isInt64Words(value.value) then text = wordIntegerText(value.value) end if
  if value.typeKind != 7 or scale <= 0 then return text end if
  negative = len(text) > 0 and bytes(text)[0] == 45
  if negative then text = decode(slice(bytes(text), 1, len(bytes(text)) - 1)) end if
  while len(text) <= scale
    text = "0" + text
  end while
  raw = bytes(text)
  text = decode(slice(raw, 0, len(raw) - scale)) + "." + decode(slice(raw, len(raw) - scale, scale))
  if negative then text = "-" + text end if
  return text
end function

/// Retains exact SQL NULL and native type information before textual encoding.
function decorateRows(response, sourceRows)
  extra = messages.newMetadata()
  extra.nullBitmap = bytes((len(sourceRows) * len(response.columns) + 7) >> 3, 0)
  extra.columnTypes = array(len(response.columns))
  if len(response.columns) > 0 then
    for index = 0 to len(response.columns) - 1
      extra.columnTypes[index] = 0
    end for
  end if
  position = 0
  for each row in sourceRows
    column = 0
    for each value in row
      if value.isNull then extra.nullBitmap[position >> 3] = extra.nullBitmap[position >> 3] | (1 << (position & 7)) end if
      if extra.columnTypes[column] == 0 then extra.columnTypes[column] = value.typeKind end if
      column = column + 1
      position = position + 1
    end for
  end for
  response.metadata = extra
  return response
end function

/// Implements response from result for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param result Result object populated or inspected by the operation.
function responseFromResult(result)
  if not executor.isQueryResult(result) then return fail("responseFromResult", "result must be QueryResult") end if
  if result.kind == executor.RESULT_MULTIPLE then
    children = []
    for each child in result.rows
      children = children + [responseFromResult(child)]
    end for
    return messages.multipleResponse(children)
  end if
  if result.kind == executor.RESULT_COMMAND then return messages.commandResponse(result.command, result.affectedRows, result.message) end if
  if result.kind != executor.RESULT_ROWS then return fail("responseFromResult", "unknown result kind") end if
  rows = array(len(result.rows))
  rowIndex = 0
  for each sourceRow in result.rows
    row = array(len(sourceRow))
    valueIndex = 0
    for each value in sourceRow
      row[valueIndex] = valueText(value)
      valueIndex = valueIndex + 1
    end for
    rows[rowIndex] = row
    rowIndex = rowIndex + 1
  end for
  return decorateRows(messages.rowResponse(result.columns, rows), result.rows)
end function

/// Converts a query result into bounded protocol responses. Row conversion and
/// payload construction are limited to one transport batch at a time, avoiding
/// the former second full-result string representation on the server heap.
/// @param result Result object populated or inspected by the operation.
function responsesFromResult(result)
  if not executor.isQueryResult(result) then return fail("responsesFromResult", "result must be QueryResult") end if
  if result.kind == executor.RESULT_MULTIPLE then
    output = list.List.new()
    for each child in result.rows
      batches = responsesFromResult(child)
      if len(batches) > 0 then batches[0].resultStart = true end if
      for each batch in batches
        output.add(batch)
      end for
    end for
    return output.toArray()
  end if
  if result.kind == executor.RESULT_COMMAND then return [messages.commandResponse(result.command, result.affectedRows, result.message)] end if
  if result.kind != executor.RESULT_ROWS then return fail("responsesFromResult", "unknown result kind") end if
  responses = list.List.new()
  batch = list.List.withCapacity(constants.DEFAULT_RESULT_BATCH_ROWS)
  sourceBatch = list.List.withCapacity(constants.DEFAULT_RESULT_BATCH_ROWS)
  baseBytes = messages.responsePayloadSize(messages.rowResponse(result.columns, []))
  batchBytes = baseBytes
  for each sourceRow in result.rows
    row = array(len(sourceRow))
    rowBytes = 0
    valueIndex = 0
    for each value in sourceRow
      row[valueIndex] = valueText(value)
      rowBytes = rowBytes + messages.fieldSize(row[valueIndex])
      valueIndex = valueIndex + 1
    end for
    if batch.len() > 0 and (batch.len() >= constants.DEFAULT_RESULT_BATCH_ROWS or batchBytes + rowBytes > constants.TARGET_RESULT_FRAME_BYTES) then
      responses.add(decorateRows(messages.rowResponse(result.columns, batch.toArray()), sourceBatch.toArray()))
      batch.clear()
      sourceBatch.clear()
      batchBytes = baseBytes
    end if
    batch.add(row)
    sourceBatch.add(sourceRow)
    batchBytes = batchBytes + rowBytes
  end for
  if batch.len() > 0 or responses.len() == 0 then responses.add(decorateRows(messages.rowResponse(result.columns, batch.toArray()), sourceBatch.toArray())) end if
  return responses.toArray()
end function

/// Formats response using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param response response value consumed by this operation.
function formatResponse(response)
  if not messages.isResponse(response) then return fail("formatResponse", "response must be Response") end if
  if response.status == constants.STATUS_MULTIPLE then
    sections = string_builder.StringBuilder.withCapacity(256)
    index = 0
    for each child in response.rows
      if index > 0 then sections.appendString("\n\n") end if
      sections.appendString(formatResponse(child))
      index = index + 1
    end for
    return sections.toString()
  end if
  if response.status == constants.STATUS_ERROR then return "ERROR " + response.errorCode + ": " + response.message end if
  if response.status == constants.STATUS_COMMAND then return response.command + " " + response.affectedRows + " " + response.message end if
  builder = string_builder.StringBuilder.withCapacity(256)
  if len(response.columns) > 0 then
    for index = 0 to len(response.columns) - 1
      if index > 0 then builder.appendString(" | ") end if
      builder.appendString(response.columns[index])
    end for
    builder.appendString("\n")
  end if
  for each row in response.rows
    if len(row) > 0 then
      for index = 0 to len(row) - 1
        if index > 0 then builder.appendString(" | ") end if
        builder.appendString(row[index])
      end for
    end if
    builder.appendString("\n")
  end for
  builder.appendString("(" + len(response.rows) + " rows)")
  return builder.toString()
end function

/// Performs the componentName operation for the minisql client formatter module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "client.formatter"
end function

/// Performs the targetMilestone operation for the minisql client formatter module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql client formatter module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
