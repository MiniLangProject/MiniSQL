// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.transaction.lock_manager as locks
import minisql.transaction.transaction as tx
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  result = try(file_api.deletePath(path))
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

// Runs the transaction test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M6 transaction tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  cleanup(path)
  state = testkit.create()
  log = wal.create(path, 4096)

  transaction = tx.beginTransaction(101, tx.ISOLATION_SERIALIZABLE, false, log)
  testkit.equal(state, transaction.state, tx.TransactionState.Active, "begin active")
  first = makePage(5, 0, 0x11)
  second = makePage(5, 1, 0x22)
  tx.stagePage(transaction, 5, 0, first)
  tx.stagePage(transaction, 5, 1, second)
  replacement = makePage(5, 0, 0x33)
  tx.stagePage(transaction, 5, 0, replacement)
  testkit.equal(state, tx.stagedPageCount(transaction), 2, "stage replaces duplicate page")
  testkit.equal(state, hex(tx.readPrivatePage(transaction, 5, 0)), hex(replacement), "read-your-write page")
  commitLsn = tx.commit(transaction)
  testkit.equal(state, transaction.state, tx.TransactionState.Committed, "commit state")
  testkit.equal(state, commitLsn, transaction.commitLsn, "commit LSN returned")
  testkit.record(state, log.lastFlushedLsn > commitLsn, "commit acknowledged only after flush boundary")
  scan = wal.scan(log, false)
  testkit.equal(state, len(scan.records), 4, "begin two images commit")
  testkit.equal(state, scan.records[3].recordType, wal.RECORD_TX_COMMIT, "commit record last")
  testkit.equal(state, tx.committedPageCount(transaction), 2, "committed page batch retained for publication")
  committedPages = tx.takeCommittedPages(transaction)
  testkit.equal(state, len(committedPages), 2, "committed page batch can be taken")
  testkit.equal(state, tx.committedPageCount(transaction), 0, "taken committed batch is released")
  testkit.equal(state, committedPages[0].fileId, 5, "committed batch identity")

  readOnly = tx.beginTransaction(102, tx.ISOLATION_READ_COMMITTED, true, log)
  testkit.errorCode(state, try(tx.stagePage(readOnly, 5, 2, first)), tx.READ_ONLY_VIOLATION, "read-only write rejected")
  tx.rollback(readOnly)
  testkit.equal(state, readOnly.state, tx.TransactionState.Aborted, "read-only rollback")

  rolledBack = tx.beginTransaction(103, tx.ISOLATION_SERIALIZABLE, false, log)
  tx.stagePage(rolledBack, 5, 2, makePage(5, 2, 0x55))
  tx.rollback(rolledBack)
  testkit.equal(state, tx.stagedPageCount(rolledBack), 0, "rollback discards private pages")
  testkit.equal(state, rolledBack.state, tx.TransactionState.Aborted, "rollback state")

  beforeWriteFailure = log.nextLsn
  writeFailure = tx.beginTransaction(104, tx.ISOLATION_SERIALIZABLE, false, log)
  tx.stagePage(writeFailure, 5, 3, makePage(5, 3, 0x66))
  wal.injectWriteFailure(log)
  testkit.errorCode(state, try(tx.commit(writeFailure)), wal.IO_FAILURE, "WAL write failure rejects commit")
  testkit.equal(state, writeFailure.state, tx.TransactionState.Failed, "write failure marks transaction failed")
  testkit.equal(state, log.nextLsn, beforeWriteFailure, "write failure rewinds WAL boundary")
  tx.rollback(writeFailure)

  beforeFlushFailure = log.nextLsn
  flushFailure = tx.beginTransaction(105, tx.ISOLATION_SERIALIZABLE, false, log)
  tx.stagePage(flushFailure, 5, 4, makePage(5, 4, 0x77))
  wal.injectFlushFailure(log)
  testkit.errorCode(state, try(tx.commit(flushFailure)), wal.IO_FAILURE, "WAL flush failure rejects commit")
  testkit.equal(state, flushFailure.state, tx.TransactionState.Failed, "flush failure marks transaction failed")
  testkit.equal(state, log.nextLsn, beforeFlushFailure, "flush failure removes unacknowledged WAL transaction")
  tx.rollback(flushFailure)

  manager = locks.create()
  testkit.record(state, locks.acquireRead(manager, 1), "first reader")
  testkit.record(state, locks.acquireRead(manager, 2), "second reader")
  testkit.errorCode(state, try(locks.acquireWrite(manager, 1)), locks.LOCK_CONFLICT, "writer blocked by other reader")
  locks.release(manager, 2)
  testkit.record(state, locks.acquireWrite(manager, 1), "reader upgrades when alone")
  testkit.errorCode(state, try(locks.acquireRead(manager, 3)), locks.LOCK_CONFLICT, "reader blocked by writer")
  locks.release(manager, 1)
  testkit.equal(state, locks.readerCount(manager), 0, "locks fully released")

  idManager = tx.createManager(1152921504606846975)
  testkit.errorCode(state, try(tx.beginManaged(idManager, tx.ISOLATION_SERIALIZABLE, false, log)), tx.TRANSACTION_STATE, "transaction ID exhaustion is fail-closed")

  wal.close(log)
  cleanup(path)
  return testkit.finish(state, "MiniSQL M6 transaction tests: SUCCESS", "MiniSQL M6 transaction tests: FAIL")
end function
