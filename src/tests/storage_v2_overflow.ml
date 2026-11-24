// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.common.format_version as format_version
import minisql.storage.overflow as overflow
import tests.support.testkit as testkit

/// Repairs the checksum after a deliberate structural mutation in a decoder test.
/// @param pointer Encoded pointer to reseal in place.
function resealPointer(pointer)
  endian.writeU32LE(pointer, overflow.POINTER_CHECKSUM_OFFSET, 0)
  endian.writeU32LE(pointer, overflow.POINTER_CHECKSUM_OFFSET, crc32c.compute(pointer))
  return pointer
end function

/// Verifies the external-pointer byte contract without allocating large LOB values.
/// @param args Unused command-line arguments.
function main(args)
  state = testkit.create()
  pointer = overflow.createPointer(123, 3, 0x01020304, 0x05060708, 0xA1B2C3D4)
  encoded = overflow.encodePointer(pointer)
  expected = "4d534f50020000007b00000000000000030000000000000004030201000000000807060500000000d4c3b2a1274af41d"
  testkit.equal(state, hex(encoded), expected, "independent U32 length and CRC golden vector")
  testkit.equal(state, len(encoded), 48, "pointer remains eight-byte aligned")
  testkit.equal(state, endian.readU16LE(encoded, 4), format_version.OVERFLOW, "explicit overflow version two")
  testkit.equal(state, endian.readU32LE(encoded, 24), 0x01020304, "length is one U32")
  testkit.equal(state, endian.readU32LE(encoded, 28), 0, "length is followed by reserved alignment bytes")
  decoded = overflow.decodePointer(encoded)
  testkit.equal(state, decoded.totalLength, pointer.totalLength, "pointer length decodes")
  testkit.equal(state, decoded.ownerId, pointer.ownerId, "owner remains aligned at offset32")
  testkit.equal(state, decoded.valueChecksum, pointer.valueChecksum, "value CRC independent from pointer CRC")

  largest = overflow.encodePointer(overflow.createPointer(123, 1, 4294967295, 1, 0))
  testkit.equal(state, overflow.decodePointer(largest).totalLength, 4294967295, "maximum U32 length roundtrip without allocation")
  testkit.errorCode(state, try(overflow.createPointer(123, 1, 4294967296, 1, 0)), overflow.INVALID_ARGUMENT, "U32 overflow rejected")
  empty = overflow.encodePointer(overflow.createPointer(123, -1, 0, 1, 0))
  testkit.equal(state, hex(slice(empty, 16, 8)), "ffffffffffffffff", "empty value has no-next-page sentinel")
  testkit.equal(state, overflow.decodePointer(empty).totalLength, 0, "empty value roundtrip")

  damaged = bytes(encoded)
  damaged[24] = damaged[24] ^ 1
  testkit.errorCode(state, try(overflow.decodePointer(damaged)), overflow.CORRUPT_DATA, "length corruption detected by pointer CRC")
  damaged = bytes(encoded)
  damaged[40] = damaged[40] ^ 1
  testkit.errorCode(state, try(overflow.decodePointer(damaged)), overflow.CORRUPT_DATA, "value CRC itself is protected")
  damaged = bytes(encoded)
  endian.writeU32LE(damaged, 28, 1)
  resealPointer(damaged)
  testkit.errorCode(state, try(overflow.decodePointer(damaged)), overflow.UNSUPPORTED_FORMAT, "nonzero reserved field is not a U64 length extension")
  legacy = bytes(encoded)
  endian.writeU16LE(legacy, 4, 1)
  resealPointer(legacy)
  testkit.errorCode(state, try(overflow.decodePointer(legacy)), overflow.UNSUPPORTED_FORMAT, "legacy pointer rejected explicitly")
  testkit.errorCode(state, try(overflow.decodePointer(slice(encoded, 0, 44))), overflow.CORRUPT_DATA, "truncated pointer rejected")
  return testkit.finish(state, "MiniSQL storage v2 overflow tests: SUCCESS", "MiniSQL storage v2 overflow tests: FAIL")
end function
