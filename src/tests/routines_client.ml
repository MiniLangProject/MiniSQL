// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.console as console
import minisql.client.formatter as formatter
import minisql.executor.executor as executor
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.server.session as session
import minisql.sql.values as values
import tests.support.testkit as testkit

/// Verifies script and interactive client delimiters without executing database changes.
function delimiterCases(state)
  script = "DELIMITER $$\nCREATE PROCEDURE p() BEGIN SELECT ';$$'; SELECT 2; END$$\nDELIMITER ;\nCALL p();"
  batch = console.scanSqlBatch(script, true)
  testkit.equal(state, len(batch.statements), 2, "compound procedure remains one request")
  testkit.equal(state, batch.statements[0], "CREATE PROCEDURE p() BEGIN SELECT ';$$'; SELECT 2; END", "custom terminator removed, body semicolons retained")
  testkit.equal(state, batch.statements[1], "CALL p();", "ordinary delimiter restored")
  testkit.equal(state, batch.delimiter, ";", "script publishes final delimiter")

  prefix = console.scanSqlBatchWithDelimiter("delimiter //\n", false, ";")
  testkit.equal(state, len(prefix.statements), 0, "interactive delimiter is never SQL")
  testkit.equal(state, prefix.delimiter, "//", "interactive delimiter retained")
  partial = console.scanSqlBatchWithDelimiter("CREATE PROCEDURE p() BEGIN SELECT 1;\n", false, prefix.delimiter)
  testkit.equal(state, len(partial.statements), 0, "body awaits custom terminator")
  finished = console.scanSqlBatchWithDelimiter(partial.remainder + "\nEND//\n", false, partial.delimiter)
  testkit.equal(state, len(finished.statements), 1, "interactive body completed")
  testkit.equal(state, finished.remainder, "", "no stale delimiter suffix")

  quoted = console.scanSqlBatch("DELIMITER $$\nSELECT `a$$b`, 'x''$$y' /* $$ */ -- $$\n$$\n", true)
  testkit.equal(state, len(quoted.statements), 1, "strings identifiers and comments hide delimiters")
  testkit.errorCode(state, try(console.scanSqlBatch("DELIMITER\nSELECT 1;", true)), 9001, "empty delimiter rejected")
  testkit.errorCode(state, try(console.scanSqlBatch("DELIMITER a b\n", true)), 9001, "whitespace delimiter rejected")
  testkit.errorCode(state, try(console.scanSqlBatch("SELECT `unfinished", true)), 9001, "unterminated backtick rejected")
  transaction = console.scanSqlBatch("BEGIN; SELECT 1; COMMIT;", true)
  testkit.equal(state, len(transaction.statements), 3, "transaction BEGIN remains an ordinary statement")
  return true
end function

/// Verifies separate result boundaries and bounded batching with identical schemas.
function multipleResultCases(state)
  rows = []
  for index = 0 to 512
    rows = rows + [[values.integer(index)]]
  end for
  first = executor.QueryResult(executor.RESULT_ROWS, "SELECT", ["number"], rows, len(rows), "")
  second = executor.QueryResult(executor.RESULT_ROWS, "SELECT", ["number"], [[values.integer(99)]], 1, "")
  empty = executor.QueryResult(executor.RESULT_ROWS, "SELECT", ["empty"], [], 0, "")
  command = executor.QueryResult(executor.RESULT_COMMAND, "CALL", [], [], 7, "p")
  multiple = executor.QueryResult(executor.RESULT_MULTIPLE, "CALL", [], [first, second, empty, command], 7, "p")
  converted = formatter.responsesFromResult(multiple)
  testkit.equal(state, len(converted), 5, "large first result is batched separately")
  testkit.record(state, converted[0].resultStart, "first result begins")
  testkit.record(state, not converted[1].resultStart, "row continuation is not a result boundary")
  testkit.record(state, converted[2].resultStart, "same-column second SELECT starts a new result")
  testkit.record(state, converted[3].resultStart, "empty result has a boundary")
  testkit.record(state, converted[4].resultStart, "final CALL command has a boundary")
  testkit.equal(state, session.resultRowCount(multiple), 514, "row limit covers every result")
  frames = session.responseMessages(messages.query(17, "CALL p()"), converted)
  testkit.equal(state, frames[0].flags, constants.FLAG_MORE | constants.FLAG_RESULT_START, "first result flags")
  testkit.equal(state, frames[1].flags, constants.FLAG_MORE, "batch continuation flags")
  testkit.equal(state, frames[4].flags, constants.FLAG_RESULT_START, "final result closes request")
  testkit.equal(state, messages.decodeResponse(frames[4].payload).affectedRows, 7, "final affected count survives protocol")
  aggregate = formatter.responseFromResult(multiple)
  testkit.equal(state, aggregate.status, constants.STATUS_MULTIPLE, "in-memory multi response")
  testkit.equal(state, len(messages.individualResponses(aggregate)), 4, "aggregate exposes all logical results")
  ordinary = session.responseMessages(messages.query(18, "SELECT 1"), formatter.responsesFromResult(second))
  testkit.equal(state, ordinary[0].flags, 0, "legacy single-result frame unchanged")
  return true
end function

/// Round-trips opt-in metadata without changing the legacy payload or NULL token.
function structuredResultCases(state)
  result = executor.rowResult(["literal", "missing", "count"], [[values.text("NULL"), values.nullValue(10), values.integer(42)]])
  response = formatter.responseFromResult(result)
  response.metadata.warnings = [messages.Condition("01000", 1642, "careful")]
  response.metadata.outputs = [messages.OutputParameter(2, "text_out", 10, false, "NULL"), messages.OutputParameter(3, "empty_out", 10, true, "")]
  legacy = messages.decodeResponse(messages.encodeResponse(response))
  testkit.record(state, legacy.metadata is void, "unnegotiated payload carries no trailer")
  testkit.equal(state, legacy.rows[0][0], "NULL", "legacy literal token unchanged")
  decoded = messages.decodeResponse(messages.encodeResponseExtended(response))
  testkit.record(state, not messages.isNullCell(decoded, 0, 0), "literal NULL is non-null with metadata")
  testkit.record(state, messages.isNullCell(decoded, 0, 1), "SQL NULL has an explicit bit")
  testkit.equal(state, decoded.metadata.columnTypes[2], 3, "integer type survives")
  testkit.equal(state, decoded.metadata.warnings[0].sqlState, "01000", "warning SQLSTATE survives")
  testkit.equal(state, decoded.metadata.outputs[0].value, "NULL", "output literal NULL survives")
  testkit.record(state, decoded.metadata.outputs[1].isNull, "output SQL NULL survives")
  joined = messages.appendRows(decoded, messages.decodeResponse(messages.encodeResponseExtended(response)))
  testkit.record(state, messages.isNullCell(joined, 1, 1), "NULL bitmap appends across partial bytes")
  testkit.record(state, not messages.isNullCell(joined, 1, 0), "NULL bitmap does not mark adjacent text")
  request = messages.query(20, "CALL p()")
  request.flags = constants.FLAG_METADATA
  frame = session.responseMessage(request, response)
  testkit.equal(state, frame.flags, constants.FLAG_METADATA, "structured response marks capability flag")
  testkit.equal(state, messages.decodeResponse(frame.payload).metadata.outputs[0].ordinal, 2, "final output declaration ordinal survives")
  return true
end function

/// Runs client-side stored procedure regression checks.
function main(args)
  state = testkit.create()
  delimiterCases(state)
  multipleResultCases(state)
  structuredResultCases(state)
  return testkit.finish(state, "MiniSQL stored procedure client tests: SUCCESS", "MiniSQL stored procedure client tests: FAIL")
end function
