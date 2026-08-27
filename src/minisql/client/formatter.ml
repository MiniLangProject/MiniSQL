package minisql.client.formatter

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import std.string_builder as string_builder
import minisql.executor.executor as executor
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.sql.values as values

const INVALID_ARGUMENT = 9001

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "client.formatter." + operation + ": " + message)
end function

// Implements value text for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements response from result for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function responseFromResult(result)
  if not executor.isQueryResult(result) then return fail("responseFromResult", "result must be QueryResult") end if
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
  return messages.rowResponse(result.columns, rows)
end function

// Converts a query result into bounded protocol responses. Row conversion and
// payload construction are limited to one transport batch at a time, avoiding
// the former second full-result string representation on the server heap.
function responsesFromResult(result)
  if not executor.isQueryResult(result) then return fail("responsesFromResult", "result must be QueryResult") end if
  if result.kind == executor.RESULT_COMMAND then return [messages.commandResponse(result.command, result.affectedRows, result.message)] end if
  if result.kind != executor.RESULT_ROWS then return fail("responsesFromResult", "unknown result kind") end if
  responses = []
  batch = []
  for each sourceRow in result.rows
    row = array(len(sourceRow))
    valueIndex = 0
    for each value in sourceRow
      row[valueIndex] = valueText(value)
      valueIndex = valueIndex + 1
    end for
    candidate = batch + [row]
    candidateResponse = messages.rowResponse(result.columns, candidate)
    if len(batch) > 0 and (len(candidate) > constants.DEFAULT_RESULT_BATCH_ROWS or messages.responsePayloadSize(candidateResponse) > constants.TARGET_RESULT_FRAME_BYTES) then
      responses = responses + [messages.rowResponse(result.columns, batch)]
      batch = [row]
    else
      batch = candidate
    end if
  end for
  if len(batch) > 0 or len(responses) == 0 then responses = responses + [messages.rowResponse(result.columns, batch)] end if
  return responses
end function

// Formats response using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function formatResponse(response)
  if not messages.isResponse(response) then return fail("formatResponse", "response must be Response") end if
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

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "client.formatter"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
