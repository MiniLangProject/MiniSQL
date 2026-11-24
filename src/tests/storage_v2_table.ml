// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.heap_file as heap_file
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import minisql.storage.table_header as table_header
import tests.support.testkit as testkit

/// Removes an isolated test file when present.
/// @param path Test artifact path.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

/// Returns a stable database identity for golden header fields.
function databaseId()
  return fromHex("00112233445566778899aabbccddeeff")
end function

/// Exercises page-zero allocation, all table open modes and semantic/CRC
/// corruption rejection without accepting or converting legacy table files.
/// @param args Destination path for isolated test fixtures.
function main(args)
  if len(args) != 1 then print "MiniSQL storage-v2 table headers: FAIL (missing path)"; return 1 end if
  path = args[0]
  legacyPath = path + ".legacy"
  cleanup(path)
  cleanup(legacyPath)
  heap_file.invalidatePageDirectory(path)
  state = testkit.create()

  heap = heap_file.create(path, 4096, 77, databaseId())
  testkit.equal(state, heap.pagedFile.pageCount, 1, "empty table already owns page zero")
  testkit.equal(state, file_api.size(heap.pagedFile.file), 12288, "empty table has two superblocks and one table header")
  testkit.equal(state, heap_file.count(heap), 0, "header-only table scans as empty")
  original = paged_file.readPage(heap.pagedFile, 0)
  common = page.verify(original)
  testkit.equal(state, common.pageType, page.TYPE_TABLE_META, "page zero is table metadata")
  testkit.equal(state, common.freeStart, 128, "table-specific header occupies first 128 page bytes")
  testkit.equal(state, hex(slice(original, 64, 8)), "4d53544202008000", "magic version and header length golden bytes")
  testkit.equal(state, hex(slice(original, 72, 16)), hex(databaseId()), "database identity golden bytes")
  testkit.equal(state, endian.readU32LE(original, 88), 77, "table identity is persisted")
  testkit.equal(state, endian.readU32LE(original, 96), 4096, "page size is persisted")
  testkit.equal(state, endian.readU16LE(original, 100), 1, "CRC32C algorithm is persisted")
  testkit.equal(state, endian.readU16LE(original, 102), 2, "physical row format is v2")
  testkit.equal(state, endian.readU32LE(original, 104), 1, "initial creation generation is persisted")
  testkit.equal(state, endian.readU32LE(original, 112), 1, "first data page is one")

  identifier = heap_file.insert(heap, bytes("first data row"))
  testkit.equal(state, identifier.pageNumber, 1, "first inserted row uses page one")
  testkit.equal(state, heap.pagedFile.pageCount, 2, "heap allocation preserves reserved page")
  heapPages = heap_file.heapPageNumbers(heap.pagedFile)
  testkit.equal(state, len(heapPages), 1, "heap directory only includes data pages")
  testkit.equal(state, heapPages[0], 1, "heap directory excludes table header")
  testkit.equal(state, hex(paged_file.readPage(heap.pagedFile, 0)), hex(original), "data allocation leaves immutable header unchanged")
  testkit.errorCode(state, try(heap_file.rowId(0, 0, 1)), heap_file.INVALID_ARGUMENT, "page zero cannot be a row identifier")

  corrupt = bytes(original)
  corrupt[80] = corrupt[80] ^ 1
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.CORRUPT_DATA, "damaged table header CRC rejected")
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.CORRUPT_DATA, "foreign database rejected even with valid CRC")
  corrupt = bytes(original)
  endian.writeU64LE(corrupt, 88, endian.uint64FromInt(78))
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.CORRUPT_DATA, "foreign table id rejected")
  corrupt = bytes(original)
  endian.writeU32LE(corrupt, 96, 8192)
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.CORRUPT_DATA, "page-size identity mismatch rejected")
  corrupt = bytes(original)
  endian.writeU16LE(corrupt, 68, 1)
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.UNSUPPORTED_FORMAT, "legacy table-format version rejected")
  corrupt = bytes(original)
  endian.writeU16LE(corrupt, 100, 0)
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.UNSUPPORTED_FORMAT, "unknown checksum algorithm rejected")
  corrupt = bytes(original)
  endian.writeU64LE(corrupt, 104, endian.uint64FromInt(0))
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.CORRUPT_DATA, "zero creation generation rejected")
  corrupt = bytes(original)
  corrupt[128] = 1
  page.reseal(corrupt)
  testkit.errorCode(state, try(table_header.validatePage(heap.pagedFile, corrupt)), table_header.UNSUPPORTED_FORMAT, "nonzero reserved tail rejected")
  heap_file.close(heap)

  readOnly = table_header.openReadOnly(path)
  testkit.record(state, table_header.validate(readOnly), "shared read-only open validates table header")
  paged_file.close(readOnly)
  managed = table_header.openReadOnlyManaged(path)
  testkit.record(state, table_header.validate(managed), "managed read-only open validates table header")
  paged_file.close(managed)
  reopened = heap_file.open(path)
  testkit.equal(state, hex(heap_file.read(reopened, identifier)), hex(bytes("first data row")), "data survives header-validating reopen")
  heap_file.close(reopened)

  // Resealed semantic corruption must fail every open mode and release its
  // handle, so the next check can reacquire the same path without lock leaks.
  raw = paged_file.open(path)
  corrupt = bytes(original)
  endian.writeU16LE(corrupt, 102, 1)
  page.reseal(corrupt)
  paged_file.writePage(raw, 0, corrupt)
  paged_file.flush(raw)
  paged_file.close(raw)
  testkit.errorCode(state, try(table_header.open(path)), table_header.UNSUPPORTED_FORMAT, "writable open rejects legacy row version")
  testkit.errorCode(state, try(table_header.openReadOnly(path)), table_header.UNSUPPORTED_FORMAT, "read-only open rejects legacy row version")
  testkit.errorCode(state, try(table_header.openReadOnlyManaged(path)), table_header.UNSUPPORTED_FORMAT, "managed open rejects legacy row version")
  testkit.errorCode(state, try(heap_file.open(path)), table_header.UNSUPPORTED_FORMAT, "heap open rejects legacy row version")

  raw = paged_file.create(legacyPath, 4096, superblock.FILE_TYPE_TABLE, 88, databaseId())
  paged_file.close(raw)
  testkit.errorCode(state, try(table_header.open(legacyPath)), table_header.UNSUPPORTED_FORMAT, "empty legacy table without header rejected")
  raw = paged_file.open(legacyPath)
  paged_file.allocatePage(raw, page.TYPE_HEAP)
  paged_file.close(raw)
  testkit.errorCode(state, try(table_header.openReadOnly(legacyPath)), table_header.UNSUPPORTED_FORMAT, "legacy heap page zero rejected")

  heap_file.invalidatePageDirectory(path)
  cleanup(path)
  cleanup(legacyPath)
  return testkit.finish(state, "MiniSQL storage-v2 table headers: SUCCESS", "MiniSQL storage-v2 table headers: FAIL")
end function
