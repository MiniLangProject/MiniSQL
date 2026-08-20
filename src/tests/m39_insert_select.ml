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

// Runs the insert select test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M39 INSERT SELECT tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m39_insert_select", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE source_item (id INTEGER PRIMARY KEY, label VARCHAR(30), amount INTEGER)")
  executeOne(engine, "CREATE TABLE target_item (id INTEGER PRIMARY KEY, label VARCHAR(30), amount INTEGER NOT NULL DEFAULT 7)")
  executeOne(engine, "INSERT INTO source_item(id, label, amount) VALUES (1, 'one', 10), (2, 'two', 20), (3, 'three', 30)")

  copied = executeOne(engine, "INSERT INTO target_item(id, label, amount) SELECT id, label, amount * 2 FROM source_item WHERE amount >= 20 ORDER BY id RETURNING id, amount")
  testkit.equal(state, copied.affectedRows, 2, "INSERT SELECT affected rows")
  testkit.equal(state, len(copied.rows), 2, "INSERT SELECT RETURNING rows")
  if len(copied.rows) >= 1 then
    testkit.equal(state, copied.rows[0][0].value, 2, "INSERT SELECT first id")
    testkit.equal(state, copied.rows[0][1].value, 40, "INSERT SELECT expression")
  end if
  if len(copied.rows) >= 2 then
    testkit.equal(state, copied.rows[1][0].value, 3, "INSERT SELECT second id")
  end if

  defaulted = executeOne(engine, "INSERT INTO target_item(id, label) SELECT id + 10, label FROM source_item WHERE id = 1 RETURNING id, amount")
  testkit.equal(state, len(defaulted.rows), 1, "INSERT SELECT default RETURNING rows")
  if len(defaulted.rows) >= 1 then
    testkit.equal(state, defaulted.rows[0][0].value, 11, "INSERT SELECT selected target columns")
    testkit.equal(state, defaulted.rows[0][1].value, 7, "INSERT SELECT target default")
  end if

  selfCopy = executeOne(engine, "INSERT INTO target_item(id, label, amount) SELECT id + 100, label, amount FROM target_item RETURNING id")
  testkit.equal(state, selfCopy.affectedRows, 3, "self INSERT SELECT materializes finite source")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM target_item").rows), 6, "self INSERT SELECT final count")

  executeOne(engine, "CREATE TABLE rollback_target (id INTEGER PRIMARY KEY, label VARCHAR(30))")
  executeOne(engine, "BEGIN")
  staged = executeOne(engine, "INSERT INTO rollback_target(id, label) SELECT id, label FROM source_item RETURNING id")
  testkit.equal(state, staged.affectedRows, 3, "transactional INSERT SELECT staged")
  executeOne(engine, "ROLLBACK")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM rollback_target").rows), 0, "INSERT SELECT rollback")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO target_item(id, label) SELECT id FROM source_item")), 9020, "INSERT SELECT column-count mismatch rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO target_item(id) SELECT label FROM source_item")), 9017, "INSERT SELECT type mismatch rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M39 INSERT SELECT tests: SUCCESS", "MiniSQL M39 INSERT SELECT tests: FAIL")
end function
