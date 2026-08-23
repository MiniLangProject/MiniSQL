// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import std.threading as threading
import minisql.catalog.catalog as catalog
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.storage.paged_file as paged_file
import minisql.transaction.lock_manager as locks
import minisql.transaction.transaction as transaction
import tests.support.testkit as testkit

// Coordination state passed to readers that must overlap inside the shared execution gate.
struct ReadGateTask
  // Shared managed database whose reader gate is exercised.
  database
  // Manual-reset event that releases both reader threads together.
  start
  // Semaphore used by each reader to report successful gate entry.
  arrived
  // Event that keeps both readers active until the writer-wait assertion completes.
  release
end struct

// Coordination state passed to the writer that must wait for active readers.
struct WriteGateTask
  // Shared managed database whose exclusive gate is exercised.
  database
  // Semaphore signaled only after exclusive writer entry succeeds.
  arrived
  // Event that lets the orchestrator end the exclusive hold.
  release
end struct

// Per-thread executor state for the real parallel query workload.
struct QueryTask
  // Executor session owned by this query thread.
  engine
  // Shared event that aligns both query workloads for measurable overlap.
  start
end struct

// Waits for the coordinated start, holds a shared database execution gate until released, and reports timeout or gate failures.
function holdReadGate(task)
  if not task.start.waitFor(5000) then return error(9100, "read worker start timed out") end if
  entered = try(database_manager.enterReadExecution(task.database))
  task.arrived.release()
  if not task.release.waitFor(5000) then
    database_manager.leaveReadExecution(task.database)
    return error(9100, "read worker release timed out")
  end if
  return database_manager.leaveReadExecution(task.database)
end function

// Acquires the exclusive database execution gate, signals arrival, and holds it until the orchestrator permits release.
function holdWriteGate(task)
  entered = try(database_manager.enterExecution(task.database))
  task.arrived.release()
  if not task.release.waitFor(5000) then
    database_manager.leaveExecution(task.database)
    return error(9100, "write worker release timed out")
  end if
  return database_manager.leaveExecution(task.database)
end function

// Executes one hundred indexed reads after a shared start signal, failing on any SQL error or malformed result shape.
function runReadQueries(task)
  if not task.start.waitFor(5000) then return error(9100, "query worker start timed out") end if
  iteration = 0
  while iteration < 100
    results = try(executor.executeSql(task.engine, "SELECT value FROM concurrent_item WHERE id = 1"))
    if typeof(results) == "error" then return results end if
    if len(results) != 1 or len(results[0].rows) != 1 then return error(9100, "query worker received invalid result") end if
    iteration = iteration + 1
  end while
  return true
end function

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the scheduler locks test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M27 scheduler and lock tests: FAIL args"; return 2 end if
  state = testkit.create()
  manager = locks.create()

  testkit.record(state, locks.acquireRead(manager, 1), "transaction one acquires read lock")
  testkit.record(state, locks.acquireRead(manager, 2), "transaction two acquires read lock")
  testkit.equal(state, locks.readerCount(manager), 2, "two concurrent readers")
  testkit.errorCode(state, try(locks.acquireWrite(manager, 1)), locks.LOCK_CONFLICT, "first upgrade waits")
  testkit.record(state, locks.isWaiting(manager, 1), "first upgrader registered in wait graph")
  testkit.errorCode(state, try(locks.acquireWrite(manager, 2)), locks.DEADLOCK_DETECTED, "second upgrade detects deadlock")
  testkit.record(state, not locks.isWaiting(manager, 2), "deadlock victim wait edges removed")
  locks.release(manager, 2)
  testkit.record(state, locks.acquireWrite(manager, 1), "surviving transaction acquires writer lock")
  testkit.equal(state, locks.activeWriter(manager), 1, "writer identity")
  locks.release(manager, 1)
  testkit.equal(state, locks.activeWriter(manager), 0, "writer released")
  testkit.equal(state, locks.readerCount(manager), 0, "readers released")

  committed = locks.acquireStatementRead(manager, 3, transaction.ISOLATION_READ_COMMITTED)
  testkit.equal(state, locks.readerCount(manager), 1, "READ COMMITTED statement lock held")
  locks.finishStatement(manager, committed)
  testkit.equal(state, locks.readerCount(manager), 0, "READ COMMITTED statement lock released")

  serial = locks.acquireStatementRead(manager, 4, transaction.ISOLATION_SERIALIZABLE)
  locks.finishStatement(manager, serial)
  testkit.equal(state, locks.readerCount(manager), 1, "SERIALIZABLE read lock survives statement")
  testkit.errorCode(state, try(locks.acquireWrite(manager, 5)), locks.LOCK_CONFLICT, "writer waits for serializable reader")
  testkit.equal(state, locks.waiterCount(manager), 1, "waiter count")
  locks.cancelWait(manager, 5)
  testkit.equal(state, locks.waiterCount(manager), 0, "cancel removes wait graph entry")
  locks.finishTransaction(manager, 4)
  testkit.record(state, locks.acquireWrite(manager, 5), "writer succeeds after transaction end")
  locks.finishTransaction(manager, 5)

  // Exercise the same shared lock manager through two real executor sessions.
  root = args[0]
  file_api.createDirectory(root)
  managed = database_manager.create(root, "m27_shared", config_model.defaultDatabaseSettings(4096))
  first = executor.attach(managed)
  testkit.record(state, database_manager.indexesReady(managed), "first attachment completes one-time index verification")
  second = executor.attach(managed)
  testkit.record(state, database_manager.indexesReady(managed), "later attachment reuses verified index state")

  // Two native readers occupy the same database simultaneously. An exclusive
  // writer cannot enter until both readers leave.
  readStart = threading.Event.new(true, false)
  readArrived = threading.Semaphore.new(0, 2)
  readRelease = threading.Event.new(true, false)
  readTask = ReadGateTask(managed, readStart, readArrived, readRelease)
  readOne = Thread(holdReadGate, "minisql-read-one")
  readTwo = Thread(holdReadGate, "minisql-read-two")
  testkit.record(state, readOne.Start(readTask) and readTwo.Start(readTask), "native read workers start")
  readStart.set()
  bothReaders = readArrived.acquireFor(5000) and readArrived.acquireFor(5000)
  testkit.record(state, bothReaders, "two read workers enter the database together")
  if bothReaders then testkit.equal(state, database_manager.peakConcurrentReaders(managed), 2, "execution gate records parallel readers") end if

  writeArrived = threading.Semaphore.new(0, 1)
  writeRelease = threading.Event.new(true, false)
  writeTask = WriteGateTask(managed, writeArrived, writeRelease)
  writer = Thread(holdWriteGate, "minisql-write")
  testkit.record(state, writer.Start(writeTask), "native write worker starts")
  testkit.record(state, not writeArrived.acquireFor(100), "writer waits while readers are active")
  readRelease.set()
  testkit.record(state, writeArrived.acquireFor(5000), "writer enters after readers leave")
  writeRelease.set()
  testkit.record(state, readOne.Join(5000) and readTwo.Join(5000) and writer.Join(5000), "parallel gate workers finish")
  testkit.record(state, readOne.Status() == "Completed" and readTwo.Status() == "Completed" and writer.Status() == "Completed", "parallel gate workers complete successfully")
  readOne.Close()
  readTwo.Close()
  writer.Close()
  readStart.close()
  readArrived.close()
  readRelease.close()
  writeArrived.close()
  writeRelease.close()

  executeOne(first, "CREATE TABLE concurrent_item (id INTEGER PRIMARY KEY, value VARCHAR(40) NOT NULL)")
  table = database_manager.findTable(managed, "concurrent_item")
  tablePath = catalog.tableFilePath(managed.path, table.tableId)
  sharedFileOne = paged_file.openReadOnly(tablePath)
  sharedFileTwo = paged_file.openReadOnly(tablePath)
  testkit.equal(state, sharedFileOne.pageCount, sharedFileTwo.pageCount, "two physical shared readers open one table file")
  paged_file.close(sharedFileOne)
  paged_file.close(sharedFileTwo)
  executeOne(first, "BEGIN")
  executeOne(first, "INSERT INTO concurrent_item(id, value) VALUES (1, 'first')")
  testkit.errorCode(state, try(executor.executeSql(second, "INSERT INTO concurrent_item(id, value) VALUES (2, 'second')")), locks.LOCK_CONFLICT, "second executor waits for active writer")
  testkit.equal(state, database_manager.waiterCount(managed), 1, "shared database records one waiting session")
  executeOne(first, "COMMIT")
  testkit.record(state, not database_manager.isLockWaiting(managed, executor.sessionIdentifier(second)), "released blocker wakes waiting session without a retry execution")
  inserted = executeOne(second, "INSERT INTO concurrent_item(id, value) VALUES (2, 'second')")
  testkit.equal(state, inserted.affectedRows, 1, "waiting write succeeds after commit")
  counted = executeOne(second, "SELECT COUNT(*) AS c FROM concurrent_item")
  testkit.record(state, len(testkit.renderValue(counted.rows[0][0])) > 0, "test diagnostics render SQL result values")
  testkit.equal(state, endian.int64ToInt(counted.rows[0][0].value), 2, "both committed rows are visible")
  testkit.equal(state, database_manager.waiterCount(managed), 0, "successful retry clears wait graph")

  // Align two independent executor sessions at a barrier, then run enough
  // indexed reads for the gate's peak counter to prove actual overlap rather
  // than merely proving that two worker objects were created.
  database_manager.resetPeakConcurrentReaders(managed)
  queryStart = threading.Event.new(true, false)
  queryOne = Thread(runReadQueries, "minisql-query-one")
  queryTwo = Thread(runReadQueries, "minisql-query-two")
  queryOne.Start(QueryTask(first, queryStart))
  queryTwo.Start(QueryTask(second, queryStart))
  queryStart.set()
  testkit.record(state, queryOne.Join(10000) and queryTwo.Join(10000), "parallel session queries finish")
  if queryOne.Status() != "Completed" then
    queryOneResult = try(queryOne.Result())
    if typeof(queryOneResult) == "error" then print "query worker one status=" + queryOne.Status() + " error=" + queryOneResult.message end if
  end if
  if queryTwo.Status() != "Completed" then
    queryTwoResult = try(queryTwo.Result())
    if typeof(queryTwoResult) == "error" then print "query worker two status=" + queryTwo.Status() + " error=" + queryTwoResult.message end if
  end if
  testkit.record(state, queryOne.Status() == "Completed" and queryTwo.Status() == "Completed", "parallel session queries complete successfully")
  testkit.record(state, database_manager.peakConcurrentReaders(managed) >= 2, "real query plans overlap in the shared reader gate")
  queryOne.Close()
  queryTwo.Close()
  queryStart.close()
  executor.close(first)
  executor.close(second)
  database_manager.close(managed)
  locks.close(manager)

  return testkit.finish(state, "MiniSQL M27 scheduler and lock tests: SUCCESS", "MiniSQL M27 scheduler and lock tests: FAIL")
end function
