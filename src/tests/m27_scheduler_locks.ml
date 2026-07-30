import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.transaction.lock_manager as locks
import minisql.transaction.transaction as transaction
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

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
  testkit.equal(state, manager.activeWriter, 1, "writer identity")
  locks.release(manager, 1)
  testkit.equal(state, manager.activeWriter, 0, "writer released")
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
  second = executor.attach(managed)
  executeOne(first, "CREATE TABLE concurrent_item (id INTEGER PRIMARY KEY, value VARCHAR(40) NOT NULL)")
  executeOne(first, "BEGIN")
  executeOne(first, "INSERT INTO concurrent_item(id, value) VALUES (1, 'first')")
  testkit.errorCode(state, try(executor.executeSql(second, "INSERT INTO concurrent_item(id, value) VALUES (2, 'second')")), locks.LOCK_CONFLICT, "second executor waits for active writer")
  testkit.equal(state, database_manager.waiterCount(managed), 1, "shared database records one waiting session")
  executeOne(first, "COMMIT")
  inserted = executeOne(second, "INSERT INTO concurrent_item(id, value) VALUES (2, 'second')")
  testkit.equal(state, inserted.affectedRows, 1, "waiting write succeeds after commit")
  counted = executeOne(second, "SELECT COUNT(*) AS c FROM concurrent_item")
  testkit.record(state, len(testkit.renderValue(counted.rows[0][0])) > 0, "test diagnostics render SQL result values")
  testkit.equal(state, endian.int64ToInt(counted.rows[0][0].value), 2, "both committed rows are visible")
  testkit.equal(state, database_manager.waiterCount(managed), 0, "successful retry clears wait graph")
  executor.close(first)
  executor.close(second)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M27 scheduler and lock tests: SUCCESS", "MiniSQL M27 scheduler and lock tests: FAIL")
end function
