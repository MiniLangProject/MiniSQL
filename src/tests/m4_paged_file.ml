// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import tests.support.testkit as test

// Builds a deterministic database identifier from the supplied seed for isolated file fixtures.
function makeDatabaseId(seed)
  value = bytes(16, 0)
  for index = 0 to 15
    value[index] = (seed + index * 13) % 256
  end for
  return value
end function

// Flips one byte at the requested file offset and flushes it to construct a deterministic on-disk corruption fixture.
function corruptByte(path, offset)
  file = file_api.openReadWrite(path, false)
  value = bytes(1, 0)
  file_api.readExactAt(file, offset, value, 0, 1)
  value[0] = value[0] ^ 0xFF
  file_api.writeAt(file, offset, value, 0, 1)
  file_api.flush(file)
  file_api.close(file)
end function

// Runs the paged file test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 4 then
    print "MiniSQL M4 paged-file recovery tests: FAIL (expected four path arguments)"
    return 2
  end if

  mainPath = args[0]
  fallbackPath = args[1]
  corruptPath = args[2]
  largePagePath = args[3]

  databaseId = makeDatabaseId(7)
  file = paged_file.create(mainPath, 4096, superblock.FILE_TYPE_GENERIC, 42, databaseId)
  test.equal(state, file.pageSize, 4096, "created page size")
  test.equal(state, file.pageCount, 0, "created page count")
  test.equal(state, file.activeSlot, paged_file.SLOT_A, "initial active slot")
  test.errorCode(state, try(paged_file.open(mainPath)), 9007, "paged file owns a lifetime exclusive lock")
  test.errorCode(state, try(paged_file.pageOffset(file, paged_file.maxPageCountFor(file.pageSize))), 9001, "page offset rejects the first impossible page number")
  test.errorCode(state, try(paged_file.create(mainPath, 4096, superblock.FILE_TYPE_GENERIC, 42, databaseId)), 9005, "create never overwrites an existing file")
  test.equal(state, file.pageCount, 0, "failed duplicate create left metadata intact")
  test.equal(state, paged_file.allocatePage(file, page.TYPE_GENERIC), 0, "allocate page zero")
  test.equal(state, paged_file.allocatePage(file, page.TYPE_GENERIC), 1, "allocate page one")
  test.equal(state, paged_file.allocatePage(file, page.TYPE_GENERIC), 2, "allocate page two")
  test.equal(state, file.pageCount, 3, "page count after allocation")

  second = paged_file.readPage(file, 1)
  second[page.HEADER_SIZE] = 0x5A
  page.reseal(second)
  paged_file.writePage(file, 1, second)
  paged_file.flush(file)
  paged_file.close(file)
  test.errorCode(state, try(paged_file.create(mainPath, 4096, superblock.FILE_TYPE_GENERIC, 42, databaseId)), 9005, "create remains non-destructive after close")

  reopened = paged_file.open(mainPath)
  test.equal(state, reopened.pageSize, 4096, "reopened page size from file")
  test.equal(state, reopened.pageCount, 3, "reopened page count")
  test.equal(state, hex(reopened.databaseId), hex(databaseId), "reopened database id")
  reread = paged_file.readPage(reopened, 1)
  test.equal(state, reread[page.HEADER_SIZE], 0x5A, "persisted page payload")
  paged_file.close(reopened)

  // Simulate a page append that reached disk but whose metadata publication did not.
  raw = file_api.openReadWrite(mainPath, false)
  garbage = bytes(123, 0xEE)
  file_api.append(raw, garbage, 0, len(garbage))
  file_api.flush(raw)
  test.equal(state, file_api.size(raw), paged_file.DATA_OFFSET + 3 * 4096 + 123, "uncommitted tail present")
  file_api.close(raw)
  trimmed = paged_file.open(mainPath)
  test.equal(state, file_api.size(trimmed.file), paged_file.DATA_OFFSET + 3 * 4096, "uncommitted tail trimmed")
  paged_file.close(trimmed)

  batched = paged_file.open(mainPath)
  test.equal(state, paged_file.allocatePages(batched, page.TYPE_GENERIC, 4), 3, "batch allocation returns first reserved page")
  test.equal(state, batched.pageCount, 7, "batch allocation publishes one combined page count")
  for pageNumber = 3 to 6
    reserved = paged_file.readPage(batched, pageNumber)
    test.equal(state, page.verify(reserved).pageId.pageNumber, pageNumber, "batch page identity " + pageNumber)
  end for
  paged_file.close(batched)
  reopenedBatch = paged_file.open(mainPath)
  test.equal(state, reopenedBatch.pageCount, 7, "batch allocation survives reopen")
  test.equal(state, file_api.size(reopenedBatch.file), paged_file.DATA_OFFSET + 7 * 4096, "batch allocation physical layout")
  paged_file.close(reopenedBatch)

  // Three appends leave slot B newest (generation 4) and slot A at pageCount 2.
  fallback = paged_file.create(fallbackPath, 4096, superblock.FILE_TYPE_GENERIC, 77, makeDatabaseId(21))
  paged_file.allocatePage(fallback, page.TYPE_GENERIC)
  paged_file.allocatePage(fallback, page.TYPE_GENERIC)
  paged_file.allocatePage(fallback, page.TYPE_GENERIC)
  test.equal(state, fallback.activeSlot, paged_file.SLOT_B, "fallback newest slot")
  paged_file.close(fallback)
  corruptByte(fallbackPath, paged_file.SLOT_B_OFFSET)
  recovered = paged_file.open(fallbackPath)
  test.equal(state, recovered.activeSlot, paged_file.SLOT_A, "fallback selected older slot")
  test.equal(state, recovered.pageCount, 2, "fallback recovered page count")
  test.equal(state, file_api.size(recovered.file), paged_file.DATA_OFFSET + 2 * 4096, "fallback trimmed uncommitted page")
  paged_file.close(recovered)


  // The page size comes from the file's redundant metadata, not from global defaults.
  largePage = paged_file.create(largePagePath, 8192, superblock.FILE_TYPE_GENERIC, 123, makeDatabaseId(44))
  paged_file.allocatePage(largePage, page.TYPE_GENERIC)
  paged_file.close(largePage)
  reopenedLarge = paged_file.open(largePagePath)
  test.equal(state, reopenedLarge.pageSize, 8192, "persisted 8192-byte page size")
  test.equal(state, reopenedLarge.pageCount, 1, "persisted 8192-byte page count")
  test.equal(state, file_api.size(reopenedLarge.file), paged_file.DATA_OFFSET + 8192, "8192-byte physical layout")
  paged_file.close(reopenedLarge)

  broken = paged_file.create(corruptPath, 4096, superblock.FILE_TYPE_GENERIC, 99, makeDatabaseId(33))
  paged_file.allocatePage(broken, page.TYPE_GENERIC)
  paged_file.close(broken)
  corruptByte(corruptPath, paged_file.SLOT_A_OFFSET)
  corruptByte(corruptPath, paged_file.SLOT_B_OFFSET)
  test.errorCode(state, try(paged_file.open(corruptPath)), 9004, "both metadata copies corrupt")

  return test.finish(state, "MiniSQL M4 paged-file recovery tests: SUCCESS", "MiniSQL M4 paged-file recovery tests: FAIL")
end function
