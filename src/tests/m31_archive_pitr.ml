// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.backup as backup
import minisql.tools.check as check
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Opens a primary or standby database, reads its replicated row count, and closes all resources before returning.
function rowCount(databasePath, standby)
  managed = void
  if standby then managed = database_manager.openStandby(databasePath) else managed = database_manager.open(databasePath) end if
  engine = executor.attach(managed)
  result = executeOne(engine, "SELECT COUNT(*) AS c FROM history_item")
  count = endian.int64ToInt(result.rows[0][0].value)
  executor.close(engine)
  database_manager.close(managed)
  return count
end function

// Opens the target database, inserts one replication fixture row, and closes the engine; SQL or storage failures propagate to the caller.
function addRow(databasePath, id, value)
  engine = executor.open(databasePath)
  executeOne(engine, "INSERT INTO history_item(id, value) VALUES (" + id + ", '" + value + "')")
  executor.close(engine)
  return true
end function

// Runs the archive pitr test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M31 archive and PITR tests: FAIL args"; return 2 end if
  state = testkit.create()
  root = args[0]
  file_api.createDirectory(root)
  managed = database_manager.create(root, "m31_source", config_model.defaultDatabaseSettings(4096))
  sourcePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE history_item (id INTEGER PRIMARY KEY, value VARCHAR(80) NOT NULL)")
  executeOne(engine, "INSERT INTO history_item(id, value) VALUES (1, 'base')")
  executor.close(engine)
  database_manager.close(managed)

  archivePath = file_api.joinPath(root, "archive")
  initialized = backup.archiveInit(sourcePath, archivePath)
  testkit.record(state, backup.isArchiveReport(initialized), "base archive created")
  testkit.record(state, initialized.baseEndLsn == initialized.latestEndLsn, "base archive boundary")

  addRow(sourcePath, 2, "after-base")
  archived = backup.archiveWal(sourcePath, archivePath)
  targetTwoRows = archived.latestEndLsn
  testkit.record(state, archived.generation == 2, "second archive generation")
  testkit.record(state, archived.latestEndLsn > initialized.baseEndLsn, "WAL archive advanced")
  verified = backup.verifyArchive(archivePath)
  testkit.equal(state, verified.latestEndLsn, archived.latestEndLsn, "archive verification")

  // Build a standby at generation two, then archive and apply generation three.
  standbyPath = file_api.joinPath(root, "standby")
  standby = backup.materializeStandby(archivePath, standbyPath)
  testkit.record(state, backup.isStandbyReport(standby), "standby materialized")
  testkit.record(state, file_api.fileExists(file_api.joinPath(standbyPath, "standby.state")), "standby marker published with destination")
  testkit.record(state, not file_api.pathExists(standbyPath + ".standby-stage"), "standby staging directory removed after publication")
  testkit.errorCode(state, try(database_manager.open(standbyPath)), database_manager.STANDBY_NOT_PROMOTED, "normal open rejects unpromoted standby")
  testkit.equal(state, rowCount(standbyPath, true), 2, "standby row count before refresh")

  addRow(sourcePath, 3, "after-standby")
  third = backup.archiveWal(sourcePath, archivePath)
  testkit.equal(state, third.generation, 3, "third archive generation")
  refreshed = backup.refreshStandby(archivePath, standbyPath)
  testkit.equal(state, refreshed.archiveGeneration, third.generation, "standby archive generation refreshed")
  testkit.equal(state, rowCount(standbyPath, true), 3, "refreshed standby row count")
  promoted = backup.promoteStandby(standbyPath)
  testkit.record(state, backup.isStandbyReport(promoted), "standby promoted")
  testkit.equal(state, rowCount(standbyPath, false), 3, "promoted standby opens normally")

  // Exact-boundary PITR at the base, generation-two and latest boundaries.
  baseRestore = file_api.joinPath(root, "restore-base")
  baseReport = backup.restoreToLsn(archivePath, baseRestore, initialized.baseEndLsn)
  testkit.record(state, backup.isPitrReport(baseReport), "base-boundary PITR report")
  testkit.equal(state, rowCount(baseRestore, false), 1, "PITR at base boundary excludes later commit")

  twoRestore = file_api.joinPath(root, "restore-two")
  twoReport = backup.restoreToLsn(archivePath, twoRestore, targetTwoRows)
  testkit.equal(state, twoReport.targetLsn, targetTwoRows, "generation-two PITR LSN")
  testkit.equal(state, rowCount(twoRestore, false), 2, "generation-two PITR row count")

  latestRestore = file_api.joinPath(root, "restore-latest")
  latestReport = backup.restoreLatest(archivePath, latestRestore)
  testkit.equal(state, latestReport.targetLsn, third.latestEndLsn, "latest PITR LSN")
  testkit.equal(state, rowCount(latestRestore, false), 3, "latest PITR row count")
  invalidTarget = initialized.baseEndLsn + 1
  testkit.errorCode(state, try(backup.restoreToLsn(archivePath, file_api.joinPath(root, "restore-invalid"), invalidTarget)), 9001, "non-record-boundary PITR target rejected")

  // An archive is permanently tied to one database identity.
  foreign = database_manager.create(root, "m31_foreign", config_model.defaultDatabaseSettings(4096))
  foreignPath = foreign.path
  database_manager.close(foreign)
  testkit.errorCode(state, try(backup.archiveWal(foreignPath, archivePath)), 9004, "foreign database cannot extend archive")

  // Detect archived-WAL tampering, then restore the original bytes and verify all
  // recovered database trees with the consistency checker.
  finalManifest = backup.verifyArchive(archivePath)
  walPath = file_api.joinPath(file_api.joinPath(archivePath, "wal"), finalManifest.walFileName)
  originalWal = backup.readWhole(walPath, backup.MAX_FILE_BYTES)
  damagedWal = bytes(originalWal)
  damagedWal[len(damagedWal) - 1] = damagedWal[len(damagedWal) - 1] ^ 1
  backup.overwriteWhole(walPath, damagedWal)
  testkit.errorCode(state, try(backup.verifyArchive(archivePath)), 9004, "tampered archived WAL rejected")
  backup.overwriteWhole(walPath, originalWal)
  testkit.equal(state, backup.verifyArchive(archivePath).generation, 3, "restored archive verifies")

  testkit.record(state, check.isCheckReport(check.run(baseRestore)), "base PITR database passes consistency check")
  testkit.record(state, check.isCheckReport(check.run(twoRestore)), "intermediate PITR database passes consistency check")
  testkit.record(state, check.isCheckReport(check.run(latestRestore)), "latest PITR database passes consistency check")
  testkit.record(state, check.isCheckReport(check.run(standbyPath)), "promoted standby passes consistency check")

  return testkit.finish(state, "MiniSQL M31 archive and PITR tests: SUCCESS", "MiniSQL M31 archive and PITR tests: FAIL")
end function
