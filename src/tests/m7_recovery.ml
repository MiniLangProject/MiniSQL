import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import minisql.transaction.recovery as recovery
import minisql.transaction.transaction as tx
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

function databaseId()
  return fromHex("102132435465768798a9bacbdcedfe0f")
end function

function makePage(pageSize, fileId, pageNumber, marker)
  result = page.create(pageSize, page.TYPE_GENERIC, fileId, pageNumber)
  result[page.HEADER_SIZE] = marker
  page.reseal(result)
  return result
end function

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

  second = recovery.recover(log, [recovery.target(44, data)], 0)
  testkit.equal(state, second.pagesRedone, 0, "redo is idempotent")
  testkit.record(state, second.pagesSkipped >= 3, "idempotent and uncommitted pages skipped")

  wal.close(log)
  paged_file.close(data)

  reopenedData = paged_file.open(dataPath)
  reopenedWal = wal.open(walPath, 4096)
  third = recovery.recover(reopenedWal, [recovery.target(44, reopenedData)], 0)
  testkit.equal(state, third.pagesRedone, 0, "restart recovery remains idempotent")
  testkit.equal(state, paged_file.readPage(reopenedData, 1)[page.HEADER_SIZE], 3, "recovered data persisted")
  wal.close(reopenedWal)
  paged_file.close(reopenedData)
  cleanup(walPath)
  cleanup(dataPath)
  return testkit.finish(state, "MiniSQL M7 recovery tests: SUCCESS", "MiniSQL M7 recovery tests: FAIL")
end function
