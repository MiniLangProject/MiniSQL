// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the dcl authorization test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M21 DCL authorization tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m21_dcl", config_model.defaultDatabaseSettings(4096))
  admin = executor.attach(managed)

  executeOne(admin, "CREATE TABLE docs (id INTEGER PRIMARY KEY, title VARCHAR(80) NOT NULL)")
  executeOne(admin, "INSERT INTO docs(id, title) VALUES (1, 'first')")
  executeOne(admin, "CREATE USER alice WITH PASSWORD 'Alice-Password-21!'")
  executeOne(admin, "CREATE USER bob WITH PASSWORD 'Bob-Password-2021!'")
  executeOne(admin, "CREATE ROLE reader")
  executeOne(admin, "CREATE ROLE reporter")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO alice")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO bob")
  executeOne(admin, "GRANT SELECT ON TABLE docs TO reader")
  executeOne(admin, "GRANT reader TO alice")

  alicePrincipal = catalog.findPrincipal(managed.catalogHandle, "alice")
  bobPrincipal = catalog.findPrincipal(managed.catalogHandle, "bob")
  alice = executor.attach(managed)
  bob = executor.attach(managed)
  executor.setPrincipal(alice, alicePrincipal.principalId)
  executor.setPrincipal(bob, bobPrincipal.principalId)

  rows = executeOne(alice, "SELECT id, title FROM docs ORDER BY id")
  testkit.equal(state, len(rows.rows), 1, "role-based SELECT succeeds")
  testkit.errorCode(state, try(executor.executeSql(alice, "INSERT INTO docs(id, title) VALUES (2, 'denied')")), 9029, "INSERT denied without privilege")

  executeOne(admin, "GRANT INSERT ON TABLE docs TO alice")
  inserted = executeOne(alice, "INSERT INTO docs(id, title) VALUES (2, 'allowed')")
  testkit.equal(state, inserted.affectedRows, 1, "direct INSERT privilege succeeds")

  testkit.errorCode(state, try(executor.executeSql(bob, "SELECT id FROM docs")), 9029, "bob initially lacks SELECT")
  executeOne(admin, "GRANT SELECT ON TABLE docs TO public")
  publicRows = executeOne(bob, "SELECT id FROM docs ORDER BY id")
  testkit.equal(state, len(publicRows.rows), 2, "PUBLIC SELECT applies to every user")

  executeOne(admin, "GRANT CREATE ON DATABASE TO alice")
  executeOne(alice, "CREATE TABLE own_data (id INTEGER PRIMARY KEY, value INTEGER)")
  ownInsert = executeOne(alice, "INSERT INTO own_data(id, value) VALUES (1, 42)")
  testkit.equal(state, ownInsert.affectedRows, 1, "table owner can insert")
  ownRows = executeOne(alice, "SELECT value FROM own_data")
  testkit.equal(state, ownRows.rows[0][0].value, 42, "table owner can select")
  executeOne(alice, "DROP TABLE own_data")
  testkit.record(state, catalog.findTable(managed.catalogHandle, "own_data") is void, "table owner can drop")

  executeOne(admin, "GRANT SELECT ON TABLE docs TO alice WITH GRANT OPTION")
  executeOne(alice, "GRANT SELECT ON TABLE docs TO bob")
  testkit.record(state, catalog.hasPrivilege(managed.catalogHandle, bobPrincipal.principalId, metadata.OBJECT_TABLE, catalog.findTable(managed.catalogHandle, "docs").tableId, metadata.PRIVILEGE_SELECT, false), "grant option delegates privilege")

  executeOne(admin, "GRANT reporter TO alice WITH ADMIN OPTION")
  executeOne(alice, "GRANT reporter TO bob")
  reporter = catalog.findPrincipal(managed.catalogHandle, "reporter")
  testkit.record(state, catalog.hasRoleAdminOption(managed.catalogHandle, alicePrincipal.principalId, reporter.principalId), "ADMIN OPTION persists")
  effectiveBob = catalog.effectivePrincipalIds(managed.catalogHandle, bobPrincipal.principalId)
  hasReporter = false
  for each principalId in effectiveBob
    if principalId == reporter.principalId then hasReporter = true end if
  end for
  testkit.record(state, hasReporter, "role administrator delegates membership")

  executeOne(alice, "ALTER USER alice WITH PASSWORD 'Alice-New-Password-21!'")
  testkit.record(state, catalog.authenticatePassword(managed.catalogHandle, "alice", "Alice-New-Password-21!"), "user changes own password")
  testkit.record(state, not catalog.authenticatePassword(managed.catalogHandle, "alice", "Alice-Password-21!"), "old password invalidated")
  testkit.errorCode(state, try(executor.executeSql(alice, "CREATE USER eve WITH PASSWORD 'Eve-Password-2021!'")), 9029, "non-admin cannot create users")

  executeOne(admin, "CREATE ROLE cycle_a")
  executeOne(admin, "CREATE ROLE cycle_b")
  executeOne(admin, "GRANT cycle_a TO cycle_b")
  testkit.errorCode(state, try(executor.executeSql(admin, "GRANT cycle_b TO cycle_a")), 9001, "role membership cycle rejected")

  executeOne(alice, "BEGIN")
  testkit.errorCode(state, try(executor.executeSql(alice, "GRANT SELECT ON TABLE docs TO bob")), 9025, "DCL in explicit transaction rejected")
  executeOne(alice, "ROLLBACK")

  executor.close(bob)
  executor.close(alice)
  executor.close(admin)
  database_manager.close(managed)
  reopened = database_manager.open(managed.path)
  reopenedAdmin = executor.attach(reopened)
  durableDocs = executeOne(reopenedAdmin, "SELECT id, title FROM docs ORDER BY id")
  testkit.equal(state, len(durableDocs.rows), 2, "restart skips WAL images for the dropped table and preserves live rows")
  testkit.record(state, catalog.findTable(reopened.catalogHandle, "own_data") is void, "restart does not resurrect dropped table")
  executor.close(reopenedAdmin)
  database_manager.close(reopened)
  return testkit.finish(state, "MiniSQL M21 DCL authorization tests: SUCCESS", "MiniSQL M21 DCL authorization tests: FAIL")
end function
