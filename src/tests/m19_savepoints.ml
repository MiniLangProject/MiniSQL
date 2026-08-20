// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.transaction.lock_manager as locks
import minisql.transaction.transaction as transaction
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

// Creates and reseals a deterministic page image whose marker byte identifies the intended recovery or transaction state.
function makePage(fileId, pageNumber, fill)
  value = page.create(4096, page.TYPE_GENERIC, fileId, pageNumber)
  for index = page.HEADER_SIZE to len(value) - 1
    value[index] = fill
  end for
  page.reseal(value)
  return value
end function

// Runs the savepoints test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M19 savepoint and lock tests: FAIL (missing WAL path)"
    return 1
  end if
  state = testkit.create()
  cleanup(args[0])
  writer = wal.create(args[0], 4096)

  tx = transaction.beginTransaction(501, transaction.ISOLATION_SERIALIZABLE, false, writer)
  transaction.stagePage(tx, 7, 0, makePage(7, 0, 0x11))
  transaction.savepoint(tx, "outer")
  transaction.stagePage(tx, 7, 0, makePage(7, 0, 0x22))
  transaction.stagePage(tx, 7, 1, makePage(7, 1, 0x33))
  transaction.savepoint(tx, "inner")
  transaction.stagePage(tx, 7, 0, makePage(7, 0, 0x44))
  testkit.equal(state, transaction.savepointCount(tx), 2, "two savepoints recorded")
  transaction.rollbackToSavepoint(tx, "inner")
  testkit.equal(state, transaction.readPrivatePage(tx, 7, 0)[page.HEADER_SIZE], 0x22, "rollback-to restores inner snapshot")
  testkit.equal(state, transaction.stagedPageCount(tx), 2, "rollback-to restores page set")
  transaction.rollbackToSavepoint(tx, "outer")
  testkit.equal(state, transaction.readPrivatePage(tx, 7, 0)[page.HEADER_SIZE], 0x11, "rollback-to outer restores earlier value")
  testkit.equal(state, transaction.stagedPageCount(tx), 1, "rollback-to outer removes later page")
  testkit.equal(state, transaction.savepointCount(tx), 1, "rollback-to discards later savepoints")

  transaction.savepoint(tx, "same")
  transaction.stagePage(tx, 7, 2, makePage(7, 2, 0x55))
  transaction.savepoint(tx, "same")
  transaction.stagePage(tx, 7, 3, makePage(7, 3, 0x66))
  transaction.rollbackToSavepoint(tx, "same")
  testkit.equal(state, transaction.stagedPageCount(tx), 2, "duplicate savepoint resolves newest occurrence")
  testkit.record(state, transaction.readPrivatePage(tx, 7, 2) is not void, "newest duplicate retains prior change")
  testkit.record(state, transaction.readPrivatePage(tx, 7, 3) is void, "newest duplicate removes later change")
  transaction.releaseSavepoint(tx, "same")
  testkit.equal(state, transaction.savepointCount(tx), 2, "release removes newest duplicate and later scope")
  transaction.rollbackToSavepoint(tx, "same")
  testkit.equal(state, transaction.stagedPageCount(tx), 1, "earlier duplicate savepoint becomes visible after release")
  testkit.record(state, transaction.readPrivatePage(tx, 7, 2) is void, "earlier duplicate restores its own snapshot")

  transaction.markFailed(tx)
  transaction.rollbackToSavepoint(tx, "outer")
  testkit.equal(state, tx.state, transaction.TransactionState.Active, "rollback-to recovers failed transaction")
  transaction.commit(tx)
  testkit.equal(state, tx.state, transaction.TransactionState.Committed, "transaction commits after rollback-to recovery")
  testkit.equal(state, transaction.savepointCount(tx), 0, "commit clears savepoints")

  manager = locks.create()
  readCommitted = locks.acquireStatementRead(manager, 601, transaction.ISOLATION_READ_COMMITTED)
  testkit.equal(state, locks.readerCount(manager), 1, "READ COMMITTED statement acquires read lock")
  locks.finishStatement(manager, readCommitted)
  testkit.equal(state, locks.readerCount(manager), 0, "READ COMMITTED releases at statement end")

  serializable = locks.acquireStatementRead(manager, 602, transaction.ISOLATION_SERIALIZABLE)
  locks.finishStatement(manager, serializable)
  testkit.equal(state, locks.readerCount(manager), 1, "SERIALIZABLE retains read lock")
  testkit.errorCode(state, try(locks.acquireWrite(manager, 603)), locks.LOCK_CONFLICT, "retained serializable read blocks writer")
  locks.finishTransaction(manager, 602)
  testkit.equal(state, locks.readerCount(manager), 0, "transaction end releases serializable read lock")
  testkit.record(state, locks.acquireWrite(manager, 603), "writer succeeds after reader transaction ends")
  locks.finishTransaction(manager, 603)
  testkit.errorCode(state, try(locks.finishStatement(manager, serializable)), 9001, "finished lease cannot be reused")

  wal.close(writer)
  cleanup(args[0])
  return testkit.finish(state, "MiniSQL M19 savepoint and isolation tests: SUCCESS", "MiniSQL M19 savepoint and isolation tests: FAIL")
end function
