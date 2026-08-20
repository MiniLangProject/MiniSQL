package minisql.sql.values

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.sql.ast as ast
import minisql.sql.types as types
import minisql.storage.row_codec as row_codec

const INVALID_ARGUMENT = 9001
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020
const CONSTRAINT_VIOLATION = 9021
const U32_BASE = 4294967296

// Groups the SQL value state and preserves the field relationships documented below.
struct SqlValue
  // Stores the type kind associated with this value.
  typeKind
  // Indicates whether the is null condition is active.
  isNull
  // Stores the value associated with this value.
  value
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "sql.values." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the SQL value condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSqlValue(value)
  return value is SqlValue
end function

// Implements null value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nullValue(typeKind)
  if typeof(typeKind) != "int" then return fail(INVALID_ARGUMENT, "nullValue", "typeKind must be int") end if
  return SqlValue(typeKind, true, void)
end function

// Implements of for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function of(typeKind, value)
  if typeof(typeKind) != "int" then return fail(INVALID_ARGUMENT, "of", "typeKind must be int") end if
  if value is void then return fail(INVALID_ARGUMENT, "of", "MiniLang void is not SQL NULL") end if
  return SqlValue(typeKind, false, value)
end function

// Implements boolean for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function boolean(value)
  if typeof(value) != "bool" then return fail(TYPE_MISMATCH, "boolean", "value must be bool") end if
  return of(types.SqlTypeKind.Boolean, value)
end function

// Implements integer for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function integer(value)
  if typeof(value) != "int" then return fail(TYPE_MISMATCH, "integer", "value must be int") end if
  return of(types.SqlTypeKind.Integer, value)
end function

// Implements double value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function doubleValue(value)
  if typeof(value) != "int" and typeof(value) != "float" then return fail(TYPE_MISMATCH, "doubleValue", "value must be numeric") end if
  return of(types.SqlTypeKind.Double, value)
end function

// Implements text for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function text(value)
  if typeof(value) != "string" then return fail(TYPE_MISMATCH, "text", "value must be string") end if
  return of(types.SqlTypeKind.Text, value)
end function

// Implements binary for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function binary(value)
  if typeof(value) != "bytes" then return fail(TYPE_MISMATCH, "binary", "value must be bytes") end if
  return of(types.SqlTypeKind.Blob, bytes(value))
end function

// Returns whether the supplied value satisfies the null condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isNull(value)
  return value is SqlValue and value.isNull
end function

// Implements unsigned magnitude to signed for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function unsignedMagnitudeToSigned(high, low, negative)
  if not negative then return endian.makeInt64(high, low) end if
  invertedLow = endian.MAX_U32 - low
  invertedHigh = endian.MAX_U32 - high
  invertedLow = invertedLow + 1
  if invertedLow >= U32_BASE then
    invertedLow = invertedLow - U32_BASE
    invertedHigh = invertedHigh + 1
    if invertedHigh >= U32_BASE then invertedHigh = invertedHigh - U32_BASE end if
  end if
  return endian.makeInt64(invertedHigh, invertedLow)
end function

// Parses int64 using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function parseInt64(textValue)
  if typeof(textValue) != "string" or len(textValue) == 0 then return fail(BINDING_ERROR, "parseInt64", "integer literal is empty") end if
  raw = bytes(textValue)
  index = 0
  negative = false
  if raw[0] == 43 or raw[0] == 45 then
    negative = raw[0] == 45
    index = 1
  end if
  if index >= len(raw) then return fail(BINDING_ERROR, "parseInt64", "integer literal has no digits") end if
  high = 0
  low = 0
  while index < len(raw)
    digitByte = raw[index]
    if digitByte < 48 or digitByte > 57 then return fail(BINDING_ERROR, "parseInt64", "integer literal contains non-digit") end if
    product = low * 10 + digitByte - 48
    // U32_BASE is 2^32. Use integer bit operations; MiniLang / is floating
    // division and would turn a non-exact carry into a float.
    carry = product >> 32
    low = product & endian.MAX_U32
    high = high * 10 + carry
    if high > 2147483648 then return fail(BINDING_ERROR, "parseInt64", "integer literal exceeds signed 64-bit range") end if
    if not negative and high == 2147483648 then return fail(BINDING_ERROR, "parseInt64", "positive integer literal exceeds signed 64-bit range") end if
    if negative and high == 2147483648 and low > 0 then return fail(BINDING_ERROR, "parseInt64", "negative integer literal exceeds signed 64-bit range") end if
    index = index + 1
  end while
  return unsignedMagnitudeToSigned(high, low, negative)
end function

// Implements literal integer for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function literalInteger(textValue)
  words = parseInt64(textValue)
  native = try(endian.int64ToInt(words))
  if typeof(native) != "error" and native >= -2147483648 and native <= 2147483647 then return of(types.SqlTypeKind.Integer, native) end if
  return of(types.SqlTypeKind.BigInt, words)
end function

// Implements floating text part for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function floatingTextPart(raw, startOffset, endOffset, operation)
  if typeof(raw) != "bytes" or typeof(startOffset) != "int" or typeof(endOffset) != "int" then
    return fail(INVALID_ARGUMENT, operation, "invalid floating text range")
  end if
  if startOffset < 0 or endOffset < startOffset or endOffset > len(raw) then
    return fail(BINDING_ERROR, operation, "floating text range is outside the source")
  end if
  encoded = slice(raw, startOffset, endOffset - startOffset)
  if encoded is void then return fail(BINDING_ERROR, operation, "floating text range could not be sliced") end if
  decoded = decode(encoded)
  if typeof(decoded) != "string" then return fail(BINDING_ERROR, operation, "floating text range is not valid UTF-8") end if
  return decoded
end function

// MiniLang's native toNumber parser accepts ordinary decimal spellings but does
// not accept scientific notation. SQL approximate-number literals do, so split
// an optional exponent and apply it explicitly. This keeps ordinary spellings on
// the compiler's well-tested conversion path while supporting forms such as
// 1.25e2, 1E-3 and a leading plus sign.
// Implements floating number from text for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function floatingNumberFromText(textValue)
  if typeof(textValue) != "string" or len(textValue) == 0 then
    return fail(BINDING_ERROR, "floatingNumberFromText", "floating literal must be non-empty text")
  end if

  direct = toNumber(textValue)
  if typeof(direct) == "float" or typeof(direct) == "int" then return direct end if

  raw = bytes(textValue)
  startOffset = 0
  endOffset = len(raw)
  while startOffset < endOffset and raw[startOffset] <= 32
    startOffset = startOffset + 1
  end while
  while endOffset > startOffset and raw[endOffset - 1] <= 32
    endOffset = endOffset - 1
  end while
  if startOffset >= endOffset then return fail(BINDING_ERROR, "floatingNumberFromText", "floating literal is empty") end if

  exponentOffset = -1
  scanOffset = startOffset
  while scanOffset < endOffset
    code = raw[scanOffset]
    if code == 69 or code == 101 then
      if exponentOffset >= 0 then return fail(BINDING_ERROR, "floatingNumberFromText", "floating literal has more than one exponent") end if
      exponentOffset = scanOffset
    end if
    scanOffset = scanOffset + 1
  end while

  mantissaEnd = endOffset
  if exponentOffset >= 0 then mantissaEnd = exponentOffset end if
  mantissaStart = startOffset
  if mantissaStart < mantissaEnd and raw[mantissaStart] == 43 then mantissaStart = mantissaStart + 1 end if
  if mantissaStart >= mantissaEnd then return fail(BINDING_ERROR, "floatingNumberFromText", "floating literal has no mantissa") end if

  mantissaText = floatingTextPart(raw, mantissaStart, mantissaEnd, "floatingNumberFromText")
  mantissa = toNumber(mantissaText)
  if typeof(mantissa) != "float" and typeof(mantissa) != "int" then
    return fail(BINDING_ERROR, "floatingNumberFromText", "invalid floating mantissa")
  end if
  if exponentOffset < 0 then return mantissa end if

  exponentIndex = exponentOffset + 1
  exponentNegative = false
  if exponentIndex < endOffset and (raw[exponentIndex] == 43 or raw[exponentIndex] == 45) then
    exponentNegative = raw[exponentIndex] == 45
    exponentIndex = exponentIndex + 1
  end if
  if exponentIndex >= endOffset then return fail(BINDING_ERROR, "floatingNumberFromText", "floating exponent has no digits") end if

  exponentMagnitude = 0
  while exponentIndex < endOffset
    code = raw[exponentIndex]
    if code < 48 or code > 57 then return fail(BINDING_ERROR, "floatingNumberFromText", "invalid floating exponent") end if
    exponentMagnitude = exponentMagnitude * 10 + code - 48
    if (not exponentNegative and exponentMagnitude > 308) or (exponentNegative and exponentMagnitude > 324) then
      return fail(BINDING_ERROR, "floatingNumberFromText", "floating exponent is outside the supported DOUBLE range")
    end if
    exponentIndex = exponentIndex + 1
  end while

  result = mantissa + 0.0
  scaleIndex = 0
  while scaleIndex < exponentMagnitude
    if exponentNegative then
      result = result / 10.0
    else
      result = result * 10.0
    end if
    scaleIndex = scaleIndex + 1
  end while

  // Infinity is equal to itself, but Infinity-Infinity is NaN. MiniLang's NaN
  // comparison is unequal to itself, which gives us a portable finite check.
  finiteProbe = result - result
  if finiteProbe != finiteProbe then return fail(BINDING_ERROR, "floatingNumberFromText", "floating literal exceeds the finite DOUBLE range") end if
  return result
end function

// Implements literal float for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function literalFloat(textValue)
  if typeof(textValue) != "string" then return fail(BINDING_ERROR, "literalFloat", "literal must be string") end if
  value = floatingNumberFromText(textValue)
  return of(types.SqlTypeKind.Double, value)
end function


// Implements decimal power10 for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decimalPower10(exponent)
  if typeof(exponent) != "int" or exponent < 0 or exponent > 18 then return fail(INVALID_ARGUMENT, "decimalPower10", "exponent must be 0..18") end if
  result = 1
  index = 0
  while index < exponent
    result = result * 10
    index = index + 1
  end while
  return result
end function

// Parse a decimal spelling into the exact signed scaled integer used by the
// row format. No binary floating-point arithmetic, rounding or truncation is
// used. Values with more non-zero fractional digits than the declared scale
// are rejected instead of silently changing the user's input.
// Implements decimal words from text for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decimalWordsFromText(textValue, precision, scale)
  if typeof(textValue) != "string" or len(textValue) == 0 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "decimal text must be non-empty") end if
  if typeof(precision) != "int" or typeof(scale) != "int" or precision < 1 or precision > 18 or scale < 0 or scale > precision then
    return fail(INVALID_ARGUMENT, "decimalWordsFromText", "DECIMAL requires 1<=precision<=18 and 0<=scale<=precision")
  end if

  raw = bytes(textValue)
  index = 0
  negative = false
  if raw[0] == 43 or raw[0] == 45 then
    negative = raw[0] == 45
    index = 1
  end if
  if index >= len(raw) then return fail(TYPE_MISMATCH, "decimalWordsFromText", "decimal text has no digits") end if

  digits = []
  fractionalDigits = 0
  seenDot = false
  seenDigit = false
  while index < len(raw) and raw[index] != 69 and raw[index] != 101
    code = raw[index]
    if code >= 48 and code <= 57 then
      digits = digits + [code - 48]
      seenDigit = true
      if seenDot then fractionalDigits = fractionalDigits + 1 end if
    else if code == 46 and not seenDot then
      seenDot = true
    else
      return fail(TYPE_MISMATCH, "decimalWordsFromText", "invalid decimal spelling")
    end if
    index = index + 1
  end while
  if not seenDigit then return fail(TYPE_MISMATCH, "decimalWordsFromText", "decimal text has no digits") end if

  exponent = 0
  if index < len(raw) then
    index = index + 1
    exponentNegative = false
    if index < len(raw) and (raw[index] == 43 or raw[index] == 45) then
      exponentNegative = raw[index] == 45
      index = index + 1
    end if
    if index >= len(raw) then return fail(TYPE_MISMATCH, "decimalWordsFromText", "decimal exponent has no digits") end if
    exponentMagnitude = 0
    while index < len(raw)
      code = raw[index]
      if code < 48 or code > 57 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "invalid decimal exponent") end if
      exponentMagnitude = exponentMagnitude * 10 + code - 48
      if exponentMagnitude > 1000 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "decimal exponent is outside supported range") end if
      index = index + 1
    end while
    exponent = exponentMagnitude
    if exponentNegative then exponent = -exponent end if
  end if

  shift = scale + exponent - fractionalDigits
  retained = len(digits)
  if shift < 0 then
    removeCount = -shift
    if removeCount >= retained then
      for each digit in digits
        if digit != 0 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "value cannot be represented at the declared scale without rounding") end if
      end for
      return endian.int64FromInt(0)
    end if
    firstRemoved = retained - removeCount
    checkIndex = firstRemoved
    while checkIndex < retained
      if digits[checkIndex] != 0 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "value cannot be represented at the declared scale without rounding") end if
      checkIndex = checkIndex + 1
    end while
    retained = firstRemoved
    shift = 0
  end if

  firstNonZero = 0
  while firstNonZero < retained and digits[firstNonZero] == 0
    firstNonZero = firstNonZero + 1
  end while
  if firstNonZero >= retained then return endian.int64FromInt(0) end if

  significantDigits = retained - firstNonZero + shift
  if significantDigits > precision then return fail(TYPE_MISMATCH, "decimalWordsFromText", "DECIMAL precision overflow") end if

  magnitude = 0
  digitIndex = firstNonZero
  while digitIndex < retained
    magnitude = magnitude * 10 + digits[digitIndex]
    digitIndex = digitIndex + 1
  end while
  zeroIndex = 0
  while zeroIndex < shift
    magnitude = magnitude * 10
    zeroIndex = zeroIndex + 1
  end while
  if magnitude > decimalPower10(precision) - 1 then return fail(TYPE_MISMATCH, "decimalWordsFromText", "DECIMAL precision overflow") end if
  if negative then magnitude = -magnitude end if
  return endian.int64FromInt(magnitude)
end function

// Implements decimal literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decimalLiteral(textValue, precision, scale)
  return of(types.SqlTypeKind.Decimal, decimalWordsFromText(textValue, precision, scale))
end function

// Implements decimal words from value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function decimalWordsFromValue(value, target)
  if value is not SqlValue or not types.isSqlType(target) or target.kind != types.SqlTypeKind.Decimal then return fail(INVALID_ARGUMENT, "decimalWordsFromValue", "invalid DECIMAL conversion arguments") end if
  if value.typeKind == types.SqlTypeKind.Decimal then
    words = asInt64(value)
    native = try(endian.int64ToInt(words))
    if typeof(native) == "error" then return fail(TYPE_MISMATCH, "decimalWordsFromValue", "DECIMAL precision overflow") end if
    magnitude = native
    if magnitude < 0 then magnitude = -magnitude end if
    if magnitude > decimalPower10(target.precision) - 1 then return fail(TYPE_MISMATCH, "decimalWordsFromValue", "DECIMAL precision overflow") end if
    return words
  end if
  if types.isIntegralKind(value.typeKind) then
    words = asInt64(value)
    native = try(endian.int64ToInt(words))
    if typeof(native) == "error" then return fail(TYPE_MISMATCH, "decimalWordsFromValue", "integer exceeds DECIMAL precision") end if
    return decimalWordsFromText("" + native, target.precision, target.scale)
  end if
  if value.typeKind == types.SqlTypeKind.Real or value.typeKind == types.SqlTypeKind.Double then
    if typeof(value.value) != "int" and typeof(value.value) != "float" then return fail(TYPE_MISMATCH, "decimalWordsFromValue", "floating DECIMAL source is invalid") end if
    return decimalWordsFromText("" + value.value, target.precision, target.scale)
  end if
  return fail(TYPE_MISMATCH, "decimalWordsFromValue", "DECIMAL target requires a numeric value")
end function

// Implements from literal for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function fromLiteral(expression)
  if not ast.isLiteralExpression(expression) then return fail(INVALID_ARGUMENT, "fromLiteral", "expression must be literal") end if
  if expression.literalKind == ast.LITERAL_NULL then return nullValue(types.SqlTypeKind.Unknown) end if
  if expression.literalKind == ast.LITERAL_BOOLEAN then return boolean(expression.value) end if
  if expression.literalKind == ast.LITERAL_INTEGER then
    if typeof(expression.value) == "int" then return integer(expression.value) end if
    return literalInteger(expression.value)
  end if
  if expression.literalKind == ast.LITERAL_FLOAT then
    if typeof(expression.value) == "float" then return doubleValue(expression.value) end if
    return literalFloat(expression.value)
  end if
  if expression.literalKind == ast.LITERAL_STRING then return text(expression.value) end if
  if expression.literalKind == ast.LITERAL_CURRENT_TIMESTAMP then return fail(BINDING_ERROR, "fromLiteral", "CURRENT_TIMESTAMP requires an execution clock") end if
  return fail(BINDING_ERROR, "fromLiteral", "unknown literal kind")
end function

// Implements int64 compare for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function int64Compare(left, right)
  if not endian.isInt64Words(left) or not endian.isInt64Words(right) then return fail(TYPE_MISMATCH, "int64Compare", "values must be Int64Words") end if
  leftNegative = endian.int64IsNegative(left)
  rightNegative = endian.int64IsNegative(right)
  if leftNegative and not rightNegative then return -1 end if
  if not leftNegative and rightNegative then return 1 end if
  if left.high < right.high then return -1 end if
  if left.high > right.high then return 1 end if
  if left.low < right.low then return -1 end if
  if left.low > right.low then return 1 end if
  return 0
end function

// Implements as int64 for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function asInt64(value)
  if value is not SqlValue or value.isNull then return fail(TYPE_MISMATCH, "asInt64", "value must be non-NULL SqlValue") end if
  if endian.isInt64Words(value.value) then return value.value end if
  if typeof(value.value) == "int" then return endian.int64FromInt(value.value) end if
  return fail(TYPE_MISMATCH, "asInt64", "value is not integral")
end function

// Implements as number for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function asNumber(value)
  if value is not SqlValue or value.isNull then return fail(TYPE_MISMATCH, "asNumber", "value must be non-NULL SqlValue") end if
  if typeof(value.value) == "int" or typeof(value.value) == "float" then return value.value end if
  native = try(endian.int64ToInt(value.value))
  if typeof(native) == "error" then return fail(TYPE_MISMATCH, "asNumber", "full-width BIGINT cannot be converted to MiniLang scalar without loss") end if
  return native
end function

// Compares non null using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function compareNonNull(left, right)
  if left is not SqlValue or right is not SqlValue or left.isNull or right.isNull then return fail(TYPE_MISMATCH, "compareNonNull", "values must be non-NULL") end if
  if types.isNumericKind(left.typeKind) and types.isNumericKind(right.typeKind) then
    if endian.isInt64Words(left.value) or endian.isInt64Words(right.value) then return int64Compare(asInt64(left), asInt64(right)) end if
    if left.value < right.value then return -1 end if
    if left.value > right.value then return 1 end if
    return 0
  end if
  if typeof(left.value) == "string" and typeof(right.value) == "string" then
    leftBytes = bytes(left.value)
    rightBytes = bytes(right.value)
    common = len(leftBytes)
    if len(rightBytes) < common then common = len(rightBytes) end if
    if common > 0 then
      for index = 0 to common - 1
        if leftBytes[index] < rightBytes[index] then return -1 end if
        if leftBytes[index] > rightBytes[index] then return 1 end if
      end for
    end if
    if len(leftBytes) < len(rightBytes) then return -1 end if
    if len(leftBytes) > len(rightBytes) then return 1 end if
    return 0
  end if
  if typeof(left.value) == "bytes" and typeof(right.value) == "bytes" then
    common = len(left.value)
    if len(right.value) < common then common = len(right.value) end if
    if common > 0 then
      for index = 0 to common - 1
        if left.value[index] < right.value[index] then return -1 end if
        if left.value[index] > right.value[index] then return 1 end if
      end for
    end if
    if len(left.value) < len(right.value) then return -1 end if
    if len(left.value) > len(right.value) then return 1 end if
    return 0
  end if
  if typeof(left.value) == "bool" and typeof(right.value) == "bool" then
    if left.value == right.value then return 0 end if
    if left.value then return 1 end if
    return -1
  end if
  return fail(TYPE_MISMATCH, "compareNonNull", "values are not comparable")
end function

// Implements truth for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function truth(value)
  if value is not SqlValue or value.typeKind != types.SqlTypeKind.Boolean then return fail(TYPE_MISMATCH, "truth", "value must be BOOLEAN") end if
  if value.isNull then return -1 end if
  if value.value then return 1 end if
  return 0
end function

// Implements from truth for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function fromTruth(value)
  if value < 0 then return nullValue(types.SqlTypeKind.Boolean) end if
  return boolean(value != 0)
end function

// Implements logical not for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function logicalNot(value)
  truthValue = truth(value)
  if truthValue < 0 then return fromTruth(-1) end if
  if truthValue == 0 then return fromTruth(1) end if
  return fromTruth(0)
end function

// Implements logical and for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function logicalAnd(left, right)
  leftTruth = truth(left)
  rightTruth = truth(right)
  if leftTruth == 0 or rightTruth == 0 then return fromTruth(0) end if
  if leftTruth < 0 or rightTruth < 0 then return fromTruth(-1) end if
  return fromTruth(1)
end function

// Implements logical or for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function logicalOr(left, right)
  leftTruth = truth(left)
  rightTruth = truth(right)
  if leftTruth == 1 or rightTruth == 1 then return fromTruth(1) end if
  if leftTruth < 0 or rightTruth < 0 then return fromTruth(-1) end if
  return fromTruth(0)
end function

// Converts convert using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function convert(value, target)
  if value is not SqlValue or not types.isSqlType(target) then return fail(INVALID_ARGUMENT, "convert", "invalid conversion arguments") end if
  if value.isNull then
    if not target.nullable then return fail(CONSTRAINT_VIOLATION, "convert", "NULL violates NOT NULL") end if
    return nullValue(target.kind)
  end if
  if target.kind == types.SqlTypeKind.Boolean then
    if typeof(value.value) != "bool" then return fail(TYPE_MISMATCH, "convert", "BOOLEAN requires boolean value") end if
    return of(target.kind, value.value)
  end if
  if target.kind == types.SqlTypeKind.SmallInt or target.kind == types.SqlTypeKind.Integer or target.kind == types.SqlTypeKind.Date then
    native = value.value
    if endian.isInt64Words(native) then
      converted = try(endian.int64ToInt(native))
      if typeof(converted) == "error" then return fail(TYPE_MISMATCH, "convert", "integer does not fit target") end if
      native = converted
    end if
    if typeof(native) != "int" then return fail(TYPE_MISMATCH, "convert", "integral target requires integer") end if
    if target.kind == types.SqlTypeKind.SmallInt and (native < -32768 or native > 32767) then return fail(TYPE_MISMATCH, "convert", "SMALLINT overflow") end if
    if (target.kind == types.SqlTypeKind.Integer or target.kind == types.SqlTypeKind.Date) and (native < -2147483648 or native > 2147483647) then return fail(TYPE_MISMATCH, "convert", "INTEGER overflow") end if
    return of(target.kind, native)
  end if
  if target.kind == types.SqlTypeKind.Decimal then
    return of(target.kind, decimalWordsFromValue(value, target))
  end if
  if target.kind == types.SqlTypeKind.BigInt or target.kind == types.SqlTypeKind.Time or target.kind == types.SqlTypeKind.Timestamp then
    words = value.value
    if typeof(words) == "int" then words = endian.int64FromInt(words) end if
    if not endian.isInt64Words(words) then return fail(TYPE_MISMATCH, "convert", "64-bit target requires integral value") end if
    return of(target.kind, words)
  end if
  if target.kind == types.SqlTypeKind.Real or target.kind == types.SqlTypeKind.Double then
    number = asNumber(value)
    return of(target.kind, number + 0.0)
  end if
  if types.isTextKind(target.kind) then
    if typeof(value.value) != "string" then return fail(TYPE_MISMATCH, "convert", "text target requires string") end if
    length = len(bytes(value.value))
    if target.length > 0 and length > target.length then return fail(TYPE_MISMATCH, "convert", "text exceeds declared length") end if
    output = value.value
    if target.kind == types.SqlTypeKind.Char then
      while len(bytes(output)) < target.length
        output = output + " "
      end while
    end if
    return of(target.kind, output)
  end if
  if types.isBinaryKind(target.kind) then
    if typeof(value.value) != "bytes" then return fail(TYPE_MISMATCH, "convert", "binary target requires bytes") end if
    if target.length > 0 and len(value.value) > target.length then return fail(TYPE_MISMATCH, "convert", "binary value exceeds declared length") end if
    if target.kind == types.SqlTypeKind.Binary and len(value.value) != target.length then return fail(TYPE_MISMATCH, "convert", "BINARY requires exact length") end if
    return of(target.kind, bytes(value.value))
  end if
  return fail(TYPE_MISMATCH, "convert", "unsupported conversion")
end function

// Implements upper ascii for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function upperAscii(value)
  if typeof(value) != "string" then return fail(INVALID_ARGUMENT, "upperAscii", "value must be string") end if
  source = bytes(value)
  output = bytes(len(source))
  if len(source) > 0 then
    for index = 0 to len(source) - 1
      code = source[index]
      if code >= 97 and code <= 122 then code = code - 32 end if
      output[index] = code
    end for
  end if
  return decode(output)
end function

// Casts cast using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function cast(value, target)
  // CAST is intentionally broader than assignment conversion. It still rejects
  // lossy overflow and malformed input instead of silently truncating data.
  if value is not SqlValue or not types.isSqlType(target) then return fail(INVALID_ARGUMENT, "cast", "invalid CAST arguments") end if
  if value.isNull then return nullValue(target.kind) end if
  if types.isTextKind(value.typeKind) and types.isNumericKind(target.kind) then
    if target.kind == types.SqlTypeKind.Decimal then return of(target.kind, decimalWordsFromText(value.value, target.precision, target.scale)) end if
    if target.kind == types.SqlTypeKind.Real or target.kind == types.SqlTypeKind.Double then
      parsed = floatingNumberFromText(value.value)
      return convert(of(types.SqlTypeKind.Double, parsed + 0.0), target)
    end if
    parsedInteger = literalInteger(value.value)
    return convert(parsedInteger, target)
  end if
  if types.isTextKind(value.typeKind) and target.kind == types.SqlTypeKind.Boolean then
    normalized = upperAscii(value.value)
    if normalized == "TRUE" or normalized == "1" then return boolean(true) end if
    if normalized == "FALSE" or normalized == "0" then return boolean(false) end if
    return fail(TYPE_MISMATCH, "cast", "text is not TRUE or FALSE")
  end if
  if types.isTextKind(target.kind) then
    textValue = void
    if typeof(value.value) == "string" then textValue = value.value end if
    if typeof(value.value) == "int" or typeof(value.value) == "float" or typeof(value.value) == "bool" then textValue = "" + value.value end if
    if textValue is void then return fail(TYPE_MISMATCH, "cast", "value cannot be rendered as text without loss") end if
    return convert(of(types.SqlTypeKind.Text, textValue), target)
  end if
  if target.kind == types.SqlTypeKind.Boolean and types.isNumericKind(value.typeKind) then
    number = asNumber(value)
    if number == 0 then return boolean(false) end if
    if number == 1 then return boolean(true) end if
    return fail(TYPE_MISMATCH, "cast", "numeric BOOLEAN cast accepts only 0 or 1")
  end if
  return convert(value, target)
end function

// Implements to storage for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function toStorage(value)
  if value is not SqlValue then return fail(INVALID_ARGUMENT, "toStorage", "value must be SqlValue") end if
  if value.isNull then return row_codec.nullValue() end if
  return value.value
end function

// Implements from storage for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function fromStorage(typeKind, raw)
  if row_codec.isNull(raw) then return nullValue(typeKind) end if
  return of(typeKind, raw)
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.values"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M13"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
