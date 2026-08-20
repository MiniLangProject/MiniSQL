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

// Terminates the crash-worker process immediately, intentionally bypassing normal resource cleanup.
extern function ExitProcess(code as u32) from "kernel32.dll" symbol "ExitProcess" returns void

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  return fromHex("8899aabbccddeeff0011223344556677")
end function

// Creates and reseals a deterministic page image whose marker byte identifies the intended recovery or transaction state.
function makePage(fileId, pageNumber, marker)
  result = page.create(4096, page.TYPE_GENERIC, fileId, pageNumber)
  result[page.HEADER_SIZE] = marker
  page.reseal(result)
  return result
end function

// Creates a durable crash fixture, emits either committed or uncommitted WAL records, then terminates without normal cleanup to simulate process loss.
function writer(mode, dataPath, walPath)
  // Recreate both files so the parent harness can reason about every durable
  // byte without inheriting state from an earlier worker invocation.
  ignored = try(file_api.deletePath(dataPath))
  ignored = try(file_api.deletePath(walPath))
  data = paged_file.create(dataPath, 4096, superblock.FILE_TYPE_TABLE, 77, databaseId())
  paged_file.appendPage(data, makePage(77, 0, 10))
  log = wal.create(walPath, 4096)
  if mode == "write-commit" then
    // Commit through the transaction layer, then append an incomplete record.
    // Immediate process termination verifies that recovery trusts the durable
    // commit boundary and ignores the torn tail without relying on close().
    transaction = tx.beginTransaction(3001, tx.ISOLATION_SERIALIZABLE, false, log)
    tx.stagePage(transaction, 77, 0, makePage(77, 0, 20))
    tx.stagePage(transaction, 77, 1, makePage(77, 1, 21))
    tx.commit(transaction)
    // Simulate a torn next record after the durable commit.
    tail = fromHex("4d53574c01004000")
    file_api.writeAt(log.file, log.nextLsn, tail, 0, len(tail))
    file_api.flush(log.file)
    print "MiniSQL M7 crash writer committed: READY"
    ExitProcess(0)
  end if
  if mode == "write-uncommitted" then
    // Flush complete page-image records without a commit record. Recovery must
    // not confuse physically durable WAL bytes with a committed transaction.
    transaction = tx.beginTransaction(3002, tx.ISOLATION_SERIALIZABLE, false, log)
    wal.appendBegin(log, transaction.transactionId)
    wal.appendRecord(log, wal.RECORD_PAGE_IMAGE, 0, 3002, 77, 0, makePage(77, 0, 30))
    wal.appendRecord(log, wal.RECORD_PAGE_IMAGE, 0, 3002, 77, 1, makePage(77, 1, 31))
    wal.flush(log)
    print "MiniSQL M7 crash writer uncommitted: READY"
    ExitProcess(0)
  end if
  return 2
end function

// Runs recovery in a fresh process and verifies that committed page images are redone while uncommitted images remain invisible.
function reader(mode, dataPath, walPath)
  data = paged_file.open(dataPath)
  log = wal.open(walPath, 4096)
  result = recovery.recover(log, [recovery.target(77, data)], 0)
  // The two modes intentionally share the same recovery call: only WAL commit
  // state may decide whether page images become visible.
  if mode == "recover-commit" then
    if data.pageCount != 2 then return 3 end if
    if paged_file.readPage(data, 0)[page.HEADER_SIZE] != 20 then return 4 end if
    if paged_file.readPage(data, 1)[page.HEADER_SIZE] != 21 then return 5 end if
    if result.pagesRedone != 2 then return 6 end if
    print "MiniSQL M7 crash recovery committed: SUCCESS"
  else if mode == "recover-uncommitted" then
    if data.pageCount != 1 then return 7 end if
    if paged_file.readPage(data, 0)[page.HEADER_SIZE] != 10 then return 8 end if
    if result.pagesRedone != 0 then return 9 end if
    print "MiniSQL M7 crash recovery uncommitted: SUCCESS"
  else
    return 10
  end if
  wal.close(log)
  paged_file.close(data)
  return 0
end function

// Runs the cross-process WAL crash and recovery test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 3 then return 1 end if
  mode = args[0]
  if mode == "write-commit" or mode == "write-uncommitted" then return writer(mode, args[1], args[2]) end if
  return reader(mode, args[1], args[2])
end function
