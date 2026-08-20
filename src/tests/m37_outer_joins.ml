// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.console as console
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Runs the outer joins test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M37 outer join tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m37_outer", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE left_item (id INTEGER PRIMARY KEY, label VARCHAR(20))")
  executeOne(engine, "CREATE TABLE right_item (id INTEGER PRIMARY KEY, label VARCHAR(20))")
  executeOne(engine, "INSERT INTO left_item(id, label) VALUES (1, 'left-only'), (2, 'matched')")
  executeOne(engine, "INSERT INTO right_item(id, label) VALUES (2, 'matched'), (3, 'right-only')")

  rightJoined = executeOne(engine, "SELECT l.id AS left_id, r.id AS right_id FROM left_item l RIGHT OUTER JOIN right_item r ON l.id = r.id ORDER BY r.id")
  testkit.equal(state, len(rightJoined.rows), 2, "RIGHT JOIN row count")
  testkit.equal(state, rightJoined.rows[0][0].value, 2, "RIGHT JOIN matched left")
  testkit.equal(state, rightJoined.rows[0][1].value, 2, "RIGHT JOIN matched right")
  testkit.record(state, rightJoined.rows[1][0].isNull, "RIGHT JOIN null-extends left")
  testkit.equal(state, rightJoined.rows[1][1].value, 3, "RIGHT JOIN unmatched right")

  fullJoined = executeOne(engine, "SELECT l.id AS left_id, r.id AS right_id FROM left_item l FULL OUTER JOIN right_item r ON l.id = r.id ORDER BY COALESCE(l.id, r.id)")
  testkit.equal(state, len(fullJoined.rows), 3, "FULL OUTER JOIN row count")
  testkit.equal(state, fullJoined.rows[0][0].value, 1, "FULL JOIN left-only key")
  testkit.record(state, fullJoined.rows[0][1].isNull, "FULL JOIN null-extends right")
  testkit.equal(state, fullJoined.rows[1][0].value, 2, "FULL JOIN matched left key")
  testkit.equal(state, fullJoined.rows[1][1].value, 2, "FULL JOIN matched right key")
  testkit.record(state, fullJoined.rows[2][0].isNull, "FULL JOIN null-extends left")
  testkit.equal(state, fullJoined.rows[2][1].value, 3, "FULL JOIN right-only key")

  plan = executeOne(engine, "EXPLAIN SELECT * FROM left_item l FULL JOIN right_item r ON l.id = r.id")
  found = false
  for each row in plan.rows
    if console.startsWithText(console.trimAscii(row[0].value), "Full Outer Join") then found = true end if
  end for
  testkit.record(state, found, "EXPLAIN identifies Full Outer Join")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M37 outer join tests: SUCCESS", "MiniSQL M37 outer join tests: FAIL")
end function
