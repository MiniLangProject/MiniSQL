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

// Runs the returning test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M38 RETURNING tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m38_returning", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE account (id INTEGER PRIMARY KEY, name VARCHAR(40) NOT NULL, balance INTEGER NOT NULL DEFAULT 0)")

  inserted = executeOne(engine, "INSERT INTO account(id, name, balance) VALUES (1, 'Ada', 10), (2, 'Bob', 20) RETURNING id, name AS owner, balance + 1 AS next_balance")
  testkit.equal(state, inserted.command, "INSERT", "INSERT RETURNING command")
  testkit.equal(state, inserted.affectedRows, 2, "INSERT RETURNING affected rows")
  testkit.equal(state, len(inserted.rows), 2, "INSERT RETURNING row count")
  testkit.equal(state, len(inserted.columns), 3, "INSERT RETURNING column count")
  testkit.equal(state, inserted.columns[1], "owner", "INSERT RETURNING alias")
  testkit.equal(state, inserted.rows[0][0].value, 1, "INSERT RETURNING first id")
  testkit.equal(state, inserted.rows[0][2].value, 11, "INSERT RETURNING expression")

  updated = executeOne(engine, "UPDATE account SET balance = balance + 5 WHERE id = 1 RETURNING id, balance")
  testkit.equal(state, updated.affectedRows, 1, "UPDATE RETURNING affected rows")
  testkit.equal(state, len(updated.rows), 1, "UPDATE RETURNING row count")
  testkit.equal(state, updated.rows[0][0].value, 1, "UPDATE RETURNING id")
  testkit.equal(state, updated.rows[0][1].value, 15, "UPDATE RETURNING post-update value")

  deleted = executeOne(engine, "DELETE FROM account WHERE id = 2 RETURNING *")
  testkit.equal(state, deleted.affectedRows, 1, "DELETE RETURNING affected rows")
  testkit.equal(state, len(deleted.columns), 3, "DELETE RETURNING star columns")
  testkit.equal(state, deleted.rows[0][0].value, 2, "DELETE RETURNING old id")
  testkit.equal(state, deleted.rows[0][1].value, "Bob", "DELETE RETURNING old text")
  testkit.equal(state, deleted.rows[0][2].value, 20, "DELETE RETURNING old value")

  executeOne(engine, "BEGIN")
  staged = executeOne(engine, "INSERT INTO account(id, name, balance) VALUES (3, 'Cara', 30) RETURNING id, name")
  testkit.equal(state, staged.rows[0][0].value, 3, "explicit transaction RETURNING row")
  executeOne(engine, "ROLLBACK")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM account WHERE id = 3").rows), 0, "RETURNING does not force commit")

  executeOne(engine, "PREPARE add_account AS INSERT INTO account(id, name, balance) VALUES (?, ?, ?) RETURNING id, balance")
  prepared = executeOne(engine, "EXECUTE add_account USING 4, 'Dora', 40")
  testkit.equal(state, prepared.command, "INSERT", "prepared RETURNING command")
  testkit.equal(state, prepared.rows[0][0].value, 4, "prepared RETURNING id")
  testkit.equal(state, prepared.rows[0][1].value, 40, "prepared RETURNING value")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO account(id, name) VALUES (5, 'Eve') RETURNING COUNT(*)")), 9020, "aggregate RETURNING rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M38 RETURNING tests: SUCCESS", "MiniSQL M38 RETURNING tests: FAIL")
end function
