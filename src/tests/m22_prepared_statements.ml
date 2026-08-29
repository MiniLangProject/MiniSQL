// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.ast as ast
import minisql.sql.parser as parser
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the prepared statements test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M22 prepared statement tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m22_prepared", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE item (id INTEGER PRIMARY KEY, code VARCHAR(40) NOT NULL UNIQUE, amount INTEGER NOT NULL DEFAULT 0)")
  executeOne(engine, "INSERT INTO item(id, code, amount) VALUES (1, 'alpha', 10), (2, 'beta', 20)")

  parsed = parser.parseSql("PREPARE first_find AS SELECT code FROM item WHERE id = ?; PREPARE second_find AS SELECT amount FROM item WHERE id = ?")
  testkit.equal(state, len(parsed), 2, "two PREPARE statements parse")
  testkit.record(state, ast.isPrepareStatement(parsed[0]), "first statement is PREPARE")
  testkit.record(state, ast.isPrepareStatement(parsed[1]), "second statement is PREPARE")
  testkit.equal(state, parsed[0].parameterCount, 1, "first PREPARE local parameter count")
  testkit.equal(state, parsed[1].parameterCount, 1, "second PREPARE local parameter count")
  testkit.equal(state, parsed[0].statement.whereExpression.right.index, 0, "first PREPARE starts at parameter zero")
  testkit.equal(state, parsed[1].statement.whereExpression.right.index, 0, "second PREPARE starts at parameter zero")

  prepared = executor.executeSql(engine, "PREPARE find_item AS SELECT code, amount FROM item WHERE id = ?; PREPARE insert_item AS INSERT INTO item(id, code, amount) VALUES (?, ?, ?)")
  testkit.equal(state, len(prepared), 2, "prepare batch result count")
  testkit.equal(state, prepared[0].command, "PREPARE", "SELECT prepare command")
  testkit.equal(state, prepared[1].command, "PREPARE", "INSERT prepare command")

  found = executeOne(engine, "EXECUTE find_item USING 2")
  testkit.equal(state, len(found.rows), 1, "prepared SELECT row count")
  testkit.equal(state, found.rows[0][0].value, "beta", "prepared SELECT text")
  testkit.equal(state, found.rows[0][1].value, 20, "prepared SELECT number")

  inserted = executeOne(engine, "EXECUTE insert_item USING 3, 'gamma', 30")
  testkit.equal(state, inserted.command, "INSERT", "prepared INSERT returns inner command")
  testkit.equal(state, inserted.affectedRows, 1, "prepared INSERT count")

  executeOne(engine, "PREPARE update_item AS UPDATE item SET amount = ? WHERE id = ?")
  updated = executeOne(engine, "EXECUTE update_item USING 35, 3")
  testkit.equal(state, updated.affectedRows, 1, "prepared UPDATE count")
  testkit.equal(state, executeOne(engine, "SELECT amount FROM item WHERE id = 3").rows[0][0].value, 35, "prepared UPDATE value")

  executeOne(engine, "PREPARE delete_item AS DELETE FROM item WHERE id = ?")
  deleted = executeOne(engine, "EXECUTE delete_item USING 1")
  testkit.equal(state, deleted.affectedRows, 1, "prepared DELETE count")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM item WHERE id = 1").rows), 0, "prepared DELETE visible")

  testkit.errorCode(state, try(executor.executeSql(engine, "EXECUTE find_item")), 9020, "missing prepared parameter rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "EXECUTE find_item USING 2, 3")), 9020, "extra prepared parameter rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "EXECUTE find_item USING id")), 9020, "non-constant USING expression rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "PREPARE find_item AS SELECT id FROM item")), 9020, "duplicate prepared name rejected")

  // A second attached session publishes DDL through the shared in-memory
  // planning generation; EXECUTE must observe it without polling schema files.
  schemaSession = executor.attach(managed)
  executeOne(schemaSession, "ALTER TABLE item ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE")
  executor.close(schemaSession)
  afterSchemaChange = executeOne(engine, "EXECUTE find_item USING 2")
  testkit.equal(state, afterSchemaChange.rows[0][0].value, "beta", "prepared statement rebinds after schema change")
  testkit.record(state, afterSchemaChange.rows[0][1].value == 20, "prepared statement retains projection after schema change")

  deallocated = executeOne(engine, "DEALLOCATE PREPARE find_item")
  testkit.equal(state, deallocated.command, "DEALLOCATE", "DEALLOCATE command")
  testkit.errorCode(state, try(executor.executeSql(engine, "EXECUTE find_item USING 2")), 9020, "deallocated statement unavailable")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  testkit.errorCode(state, try(executor.executeSql(reopened, "EXECUTE insert_item USING 4, 'delta', 40")), 9020, "prepared statements are session scoped")
  durable = executeOne(reopened, "SELECT code, amount, active FROM item ORDER BY id")
  testkit.equal(state, len(durable.rows), 2, "prepared DML survives reopen")
  testkit.equal(state, durable.rows[0][0].value, "beta", "durable prepared row one")
  testkit.record(state, durable.rows[0][2].value, "metadata default visible after reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M22 prepared statement tests: SUCCESS", "MiniSQL M22 prepared statement tests: FAIL")
end function
