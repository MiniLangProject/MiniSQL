// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.console as console
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Scans an EXPLAIN result for a row whose text begins with the requested physical-plan prefix.
function planContains(result, prefix)
  for each row in result.rows
    if console.startsWithText(console.trimAscii(row[0].value), prefix) then return true end if
  end for
  return false
end function

// Runs the optimizer executor v2 test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M46 optimizer executor v2: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m46_optimizer", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE left_hash (id INTEGER PRIMARY KEY, join_key INTEGER NOT NULL, payload INTEGER NOT NULL)")
  executeOne(engine, "CREATE TABLE right_hash (id INTEGER PRIMARY KEY, join_key INTEGER NOT NULL, payload INTEGER NOT NULL)")
  leftSql = "INSERT INTO left_hash(id, join_key, payload) VALUES "
  rightSql = "INSERT INTO right_hash(id, join_key, payload) VALUES "
  for index = 1 to 200
    if index > 1 then leftSql = leftSql + ", " end if
    leftSql = leftSql + "(" + index + ", " + (index % 50) + ", " + (201 - index) + ")"
  end for
  for index = 1 to 100
    if index > 1 then rightSql = rightSql + ", " end if
    rightSql = rightSql + "(" + index + ", " + (index % 50) + ", " + index + ")"
  end for
  executeOne(engine, leftSql)
  executeOne(engine, rightSql)
  executeOne(engine, "ANALYZE")

  joined = executeOne(engine, "SELECT COUNT(*) AS c FROM left_hash l INNER JOIN right_hash r ON l.join_key = r.join_key")
  testkit.equal(state, endian.int64ToInt(joined.rows[0][0].value), 400, "hash join result")
  joinPlan = executeOne(engine, "EXPLAIN SELECT l.id FROM left_hash l INNER JOIN right_hash r ON l.join_key = r.join_key")
  testkit.record(state, planContains(joinPlan, "Hash Join"), "optimizer selects Hash Join")

  grouped = executeOne(engine, "SELECT join_key, COUNT(*) AS c FROM left_hash GROUP BY join_key ORDER BY join_key")
  testkit.equal(state, len(grouped.rows), 50, "hash aggregate group count")
  testkit.equal(state, endian.int64ToInt(grouped.rows[0][1].value), 4, "hash aggregate group cardinality")
  aggregatePlan = executeOne(engine, "EXPLAIN SELECT join_key, COUNT(*) FROM left_hash GROUP BY join_key")
  testkit.record(state, planContains(aggregatePlan, "Hash Aggregate"), "optimizer selects Hash Aggregate")

  sorted = executeOne(engine, "SELECT id, payload FROM left_hash ORDER BY payload, id")
  testkit.equal(state, len(sorted.rows), 200, "external sort row count")
  testkit.equal(state, sorted.rows[0][1].value, 1, "external sort first value")
  testkit.equal(state, sorted.rows[199][1].value, 200, "external sort last value")
  sortPlan = executeOne(engine, "EXPLAIN SELECT id, payload FROM left_hash ORDER BY payload, id")
  testkit.record(state, planContains(sortPlan, "External Merge Sort"), "optimizer selects External Merge Sort")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M46 optimizer executor v2: SUCCESS", "MiniSQL M46 optimizer executor v2: FAIL")
end function
