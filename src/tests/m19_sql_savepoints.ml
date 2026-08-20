// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the sql savepoints test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M19 SQL savepoint tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m19_sql", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE item (id INTEGER PRIMARY KEY, name VARCHAR(40) NOT NULL UNIQUE)")

  executeOne(engine, "BEGIN ISOLATION LEVEL SERIALIZABLE READ WRITE")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (1, 'kept')")
  save = executeOne(engine, "SAVEPOINT before_optional")
  testkit.equal(state, save.command, "SAVEPOINT", "SAVEPOINT command")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (2, 'rolled-back')")
  visible = executeOne(engine, "SELECT id FROM item ORDER BY id")
  testkit.equal(state, len(visible.rows), 2, "read-your-writes before rollback-to")
  rollback = executeOne(engine, "ROLLBACK TO SAVEPOINT before_optional")
  testkit.equal(state, rollback.command, "ROLLBACK TO", "ROLLBACK TO command")
  executeOne(engine, "COMMIT")
  committed = executeOne(engine, "SELECT id, name FROM item ORDER BY id")
  testkit.equal(state, len(committed.rows), 1, "rollback-to excluded staged row from commit")
  testkit.equal(state, committed.rows[0][1].value, "kept", "earlier staged row committed")

  executeOne(engine, "BEGIN")
  executeOne(engine, "SAVEPOINT recover")
  failed = try(executor.executeSql(engine, "INSERT INTO item(id, name) VALUES (3, 'kept')"))
  testkit.errorCode(state, failed, 9022, "constraint error marks transaction failed")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT id FROM item")), 9011, "failed transaction blocks normal statements")
  executeOne(engine, "ROLLBACK TO recover")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (3, 'recovered')")
  executeOne(engine, "COMMIT")
  recovered = executeOne(engine, "SELECT name FROM item WHERE id = 3")
  testkit.equal(state, recovered.rows[0][0].value, "recovered", "rollback-to recovers failed SQL transaction")

  executeOne(engine, "BEGIN")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (4, 'before-shadow')")
  executeOne(engine, "SAVEPOINT same")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (5, 'between-shadows')")
  executeOne(engine, "SAVEPOINT same")
  executeOne(engine, "INSERT INTO item(id, name) VALUES (6, 'after-shadow')")
  executeOne(engine, "ROLLBACK TO same")
  executeOne(engine, "RELEASE SAVEPOINT same")
  executeOne(engine, "COMMIT")
  shadowRows = executeOne(engine, "SELECT id FROM item WHERE id >= 4 ORDER BY id")
  testkit.equal(state, len(shadowRows.rows), 2, "newest duplicate savepoint used")
  testkit.equal(state, shadowRows.rows[1][0].value, 5, "changes before newest duplicate retained")

  executeOne(engine, "BEGIN")
  executeOne(engine, "SAVEPOINT released")
  executeOne(engine, "RELEASE released")
  testkit.errorCode(state, try(executor.executeSql(engine, "ROLLBACK TO released")), 9011, "released SQL savepoint unavailable")
  executeOne(engine, "ROLLBACK")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M19 SQL savepoint tests: SUCCESS", "MiniSQL M19 SQL savepoint tests: FAIL")
end function
