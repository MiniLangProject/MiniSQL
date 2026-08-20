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

// Runs the conflict nothing test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M40 ON CONFLICT DO NOTHING tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m40_conflict_nothing", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE contact (id INTEGER PRIMARY KEY, email VARCHAR(80) UNIQUE, label VARCHAR(30))")
  executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (1, 'a@example.test', 'first')")

  primarySkip = executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (1, 'other@example.test', 'duplicate id') ON CONFLICT DO NOTHING RETURNING id")
  testkit.equal(state, primarySkip.affectedRows, 0, "untargeted primary-key conflict skipped")
  testkit.equal(state, len(primarySkip.rows), 0, "skipped row not returned")

  uniqueSkip = executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (2, 'a@example.test', 'duplicate email') ON CONFLICT DO NOTHING")
  testkit.equal(state, uniqueSkip.affectedRows, 0, "untargeted unique conflict skipped")

  mixed = executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (1, 'x@example.test', 'skip'), (2, 'b@example.test', 'insert') ON CONFLICT DO NOTHING RETURNING id, email")
  testkit.equal(state, mixed.affectedRows, 1, "mixed conflict batch affected rows")
  testkit.equal(state, len(mixed.rows), 1, "mixed conflict RETURNING rows")
  testkit.equal(state, mixed.rows[0][0].value, 2, "mixed conflict returned inserted id")

  targetedId = executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (1, 'c@example.test', 'target id') ON CONFLICT (id) DO NOTHING")
  testkit.equal(state, targetedId.affectedRows, 0, "targeted primary-key conflict skipped")
  targetedEmail = executeOne(engine, "INSERT INTO contact(id, email, label) VALUES (3, 'b@example.test', 'target email') ON CONFLICT (email) DO NOTHING")
  testkit.equal(state, targetedEmail.affectedRows, 0, "targeted unique conflict skipped")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO contact(id, email, label) VALUES (3, 'b@example.test', 'wrong target') ON CONFLICT (id) DO NOTHING")), 9022, "non-target unique conflict remains an error")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO contact(id, email, label) VALUES (4, 'd@example.test', 'bad target') ON CONFLICT (label) DO NOTHING")), 9020, "invalid conflict target rejected")

  executeOne(engine, "CREATE TABLE nullable_unique (id INTEGER PRIMARY KEY, optional_code VARCHAR(20) UNIQUE)")
  nulls = executeOne(engine, "INSERT INTO nullable_unique(id, optional_code) VALUES (1, NULL), (2, NULL) ON CONFLICT DO NOTHING")
  testkit.equal(state, nulls.affectedRows, 2, "multiple NULL unique values do not conflict")

  executeOne(engine, "CREATE TABLE pair_item (id INTEGER PRIMARY KEY, left_key INTEGER, right_key INTEGER, UNIQUE (left_key, right_key))")
  executeOne(engine, "INSERT INTO pair_item(id, left_key, right_key) VALUES (1, 10, 20)")
  pairSkip = executeOne(engine, "INSERT INTO pair_item(id, left_key, right_key) VALUES (2, 10, 20) ON CONFLICT (left_key, right_key) DO NOTHING")
  testkit.equal(state, pairSkip.affectedRows, 0, "composite conflict target skipped")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO pair_item(id, left_key, right_key) VALUES (3, 10, 20) ON CONFLICT (right_key, left_key) DO NOTHING")), 9020, "composite target order must match persisted constraint")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M40 ON CONFLICT DO NOTHING tests: SUCCESS", "MiniSQL M40 ON CONFLICT DO NOTHING tests: FAIL")
end function
