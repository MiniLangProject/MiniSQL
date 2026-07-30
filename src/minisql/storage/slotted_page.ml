package minisql.storage.slotted_page

import minisql.common.endian as endian
import minisql.storage.page as page

// Slotted-page format v1. The slot directory grows from the beginning of the
// payload while record bodies grow backwards from the end of the page. Slot
// indices remain stable across compaction. A 16-bit generation protects RowId
// values against delete/reuse aliasing.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const PAGE_FULL = 9015
const ROW_NOT_FOUND = 9016
const STALE_REFERENCE = 9018

const SLOT_SIZE = 8
const SLOT_FLAG_LIVE = 0
const SLOT_FLAG_DELETED = 1
const SLOT_FLAG_FORWARD_ROOT = 2
const SLOT_FLAG_FORWARD_INTERNAL = 3
const SLOT_FLAG_MOVED = 4

struct SlotEntry
  dataOffset
  dataLength
  flags
  generation
end struct

function fail(code, operation, message)
  return error(code, "storage.slotted_page." + operation + ": " + message)
end function

function create(pageSize, fileId, pageNumber)
  return page.create(pageSize, page.TYPE_HEAP, fileId, pageNumber)
end function

function slotOffset(slotId)
  return page.HEADER_SIZE + slotId * SLOT_SIZE
end function

function validFlags(flags)
  return flags == SLOT_FLAG_LIVE or flags == SLOT_FLAG_DELETED or flags == SLOT_FLAG_FORWARD_ROOT or flags == SLOT_FLAG_FORWARD_INTERNAL or flags == SLOT_FLAG_MOVED
end function

function nextGeneration(generation)
  if typeof(generation) != "int" or generation < 0 or generation > 65535 then return fail(CORRUPT_DATA, "nextGeneration", "generation is outside U16") end if
  // Generation values never wrap. A slot deleted at generation 65535 is
  // permanently retired and findDeleted() will not reuse it. This prevents an
  // ancient RowId from becoming valid again after 65535 reuse cycles.
  if generation >= 65535 then return 65535 end if
  return generation + 1
end function

function rawEntry(pageBytes, slotId)
  offset = slotOffset(slotId)
  return SlotEntry(
    endian.readU16LE(pageBytes, offset),
    endian.readU16LE(pageBytes, offset + 2),
    endian.readU16LE(pageBytes, offset + 4),
    endian.readU16LE(pageBytes, offset + 6)
  )
end function

function writeEntry(pageBytes, slotId, entry)
  if entry is not SlotEntry then return fail(INVALID_ARGUMENT, "writeEntry", "entry must be SlotEntry") end if
  offset = slotOffset(slotId)
  endian.writeU16LE(pageBytes, offset, entry.dataOffset)
  endian.writeU16LE(pageBytes, offset + 2, entry.dataLength)
  endian.writeU16LE(pageBytes, offset + 4, entry.flags)
  endian.writeU16LE(pageBytes, offset + 6, entry.generation)
  return true
end function

function validateSlot(header, slotId, operation)
  if typeof(slotId) != "int" or slotId < 0 or slotId >= header.itemCount then
    return fail(ROW_NOT_FOUND, operation, "slot does not exist")
  end if
  return true
end function

function validate(pageBytes, operation)
  header = page.verify(pageBytes)
  if header.pageType != page.TYPE_HEAP and header.pageType != page.TYPE_CATALOG then
    return fail(CORRUPT_DATA, operation, "page is not a slotted heap/catalog page")
  end if
  expectedFreeStart = page.HEADER_SIZE + header.itemCount * SLOT_SIZE
  if header.freeStart != expectedFreeStart then return fail(CORRUPT_DATA, operation, "slot directory length mismatch") end if
  if header.freeStart > header.freeEnd then return fail(CORRUPT_DATA, operation, "slot directory overlaps record data") end if

  occupied = bytes(len(pageBytes), 0)
  usedBytes = 0
  if header.itemCount > 0 then
    for slotId = 0 to header.itemCount - 1
      entry = rawEntry(pageBytes, slotId)
      if not validFlags(entry.flags) then return fail(CORRUPT_DATA, operation, "unknown slot flags") end if
      if entry.generation == 0 then return fail(CORRUPT_DATA, operation, "slot generation zero is invalid") end if
      if entry.flags == SLOT_FLAG_DELETED then
        if entry.dataOffset != 0 or entry.dataLength != 0 then return fail(CORRUPT_DATA, operation, "deleted slot still references data") end if
      else
        if entry.dataLength == 0 then return fail(CORRUPT_DATA, operation, "live slot has zero length") end if
        if entry.dataOffset < header.freeEnd or entry.dataOffset > len(pageBytes) or entry.dataLength > len(pageBytes) - entry.dataOffset then
          return fail(CORRUPT_DATA, operation, "slot data range is invalid")
        end if
        usedBytes = usedBytes + entry.dataLength
        for byteIndex = entry.dataOffset to entry.dataOffset + entry.dataLength - 1
          if occupied[byteIndex] != 0 then return fail(CORRUPT_DATA, operation, "slot data ranges overlap") end if
          occupied[byteIndex] = 1
        end for
      end if
    end for
  end if
  if usedBytes != len(pageBytes) - header.freeEnd then return fail(CORRUPT_DATA, operation, "record area is not compact") end if
  return header
end function

function slotCount(pageBytes)
  return validate(pageBytes, "slotCount").itemCount
end function

function liveSlotCount(pageBytes)
  header = validate(pageBytes, "liveSlotCount")
  count = 0
  if header.itemCount > 0 then
    for slotId = 0 to header.itemCount - 1
      if rawEntry(pageBytes, slotId).flags != SLOT_FLAG_DELETED then count = count + 1 end if
    end for
  end if
  return count
end function

function entry(pageBytes, slotId)
  header = validate(pageBytes, "entry")
  validateSlot(header, slotId, "entry")
  return rawEntry(pageBytes, slotId)
end function

function entryFlags(pageBytes, slotId)
  return entry(pageBytes, slotId).flags
end function

function entryGeneration(pageBytes, slotId)
  return entry(pageBytes, slotId).generation
end function

function isDeleted(pageBytes, slotId)
  return entryFlags(pageBytes, slotId) == SLOT_FLAG_DELETED
end function

function read(pageBytes, slotId)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "read", "slot is deleted") end if
  return slice(pageBytes, current.dataOffset, current.dataLength)
end function

function readGeneration(pageBytes, slotId, generation)
  if typeof(generation) != "int" or generation <= 0 or generation > 65535 then return fail(INVALID_ARGUMENT, "readGeneration", "generation must be a positive U16") end if
  current = entry(pageBytes, slotId)
  if current.generation != generation then return fail(STALE_REFERENCE, "readGeneration", "slot generation changed") end if
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "readGeneration", "slot is deleted") end if
  return slice(pageBytes, current.dataOffset, current.dataLength)
end function

function freeBytes(pageBytes)
  header = validate(pageBytes, "freeBytes")
  return header.freeEnd - header.freeStart
end function

function findDeleted(pageBytes, header)
  if header.itemCount == 0 then return -1 end if
  for slotId = 0 to header.itemCount - 1
    current = rawEntry(pageBytes, slotId)
    // Generation 65535 is saturated. Reusing that slot would require wrapping
    // to an older generation and could make a stale RowId alias new data.
    if current.flags == SLOT_FLAG_DELETED and current.generation < 65535 then return slotId end if
  end for
  return -1
end function

// Rebuilds a compact copy. replacementSlot=-1 means pure compaction. Mutation
// of pageBytes happens only after the complete replacement page was validated.
function rebuild(pageBytes, replacementSlot, replacement, replacementFlags, deleteReplacement)
  header = validate(pageBytes, "rebuild")
  if typeof(replacementSlot) != "int" or replacementSlot < -1 or replacementSlot >= header.itemCount then return fail(INVALID_ARGUMENT, "rebuild", "invalid replacement slot") end if
  if typeof(deleteReplacement) != "bool" then return fail(INVALID_ARGUMENT, "rebuild", "deleteReplacement must be bool") end if
  if replacementSlot >= 0 and not deleteReplacement then
    if typeof(replacement) != "bytes" or len(replacement) == 0 or len(replacement) > 65535 then return fail(INVALID_ARGUMENT, "rebuild", "replacement must contain 1..65535 bytes") end if
    if not validFlags(replacementFlags) or replacementFlags == SLOT_FLAG_DELETED then return fail(INVALID_ARGUMENT, "rebuild", "invalid replacement flags") end if
  end if

  output = page.create(len(pageBytes), header.pageType, header.pageId.fileId, header.pageId.pageNumber)
  outputHeader = page.decodePageHeader(output)
  outputHeader.flags = header.flags
  outputHeader.pageLsn = header.pageLsn
  outputHeader.generation = header.generation
  outputHeader.itemCount = header.itemCount
  outputHeader.freeStart = page.HEADER_SIZE + header.itemCount * SLOT_SIZE
  cursor = len(pageBytes)

  if header.itemCount > 0 then
    for slotId = 0 to header.itemCount - 1
      oldEntry = rawEntry(pageBytes, slotId)
      deleted = oldEntry.flags == SLOT_FLAG_DELETED
      data = bytes()
      flags = oldEntry.flags
      generation = oldEntry.generation
      if slotId == replacementSlot then
        deleted = deleteReplacement
        if deleted then
          generation = nextGeneration(generation)
          flags = SLOT_FLAG_DELETED
        else
          data = replacement
          flags = replacementFlags
        end if
      else if not deleted then
        data = slice(pageBytes, oldEntry.dataOffset, oldEntry.dataLength)
      end if

      if deleted then
        writeEntry(output, slotId, SlotEntry(0, 0, SLOT_FLAG_DELETED, generation))
      else
        cursor = cursor - len(data)
        if cursor < outputHeader.freeStart then return fail(PAGE_FULL, "rebuild", "records do not fit in page") end if
        copyBytes(output, cursor, data, 0, len(data))
        writeEntry(output, slotId, SlotEntry(cursor, len(data), flags, generation))
      end if
    end for
  end if
  outputHeader.freeEnd = cursor
  page.seal(output, outputHeader)
  validate(output, "rebuild.output")
  copyBytes(pageBytes, 0, output, 0, len(output))
  return outputHeader
end function

function compact(pageBytes)
  return rebuild(pageBytes, -1, bytes(), SLOT_FLAG_LIVE, false)
end function

function insertWithFlags(pageBytes, recordBytes, slotFlags)
  validate(pageBytes, "insertWithFlags")
  if typeof(recordBytes) != "bytes" or len(recordBytes) == 0 or len(recordBytes) > 65535 then return fail(INVALID_ARGUMENT, "insertWithFlags", "record must contain 1..65535 bytes") end if
  if not validFlags(slotFlags) or slotFlags == SLOT_FLAG_DELETED then return fail(INVALID_ARGUMENT, "insertWithFlags", "invalid slot flags") end if

  working = bytes(pageBytes)
  compact(working)
  header = page.decodePageHeader(working)
  reusable = findDeleted(working, header)
  directoryBytes = SLOT_SIZE
  if reusable >= 0 then directoryBytes = 0 end if
  if len(recordBytes) + directoryBytes > header.freeEnd - header.freeStart then return fail(PAGE_FULL, "insertWithFlags", "record does not fit") end if

  slotId = reusable
  generation = 1
  if reusable < 0 then
    slotId = header.itemCount
    header.itemCount = header.itemCount + 1
    header.freeStart = header.freeStart + SLOT_SIZE
  else
    generation = rawEntry(working, slotId).generation
  end if
  dataOffset = header.freeEnd - len(recordBytes)
  copyBytes(working, dataOffset, recordBytes, 0, len(recordBytes))
  writeEntry(working, slotId, SlotEntry(dataOffset, len(recordBytes), slotFlags, generation))
  header.freeEnd = dataOffset
  page.seal(working, header)
  validate(working, "insertWithFlags.output")
  copyBytes(pageBytes, 0, working, 0, len(working))
  return slotId
end function

function insert(pageBytes, recordBytes)
  return insertWithFlags(pageBytes, recordBytes, SLOT_FLAG_LIVE)
end function

function updateWithFlags(pageBytes, slotId, recordBytes, slotFlags)
  header = validate(pageBytes, "updateWithFlags")
  validateSlot(header, slotId, "updateWithFlags")
  if typeof(recordBytes) != "bytes" or len(recordBytes) == 0 or len(recordBytes) > 65535 then return fail(INVALID_ARGUMENT, "updateWithFlags", "record must contain 1..65535 bytes") end if
  if not validFlags(slotFlags) or slotFlags == SLOT_FLAG_DELETED then return fail(INVALID_ARGUMENT, "updateWithFlags", "invalid slot flags") end if
  current = rawEntry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "updateWithFlags", "slot is deleted") end if
  working = bytes(pageBytes)
  rebuild(working, slotId, recordBytes, slotFlags, false)
  copyBytes(pageBytes, 0, working, 0, len(working))
  return true
end function

function update(pageBytes, slotId, recordBytes)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "update", "slot is deleted") end if
  return updateWithFlags(pageBytes, slotId, recordBytes, current.flags)
end function

function setFlags(pageBytes, slotId, slotFlags)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "setFlags", "slot is deleted") end if
  return updateWithFlags(pageBytes, slotId, read(pageBytes, slotId), slotFlags)
end function

function remove(pageBytes, slotId)
  header = validate(pageBytes, "remove")
  validateSlot(header, slotId, "remove")
  current = rawEntry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "remove", "slot is already deleted") end if
  working = bytes(pageBytes)
  rebuild(working, slotId, bytes(), SLOT_FLAG_DELETED, true)
  copyBytes(pageBytes, 0, working, 0, len(working))
  return true
end function

function componentName()
  return "storage.slotted_page"
end function

function targetMilestone()
  return "M9"
end function

function isImplemented()
  return true
end function
