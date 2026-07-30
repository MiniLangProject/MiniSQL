import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.overflow as overflow
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.row_codec as rows
import minisql.storage.superblock as superblock
import tests.support.testkit as testkit

function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

function databaseId()
  return fromHex("13579bdf2468ace00123456789abcdef")
end function

function makeValue(length, seed)
  result = bytes(length, 0)
  if length > 0 then
    for index = 0 to length - 1
      result[index] = (seed + index * 37 + (index >> 3)) & 255
    end for
  end if
  return result
end function

function makeAsciiText(length)
  raw = bytes(length, 0)
  if length > 0 then
    for index = 0 to length - 1
      raw[index] = 65 + (index % 26)
    end for
  end if
  return decode(raw)
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M10 overflow tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  cleanup(path)
  state = testkit.create()
  testkit.errorCode(state, try(overflow.createPointer(1, 0, 4294967296, 1, 0)), overflow.INVALID_ARGUMENT, "pointer length must fit U32")
  file = paged_file.create(path, 4096, superblock.FILE_TYPE_TABLE, 123, databaseId())
  capacity = overflow.chunkCapacity(file)
  lengths = [0, 1, capacity - 1, capacity, capacity + 1, capacity * 3 + 17, 262144]
  pointers = []
  expected = []
  for index = 0 to len(lengths) - 1
    value = makeValue(lengths[index], index * 11)
    pointer = overflow.write(file, 500 + index, value)
    pointers = pointers + [pointer]
    expected = expected + [value]
    testkit.equal(state, hex(overflow.read(file, pointer)), hex(value), "overflow roundtrip " + lengths[index])
  end for
  testkit.record(state, file.pageCount > 60, "large value spans many pages")

  range = overflow.readRange(file, pointers[5], capacity - 10, 40)
  testkit.equal(state, hex(range), hex(slice(expected[5], capacity - 10, 40)), "partial range across page boundary")
  encodedPointer = overflow.encodePointer(pointers[4])
  decodedPointer = overflow.decodePointer(encodedPointer)
  testkit.equal(state, decodedPointer.firstPage, pointers[4].firstPage, "pointer first page roundtrip")
  testkit.equal(state, decodedPointer.totalLength, pointers[4].totalLength, "pointer length roundtrip")
  external = overflow.toExternal(pointers[4])
  testkit.record(state, rows.isExternalValue(external), "external pointer exact type predicate")
  testkit.errorCode(state, try(overflow.fromExternal([])), overflow.INVALID_ARGUMENT, "wrong external pointer struct rejected")
  fromExternal = overflow.fromExternal(external)
  testkit.equal(state, fromExternal.ownerId, pointers[4].ownerId, "row external pointer integration")

  textPointer = overflow.storeText(file, 900, "Über mehrere Seiten: " + makeAsciiText(capacity + 50))
  text = overflow.readText(file, textPointer)
  testkit.record(state, len(bytes(text)) > capacity, "large UTF-8 text roundtrip")

  replaceOldValue = makeValue(capacity + 100, 77)
  replaceOld = overflow.write(file, 1000, replaceOldValue)
  oldFirst = replaceOld.firstPage
  replaceNewValue = makeValue(capacity * 2 + 33, 88)
  replacement = overflow.prepareReplace(file, replaceOld, 1001, replaceNewValue)
  replaceNew = replacement.newPointer
  testkit.equal(state, hex(overflow.read(file, replaceNew)), hex(replaceNewValue), "prepared replacement value readable")
  testkit.equal(state, hex(overflow.read(file, replaceOld)), hex(replaceOldValue), "old value remains until pointer publication")
  oldPage = paged_file.readPage(file, oldFirst)
  testkit.equal(state, page.verify(oldPage).pageType, page.TYPE_OVERFLOW, "prepare replacement never frees old chain")
  overflow.commitReplace(file, replacement)
  oldPage = paged_file.readPage(file, oldFirst)
  testkit.equal(state, page.verify(oldPage).pageType, page.TYPE_FREE, "old chain freed only after explicit commit")

  wrongOwner = overflow.createPointer(pointers[4].fileId, pointers[4].firstPage, pointers[4].totalLength, pointers[4].ownerId + 1, pointers[4].valueChecksum)
  testkit.errorCode(state, try(overflow.read(file, wrongOwner)), overflow.CORRUPT_DATA, "owner mismatch detected")
  missing = overflow.createPointer(file.fileId, file.pageCount + 10, 1, 77, 0)
  testkit.errorCode(state, try(overflow.read(file, missing)), overflow.CORRUPT_DATA, "missing page detected")

  cycleValue = makeValue(capacity + 5, 101)
  cyclePointer = overflow.write(file, 1100, cycleValue)
  cyclePage = paged_file.readPage(file, cyclePointer.firstPage)
  endian.writeU64LE(cyclePage, overflow.NEXT_PAGE_OFFSET, endian.uint64FromInt(cyclePointer.firstPage))
  page.reseal(cyclePage)
  paged_file.writePage(file, cyclePointer.firstPage, cyclePage)
  paged_file.flush(file)
  testkit.errorCode(state, try(overflow.read(file, cyclePointer)), overflow.CORRUPT_DATA, "cycle detected")

  durablePointer = pointers[6]
  paged_file.close(file)
  reopened = paged_file.open(path)
  testkit.equal(state, hex(overflow.read(reopened, durablePointer)), hex(expected[6]), "large value survives reopen")
  freed = overflow.free(reopened, durablePointer)
  testkit.record(state, freed > 60, "large chain freed")
  testkit.equal(state, page.verify(paged_file.readPage(reopened, durablePointer.firstPage)).pageType, page.TYPE_FREE, "first freed page marked free")
  pageCountBeforeReuse = reopened.pageCount
  reusedPointer = overflow.write(reopened, 1200, makeValue(capacity * 2, 111))
  testkit.equal(state, reopened.pageCount, pageCountBeforeReuse, "free overflow pages are reused before file growth")
  testkit.equal(state, hex(overflow.read(reopened, reusedPointer)), hex(makeValue(capacity * 2, 111)), "reused overflow pages remain correct")
  paged_file.close(reopened)
  cleanup(path)
  return testkit.finish(state, "MiniSQL M10 overflow tests: SUCCESS", "MiniSQL M10 overflow tests: FAIL")
end function
