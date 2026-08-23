// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.page as page
import minisql.storage.heap_file as heap_file
import minisql.storage.slotted_page as slotted
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  return fromHex("fedcba98765432100123456789abcdef")
end function

// Builds a deterministic variable-length heap record used to validate insertion, lookup, update, and deletion.
function makeRecord(index, length)
  result = bytes(length, 0)
  if length > 0 then
    for offset = 0 to length - 1
      result[offset] = (index * 31 + offset * 17) & 255
    end for
  end if
  return result
end function

// Runs the heap file test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M9 heap-file tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  appendPath = path + ".append"
  cleanup(path)
  cleanup(appendPath)
  state = testkit.create()

  rawPage = slotted.create(4096, 99, 0)
  slot0 = slotted.insert(rawPage, bytes("alpha"))
  slot1 = slotted.insert(rawPage, bytes("beta"))
  testkit.equal(state, slot0, 0, "first slot")
  testkit.equal(state, slot1, 1, "second slot")
  testkit.equal(state, decode(slotted.read(rawPage, slot0)), "alpha", "slot read")
  originalGeneration = slotted.entryGeneration(rawPage, slot0)
  slotted.remove(rawPage, slot0)
  testkit.record(state, slotted.isDeleted(rawPage, slot0), "slot deleted")
  deletedGeneration = slotted.entryGeneration(rawPage, slot0)
  testkit.record(state, deletedGeneration != originalGeneration, "delete advances slot generation")
  reused = slotted.insert(rawPage, bytes("gamma"))
  testkit.equal(state, reused, slot0, "deleted slot reused")
  testkit.equal(state, slotted.entryGeneration(rawPage, reused), deletedGeneration, "reused slot keeps new generation")
  testkit.errorCode(state, try(slotted.readGeneration(rawPage, reused, originalGeneration)), slotted.STALE_REFERENCE, "old generation rejected")
  slotted.update(rawPage, slot1, bytes(1000, 0x42))
  testkit.equal(state, len(slotted.read(rawPage, slot1)), 1000, "slot grows after compaction")
  testkit.record(state, slotted.freeBytes(rawPage) > 0, "free-space accounting")
  beforeFailure = bytes(rawPage)
  testkit.errorCode(state, try(slotted.insert(rawPage, bytes(4096, 0x55))), slotted.PAGE_FULL, "oversized page insert rejected")
  testkit.equal(state, hex(rawPage), hex(beforeFailure), "failed slotted insert is byte-atomic")

  // A saturated generation is retired instead of wrapping and aliasing an old
  // RowId. Set the current live slot to 65535, delete it, then verify insertion
  // allocates another slot rather than reusing it.
  saturatedPage = slotted.create(4096, 100, 0)
  saturatedSlot = slotted.insert(saturatedPage, bytes("old"))
  endian.writeU16LE(saturatedPage, slotted.slotOffset(saturatedSlot) + 6, 65535)
  page.reseal(saturatedPage)
  slotted.remove(saturatedPage, saturatedSlot)
  testkit.equal(state, slotted.entryGeneration(saturatedPage, saturatedSlot), 65535, "generation saturates without wrap")
  nextSlot = slotted.insert(saturatedPage, bytes("new"))
  testkit.record(state, nextSlot != saturatedSlot, "saturated deleted slot is permanently retired")

  // Near-page-sized rows must advance through the append frontier without
  // rescanning every older full page for every insertion.
  appendHeap = heap_file.create(appendPath, 4096, 101, databaseId())
  appendId = void
  for index = 0 to 255
    appendId = heap_file.insert(appendHeap, makeRecord(index, 3000))
  end for
  testkit.equal(state, appendHeap.pagedFile.pageCount, 256, "append-heavy rows allocate one page each")
  testkit.equal(state, appendId.pageNumber, 255, "append frontier advances linearly")
  testkit.equal(state, appendHeap.insertionPageHint, 255, "heap retains the latest insertion page")
  heap_file.close(appendHeap)
  reopenedAppend = heap_file.open(appendPath)
  testkit.equal(state, reopenedAppend.insertionPageHint, 255, "reopened append-only heap resumes at its frontier")
  heap_file.close(reopenedAppend)
  cleanup(appendPath)

  heap = heap_file.create(path, 4096, 99, databaseId())
  ids = []
  expected = []
  deleted = []
  for index = 0 to 199
    record = makeRecord(index, 20 + (index % 73))
    ids = ids + [heap_file.insert(heap, record)]
    expected = expected + [record]
    deleted = deleted + [false]
  end for
  testkit.record(state, heap.pagedFile.pageCount > 1, "rows span multiple pages")

  for index = 0 to 199
    if index % 3 == 0 then
      replacement = makeRecord(index + 1000, 700 + (index % 211))
      heap_file.update(heap, ids[index], replacement)
      expected[index] = replacement
    end if
  end for
  for index = 0 to 199
    if index % 5 == 0 then
      heap_file.remove(heap, ids[index])
      deleted[index] = true
    end if
  end for

  for index = 0 to 199
    if deleted[index] then
      testkit.errorCode(state, try(heap_file.read(heap, ids[index])), heap_file.ROW_NOT_FOUND, "deleted row " + index)
    else
      testkit.equal(state, hex(heap_file.read(heap, ids[index])), hex(expected[index]), "row before reopen " + index)
    end if
  end for
  testkit.equal(state, heap_file.count(heap), 160, "scan excludes deleted and internal moved rows")
  heap_file.close(heap)

  reopened = heap_file.open(path)
  testkit.equal(state, reopened.insertionPageHint, ids[0].pageNumber, "reopen discovers durable deleted-slot space")
  for index = 0 to 199
    if deleted[index] then
      testkit.errorCode(state, try(heap_file.read(reopened, ids[index])), heap_file.ROW_NOT_FOUND, "deleted row after reopen " + index)
    else
      testkit.equal(state, hex(heap_file.read(reopened, ids[index])), hex(expected[index]), "row after reopen " + index)
    end if
  end for
  testkit.equal(state, heap_file.count(reopened), 160, "scan count survives reopen")
  replacementId = heap_file.insert(reopened, bytes("slot reuse check"))
  testkit.equal(state, replacementId.pageNumber, ids[0].pageNumber, "deleted page reused")
  testkit.equal(state, replacementId.slotId, ids[0].slotId, "deleted slot reused by heap")
  testkit.errorCode(state, try(heap_file.read(reopened, ids[0])), heap_file.STALE_REFERENCE, "old RowId cannot alias reused slot")
  heap_file.close(reopened)
  cleanup(path)
  return testkit.finish(state, "MiniSQL M9 heap-file tests: SUCCESS", "MiniSQL M9 heap-file tests: FAIL")
end function
