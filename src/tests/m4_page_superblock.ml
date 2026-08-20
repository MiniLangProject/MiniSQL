// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import tests.support.testkit as test

// Builds a deterministic database identifier from the supplied seed for isolated file fixtures.
function makeDatabaseId()
  value = bytes(16, 0)
  for index = 0 to 15
    value[index] = index * 7 + 3
  end for
  return value
end function

// Runs the page superblock test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  pageBytes = page.create(4096, page.TYPE_GENERIC, 42, 7)
  header = page.verify(pageBytes)
  test.equal(state, header.version, page.FORMAT_VERSION, "page version")
  test.equal(state, header.pageType, page.TYPE_GENERIC, "page type")
  test.equal(state, header.pageId.fileId, 42, "page file id")
  test.equal(state, header.pageId.pageNumber, 7, "page number")
  test.equal(state, header.freeStart, page.HEADER_SIZE, "page free start")
  test.equal(state, header.freeEnd, 4096, "page free end")
  test.record(state, header.headerChecksum != 0, "page header checksum")
  test.record(state, header.payloadChecksum != 0, "page payload checksum")

  pageBytes[page.HEADER_SIZE] = 0x5A
  test.errorCode(state, try(page.verify(pageBytes)), 9004, "payload corruption detected")
  page.reseal(pageBytes)
  repaired = page.verify(pageBytes)
  test.equal(state, pageBytes[page.HEADER_SIZE], 0x5A, "resealed payload retained")
  test.record(state, repaired.payloadChecksum != header.payloadChecksum, "reseal changed payload checksum")

  corruptHeader = bytes(pageBytes)
  corruptHeader[8] = corruptHeader[8] ^ 1
  test.errorCode(state, try(page.verify(corruptHeader)), 9004, "header corruption detected")

  oversizedIdPage = bytes(pageBytes)
  endian.writeU64LE(oversizedIdPage, 16, endian.makeUInt64(endian.MAX_SCALAR_HIGH + 1, 0))
  endian.writeU32LE(oversizedIdPage, page.HEADER_CHECKSUM_OFFSET, 0)
  endian.writeU32LE(oversizedIdPage, page.HEADER_CHECKSUM_OFFSET, crc32c.computeRange(oversizedIdPage, 0, page.HEADER_SIZE))
  test.errorCode(state, try(page.verify(oversizedIdPage)), 9003, "page ID beyond native range")
  test.errorCode(state, try(page.create(5000, page.TYPE_GENERIC, 1, 0)), 9001, "unsupported page size")

  databaseId = makeDatabaseId()
  original = superblock.create(
    superblock.FORMAT_VERSION,
    endian.makeUInt64(0, 5),
    4096,
    superblock.FILE_TYPE_GENERIC,
    42,
    7,
    databaseId,
    3
  )
  encoded = superblock.encode(original)
  test.equal(state, len(encoded), superblock.SLOT_SIZE, "superblock slot size")
  decoded = superblock.decode(encoded)
  test.equal(state, decoded.formatVersion, superblock.FORMAT_VERSION, "superblock version")
  test.equal(state, decoded.pageSize, 4096, "superblock page size")
  test.equal(state, decoded.fileType, superblock.FILE_TYPE_GENERIC, "superblock file type")
  test.equal(state, decoded.fileId, 42, "superblock file id")
  test.equal(state, decoded.pageCount, 7, "superblock page count")
  test.equal(state, decoded.featureFlags, 3, "superblock flags")
  test.equal(state, hex(decoded.databaseId), hex(databaseId), "superblock database id")
  test.record(state, endian.uint64Equals(decoded.generation, endian.makeUInt64(0, 5)), "superblock generation")

  newer = superblock.incrementGeneration(decoded.generation)
  test.record(state, endian.uint64Equals(newer, endian.makeUInt64(0, 6)), "generation increment")
  test.equal(state, superblock.compareGeneration(decoded.generation, newer), -1, "generation comparison less")
  test.equal(state, superblock.compareGeneration(newer, decoded.generation), 1, "generation comparison greater")
  test.equal(state, superblock.compareGeneration(newer, newer), 0, "generation comparison equal")

  corruptSlot = bytes(encoded)
  corruptSlot[200] = corruptSlot[200] ^ 1
  test.errorCode(state, try(superblock.decode(corruptSlot)), 9004, "superblock corruption detected")

  reservedSlot = bytes(encoded)
  reservedSlot[200] = 1
  endian.writeU32LE(reservedSlot, superblock.CHECKSUM_OFFSET, 0)
  endian.writeU32LE(reservedSlot, superblock.CHECKSUM_OFFSET, crc32c.compute(reservedSlot))
  test.errorCode(state, try(superblock.decode(reservedSlot)), 9003, "valid checksum with unknown reserved data")

  firstSameGeneration = superblock.create(1, endian.makeUInt64(0, 9), 4096, superblock.FILE_TYPE_GENERIC, 42, 7, databaseId, 3)
  secondSameGeneration = superblock.create(1, endian.makeUInt64(0, 9), 4096, superblock.FILE_TYPE_GENERIC, 42, 8, databaseId, 3)
  test.errorCode(state, try(paged_file.chooseMetadata(firstSameGeneration, secondSameGeneration)), 9004, "equal generations with different page counts")

  test.errorCode(state, try(superblock.create(1, endian.makeUInt64(0, 0), 4096, 1, 1, 0, bytes(15, 0), 0)), 9001, "database id width")
  test.errorCode(state, try(superblock.incrementGeneration(endian.makeUInt64(endian.MAX_U32, endian.MAX_U32))), 9001, "generation overflow")

  return test.finish(state, "MiniSQL M4 page and superblock tests: SUCCESS", "MiniSQL M4 page and superblock tests: FAIL")
end function
