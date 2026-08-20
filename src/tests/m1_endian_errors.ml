// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import tests.support.testkit as test

// Asserts that an invalid endian operation left the destination buffer byte-for-byte unchanged.
function expectUnchanged(state, buffer, before, label)
  test.equal(state, hex(buffer), before, label)
end function

// Runs the endian errors test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  test.errorCode(state, try(endian.readU16LE("not-bytes", 0)), 9001, "read rejects non-bytes")
  test.errorCode(state, try(endian.readU16LE(bytes(2), true)), 9001, "read rejects bool offset")
  test.errorCode(state, try(endian.readU16LE(bytes(2), -1)), 9001, "read rejects negative offset")
  test.errorCode(state, try(endian.readU16LE(bytes(1), 0)), 9001, "read rejects short buffer")
  test.errorCode(state, try(endian.readU32BE(bytes(8), 5)), 9001, "read rejects overflowing range")
  test.errorCode(state, try(endian.readU64LE(bytes(7), 0)), 9001, "readU64 rejects short buffer")
  test.errorCode(state, try(endian.readI64LE(bytes(7), 0)), 9001, "readI64 rejects short buffer")

  b = bytes(8, 0xA5)
  before = hex(b)
  test.errorCode(state, try(endian.writeU8(b, 0, -1)), 9001, "writeU8 lower bound")
  expectUnchanged(state, b, before, "writeU8 lower bound is atomic")
  test.errorCode(state, try(endian.writeU8(b, 0, 256)), 9001, "writeU8 upper bound")
  expectUnchanged(state, b, before, "writeU8 upper bound is atomic")
  test.errorCode(state, try(endian.writeI8(b, 0, -129)), 9001, "writeI8 lower bound")
  expectUnchanged(state, b, before, "writeI8 lower bound is atomic")
  test.errorCode(state, try(endian.writeI8(b, 0, 128)), 9001, "writeI8 upper bound")
  expectUnchanged(state, b, before, "writeI8 upper bound is atomic")

  test.errorCode(state, try(endian.writeU16LE(b, 0, -1)), 9001, "writeU16 lower bound")
  expectUnchanged(state, b, before, "writeU16 lower bound is atomic")
  test.errorCode(state, try(endian.writeU16BE(b, 0, 65536)), 9001, "writeU16 upper bound")
  expectUnchanged(state, b, before, "writeU16 upper bound is atomic")
  test.errorCode(state, try(endian.writeI16LE(b, 0, -32769)), 9001, "writeI16 lower bound")
  expectUnchanged(state, b, before, "writeI16 lower bound is atomic")
  test.errorCode(state, try(endian.writeI16BE(b, 0, 32768)), 9001, "writeI16 upper bound")
  expectUnchanged(state, b, before, "writeI16 upper bound is atomic")

  test.errorCode(state, try(endian.writeU32LE(b, 0, -1)), 9001, "writeU32 lower bound")
  expectUnchanged(state, b, before, "writeU32 lower bound is atomic")
  test.errorCode(state, try(endian.writeU32BE(b, 0, 4294967296)), 9001, "writeU32 upper bound")
  expectUnchanged(state, b, before, "writeU32 upper bound is atomic")
  test.errorCode(state, try(endian.writeI32LE(b, 0, -2147483649)), 9001, "writeI32 lower bound")
  expectUnchanged(state, b, before, "writeI32 lower bound is atomic")
  test.errorCode(state, try(endian.writeI32BE(b, 0, 2147483648)), 9001, "writeI32 upper bound")
  expectUnchanged(state, b, before, "writeI32 upper bound is atomic")

  test.errorCode(state, try(endian.writeU16LE(b, 7, 1)), 9001, "write rejects overflowing offset")
  expectUnchanged(state, b, before, "overflowing offset is atomic")
  test.errorCode(state, try(endian.writeU32LE(b, -1, 1)), 9001, "write rejects negative offset")
  expectUnchanged(state, b, before, "negative offset is atomic")
  test.errorCode(state, try(endian.writeU32LE(b, 0, true)), 9001, "write rejects bool value")
  expectUnchanged(state, b, before, "bool value is atomic")
  test.errorCode(state, try(endian.writeU32LE("not-bytes", 0, 1)), 9001, "write rejects non-bytes")

  test.errorCode(state, try(endian.makeUInt64(-1, 0)), 9001, "makeUInt64 rejects negative high")
  test.errorCode(state, try(endian.makeUInt64(0, 4294967296)), 9001, "makeUInt64 rejects oversized low")
  test.errorCode(state, try(endian.makeUInt64(true, 0)), 9001, "makeUInt64 rejects bool high")
  test.errorCode(state, try(endian.makeInt64(-1, 0)), 9001, "makeInt64 rejects negative high")
  test.errorCode(state, try(endian.makeInt64(0, 4294967296)), 9001, "makeInt64 rejects oversized low")
  test.errorCode(state, try(endian.makeInt64(0, false)), 9001, "makeInt64 rejects bool low")

  test.errorCode(state, try(endian.uint64FromInt(-1)), 9001, "uint64FromInt rejects negative")
  test.errorCode(state, try(endian.uint64FromInt("1")), 9001, "uint64FromInt rejects string")
  test.errorCode(state, try(endian.uint64ToInt(endian.makeUInt64(0x10000000, 0))), 9001, "uint64ToInt rejects first scalar overflow")
  test.errorCode(state, try(endian.uint64ToInt(endian.makeUInt64(0x80000000, 0))), 9001, "uint64ToInt rejects large unsigned value")
  test.errorCode(state, try(endian.uint64ToInt(123)), 9001, "uint64ToInt rejects non-words")
  test.errorCode(state, try(endian.uint64Equals(endian.makeUInt64(0, 0), endian.makeInt64(0, 0))), 9001, "uint64Equals rejects signed words")

  test.errorCode(state, try(endian.int64FromInt("1")), 9001, "int64FromInt rejects string")
  test.errorCode(state, try(endian.int64ToInt(endian.makeInt64(0x10000000, 0))), 9001, "int64ToInt rejects positive scalar overflow")
  test.errorCode(state, try(endian.int64ToInt(endian.makeInt64(0xEFFFFFFF, 0xFFFFFFFF))), 9001, "int64ToInt rejects negative scalar overflow")
  test.errorCode(state, try(endian.int64ToInt(endian.makeInt64(0x80000000, 0))), 9001, "int64ToInt rejects I64 minimum")
  test.errorCode(state, try(endian.int64ToInt(123)), 9001, "int64ToInt rejects scalar input")
  test.errorCode(state, try(endian.int64Equals(endian.makeInt64(0, 0), endian.makeUInt64(0, 0))), 9001, "int64Equals rejects unsigned words")
  test.errorCode(state, try(endian.int64IsNegative(endian.makeUInt64(0, 0))), 9001, "int64IsNegative rejects unsigned words")
  test.errorCode(state, try(endian.uint64BitsToInt64(endian.makeInt64(0, 0))), 9001, "U64 bit cast rejects signed words")
  test.errorCode(state, try(endian.int64BitsToUInt64(endian.makeUInt64(0, 0))), 9001, "I64 bit cast rejects unsigned words")

  badUHigh = endian.UInt64Words(4294967296, 0)
  test.errorCode(state, try(endian.writeU64LE(b, 0, badUHigh)), 9001, "writeU64 rejects oversized high")
  expectUnchanged(state, b, before, "writeU64 oversized high is atomic")
  badULow = endian.UInt64Words(0, -1)
  test.errorCode(state, try(endian.writeU64BE(b, 0, badULow)), 9001, "writeU64 rejects negative low")
  expectUnchanged(state, b, before, "writeU64 negative low is atomic")
  test.errorCode(state, try(endian.writeU64LE(b, 1, endian.makeUInt64(0, 0))), 9001, "writeU64 rejects short tail")
  expectUnchanged(state, b, before, "writeU64 short tail is atomic")
  test.errorCode(state, try(endian.writeU64LE(b, 0, 123)), 9001, "writeU64 rejects scalar")
  expectUnchanged(state, b, before, "writeU64 scalar is atomic")
  test.errorCode(state, try(endian.writeU64LE(b, 0, endian.makeInt64(0, 0))), 9001, "writeU64 rejects signed words")
  expectUnchanged(state, b, before, "writeU64 signed words is atomic")

  badIHigh = endian.Int64Words(4294967296, 0)
  test.errorCode(state, try(endian.writeI64LE(b, 0, badIHigh)), 9001, "writeI64 rejects oversized high")
  expectUnchanged(state, b, before, "writeI64 oversized high is atomic")
  badILow = endian.Int64Words(0, -1)
  test.errorCode(state, try(endian.writeI64BE(b, 0, badILow)), 9001, "writeI64 rejects negative low")
  expectUnchanged(state, b, before, "writeI64 negative low is atomic")
  test.errorCode(state, try(endian.writeI64LE(b, 1, endian.makeInt64(0, 0))), 9001, "writeI64 rejects short tail")
  expectUnchanged(state, b, before, "writeI64 short tail is atomic")
  test.errorCode(state, try(endian.writeI64LE(b, 0, -1)), 9001, "writeI64 rejects scalar")
  expectUnchanged(state, b, before, "writeI64 scalar is atomic")
  test.errorCode(state, try(endian.writeI64LE(b, 0, endian.makeUInt64(0, 0))), 9001, "writeI64 rejects unsigned words")
  expectUnchanged(state, b, before, "writeI64 unsigned words is atomic")

  test.errorCode(state, try(endian.writeI64FromIntLE(b, 0, "-1")), 9001, "writeI64FromInt rejects string")
  expectUnchanged(state, b, before, "writeI64FromInt string is atomic")
  test.errorCode(state, try(endian.writeI64FromIntBE(b, 1, 0)), 9001, "writeI64FromInt rejects short tail")
  expectUnchanged(state, b, before, "writeI64FromInt short tail is atomic")

  fullMaximum = bytes(8, 0)
  endian.writeI64LE(fullMaximum, 0, endian.maxInt64())
  test.errorCode(state, try(endian.readI64AsIntLE(fullMaximum, 0)), 9001, "readI64AsInt rejects I64 maximum")
  fullMinimum = bytes(8, 0)
  endian.writeI64BE(fullMinimum, 0, endian.minInt64())
  test.errorCode(state, try(endian.readI64AsIntBE(fullMinimum, 0)), 9001, "readI64AsInt rejects I64 minimum")

  test.verifyChecks(state, 85, "m1_endian_errors.ml check count")

  return test.finish(
    state,
    "MiniSQL M1R1 endian error tests: SUCCESS",
    "MiniSQL M1R1 endian error tests: FAIL"
  )
end function
