//! Exact finite IEEE-754 binary64 codecs for persistent MiniSQL values.

package minisql.common.float_codec
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.math as math

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const TYPE_MISMATCH = 9017
const WIDTH = 8
const FRACTION_UNIT = 4503599627370496

// frexp/ldexp scale by powers of two exactly. They avoid dependence on the
// runtime's tagged/boxed float representation and never render decimal text.
#if TARGET_OS == "windows"
/// Splits a native double into its exact binary significand and exponent.
extern function nativeFrexp(value as double, exponent as bytes) from "msvcrt.dll" symbol "frexp" returns double
/// Scales a native double by an integral power of two.
extern function nativeLdexp(value as double, exponent as i32) from "msvcrt.dll" symbol "ldexp" returns double
/// Copies the sign bit, including the sign of zero.
extern function nativeCopySign(value as double, signValue as double) from "msvcrt.dll" symbol "_copysign" returns double
/// Reports whether the native value is finite without unordered comparisons.
extern function nativeFinite(value as double) from "msvcrt.dll" symbol "_finite" returns i32
#else
/// Splits a native double into its exact binary significand and exponent.
extern function nativeFrexp(value as double, exponent as bytes) from "libm.so.6" symbol "frexp" returns double
/// Scales a native double by an integral power of two.
extern function nativeLdexp(value as double, exponent as i32) from "libm.so.6" symbol "ldexp" returns double
/// Copies the sign bit, including the sign of zero.
extern function nativeCopySign(value as double, signValue as double) from "libm.so.6" symbol "copysign" returns double
/// Reports whether the native value is finite without unordered comparisons.
extern function nativeFinite(value as double) from "libm.so.6" symbol "finite" returns i32
#endif

/// Reports whether an encoded binary64 has a finite exponent, after bounds checks.
/// @param source Input byte buffer.
/// @param offset Start of the eight-byte value.
function isFiniteEncoded(source, offset)
  endian.validateRange(source, offset, WIDTH, "float_codec.isFiniteEncoded")
  high = endian.readU32LE(source, offset + 4)
  return ((high >> 20) & 2047) != 2047
end function

/// Encodes a finite number without changing zero's sign or losing subnormal bits.
/// @param value MiniLang numeric value; integers convert to binary64 by normal numeric semantics.
function encodeFloat64LE(value)
  if typeof(value) != "float" and typeof(value) != "int" then return error(TYPE_MISMATCH, "common.float_codec.encodeFloat64LE: expected number") end if
  if nativeFinite(value) == 0 then return error(TYPE_MISMATCH, "common.float_codec.encodeFloat64LE: non-finite value") end if
  exponentBytes = bytes(4, 0)
  fraction = nativeFrexp(value, exponentBytes)
  if typeof(fraction) != "float" and typeof(fraction) != "int" then return error(TYPE_MISMATCH, "common.float_codec.encodeFloat64LE: native float conversion failed") end if
  // SQL storage rejects NaN/infinity above so indexes have a finite order.
  negative = nativeCopySign(1.0, value) < 0
  magnitude = nativeCopySign(fraction, 1.0)
  storedExponent = 0
  mantissa = 0
  if magnitude != 0 then
    exponent = endian.readI32LE(exponentBytes, 0)
    if exponent < -1021 then
      // Subnormal significand is value * 2^1074. Using the frexp fraction
      // avoids creating an unrepresentable intermediate scaling factor.
      mantissa = math.toIntExact(nativeLdexp(magnitude, exponent + 1074))
    else
      storedExponent = exponent + 1022
      mantissa = math.toIntExact(nativeLdexp(magnitude, 53)) - FRACTION_UNIT
    end if
  end if
  low = mantissa & 0xFFFFFFFF
  high = (mantissa >> 32) | (storedExponent << 20)
  if negative then high = high | 0x80000000 end if
  output = bytes(WIDTH, 0)
  endian.writeU32LE(output, 0, low)
  endian.writeU32LE(output, 4, high)
  return output
end function

/// Writes a complete finite binary64 only after value and destination validation.
/// @param destination Output byte buffer.
/// @param offset Start of the eight-byte destination.
/// @param value Numeric value to encode.
function writeFloat64LE(destination, offset, value)
  endian.validateRange(destination, offset, WIDTH, "float_codec.writeFloat64LE")
  encoded = encodeFloat64LE(value)
  copyBytes(destination, offset, encoded, 0, WIDTH)
  return true
end function

/// Decodes finite binary64, preserving negative zero and the full 53-bit significand.
/// @param source Input byte buffer.
/// @param offset Start of the eight-byte value.
function decodeFloat64LE(source, offset)
  endian.validateRange(source, offset, WIDTH, "float_codec.decodeFloat64LE")
  low = endian.readU32LE(source, offset)
  high = endian.readU32LE(source, offset + 4)
  exponent = (high >> 20) & 2047
  if exponent == 2047 then return error(CORRUPT_DATA, "common.float_codec.decodeFloat64LE: non-finite value") end if
  mantissa = (high & 0xFFFFF) * 4294967296 + low
  power = -1074
  if exponent != 0 then
    mantissa = mantissa + FRACTION_UNIT
    power = exponent - 1075
  end if
  value = nativeLdexp(toFloat(mantissa), power)
  if (high & 0x80000000) != 0 then return nativeCopySign(value, -1.0) end if
  return value
end function

/// Returns this module's stable registry name.
function componentName()
  return "common.float_codec"
end function

/// Returns the storage generation that introduced this module.
function targetMilestone()
  return "StorageV2"
end function

/// Reports that the binary64 codec is available.
function isImplemented()
  return true
end function
