package minisql.storage.row_codec

import minisql.common.endian as endian

// Row format v1. SQL NULL is represented by SqlNull rather than MiniLang void,
// so absence in the host language cannot be confused with a stored SQL value.
// Full SQL BIGINT/DECIMAL/TIME/TIMESTAMP ranges use Int64Words.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const TYPE_MISMATCH = 9017

const FORMAT_VERSION = 1
const HEADER_SIZE = 16
const DIRECTORY_ENTRY_SIZE = 8

const TYPE_BOOLEAN = 1
const TYPE_SMALLINT = 2
const TYPE_INTEGER = 3
const TYPE_BIGINT = 4
const TYPE_REAL = 5
const TYPE_DOUBLE = 6
const TYPE_DECIMAL = 7
const TYPE_CHAR = 8
const TYPE_VARCHAR = 9
const TYPE_TEXT = 10
const TYPE_BINARY = 11
const TYPE_VARBINARY = 12
const TYPE_BLOB = 13
const TYPE_DATE = 14
const TYPE_TIME = 15
const TYPE_TIMESTAMP = 16

const FLAG_NULL = 1
const FLAG_EXTERNAL = 2

struct SqlNull
  marker
end struct

struct ColumnSpec
  typeCode
  nullable
  maxLength
  precision
  scale
end struct

struct RowSchema
  version
  columns
end struct

struct RowData
  schemaVersion
  values
end struct

struct ExternalValue
  encodedPointer
end struct

function isExternalValue(value)
  return value is ExternalValue
end function

function fail(code, operation, message)
  return error(code, "storage.row_codec." + operation + ": " + message)
end function

function magicBytes()
  return bytes("MSRW")
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function nullValue()
  return SqlNull(1)
end function

function isNull(value)
  return value is SqlNull
end function

function validType(typeCode)
  return typeof(typeCode) == "int" and typeCode >= TYPE_BOOLEAN and typeCode <= TYPE_TIMESTAMP
end function

function isTextType(typeCode)
  return typeCode == TYPE_CHAR or typeCode == TYPE_VARCHAR or typeCode == TYPE_TEXT
end function

function isBinaryType(typeCode)
  return typeCode == TYPE_BINARY or typeCode == TYPE_VARBINARY or typeCode == TYPE_BLOB
end function

function isExternalType(typeCode)
  return typeCode == TYPE_TEXT or typeCode == TYPE_BLOB
end function

function column(typeCode, nullable, maxLength, precision, scale)
  if not validType(typeCode) then return fail(INVALID_ARGUMENT, "column", "unknown type code") end if
  if typeof(nullable) != "bool" then return fail(INVALID_ARGUMENT, "column", "nullable must be bool") end if
  if typeof(maxLength) != "int" or maxLength < 0 or maxLength > 65535 then return fail(INVALID_ARGUMENT, "column", "maxLength must fit U16") end if
  if typeof(precision) != "int" or precision < 0 or precision > 65535 or typeof(scale) != "int" or scale < 0 or scale > 65535 then return fail(INVALID_ARGUMENT, "column", "precision and scale must fit U16") end if
  if typeCode == TYPE_DECIMAL and (precision < 1 or precision > 18 or scale > precision) then return fail(INVALID_ARGUMENT, "column", "DECIMAL requires 1<=precision<=18 and scale<=precision") end if
  if (typeCode == TYPE_CHAR or typeCode == TYPE_VARCHAR or typeCode == TYPE_BINARY or typeCode == TYPE_VARBINARY) and maxLength <= 0 then return fail(INVALID_ARGUMENT, "column", "fixed/bounded string type requires maxLength") end if
  return ColumnSpec(typeCode, nullable, maxLength, precision, scale)
end function

function schema(version, columns)
  if typeof(version) != "int" or version <= 0 or version > 65535 then return fail(INVALID_ARGUMENT, "schema", "version must fit positive U16") end if
  if typeof(columns) != "array" or len(columns) == 0 or len(columns) > 4095 then return fail(INVALID_ARGUMENT, "schema", "columns must contain 1..4095 entries") end if
  for each spec in columns
    if spec is not ColumnSpec then return fail(INVALID_ARGUMENT, "schema", "columns contain invalid specification") end if
  end for
  return RowSchema(version, columns)
end function

function encodeText(spec, value)
  if typeof(value) != "string" then return fail(TYPE_MISMATCH, "encodeText", "text type requires string") end if
  encoded = bytes(value)
  if spec.typeCode == TYPE_CHAR then
    if len(encoded) > spec.maxLength then return fail(TYPE_MISMATCH, "encodeText", "CHAR value exceeds declared length") end if
    padded = bytes(spec.maxLength, 32)
    if len(encoded) > 0 then copyBytes(padded, 0, encoded, 0, len(encoded)) end if
    return padded
  end if
  if spec.maxLength > 0 and len(encoded) > spec.maxLength then return fail(TYPE_MISMATCH, "encodeText", "text exceeds declared maximum") end if
  return encoded
end function

function encodeBinary(spec, value)
  if typeof(value) != "bytes" then return fail(TYPE_MISMATCH, "encodeBinary", "binary type requires bytes") end if
  if spec.typeCode == TYPE_BINARY and len(value) != spec.maxLength then return fail(TYPE_MISMATCH, "encodeBinary", "BINARY requires exactly maxLength bytes") end if
  if spec.maxLength > 0 and len(value) > spec.maxLength then return fail(TYPE_MISMATCH, "encodeBinary", "binary value exceeds declared maximum") end if
  return bytes(value)
end function

function encodeScalar(spec, value)
  if spec.typeCode == TYPE_BOOLEAN then
    if typeof(value) != "bool" then return fail(TYPE_MISMATCH, "encodeScalar", "BOOLEAN requires bool") end if
    result = bytes(1, 0)
    if value then result[0] = 1 end if
    return result
  end if
  if spec.typeCode == TYPE_SMALLINT then
    if typeof(value) != "int" then return fail(TYPE_MISMATCH, "encodeScalar", "SMALLINT requires int") end if
    result = bytes(2, 0)
    endian.writeI16LE(result, 0, value)
    return result
  end if
  if spec.typeCode == TYPE_INTEGER or spec.typeCode == TYPE_DATE then
    if typeof(value) != "int" then return fail(TYPE_MISMATCH, "encodeScalar", "INTEGER/DATE requires int") end if
    result = bytes(4, 0)
    endian.writeI32LE(result, 0, value)
    return result
  end if
  if spec.typeCode == TYPE_BIGINT or spec.typeCode == TYPE_DECIMAL or spec.typeCode == TYPE_TIME or spec.typeCode == TYPE_TIMESTAMP then
    if not endian.isInt64Words(value) then return fail(TYPE_MISMATCH, "encodeScalar", "64-bit SQL value requires Int64Words") end if
    result = bytes(8, 0)
    endian.writeI64LE(result, 0, value)
    return result
  end if
  if spec.typeCode == TYPE_REAL or spec.typeCode == TYPE_DOUBLE then
    if typeof(value) != "float" and typeof(value) != "int" then return fail(TYPE_MISMATCH, "encodeScalar", "floating type requires number") end if
    // MiniLang currently has no stable float-bit cast. Format v1 therefore uses
    // a canonical UTF-8 numeric rendering and validates it on decode.
    return bytes("" + value)
  end if
  if isTextType(spec.typeCode) then return encodeText(spec, value) end if
  if isBinaryType(spec.typeCode) then return encodeBinary(spec, value) end if
  return fail(UNSUPPORTED_FORMAT, "encodeScalar", "unsupported type code")
end function

function decodeText(spec, encoded)
  if spec.typeCode == TYPE_CHAR and len(encoded) != spec.maxLength then return fail(CORRUPT_DATA, "decodeText", "CHAR length mismatch") end if
  if spec.maxLength > 0 and len(encoded) > spec.maxLength then return fail(CORRUPT_DATA, "decodeText", "text exceeds declared maximum") end if
  value = decode(encoded)
  if typeof(value) != "string" then return fail(CORRUPT_DATA, "decodeText", "text is not valid UTF-8") end if
  return value
end function

function decodeBinary(spec, encoded)
  if spec.typeCode == TYPE_BINARY and len(encoded) != spec.maxLength then return fail(CORRUPT_DATA, "decodeBinary", "BINARY length mismatch") end if
  if spec.maxLength > 0 and len(encoded) > spec.maxLength then return fail(CORRUPT_DATA, "decodeBinary", "binary value exceeds declared maximum") end if
  return bytes(encoded)
end function

function decodeScalar(spec, encoded)
  if spec.typeCode == TYPE_BOOLEAN then
    if len(encoded) != 1 or (encoded[0] != 0 and encoded[0] != 1) then return fail(CORRUPT_DATA, "decodeScalar", "invalid BOOLEAN") end if
    return encoded[0] == 1
  end if
  if spec.typeCode == TYPE_SMALLINT then
    if len(encoded) != 2 then return fail(CORRUPT_DATA, "decodeScalar", "invalid SMALLINT length") end if
    return endian.readI16LE(encoded, 0)
  end if
  if spec.typeCode == TYPE_INTEGER or spec.typeCode == TYPE_DATE then
    if len(encoded) != 4 then return fail(CORRUPT_DATA, "decodeScalar", "invalid INTEGER/DATE length") end if
    return endian.readI32LE(encoded, 0)
  end if
  if spec.typeCode == TYPE_BIGINT or spec.typeCode == TYPE_DECIMAL or spec.typeCode == TYPE_TIME or spec.typeCode == TYPE_TIMESTAMP then
    if len(encoded) != 8 then return fail(CORRUPT_DATA, "decodeScalar", "invalid 64-bit value length") end if
    return endian.readI64LE(encoded, 0)
  end if
  if spec.typeCode == TYPE_REAL or spec.typeCode == TYPE_DOUBLE then
    text = decode(encoded)
    if typeof(text) != "string" then return fail(CORRUPT_DATA, "decodeScalar", "floating rendering is not UTF-8") end if
    value = toNumber(text)
    if typeof(value) != "float" and typeof(value) != "int" then return fail(CORRUPT_DATA, "decodeScalar", "invalid floating rendering") end if
    return value
  end if
  if isTextType(spec.typeCode) then return decodeText(spec, encoded) end if
  if isBinaryType(spec.typeCode) then return decodeBinary(spec, encoded) end if
  return fail(UNSUPPORTED_FORMAT, "decodeScalar", "unsupported type code")
end function

function encode(rowSchema, values)
  if rowSchema is not RowSchema then return fail(INVALID_ARGUMENT, "encode", "rowSchema must be RowSchema") end if
  if typeof(values) != "array" or len(values) != len(rowSchema.columns) then return fail(INVALID_ARGUMENT, "encode", "value count does not match schema") end if
  count = len(values)
  nullBytes = (count + 7) >> 3
  directoryOffset = HEADER_SIZE + nullBytes
  dataOffset = directoryOffset + count * DIRECTORY_ENTRY_SIZE
  encodedValues = []
  flags = []
  total = dataOffset

  for index = 0 to count - 1
    spec = rowSchema.columns[index]
    value = values[index]
    if isNull(value) then
      if not spec.nullable then return fail(TYPE_MISMATCH, "encode", "NULL in NOT NULL column " + index) end if
      encodedValues = encodedValues + [bytes()]
      flags = flags + [FLAG_NULL]
    else if value is ExternalValue then
      if not isExternalType(spec.typeCode) then return fail(TYPE_MISMATCH, "encode", "external value only allowed for TEXT/BLOB") end if
      if typeof(value.encodedPointer) != "bytes" or len(value.encodedPointer) == 0 then return fail(TYPE_MISMATCH, "encode", "external pointer must be non-empty bytes") end if
      encodedValues = encodedValues + [bytes(value.encodedPointer)]
      flags = flags + [FLAG_EXTERNAL]
      total = total + len(value.encodedPointer)
    else
      if value is void then return fail(TYPE_MISMATCH, "encode", "MiniLang void is not SQL NULL; use nullValue()") end if
      encoded = encodeScalar(spec, value)
      encodedValues = encodedValues + [encoded]
      flags = flags + [0]
      total = total + len(encoded)
    end if
  end for
  if total > 65535 then return fail(INVALID_ARGUMENT, "encode", "encoded row exceeds 65535 bytes") end if

  output = bytes(total, 0)
  copyBytes(output, 0, magicBytes(), 0, 4)
  endian.writeU16LE(output, 4, FORMAT_VERSION)
  endian.writeU16LE(output, 6, rowSchema.version)
  endian.writeU16LE(output, 8, count)
  endian.writeU16LE(output, 10, nullBytes)
  endian.writeU16LE(output, 12, directoryOffset)
  endian.writeU16LE(output, 14, 0)
  cursor = dataOffset
  for index = 0 to count - 1
    entryOffset = directoryOffset + index * DIRECTORY_ENTRY_SIZE
    endian.writeU16LE(output, entryOffset, rowSchema.columns[index].typeCode)
    endian.writeU16LE(output, entryOffset + 2, flags[index])
    endian.writeU16LE(output, entryOffset + 4, cursor)
    endian.writeU16LE(output, entryOffset + 6, len(encodedValues[index]))
    if (flags[index] & FLAG_NULL) != 0 then
      bitmapByte = HEADER_SIZE + (index >> 3)
      output[bitmapByte] = output[bitmapByte] | (1 << (index % 8))
    else
      if len(encodedValues[index]) > 0 then copyBytes(output, cursor, encodedValues[index], 0, len(encodedValues[index])) end if
      cursor = cursor + len(encodedValues[index])
    end if
  end for
  return output
end function

function encodeRow(rowSchema, values)
  return encode(rowSchema, values)
end function

function decodeRow(rowSchema, encoded)
  if rowSchema is not RowSchema then return fail(INVALID_ARGUMENT, "decodeRow", "rowSchema must be RowSchema") end if
  if typeof(encoded) != "bytes" or len(encoded) < HEADER_SIZE then return fail(CORRUPT_DATA, "decodeRow", "row is shorter than header") end if
  if not bytesEqual(slice(encoded, 0, 4), magicBytes()) then return fail(UNSUPPORTED_FORMAT, "decodeRow", "row magic mismatch") end if
  if endian.readU16LE(encoded, 4) != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decodeRow", "row format mismatch") end if
  schemaVersion = endian.readU16LE(encoded, 6)
  count = endian.readU16LE(encoded, 8)
  nullBytes = endian.readU16LE(encoded, 10)
  directoryOffset = endian.readU16LE(encoded, 12)
  if endian.readU16LE(encoded, 14) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeRow", "reserved row field is non-zero") end if
  if schemaVersion != rowSchema.version then return fail(UNSUPPORTED_FORMAT, "decodeRow", "schema version does not match decoder") end if
  if count != len(rowSchema.columns) or nullBytes != ((count + 7) >> 3) or directoryOffset != HEADER_SIZE + nullBytes then return fail(CORRUPT_DATA, "decodeRow", "row shape does not match schema") end if
  dataStart = directoryOffset + count * DIRECTORY_ENTRY_SIZE
  if dataStart > len(encoded) then return fail(CORRUPT_DATA, "decodeRow", "directory exceeds row") end if

  // Bits beyond the final column are reserved and must stay zero.
  if count % 8 != 0 then
    lastMask = 0
    for bit = count % 8 to 7
      lastMask = lastMask | (1 << bit)
    end for
    if (encoded[HEADER_SIZE + nullBytes - 1] & lastMask) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeRow", "reserved NULL-bitmap bits are non-zero") end if
  end if

  values = []
  cursor = dataStart
  for index = 0 to count - 1
    spec = rowSchema.columns[index]
    entryOffset = directoryOffset + index * DIRECTORY_ENTRY_SIZE
    typeCode = endian.readU16LE(encoded, entryOffset)
    entryFlags = endian.readU16LE(encoded, entryOffset + 2)
    valueOffset = endian.readU16LE(encoded, entryOffset + 4)
    valueLength = endian.readU16LE(encoded, entryOffset + 6)
    if typeCode != spec.typeCode or (entryFlags != 0 and entryFlags != FLAG_NULL and entryFlags != FLAG_EXTERNAL) then return fail(CORRUPT_DATA, "decodeRow", "invalid directory entry") end if
    bitmapNull = (encoded[HEADER_SIZE + (index >> 3)] & (1 << (index % 8))) != 0
    if ((entryFlags & FLAG_NULL) != 0) != bitmapNull then return fail(CORRUPT_DATA, "decodeRow", "NULL bitmap disagrees with directory") end if
    if valueOffset != cursor then return fail(CORRUPT_DATA, "decodeRow", "non-canonical value offset") end if

    if bitmapNull then
      if valueLength != 0 or not spec.nullable then return fail(CORRUPT_DATA, "decodeRow", "invalid NULL value") end if
      values = values + [nullValue()]
    else
      if valueOffset < dataStart or valueOffset > len(encoded) or valueLength > len(encoded) - valueOffset then return fail(CORRUPT_DATA, "decodeRow", "value range exceeds row") end if
      valueBytes = slice(encoded, valueOffset, valueLength)
      if (entryFlags & FLAG_EXTERNAL) != 0 then
        if not isExternalType(spec.typeCode) or valueLength == 0 then return fail(CORRUPT_DATA, "decodeRow", "invalid external LOB pointer") end if
        values = values + [ExternalValue(valueBytes)]
      else
        values = values + [decodeScalar(spec, valueBytes)]
      end if
      cursor = cursor + valueLength
    end if
  end for
  if cursor != len(encoded) then return fail(CORRUPT_DATA, "decodeRow", "trailing or unreachable row bytes") end if
  return RowData(schemaVersion, values)
end function

function decodeCompatible(rowSchema, encoded)
  if rowSchema is not RowSchema then return fail(INVALID_ARGUMENT, "decodeCompatible", "rowSchema must be RowSchema") end if
  if typeof(encoded) != "bytes" or len(encoded) < HEADER_SIZE then return fail(CORRUPT_DATA, "decodeCompatible", "row is shorter than header") end if
  if not bytesEqual(slice(encoded, 0, 4), magicBytes()) then return fail(UNSUPPORTED_FORMAT, "decodeCompatible", "row magic mismatch") end if
  if endian.readU16LE(encoded, 4) != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decodeCompatible", "row format mismatch") end if
  schemaVersion = endian.readU16LE(encoded, 6)
  count = endian.readU16LE(encoded, 8)
  nullBytes = endian.readU16LE(encoded, 10)
  directoryOffset = endian.readU16LE(encoded, 12)
  if endian.readU16LE(encoded, 14) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeCompatible", "reserved row field is non-zero") end if
  if schemaVersion <= 0 or schemaVersion > rowSchema.version then return fail(UNSUPPORTED_FORMAT, "decodeCompatible", "stored schema version is newer than decoder") end if
  if count <= 0 or count > len(rowSchema.columns) or nullBytes != ((count + 7) >> 3) or directoryOffset != HEADER_SIZE + nullBytes then return fail(CORRUPT_DATA, "decodeCompatible", "row shape is incompatible with schema") end if
  dataStart = directoryOffset + count * DIRECTORY_ENTRY_SIZE
  if dataStart > len(encoded) then return fail(CORRUPT_DATA, "decodeCompatible", "directory exceeds row") end if
  if count % 8 != 0 then
    lastMask = 0
    for bit = count % 8 to 7
      lastMask = lastMask | (1 << bit)
    end for
    if (encoded[HEADER_SIZE + nullBytes - 1] & lastMask) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeCompatible", "reserved NULL-bitmap bits are non-zero") end if
  end if
  output = []
  cursor = dataStart
  for index = 0 to count - 1
    spec = rowSchema.columns[index]
    entryOffset = directoryOffset + index * DIRECTORY_ENTRY_SIZE
    typeCode = endian.readU16LE(encoded, entryOffset)
    entryFlags = endian.readU16LE(encoded, entryOffset + 2)
    valueOffset = endian.readU16LE(encoded, entryOffset + 4)
    valueLength = endian.readU16LE(encoded, entryOffset + 6)
    if typeCode != spec.typeCode or (entryFlags != 0 and entryFlags != FLAG_NULL and entryFlags != FLAG_EXTERNAL) then return fail(CORRUPT_DATA, "decodeCompatible", "invalid directory entry") end if
    bitmapNull = (encoded[HEADER_SIZE + (index >> 3)] & (1 << (index % 8))) != 0
    if ((entryFlags & FLAG_NULL) != 0) != bitmapNull then return fail(CORRUPT_DATA, "decodeCompatible", "NULL bitmap disagrees with directory") end if
    if valueOffset != cursor then return fail(CORRUPT_DATA, "decodeCompatible", "non-canonical value offset") end if
    if bitmapNull then
      if valueLength != 0 or not spec.nullable then return fail(CORRUPT_DATA, "decodeCompatible", "invalid NULL value") end if
      output = output + [nullValue()]
    else
      if valueOffset < dataStart or valueOffset > len(encoded) or valueLength > len(encoded) - valueOffset then return fail(CORRUPT_DATA, "decodeCompatible", "value range exceeds row") end if
      valueBytes = slice(encoded, valueOffset, valueLength)
      if (entryFlags & FLAG_EXTERNAL) != 0 then
        if not isExternalType(spec.typeCode) or valueLength == 0 then return fail(CORRUPT_DATA, "decodeCompatible", "invalid external LOB pointer") end if
        output = output + [ExternalValue(valueBytes)]
      else
        output = output + [decodeScalar(spec, valueBytes)]
      end if
      cursor = cursor + valueLength
    end if
  end for
  if cursor != len(encoded) then return fail(CORRUPT_DATA, "decodeCompatible", "trailing or unreachable row bytes") end if
  return RowData(schemaVersion, output)
end function

function external(encodedPointer)
  if typeof(encodedPointer) != "bytes" or len(encodedPointer) == 0 then return fail(INVALID_ARGUMENT, "external", "pointer must be non-empty bytes") end if
  return ExternalValue(bytes(encodedPointer))
end function

function componentName()
  return "storage.row_codec"
end function

function targetMilestone()
  return "M9"
end function

function isImplemented()
  return true
end function
