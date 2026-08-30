// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes one SQL statement and returns its single result.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Verifies deterministic ENOSPC-style failures and durable recovery after the
// injected failure is removed. The failpoint is process-local, opt-in and has
// no environment/configuration activation path in production binaries.
function main(args)
  if len(args) != 1 then print "MiniSQL M78 fault injection: FAIL (missing data root)"; return 1 end if
  state = testkit.create()

  // The low-level boundary admits complete writes until its byte budget is
  // exhausted, then rejects the next write before native I/O can tear it.
  probePath = file_api.joinPath(args[0], "m78-write-probe.bin")
  probe = file_api.create(probePath)
  file_api.configureWriteFault(4)
  testkit.equal(state, file_api.writeAt(probe, 0, bytes("safe"), 0, 4), 4, "injected write budget admits complete write")
  exhausted = try(file_api.writeAt(probe, 4, bytes("x"), 0, 1))
  testkit.errorCode(state, exhausted, 9005, "injected storage exhaustion is typed")
  file_api.clearWriteFault()
  testkit.equal(state, file_api.writeAt(probe, 4, bytes("x"), 0, 1), 1, "writes resume after failpoint clear")
  file_api.flush(probe)
  file_api.close(probe)

  // Exercise the same failure through the real WAL/autocommit path. A failed
  // statement must not become visible after close and crash-style reopen.
  managed = database_manager.create(args[0], "m78_storage_fault", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE fault_item (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)")
  executeOne(engine, "INSERT INTO fault_item(id, payload) VALUES (1, 'durable-before-fault')")

  file_api.configureWriteFault(0)
  failedInsert = try(executeOne(engine, "INSERT INTO fault_item(id, payload) VALUES (2, 'must-not-commit')"))
  file_api.clearWriteFault()
  testkit.errorCode(state, failedInsert, 9005, "database propagates injected storage exhaustion")

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  countAfterFailure = executeOne(reopened, "SELECT COUNT(*) FROM fault_item")
  testkit.equal(state, endian.int64ToInt(countAfterFailure.rows[0][0].value), 1, "failed write remains invisible after recovery")
  executeOne(reopened, "INSERT INTO fault_item(id, payload) VALUES (3, 'durable-after-recovery')")
  finalCount = executeOne(reopened, "SELECT COUNT(*) FROM fault_item")
  testkit.equal(state, endian.int64ToInt(finalCount.rows[0][0].value), 2, "database accepts durable writes after recovery")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M78 fault injection: SUCCESS", "MiniSQL M78 fault injection: FAIL")
end function
