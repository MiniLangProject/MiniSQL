// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Converts either a direct integer or an integer-valued SQL wrapper into a host integer for assertions.
function intValue(value)
  if typeof(value.value) == "int" then return value.value end if
  return endian.int64ToInt(value.value)
end function

// Runs the scalar expressions test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M35 scalar expression tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m35_scalar", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  searched = executeOne(engine, "SELECT CASE WHEN 2 > 1 THEN 'yes' ELSE 'no' END AS answer")
  testkit.equal(state, searched.rows[0][0].value, "yes", "searched CASE")

  simple = executeOne(engine, "SELECT CASE 2 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE 'other' END AS answer")
  testkit.equal(state, simple.rows[0][0].value, "two", "simple CASE")

  castInteger = executeOne(engine, "SELECT CAST('42' AS INTEGER) AS value")
  testkit.equal(state, castInteger.rows[0][0].value, 42, "CAST text to integer")
  castText = executeOne(engine, "SELECT CAST(7 AS VARCHAR(8)) AS value")
  testkit.equal(state, castText.rows[0][0].value, "7", "CAST integer to text")
  castBoolean = executeOne(engine, "SELECT CAST('TRUE' AS BOOLEAN) AS value")
  testkit.record(state, castBoolean.rows[0][0].value, "CAST text to boolean")

  coalesced = executeOne(engine, "SELECT COALESCE(NULL, NULL, 'fallback') AS value")
  testkit.equal(state, coalesced.rows[0][0].value, "fallback", "COALESCE first non-NULL")
  nullified = executeOne(engine, "SELECT NULLIF(5, 5) AS value, NULLIF(5, 6) AS retained")
  testkit.record(state, nullified.rows[0][0].isNull, "NULLIF equal values returns NULL")
  testkit.equal(state, nullified.rows[0][1].value, 5, "NULLIF unequal values retains first")

  textFunctions = executeOne(engine, "SELECT LOWER('MiniSQL') AS lower_value, UPPER('MiniSQL') AS upper_value, CHAR_LENGTH('Grüße') AS characters, SUBSTRING('Grüße', 2, 3) AS middle, TRIM('  clean  ') AS trimmed, REPLACE('a-b-a', 'a', 'x') AS replaced, CONCAT('Mini', 'SQL') AS concatenated")
  testkit.equal(state, textFunctions.rows[0][0].value, "minisql", "LOWER ASCII conversion")
  testkit.equal(state, textFunctions.rows[0][1].value, "MINISQL", "UPPER ASCII conversion")
  testkit.equal(state, textFunctions.rows[0][2].value, 5, "CHAR_LENGTH counts UTF-8 characters")
  testkit.equal(state, textFunctions.rows[0][3].value, "rüß", "SUBSTRING uses character offsets")
  testkit.equal(state, textFunctions.rows[0][4].value, "clean", "TRIM removes surrounding spaces")
  testkit.equal(state, textFunctions.rows[0][5].value, "x-b-x", "REPLACE replaces all matches")
  testkit.equal(state, textFunctions.rows[0][6].value, "MiniSQL", "CONCAT combines text")
  unicodeReplace = executeOne(engine, "SELECT REPLACE('Grüße', 'ü', 'UE') AS replaced")
  testkit.equal(state, unicodeReplace.rows[0][0].value, "GrUEße", "REPLACE preserves unmatched multibyte UTF-8")

  numericFunctions = executeOne(engine, "SELECT ABS(-7) AS absolute_value, ROUND(2.6) AS rounded, CEIL(-2.2) AS ceiling, FLOOR(-2.2) AS floor_value, POWER(2, 10) AS powered")
  testkit.equal(state, numericFunctions.rows[0][0].value, 7, "ABS integer")
  testkit.equal(state, numericFunctions.rows[0][1].value, 3.0, "ROUND approximate number")
  testkit.equal(state, numericFunctions.rows[0][2].value, -2.0, "CEIL negative number")
  testkit.equal(state, numericFunctions.rows[0][3].value, -3.0, "FLOOR negative number")
  testkit.equal(state, numericFunctions.rows[0][4].value, 1024.0, "POWER numeric result")

  temporalFunctions = executeOne(engine, "SELECT DATE_PART('year', CAST(0 AS DATE)) AS year_value, DATE_PART('month', CAST(0 AS DATE)) AS month_value, DATE_PART('day', CAST(86400000000 AS TIMESTAMP)) AS day_value, DATE_PART('hour', CAST(3661000000 AS TIME)) AS hour_value, DATE_PART('minute', CAST(3661000000 AS TIME)) AS minute_value, DATE_PART('second', CAST(3661000000 AS TIME)) AS second_value")
  testkit.equal(state, temporalFunctions.rows[0][0].value, 1970, "DATE_PART year")
  testkit.equal(state, temporalFunctions.rows[0][1].value, 1, "DATE_PART month")
  testkit.equal(state, temporalFunctions.rows[0][2].value, 2, "DATE_PART timestamp day")
  testkit.equal(state, temporalFunctions.rows[0][3].value, 1, "DATE_PART hour")
  testkit.equal(state, temporalFunctions.rows[0][4].value, 1, "DATE_PART minute")
  testkit.equal(state, temporalFunctions.rows[0][5].value, 1, "DATE_PART second")

  executeOne(engine, "CREATE TABLE number_item (value INTEGER)")
  emptyAggregate = executeOne(engine, "SELECT COALESCE(SUM(value), 0) AS total FROM number_item")
  testkit.equal(state, intValue(emptyAggregate.rows[0][0]), 0, "COALESCE around aggregate")
  executeOne(engine, "INSERT INTO number_item(value) VALUES (2), (3)")
  aggregateCase = executeOne(engine, "SELECT CASE WHEN COUNT(*) > 0 THEN SUM(value) ELSE 0 END AS total FROM number_item")
  testkit.equal(state, intValue(aggregateCase.rows[0][0]), 5, "CASE around aggregates")

  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT COALESCE(1, 'text')")), 9017, "COALESCE incompatible result types rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT CAST('not-a-number' AS INTEGER)")), 9020, "invalid integer CAST rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT SUBSTRING('x', 0)")), 9001, "SUBSTRING rejects non-positive start")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT POWER(-2, 0.5)")), 9017, "POWER rejects undefined real domain")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M35 scalar expression tests: SUCCESS", "MiniSQL M35 scalar expression tests: FAIL")
end function
