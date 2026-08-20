// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import tests.support.testkit as test

// Runs the int64 model test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  // MiniLang scalar payload boundaries used by every scalar conversion helper.
  test.equal(state, endian.MAX_MINILANG_INT, 1152921504606846975, "MiniLang scalar maximum")
  test.equal(state, endian.MIN_MINILANG_INT, -1152921504606846976, "MiniLang scalar minimum")

  unsignedMaximum = endian.uint64FromInt(endian.MAX_MINILANG_INT)
  test.equal(state, unsignedMaximum.high, 0x0FFFFFFF, "unsigned scalar maximum high")
  test.equal(state, unsignedMaximum.low, 0xFFFFFFFF, "unsigned scalar maximum low")
  test.equal(state, endian.uint64ToInt(unsignedMaximum), endian.MAX_MINILANG_INT, "unsigned scalar maximum roundtrip")
  test.errorCode(state, try(endian.uint64ToInt(endian.makeUInt64(0x10000000, 0))), 9001, "first unsigned value outside scalar domain")

  signedMaximum = endian.int64FromInt(endian.MAX_MINILANG_INT)
  test.equal(state, signedMaximum.high, 0x0FFFFFFF, "signed scalar maximum high")
  test.equal(state, signedMaximum.low, 0xFFFFFFFF, "signed scalar maximum low")
  test.equal(state, endian.int64ToInt(signedMaximum), endian.MAX_MINILANG_INT, "signed scalar maximum roundtrip")
  test.equal(state, endian.int64IsNegative(signedMaximum), false, "signed scalar maximum sign")

  signedMinimum = endian.int64FromInt(endian.MIN_MINILANG_INT)
  test.equal(state, signedMinimum.high, 0xF0000000, "signed scalar minimum high")
  test.equal(state, signedMinimum.low, 0, "signed scalar minimum low")
  test.equal(state, endian.int64ToInt(signedMinimum), endian.MIN_MINILANG_INT, "signed scalar minimum roundtrip")
  test.equal(state, endian.int64IsNegative(signedMinimum), true, "signed scalar minimum sign")

  fullMinimum = endian.minInt64()
  test.equal(state, fullMinimum.high, 0x80000000, "full I64 minimum high")
  test.equal(state, fullMinimum.low, 0, "full I64 minimum low")
  test.equal(state, endian.int64IsNegative(fullMinimum), true, "full I64 minimum sign")
  test.errorCode(state, try(endian.int64ToInt(fullMinimum)), 9001, "full I64 minimum is not scalar")

  fullMaximum = endian.maxInt64()
  test.equal(state, fullMaximum.high, 0x7FFFFFFF, "full I64 maximum high")
  test.equal(state, fullMaximum.low, 0xFFFFFFFF, "full I64 maximum low")
  test.equal(state, endian.int64IsNegative(fullMaximum), false, "full I64 maximum sign")
  test.errorCode(state, try(endian.int64ToInt(fullMaximum)), 9001, "full I64 maximum is not scalar")

  firstPositiveOverflow = endian.makeInt64(0x10000000, 0)
  test.errorCode(state, try(endian.int64ToInt(firstPositiveOverflow)), 9001, "first positive I64 scalar overflow")
  lastNegativeOverflow = endian.makeInt64(0xEFFFFFFF, 0xFFFFFFFF)
  test.errorCode(state, try(endian.int64ToInt(lastNegativeOverflow)), 9001, "last negative I64 scalar overflow")

  b = bytes(8, 0)
  endian.writeI64LE(b, 0, fullMinimum)
  test.equal(state, hex(b), "0000000000000080", "full I64 minimum LE bytes")
  readSigned = endian.readI64LE(b, 0)
  test.equal(state, readSigned.high, fullMinimum.high, "full I64 minimum LE high")
  test.equal(state, readSigned.low, fullMinimum.low, "full I64 minimum LE low")
  test.errorCode(state, try(endian.readI64AsIntLE(b, 0)), 9001, "full I64 minimum LE scalar read rejected")

  endian.writeI64BE(b, 0, fullMaximum)
  test.equal(state, hex(b), "7fffffffffffffff", "full I64 maximum BE bytes")
  readSigned = endian.readI64BE(b, 0)
  test.equal(state, readSigned.high, fullMaximum.high, "full I64 maximum BE high")
  test.equal(state, readSigned.low, fullMaximum.low, "full I64 maximum BE low")
  test.errorCode(state, try(endian.readI64AsIntBE(b, 0)), 9001, "full I64 maximum BE scalar read rejected")

  before = hex(b)
  test.errorCode(state, try(endian.writeI64LE(b, 0, -1)), 9001, "full I64 API rejects scalar")
  test.equal(state, hex(b), before, "full I64 scalar rejection is atomic")
  test.equal(state, endian.writeI64FromIntLE(b, 0, -1), 8, "scalar convenience write offset")
  test.equal(state, hex(b), "ffffffffffffffff", "scalar convenience write bytes")
  test.equal(state, endian.readI64AsIntLE(b, 0), -1, "scalar convenience read")

  test.verifyChecks(state, 37, "m1_int64_model.ml check count")

  return test.finish(
    state,
    "MiniSQL M1R1 tagged-int and I64 model tests: SUCCESS",
    "MiniSQL M1R1 tagged-int and I64 model tests: FAIL"
  )
end function
