// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.crc32c as crc32c
import minisql.storage.checksum as checksum
import tests.support.testkit as test
import std.cpu as cpu

// Runs the crc envelope test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()

  test.equal(state, crc32c.compute(bytes()), 0, "CRC empty")
  test.equal(state, crc32c.compute(bytes("123456789")), 0xE3069283, "CRC check string")
  test.equal(state, crc32c.compute(bytes("abc")), 0x364B3FB7, "CRC abc")
  test.equal(state, crc32c.compute(bytes(32, 0)), 0x8A9136AA, "CRC 32 zero bytes")

  // Exact values on both sides of every eight-byte block boundary protect the
  // native qword path and its scalar tail from off-by-one regressions.
  boundaryLengths = [1, 7, 8, 9, 15, 16, 17, 4096, 4097]
  boundaryChecksums = [0x527D5351, 0xBB3E6A6D, 0x8C28B28A, 0xBBE568A3, 0x530ED410, 0x42709AEA, 0xDAEDA3E9, 0x98F94189, 0xA8A14AA4]
  for index = 0 to len(boundaryLengths) - 1
    test.equal(state, crc32c.compute(bytes(boundaryLengths[index], 0)), boundaryChecksums[index], "CRC native boundary " + boundaryLengths[index])
  end for

  allBytes = bytes(256, 0)
  for index = 0 to 255
    allBytes[index] = index
  end for
  test.equal(state, crc32c.compute(allBytes), 0x9C44184B, "CRC byte ramp")
  // Force the portable backend to prove that databases remain readable on
  // processors without SSE4.2 and that dispatch changes no serialized bit.
  detectedFeatures = cpu.features()
  previousDispatch = cpu.setDispatchMaskForTesting(detectedFeatures ^ (detectedFeatures & cpu.SSE42))
  test.equal(state, crc32c.compute(allBytes), 0x9C44184B, "CRC software fallback byte ramp")
  cpu.setDispatchMaskForTesting(previousDispatch)
  test.equal(state, crc32c.compute(allBytes), 0x9C44184B, "CRC restored hardware dispatch")

  text = bytes("123456789")
  partial = crc32c.update(0, text, 0, 4)
  partial = crc32c.update(partial, text, 4, 5)
  test.equal(state, partial, 0xE3069283, "CRC incremental")
  zeroSeventeen = bytes(17, 0)
  boundaryPartial = crc32c.update(0, zeroSeventeen, 0, 7)
  boundaryPartial = crc32c.update(boundaryPartial, zeroSeventeen, 7, 8)
  boundaryPartial = crc32c.update(boundaryPartial, zeroSeventeen, 15, 2)
  test.equal(state, boundaryPartial, 0xDAEDA3E9, "CRC incremental across native boundaries")
  test.equal(state, crc32c.computeRange(text, 2, 4), crc32c.compute(bytes("3456")), "CRC range")
  test.record(state, crc32c.verifyRange(text, 0, len(text), 0xE3069283), "CRC verify")
  test.record(state, not crc32c.verifyRange(text, 0, len(text), 0), "CRC reject mismatch")
  test.errorCode(state, try(crc32c.computeRange(text, -1, 1)), 9001, "CRC invalid range")
  test.errorCode(state, try(checksum.compute(checksum.ALGORITHM_NONE, text, -1, 1)), 9001, "NONE checksum still validates range")
  test.errorCode(state, try(checksum.verify(checksum.ALGORITHM_CRC32C, text, 0, len(text), -1)), 9001, "checksum expected value validation")

  magic = bytes("TESTENV1")
  payload = bytes("MiniSQL protected payload")
  encoded = checksum.encodeEnvelope(magic, 1, 7, 0x12345678, payload)
  decoded = checksum.decodeEnvelope(encoded, magic, 1, 7)
  test.equal(state, decoded.version, 1, "envelope version")
  test.equal(state, decoded.kind, 7, "envelope kind")
  test.equal(state, decoded.flags, 0x12345678, "envelope flags")
  test.equal(state, hex(decoded.payload), hex(payload), "envelope payload")
  test.equal(state, decoded.payloadChecksum, crc32c.compute(payload), "envelope payload checksum")

  emptyEncoded = checksum.encodeEnvelope(magic, 1, 8, 0, bytes())
  emptyDecoded = checksum.decodeEnvelope(emptyEncoded, magic, 1, 8)
  test.equal(state, len(emptyDecoded.payload), 0, "empty envelope")

  corruptHeader = bytes(encoded)
  corruptHeader[12] = corruptHeader[12] ^ 1
  test.errorCode(state, try(checksum.decodeEnvelope(corruptHeader, magic, 1, 7)), 9004, "corrupt envelope header")

  reservedField = bytes(encoded)
  reservedField[28] = 1
  test.errorCode(state, try(checksum.decodeEnvelope(reservedField, magic, 1, 7)), 9003, "reserved envelope field")

  corruptPayload = bytes(encoded)
  corruptPayload[checksum.ENVELOPE_HEADER_SIZE] = corruptPayload[checksum.ENVELOPE_HEADER_SIZE] ^ 1
  test.errorCode(state, try(checksum.decodeEnvelope(corruptPayload, magic, 1, 7)), 9004, "corrupt envelope payload")

  truncated = slice(encoded, 0, len(encoded) - 1)
  test.errorCode(state, try(checksum.decodeEnvelope(truncated, magic, 1, 7)), 9004, "truncated envelope")
  test.errorCode(state, try(checksum.decodeEnvelope(encoded, bytes("BADMAGIC"), 1, 7)), 9003, "envelope magic mismatch")
  test.errorCode(state, try(checksum.decodeEnvelope(encoded, magic, 2, 7)), 9003, "envelope version mismatch")
  test.errorCode(state, try(checksum.decodeEnvelope(encoded, magic, 1, 9)), 9003, "envelope kind mismatch")
  test.errorCode(state, try(checksum.compute(99, payload, 0, len(payload))), 9003, "unknown checksum algorithm")

  return test.finish(state, "MiniSQL M2 CRC32C and envelope tests: SUCCESS", "MiniSQL M2 CRC32C and envelope tests: FAIL")
end function
