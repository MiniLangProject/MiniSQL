package minisql.common.endian
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

// MiniSQL M1 fixed-width integer codecs, revision 1.
//
// MiniLang native values use three tag bits. A MiniLang int therefore carries a
// signed 61-bit payload, not every signed 64-bit value. MiniSQL consequently
// represents the complete U64 and I64 domains as two validated U32 words.
//
// All functions are strict:
// - buffers must be MiniLang bytes values;
// - offsets must be non-negative ints and the complete field must fit;
// - scalar values must fit their declared width and the MiniLang scalar domain;
// - a failed write never changes any byte in the destination buffer.
//
// Write functions return the first offset after the encoded field. Read functions
// return a scalar for widths through 32 bits and a word-pair value for 64 bits.

const INVALID_ARGUMENT = 9001

const WIDTH_U8 = 1
const WIDTH_U16 = 2
const WIDTH_U32 = 4
const WIDTH_U64 = 8

const MIN_I8 = -128
const MAX_I8 = 127
const MAX_U8 = 255

const MIN_I16 = -32768
const MAX_I16 = 32767
const MAX_U16 = 65535

const MIN_I32 = -2147483648
const MAX_I32 = 2147483647
const MAX_U32 = 4294967295
const U32_BASE = 4294967296

// Native MiniLang integer payload limits with three tag bits.
const MIN_MINILANG_INT = -1152921504606846976
const MAX_MINILANG_INT = 1152921504606846975
const MAX_SCALAR_HIGH = 0x0FFFFFFF
const MIN_SCALAR_HIGH = 0xF0000000

const I64_MIN_HIGH = 0x80000000
const I64_MIN_LOW = 0x00000000
const I64_MAX_HIGH = 0x7FFFFFFF
const I64_MAX_LOW = 0xFFFFFFFF

// Defines the uint64 words record used by this module.
struct UInt64Words
  // High field of the uint64 words.
  high
  // Low field of the uint64 words.
  low
end struct

// Defines the int64 words record used by this module.
struct Int64Words
  // High field of the int64 words.
  high
  // Low field of the int64 words.
  low
end struct

// Evaluates whether the supplied input satisfies the uint64 words predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isUInt64Words(value)
  return value is UInt64Words
end function

// Evaluates whether the supplied input satisfies the int64 words predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isInt64Words(value)
  return value is Int64Words
end function

// Creates an invalid-argument error with operation context.
// Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function invalid(operation, message)
  return error(INVALID_ARGUMENT, "common.endian." + operation + ": " + message)
end function

// Validates the range.
// Inputs: `buffer`, `offset`, `width`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateRange(buffer, offset, width, operation)
  if typeof(buffer) != "bytes" then
    return invalid(operation, "buffer must be bytes")
  end if
  if typeof(offset) != "int" then
    return invalid(operation, "offset must be int")
  end if
  if typeof(width) != "int" or width < 0 then
    return invalid(operation, "internal width is invalid")
  end if
  if offset < 0 then
    return invalid(operation, "offset must be non-negative")
  end if

  size = len(buffer)
  if size < width then
    return invalid(operation, "field width exceeds buffer length")
  end if
  if offset > size - width then
    return invalid(operation, "field exceeds buffer bounds")
  end if
  return true
end function

// Validates the int range.
// Inputs: `value`, `minimum`, `maximum`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateIntRange(value, minimum, maximum, operation)
  if typeof(value) != "int" then
    return invalid(operation, "value must be int")
  end if
  if value < minimum or value > maximum then
    return invalid(operation, "value is outside the supported range")
  end if
  return true
end function

// Validates the uint64 words.
// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateUInt64Words(value, operation)
  if value is not UInt64Words then
    return invalid(operation, "value must be UInt64Words")
  end if
  validateIntRange(value.high, 0, MAX_U32, operation)
  validateIntRange(value.low, 0, MAX_U32, operation)
  return true
end function

// Validates the int64 words.
// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateInt64Words(value, operation)
  if value is not Int64Words then
    return invalid(operation, "value must be Int64Words")
  end if
  validateIntRange(value.high, 0, MAX_U32, operation)
  validateIntRange(value.low, 0, MAX_U32, operation)
  return true
end function

// Constructs the uint64.
// Inputs: `high`, `low`. Returns the produced value or propagates a structured error from validation or delegated operations.
function makeUInt64(high, low)
  validateIntRange(high, 0, MAX_U32, "makeUInt64")
  validateIntRange(low, 0, MAX_U32, "makeUInt64")
  return UInt64Words(high, low)
end function

// Constructs the int64.
// Inputs: `high`, `low`. Returns the produced value or propagates a structured error from validation or delegated operations.
function makeInt64(high, low)
  validateIntRange(high, 0, MAX_U32, "makeInt64")
  validateIntRange(low, 0, MAX_U32, "makeInt64")
  return Int64Words(high, low)
end function

// Performs the min int64 operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function minInt64()
  return Int64Words(I64_MIN_HIGH, I64_MIN_LOW)
end function

// Performs the max int64 operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function maxInt64()
  return Int64Words(I64_MAX_HIGH, I64_MAX_LOW)
end function

// Performs the uint64 from int operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function uint64FromInt(value)
  validateIntRange(value, 0, MAX_MINILANG_INT, "uint64FromInt")
  high = value >> 32
  low = value - (high * U32_BASE)
  return UInt64Words(high, low)
end function

// Performs the uint64 to int operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function uint64ToInt(value)
  validateUInt64Words(value, "uint64ToInt")
  if value.high > MAX_SCALAR_HIGH then
    return invalid("uint64ToInt", "value does not fit a non-negative MiniLang int")
  end if
  return value.high * U32_BASE + value.low
end function

// Performs the uint64 equals operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function uint64Equals(left, right)
  validateUInt64Words(left, "uint64Equals")
  validateUInt64Words(right, "uint64Equals")
  return left.high == right.high and left.low == right.low
end function

// Performs the int64 from int operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function int64FromInt(value)
  validateIntRange(value, MIN_MINILANG_INT, MAX_MINILANG_INT, "int64FromInt")

  // Arithmetic right shift produces a signed high word. Subtracting that word
  // from the scalar yields an unsigned low word without leaving the 61-bit domain.
  signedHigh = value >> 32
  low = value - (signedHigh * U32_BASE)
  high = signedHigh
  if high < 0 then
    high = high + U32_BASE
  end if
  return Int64Words(high, low)
end function

// Performs the int64 to int operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function int64ToInt(value)
  validateInt64Words(value, "int64ToInt")

  if value.high <= MAX_SCALAR_HIGH then
    return value.high * U32_BASE + value.low
  end if

  // Signed values at or above F0000000:00000000 are within the native
  // MiniLang interval [-2^60, -1]. More-negative I64 values are not scalar-safe.
  if value.high >= MIN_SCALAR_HIGH then
    signedHigh = value.high - U32_BASE
    return signedHigh * U32_BASE + value.low
  end if

  return invalid("int64ToInt", "value does not fit the MiniLang signed 61-bit domain")
end function

// Performs the int64 equals operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function int64Equals(left, right)
  validateInt64Words(left, "int64Equals")
  validateInt64Words(right, "int64Equals")
  return left.high == right.high and left.low == right.low
end function

// Performs the int64 is negative operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function int64IsNegative(value)
  validateInt64Words(value, "int64IsNegative")
  return value.high >= I64_MIN_HIGH
end function

// Performs the uint64 bits to int64 operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function uint64BitsToInt64(value)
  validateUInt64Words(value, "uint64BitsToInt64")
  return Int64Words(value.high, value.low)
end function

// Performs the int64 bits to uint64 operation for this module.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function int64BitsToUInt64(value)
  validateInt64Words(value, "int64BitsToUInt64")
  return UInt64Words(value.high, value.low)
end function

// Reads the u8.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU8(buffer, offset)
  validateRange(buffer, offset, WIDTH_U8, "readU8")
  return buffer[offset]
end function

// Reads the i8.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI8(buffer, offset)
  value = readU8(buffer, offset)
  if value >= 128 then
    return value - 256
  end if
  return value
end function

// Writes the u8.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU8(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U8, "writeU8")
  validateIntRange(value, 0, MAX_U8, "writeU8")
  buffer[offset] = value
  return offset + WIDTH_U8
end function

// Writes the i8.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI8(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U8, "writeI8")
  validateIntRange(value, MIN_I8, MAX_I8, "writeI8")
  encoded = value
  if encoded < 0 then
    encoded = encoded + 256
  end if
  buffer[offset] = encoded
  return offset + WIDTH_U8
end function

// Reads the u16 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU16LE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U16, "readU16LE")
  return buffer[offset] + (buffer[offset + 1] << 8)
end function

// Reads the u16 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU16BE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U16, "readU16BE")
  return (buffer[offset] << 8) + buffer[offset + 1]
end function

// Reads the i16 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI16LE(buffer, offset)
  value = readU16LE(buffer, offset)
  if value >= 32768 then
    return value - 65536
  end if
  return value
end function

// Reads the i16 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI16BE(buffer, offset)
  value = readU16BE(buffer, offset)
  if value >= 32768 then
    return value - 65536
  end if
  return value
end function

// Writes the u16 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU16LE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U16, "writeU16LE")
  validateIntRange(value, 0, MAX_U16, "writeU16LE")
  buffer[offset] = value & 255
  buffer[offset + 1] = (value >> 8) & 255
  return offset + WIDTH_U16
end function

// Writes the u16 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU16BE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U16, "writeU16BE")
  validateIntRange(value, 0, MAX_U16, "writeU16BE")
  buffer[offset] = (value >> 8) & 255
  buffer[offset + 1] = value & 255
  return offset + WIDTH_U16
end function

// Writes the i16 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI16LE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U16, "writeI16LE")
  validateIntRange(value, MIN_I16, MAX_I16, "writeI16LE")
  encoded = value
  if encoded < 0 then
    encoded = encoded + 65536
  end if
  buffer[offset] = encoded & 255
  buffer[offset + 1] = (encoded >> 8) & 255
  return offset + WIDTH_U16
end function

// Writes the i16 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI16BE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U16, "writeI16BE")
  validateIntRange(value, MIN_I16, MAX_I16, "writeI16BE")
  encoded = value
  if encoded < 0 then
    encoded = encoded + 65536
  end if
  buffer[offset] = (encoded >> 8) & 255
  buffer[offset + 1] = encoded & 255
  return offset + WIDTH_U16
end function

// Reads the u32 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU32LE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U32, "readU32LE")
  return buffer[offset] +
    (buffer[offset + 1] << 8) +
    (buffer[offset + 2] << 16) +
    (buffer[offset + 3] << 24)
end function

// Reads the u32 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU32BE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U32, "readU32BE")
  return (buffer[offset] << 24) +
    (buffer[offset + 1] << 16) +
    (buffer[offset + 2] << 8) +
    buffer[offset + 3]
end function

// Reads the i32 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI32LE(buffer, offset)
  value = readU32LE(buffer, offset)
  if value >= 2147483648 then
    return value - U32_BASE
  end if
  return value
end function

// Reads the i32 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI32BE(buffer, offset)
  value = readU32BE(buffer, offset)
  if value >= 2147483648 then
    return value - U32_BASE
  end if
  return value
end function

// Writes the u32 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU32LE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U32, "writeU32LE")
  validateIntRange(value, 0, MAX_U32, "writeU32LE")
  buffer[offset] = value & 255
  buffer[offset + 1] = (value >> 8) & 255
  buffer[offset + 2] = (value >> 16) & 255
  buffer[offset + 3] = (value >> 24) & 255
  return offset + WIDTH_U32
end function

// Writes the u32 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU32BE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U32, "writeU32BE")
  validateIntRange(value, 0, MAX_U32, "writeU32BE")
  buffer[offset] = (value >> 24) & 255
  buffer[offset + 1] = (value >> 16) & 255
  buffer[offset + 2] = (value >> 8) & 255
  buffer[offset + 3] = value & 255
  return offset + WIDTH_U32
end function

// Writes the i32 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI32LE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U32, "writeI32LE")
  validateIntRange(value, MIN_I32, MAX_I32, "writeI32LE")
  encoded = value
  if encoded < 0 then
    encoded = encoded + U32_BASE
  end if
  buffer[offset] = encoded & 255
  buffer[offset + 1] = (encoded >> 8) & 255
  buffer[offset + 2] = (encoded >> 16) & 255
  buffer[offset + 3] = (encoded >> 24) & 255
  return offset + WIDTH_U32
end function

// Writes the i32 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI32BE(buffer, offset, value)
  validateRange(buffer, offset, WIDTH_U32, "writeI32BE")
  validateIntRange(value, MIN_I32, MAX_I32, "writeI32BE")
  encoded = value
  if encoded < 0 then
    encoded = encoded + U32_BASE
  end if
  buffer[offset] = (encoded >> 24) & 255
  buffer[offset + 1] = (encoded >> 16) & 255
  buffer[offset + 2] = (encoded >> 8) & 255
  buffer[offset + 3] = encoded & 255
  return offset + WIDTH_U32
end function

// Reads the u64 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU64LE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U64, "readU64LE")
  low = readU32LE(buffer, offset)
  high = readU32LE(buffer, offset + 4)
  return UInt64Words(high, low)
end function

// Reads the u64 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readU64BE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U64, "readU64BE")
  high = readU32BE(buffer, offset)
  low = readU32BE(buffer, offset + 4)
  return UInt64Words(high, low)
end function

// Reads the i64 le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI64LE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U64, "readI64LE")
  low = readU32LE(buffer, offset)
  high = readU32LE(buffer, offset + 4)
  return Int64Words(high, low)
end function

// Reads the i64 be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI64BE(buffer, offset)
  validateRange(buffer, offset, WIDTH_U64, "readI64BE")
  high = readU32BE(buffer, offset)
  low = readU32BE(buffer, offset + 4)
  return Int64Words(high, low)
end function

// Reads the i64 as int le.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI64AsIntLE(buffer, offset)
  return int64ToInt(readI64LE(buffer, offset))
end function

// Reads the i64 as int be.
// Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readI64AsIntBE(buffer, offset)
  return int64ToInt(readI64BE(buffer, offset))
end function

// Writes the u64 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU64LE(buffer, offset, value)
  // Validate the complete operation before the first byte is modified.
  validateRange(buffer, offset, WIDTH_U64, "writeU64LE")
  validateUInt64Words(value, "writeU64LE")
  writeU32LE(buffer, offset, value.low)
  writeU32LE(buffer, offset + 4, value.high)
  return offset + WIDTH_U64
end function

// Writes the u64 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeU64BE(buffer, offset, value)
  // Validate the complete operation before the first byte is modified.
  validateRange(buffer, offset, WIDTH_U64, "writeU64BE")
  validateUInt64Words(value, "writeU64BE")
  writeU32BE(buffer, offset, value.high)
  writeU32BE(buffer, offset + 4, value.low)
  return offset + WIDTH_U64
end function

// Writes the i64 le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI64LE(buffer, offset, value)
  // I64 takes Int64Words so all 64 signed bit patterns remain lossless.
  validateRange(buffer, offset, WIDTH_U64, "writeI64LE")
  validateInt64Words(value, "writeI64LE")
  writeU32LE(buffer, offset, value.low)
  writeU32LE(buffer, offset + 4, value.high)
  return offset + WIDTH_U64
end function

// Writes the i64 be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI64BE(buffer, offset, value)
  // I64 takes Int64Words so all 64 signed bit patterns remain lossless.
  validateRange(buffer, offset, WIDTH_U64, "writeI64BE")
  validateInt64Words(value, "writeI64BE")
  writeU32BE(buffer, offset, value.high)
  writeU32BE(buffer, offset + 4, value.low)
  return offset + WIDTH_U64
end function

// Writes the i64 from int le.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI64FromIntLE(buffer, offset, value)
  // Conversion is completed before writeI64LE can mutate the destination.
  validateRange(buffer, offset, WIDTH_U64, "writeI64FromIntLE")
  words = int64FromInt(value)
  return writeI64LE(buffer, offset, words)
end function

// Writes the i64 from int be.
// Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeI64FromIntBE(buffer, offset, value)
  // Conversion is completed before writeI64BE can mutate the destination.
  validateRange(buffer, offset, WIDTH_U64, "writeI64FromIntBE")
  words = int64FromInt(value)
  return writeI64BE(buffer, offset, words)
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.endian"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M1"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
