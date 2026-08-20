package minisql.storage.heap_file
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.slotted_page as slotted
import minisql.storage.superblock as superblock

// Heap-file storage built on stable slotted pages. External RowId values contain
// the slot generation, so a deleted and later reused slot cannot alias an older
// row. Growing updates preserve the original RowId through forwarding records.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const ROW_NOT_FOUND = 9016
const STALE_REFERENCE = 9018

const FORWARD_SIZE = 24
const MAX_FORWARD_DEPTH = 64

// Defines the row id record used by this module.
struct RowId
  // Page number field of the row id.
  pageNumber
  // Slot id field of the row id.
  slotId
  // Generation field of the row id.
  generation
end struct

// Defines the heap row record used by this module.
struct HeapRow
  // Identifier field of the heap row.
  identifier
  // Value field of the heap row.
  value
end struct

// Defines the resolved row record used by this module.
struct ResolvedRow
  // Leaf field of the resolved row.
  leaf
  // Value field of the resolved row.
  value
  // Flags field of the resolved row.
  flags
  // Chain field of the resolved row.
  chain
end struct

// Defines the heap file record used by this module.
struct HeapFile
  // Paged file field of the heap file.
  pagedFile
  // Closed field of the heap file.
  closed
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "storage.heap_file." + operation + ": " + message)
end function

// Performs the forwarding magic operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function forwardingMagic()
  return bytes("MSFW")
end function

// Performs the bytes equal operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

// Performs the row id operation for this module.
// Inputs: `pageNumber`, `slotId`, `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function rowId(pageNumber, slotId, generation)
  if typeof(pageNumber) != "int" or pageNumber < 0 or pageNumber > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "rowId", "pageNumber must be non-negative") end if
  if typeof(slotId) != "int" or slotId < 0 or slotId > 65535 then return fail(INVALID_ARGUMENT, "rowId", "slotId must fit U16") end if
  if typeof(generation) != "int" or generation <= 0 or generation > 65535 then return fail(INVALID_ARGUMENT, "rowId", "generation must be a positive U16") end if
  return RowId(pageNumber, slotId, generation)
end function

// Compares the row id.
// Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function sameRowId(left, right)
  if left is not RowId or right is not RowId then return false end if
  return left.pageNumber == right.pageNumber and left.slotId == right.slotId and left.generation == right.generation
end function

// Performs the contains row id operation for this module.
// Inputs: `values`, `sought`. Returns the produced value or propagates a structured error from validation or delegated operations.
function containsRowId(values, sought)
  for each value in values
    if sameRowId(value, sought) then return true end if
  end for
  return false
end function

// Encodes the forward.
// Inputs: `target`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodeForward(target)
  if target is not RowId then return fail(INVALID_ARGUMENT, "encodeForward", "target must be RowId") end if
  checked = rowId(target.pageNumber, target.slotId, target.generation)
  output = bytes(FORWARD_SIZE, 0)
  copyBytes(output, 0, forwardingMagic(), 0, 4)
  endian.writeU16LE(output, 4, 1)
  endian.writeU16LE(output, 6, 0)
  endian.writeU64LE(output, 8, endian.uint64FromInt(checked.pageNumber))
  endian.writeU32LE(output, 16, checked.slotId)
  endian.writeU16LE(output, 20, checked.generation)
  endian.writeU16LE(output, 22, 0)
  return output
end function

// Decodes the forward.
// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeForward(value)
  if typeof(value) != "bytes" or len(value) != FORWARD_SIZE then return fail(CORRUPT_DATA, "decodeForward", "forwarding record has the wrong size") end if
  if not bytesEqual(slice(value, 0, 4), forwardingMagic()) then return fail(CORRUPT_DATA, "decodeForward", "forwarding magic mismatch") end if
  if endian.readU16LE(value, 4) != 1 or endian.readU16LE(value, 6) != 0 or endian.readU16LE(value, 22) != 0 then return fail(CORRUPT_DATA, "decodeForward", "unsupported forwarding format") end if
  pageWords = endian.readU64LE(value, 8)
  if pageWords.high > endian.MAX_SCALAR_HIGH then return fail(CORRUPT_DATA, "decodeForward", "forward page exceeds native range") end if
  return rowId(endian.uint64ToInt(pageWords), endian.readU32LE(value, 16), endian.readU16LE(value, 20))
end function

// Creates the requested value.
// Inputs: `path`, `pageSize`, `fileId`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function create(path, pageSize, fileId, databaseId)
  file = paged_file.create(path, pageSize, superblock.FILE_TYPE_TABLE, fileId, databaseId)
  return HeapFile(file, false)
end function

// Opens the requested value.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function open(path)
  file = paged_file.open(path)
  if file.fileType != superblock.FILE_TYPE_TABLE then paged_file.close(file); return fail(CORRUPT_DATA, "open", "file is not a table") end if
  return HeapFile(file, false)
end function

// Validates the open.
// Inputs: `heap`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateOpen(heap, operation)
  if heap is not HeapFile then return fail(INVALID_ARGUMENT, operation, "heap must be HeapFile") end if
  if heap.closed then return fail(CLOSED_HANDLE, operation, "heap is closed") end if
  paged_file.validateOpen(heap.pagedFile, "heap_file." + operation)
  return true
end function

// Validates the identifier.
// Inputs: `identifier`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateIdentifier(identifier, operation)
  if identifier is not RowId then return fail(INVALID_ARGUMENT, operation, "identifier must be RowId") end if
  rowId(identifier.pageNumber, identifier.slotId, identifier.generation)
  return true
end function

// Loads the slot.
// Inputs: `heap`, `identifier`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function loadSlot(heap, identifier, operation)
  validateIdentifier(identifier, operation)
  if identifier.pageNumber >= heap.pagedFile.pageCount then return fail(ROW_NOT_FOUND, operation, "page does not exist") end if
  pageBytes = paged_file.readPage(heap.pagedFile, identifier.pageNumber)
  current = try(slotted.entry(pageBytes, identifier.slotId))
  if typeof(current) == "error" then return current end if
  if current.flags == slotted.SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, operation, "row is deleted") end if
  if current.generation != identifier.generation then return fail(STALE_REFERENCE, operation, "RowId generation is stale") end if
  value = slotted.readGeneration(pageBytes, identifier.slotId, identifier.generation)
  return [pageBytes, current, value]
end function

// Performs the resolve operation for this module.
// Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.
function resolve(heap, identifier)
  validateOpen(heap, "resolve")
  validateIdentifier(identifier, "resolve")
  currentId = identifier
  chain = []
  depth = 0
  while true
    if depth >= MAX_FORWARD_DEPTH then return fail(CORRUPT_DATA, "resolve", "forwarding chain exceeds limit") end if
    if containsRowId(chain, currentId) then return fail(CORRUPT_DATA, "resolve", "forwarding chain contains a cycle") end if
    chain = chain + [currentId]
    loaded = loadSlot(heap, currentId, "resolve")
    current = loaded[1]
    value = loaded[2]
    if current.flags == slotted.SLOT_FLAG_FORWARD_ROOT or current.flags == slotted.SLOT_FLAG_FORWARD_INTERNAL then
      currentId = decodeForward(value)
    else if current.flags == slotted.SLOT_FLAG_LIVE or current.flags == slotted.SLOT_FLAG_MOVED then
      return ResolvedRow(currentId, value, current.flags, chain)
    else
      return fail(CORRUPT_DATA, "resolve", "unexpected slot state")
    end if
    depth = depth + 1
  end while
end function

// Inserts the with flags.
// Inputs: `heap`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.
function insertWithFlags(heap, recordBytes, slotFlags)
  validateOpen(heap, "insertWithFlags")
  if typeof(recordBytes) != "bytes" or len(recordBytes) == 0 then return fail(INVALID_ARGUMENT, "insertWithFlags", "record must be non-empty bytes") end if
  if slotFlags != slotted.SLOT_FLAG_LIVE and slotFlags != slotted.SLOT_FLAG_MOVED then return fail(INVALID_ARGUMENT, "insertWithFlags", "heap insertion requires live or moved state") end if

  if heap.pagedFile.pageCount > 0 then
    for pageNumber = 0 to heap.pagedFile.pageCount - 1
      pageBytes = paged_file.readPage(heap.pagedFile, pageNumber)
      header = page.verify(pageBytes)
      if header.pageType != page.TYPE_HEAP then continue end if
      inserted = try(slotted.insertWithFlags(pageBytes, recordBytes, slotFlags))
      if typeof(inserted) != "error" then
        generation = slotted.entryGeneration(pageBytes, inserted)
        paged_file.writePage(heap.pagedFile, pageNumber, pageBytes)
        paged_file.flush(heap.pagedFile)
        return rowId(pageNumber, inserted, generation)
      end if
      if inserted.code != slotted.PAGE_FULL then return inserted end if
    end for
  end if

  pageNumber = heap.pagedFile.pageCount
  pageBytes = slotted.create(heap.pagedFile.pageSize, heap.pagedFile.fileId, pageNumber)
  slotId = slotted.insertWithFlags(pageBytes, recordBytes, slotFlags)
  generation = slotted.entryGeneration(pageBytes, slotId)
  paged_file.appendPage(heap.pagedFile, pageBytes)
  return rowId(pageNumber, slotId, generation)
end function

// Inserts the requested value.
// Inputs: `heap`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function insert(heap, recordBytes)
  return insertWithFlags(heap, recordBytes, slotted.SLOT_FLAG_LIVE)
end function

// Reads the requested value.
// Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.
function read(heap, identifier)
  return resolve(heap, identifier).value
end function

// Updates the requested value.
// Inputs: `heap`, `identifier`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function update(heap, identifier, recordBytes)
  validateOpen(heap, "update")
  validateIdentifier(identifier, "update")
  if typeof(recordBytes) != "bytes" or len(recordBytes) == 0 then return fail(INVALID_ARGUMENT, "update", "record must be non-empty bytes") end if
  resolved = resolve(heap, identifier)
  leaf = resolved.leaf
  loaded = loadSlot(heap, leaf, "update")
  pageBytes = loaded[0]
  current = loaded[1]
  direct = try(slotted.updateWithFlags(pageBytes, leaf.slotId, recordBytes, current.flags))
  if typeof(direct) != "error" then
    paged_file.writePage(heap.pagedFile, leaf.pageNumber, pageBytes)
    paged_file.flush(heap.pagedFile)
    return identifier
  end if
  if direct.code != slotted.PAGE_FULL then return direct end if

  // Publish the new copy before replacing the old record with a forwarding
  // pointer. A crash before pointer publication can leak the new copy but cannot
  // lose the old row.
  newId = insertWithFlags(heap, recordBytes, slotted.SLOT_FLAG_MOVED)
  pageBytes = paged_file.readPage(heap.pagedFile, leaf.pageNumber)
  current = slotted.entry(pageBytes, leaf.slotId)
  if current.generation != leaf.generation then return fail(STALE_REFERENCE, "update", "leaf generation changed during update") end if
  forwardingFlags = slotted.SLOT_FLAG_FORWARD_INTERNAL
  if len(resolved.chain) == 1 and current.flags == slotted.SLOT_FLAG_LIVE then forwardingFlags = slotted.SLOT_FLAG_FORWARD_ROOT end if
  slotted.updateWithFlags(pageBytes, leaf.slotId, encodeForward(newId), forwardingFlags)
  paged_file.writePage(heap.pagedFile, leaf.pageNumber, pageBytes)
  paged_file.flush(heap.pagedFile)
  return identifier
end function

// Removes the requested value.
// Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.
function remove(heap, identifier)
  validateOpen(heap, "remove")
  validateIdentifier(identifier, "remove")
  resolved = resolve(heap, identifier)

  // Delete the externally visible root first. If a crash occurs while cleaning
  // internal/moved records, the remaining pages are unreachable leaks rather
  // than a dangling visible RowId.
  chain = resolved.chain
  if len(chain) > 0 then
    rootId = chain[0]
    rootPage = paged_file.readPage(heap.pagedFile, rootId.pageNumber)
    rootEntry = slotted.entry(rootPage, rootId.slotId)
    if rootEntry.generation != rootId.generation or rootEntry.flags == slotted.SLOT_FLAG_DELETED then return fail(STALE_REFERENCE, "remove", "root changed during delete") end if
    slotted.remove(rootPage, rootId.slotId)
    paged_file.writePage(heap.pagedFile, rootId.pageNumber, rootPage)
    // Make the externally visible deletion durable before reclaiming internal
    // forwarding/moved records. A crash can then leak only unreachable storage.
    paged_file.flush(heap.pagedFile)

    if len(chain) > 1 then
      for index = 1 to len(chain) - 1
        currentId = chain[index]
        pageBytes = paged_file.readPage(heap.pagedFile, currentId.pageNumber)
        current = slotted.entry(pageBytes, currentId.slotId)
        if current.generation == currentId.generation and current.flags != slotted.SLOT_FLAG_DELETED then
          slotted.remove(pageBytes, currentId.slotId)
          paged_file.writePage(heap.pagedFile, currentId.pageNumber, pageBytes)
        end if
      end for
      paged_file.flush(heap.pagedFile)
    end if
  end if
  return true
end function

// Scans the requested value.
// Inputs: `heap`. Returns the produced value or propagates a structured error from validation or delegated operations.
function scan(heap)
  validateOpen(heap, "scan")
  rows = []
  if heap.pagedFile.pageCount == 0 then return rows end if
  for pageNumber = 0 to heap.pagedFile.pageCount - 1
    pageBytes = paged_file.readPage(heap.pagedFile, pageNumber)
    header = page.verify(pageBytes)
    if header.pageType != page.TYPE_HEAP then continue end if
    count = slotted.slotCount(pageBytes)
    if count > 0 then
      for slotId = 0 to count - 1
        current = slotted.entry(pageBytes, slotId)
        if current.flags == slotted.SLOT_FLAG_LIVE or current.flags == slotted.SLOT_FLAG_FORWARD_ROOT then
          identifier = rowId(pageNumber, slotId, current.generation)
          rows = rows + [HeapRow(identifier, read(heap, identifier))]
        end if
      end for
    end if
  end for
  return rows
end function

// Counts the requested value.
// Inputs: `heap`. Returns the produced value or propagates a structured error from validation or delegated operations.
function count(heap)
  return len(scan(heap))
end function

// Closes the requested value.
// Inputs: `heap`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(heap)
  validateOpen(heap, "close")
  paged_file.close(heap.pagedFile)
  heap.closed = true
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "storage.heap_file"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M9"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
