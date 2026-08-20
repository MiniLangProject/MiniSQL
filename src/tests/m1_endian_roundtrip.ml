// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import tests.support.testkit as test

// Advances the deterministic 32-bit pseudo-random sequence used to cover endian round trips reproducibly.
function nextU32(value)
  return (value * 1664525 + 1013904223) % 4294967296
end function

// Verifies that an endian codec touched only its requested byte range, preserving every surrounding canary byte.
function checkCanaries(state, buffer, start, width, label)
  for index = 0 to len(buffer) - 1
    if index < start or index >= start + width then
      if buffer[index] != 0xA5 then
        test.record(state, false, label + " canary index=" + index)
        return
      end if
    end if
  end for
  test.record(state, true, label + " canaries")
end function

// Runs the endian roundtrip test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  b1 = bytes(1, 0)
  for value = 0 to 255
    endian.writeU8(b1, 0, value)
    test.equal(state, endian.readU8(b1, 0), value, "exhaustive U8 roundtrip")
  end for
  for value = -128 to 127
    endian.writeI8(b1, 0, value)
    test.equal(state, endian.readI8(b1, 0), value, "exhaustive I8 roundtrip")
  end for

  b2 = bytes(2, 0)
  for value = 0 to 65535
    endian.writeU16LE(b2, 0, value)
    test.equal(state, endian.readU16LE(b2, 0), value, "exhaustive U16LE roundtrip")
    endian.writeU16BE(b2, 0, value)
    test.equal(state, endian.readU16BE(b2, 0), value, "exhaustive U16BE roundtrip")

    signed16 = value
    if signed16 >= 32768 then
      signed16 = signed16 - 65536
    end if
    endian.writeI16LE(b2, 0, signed16)
    test.equal(state, endian.readI16LE(b2, 0), signed16, "exhaustive I16LE roundtrip")
    endian.writeI16BE(b2, 0, signed16)
    test.equal(state, endian.readI16BE(b2, 0), signed16, "exhaustive I16BE roundtrip")
  end for

  state32 = 0x13579BDF
  b4 = bytes(4, 0)
  for iteration = 0 to 4095
    state32 = nextU32(state32)
    unsigned = state32
    signed32 = unsigned
    if signed32 >= 2147483648 then
      signed32 = signed32 - 4294967296
    end if

    endian.writeU32LE(b4, 0, unsigned)
    test.equal(state, endian.readU32LE(b4, 0), unsigned, "random U32LE roundtrip")
    endian.writeU32BE(b4, 0, unsigned)
    test.equal(state, endian.readU32BE(b4, 0), unsigned, "random U32BE roundtrip")
    endian.writeI32LE(b4, 0, signed32)
    test.equal(state, endian.readI32LE(b4, 0), signed32, "random I32LE roundtrip")
    endian.writeI32BE(b4, 0, signed32)
    test.equal(state, endian.readI32BE(b4, 0), signed32, "random I32BE roundtrip")
  end for

  high = 0x2468ACE0
  low = 0xFDB97531
  b8 = bytes(8, 0)
  for iteration = 0 to 2047
    high = nextU32(high)
    low = nextU32(low)
    unsignedWords = endian.makeUInt64(high, low)

    endian.writeU64LE(b8, 0, unsignedWords)
    readUnsigned = endian.readU64LE(b8, 0)
    test.equal(state, readUnsigned.high, high, "random U64LE high")
    test.equal(state, readUnsigned.low, low, "random U64LE low")

    endian.writeU64BE(b8, 0, unsignedWords)
    readUnsigned = endian.readU64BE(b8, 0)
    test.equal(state, readUnsigned.high, high, "random U64BE high")
    test.equal(state, readUnsigned.low, low, "random U64BE low")

    signedWords = endian.makeInt64(high, low)
    endian.writeI64LE(b8, 0, signedWords)
    readSigned = endian.readI64LE(b8, 0)
    test.equal(state, readSigned.high, high, "random I64LE high")
    test.equal(state, readSigned.low, low, "random I64LE low")

    endian.writeI64BE(b8, 0, signedWords)
    readSigned = endian.readI64BE(b8, 0)
    test.equal(state, readSigned.high, high, "random I64BE high")
    test.equal(state, readSigned.low, low, "random I64BE low")

    castSigned = endian.uint64BitsToInt64(unsignedWords)
    test.equal(state, castSigned.high, high, "random U64 to I64 high")
    test.equal(state, castSigned.low, low, "random U64 to I64 low")
    castUnsigned = endian.int64BitsToUInt64(signedWords)
    test.equal(state, castUnsigned.high, high, "random I64 to U64 high")
    test.equal(state, castUnsigned.low, low, "random I64 to U64 low")
  end for

  scalarHighState = 0x0BADF00D
  scalarLowState = 0x10203040
  for iteration = 0 to 2047
    scalarHighState = nextU32(scalarHighState)
    scalarLowState = nextU32(scalarLowState)
    scalarHigh = scalarHighState & 0x0FFFFFFF
    positive = scalarHigh * endian.U32_BASE + scalarLowState

    scalarWords = endian.int64FromInt(positive)
    test.equal(state, endian.int64ToInt(scalarWords), positive, "random positive scalar conversion")
    endian.writeI64FromIntLE(b8, 0, positive)
    test.equal(state, endian.readI64AsIntLE(b8, 0), positive, "random positive scalar LE")
    endian.writeI64FromIntBE(b8, 0, positive)
    test.equal(state, endian.readI64AsIntBE(b8, 0), positive, "random positive scalar BE")

    negative = -positive
    scalarWords = endian.int64FromInt(negative)
    test.equal(state, endian.int64ToInt(scalarWords), negative, "random negative scalar conversion")
    endian.writeI64FromIntLE(b8, 0, negative)
    test.equal(state, endian.readI64AsIntLE(b8, 0), negative, "random negative scalar LE")
    endian.writeI64FromIntBE(b8, 0, negative)
    test.equal(state, endian.readI64AsIntBE(b8, 0), negative, "random negative scalar BE")
  end for

  scalarBoundaryValues = [
    endian.MIN_MINILANG_INT,
    endian.MIN_MINILANG_INT + 1,
    -4294967297,
    -4294967296,
    -4294967295,
    -2,
    -1,
    0,
    1,
    2,
    4294967295,
    4294967296,
    4294967297,
    endian.MAX_MINILANG_INT - 1,
    endian.MAX_MINILANG_INT,
  ]
  for each value in scalarBoundaryValues
    scalarWords = endian.int64FromInt(value)
    test.equal(state, endian.int64ToInt(scalarWords), value, "I64 scalar boundary conversion")
    endian.writeI64FromIntLE(b8, 0, value)
    test.equal(state, endian.readI64AsIntLE(b8, 0), value, "I64 scalar boundary LE")
    endian.writeI64FromIntBE(b8, 0, value)
    test.equal(state, endian.readI64AsIntBE(b8, 0), value, "I64 scalar boundary BE")
  end for

  fullI64Patterns = [
    endian.makeInt64(0x80000000, 0x00000000),
    endian.makeInt64(0x80000000, 0x00000001),
    endian.makeInt64(0xFFFFFFFF, 0xFFFFFFFE),
    endian.makeInt64(0xFFFFFFFF, 0xFFFFFFFF),
    endian.makeInt64(0x7FFFFFFF, 0xFFFFFFFE),
    endian.makeInt64(0x7FFFFFFF, 0xFFFFFFFF),
  ]
  for each pattern in fullI64Patterns
    endian.writeI64LE(b8, 0, pattern)
    readSigned = endian.readI64LE(b8, 0)
    test.equal(state, readSigned.high, pattern.high, "full I64 pattern LE high")
    test.equal(state, readSigned.low, pattern.low, "full I64 pattern LE low")
    endian.writeI64BE(b8, 0, pattern)
    readSigned = endian.readI64BE(b8, 0)
    test.equal(state, readSigned.high, pattern.high, "full I64 pattern BE high")
    test.equal(state, readSigned.low, pattern.low, "full I64 pattern BE low")
  end for

  for offset = 0 to 16
    guarded = bytes(24, 0xA5)
    endian.writeU64LE(guarded, offset, endian.makeUInt64(0x89ABCDEF, 0x01234567))
    readUnsigned = endian.readU64LE(guarded, offset)
    test.equal(state, readUnsigned.high, 0x89ABCDEF, "offset U64 high")
    test.equal(state, readUnsigned.low, 0x01234567, "offset U64 low")
    checkCanaries(state, guarded, offset, 8, "offset U64")
  end for

  test.verifyChecks(state, 316024, "m1_endian_roundtrip.ml check count")

  return test.finish(
    state,
    "MiniSQL M1R1 endian roundtrip tests: SUCCESS",
    "MiniSQL M1R1 endian roundtrip tests: FAIL"
  )
end function
