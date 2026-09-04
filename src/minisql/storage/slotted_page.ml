//! Provides minisql storage slotted page facilities for this project.

package minisql.storage.slotted_page
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.storage.page as page

/// Slotted-page format v1. The slot directory grows from the beginning of the

const INVALID_ARGUMENT = 9001
/// Defines the corrupt data constant used by the minisql storage slotted page module.
const CORRUPT_DATA = 9004
/// Defines the page full constant used by the minisql storage slotted page module.
const PAGE_FULL = 9015
/// Defines the row not found constant used by the minisql storage slotted page module.
const ROW_NOT_FOUND = 9016
/// Defines the stale reference constant used by the minisql storage slotted page module.
const STALE_REFERENCE = 9018

/// Defines the slot size constant used by the minisql storage slotted page module.
const SLOT_SIZE = 8
/// Defines the slot flag live constant used by the minisql storage slotted page module.
const SLOT_FLAG_LIVE = 0
/// Defines the slot flag deleted constant used by the minisql storage slotted page module.
const SLOT_FLAG_DELETED = 1
/// Defines the slot flag forward root constant used by the minisql storage slotted page module.
const SLOT_FLAG_FORWARD_ROOT = 2
/// Defines the slot flag forward internal constant used by the minisql storage slotted page module.
const SLOT_FLAG_FORWARD_INTERNAL = 3
/// Defines the slot flag moved constant used by the minisql storage slotted page module.
const SLOT_FLAG_MOVED = 4

/// Defines the slot entry record used by this module.
struct SlotEntry
  /// Data offset field of the slot entry.
  dataOffset
  /// Data length field of the slot entry.
  dataLength
  /// Flags field of the slot entry.
  flags
  /// Generation field of the slot entry.
  generation
end struct

/// Performs the fail operation for the minisql storage slotted page module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "storage.slotted_page." + operation + ": " + message)
end function

/// Creates create for the minisql storage slotted page module.
/// Inputs: `pageSize`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageSize pageSize value consumed by this operation.
/// @param fileId Identifier of file.
/// @param pageNumber pageNumber value consumed by this operation.
function create(pageSize, fileId, pageNumber)
  return page.create(pageSize, page.TYPE_HEAP, fileId, pageNumber)
end function

/// Performs the slotOffset operation for the minisql storage slotted page module.
/// Inputs: `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param slotId Identifier of slot.
function slotOffset(slotId)
  return page.HEADER_SIZE + slotId * SLOT_SIZE
end function

/// Performs the valid flags operation for this module.
/// Inputs: `flags`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param flags Bit flags controlling the operation.
function validFlags(flags)
  return flags == SLOT_FLAG_LIVE or flags == SLOT_FLAG_DELETED or flags == SLOT_FLAG_FORWARD_ROOT or flags == SLOT_FLAG_FORWARD_INTERNAL or flags == SLOT_FLAG_MOVED
end function

/// Performs the next generation operation for this module.
/// Inputs: `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param generation generation value consumed by this operation.
function nextGeneration(generation)
  if typeof(generation) != "int" or generation < 0 or generation > 65535 then return fail(CORRUPT_DATA, "nextGeneration", "generation is outside U16") end if
  // Generation values never wrap. A slot deleted at generation 65535 is
  // permanently retired and findDeleted() will not reuse it. This prevents an
  // ancient RowId from becoming valid again after 65535 reuse cycles.
  if generation >= 65535 then return 65535 end if
  return generation + 1
end function

/// Performs the raw entry operation for this module.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function rawEntry(pageBytes, slotId)
  offset = slotOffset(slotId)
  return SlotEntry(
    endian.readU16LE(pageBytes, offset),
    endian.readU16LE(pageBytes, offset + 2),
    endian.readU16LE(pageBytes, offset + 4),
    endian.readU16LE(pageBytes, offset + 6)
  )
end function

/// Writes the entry.
/// Inputs: `pageBytes`, `slotId`, `entry`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param entry entry value consumed by this operation.
function writeEntry(pageBytes, slotId, entry)
  if entry is not SlotEntry then return fail(INVALID_ARGUMENT, "writeEntry", "entry must be SlotEntry") end if
  offset = slotOffset(slotId)
  endian.writeU16LE(pageBytes, offset, entry.dataOffset)
  endian.writeU16LE(pageBytes, offset + 2, entry.dataLength)
  endian.writeU16LE(pageBytes, offset + 4, entry.flags)
  endian.writeU16LE(pageBytes, offset + 6, entry.generation)
  return true
end function

/// Validates the slot.
/// Inputs: `header`, `slotId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param header header value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param operation operation value consumed by this operation.
function validateSlot(header, slotId, operation)
  if typeof(slotId) != "int" or slotId < 0 or slotId >= header.itemCount then
    return fail(ROW_NOT_FOUND, operation, "slot does not exist")
  end if
  return true
end function

/// Validates validate for the minisql storage slotted page workflow.
/// Inputs: `pageBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param operation operation value consumed by this operation.
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

/// Performs the slot count operation for this module.
/// Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
function slotCount(pageBytes)
  return validate(pageBytes, "slotCount").itemCount
end function

/// Performs the live slot count operation for this module.
/// Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
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

/// Performs the entry operation for this module.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function entry(pageBytes, slotId)
  header = validate(pageBytes, "entry")
  validateSlot(header, slotId, "entry")
  return rawEntry(pageBytes, slotId)
end function

/// Performs the entry flags operation for this module.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function entryFlags(pageBytes, slotId)
  return entry(pageBytes, slotId).flags
end function

/// Performs the entry generation operation for this module.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function entryGeneration(pageBytes, slotId)
  return entry(pageBytes, slotId).generation
end function

/// Evaluates whether the supplied input satisfies the deleted predicate.
/// Inputs: `pageBytes`, `slotId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function isDeleted(pageBytes, slotId)
  return entryFlags(pageBytes, slotId) == SLOT_FLAG_DELETED
end function

/// Reads read for the minisql storage slotted page workflow.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
function read(pageBytes, slotId)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "read", "slot is deleted") end if
  return slice(pageBytes, current.dataOffset, current.dataLength)
end function

/// Reads the generation.
/// Inputs: `pageBytes`, `slotId`, `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param generation generation value consumed by this operation.
function readGeneration(pageBytes, slotId, generation)
  if typeof(generation) != "int" or generation <= 0 or generation > 65535 then return fail(INVALID_ARGUMENT, "readGeneration", "generation must be a positive U16") end if
  current = entry(pageBytes, slotId)
  if current.generation != generation then return fail(STALE_REFERENCE, "readGeneration", "slot generation changed") end if
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "readGeneration", "slot is deleted") end if
  return slice(pageBytes, current.dataOffset, current.dataLength)
end function

/// Releases the bytes.
/// Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
function freeBytes(pageBytes)
  header = validate(pageBytes, "freeBytes")
  return header.freeEnd - header.freeStart
end function

/// Finds the deleted.
/// Inputs: `pageBytes`, `header`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param header header value consumed by this operation.
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

/// Rebuilds a compact copy. replacementSlot=-1 means pure compaction. Mutation
/// of pageBytes happens only after the complete replacement page was validated.
/// Performs the rebuild operation for this module.
/// Inputs: `pageBytes`, `replacementSlot`, `replacement`, `replacementFlags`, `deleteReplacement`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param replacementSlot replacementSlot value consumed by this operation.
/// @param replacement replacement value consumed by this operation.
/// @param replacementFlags replacementFlags value consumed by this operation.
/// @param deleteReplacement deleteReplacement value consumed by this operation.
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

/// Performs the compact operation for this module.
/// Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
function compact(pageBytes)
  return rebuild(pageBytes, -1, bytes(), SLOT_FLAG_LIVE, false)
end function

/// Inserts the with flags.
/// Inputs: `pageBytes`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param recordBytes recordBytes value consumed by this operation.
/// @param slotFlags slotFlags value consumed by this operation.
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

/// Performs the insert operation for the minisql storage slotted page module.
/// Inputs: `pageBytes`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param recordBytes recordBytes value consumed by this operation.
function insert(pageBytes, recordBytes)
  return insertWithFlags(pageBytes, recordBytes, SLOT_FLAG_LIVE)
end function

/// Updates the with flags.
/// Inputs: `pageBytes`, `slotId`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param recordBytes recordBytes value consumed by this operation.
/// @param slotFlags slotFlags value consumed by this operation.
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

/// Updates the requested value.
/// Inputs: `pageBytes`, `slotId`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param recordBytes recordBytes value consumed by this operation.
function update(pageBytes, slotId, recordBytes)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "update", "slot is deleted") end if
  return updateWithFlags(pageBytes, slotId, recordBytes, current.flags)
end function

/// Updates the flags.
/// Inputs: `pageBytes`, `slotId`, `slotFlags`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
/// @param slotFlags slotFlags value consumed by this operation.
function setFlags(pageBytes, slotId, slotFlags)
  current = entry(pageBytes, slotId)
  if current.flags == SLOT_FLAG_DELETED then return fail(ROW_NOT_FOUND, "setFlags", "slot is deleted") end if
  return updateWithFlags(pageBytes, slotId, read(pageBytes, slotId), slotFlags)
end function

/// Removes remove from the state managed by the minisql storage slotted page module.
/// Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param pageBytes pageBytes value consumed by this operation.
/// @param slotId Identifier of slot.
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

/// Performs the componentName operation for the minisql storage slotted page module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "storage.slotted_page"
end function

/// Performs the targetMilestone operation for the minisql storage slotted page module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M9"
end function

/// Returns whether implemented satisfies the condition required by the minisql storage slotted page module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
