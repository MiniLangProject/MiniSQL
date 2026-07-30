package minisql.common.varint

import minisql.common.endian as endian

// Canonical unsigned LEB128 plus ZigZag signed codecs.
// Full 64-bit domains use the M1 UInt64Words/Int64Words representation.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const MAX_U32_BYTES = 5
const MAX_U64_BYTES = 10

struct Varint32Result
  value
  nextOffset
  bytesRead
end struct

struct Varint64Result
  value
  nextOffset
  bytesRead
end struct

function invalid(operation, message)
  return error(INVALID_ARGUMENT, "common.varint." + operation + ": " + message)
end function

function corrupt(operation, message)
  return error(CORRUPT_DATA, "common.varint." + operation + ": " + message)
end function

function validateBufferOffset(buffer, offset, operation)
  if typeof(buffer) != "bytes" then
    return invalid(operation, "buffer must be bytes")
  end if
  if typeof(offset) != "int" or offset < 0 then
    return invalid(operation, "offset must be a non-negative int")
  end if
  if offset > len(buffer) then
    return invalid(operation, "offset exceeds buffer length")
  end if
  return true
end function

function validateWriteRange(buffer, offset, width, operation)
  validateBufferOffset(buffer, offset, operation)
  if typeof(width) != "int" or width < 0 then
    return invalid(operation, "width must be a non-negative int")
  end if
  if width > len(buffer) - offset then
    return invalid(operation, "encoded value exceeds buffer bounds")
  end if
  return true
end function

function encodedLengthU32(value)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_U32 then
    return invalid("encodedLengthU32", "value must be in 0..4294967295")
  end if
  length = 1
  remaining = value
  while remaining >= 128
    remaining = remaining >> 7
    length = length + 1
  end while
  return length
end function

function encodedLengthU64(value)
  endian.validateUInt64Words(value, "varint.encodedLengthU64")
  high = value.high
  low = value.low
  length = 1
  while high != 0 or low >= 128
    low = (low >> 7) | ((high & 0x7F) << 25)
    high = high >> 7
    length = length + 1
  end while
  return length
end function

function writeU32(buffer, offset, value)
  width = encodedLengthU32(value)
  validateWriteRange(buffer, offset, width, "writeU32")
  remaining = value
  cursor = offset
  while remaining >= 128
    buffer[cursor] = (remaining & 0x7F) | 0x80
    remaining = remaining >> 7
    cursor = cursor + 1
  end while
  buffer[cursor] = remaining
  return cursor + 1
end function

function readU32(buffer, offset)
  validateBufferOffset(buffer, offset, "readU32")
  result = 0
  shift = 0
  cursor = offset
  for index = 0 to MAX_U32_BYTES - 1
    if cursor >= len(buffer) then
      return corrupt("readU32", "truncated varint")
    end if
    byteValue = buffer[cursor]
    payload = byteValue & 0x7F
    if index == 4 and payload > 15 then
      return corrupt("readU32", "value exceeds U32")
    end if
    result = result | (payload << shift)
    cursor = cursor + 1
    if (byteValue & 0x80) == 0 then
      if index > 0 and payload == 0 then
        return corrupt("readU32", "non-canonical encoding")
      end if
      return Varint32Result(result, cursor, cursor - offset)
    end if
    shift = shift + 7
  end for
  return corrupt("readU32", "unterminated or oversized varint")
end function

function writeU64(buffer, offset, value)
  width = encodedLengthU64(value)
  validateWriteRange(buffer, offset, width, "writeU64")
  high = value.high
  low = value.low
  cursor = offset
  while high != 0 or low >= 128
    buffer[cursor] = (low & 0x7F) | 0x80
    low = (low >> 7) | ((high & 0x7F) << 25)
    high = high >> 7
    cursor = cursor + 1
  end while
  buffer[cursor] = low
  return cursor + 1
end function

function readU64(buffer, offset)
  validateBufferOffset(buffer, offset, "readU64")
  high = 0
  low = 0
  shift = 0
  cursor = offset
  for index = 0 to MAX_U64_BYTES - 1
    if cursor >= len(buffer) then
      return corrupt("readU64", "truncated varint")
    end if
    byteValue = buffer[cursor]
    payload = byteValue & 0x7F
    if index == 9 and payload > 1 then
      return corrupt("readU64", "value exceeds U64")
    end if

    if shift < 32 then
      low = low | ((payload << shift) & endian.MAX_U32)
      if shift > 25 then
        high = high | (payload >> (32 - shift))
      end if
    else
      high = high | ((payload << (shift - 32)) & endian.MAX_U32)
    end if

    cursor = cursor + 1
    if (byteValue & 0x80) == 0 then
      if index > 0 and payload == 0 then
        return corrupt("readU64", "non-canonical encoding")
      end if
      return Varint64Result(endian.makeUInt64(high, low), cursor, cursor - offset)
    end if
    shift = shift + 7
  end for
  return corrupt("readU64", "unterminated or oversized varint")
end function

function zigZagEncodeI32(value)
  if typeof(value) != "int" or value < endian.MIN_I32 or value > endian.MAX_I32 then
    return invalid("zigZagEncodeI32", "value must fit I32")
  end if
  if value >= 0 then
    return value << 1
  end if
  return ((-value) << 1) - 1
end function

function zigZagDecodeI32(value)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_U32 then
    return invalid("zigZagDecodeI32", "value must fit U32")
  end if
  magnitude = value >> 1
  if (value & 1) == 0 then
    return magnitude
  end if
  return -magnitude - 1
end function

function writeI32(buffer, offset, value)
  return writeU32(buffer, offset, zigZagEncodeI32(value))
end function

function readI32(buffer, offset)
  decoded = readU32(buffer, offset)
  return Varint32Result(zigZagDecodeI32(decoded.value), decoded.nextOffset, decoded.bytesRead)
end function

function zigZagEncodeI64(value)
  endian.validateInt64Words(value, "varint.zigZagEncodeI64")
  signMask = 0
  if value.high >= 0x80000000 then
    signMask = endian.MAX_U32
  end if
  shiftedHigh = ((value.high << 1) & endian.MAX_U32) | (value.low >> 31)
  shiftedLow = (value.low << 1) & endian.MAX_U32
  return endian.makeUInt64(shiftedHigh ^ signMask, shiftedLow ^ signMask)
end function

function zigZagDecodeI64(value)
  endian.validateUInt64Words(value, "varint.zigZagDecodeI64")
  signMask = 0
  if (value.low & 1) != 0 then
    signMask = endian.MAX_U32
  end if
  shiftedHigh = value.high >> 1
  shiftedLow = (value.low >> 1) | ((value.high & 1) << 31)
  return endian.makeInt64(shiftedHigh ^ signMask, shiftedLow ^ signMask)
end function

function writeI64(buffer, offset, value)
  return writeU64(buffer, offset, zigZagEncodeI64(value))
end function

function readI64(buffer, offset)
  decoded = readU64(buffer, offset)
  return Varint64Result(zigZagDecodeI64(decoded.value), decoded.nextOffset, decoded.bytesRead)
end function

function componentName()
  return "common.varint"
end function

function targetMilestone()
  return "M2"
end function

function isImplemented()
  return true
end function
