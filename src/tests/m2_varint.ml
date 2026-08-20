// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.common.varint as varint
import tests.support.testkit as test

// Encodes and decodes an unsigned 32-bit value, checking the golden bytes and the consumed-length contract.
function checkU32Golden(state, value, expectedHex, label)
  buffer = bytes(10, 0)
  next = varint.writeU32(buffer, 0, value)
  encoded = slice(buffer, 0, next)
  test.equal(state, hex(encoded), expectedHex, label + " encoding")
  decoded = varint.readU32(encoded, 0)
  test.equal(state, decoded.value, value, label + " value")
  test.equal(state, decoded.nextOffset, next, label + " nextOffset")
  test.equal(state, decoded.bytesRead, next, label + " bytesRead")
end function

// Encodes and decodes an unsigned 64-bit value, checking the golden bytes and the consumed-length contract.
function checkU64Golden(state, value, expectedHex, label)
  buffer = bytes(16, 0)
  next = varint.writeU64(buffer, 0, value)
  encoded = slice(buffer, 0, next)
  test.equal(state, hex(encoded), expectedHex, label + " encoding")
  decoded = varint.readU64(encoded, 0)
  test.record(state, endian.uint64Equals(decoded.value, value), label + " value")
  test.equal(state, decoded.nextOffset, next, label + " nextOffset")
  test.equal(state, decoded.bytesRead, next, label + " bytesRead")
end function

// Encodes and decodes a signed 32-bit value, checking the golden bytes and the consumed-length contract.
function checkI32Golden(state, value, expectedHex, label)
  buffer = bytes(10, 0)
  next = varint.writeI32(buffer, 0, value)
  encoded = slice(buffer, 0, next)
  test.equal(state, hex(encoded), expectedHex, label + " encoding")
  decoded = varint.readI32(encoded, 0)
  test.equal(state, decoded.value, value, label + " value")
end function

// Encodes and decodes a signed 64-bit value, checking the golden bytes and the consumed-length contract.
function checkI64Golden(state, value, expectedHex, label)
  buffer = bytes(16, 0)
  next = varint.writeI64(buffer, 0, value)
  encoded = slice(buffer, 0, next)
  test.equal(state, hex(encoded), expectedHex, label + " encoding")
  decoded = varint.readI64(encoded, 0)
  test.record(state, endian.int64Equals(decoded.value, value), label + " value")
end function

// Runs the varint test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  checkU32Golden(state, 0, "00", "u32 zero")
  checkU32Golden(state, 1, "01", "u32 one")
  checkU32Golden(state, 127, "7f", "u32 127")
  checkU32Golden(state, 128, "8001", "u32 128")
  checkU32Golden(state, 255, "ff01", "u32 255")
  checkU32Golden(state, 300, "ac02", "u32 300")
  checkU32Golden(state, 16384, "808001", "u32 16384")
  checkU32Golden(state, endian.MAX_U32, "ffffffff0f", "u32 maximum")

  checkU64Golden(state, endian.makeUInt64(0, 0), "00", "u64 zero")
  checkU64Golden(state, endian.makeUInt64(0, 128), "8001", "u64 128")
  checkU64Golden(state, endian.makeUInt64(0x01234567, 0x89ABCDEF), "ef9bafcdf8acd19101", "u64 mixed")
  checkU64Golden(state, endian.makeUInt64(endian.MAX_U32, endian.MAX_U32), "ffffffffffffffffff01", "u64 maximum")

  checkI32Golden(state, 0, "00", "i32 zero")
  checkI32Golden(state, -1, "01", "i32 minus one")
  checkI32Golden(state, 1, "02", "i32 plus one")
  checkI32Golden(state, -65, "8101", "i32 minus 65")
  checkI32Golden(state, endian.MIN_I32, "ffffffff0f", "i32 minimum")
  checkI32Golden(state, endian.MAX_I32, "feffffff0f", "i32 maximum")

  checkI64Golden(state, endian.makeInt64(0, 0), "00", "i64 zero")
  checkI64Golden(state, endian.makeInt64(endian.MAX_U32, endian.MAX_U32), "01", "i64 minus one")
  checkI64Golden(state, endian.makeInt64(0, 1), "02", "i64 plus one")
  checkI64Golden(state, endian.makeInt64(endian.MAX_U32, endian.MAX_U32 - 1), "03", "i64 minus two")
  checkI64Golden(state, endian.minInt64(), "ffffffffffffffffff01", "i64 minimum")
  checkI64Golden(state, endian.maxInt64(), "feffffffffffffffff01", "i64 maximum")

  // Exhaustive U16-sized scalar domain through the U32 codec.
  reusable = bytes(10, 0)
  for value = 0 to 65535
    next = varint.writeU32(reusable, 0, value)
    decoded = varint.readU32(reusable, 0)
    test.equal(state, decoded.value, value, "u32 exhaustive value " + value)
    test.equal(state, decoded.nextOffset, next, "u32 exhaustive offset " + value)
  end for

  // Deterministic full-width bit patterns.
  high = 0x13579BDF
  low = 0x2468ACE0
  for iteration = 0 to 4095
    high = (high * 1664525 + 1013904223) % endian.U32_BASE
    low = (low * 22695477 + 1) % endian.U32_BASE
    original = endian.makeUInt64(high, low)
    next = varint.writeU64(reusable, 0, original)
    decoded = varint.readU64(reusable, 0)
    test.record(state, endian.uint64Equals(decoded.value, original), "u64 deterministic value " + iteration)
    test.equal(state, decoded.nextOffset, next, "u64 deterministic offset " + iteration)
  end for

  // Offset/canary behavior.
  canary = bytes(20, 0xA5)
  next = varint.writeU64(canary, 5, endian.makeUInt64(0x01234567, 0x89ABCDEF))
  test.equal(state, next, 14, "u64 offset next")
  for index = 0 to 4
    test.equal(state, canary[index], 0xA5, "prefix canary " + index)
  end for
  for index = 14 to 19
    test.equal(state, canary[index], 0xA5, "suffix canary " + index)
  end for

  // Failed writes are atomic.
  shortBuffer = bytes(1, 0xA5)
  failedWrite = try(varint.writeU32(shortBuffer, 0, 128))
  test.errorCode(state, failedWrite, 9001, "short U32 write")
  test.equal(state, hex(shortBuffer), "a5", "short U32 write atomic")

  badValue = try(varint.writeU32(bytes(5, 0xA5), 0, -1))
  test.errorCode(state, badValue, 9001, "negative U32 write")

  test.errorCode(state, try(varint.readU32(fromHex("80"), 0)), 9004, "truncated U32")
  test.errorCode(state, try(varint.readU32(fromHex("8000"), 0)), 9004, "noncanonical U32")
  test.errorCode(state, try(varint.readU32(fromHex("ffffffff1f"), 0)), 9004, "overflow U32")
  test.errorCode(state, try(varint.readU64(fromHex("ffffffffffffffffff02"), 0)), 9004, "overflow U64")
  test.errorCode(state, try(varint.readU64(fromHex("80808080808080808080"), 0)), 9004, "unterminated U64")

  return test.finish(state, "MiniSQL M2 varint tests: SUCCESS", "MiniSQL M2 varint tests: FAIL")
end function
