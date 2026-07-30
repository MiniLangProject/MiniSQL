package minisql.storage.superblock

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.common.limits as limits

// Fixed 4096-byte metadata slot used twice at the beginning of every paged file.
// The two copies are updated alternately. The valid copy with the highest
// generation is authoritative after a crash.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004

const FORMAT_VERSION = 1
const SLOT_SIZE = 4096
const HEADER_SIZE = 128
const DATABASE_ID_SIZE = 16
const CHECKSUM_OFFSET = 72

const FILE_TYPE_TABLE = 1
const FILE_TYPE_INDEX = 2
const FILE_TYPE_WAL = 3
const FILE_TYPE_DATABASE_META = 4
const FILE_TYPE_GENERIC = 255

struct Superblock
  formatVersion
  generation
  pageSize
  fileType
  fileId
  pageCount
  databaseId
  featureFlags
end struct

function fail(code, operation, message)
  return error(code, "storage.superblock." + operation + ": " + message)
end function

function magicBytes()
  return bytes("MSQLSB01")
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" then return false end if
  if len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

function validateNativeId(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

function decodeNativeId(value, operation, name)
  endian.validateUInt64Words(value, "storage.superblock." + operation + "." + name)
  if value.high > endian.MAX_SCALAR_HIGH then
    return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds the native MiniLang identifier range")
  end if
  return endian.uint64ToInt(value)
end function

function validateFileType(fileType, operation)
  if typeof(fileType) != "int" or fileType < 0 or fileType > 65535 then
    return fail(INVALID_ARGUMENT, operation, "fileType must fit U16")
  end if
  return true
end function

function validateDatabaseId(databaseId, operation)
  if typeof(databaseId) != "bytes" or len(databaseId) != DATABASE_ID_SIZE then
    return fail(INVALID_ARGUMENT, operation, "databaseId must be exactly 16 bytes")
  end if
  return true
end function

function create(formatVersion, generation, pageSize, fileType, fileId, pageCount, databaseId, featureFlags)
  if formatVersion != FORMAT_VERSION then
    return fail(UNSUPPORTED_FORMAT, "create", "unsupported superblock format version")
  end if
  endian.validateUInt64Words(generation, "storage.superblock.create.generation")
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "create", "unsupported page size")
  end if
  validateFileType(fileType, "create")
  validateNativeId(fileId, "create", "fileId")
  validateNativeId(pageCount, "create", "pageCount")
  validateDatabaseId(databaseId, "create")
  if typeof(featureFlags) != "int" or featureFlags < 0 or featureFlags > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, "create", "featureFlags must fit U32")
  end if
  return Superblock(formatVersion, generation, pageSize, fileType, fileId, pageCount, bytes(databaseId), featureFlags)
end function

function encode(superblock)
  if superblock is not Superblock then return fail(INVALID_ARGUMENT, "encode", "value must be Superblock") end if
  validated = create(
    superblock.formatVersion,
    superblock.generation,
    superblock.pageSize,
    superblock.fileType,
    superblock.fileId,
    superblock.pageCount,
    superblock.databaseId,
    superblock.featureFlags
  )

  output = bytes(SLOT_SIZE, 0)
  copyExact(output, 0, magicBytes(), 0, 8)
  endian.writeU16LE(output, 8, validated.formatVersion)
  endian.writeU16LE(output, 10, HEADER_SIZE)
  endian.writeU16LE(output, 12, validated.fileType)
  endian.writeU16LE(output, 14, 0)
  endian.writeU64LE(output, 16, validated.generation)
  endian.writeU32LE(output, 24, validated.pageSize)
  endian.writeU32LE(output, 28, 0)
  endian.writeU64LE(output, 32, endian.uint64FromInt(validated.fileId))
  endian.writeU64LE(output, 40, endian.uint64FromInt(validated.pageCount))
  copyExact(output, 48, validated.databaseId, 0, DATABASE_ID_SIZE)
  endian.writeU32LE(output, 64, validated.featureFlags)
  endian.writeU32LE(output, 68, 0)
  endian.writeU32LE(output, CHECKSUM_OFFSET, 0)
  checksum = crc32c.compute(output)
  endian.writeU32LE(output, CHECKSUM_OFFSET, checksum)
  return output
end function

function decode(source)
  if typeof(source) != "bytes" or len(source) != SLOT_SIZE then
    return fail(CORRUPT_DATA, "decode", "superblock slot must be exactly 4096 bytes")
  end if
  if not bytesEqual(slice(source, 0, 8), magicBytes()) then
    return fail(UNSUPPORTED_FORMAT, "decode", "superblock magic mismatch")
  end if
  version = endian.readU16LE(source, 8)
  headerSize = endian.readU16LE(source, 10)
  if version != FORMAT_VERSION then return fail(UNSUPPORTED_FORMAT, "decode", "unsupported superblock version") end if
  if headerSize != HEADER_SIZE then return fail(UNSUPPORTED_FORMAT, "decode", "unsupported superblock header size") end if
  if endian.readU16LE(source, 14) != 0 or endian.readU32LE(source, 28) != 0 or endian.readU32LE(source, 68) != 0 then
    return fail(UNSUPPORTED_FORMAT, "decode", "reserved superblock fields are non-zero")
  end if

  storedChecksum = endian.readU32LE(source, CHECKSUM_OFFSET)
  copy = bytes(source)
  endian.writeU32LE(copy, CHECKSUM_OFFSET, 0)
  if crc32c.compute(copy) != storedChecksum then
    return fail(CORRUPT_DATA, "decode", "superblock checksum mismatch")
  end if
  for index = 76 to SLOT_SIZE - 1
    if source[index] != 0 then
      return fail(UNSUPPORTED_FORMAT, "decode", "reserved superblock bytes are non-zero")
    end if
  end for

  generation = endian.readU64LE(source, 16)
  pageSize = endian.readU32LE(source, 24)
  fileType = endian.readU16LE(source, 12)
  fileId = decodeNativeId(endian.readU64LE(source, 32), "decode", "fileId")
  pageCount = decodeNativeId(endian.readU64LE(source, 40), "decode", "pageCount")
  databaseId = slice(source, 48, DATABASE_ID_SIZE)
  featureFlags = endian.readU32LE(source, 64)
  return create(version, generation, pageSize, fileType, fileId, pageCount, databaseId, featureFlags)
end function

function compareGeneration(left, right)
  endian.validateUInt64Words(left, "storage.superblock.compareGeneration.left")
  endian.validateUInt64Words(right, "storage.superblock.compareGeneration.right")
  if left.high < right.high then return -1 end if
  if left.high > right.high then return 1 end if
  if left.low < right.low then return -1 end if
  if left.low > right.low then return 1 end if
  return 0
end function

function incrementGeneration(value)
  endian.validateUInt64Words(value, "storage.superblock.incrementGeneration")
  if value.high == endian.MAX_U32 and value.low == endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, "incrementGeneration", "generation overflow")
  end if
  high = value.high
  low = value.low + 1
  if low > endian.MAX_U32 then
    low = 0
    high = high + 1
  end if
  return endian.makeUInt64(high, low)
end function

function sameDatabaseId(left, right)
  validateDatabaseId(left, "sameDatabaseId")
  validateDatabaseId(right, "sameDatabaseId")
  return bytesEqual(left, right)
end function

function immutableIdentityMatches(left, right)
  if left is not Superblock or right is not Superblock then
    return fail(INVALID_ARGUMENT, "immutableIdentityMatches", "values must be Superblock")
  end if
  return left.formatVersion == right.formatVersion and
    left.pageSize == right.pageSize and
    left.fileType == right.fileType and
    left.fileId == right.fileId and
    left.featureFlags == right.featureFlags and
    sameDatabaseId(left.databaseId, right.databaseId)
end function

function componentName()
  return "storage.superblock"
end function

function targetMilestone()
  return "M4"
end function

function isImplemented()
  return true
end function
