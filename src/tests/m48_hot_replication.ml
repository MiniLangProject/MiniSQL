// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.backup as backup
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Executes the replication count query and converts its SQL integer wrapper to the host integer used by assertions.
function countRows(engine)
  result = executeOne(engine, "SELECT COUNT(*) FROM replicated_item")
  return endian.int64ToInt(result.rows[0][0].value)
end function

// Runs the hot replication test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M48 hot replication tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m48_primary", config_model.defaultDatabaseSettings(4096))
  primaryPath = managed.path
  initial = executor.attach(managed)
  executeOne(initial, "CREATE TABLE replicated_item (id INTEGER PRIMARY KEY, value VARCHAR(40) NOT NULL)")
  executor.close(initial)
  database_manager.close(managed)

  archivePath = file_api.joinPath(args[0], "m48-archive")
  initialArchive = backup.archiveInit(primaryPath, archivePath)
  testkit.equal(state, initialArchive.generation, 1, "base archive generation")

  // Export only WAL bytes covered by the primary's durable marker while the
  // primary remains open; a live archive must advance both generation and LSN.
  primary = executor.open(primaryPath)
  executeOne(primary, "INSERT INTO replicated_item(id, value) VALUES (1, 'first')")
  firstLive = backup.archiveWalLive(primaryPath, archivePath)
  testkit.record(state, firstLive.generation >= 2, "live archive advances while primary remains open")
  testkit.record(state, firstLive.latestEndLsn > initialArchive.latestEndLsn, "live archive advances durable LSN")
  walPath = file_api.joinPath(file_api.joinPath(primaryPath, "wal"), "wal.log")
  testkit.equal(state, wal.readDurableMarker(walPath), firstLive.latestEndLsn, "live archive stops at durable marker")

  // Materialization creates a read-only standby at the first live boundary.
  // Its visible row count and write rejection jointly validate standby mode.
  standbyPath = file_api.joinPath(args[0], "m48-standby")
  materialized = backup.materializeStandby(archivePath, standbyPath)
  testkit.equal(state, materialized.appliedLsn, firstLive.latestEndLsn, "standby materialized at live LSN")

  standbyManaged = database_manager.openStandby(standbyPath)
  standby = executor.attach(standbyManaged)
  testkit.equal(state, countRows(standby), 1, "read-only standby exposes first committed row")
  blocked = try(executor.executeSql(standby, "INSERT INTO replicated_item(id, value) VALUES (99, 'blocked')"))
  testkit.errorCode(state, blocked, database_manager.STANDBY_NOT_PROMOTED, "standby rejects writes before promotion")
  executor.close(standby)
  database_manager.close(standbyManaged)

  // A later live export must refresh the existing standby monotonically; after
  // reopening, both committed rows must be visible at the new applied LSN.
  executeOne(primary, "INSERT INTO replicated_item(id, value) VALUES (2, 'second')")
  secondLive = backup.archiveWalLive(primaryPath, archivePath)
  testkit.record(state, secondLive.generation > firstLive.generation, "second live export advances generation")
  testkit.record(state, secondLive.latestEndLsn > firstLive.latestEndLsn, "second live export advances LSN")
  executor.close(primary)

  refreshed = backup.refreshStandby(archivePath, standbyPath)
  testkit.equal(state, refreshed.appliedLsn, secondLive.latestEndLsn, "standby refresh reaches second live LSN")
  reopenedManaged = database_manager.openStandby(standbyPath)
  reopened = executor.attach(reopenedManaged)
  testkit.equal(state, countRows(reopened), 2, "refreshed standby exposes both committed rows")
  executor.close(reopened)
  database_manager.close(reopenedManaged)

  return testkit.finish(state, "MiniSQL M48 hot replication tests: SUCCESS", "MiniSQL M48 hot replication tests: FAIL")
end function
