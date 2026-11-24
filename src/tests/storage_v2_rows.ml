// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.common.float_codec as floats
import minisql.storage.page as page
import minisql.storage.row_codec as rows
import minisql.storage.slotted_page as slotted
import tests.support.testkit as testkit

#if TARGET_OS == "windows"
/// Produces a native NaN for the finite-input rejection test.
extern function testSqrt(value as double) from "msvcrt.dll" symbol "sqrt" returns double
#else
/// Produces a native NaN for the finite-input rejection test.
extern function testSqrt(value as double) from "libm.so.6" symbol "sqrt" returns double
#endif

/// Checks exact binary64 bits through decode, encode, and a physical SQL row.
function checkFloatBits(state, spelling, label)
  encoded = fromHex(spelling)
  value = floats.decodeFloat64LE(encoded, 0)
  testkit.equal(state, typeof(value), "float", label + " remains float")
  testkit.equal(state, hex(floats.encodeFloat64LE(value)), spelling, label + " exact bits")
  schema = rows.schema(1, [rows.column(rows.TYPE_DOUBLE, false, 0, 0, 0)])
  row = rows.encode(schema, [value])
  decoded = rows.decodeRow(schema, row)
  testkit.equal(state, hex(floats.encodeFloat64LE(decoded.values[0])), spelling, label + " row roundtrip")
end function

/// Checks source-level numeric input against independent IEEE-754 golden bytes.
function checkFloatValue(state, value, spelling, label)
  testkit.equal(state, hex(floats.encodeFloat64LE(value)), spelling, label)
end function

/// Builds the user-facing three-column row example.
function exampleSchema(version)
  return rows.schema(version, [
    rows.column(rows.TYPE_BIGINT, false, 0, 0, 0),
    rows.column(rows.TYPE_TEXT, true, 0, 0, 0),
    rows.column(rows.TYPE_BOOLEAN, false, 0, 0, 0)
  ])
end function

/// Runs binary64, row alignment, corruption, and slotted-allocation regressions.
function main(args)
  state = testkit.create()
  checkFloatValue(state, 0.0, "0000000000000000", "positive zero")
  checkFloatValue(state, 1.0, "000000000000f03f", "one")
  checkFloatValue(state, -2.5, "00000000000004c0", "negative finite")
  checkFloatValue(state, 0.1, "9a9999999999b93f", "decimal literal full precision")
  checkFloatValue(state, 1.0000000000000002, "010000000000f03f", "next representable one")
  checkFloatValue(state, 9007199254740991, "ffffffffffff3f43", "largest exact 53-bit integer")
  patterns = [
    "0000000000000000", "0000000000000080",
    "0100000000000000", "0100000000000080",
    "ffffffffffff0f00", "ffffffffffff0f80",
    "0000000000001000", "0000000000001080",
    "010000000000f03f", "ffffffffffffef7f", "ffffffffffffefff",
    "9a9999999999b93f", "182d4454fb210940", "785634120000f03f"
  ]
  for index = 0 to len(patterns) - 1
    checkFloatBits(state, patterns[index], "binary64 vector " + index)
  end for
  // Exercise finite bit patterns across signs, exponents and significands,
  // independently of decimal parsing and source literal rounding.
  lowWord = 0x9e3779b9
  highWord = 0x12345678
  for index = 0 to 127
    lowWord = (lowWord * 1664525 + 1013904223) & 0xFFFFFFFF
    highWord = (highWord * 22695477 + 1) & 0xFFFFFFFF
    finiteHigh = highWord
    if ((finiteHigh >> 20) & 2047) == 2047 then finiteHigh = finiteHigh ^ 0x00100000 end if
    vector = bytes(8, 0)
    endian.writeU32LE(vector, 0, lowWord)
    endian.writeU32LE(vector, 4, finiteHigh)
    checkFloatBits(state, hex(vector), "finite bit pattern " + index)
  end for
  testkit.errorCode(state, try(floats.decodeFloat64LE(fromHex("000000000000f07f"), 0)), floats.CORRUPT_DATA, "infinity bytes rejected")
  testkit.errorCode(state, try(floats.decodeFloat64LE(fromHex("000000000000f8ff"), 0)), floats.CORRUPT_DATA, "NaN bytes rejected")
  testkit.errorCode(state, try(floats.encodeFloat64LE(floats.nativeLdexp(1.0, 1024))), floats.TYPE_MISMATCH, "infinity value rejected")
  testkit.errorCode(state, try(floats.encodeFloat64LE(testSqrt(-1.0))), floats.TYPE_MISMATCH, "NaN value rejected")
  testkit.errorCode(state, try(floats.decodeFloat64LE(bytes(7), 0)), floats.INVALID_ARGUMENT, "truncated float rejected")

  schema = exampleSchema(1)
  encoded = rows.encode(schema, [endian.int64FromInt(1), "Nils", true])
  expected = "4d535257020001000300010018000000000000000000000004000000300008000a00000038000400010000003c00010001000000000000004e696c7301000000"
  testkit.equal(state, hex(encoded), expected, "exact aligned row vector")
  testkit.equal(state, len(encoded), 64, "example row length")
  testkit.equal(state, endian.readU16LE(encoded, 12), 24, "directory starts on eight-byte boundary")
  testkit.equal(state, endian.readU16LE(encoded, 28), 48, "BIGINT offset")
  testkit.equal(state, endian.readU16LE(encoded, 36), 56, "TEXT offset")
  testkit.equal(state, endian.readU16LE(encoded, 44), 60, "BOOLEAN offset")

  // Reserved header, bitmap-directory padding, field offsets and tail padding
  // remain invalid even when their enclosing page checksum would be recomputed.
  corrupt = bytes(encoded)
  corrupt[4] = 1
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.UNSUPPORTED_FORMAT, "v1 row rejected")
  corrupt = bytes(encoded)
  corrupt[17] = 1
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "directory padding rejected")
  corrupt = bytes(encoded)
  corrupt[63] = 1
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "row tail padding rejected")
  corrupt = bytes(encoded)
  endian.writeU16LE(corrupt, 28, 49)
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "misaligned scalar offset rejected")
  corrupt = bytes(encoded)
  endian.writeU16LE(corrupt, 30, 65535)
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "value length outside row rejected")
  corrupt = bytes(encoded)
  endian.writeU16LE(corrupt, 12, 65528)
  testkit.errorCode(state, try(rows.decodeRow(schema, corrupt)), rows.CORRUPT_DATA, "directory outside row rejected")
  testkit.errorCode(state, try(rows.decodeRow(schema, encoded + bytes(8, 0))), rows.CORRUPT_DATA, "redundant aligned tail rejected")
  testkit.errorCode(state, try(rows.decodeRow(schema, slice(encoded, 0, 63))), rows.CORRUPT_DATA, "unaligned length rejected")

  // Inter-value padding exercises every scalar alignment, NULL, empty values,
  // and an external pointer following an unaligned one-byte string.
  mixed = rows.schema(1, [
    rows.column(rows.TYPE_BOOLEAN, false, 0, 0, 0),
    rows.column(rows.TYPE_SMALLINT, false, 0, 0, 0),
    rows.column(rows.TYPE_BOOLEAN, false, 0, 0, 0),
    rows.column(rows.TYPE_INTEGER, false, 0, 0, 0),
    rows.column(rows.TYPE_BOOLEAN, false, 0, 0, 0),
    rows.column(rows.TYPE_REAL, false, 0, 0, 0),
    rows.column(rows.TYPE_TEXT, false, 0, 0, 0),
    rows.column(rows.TYPE_BLOB, false, 0, 0, 0),
    rows.column(rows.TYPE_INTEGER, true, 0, 0, 0),
    rows.column(rows.TYPE_VARCHAR, false, 8, 0, 0)
  ])
  mixedRow = rows.encode(mixed, [true, -123, false, 123456, true, 0.1, "x", rows.external(bytes(48, 0x11)), rows.nullValue(), ""])
  offsets = [104, 106, 108, 112, 116, 120, 128, 136, 184, 184]
  for index = 0 to len(offsets) - 1
    testkit.equal(state, endian.readU16LE(mixedRow, 24 + index * 8 + 4), offsets[index], "natural alignment " + index)
  end for
  testkit.equal(state, len(mixedRow), 184, "mixed row aligned length")
  mixedDecoded = rows.decodeRow(mixed, mixedRow)
  testkit.record(state, rows.isNull(mixedDecoded.values[8]), "NULL remains NULL")
  testkit.equal(state, mixedDecoded.values[9], "", "empty string remains distinct from NULL")
  for each badOffset in [105, 109, 117, 129]
    corrupt = bytes(mixedRow)
    corrupt[badOffset] = 1
    testkit.errorCode(state, try(rows.decodeCompatible(mixed, corrupt)), rows.CORRUPT_DATA, "inter-value padding rejected " + badOffset)
  end for
  newer = rows.schema(2, schema.columns + [rows.column(rows.TYPE_INTEGER, true, 0, 0, 0)])
  testkit.equal(state, len(rows.decodeCompatible(newer, encoded).values), 3, "schema-prefix evolution remains valid")

  raw = slotted.create(4096, 100, 1)
  firstSlot = slotted.insert(raw, bytes("abc"))
  secondSlot = slotted.insert(raw, bytes(9, 0x5a))
  testkit.equal(state, slotted.entry(raw, firstSlot).dataOffset, 4088, "three-byte record allocation")
  testkit.equal(state, slotted.entry(raw, secondSlot).dataOffset, 4072, "nine-byte record allocation")
  testkit.equal(state, slotted.entry(raw, firstSlot).dataLength, 3, "slot length excludes padding")
  testkit.equal(state, slotted.freeBytes(raw), 3992, "padding charged to page space")
  corrupt = bytes(raw)
  corrupt[4091] = 1
  page.reseal(corrupt)
  testkit.errorCode(state, try(slotted.validate(corrupt, "test")), slotted.CORRUPT_DATA, "slot padding rejected")
  corruptBefore = bytes(corrupt)
  testkit.errorCode(state, try(slotted.compact(corrupt)), slotted.CORRUPT_DATA, "compaction rejects corrupt padding")
  testkit.equal(state, hex(corrupt), hex(corruptBefore), "failed compaction is byte atomic")
  corrupt = bytes(raw)
  endian.writeU16LE(corrupt, slotted.slotOffset(firstSlot), 4089)
  page.reseal(corrupt)
  testkit.errorCode(state, try(slotted.validate(corrupt, "test")), slotted.CORRUPT_DATA, "unaligned slot offset rejected")
  corrupt = bytes(raw)
  endian.writeU16LE(corrupt, slotted.slotOffset(firstSlot) + 2, 65535)
  page.reseal(corrupt)
  testkit.errorCode(state, try(slotted.validate(corrupt, "test")), slotted.CORRUPT_DATA, "allocation outside page rejected")
  corrupt = bytes(raw)
  endian.writeU16LE(corrupt, slotted.slotOffset(secondSlot), 4088)
  page.reseal(corrupt)
  testkit.errorCode(state, try(slotted.validate(corrupt, "test")), slotted.CORRUPT_DATA, "overlapping allocations rejected")
  slotted.update(raw, firstSlot, bytes(17, 0x33))
  slotted.compact(raw)
  testkit.equal(state, slotted.entry(raw, firstSlot).dataOffset % 8, 0, "update alignment")
  testkit.equal(state, slotted.entry(raw, secondSlot).dataOffset % 8, 0, "compaction alignment")
  oldGeneration = slotted.entry(raw, secondSlot).generation
  slotted.remove(raw, secondSlot)
  replacement = slotted.insert(raw, bytes(1, 0x44))
  testkit.equal(state, replacement, secondSlot, "deleted slot reused")
  testkit.equal(state, slotted.entry(raw, replacement).generation, oldGeneration + 1, "generation retained on reuse")
  testkit.equal(state, len(slotted.read(raw, replacement)), 1, "padding is not returned as record data")
  full = slotted.create(4096, 101, 1)
  slotted.insert(full, bytes(4023, 0x55))
  testkit.equal(state, slotted.freeBytes(full), 0, "near-page record consumes rounded allocation")
  snapshot = bytes(full)
  testkit.errorCode(state, try(slotted.insert(full, bytes(1, 0x66))), slotted.PAGE_FULL, "aligned page capacity enforced")
  testkit.equal(state, hex(full), hex(snapshot), "failed insertion is byte atomic")
  testkit.errorCode(state, try(slotted.update(full, 0, bytes(4025, 0x77))), slotted.PAGE_FULL, "growing update accounts for aligned size")
  testkit.equal(state, hex(full), hex(snapshot), "failed update is byte atomic")
  return testkit.finish(state, "MiniSQL storage v2 row tests: SUCCESS", "MiniSQL storage v2 row tests: FAIL")
end function
