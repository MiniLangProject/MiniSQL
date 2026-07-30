package minisql.storage.checksum

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const ALGORITHM_NONE = 0
const ALGORITHM_CRC32C = 1
const ENVELOPE_HEADER_SIZE = 32
const ENVELOPE_CHECKSUM_OFFSET = 24

struct Envelope
  magic
  version
  kind
  flags
  payload
  payloadChecksum
  headerChecksum
end struct

function fail(code, operation, message)
  return error(code, "storage.checksum." + operation + ": " + message)
end function

function validateMagic(magic, operation)
  if typeof(magic) != "bytes" or len(magic) != 8 then
    return fail(INVALID_ARGUMENT, operation, "magic must be exactly 8 bytes")
  end if
  return true
end function

function validateU16(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > 65535 then
    return fail(INVALID_ARGUMENT, operation, name + " must fit U16")
  end if
  return true
end function

function validateU32(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, operation, name + " must fit U32")
  end if
  return true
end function

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

function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return void end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
end function

function compute(algorithm, buffer, offset, length)
  crc32c.validateRange(buffer, offset, length, "storage.checksum.compute")
  if algorithm == ALGORITHM_NONE then return 0 end if
  if algorithm == ALGORITHM_CRC32C then return crc32c.computeRange(buffer, offset, length) end if
  return fail(UNSUPPORTED_FORMAT, "compute", "unknown checksum algorithm")
end function

function verify(algorithm, buffer, offset, length, expected)
  validateU32(expected, "verify", "expected")
  return compute(algorithm, buffer, offset, length) == expected
end function

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

function componentName()
  return "storage.checksum"
end function

function targetMilestone()
  return "M2"
end function

function isImplemented()
  return true
end function
