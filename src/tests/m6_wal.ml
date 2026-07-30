import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

function cleanup(path)
  result = try(file_api.deletePath(path))
  return true
end function

function makePage(fileId, pageNumber, fill)
  value = page.create(4096, page.TYPE_GENERIC, fileId, pageNumber)
  for index = page.HEADER_SIZE to len(value) - 1
    value[index] = fill
  end for
  page.reseal(value)
  return value
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M6 WAL tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  cleanup(path)
  state = testkit.create()

  log = wal.create(path, 4096)
  testkit.equal(state, log.nextLsn, 0, "new WAL begins at LSN zero")
  first = wal.appendRecord(log, wal.RECORD_TX_BEGIN, 0, 7, 0, 0, bytes())
  payload = makePage(42, 9, 0x5a)
  second = wal.appendRecord(log, wal.RECORD_PAGE_IMAGE, 3, 7, 42, 9, payload)
  third = wal.appendRecord(log, wal.RECORD_TX_COMMIT, 0, 7, 0, 0, bytes())
  testkit.equal(state, first.lsn, 0, "first LSN")
  testkit.equal(state, second.lsn, wal.HEADER_SIZE, "second LSN")
  testkit.equal(state, third.lsn, wal.HEADER_SIZE * 2 + len(payload), "third LSN")
  testkit.equal(state, wal.segmentNumber(log, 0), 0, "segment zero")
  testkit.equal(state, wal.segmentOffset(log, 4100), 4, "segment offset")
  flushed = wal.flush(log)
  testkit.equal(state, flushed, log.nextLsn, "flush advances durable boundary")

  scan = wal.scan(log, false)
  testkit.equal(state, len(scan.records), 3, "three records scan")
  testkit.equal(state, scan.records[1].recordType, wal.RECORD_PAGE_IMAGE, "page record type")
  testkit.equal(state, scan.records[1].transactionId, 7, "transaction id")
  testkit.equal(state, scan.records[1].fileId, 42, "file id")
  testkit.equal(state, scan.records[1].pageNumber, 9, "page number")
  testkit.equal(state, hex(scan.records[1].payload), hex(second.payload), "payload roundtrip")
  pageHeader = page.verify(scan.records[1].payload)
  testkit.equal(state, endian.uint64ToInt(pageHeader.pageLsn), second.lsn, "page image carries WAL LSN")
  testkit.record(state, not scan.truncatedTail, "clean WAL has no truncated tail")

  encoded = wal.encode(second)
  decoded = wal.decode(encoded)
  testkit.equal(state, decoded.totalLength, len(encoded), "encoded length")
  corruptedHeader = bytes(encoded)
  corruptedHeader[12] = corruptedHeader[12] ^ 1
  testkit.errorCode(state, try(wal.decode(corruptedHeader)), wal.CORRUPT_DATA, "header corruption")
  corruptedPayload = bytes(encoded)
  corruptedPayload[len(corruptedPayload) - 1] = corruptedPayload[len(corruptedPayload) - 1] ^ 0x80
  testkit.errorCode(state, try(wal.decode(corruptedPayload)), wal.CORRUPT_DATA, "payload corruption")
  testkit.errorCode(state, try(wal.decode(slice(encoded, 0, len(encoded) - 1))), wal.CORRUPT_DATA, "truncated record")
  wal.close(log)

  raw = file_api.openReadWrite(path, false)
  tail = fromHex("aabbccddee")
  originalSize = file_api.size(raw)
  file_api.append(raw, tail, 0, len(tail))
  file_api.flush(raw)
  file_api.close(raw)

  repaired = wal.open(path, 4096)
  testkit.equal(state, repaired.nextLsn, originalSize, "open truncates invalid suffix")
  repairedScan = wal.scan(repaired, false)
  testkit.equal(state, len(repairedScan.records), 3, "valid prefix survives tail repair")
  testkit.record(state, not repairedScan.truncatedTail, "repaired WAL scans cleanly")
  wal.close(repaired)

  cleanup(path)
  return testkit.finish(state, "MiniSQL M6 WAL tests: SUCCESS", "MiniSQL M6 WAL tests: FAIL")
end function
