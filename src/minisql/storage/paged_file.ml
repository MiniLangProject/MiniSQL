package minisql.storage.paged_file

import minisql.common.endian as endian
import minisql.common.limits as limits
import minisql.platform.file as file_api
import minisql.platform.lock as file_lock
import minisql.storage.page as page
import minisql.storage.superblock as superblock

// A paged file begins with two fixed 4096-byte superblock slots followed by a
// fixed data region at offset 8192. Page size is persisted in both superblocks;
// the global configuration is never consulted when an existing file is opened.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008

const SLOT_A = 0
const SLOT_B = 1
const SLOT_A_OFFSET = 0
const SLOT_B_OFFSET = 4096
const DATA_OFFSET = 8192

struct PagedFile
  path
  file
  pageSize
  fileType
  fileId
  databaseId
  pageCount
  generation
  activeSlot
  featureFlags
  closed
end struct

function fail(code, operation, message)
  return error(code, "storage.paged_file." + operation + ": " + message)
end function

function validateDatabaseId(databaseId, operation)
  if typeof(databaseId) != "bytes" or len(databaseId) != superblock.DATABASE_ID_SIZE then
    return fail(INVALID_ARGUMENT, operation, "databaseId must be exactly 16 bytes")
  end if
  return true
end function

function validateNativeId(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

function validateOpen(pagedFile, operation)
  if pagedFile is not PagedFile then return fail(INVALID_ARGUMENT, operation, "value must be PagedFile") end if
  if pagedFile.closed then return fail(CLOSED_HANDLE, operation, "paged file is closed") end if
  return true
end function

function slotOffset(slot)
  if slot == SLOT_A then return SLOT_A_OFFSET end if
  if slot == SLOT_B then return SLOT_B_OFFSET end if
  return fail(INVALID_ARGUMENT, "slotOffset", "slot must be 0 or 1")
end function

function maxPageCountFor(pageSize)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "maxPageCountFor", "unsupported page size")
  end if
  available = endian.MAX_MINILANG_INT - DATA_OFFSET
  if pageSize == 4096 then return available >> 12 end if
  if pageSize == 8192 then return available >> 13 end if
  if pageSize == 16384 then return available >> 14 end if
  return available >> 15
end function

function pageOffset(pagedFile, pageNumber)
  validateOpen(pagedFile, "pageOffset")
  validateNativeId(pageNumber, "pageOffset", "pageNumber")
  if pageNumber >= maxPageCountFor(pagedFile.pageSize) then
    return fail(INVALID_ARGUMENT, "pageOffset", "page number would extend beyond the native file-size range")
  end if
  return DATA_OFFSET + pageNumber * pagedFile.pageSize
end function

function committedSize(pageSize, pageCount)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "committedSize", "unsupported page size")
  end if
  validateNativeId(pageCount, "committedSize", "pageCount")
  if pageCount > maxPageCountFor(pageSize) then
    return fail(INVALID_ARGUMENT, "committedSize", "file size exceeds native range")
  end if
  return DATA_OFFSET + pageCount * pageSize
end function

function metadataFor(pagedFile, generation, pageCount)
  return superblock.create(
    superblock.FORMAT_VERSION,
    generation,
    pagedFile.pageSize,
    pagedFile.fileType,
    pagedFile.fileId,
    pageCount,
    pagedFile.databaseId,
    pagedFile.featureFlags
  )
end function

function writeSlot(file, slot, metadata)
  encoded = superblock.encode(metadata)
  file_api.writeAt(file, slotOffset(slot), encoded, 0, len(encoded))
  return true
end function

function commitMetadata(pagedFile, newPageCount)
  validateOpen(pagedFile, "commitMetadata")
  validateNativeId(newPageCount, "commitMetadata", "newPageCount")
  newGeneration = superblock.incrementGeneration(pagedFile.generation)
  targetSlot = SLOT_A
  if pagedFile.activeSlot == SLOT_A then targetSlot = SLOT_B end if
  metadata = metadataFor(pagedFile, newGeneration, newPageCount)
  writeSlot(pagedFile.file, targetSlot, metadata)
  file_api.flush(pagedFile.file)
  pagedFile.generation = newGeneration
  pagedFile.pageCount = newPageCount
  pagedFile.activeSlot = targetSlot
  return true
end function

function create(path, pageSize, fileType, fileId, databaseId)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "create", "path must be non-empty") end if
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "create", "unsupported page size")
  end if
  if typeof(fileType) != "int" or fileType < 0 or fileType > 65535 then
    return fail(INVALID_ARGUMENT, "create", "fileType must fit U16")
  end if
  validateNativeId(fileId, "create", "fileId")
  validateDatabaseId(databaseId, "create")

  file = file_api.createNewDurable(path)
  lockResult = try(file_lock.acquireExclusive(file, true))
  if typeof(lockResult) == "error" then
    file_api.close(file)
    return lockResult
  end if
  result = PagedFile(
    path,
    file,
    pageSize,
    fileType,
    fileId,
    bytes(databaseId),
    0,
    endian.makeUInt64(0, 0),
    SLOT_B,
    0,
    false
  )

  // Establish a durable older copy first, then publish generation 1 in slot A.
  older = metadataFor(result, endian.makeUInt64(0, 0), 0)
  writeSlot(file, SLOT_B, older)
  file_api.flush(file)
  newest = metadataFor(result, endian.makeUInt64(0, 1), 0)
  writeSlot(file, SLOT_A, newest)
  file_api.flush(file)
  result.generation = endian.makeUInt64(0, 1)
  result.activeSlot = SLOT_A
  return result
end function

function readSlot(file, slot)
  data = bytes(superblock.SLOT_SIZE, 0)
  file_api.readExactAt(file, slotOffset(slot), data, 0, len(data))
  return superblock.decode(data)
end function

function chooseMetadata(firstResult, secondResult)
  firstValid = typeof(firstResult) != "error"
  secondValid = typeof(secondResult) != "error"
  if not firstValid and not secondValid then
    return fail(CORRUPT_DATA, "open", "both superblock copies are invalid")
  end if
  if firstValid and secondValid then
    if not superblock.immutableIdentityMatches(firstResult, secondResult) then
      return fail(CORRUPT_DATA, "open", "superblock copies disagree on immutable identity")
    end if
    comparison = superblock.compareGeneration(firstResult.generation, secondResult.generation)
    if comparison == 0 and firstResult.pageCount != secondResult.pageCount then
      return fail(CORRUPT_DATA, "open", "equal superblock generations disagree on page count")
    end if
    if comparison >= 0 then
      return [firstResult, SLOT_A]
    end if
    return [secondResult, SLOT_B]
  end if
  if firstValid then return [firstResult, SLOT_A] end if
  return [secondResult, SLOT_B]
end function

function open(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  file = file_api.openReadWrite(path, false)
  lockResult = try(file_lock.acquireExclusive(file, true))
  if typeof(lockResult) == "error" then
    file_api.close(file)
    return lockResult
  end if
  actualSize = file_api.size(file)
  if actualSize < DATA_OFFSET then
    file_api.close(file)
    return fail(CORRUPT_DATA, "open", "file is shorter than the metadata region")
  end if

  first = try(readSlot(file, SLOT_A))
  second = try(readSlot(file, SLOT_B))
  selected = try(chooseMetadata(first, second))
  if typeof(selected) == "error" then
    file_api.close(file)
    return selected
  end if
  metadata = selected[0]
  activeSlot = selected[1]
  requiredSize = committedSize(metadata.pageSize, metadata.pageCount)
  if actualSize < requiredSize then
    file_api.close(file)
    return fail(CORRUPT_DATA, "open", "file is shorter than committed page count")
  end if
  if actualSize > requiredSize then
    // Data written before an interrupted metadata publication is uncommitted tail.
    file_api.truncate(file, requiredSize)
    file_api.flush(file)
  end if

  return PagedFile(
    path,
    file,
    metadata.pageSize,
    metadata.fileType,
    metadata.fileId,
    bytes(metadata.databaseId),
    metadata.pageCount,
    metadata.generation,
    activeSlot,
    metadata.featureFlags,
    false
  )
end function

function validatePageIdentity(pagedFile, pageBytes, expectedPageNumber, operation)
  validateOpen(pagedFile, operation)
  if typeof(pageBytes) != "bytes" or len(pageBytes) != pagedFile.pageSize then
    return fail(INVALID_ARGUMENT, operation, "page buffer has the wrong size")
  end if
  header = page.verify(pageBytes)
  if header.pageId.fileId != pagedFile.fileId then
    return fail(CORRUPT_DATA, operation, "page belongs to another file")
  end if
  if header.pageId.pageNumber != expectedPageNumber then
    return fail(CORRUPT_DATA, operation, "page number mismatch")
  end if
  return header
end function

function readPage(pagedFile, pageNumber)
  validateOpen(pagedFile, "readPage")
  validateNativeId(pageNumber, "readPage", "pageNumber")
  if pageNumber >= pagedFile.pageCount then return fail(INVALID_ARGUMENT, "readPage", "page number is outside the file") end if
  output = bytes(pagedFile.pageSize, 0)
  file_api.readExactAt(pagedFile.file, pageOffset(pagedFile, pageNumber), output, 0, len(output))
  validatePageIdentity(pagedFile, output, pageNumber, "readPage")
  return output
end function

function appendPage(pagedFile, pageBytes)
  validateOpen(pagedFile, "appendPage")
  pageNumber = pagedFile.pageCount
  validatePageIdentity(pagedFile, pageBytes, pageNumber, "appendPage")
  file_api.writeAt(pagedFile.file, pageOffset(pagedFile, pageNumber), pageBytes, 0, len(pageBytes))
  // The page reaches stable storage before either metadata copy advertises it.
  file_api.flush(pagedFile.file)
  commitMetadata(pagedFile, pageNumber + 1)
  return pageNumber
end function

function allocatePage(pagedFile, pageType)
  validateOpen(pagedFile, "allocatePage")
  pageNumber = pagedFile.pageCount
  pageBytes = page.create(pagedFile.pageSize, pageType, pagedFile.fileId, pageNumber)
  appendPage(pagedFile, pageBytes)
  return pageNumber
end function

function writePage(pagedFile, pageNumber, pageBytes)
  validateOpen(pagedFile, "writePage")
  validateNativeId(pageNumber, "writePage", "pageNumber")
  if pageNumber >= pagedFile.pageCount then return fail(INVALID_ARGUMENT, "writePage", "page number is outside the file") end if
  validatePageIdentity(pagedFile, pageBytes, pageNumber, "writePage")
  file_api.writeAt(pagedFile.file, pageOffset(pagedFile, pageNumber), pageBytes, 0, len(pageBytes))
  return true
end function

function flush(pagedFile)
  validateOpen(pagedFile, "flush")
  return file_api.flush(pagedFile.file)
end function

function close(pagedFile)
  validateOpen(pagedFile, "close")
  file_api.flush(pagedFile.file)
  file_api.close(pagedFile.file)
  pagedFile.closed = true
  return true
end function

// Flush and return a byte-for-byte image through the handle that already owns
// the exclusive file lock. Opening the same path through a second handle would
// make Windows reject overlapping reads with ERROR_LOCK_VIOLATION (33).
// Transactional DDL uses this to capture durable before-images without
// weakening the paged-file single-owner lock contract.
function snapshotDurableBytes(pagedFile, maxBytes)
  validateOpen(pagedFile, "snapshotDurableBytes")
  if typeof(maxBytes) != "int" or maxBytes < 0 or maxBytes > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "snapshotDurableBytes", "maxBytes must be a non-negative native MiniLang int")
  end if
  file_api.flush(pagedFile.file)
  length = file_api.size(pagedFile.file)
  if length > maxBytes then
    return fail(CORRUPT_DATA, "snapshotDurableBytes", "paged-file image exceeds safety limit")
  end if
  output = bytes(length, 0)
  if length > 0 then
    file_api.readExactAt(pagedFile.file, 0, output, 0, length)
  end if
  return output
end function

function componentName()
  return "storage.paged_file"
end function

function targetMilestone()
  return "M4"
end function

function isImplemented()
  return true
end function
