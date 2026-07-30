package minisql.storage.overflow

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.row_codec as row_codec

// Overflow-chain format v1 for large TEXT/BLOB values. Every chain page is a
// normal checksummed MiniSQL page and additionally carries owner, sequence and
// total-length metadata. The pointer stores a whole-value CRC-32C.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004

const FORMAT_VERSION = 1
const POINTER_SIZE = 48
const CHAIN_HEADER_OFFSET = 64
const CHAIN_HEADER_SIZE = 40
const DATA_OFFSET = 104
const NEXT_PAGE_OFFSET = 80
const CHUNK_LENGTH_OFFSET = 88
const TOTAL_LENGTH_OFFSET = 92
const SEQUENCE_OFFSET = 96

struct OverflowPointer
  fileId
  firstPage
  totalLength
  ownerId
  valueChecksum
end struct

struct OverflowReplacement
  oldPointer
  newPointer
  completed
end struct

function fail(code, operation, message)
  return error(code, "storage.overflow." + operation + ": " + message)
end function

function pointerMagic()
  return bytes("MSOP")
end function

function pageMagic()
  return bytes("MSOV")
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function validateNative(value, operation, name, allowMinusOne)
  if typeof(value) != "int" then return fail(INVALID_ARGUMENT, operation, name + " must be int") end if
  if allowMinusOne and value == -1 then return true end if
  if value < 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, name + " is outside native range") end if
  return true
end function

function createPointer(fileId, firstPage, totalLength, ownerId, valueChecksum)
  validateNative(fileId, "createPointer", "fileId", false)
  validateNative(firstPage, "createPointer", "firstPage", true)
  validateNative(totalLength, "createPointer", "totalLength", false)
  if totalLength > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "createPointer", "totalLength must fit U32") end if
  validateNative(ownerId, "createPointer", "ownerId", false)
  if typeof(valueChecksum) != "int" or valueChecksum < 0 or valueChecksum > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "createPointer", "valueChecksum must fit U32") end if
  if totalLength == 0 and firstPage != -1 then return fail(INVALID_ARGUMENT, "createPointer", "empty value must use firstPage=-1") end if
  if totalLength > 0 and firstPage < 0 then return fail(INVALID_ARGUMENT, "createPointer", "non-empty value requires first page") end if
  return OverflowPointer(fileId, firstPage, totalLength, ownerId, valueChecksum)
end function

function encodePointer(pointer)
  if pointer is not OverflowPointer then return fail(INVALID_ARGUMENT, "encodePointer", "value must be OverflowPointer") end if
  checked = createPointer(pointer.fileId, pointer.firstPage, pointer.totalLength, pointer.ownerId, pointer.valueChecksum)
  output = bytes(POINTER_SIZE, 0)
  copyBytes(output, 0, pointerMagic(), 0, 4)
  endian.writeU16LE(output, 4, FORMAT_VERSION)
  endian.writeU16LE(output, 6, 0)
  endian.writeU64LE(output, 8, endian.uint64FromInt(checked.fileId))
  if checked.firstPage == -1 then
    endian.writeU64LE(output, 16, endian.makeUInt64(endian.MAX_U32, endian.MAX_U32))
  else
    endian.writeU64LE(output, 16, endian.uint64FromInt(checked.firstPage))
  end if
  endian.writeU64LE(output, 24, endian.uint64FromInt(checked.totalLength))
  endian.writeU64LE(output, 32, endian.uint64FromInt(checked.ownerId))
  endian.writeU32LE(output, 40, checked.valueChecksum)
  endian.writeU32LE(output, 44, 0)
  return output
end function

function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

function decodePointer(encoded)
  if typeof(encoded) != "bytes" or len(encoded) != POINTER_SIZE then return fail(CORRUPT_DATA, "decodePointer", "pointer must be 48 bytes") end if
  if not bytesEqual(slice(encoded, 0, 4), pointerMagic()) then return fail(UNSUPPORTED_FORMAT, "decodePointer", "pointer magic mismatch") end if
  if endian.readU16LE(encoded, 4) != FORMAT_VERSION or endian.readU16LE(encoded, 6) != 0 or endian.readU32LE(encoded, 44) != 0 then return fail(UNSUPPORTED_FORMAT, "decodePointer", "unsupported pointer fields") end if
  firstWords = endian.readU64LE(encoded, 16)
  firstPage = -1
  if firstWords.high != endian.MAX_U32 or firstWords.low != endian.MAX_U32 then firstPage = decodeNative(firstWords, "decodePointer", "firstPage") end if
  return createPointer(
    decodeNative(endian.readU64LE(encoded, 8), "decodePointer", "fileId"),
    firstPage,
    decodeNative(endian.readU64LE(encoded, 24), "decodePointer", "totalLength"),
    decodeNative(endian.readU64LE(encoded, 32), "decodePointer", "ownerId"),
    endian.readU32LE(encoded, 40)
  )
end function

function toExternal(pointer)
  return row_codec.external(encodePointer(pointer))
end function

function fromExternal(value)
  if not row_codec.isExternalValue(value) then return fail(INVALID_ARGUMENT, "fromExternal", "value must be ExternalValue") end if
  return decodePointer(value.encodedPointer)
end function

function chunkCapacity(pagedFile)
  paged_file.validateOpen(pagedFile, "overflow.chunkCapacity")
  if pagedFile.pageSize <= DATA_OFFSET then return fail(INVALID_ARGUMENT, "chunkCapacity", "page size is too small") end if
  return pagedFile.pageSize - DATA_OFFSET
end function

function encodePage(pagedFile, pageNumber, ownerId, nextPage, totalLength, sequence, chunk)
  validateNative(ownerId, "encodePage", "ownerId", false)
  validateNative(nextPage, "encodePage", "nextPage", true)
  if typeof(totalLength) != "int" or totalLength <= 0 or totalLength > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodePage", "invalid totalLength") end if
  if typeof(sequence) != "int" or sequence < 0 or sequence > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodePage", "invalid sequence") end if
  if typeof(chunk) != "bytes" or len(chunk) == 0 or len(chunk) > chunkCapacity(pagedFile) then return fail(INVALID_ARGUMENT, "encodePage", "invalid chunk") end if
  result = page.create(pagedFile.pageSize, page.TYPE_OVERFLOW, pagedFile.fileId, pageNumber)
  copyBytes(result, CHAIN_HEADER_OFFSET, pageMagic(), 0, 4)
  endian.writeU16LE(result, 68, FORMAT_VERSION)
  endian.writeU16LE(result, 70, 0)
  endian.writeU64LE(result, 72, endian.uint64FromInt(ownerId))
  if nextPage == -1 then
    endian.writeU64LE(result, NEXT_PAGE_OFFSET, endian.makeUInt64(endian.MAX_U32, endian.MAX_U32))
  else
    endian.writeU64LE(result, NEXT_PAGE_OFFSET, endian.uint64FromInt(nextPage))
  end if
  endian.writeU32LE(result, CHUNK_LENGTH_OFFSET, len(chunk))
  endian.writeU32LE(result, TOTAL_LENGTH_OFFSET, totalLength)
  endian.writeU32LE(result, SEQUENCE_OFFSET, sequence)
  endian.writeU32LE(result, 100, 0)
  copyBytes(result, DATA_OFFSET, chunk, 0, len(chunk))
  page.reseal(result)
  return result
end function

function decodeNext(pageBytes)
  words = endian.readU64LE(pageBytes, NEXT_PAGE_OFFSET)
  if words.high == endian.MAX_U32 and words.low == endian.MAX_U32 then return -1 end if
  return decodeNative(words, "decodeNext", "nextPage")
end function

function validateChainPage(pagedFile, pageBytes, pointer, expectedPage, expectedSequence)
  header = page.verify(pageBytes)
  if header.pageType != page.TYPE_OVERFLOW or header.pageId.fileId != pointer.fileId or header.pageId.pageNumber != expectedPage then return fail(CORRUPT_DATA, "validateChainPage", "overflow page identity/type mismatch") end if
  if not bytesEqual(slice(pageBytes, CHAIN_HEADER_OFFSET, 4), pageMagic()) then return fail(UNSUPPORTED_FORMAT, "validateChainPage", "overflow magic mismatch") end if
  if endian.readU16LE(pageBytes, 68) != FORMAT_VERSION or endian.readU16LE(pageBytes, 70) != 0 or endian.readU32LE(pageBytes, 100) != 0 then return fail(UNSUPPORTED_FORMAT, "validateChainPage", "unsupported overflow header") end if
  owner = decodeNative(endian.readU64LE(pageBytes, 72), "validateChainPage", "ownerId")
  if owner != pointer.ownerId then return fail(CORRUPT_DATA, "validateChainPage", "owner mismatch") end if
  if endian.readU32LE(pageBytes, TOTAL_LENGTH_OFFSET) != pointer.totalLength then return fail(CORRUPT_DATA, "validateChainPage", "total length mismatch") end if
  if endian.readU32LE(pageBytes, SEQUENCE_OFFSET) != expectedSequence then return fail(CORRUPT_DATA, "validateChainPage", "sequence mismatch") end if
  chunkLength = endian.readU32LE(pageBytes, CHUNK_LENGTH_OFFSET)
  if chunkLength == 0 or chunkLength > chunkCapacity(pagedFile) then return fail(CORRUPT_DATA, "validateChainPage", "invalid chunk length") end if
  return chunkLength
end function

function contains(values, sought)
  for each value in values
    if value == sought then return true end if
  end for
  return false
end function

function pageCountForLength(pagedFile, length)
  if typeof(length) != "int" or length < 0 then return fail(INVALID_ARGUMENT, "pageCountForLength", "length must be non-negative") end if
  if length == 0 then return 0 end if
  capacity = chunkCapacity(pagedFile)
  count = 0
  remaining = length
  while remaining > 0
    count = count + 1
    remaining = remaining - capacity
  end while
  return count
end function

function allocatePageNumbers(pagedFile, count)
  if typeof(count) != "int" or count < 0 then return fail(INVALID_ARGUMENT, "allocatePageNumbers", "count must be non-negative") end if
  result = []
  if count == 0 then return result end if
  if pagedFile.pageCount > 0 then
    for pageNumber = 0 to pagedFile.pageCount - 1
      header = page.verify(paged_file.readPage(pagedFile, pageNumber))
      if header.pageType == page.TYPE_FREE then result = result + [pageNumber] end if
      if len(result) == count then return result end if
    end for
  end if
  nextPage = pagedFile.pageCount
  while len(result) < count
    result = result + [nextPage]
    nextPage = nextPage + 1
  end while
  return result
end function

function write(pagedFile, ownerId, value)
  paged_file.validateOpen(pagedFile, "overflow.write")
  validateNative(ownerId, "write", "ownerId", false)
  if typeof(value) != "bytes" then return fail(INVALID_ARGUMENT, "write", "value must be bytes") end if
  if len(value) == 0 then return createPointer(pagedFile.fileId, -1, 0, ownerId, crc32c.compute(value)) end if
  if len(value) > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "write", "overflow value exceeds U32 length") end if

  count = pageCountForLength(pagedFile, len(value))
  pageNumbers = allocatePageNumbers(pagedFile, count)
  capacity = chunkCapacity(pagedFile)
  offset = 0
  for sequence = 0 to count - 1
    length = capacity
    if len(value) - offset < length then length = len(value) - offset end if
    nextPage = -1
    if sequence < count - 1 then nextPage = pageNumbers[sequence + 1] end if
    encodedPage = encodePage(pagedFile, pageNumbers[sequence], ownerId, nextPage, len(value), sequence, slice(value, offset, length))
    if pageNumbers[sequence] == pagedFile.pageCount then
      paged_file.appendPage(pagedFile, encodedPage)
    else
      paged_file.writePage(pagedFile, pageNumbers[sequence], encodedPage)
    end if
    offset = offset + length
  end for
  paged_file.flush(pagedFile)
  return createPointer(pagedFile.fileId, pageNumbers[0], len(value), ownerId, crc32c.compute(value))
end function

function validatePointerForFile(pagedFile, pointer, operation)
  paged_file.validateOpen(pagedFile, "overflow." + operation)
  if pointer is not OverflowPointer then return fail(INVALID_ARGUMENT, operation, "pointer must be OverflowPointer") end if
  createPointer(pointer.fileId, pointer.firstPage, pointer.totalLength, pointer.ownerId, pointer.valueChecksum)
  if pointer.fileId != pagedFile.fileId then return fail(CORRUPT_DATA, operation, "pointer belongs to another file") end if
  return true
end function

// Traverses and validates the complete chain while copying only the requested
// range. This keeps range reads bounded by the requested output size while still
// checking the whole-value checksum and every chain link.
function readRange(pagedFile, pointer, requestedOffset, requestedLength)
  validatePointerForFile(pagedFile, pointer, "readRange")
  if typeof(requestedOffset) != "int" or typeof(requestedLength) != "int" or requestedOffset < 0 or requestedLength < 0 or requestedOffset > pointer.totalLength or requestedLength > pointer.totalLength - requestedOffset then return fail(INVALID_ARGUMENT, "readRange", "range exceeds value") end if
  if pointer.totalLength == 0 then
    if pointer.valueChecksum != crc32c.compute(bytes()) then return fail(CORRUPT_DATA, "readRange", "empty-value checksum mismatch") end if
    return bytes()
  end if

  output = bytes(requestedLength, 0)
  current = pointer.firstPage
  visited = []
  sequence = 0
  logicalOffset = 0
  copied = 0
  checksum = 0
  rangeEnd = requestedOffset + requestedLength
  while current != -1
    if current < 0 or current >= pagedFile.pageCount then return fail(CORRUPT_DATA, "readRange", "overflow page is missing") end if
    if contains(visited, current) then return fail(CORRUPT_DATA, "readRange", "overflow chain contains a cycle") end if
    visited = visited + [current]
    pageBytes = paged_file.readPage(pagedFile, current)
    chunkLength = validateChainPage(pagedFile, pageBytes, pointer, current, sequence)
    if chunkLength > pointer.totalLength - logicalOffset then return fail(CORRUPT_DATA, "readRange", "chunks exceed total length") end if
    checksum = crc32c.update(checksum, pageBytes, DATA_OFFSET, chunkLength)

    chunkStart = logicalOffset
    chunkEnd = logicalOffset + chunkLength
    copyStart = requestedOffset
    if chunkStart > copyStart then copyStart = chunkStart end if
    copyEnd = rangeEnd
    if chunkEnd < copyEnd then copyEnd = chunkEnd end if
    if copyEnd > copyStart then
      length = copyEnd - copyStart
      sourceOffset = DATA_OFFSET + copyStart - chunkStart
      destinationOffset = copyStart - requestedOffset
      copyBytes(output, destinationOffset, pageBytes, sourceOffset, length)
      copied = copied + length
    end if

    logicalOffset = logicalOffset + chunkLength
    current = decodeNext(pageBytes)
    sequence = sequence + 1
  end while
  if logicalOffset != pointer.totalLength then return fail(CORRUPT_DATA, "readRange", "chain ended before total length") end if
  if checksum != pointer.valueChecksum then return fail(CORRUPT_DATA, "readRange", "whole-value checksum mismatch") end if
  if copied != requestedLength then return fail(CORRUPT_DATA, "readRange", "requested range was not fully covered") end if
  return output
end function

function read(pagedFile, pointer)
  validatePointerForFile(pagedFile, pointer, "read")
  return readRange(pagedFile, pointer, 0, pointer.totalLength)
end function

function free(pagedFile, pointer)
  validatePointerForFile(pagedFile, pointer, "free")
  // Validate the complete chain before mutating any page.
  ignored = readRange(pagedFile, pointer, 0, 0)
  if pointer.totalLength == 0 then return 0 end if
  current = pointer.firstPage
  freed = 0
  while current != -1
    original = paged_file.readPage(pagedFile, current)
    next = decodeNext(original)
    replacement = page.create(pagedFile.pageSize, page.TYPE_FREE, pagedFile.fileId, current)
    paged_file.writePage(pagedFile, current, replacement)
    current = next
    freed = freed + 1
  end while
  paged_file.flush(pagedFile)
  return freed
end function

function prepareReplace(pagedFile, oldPointer, ownerId, newValue)
  validatePointerForFile(pagedFile, oldPointer, "prepareReplace")
  ignored = readRange(pagedFile, oldPointer, 0, 0)
  newPointer = write(pagedFile, ownerId, newValue)
  ignored = readRange(pagedFile, newPointer, 0, 0)
  return OverflowReplacement(oldPointer, newPointer, false)
end function

function commitReplace(pagedFile, replacement)
  if replacement is not OverflowReplacement then return fail(INVALID_ARGUMENT, "commitReplace", "replacement must be OverflowReplacement") end if
  if replacement.completed then return fail(INVALID_ARGUMENT, "commitReplace", "replacement is already completed") end if
  // The caller must persist replacement.newPointer in its row/transaction before
  // invoking this function. Only then is the old chain reclaimed.
  free(pagedFile, replacement.oldPointer)
  replacement.completed = true
  return replacement.newPointer
end function

function abortReplace(pagedFile, replacement)
  if replacement is not OverflowReplacement then return fail(INVALID_ARGUMENT, "abortReplace", "replacement must be OverflowReplacement") end if
  if replacement.completed then return fail(INVALID_ARGUMENT, "abortReplace", "replacement is already completed") end if
  free(pagedFile, replacement.newPointer)
  replacement.completed = true
  return replacement.oldPointer
end function

// Convenience helper with leak-safe semantics: write and return the new value,
// but never destroy oldPointer implicitly. Call free(oldPointer) only after the
// new pointer is durably published.
function replace(pagedFile, oldPointer, ownerId, newValue)
  return prepareReplace(pagedFile, oldPointer, ownerId, newValue).newPointer
end function

function storeText(pagedFile, ownerId, text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "storeText", "text must be string") end if
  return write(pagedFile, ownerId, bytes(text))
end function

function readText(pagedFile, pointer)
  text = decode(read(pagedFile, pointer))
  if typeof(text) != "string" then return fail(CORRUPT_DATA, "readText", "stored text is not valid UTF-8") end if
  return text
end function

function componentName()
  return "storage.overflow"
end function

function targetMilestone()
  return "M10"
end function

function isImplemented()
  return true
end function
