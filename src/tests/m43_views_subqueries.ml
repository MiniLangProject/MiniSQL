// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Runs the views subqueries test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M43 views and subqueries: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m43_views", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE source_item (id INTEGER PRIMARY KEY, amount INTEGER, enabled BOOLEAN)")
  executeOne(engine, "INSERT INTO source_item(id, amount, enabled) VALUES (1, 10, TRUE), (2, 20, FALSE), (3, NULL, TRUE)")

  scalar = executeOne(engine, "SELECT (SELECT amount FROM source_item WHERE id = 2) AS amount")
  testkit.equal(state, scalar.rows[0][0].value, 20, "scalar subquery one row")
  emptyScalar = executeOne(engine, "SELECT (SELECT amount FROM source_item WHERE id = 99) AS amount")
  testkit.record(state, emptyScalar.rows[0][0].isNull, "scalar subquery zero rows returns NULL")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT (SELECT amount FROM source_item) AS amount")), 9020, "scalar subquery rejects multiple rows")

  existsResult = executeOne(engine, "SELECT EXISTS (SELECT id FROM source_item WHERE enabled = TRUE) AS present, EXISTS (SELECT id FROM source_item WHERE id = 99) AS absent")
  testkit.record(state, existsResult.rows[0][0].value, "EXISTS true")
  testkit.record(state, not existsResult.rows[0][1].value, "EXISTS false")

  inResult = executeOne(engine, "SELECT id FROM source_item WHERE id IN (SELECT id FROM source_item WHERE enabled = TRUE) ORDER BY id")
  testkit.equal(state, len(inResult.rows), 2, "IN subquery row count")
  testkit.equal(state, inResult.rows[0][0].value, 1, "IN subquery first row")
  testkit.equal(state, inResult.rows[1][0].value, 3, "IN subquery second row")
  notInResult = executeOne(engine, "SELECT id FROM source_item WHERE id NOT IN (SELECT amount FROM source_item) ORDER BY id")
  testkit.equal(state, len(notInResult.rows), 0, "NOT IN subquery observes NULL semantics")

  executeOne(engine, "CREATE VIEW active_item AS SELECT id, amount FROM source_item WHERE enabled = TRUE")
  viewRows = executeOne(engine, "SELECT id FROM active_item ORDER BY id")
  testkit.equal(state, len(viewRows.rows), 2, "view row count")
  testkit.equal(state, viewRows.rows[1][0].value, 3, "view result")
  executeOne(engine, "CREATE OR REPLACE VIEW active_item AS SELECT id, amount FROM source_item WHERE enabled = FALSE")
  replaced = executeOne(engine, "SELECT id FROM active_item")
  testkit.equal(state, len(replaced.rows), 1, "replaced view row count")
  testkit.equal(state, replaced.rows[0][0].value, 2, "replaced view result")

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT id FROM active_item")
  testkit.equal(state, len(durable.rows), 1, "view survives reopen")
  executeOne(reopened, "DROP VIEW active_item")
  testkit.errorCode(state, try(executor.executeSql(reopened, "SELECT * FROM active_item")), 9014, "dropped view is unavailable")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M43 views and subqueries: SUCCESS", "MiniSQL M43 views and subqueries: FAIL")
end function
