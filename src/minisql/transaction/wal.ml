package minisql.transaction.wal
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.page as page
import std.ds.list as list

// Write-ahead log format v1. Records are append-only, length-prefixed and
// independently protected by header and payload CRC-32C values. The current
// implementation stores logical segments in one durable file; segmentNumber
// and segmentOffset expose the configured segment geometry so physical segment
// rotation can be introduced without changing record encoding.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const IO_FAILURE = 9005
const CLOSED_HANDLE = 9008

const FORMAT_VERSION = 1
const HEADER_SIZE = 80
const MAGIC_SIZE = 8
const PAYLOAD_CHECKSUM_OFFSET = 64
const HEADER_CHECKSUM_OFFSET = 68
const MAX_RECORD_SIZE = 67108864
const APPEND_BATCH_BYTES = 4194304

// M48 durable-export marker. The WAL itself remains format v1. The sidecar
// marker records only the prefix known to have completed FlushFileBuffers.
const DURABLE_MARKER_VERSION = 1
const DURABLE_MARKER_SIZE = 32
const DURABLE_MARKER_CHECKSUM_OFFSET = 24

const RECORD_TX_BEGIN = 1
const RECORD_PAGE_IMAGE = 2
const RECORD_TX_COMMIT = 3
const RECORD_TX_ABORT = 4
const RECORD_CHECKPOINT_BEGIN = 5
const RECORD_CHECKPOINT_END = 6

// Defines the wal record record used by this module.
struct WalRecord
  // Record type field of the wal record.
  recordType
  // Flags field of the wal record.
  flags
  // Lsn field of the wal record.
  lsn
  // Total length field of the wal record.
  totalLength
  // Transaction id field of the wal record.
  transactionId
  // File id field of the wal record.
  fileId
  // Page number field of the wal record.
  pageNumber
  // Page lsn field of the wal record.
  pageLsn
  // Payload field of the wal record.
  payload
end struct

// Defines the wal scan record used by this module.
struct WalScan
  // Records field of the wal scan.
  records
  // Valid bytes field of the wal scan.
  validBytes
  // Truncated tail field of the wal scan.
  truncatedTail
end struct

// Evaluates whether the supplied input satisfies the wal scan predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isWalScan(value)
  return value is WalScan
end function

// Defines the wal writer record used by this module.
struct WalWriter
  // Path field of the wal writer.
  path
  // File field of the wal writer.
  file
  // Segment bytes field of the wal writer.
  segmentBytes
  // Next lsn field of the wal writer.
  nextLsn
  // Last flushed lsn field of the wal writer.
  lastFlushedLsn
  // Record count field of the wal writer.
  recordCount
  // Fail next write field of the wal writer.
  failNextWrite
  // Fail next flush field of the wal writer.
  failNextFlush
  // Closed field of the wal writer.
  closed
end struct

// Holds one bounded WAL append buffer. `nextLsn` advances logically while the
// physical writer position is published only after the complete transaction
// batch has been appended successfully.
struct WalAppendBatch
  // WAL writer whose physical append position is published on commit.
  writer
  // Contiguous encoded records awaiting one file write.
  buffer
  // Number of populated bytes in the bounded append buffer.
  used
  // Logical LSN assigned to the next record in this batch.
  nextLsn
  // Number of complete encoded records accumulated in the batch.
  records
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "transaction.wal." + operation + ": " + message)
end function

// Performs the magic bytes operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function magicBytes()
  return bytes("MSQLWAL1")
end function

// Copies the exact.
// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
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

// Validates the native.
// Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.
function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

// Decodes the native.
// Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeNative(words, operation, name)
  endian.validateUInt64Words(words, "transaction.wal." + operation + "." + name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

// Validates the record type.
// Inputs: `recordType`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateRecordType(recordType, operation)
  if typeof(recordType) != "int" or recordType < RECORD_TX_BEGIN or recordType > RECORD_CHECKPOINT_END then
    return fail(INVALID_ARGUMENT, operation, "unknown WAL record type")
  end if
  return true
end function


// Performs the durable marker magic operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function durableMarkerMagic()
  return bytes("MSWDL001")
end function

// Performs the durable marker path operation for this module.
// Inputs: `walPath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function durableMarkerPath(walPath)
  if typeof(walPath) != "string" or len(walPath) == 0 then return fail(INVALID_ARGUMENT, "durableMarkerPath", "walPath must be non-empty") end if
  return walPath + ".durable"
end function

// Encodes the durable marker.
// Inputs: `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encodeDurableMarker(lsn)
  validateNative(lsn, "encodeDurableMarker", "lsn")
  output = bytes(DURABLE_MARKER_SIZE, 0)
  copyExact(output, 0, durableMarkerMagic(), 0, 8)
  endian.writeU16LE(output, 8, DURABLE_MARKER_VERSION)
  endian.writeU16LE(output, 10, DURABLE_MARKER_SIZE)
  endian.writeU32LE(output, 12, 0)
  endian.writeU64LE(output, 16, endian.uint64FromInt(lsn))
  endian.writeU32LE(output, DURABLE_MARKER_CHECKSUM_OFFSET, 0)
  endian.writeU32LE(output, 28, 0)
  endian.writeU32LE(output, DURABLE_MARKER_CHECKSUM_OFFSET, crc32c.compute(output))
  return output
end function

// Decodes the durable marker.
// Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeDurableMarker(source)
  if typeof(source) != "bytes" or len(source) != DURABLE_MARKER_SIZE then return fail(CORRUPT_DATA, "decodeDurableMarker", "marker size is invalid") end if
  if not bytesEqual(slice(source, 0, 8), durableMarkerMagic()) then return fail(UNSUPPORTED_FORMAT, "decodeDurableMarker", "marker magic mismatch") end if
  if endian.readU16LE(source, 8) != DURABLE_MARKER_VERSION or endian.readU16LE(source, 10) != DURABLE_MARKER_SIZE then return fail(UNSUPPORTED_FORMAT, "decodeDurableMarker", "marker version is unsupported") end if
  if endian.readU32LE(source, 12) != 0 or endian.readU32LE(source, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeDurableMarker", "reserved marker fields are non-zero") end if
  stored = endian.readU32LE(source, DURABLE_MARKER_CHECKSUM_OFFSET)
  copy = bytes(source)
  endian.writeU32LE(copy, DURABLE_MARKER_CHECKSUM_OFFSET, 0)
  if crc32c.compute(copy) != stored then return fail(CORRUPT_DATA, "decodeDurableMarker", "marker checksum mismatch") end if
  words = endian.readU64LE(source, 16)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, "decodeDurableMarker", "durable LSN exceeds native range") end if
  return endian.uint64ToInt(words)
end function

// Reads the durable marker.
// Inputs: `walPath`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readDurableMarker(walPath)
  path = durableMarkerPath(walPath)
  if not file_api.fileExists(path) then return -1 end if
  encoded = file_api.readAllBytes(path, DURABLE_MARKER_SIZE)
  return decodeDurableMarker(encoded)
end function

// Writes the durable marker.
// Inputs: `walPath`, `lsn`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeDurableMarker(walPath, lsn)
  encoded = encodeDurableMarker(lsn)
  path = durableMarkerPath(walPath)
  temporary = path + ".new"
  ignoredDelete = try(file_api.deletePath(temporary))
  handle = try(file_api.createNewDurable(temporary))
  if typeof(handle) == "error" then return handle end if
  written = try(file_api.writeAt(handle, 0, encoded, 0, len(encoded)))
  flushed = true
  if typeof(written) != "error" then flushed = try(file_api.flush(handle)) end if
  closed = try(file_api.close(handle))
  if typeof(written) == "error" then return written end if
  if typeof(flushed) == "error" then return flushed end if
  if typeof(closed) == "error" then return closed end if
  file_api.movePath(temporary, path, true)
  return lsn
end function

// Creates the record.
// Inputs: `recordType`, `flags`, `transactionId`, `fileId`, `pageNumber`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createRecord(recordType, flags, transactionId, fileId, pageNumber, payload)
  validateRecordType(recordType, "createRecord")
  if typeof(flags) != "int" or flags < 0 or flags > 65535 then return fail(INVALID_ARGUMENT, "createRecord", "flags must fit U16") end if
  validateNative(transactionId, "createRecord", "transactionId")
  validateNative(fileId, "createRecord", "fileId")
  validateNative(pageNumber, "createRecord", "pageNumber")
  if typeof(payload) != "bytes" then return fail(INVALID_ARGUMENT, "createRecord", "payload must be bytes") end if
  if len(payload) > endian.MAX_U32 - HEADER_SIZE or len(payload) > MAX_RECORD_SIZE - HEADER_SIZE then return fail(INVALID_ARGUMENT, "createRecord", "payload is too large") end if
  if recordType == RECORD_PAGE_IMAGE then
    if len(payload) < page.HEADER_SIZE then return fail(INVALID_ARGUMENT, "createRecord", "PAGE_IMAGE must contain a complete page") end if
    header = page.verify(payload)
    if header.pageId.fileId != fileId or header.pageId.pageNumber != pageNumber then
      return fail(INVALID_ARGUMENT, "createRecord", "PAGE_IMAGE identity does not match WAL target")
    end if
  else
    if fileId != 0 or pageNumber != 0 then return fail(INVALID_ARGUMENT, "createRecord", "non-page record must use zero file/page IDs") end if
  end if
  return WalRecord(recordType, flags, 0, HEADER_SIZE + len(payload), transactionId, fileId, pageNumber, 0, bytes(payload))
end function

// Validates the record.
// Inputs: `record`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateRecord(record, operation)
  if record is not WalRecord then return fail(INVALID_ARGUMENT, operation, "record must be WalRecord") end if
  validateRecordType(record.recordType, operation)
  if typeof(record.flags) != "int" or record.flags < 0 or record.flags > 65535 then return fail(INVALID_ARGUMENT, operation, "flags must fit U16") end if
  validateNative(record.lsn, operation, "lsn")
  validateNative(record.transactionId, operation, "transactionId")
  validateNative(record.fileId, operation, "fileId")
  validateNative(record.pageNumber, operation, "pageNumber")
  validateNative(record.pageLsn, operation, "pageLsn")
  if typeof(record.payload) != "bytes" then return fail(INVALID_ARGUMENT, operation, "payload must be bytes") end if
  if record.totalLength != HEADER_SIZE + len(record.payload) then return fail(INVALID_ARGUMENT, operation, "totalLength mismatch") end if
  if record.totalLength > MAX_RECORD_SIZE then return fail(INVALID_ARGUMENT, operation, "record exceeds safety limit") end if
  return true
end function

// Encodes the requested value.
// Inputs: `record`. Returns the produced value or propagates a structured error from validation or delegated operations.
function encode(record)
  validateRecord(record, "encode")
  output = bytes(record.totalLength, 0)
  copyExact(output, 0, magicBytes(), 0, MAGIC_SIZE)
  endian.writeU16LE(output, 8, FORMAT_VERSION)
  endian.writeU16LE(output, 10, HEADER_SIZE)
  endian.writeU16LE(output, 12, record.recordType)
  endian.writeU16LE(output, 14, record.flags)
  endian.writeU32LE(output, 16, record.totalLength)
  endian.writeU32LE(output, 20, len(record.payload))
  endian.writeU64LE(output, 24, endian.uint64FromInt(record.lsn))
  endian.writeU64LE(output, 32, endian.uint64FromInt(record.transactionId))
  endian.writeU64LE(output, 40, endian.uint64FromInt(record.fileId))
  endian.writeU64LE(output, 48, endian.uint64FromInt(record.pageNumber))
  endian.writeU64LE(output, 56, endian.uint64FromInt(record.pageLsn))
  endian.writeU32LE(output, PAYLOAD_CHECKSUM_OFFSET, crc32c.compute(record.payload))
  endian.writeU32LE(output, HEADER_CHECKSUM_OFFSET, 0)
  endian.writeU64LE(output, 72, endian.makeUInt64(0, 0))
  headerChecksum = crc32c.computeRange(output, 0, HEADER_SIZE)
  endian.writeU32LE(output, HEADER_CHECKSUM_OFFSET, headerChecksum)
  if len(record.payload) > 0 then copyExact(output, HEADER_SIZE, record.payload, 0, len(record.payload)) end if
  return output
end function

// Decodes the record.
// Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decodeRecord(source)
  if typeof(source) != "bytes" or len(source) < HEADER_SIZE then return fail(CORRUPT_DATA, "decode", "record is shorter than header") end if
  if len(source) > MAX_RECORD_SIZE then return fail(CORRUPT_DATA, "decode", "record exceeds safety limit") end if
  if not bytesEqual(slice(source, 0, MAGIC_SIZE), magicBytes()) then return fail(UNSUPPORTED_FORMAT, "decode", "record magic mismatch") end if
  if endian.readU16LE(source, 8) != FORMAT_VERSION or endian.readU16LE(source, 10) != HEADER_SIZE then
    return fail(UNSUPPORTED_FORMAT, "decode", "unsupported record version/header size")
  end if
  totalLength = endian.readU32LE(source, 16)
  payloadLength = endian.readU32LE(source, 20)
  if totalLength != len(source) or totalLength != HEADER_SIZE + payloadLength then return fail(CORRUPT_DATA, "decode", "record length mismatch") end if
  reserved = endian.readU64LE(source, 72)
  if reserved.high != 0 or reserved.low != 0 then return fail(UNSUPPORTED_FORMAT, "decode", "reserved field is non-zero") end if
  storedHeader = endian.readU32LE(source, HEADER_CHECKSUM_OFFSET)
  headerCopy = slice(source, 0, HEADER_SIZE)
  endian.writeU32LE(headerCopy, HEADER_CHECKSUM_OFFSET, 0)
  if crc32c.compute(headerCopy) != storedHeader then return fail(CORRUPT_DATA, "decode", "header checksum mismatch") end if
  payload = bytes()
  if payloadLength > 0 then payload = slice(source, HEADER_SIZE, payloadLength) end if
  if crc32c.compute(payload) != endian.readU32LE(source, PAYLOAD_CHECKSUM_OFFSET) then return fail(CORRUPT_DATA, "decode", "payload checksum mismatch") end if
  record = WalRecord(
    endian.readU16LE(source, 12),
    endian.readU16LE(source, 14),
    decodeNative(endian.readU64LE(source, 24), "decode", "lsn"),
    totalLength,
    decodeNative(endian.readU64LE(source, 32), "decode", "transactionId"),
    decodeNative(endian.readU64LE(source, 40), "decode", "fileId"),
    decodeNative(endian.readU64LE(source, 48), "decode", "pageNumber"),
    decodeNative(endian.readU64LE(source, 56), "decode", "pageLsn"),
    payload
  )
  validateRecord(record, "decode")
  if record.recordType == RECORD_PAGE_IMAGE then
    header = page.verify(record.payload)
    if header.pageId.fileId != record.fileId or header.pageId.pageNumber != record.pageNumber then return fail(CORRUPT_DATA, "decode", "PAGE_IMAGE identity mismatch") end if
    if page.compareLsn(header.pageLsn, endian.uint64FromInt(record.pageLsn)) != 0 then return fail(CORRUPT_DATA, "decode", "PAGE_IMAGE pageLSN mismatch") end if
  end if
  return record
end function

// Public compatibility wrapper. Qualified calls such as wal.decode(...) resolve
// to this package function. Internal WAL code deliberately uses decodeRecord so
// the MiniLang builtin decode(bytes) cannot shadow the WAL record decoder.
// Decodes the requested value.
// Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
function decode(source)
  return decodeRecord(source)
end function

// Scans the file.
// Inputs: `file`. Returns the produced value or propagates a structured error from validation or delegated operations.
function scanFile(file)
  file_api.validateOpen(file, "wal.scanFile")
  length = file_api.size(file)
  offset = 0
  records = list.List.new()
  truncated = false
  while offset < length
    remaining = length - offset
    if remaining < HEADER_SIZE then truncated = true; break end if
    header = bytes(HEADER_SIZE, 0)
    file_api.readExactAt(file, offset, header, 0, HEADER_SIZE)
    if not bytesEqual(slice(header, 0, MAGIC_SIZE), magicBytes()) then return fail(CORRUPT_DATA, "scanFile", "record magic mismatch at offset " + offset) end if
    totalLength = endian.readU32LE(header, 16)
    if totalLength < HEADER_SIZE then return fail(CORRUPT_DATA, "scanFile", "invalid record length at offset " + offset) end if
    if totalLength > MAX_RECORD_SIZE then return fail(CORRUPT_DATA, "scanFile", "record exceeds safety limit at offset " + offset) end if
    if totalLength > remaining then truncated = true; break end if
    encoded = bytes(totalLength, 0)
    file_api.readExactAt(file, offset, encoded, 0, totalLength)
    record = decodeRecord(encoded)
    if record.lsn != offset then return fail(CORRUPT_DATA, "scanFile", "record LSN differs from file offset") end if
    records.add(record)
    offset = offset + totalLength
  end while
  return WalScan(records.toArray(), offset, truncated)
end function

// Scans the snapshot.
// Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.
function scanSnapshot(source)
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "scanSnapshot", "source must be bytes") end if
  offset = 0
  records = list.List.new()
  truncated = false
  while offset < len(source)
    remaining = len(source) - offset
    if remaining < HEADER_SIZE then truncated = true; break end if
    header = slice(source, offset, HEADER_SIZE)
    if not bytesEqual(slice(header, 0, MAGIC_SIZE), magicBytes()) then truncated = true; break end if
    totalLength = endian.readU32LE(header, 16)
    if totalLength < HEADER_SIZE or totalLength > MAX_RECORD_SIZE or totalLength > remaining then truncated = true; break end if
    decoded = try(decodeRecord(slice(source, offset, totalLength)))
    if typeof(decoded) == "error" then
      if offset + totalLength == len(source) then truncated = true; break end if
      return decoded
    end if
    if decoded.lsn != offset then return fail(CORRUPT_DATA, "scanSnapshot", "record LSN differs from snapshot offset") end if
    records.add(decoded)
    offset = offset + totalLength
  end while
  return WalScan(records.toArray(), offset, truncated)
end function

// Validates the segment bytes.
// Inputs: `segmentBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateSegmentBytes(segmentBytes, operation)
  if typeof(segmentBytes) != "int" or segmentBytes < 4096 or segmentBytes > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, "segmentBytes must be at least 4096")
  end if
  return true
end function

// Creates the requested value.
// Inputs: `path`, `segmentBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function create(path, segmentBytes)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "create", "path must be non-empty") end if
  validateSegmentBytes(segmentBytes, "create")
  file = file_api.createNewDurable(path)
  ignoredMarker = try(writeDurableMarker(path, 0))
  return WalWriter(path, file, segmentBytes, 0, 0, 0, false, false, false)
end function

// Opens the requested value.
// Inputs: `path`, `segmentBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function open(path, segmentBytes)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  validateSegmentBytes(segmentBytes, "open")
  file = file_api.openReadWrite(path, false)
  scanned = try(scanFile(file))
  if typeof(scanned) == "error" then file_api.close(file); return scanned end if
  if scanned.truncatedTail then
    file_api.truncate(file, scanned.validBytes)
    file_api.flush(file)
  end if
  // Once a WAL is reopened after a process restart, every byte that survived
  // the open/repair pass is durable. Refresh the export marker for old and new
  // databases alike. Marker failure may delay replication but must not make an
  // already durable database unavailable.
  ignoredMarker = try(writeDurableMarker(path, scanned.validBytes))
  return WalWriter(path, file, segmentBytes, scanned.validBytes, scanned.validBytes, len(scanned.records), false, false, false)
end function

// Validates the open.
// Inputs: `writer`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateOpen(writer, operation)
  if writer is not WalWriter then return fail(INVALID_ARGUMENT, operation, "writer must be WalWriter") end if
  if writer.closed then return fail(CLOSED_HANDLE, operation, "WAL is closed") end if
  file_api.validateOpen(writer.file, "wal." + operation)
  return true
end function

// Performs the segment number operation for this module.
// Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function segmentNumber(writer, lsn)
  validateOpen(writer, "segmentNumber")
  validateNative(lsn, "segmentNumber", "lsn")
  return lsn / writer.segmentBytes
end function

// Performs the segment offset operation for this module.
// Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function segmentOffset(writer, lsn)
  validateOpen(writer, "segmentOffset")
  validateNative(lsn, "segmentOffset", "lsn")
  return lsn % writer.segmentBytes
end function

// Appends the record.
// Inputs: `writer`, `recordType`, `flags`, `transactionId`, `fileId`, `pageNumber`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendRecord(writer, recordType, flags, transactionId, fileId, pageNumber, payload)
  validateOpen(writer, "appendRecord")
  if writer.failNextWrite then
    writer.failNextWrite = false
    return fail(IO_FAILURE, "appendRecord", "injected WAL write failure")
  end if
  record = createRecord(recordType, flags, transactionId, fileId, pageNumber, payload)
  record.lsn = writer.nextLsn
  if record.recordType == RECORD_PAGE_IMAGE then
    image = bytes(record.payload)
    header = page.verify(image)
    header.pageLsn = endian.uint64FromInt(record.lsn)
    page.seal(image, header)
    record.payload = image
    record.pageLsn = record.lsn
    record.totalLength = HEADER_SIZE + len(image)
  end if
  encoded = encode(record)
  file_api.append(writer.file, encoded, 0, len(encoded))
  writer.nextLsn = writer.nextLsn + len(encoded)
  writer.recordCount = writer.recordCount + 1
  return record
end function

// Assigns an LSN, updates a PAGE_IMAGE header and returns the encoded record.
function encodeRecordAt(record, lsn)
  record.lsn = lsn
  if record.recordType == RECORD_PAGE_IMAGE then
    image = bytes(record.payload)
    header = page.verify(image)
    header.pageLsn = endian.uint64FromInt(record.lsn)
    page.seal(image, header)
    record.payload = image
    record.pageLsn = record.lsn
    record.totalLength = HEADER_SIZE + len(image)
  end if
  return encode(record)
end function

// Flushes the occupied prefix of a bounded append batch.
function flushAppendBatch(batch)
  if batch is not WalAppendBatch then return fail(INVALID_ARGUMENT, "flushAppendBatch", "batch must be WalAppendBatch") end if
  if batch.used == 0 then return false end if
  written = try(file_api.append(batch.writer.file, batch.buffer, 0, batch.used))
  if typeof(written) == "error" then return written end if
  batch.used = 0
  return true
end function

// Adds one record to the bounded batch, flushing or directly appending records
// larger than the staging buffer. At most APPEND_BATCH_BYTES are duplicated.
function appendBatchRecord(batch, record)
  encoded = encodeRecordAt(record, batch.nextLsn)
  if len(encoded) > len(batch.buffer) then
    flushAppendBatch(batch)
    written = try(file_api.append(batch.writer.file, encoded, 0, len(encoded)))
    if typeof(written) == "error" then return written end if
  else
    if batch.used > len(batch.buffer) - len(encoded) then flushAppendBatch(batch) end if
    copyExact(batch.buffer, batch.used, encoded, 0, len(encoded))
    batch.used = batch.used + len(encoded)
  end if
  batch.nextLsn = batch.nextLsn + len(encoded)
  batch.records = batch.records + 1
  return record.lsn
end function

// Appends a complete transaction using a bounded staging buffer. This reduces
// one kernel write per page image to roughly one write per 4 MiB while retaining
// the existing single FlushFileBuffers durability boundary and rewind-on-error
// behavior. `changes` contain fileId, pageNumber and pageBytes fields.
function appendTransaction(writer, transactionId, changes)
  validateOpen(writer, "appendTransaction")
  validateNative(transactionId, "appendTransaction", "transactionId")
  if typeof(changes) != "array" then return fail(INVALID_ARGUMENT, "appendTransaction", "changes must be array") end if
  if writer.failNextWrite then
    writer.failNextWrite = false
    return fail(IO_FAILURE, "appendTransaction", "injected WAL write failure")
  end if
  bufferBytes = HEADER_SIZE * 2
  for each change in changes
    recordBytes = HEADER_SIZE + len(change.pageBytes)
    if bufferBytes < APPEND_BATCH_BYTES then
      if recordBytes >= APPEND_BATCH_BYTES - bufferBytes then bufferBytes = APPEND_BATCH_BYTES else bufferBytes = bufferBytes + recordBytes end if
    end if
  end for
  batch = WalAppendBatch(writer, bytes(bufferBytes, 0), 0, writer.nextLsn, 0)
  beginLsn = try(appendBatchRecord(batch, createRecord(RECORD_TX_BEGIN, 0, transactionId, 0, 0, bytes())))
  if typeof(beginLsn) == "error" then return beginLsn end if
  for each change in changes
    appended = try(appendBatchRecord(batch, createRecord(RECORD_PAGE_IMAGE, 0, transactionId, change.fileId, change.pageNumber, change.pageBytes)))
    if typeof(appended) == "error" then return appended end if
  end for
  commitLsn = try(appendBatchRecord(batch, createRecord(RECORD_TX_COMMIT, 0, transactionId, 0, 0, bytes())))
  if typeof(commitLsn) == "error" then return commitLsn end if
  finalAppend = try(flushAppendBatch(batch))
  if typeof(finalAppend) == "error" then return finalAppend end if
  writer.nextLsn = batch.nextLsn
  writer.recordCount = writer.recordCount + batch.records
  return [beginLsn, commitLsn]
end function

// Appends the begin.
// Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendBegin(writer, transactionId)
  return appendRecord(writer, RECORD_TX_BEGIN, 0, transactionId, 0, 0, bytes())
end function

// Appends the page image.
// Inputs: `writer`, `transactionId`, `fileId`, `pageNumber`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendPageImage(writer, transactionId, fileId, pageNumber, pageBytes)
  return appendRecord(writer, RECORD_PAGE_IMAGE, 0, transactionId, fileId, pageNumber, pageBytes)
end function

// Appends the commit.
// Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendCommit(writer, transactionId)
  return appendRecord(writer, RECORD_TX_COMMIT, 0, transactionId, 0, 0, bytes())
end function

// Appends the abort.
// Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendAbort(writer, transactionId)
  return appendRecord(writer, RECORD_TX_ABORT, 0, transactionId, 0, 0, bytes())
end function

// Appends the checkpoint begin.
// Inputs: `writer`, `checkpointId`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendCheckpointBegin(writer, checkpointId, payload)
  return appendRecord(writer, RECORD_CHECKPOINT_BEGIN, 0, checkpointId, 0, 0, payload)
end function

// Appends the checkpoint end.
// Inputs: `writer`, `checkpointId`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.
function appendCheckpointEnd(writer, checkpointId, payload)
  return appendRecord(writer, RECORD_CHECKPOINT_END, 0, checkpointId, 0, 0, payload)
end function

// Scans the requested value.
// Inputs: `writer`, `repairTail`. Returns the produced value or propagates a structured error from validation or delegated operations.
function scan(writer, repairTail)
  validateOpen(writer, "scan")
  if typeof(repairTail) != "bool" then return fail(INVALID_ARGUMENT, "scan", "repairTail must be bool") end if
  result = scanFile(writer.file)
  if repairTail and result.truncatedTail then
    file_api.truncate(writer.file, result.validBytes)
    file_api.flush(writer.file)
    ignoredMarker = try(writeDurableMarker(writer.path, result.validBytes))
    writer.nextLsn = result.validBytes
    writer.lastFlushedLsn = result.validBytes
    result = scanFile(writer.file)
  end if
  return result
end function

// Flushes the requested value.
// Inputs: `writer`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function flush(writer)
  validateOpen(writer, "flush")
  if writer.failNextFlush then
    writer.failNextFlush = false
    return fail(IO_FAILURE, "flush", "injected WAL flush failure")
  end if
  file_api.flush(writer.file)
  // The data flush is the commit boundary. A marker failure is intentionally
  // non-fatal: it can only make a live replica lag, whereas returning a commit
  // error after the WAL became durable would invite an unsafe client retry.
  ignoredMarker = try(writeDurableMarker(writer.path, writer.nextLsn))
  writer.lastFlushedLsn = writer.nextLsn
  return writer.lastFlushedLsn
end function

// Performs the rewind operation for this module.
// Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function rewind(writer, lsn)
  validateOpen(writer, "rewind")
  validateNative(lsn, "rewind", "lsn")
  if lsn > writer.nextLsn then return fail(INVALID_ARGUMENT, "rewind", "lsn exceeds WAL end") end if
  file_api.truncate(writer.file, lsn)
  file_api.flush(writer.file)
  ignoredMarker = try(writeDurableMarker(writer.path, lsn))
  writer.nextLsn = lsn
  if writer.lastFlushedLsn > lsn then writer.lastFlushedLsn = lsn end if
  scanned = scanFile(writer.file)
  writer.recordCount = len(scanned.records)
  return true
end function

// Performs the inject write failure operation for this module.
// Inputs: `writer`. Returns the produced value or propagates a structured error from validation or delegated operations.
function injectWriteFailure(writer)
  validateOpen(writer, "injectWriteFailure")
  writer.failNextWrite = true
  return true
end function

// Performs the inject flush failure operation for this module.
// Inputs: `writer`. Returns the produced value or propagates a structured error from validation or delegated operations.
function injectFlushFailure(writer)
  validateOpen(writer, "injectFlushFailure")
  writer.failNextFlush = true
  return true
end function

// Closes the requested value.
// Inputs: `writer`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(writer)
  validateOpen(writer, "close")
  flush(writer)
  file_api.close(writer.file)
  writer.closed = true
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "transaction.wal"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M6"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
