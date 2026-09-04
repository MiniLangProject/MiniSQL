//! Provides minisql transaction checkpoint facilities for this project.

package minisql.transaction.checkpoint
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import minisql.transaction.wal as wal

/// Durable checkpoint metadata and orchestration. A checkpoint flushes dirty

const INVALID_ARGUMENT = 9001
/// Defines the unsupported format constant used by the minisql transaction checkpoint module.
const UNSUPPORTED_FORMAT = 9003
/// Defines the corrupt data constant used by the minisql transaction checkpoint module.
const CORRUPT_DATA = 9004
/// Defines the closed handle constant used by the minisql transaction checkpoint module.
const CLOSED_HANDLE = 9008

/// Defines the format version constant used by the minisql transaction checkpoint module.
const FORMAT_VERSION = 1
/// Defines the slot size constant used by the minisql transaction checkpoint module.
const SLOT_SIZE = 256
/// Defines the slot a constant used by the minisql transaction checkpoint module.
const SLOT_A = 0
/// Defines the slot b constant used by the minisql transaction checkpoint module.
const SLOT_B = 1
/// Defines the slot a offset constant used by the minisql transaction checkpoint module.
const SLOT_A_OFFSET = 0
/// Defines the slot b offset constant used by the minisql transaction checkpoint module.
const SLOT_B_OFFSET = 256
/// Defines the file size constant used by the minisql transaction checkpoint module.
const FILE_SIZE = 512
/// Defines the checksum offset constant used by the minisql transaction checkpoint module.
const CHECKSUM_OFFSET = 64

/// Defines the checkpoint metadata record used by this module.
struct CheckpointMetadata
  /// Generation field of the checkpoint metadata.
  generation
  /// Checkpoint lsn field of the checkpoint metadata.
  checkpointLsn
  /// Redo start lsn field of the checkpoint metadata.
  redoStartLsn
  /// Record count field of the checkpoint metadata.
  recordCount
  /// Database id field of the checkpoint metadata.
  databaseId
end struct

/// Defines the checkpoint file record used by this module.
struct CheckpointFile
  /// Path field of the checkpoint file.
  path
  /// File field of the checkpoint file.
  file
  /// Metadata field of the checkpoint file.
  metadata
  /// Active slot field of the checkpoint file.
  activeSlot
  /// Closed field of the checkpoint file.
  closed
end struct

/// Performs the fail operation for the minisql transaction checkpoint module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "transaction.checkpoint." + operation + ": " + message)
end function

/// Performs the magicBytes operation for the minisql transaction checkpoint module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function magicBytes()
  return bytes("MSQLCKP1")
end function

/// Performs the copyExact operation for the minisql transaction checkpoint module.
/// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param destination destination value consumed by this operation.
/// @param destinationOffset destinationOffset value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param sourceOffset sourceOffset value consumed by this operation.
/// @param count Number of items or units to process.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

/// Performs the bytesEqual operation for the minisql transaction checkpoint module.
/// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

/// Validates native for the minisql transaction checkpoint workflow.
/// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative") end if
  return true
end function

/// Validates database id for the minisql transaction checkpoint workflow.
/// Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param databaseId Identifier of database.
/// @param operation operation value consumed by this operation.
function validateDatabaseId(databaseId, operation)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 then return fail(INVALID_ARGUMENT, operation, "databaseId must be 16 bytes") end if
  return true
end function

/// Decodes native for the minisql transaction checkpoint workflow.
/// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param words words value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function decodeNative(words, operation, name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

/// Performs the new metadata operation for this module.
/// Inputs: `generation`, `checkpointLsn`, `redoStartLsn`, `recordCount`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param generation generation value consumed by this operation.
/// @param checkpointLsn checkpointLsn value consumed by this operation.
/// @param redoStartLsn redoStartLsn value consumed by this operation.
/// @param recordCount Number of record to process.
/// @param databaseId Identifier of database.
function newMetadata(generation, checkpointLsn, redoStartLsn, recordCount, databaseId)
  endian.validateUInt64Words(generation, "transaction.checkpoint.newMetadata.generation")
  validateNative(checkpointLsn, "newMetadata", "checkpointLsn")
  validateNative(redoStartLsn, "newMetadata", "redoStartLsn")
  validateNative(recordCount, "newMetadata", "recordCount")
  if redoStartLsn > checkpointLsn then return fail(INVALID_ARGUMENT, "newMetadata", "redoStartLsn must not exceed checkpointLsn") end if
  validateDatabaseId(databaseId, "newMetadata")
  return CheckpointMetadata(generation, checkpointLsn, redoStartLsn, recordCount, bytes(databaseId))
end function

/// Encodes the slot.
/// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param value Value consumed or transformed by the operation.
function encodeSlot(value)
  if value is not CheckpointMetadata then return fail(INVALID_ARGUMENT, "encodeSlot", "value must be CheckpointMetadata") end if
  newMetadata(value.generation, value.checkpointLsn, value.redoStartLsn, value.recordCount, value.databaseId)
  output = bytes(SLOT_SIZE, 0)
  copyExact(output, 0, magicBytes(), 0, 8)
  endian.writeU16LE(output, 8, FORMAT_VERSION)
  endian.writeU16LE(output, 10, SLOT_SIZE)
  endian.writeU32LE(output, 12, 0)
  endian.writeU64LE(output, 16, value.generation)
  endian.writeU64LE(output, 24, endian.uint64FromInt(value.checkpointLsn))
  endian.writeU64LE(output, 32, endian.uint64FromInt(value.redoStartLsn))
  endian.writeU64LE(output, 40, endian.uint64FromInt(value.recordCount))
  copyExact(output, 48, value.databaseId, 0, 16)
  endian.writeU32LE(output, CHECKSUM_OFFSET, 0)
  checksum = crc32c.compute(output)
  endian.writeU32LE(output, CHECKSUM_OFFSET, checksum)
  return output
end function

/// Decodes the slot.
/// Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param source source value consumed by this operation.
function decodeSlot(source)
  if typeof(source) != "bytes" or len(source) != SLOT_SIZE then return fail(CORRUPT_DATA, "decodeSlot", "slot must be exactly 256 bytes") end if
  if not bytesEqual(slice(source, 0, 8), magicBytes()) then return fail(UNSUPPORTED_FORMAT, "decodeSlot", "slot magic mismatch") end if
  if endian.readU16LE(source, 8) != FORMAT_VERSION or endian.readU16LE(source, 10) != SLOT_SIZE then return fail(UNSUPPORTED_FORMAT, "decodeSlot", "unsupported slot format") end if
  if endian.readU32LE(source, 12) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSlot", "reserved slot field is non-zero") end if
  if SLOT_SIZE > 68 then
    for index = 68 to SLOT_SIZE - 1
      if source[index] != 0 then return fail(UNSUPPORTED_FORMAT, "decodeSlot", "reserved slot tail is non-zero") end if
    end for
  end if
  stored = endian.readU32LE(source, CHECKSUM_OFFSET)
  copy = bytes(source)
  endian.writeU32LE(copy, CHECKSUM_OFFSET, 0)
  if crc32c.compute(copy) != stored then return fail(CORRUPT_DATA, "decodeSlot", "slot checksum mismatch") end if
  generation = endian.readU64LE(source, 16)
  if generation.high == 0 and generation.low == 0 then return fail(CORRUPT_DATA, "decodeSlot", "generation zero is invalid") end if
  return newMetadata(
    generation,
    decodeNative(endian.readU64LE(source, 24), "decodeSlot", "checkpointLsn"),
    decodeNative(endian.readU64LE(source, 32), "decodeSlot", "redoStartLsn"),
    decodeNative(endian.readU64LE(source, 40), "decodeSlot", "recordCount"),
    slice(source, 48, 16)
  )
end function

/// Performs the slotOffset operation for the minisql transaction checkpoint module.
/// Inputs: `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param slot slot value consumed by this operation.
function slotOffset(slot)
  if slot == SLOT_A then return SLOT_A_OFFSET end if
  if slot == SLOT_B then return SLOT_B_OFFSET end if
  return fail(INVALID_ARGUMENT, "slotOffset", "unknown slot")
end function

/// Reads the slot.
/// Inputs: `file`, `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param file file value consumed by this operation.
/// @param slot slot value consumed by this operation.
function readSlot(file, slot)
  data = bytes(SLOT_SIZE, 0)
  file_api.readExactAt(file, slotOffset(slot), data, 0, SLOT_SIZE)
  return decodeSlot(data)
end function

/// Writes the slot.
/// Inputs: `file`, `slot`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param file file value consumed by this operation.
/// @param slot slot value consumed by this operation.
/// @param value Value consumed or transformed by the operation.
function writeSlot(file, slot, value)
  encoded = encodeSlot(value)
  file_api.writeAt(file, slotOffset(slot), encoded, 0, SLOT_SIZE)
  return true
end function

/// Performs the choose operation for this module.
/// Inputs: `firstResult`, `secondResult`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param firstResult firstResult value consumed by this operation.
/// @param secondResult secondResult value consumed by this operation.
function choose(firstResult, secondResult)
  firstOk = typeof(firstResult) != "error"
  secondOk = typeof(secondResult) != "error"
  if not firstOk and not secondOk then return fail(CORRUPT_DATA, "choose", "both checkpoint slots are invalid") end if
  if firstOk and not secondOk then return [firstResult, SLOT_A] end if
  if secondOk and not firstOk then return [secondResult, SLOT_B] end if
  if not bytesEqual(firstResult.databaseId, secondResult.databaseId) then return fail(CORRUPT_DATA, "choose", "checkpoint slots disagree on database identity") end if
  comparison = superblock.compareGeneration(firstResult.generation, secondResult.generation)
  if comparison == 0 then
    if firstResult.checkpointLsn != secondResult.checkpointLsn or firstResult.redoStartLsn != secondResult.redoStartLsn or firstResult.recordCount != secondResult.recordCount then
      return fail(CORRUPT_DATA, "choose", "equal checkpoint generations contain divergent metadata")
    end if
    return [firstResult, SLOT_A]
  end if
  if comparison > 0 then return [firstResult, SLOT_A] end if
  return [secondResult, SLOT_B]
end function

/// Creates create for the minisql transaction checkpoint module.
/// Inputs: `path`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
/// @param databaseId Identifier of database.
function create(path, databaseId)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "create", "path must be non-empty") end if
  validateDatabaseId(databaseId, "create")
  file = file_api.createNewDurable(path)
  file_api.truncate(file, FILE_SIZE)
  initial = newMetadata(endian.makeUInt64(0, 1), 0, 0, 0, databaseId)
  writeSlot(file, SLOT_A, initial)
  file_api.flush(file)
  return CheckpointFile(path, file, initial, SLOT_A, false)
end function

/// Opens open for the minisql transaction checkpoint module.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function open(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  file = file_api.openReadWrite(path, false)
  if file_api.size(file) != FILE_SIZE then file_api.close(file); return fail(CORRUPT_DATA, "open", "checkpoint file size mismatch") end if
  first = try(readSlot(file, SLOT_A))
  second = try(readSlot(file, SLOT_B))
  selected = try(choose(first, second))
  if typeof(selected) == "error" then file_api.close(file); return selected end if
  return CheckpointFile(path, file, selected[0], selected[1], false)
end function

/// Validates open for the minisql transaction checkpoint workflow.
/// Inputs: `checkpointFile`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param checkpointFile checkpointFile value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateOpen(checkpointFile, operation)
  if checkpointFile is not CheckpointFile then return fail(INVALID_ARGUMENT, operation, "value must be CheckpointFile") end if
  if checkpointFile.closed then return fail(CLOSED_HANDLE, operation, "checkpoint file is closed") end if
  return true
end function

/// Performs the publish operation for this module.
/// Inputs: `checkpointFile`, `checkpointLsn`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param checkpointFile checkpointFile value consumed by this operation.
/// @param checkpointLsn checkpointLsn value consumed by this operation.
/// @param redoStartLsn redoStartLsn value consumed by this operation.
/// @param recordCount Number of record to process.
function publish(checkpointFile, checkpointLsn, redoStartLsn, recordCount)
  validateOpen(checkpointFile, "publish")
  generation = superblock.incrementGeneration(checkpointFile.metadata.generation)
  next = newMetadata(generation, checkpointLsn, redoStartLsn, recordCount, checkpointFile.metadata.databaseId)
  target = SLOT_A
  if checkpointFile.activeSlot == SLOT_A then target = SLOT_B end if
  writeSlot(checkpointFile.file, target, next)
  file_api.flush(checkpointFile.file)
  checkpointFile.metadata = next
  checkpointFile.activeSlot = target
  return next
end function

/// Begins the wal checkpoint.
/// Inputs: `log`, `checkpointId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param checkpointId Identifier of checkpoint.
function beginWalCheckpoint(log, checkpointId)
  return wal.appendCheckpointBegin(log, checkpointId, bytes())
end function

/// Performs the complete wal checkpoint operation for this module.
/// Inputs: `log`, `checkpointFile`, `checkpointId`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param checkpointFile checkpointFile value consumed by this operation.
/// @param checkpointId Identifier of checkpoint.
/// @param redoStartLsn redoStartLsn value consumed by this operation.
/// @param recordCount Number of record to process.
function completeWalCheckpoint(log, checkpointFile, checkpointId, redoStartLsn, recordCount)
  ending = wal.appendCheckpointEnd(log, checkpointId, bytes())
  wal.flush(log)
  return publish(checkpointFile, log.nextLsn, redoStartLsn, recordCount)
end function

/// Performs the perform operation for this module.
/// Inputs: `log`, `checkpointFile`, `checkpointId`, `pagedFiles`, `redoStartLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param checkpointFile checkpointFile value consumed by this operation.
/// @param checkpointId Identifier of checkpoint.
/// @param pagedFiles pagedFiles value consumed by this operation.
/// @param redoStartLsn redoStartLsn value consumed by this operation.
function perform(log, checkpointFile, checkpointId, pagedFiles, redoStartLsn)
  validateOpen(checkpointFile, "perform")
  if typeof(pagedFiles) != "array" then return fail(INVALID_ARGUMENT, "perform", "pagedFiles must be array") end if
  beginWalCheckpoint(log, checkpointId)
  wal.flush(log)
  for each file in pagedFiles
    paged_file.flush(file)
  end for
  return completeWalCheckpoint(log, checkpointFile, checkpointId, redoStartLsn, log.recordCount)
end function

/// Closes close owned by the minisql transaction checkpoint module.
/// Inputs: `checkpointFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param checkpointFile checkpointFile value consumed by this operation.
function close(checkpointFile)
  validateOpen(checkpointFile, "close")
  file_api.close(checkpointFile.file)
  checkpointFile.closed = true
  return true
end function

/// Performs the componentName operation for the minisql transaction checkpoint module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "transaction.checkpoint"
end function

/// Performs the targetMilestone operation for the minisql transaction checkpoint module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M7"
end function

/// Returns whether implemented satisfies the condition required by the minisql transaction checkpoint module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
