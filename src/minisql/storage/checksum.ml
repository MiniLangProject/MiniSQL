//! Provides minisql storage checksum facilities for this project.

package minisql.storage.checksum
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian

/// Generic checksum envelope for sidecar and metadata payloads. The fixed header

const INVALID_ARGUMENT = 9001
/// Defines the unsupported format constant used by the minisql storage checksum module.
const UNSUPPORTED_FORMAT = 9003
/// Defines the corrupt data constant used by the minisql storage checksum module.
const CORRUPT_DATA = 9004
/// Defines the algorithm none constant used by the minisql storage checksum module.
const ALGORITHM_NONE = 0
/// Defines the algorithm crc32 c constant used by the minisql storage checksum module.
const ALGORITHM_CRC32C = 1
/// Defines the envelope header size constant used by the minisql storage checksum module.
const ENVELOPE_HEADER_SIZE = 32
/// Defines the envelope checksum offset constant used by the minisql storage checksum module.
const ENVELOPE_CHECKSUM_OFFSET = 24

/// Defines the envelope record used by this module.
struct Envelope
  /// Magic field of the envelope.
  magic
  /// Version field of the envelope.
  version
  /// Kind field of the envelope.
  kind
  /// Flags field of the envelope.
  flags
  /// Payload field of the envelope.
  payload
  /// Payload checksum field of the envelope.
  payloadChecksum
  /// Header checksum field of the envelope.
  headerChecksum
end struct

/// Performs the fail operation for the minisql storage checksum module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "storage.checksum." + operation + ": " + message)
end function

/// Validates the magic.
/// Inputs: `magic`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param magic magic value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateMagic(magic, operation)
  if typeof(magic) != "bytes" or len(magic) != 8 then
    return fail(INVALID_ARGUMENT, operation, "magic must be exactly 8 bytes")
  end if
  return true
end function

/// Validates the u16.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateU16(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > 65535 then
    return fail(INVALID_ARGUMENT, operation, name + " must fit U16")
  end if
  return true
end function

/// Validates the u32.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateU32(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, operation, name + " must fit U32")
  end if
  return true
end function

/// Performs the bytesEqual operation for the minisql storage checksum module.
/// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then
    return false
  end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

/// Performs the copyExact operation for the minisql storage checksum module.
/// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param destination destination value consumed by this operation.
/// @param destinationOffset destinationOffset value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param sourceOffset sourceOffset value consumed by this operation.
/// @param count Number of items or units to process.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return void end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
end function

/// Computes the requested value.
/// Inputs: `algorithm`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param algorithm algorithm value consumed by this operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
function compute(algorithm, buffer, offset, length)
  crc32c.validateRange(buffer, offset, length, "storage.checksum.compute")
  if algorithm == ALGORITHM_NONE then return 0 end if
  if algorithm == ALGORITHM_CRC32C then return crc32c.computeRange(buffer, offset, length) end if
  return fail(UNSUPPORTED_FORMAT, "compute", "unknown checksum algorithm")
end function

/// Performs the verify operation for the minisql storage checksum module.
/// Inputs: `algorithm`, `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param algorithm algorithm value consumed by this operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
/// @param expected expected value consumed by this operation.
function verify(algorithm, buffer, offset, length, expected)
  validateU32(expected, "verify", "expected")
  return compute(algorithm, buffer, offset, length) == expected
end function

/// Encodes the envelope.
/// Inputs: `magic`, `version`, `kind`, `flags`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param magic magic value consumed by this operation.
/// @param version version value consumed by this operation.
/// @param kind kind value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param payload payload value consumed by this operation.
function encodeEnvelope(magic, version, kind, flags, payload)
  validateMagic(magic, "encodeEnvelope")
  validateU16(version, "encodeEnvelope", "version")
  validateU16(kind, "encodeEnvelope", "kind")
  validateU32(flags, "encodeEnvelope", "flags")
  if typeof(payload) != "bytes" then
    return fail(INVALID_ARGUMENT, "encodeEnvelope", "payload must be bytes")
  end if
  if len(payload) > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, "encodeEnvelope", "payload is too large")
  end if

  output = bytes(ENVELOPE_HEADER_SIZE + len(payload), 0)
  copyExact(output, 0, magic, 0, 8)
  endian.writeU16LE(output, 8, version)
  endian.writeU16LE(output, 10, kind)
  endian.writeU32LE(output, 12, flags)
  endian.writeU32LE(output, 16, len(payload))
  payloadChecksum = crc32c.compute(payload)
  endian.writeU32LE(output, 20, payloadChecksum)
  endian.writeU32LE(output, ENVELOPE_CHECKSUM_OFFSET, 0)
  endian.writeU32LE(output, 28, 0)
  copyExact(output, ENVELOPE_HEADER_SIZE, payload, 0, len(payload))
  headerChecksum = crc32c.computeRange(output, 0, ENVELOPE_HEADER_SIZE)
  endian.writeU32LE(output, ENVELOPE_CHECKSUM_OFFSET, headerChecksum)
  return output
end function

/// Decodes the envelope.
/// Inputs: `source`, `expectedMagic`, `expectedVersion`, `expectedKind`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param source source value consumed by this operation.
/// @param expectedMagic expectedMagic value consumed by this operation.
/// @param expectedVersion expectedVersion value consumed by this operation.
/// @param expectedKind expectedKind value consumed by this operation.
function decodeEnvelope(source, expectedMagic, expectedVersion, expectedKind)
  if typeof(source) != "bytes" or len(source) < ENVELOPE_HEADER_SIZE then
    return fail(CORRUPT_DATA, "decodeEnvelope", "source is shorter than the envelope header")
  end if
  validateMagic(expectedMagic, "decodeEnvelope")
  validateU16(expectedVersion, "decodeEnvelope", "expectedVersion")
  validateU16(expectedKind, "decodeEnvelope", "expectedKind")

  actualMagic = slice(source, 0, 8)
  if not bytesEqual(actualMagic, expectedMagic) then
    return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "magic mismatch")
  end if
  version = endian.readU16LE(source, 8)
  kind = endian.readU16LE(source, 10)
  if version != expectedVersion then
    return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "version mismatch")
  end if
  if kind != expectedKind then
    return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "kind mismatch")
  end if
  flags = endian.readU32LE(source, 12)
  payloadLength = endian.readU32LE(source, 16)
  payloadChecksum = endian.readU32LE(source, 20)
  storedHeaderChecksum = endian.readU32LE(source, ENVELOPE_CHECKSUM_OFFSET)
  if endian.readU32LE(source, 28) != 0 then
    return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "reserved envelope field is non-zero")
  end if
  if payloadLength != len(source) - ENVELOPE_HEADER_SIZE then
    return fail(CORRUPT_DATA, "decodeEnvelope", "payload length mismatch")
  end if

  header = slice(source, 0, ENVELOPE_HEADER_SIZE)
  endian.writeU32LE(header, ENVELOPE_CHECKSUM_OFFSET, 0)
  actualHeaderChecksum = crc32c.compute(header)
  if actualHeaderChecksum != storedHeaderChecksum then
    return fail(CORRUPT_DATA, "decodeEnvelope", "header checksum mismatch")
  end if
  payload = slice(source, ENVELOPE_HEADER_SIZE, payloadLength)
  if crc32c.compute(payload) != payloadChecksum then
    return fail(CORRUPT_DATA, "decodeEnvelope", "payload checksum mismatch")
  end if
  return Envelope(actualMagic, version, kind, flags, payload, payloadChecksum, storedHeaderChecksum)
end function

/// Performs the componentName operation for the minisql storage checksum module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "storage.checksum"
end function

/// Performs the targetMilestone operation for the minisql storage checksum module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M2"
end function

/// Returns whether implemented satisfies the condition required by the minisql storage checksum module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
