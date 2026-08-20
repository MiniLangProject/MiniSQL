// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.backup as backup
import minisql.tools.check as checker
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Returns true when a backup manifest declares the required security catalog entry.
function manifestHasSecurity(manifest)
  for each entry in manifest.entries
    if entry.relativePath == "catalog\\security.tbl" then return true end if
  end for
  return false
end function

// Runs the security tools test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M21 security backup/check tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  root = args[0]
  backupPath = file_api.joinPath(root, "security-backup")
  restorePath = file_api.joinPath(root, "security-restore")

  managed = database_manager.create(root, "m21_tools", config_model.defaultDatabaseSettings(4096))
  sourcePath = managed.path
  admin = executor.attach(managed)
  executeOne(admin, "CREATE TABLE audit_item (id INTEGER PRIMARY KEY, text VARCHAR(80))")
  executeOne(admin, "INSERT INTO audit_item(id, text) VALUES (1, 'preserved')")
  executeOne(admin, "CREATE USER auditor WITH PASSWORD 'Auditor-Password-21!'")
  executeOne(admin, "CREATE ROLE audit_reader")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO auditor")
  executeOne(admin, "GRANT SELECT ON TABLE audit_item TO audit_reader")
  executeOne(admin, "GRANT audit_reader TO auditor")
  executeOne(admin, "ANALYZE audit_item")
  executor.close(admin)
  database_manager.close(managed)

  report = checker.run(sourcePath)
  testkit.record(state, checker.isCheckReport(report), "checker validates secured database")
  testkit.equal(state, report.rowCount, 1, "checker row count")
  testkit.equal(state, len(report.warnings), 0, "checker warnings")

  backupReport = backup.run(sourcePath, backupPath)
  testkit.record(state, backup.isBackupReport(backupReport), "backup report")
  manifest = backup.readManifest(backupPath)
  testkit.record(state, manifestHasSecurity(manifest), "backup manifest includes security catalog")

  restoreReport = backup.restore(backupPath, restorePath)
  testkit.record(state, backup.isRestoreReport(restoreReport), "restore report")
  restoredCheck = checker.run(restorePath)
  testkit.equal(state, restoredCheck.rowCount, 1, "restored secured database passes checker")

  restored = database_manager.open(restorePath)
  auditor = catalog.findPrincipal(restored.catalogHandle, "auditor")
  role = catalog.findPrincipal(restored.catalogHandle, "audit_reader")
  table = catalog.findTable(restored.catalogHandle, "audit_item")
  testkit.record(state, metadata.isPrincipalMetadata(auditor), "restored user exists")
  testkit.record(state, metadata.isPrincipalMetadata(role), "restored role exists")
  testkit.record(state, catalog.authenticatePassword(restored.catalogHandle, "auditor", "Auditor-Password-21!"), "restored password material works")
  testkit.record(state, catalog.hasPrivilege(restored.catalogHandle, auditor.principalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, false), "restored CONNECT privilege")
  testkit.record(state, catalog.hasPrivilege(restored.catalogHandle, auditor.principalId, metadata.OBJECT_TABLE, table.tableId, metadata.PRIVILEGE_SELECT, false), "restored role-derived table privilege")
  database_manager.close(restored)

  return testkit.finish(state, "MiniSQL M21 security backup/check tests: SUCCESS", "MiniSQL M21 security backup/check tests: FAIL")
end function
