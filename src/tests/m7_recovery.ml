// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import minisql.transaction.recovery as recovery
import minisql.transaction.transaction as tx
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  return fromHex("102132435465768798a9bacbdcedfe0f")
end function

// Creates and reseals a deterministic page image whose marker byte identifies the intended recovery or transaction state.
function makePage(pageSize, fileId, pageNumber, marker)
  result = page.create(pageSize, page.TYPE_GENERIC, fileId, pageNumber)
  result[page.HEADER_SIZE] = marker
  page.reseal(result)
  return result
end function

// Runs the recovery test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 2 then
    print "MiniSQL M7 recovery tests: FAIL (missing paths)"
    return 1
  end if
  dataPath = args[0]
  walPath = args[1]
  cleanup(dataPath)
  cleanup(walPath)
  state = testkit.create()

  data = paged_file.create(dataPath, 4096, superblock.FILE_TYPE_TABLE, 44, databaseId())
  paged_file.appendPage(data, makePage(4096, 44, 0, 1))
  log = wal.create(walPath, 4096)

  committed = tx.beginTransaction(2001, tx.ISOLATION_SERIALIZABLE, false, log)
  tx.stagePage(committed, 44, 0, makePage(4096, 44, 0, 2))
  tx.stagePage(committed, 44, 1, makePage(4096, 44, 1, 3))
  tx.commit(committed)

  incomplete = tx.beginTransaction(2002, tx.ISOLATION_SERIALIZABLE, false, log)
  wal.appendBegin(log, incomplete.transactionId)
  wal.appendRecord(log, wal.RECORD_PAGE_IMAGE, 0, 2002, 44, 2, makePage(4096, 44, 2, 4))
  wal.flush(log)

  scanned = wal.scan(log, false)
  testkit.record(state, wal.isWalScan(scanned), "WAL scan exact type predicate")
  testkit.errorCode(state, try(recovery.recoverScan([], [recovery.target(44, data)], 0)), recovery.INVALID_ARGUMENT, "non-WalScan input rejected")
  result = recovery.recoverScan(scanned, [recovery.target(44, data)], 0)
  testkit.equal(state, result.committedTransactions, 1, "one committed transaction")
  testkit.equal(state, result.pagesRedone, 2, "two committed pages redone")
  testkit.equal(state, data.pageCount, 2, "uncommitted append ignored")
  testkit.equal(state, paged_file.readPage(data, 0)[page.HEADER_SIZE], 2, "existing page redone")
  testkit.equal(state, paged_file.readPage(data, 1)[page.HEADER_SIZE], 3, "new page redone")

  // A dropped table keeps historical committed images in the WAL until a later
  // checkpoint. Generic recovery remains strict, while an explicit retirement
  // tombstone skips the image and never requires the deleted file to reappear.
  retired = tx.beginTransaction(2003, tx.ISOLATION_SERIALIZABLE, false, log)
  tx.stagePage(retired, 43, 0, makePage(4096, 43, 0, 9))
  tx.commit(retired)
  retiredScan = wal.scan(log, false)
  testkit.errorCode(state, try(recovery.recoverScan(retiredScan, [recovery.target(44, data)], 0)), recovery.CORRUPT_DATA, "unclassified missing target remains corruption")
  retiredResult = recovery.recoverScan(retiredScan, [recovery.target(44, data), recovery.retiredTarget(43)], 0)
  testkit.equal(state, retiredResult.pagesRedone, 0, "retired file image is not replayed")
  testkit.record(state, retiredResult.pagesSkipped >= 4, "retired file image is counted as skipped")

  second = recovery.recover(log, [recovery.target(44, data), recovery.retiredTarget(43)], 0)
  testkit.equal(state, second.pagesRedone, 0, "redo is idempotent")
  testkit.record(state, second.pagesSkipped >= 3, "idempotent and uncommitted pages skipped")

  // A bounded WAL reset restarts physical LSNs at zero while existing base
  // pages retain LSNs from the previous epoch. Conventional recovery therefore
  // skips the numerically smaller new image; epoch recovery must replay it.
  wal.rewind(log, 0)
  epochTransaction = tx.beginTransaction(3001, tx.ISOLATION_SERIALIZABLE, false, log)
  epochPage = makePage(4096, 44, 0, 7)
  tx.stagePage(epochTransaction, 44, 0, epochPage)
  tx.commit(epochTransaction)
  epochScan = wal.scan(log, false)
  conventionalEpoch = recovery.recoverScan(epochScan, [recovery.target(44, data)], 0)
  testkit.equal(state, conventionalEpoch.pagesRedone, 0, "old page LSN demonstrates reset epoch")
  forcedEpoch = recovery.recoverScanForced(epochScan, [recovery.target(44, data)])
  testkit.equal(state, forcedEpoch.pagesRedone, 1, "bounded WAL epoch forces committed page replay")
  testkit.equal(state, paged_file.readPage(data, 0)[page.HEADER_SIZE], 7, "forced epoch replay publishes newest image")

  wal.close(log)
  paged_file.close(data)

  reopenedData = paged_file.open(dataPath)
  reopenedWal = wal.open(walPath, 4096)
  third = recovery.recoverScanForced(wal.scan(reopenedWal, false), [recovery.target(44, reopenedData)])
  testkit.equal(state, third.pagesRedone, 1, "restart epoch replay remains deterministic")
  testkit.equal(state, paged_file.readPage(reopenedData, 0)[page.HEADER_SIZE], 7, "epoch-recovered data persisted")
  wal.close(reopenedWal)
  paged_file.close(reopenedData)
  cleanup(walPath)
  cleanup(dataPath)
  return testkit.finish(state, "MiniSQL M7 recovery tests: SUCCESS", "MiniSQL M7 recovery tests: FAIL")
end function
