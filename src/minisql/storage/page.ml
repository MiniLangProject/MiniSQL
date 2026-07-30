package minisql.storage.page

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.common.limits as limits

// MiniSQL page format version 1.
//
// Every page is self-describing and protected by two CRC-32C values:
// - payloadChecksum covers bytes HEADER_SIZE..pageSize-1;
// - headerChecksum covers the 64-byte header with its checksum field zeroed.
//
// All persisted integers are little-endian. File and page identifiers currently
// use non-negative native MiniLang ints and are encoded as full-width U64 fields.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004

const FORMAT_VERSION = 1
const HEADER_SIZE = 64
const MAGIC_SIZE = 4
const PAYLOAD_CHECKSUM_OFFSET = 56
const HEADER_CHECKSUM_OFFSET = 60

const TYPE_FREE = 0
const TYPE_HEAP = 1
const TYPE_OVERFLOW = 2
const TYPE_BTREE_INTERNAL = 3
const TYPE_BTREE_LEAF = 4
const TYPE_CATALOG = 5
const TYPE_GENERIC = 255

struct PageId
  fileId
  pageNumber
end struct

struct PageHeader
  version
  pageType
  flags
  pageId
  pageLsn
  generation
  itemCount
  freeStart
  freeEnd
  payloadChecksum
  headerChecksum
end struct

function fail(code, operation, message)
  return error(code, "storage.page." + operation + ": " + message)
end function

function magicBytes()
  return bytes("MSPG")
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
  endian.validateUInt64Words(value, "storage.page." + operation + "." + name)
  if value.high > endian.MAX_SCALAR_HIGH then
    return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds the native MiniLang identifier range")
  end if
  return endian.uint64ToInt(value)
end function

function validatePageType(value, operation)
  if typeof(value) != "int" or value < 0 or value > 65535 then
    return fail(INVALID_ARGUMENT, operation, "pageType must fit U16")
  end if
  return true
end function

function validatePageSize(pageSize, operation)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, operation, "unsupported page size")
  end if
  if pageSize <= HEADER_SIZE then
    return fail(INVALID_ARGUMENT, operation, "page size is too small for the header")
  end if
  return true
end function

function validatePageBuffer(pageBytes, operation)
  if typeof(pageBytes) != "bytes" then
    return fail(INVALID_ARGUMENT, operation, "page must be bytes")
  end if
  validatePageSize(len(pageBytes), operation)
  return true
end function

function createPageId(fileId, pageNumber)
  validateNativeId(fileId, "createPageId", "fileId")
  validateNativeId(pageNumber, "createPageId", "pageNumber")
  return PageId(fileId, pageNumber)
end function

function newHeader(pageType, pageId, pageSize)
  validatePageType(pageType, "newHeader")
  if pageId is not PageId then return fail(INVALID_ARGUMENT, "newHeader", "pageId must be PageId") end if
  validateNativeId(pageId.fileId, "newHeader", "fileId")
  validateNativeId(pageId.pageNumber, "newHeader", "pageNumber")
  validatePageSize(pageSize, "newHeader")
  return PageHeader(
    FORMAT_VERSION,
    pageType,
    0,
    pageId,
    endian.makeUInt64(0, 0),
    endian.makeUInt64(0, 0),
    0,
    HEADER_SIZE,
    pageSize,
    0,
    0
  )
end function

function validateHeader(header, pageSize, operation)
  if header is not PageHeader then return fail(INVALID_ARGUMENT, operation, "header must be PageHeader") end if
  validatePageSize(pageSize, operation)
  if header.version != FORMAT_VERSION then
    return fail(UNSUPPORTED_FORMAT, operation, "unsupported page format version")
  end if
  validatePageType(header.pageType, operation)
  if typeof(header.flags) != "int" or header.flags < 0 or header.flags > 65535 then
    return fail(INVALID_ARGUMENT, operation, "flags must fit U16")
  end if
  if header.pageId is not PageId then return fail(INVALID_ARGUMENT, operation, "pageId must be PageId") end if
  validateNativeId(header.pageId.fileId, operation, "fileId")
  validateNativeId(header.pageId.pageNumber, operation, "pageNumber")
  endian.validateUInt64Words(header.pageLsn, "storage.page." + operation + ".pageLsn")
  endian.validateUInt64Words(header.generation, "storage.page." + operation + ".generation")
  if typeof(header.itemCount) != "int" or header.itemCount < 0 or header.itemCount > 65535 then
    return fail(INVALID_ARGUMENT, operation, "itemCount must fit U16")
  end if
  if typeof(header.freeStart) != "int" or typeof(header.freeEnd) != "int" then
    return fail(INVALID_ARGUMENT, operation, "free-space offsets must be int")
  end if
  if header.freeStart < HEADER_SIZE or header.freeEnd < header.freeStart or header.freeEnd > pageSize then
    return fail(CORRUPT_DATA, operation, "invalid free-space offsets")
  end if
  if typeof(header.payloadChecksum) != "int" or header.payloadChecksum < 0 or header.payloadChecksum > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, operation, "payloadChecksum must fit U32")
  end if
  if typeof(header.headerChecksum) != "int" or header.headerChecksum < 0 or header.headerChecksum > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, operation, "headerChecksum must fit U32")
  end if
  return true
end function

function encodePageHeader(header, destination)
  if typeof(destination) != "bytes" or len(destination) < HEADER_SIZE then
    return fail(INVALID_ARGUMENT, "encodePageHeader", "destination must contain at least 64 bytes")
  end if
  validateHeader(header, len(destination), "encodePageHeader")

  fillBytes(destination, 0, HEADER_SIZE, 0)
  copyExact(destination, 0, magicBytes(), 0, MAGIC_SIZE)
  endian.writeU16LE(destination, 4, header.version)
  endian.writeU16LE(destination, 6, HEADER_SIZE)
  endian.writeU16LE(destination, 8, header.pageType)
  endian.writeU16LE(destination, 10, header.flags)
  endian.writeU32LE(destination, 12, 0)
  endian.writeU64LE(destination, 16, endian.uint64FromInt(header.pageId.fileId))
  endian.writeU64LE(destination, 24, endian.uint64FromInt(header.pageId.pageNumber))
  endian.writeU64LE(destination, 32, header.pageLsn)
  endian.writeU64LE(destination, 40, header.generation)
  endian.writeU16LE(destination, 48, header.itemCount)
  endian.writeU16LE(destination, 50, header.freeStart)
  endian.writeU16LE(destination, 52, header.freeEnd)
  endian.writeU16LE(destination, 54, 0)
  endian.writeU32LE(destination, PAYLOAD_CHECKSUM_OFFSET, header.payloadChecksum)
  endian.writeU32LE(destination, HEADER_CHECKSUM_OFFSET, header.headerChecksum)
  return HEADER_SIZE
end function

function decodePageHeader(source)
  validatePageBuffer(source, "decodePageHeader")
  if not bytesEqual(slice(source, 0, MAGIC_SIZE), magicBytes()) then
    return fail(UNSUPPORTED_FORMAT, "decodePageHeader", "page magic mismatch")
  end if
  version = endian.readU16LE(source, 4)
  headerSize = endian.readU16LE(source, 6)
  if version != FORMAT_VERSION then
    return fail(UNSUPPORTED_FORMAT, "decodePageHeader", "unsupported page format version")
  end if
  if headerSize != HEADER_SIZE then
    return fail(UNSUPPORTED_FORMAT, "decodePageHeader", "unsupported page header size")
  end if
  if endian.readU32LE(source, 12) != 0 or endian.readU16LE(source, 54) != 0 then
    return fail(UNSUPPORTED_FORMAT, "decodePageHeader", "reserved page-header fields are non-zero")
  end if

  storedHeaderChecksum = endian.readU32LE(source, HEADER_CHECKSUM_OFFSET)
  headerCopy = slice(source, 0, HEADER_SIZE)
  endian.writeU32LE(headerCopy, HEADER_CHECKSUM_OFFSET, 0)
  actualHeaderChecksum = crc32c.compute(headerCopy)
  if storedHeaderChecksum != actualHeaderChecksum then
    return fail(CORRUPT_DATA, "decodePageHeader", "header checksum mismatch")
  end if

  fileId = decodeNativeId(endian.readU64LE(source, 16), "decodePageHeader", "fileId")
  pageNumber = decodeNativeId(endian.readU64LE(source, 24), "decodePageHeader", "pageNumber")
  header = PageHeader(
    version,
    endian.readU16LE(source, 8),
    endian.readU16LE(source, 10),
    PageId(fileId, pageNumber),
    endian.readU64LE(source, 32),
    endian.readU64LE(source, 40),
    endian.readU16LE(source, 48),
    endian.readU16LE(source, 50),
    endian.readU16LE(source, 52),
    endian.readU32LE(source, PAYLOAD_CHECKSUM_OFFSET),
    storedHeaderChecksum
  )
  validateHeader(header, len(source), "decodePageHeader")
  return header
end function

function seal(pageBytes, header)
  validatePageBuffer(pageBytes, "seal")
  validateHeader(header, len(pageBytes), "seal")
  header.payloadChecksum = crc32c.computeRange(pageBytes, HEADER_SIZE, len(pageBytes) - HEADER_SIZE)
  header.headerChecksum = 0
  encodePageHeader(header, pageBytes)
  header.headerChecksum = crc32c.computeRange(pageBytes, 0, HEADER_SIZE)
  endian.writeU32LE(pageBytes, HEADER_CHECKSUM_OFFSET, header.headerChecksum)
  return header
end function

function verify(pageBytes)
  validatePageBuffer(pageBytes, "verify")
  header = decodePageHeader(pageBytes)
  actualPayloadChecksum = crc32c.computeRange(pageBytes, HEADER_SIZE, len(pageBytes) - HEADER_SIZE)
  if actualPayloadChecksum != header.payloadChecksum then
    return fail(CORRUPT_DATA, "verify", "payload checksum mismatch")
  end if
  return header
end function

function create(pageSize, pageType, fileId, pageNumber)
  pageId = createPageId(fileId, pageNumber)
  header = newHeader(pageType, pageId, pageSize)
  pageBytes = bytes(pageSize, 0)
  seal(pageBytes, header)
  return pageBytes
end function

function reseal(pageBytes)
  validatePageBuffer(pageBytes, "reseal")
  header = decodePageHeader(pageBytes)
  seal(pageBytes, header)
  return header
end function

function compareLsn(left, right)
  endian.validateUInt64Words(left, "storage.page.compareLsn.left")
  endian.validateUInt64Words(right, "storage.page.compareLsn.right")
  if left.high < right.high then return -1 end if
  if left.high > right.high then return 1 end if
  if left.low < right.low then return -1 end if
  if left.low > right.low then return 1 end if
  return 0
end function

function setLsn(pageBytes, lsn)
  validatePageBuffer(pageBytes, "setLsn")
  endian.validateUInt64Words(lsn, "storage.page.setLsn.lsn")
  header = verify(pageBytes)
  header.pageLsn = lsn
  seal(pageBytes, header)
  return header
end function

function componentName()
  return "storage.page"
end function

function targetMilestone()
  return "M4"
end function

function isImplemented()
  return true
end function
