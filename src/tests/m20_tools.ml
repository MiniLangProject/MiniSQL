// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.backup as backup
import minisql.tools.check as checker
import minisql.tools.migrate as migrate
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Flips and flushes the first byte of a file to exercise format and integrity rejection paths.
function corruptFirstByte(path)
  handle = file_api.openReadWrite(path, false)
  value = bytes(1, 0)
  file_api.readExactAt(handle, 0, value, 0, 1)
  value[0] = value[0] ^ 1
  file_api.writeAt(handle, 0, value, 0, 1)
  file_api.flush(handle)
  file_api.close(handle)
  return true
end function

// Produces a deterministic external TEXT payload that cannot fit inline on a
// 4 KiB heap page. The consistency check must validate its overflow chain while
// retaining only this one row.
function externalPayload()
  output = ""
  for index = 0 to 255
    output = output + "0123456789abcdef"
  end for
  return output
end function

// Runs the tools test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M20 maintenance tool tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  root = args[0]
  backupPath = file_api.joinPath(root, "verified-backup")
  restorePath = file_api.joinPath(root, "restored-database")
  rejectedRestorePath = file_api.joinPath(root, "rejected-restore")

  managed = database_manager.create(root, "m20_source", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE asset (id INTEGER PRIMARY KEY, code VARCHAR(20) NOT NULL UNIQUE, value INTEGER CHECK (value >= 0))")
  executeOne(engine, "INSERT INTO asset(id, code, value) VALUES (1, 'alpha', 10), (2, 'beta', 20), (3, 'gamma', 30)")
  executeOne(engine, "CREATE TABLE streamed_payload (id INTEGER PRIMARY KEY, code VARCHAR(20) NOT NULL UNIQUE, body TEXT NOT NULL)")
  executeOne(engine, "INSERT INTO streamed_payload(id, code, body) VALUES (1, 'external', '" + externalPayload() + "')")
  executeOne(engine, "ANALYZE asset")
  executor.close(engine)
  database_manager.close(managed)

  report = checker.run(databasePath)
  testkit.record(state, checker.isCheckReport(report), "consistency checker returns report")
  testkit.equal(state, report.tableCount, 2, "checker table count")
  testkit.equal(state, report.rowCount, 4, "checker row count including external payload")
  testkit.record(state, report.indexCount >= 4, "checker verifies primary and unique indexes through streaming probes")
  testkit.equal(state, report.statisticsTableCount, 1, "checker validates statistics")
  testkit.equal(state, len(report.warnings), 0, "checker warning count")

  backupReport = backup.run(databasePath, backupPath)
  testkit.record(state, backup.isBackupReport(backupReport), "backup returns report")
  testkit.record(state, backupReport.fileCount >= 8, "backup captures database files")
  testkit.record(state, backupReport.totalBytes > 0, "backup has bytes")
  testkit.equal(state, backupReport.pageSize, 4096, "backup page size")

  manifest = backup.readManifest(backupPath)
  testkit.record(state, backup.isBackupManifest(manifest), "backup manifest decodes")
  testkit.equal(state, len(manifest.entries), backupReport.fileCount, "manifest entry count")

  restoreReport = backup.restore(backupPath, restorePath)
  testkit.record(state, backup.isRestoreReport(restoreReport), "restore returns report")
  testkit.equal(state, restoreReport.fileCount, backupReport.fileCount, "restore file count")
  restoredCheck = checker.run(restorePath)
  testkit.equal(state, restoredCheck.rowCount, 4, "restored database passes consistency check")

  restored = executor.open(restorePath)
  rows = executeOne(restored, "SELECT code, value FROM asset ORDER BY id")
  testkit.equal(state, len(rows.rows), 3, "restored SQL row count")
  testkit.equal(state, rows.rows[2][0].value, "gamma", "restored SQL text value")
  testkit.equal(state, rows.rows[2][1].value, 30, "restored SQL numeric value")
  payloadRows = executeOne(restored, "SELECT LENGTH(body) FROM streamed_payload WHERE id = 1")
  testkit.equal(state, payloadRows.rows[0][0].value, 4096, "restored external payload remains complete")
  executor.close(restored)

  samePlan = migrate.plan(databasePath, 4096)
  testkit.record(state, migrate.isMigrationPlan(samePlan), "same-size migration plan")
  testkit.record(state, samePlan.supported, "same-size migration supported")
  testkit.record(state, not samePlan.rewriteRequired, "same-size migration needs no rewrite")
  sameRun = migrate.run(databasePath, 4096)
  testkit.record(state, migrate.isMigrationReport(sameRun), "same-size migration report")
  testkit.record(state, not sameRun.changed, "same-size migration does not alter database")

  rewritePlan = migrate.plan(databasePath, 8192)
  testkit.record(state, rewritePlan.rewriteRequired, "page-size change requires rewrite")
  testkit.record(state, not rewritePlan.supported, "unsafe in-place page-size change refused")
  testkit.errorCode(state, try(migrate.run(databasePath, 8192)), 9003, "page-size rewrite refused before mutation")
  afterRefusal = checker.run(databasePath)
  testkit.equal(state, afterRefusal.pageSize, 4096, "refused migration preserves source page size")
  testkit.equal(state, afterRefusal.rowCount, 4, "refused migration preserves source rows")

  corruptFirstByte(file_api.joinPath(backupPath, "db.meta"))
  testkit.errorCode(state, try(backup.restore(backupPath, rejectedRestorePath)), 9004, "corrupt backup rejected by checksum")
  testkit.record(state, not file_api.pathExists(rejectedRestorePath), "corrupt backup never publishes destination")
  testkit.errorCode(state, try(backup.restore(backupPath, restorePath)), 9013, "restore never overwrites existing database")

  return testkit.finish(state, "MiniSQL M20 check, backup, restore and migration tests: SUCCESS", "MiniSQL M20 check, backup, restore and migration tests: FAIL")
end function
