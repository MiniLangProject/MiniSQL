package minisql.transaction.wal

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.platform.file as file_api
import minisql.storage.page as page

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

struct WalRecord
  recordType
  flags
  lsn
  totalLength
  transactionId
  fileId
  pageNumber
  pageLsn
  payload
end struct

struct WalScan
  records
  validBytes
  truncatedTail
end struct

function isWalScan(value)
  return value is WalScan
end function

struct WalWriter
  path
  file
  segmentBytes
  nextLsn
  lastFlushedLsn
  recordCount
  failNextWrite
  failNextFlush
  closed
end struct

function fail(code, operation, message)
  return error(code, "transaction.wal." + operation + ": " + message)
end function

function magicBytes()
  return bytes("MSQLWAL1")
end function

function copyExact(destination, destinationOffset, source, sourceOffset, count)
  if count == 0 then return true end if
  for index = 0 to count - 1
    destination[destinationOffset + index] = source[sourceOffset + index]
  end for
  return true
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function validateNative(value, operation, name)
  if typeof(value) != "int" or value < 0 or value > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, name + " must be a non-negative native MiniLang int")
  end if
  return true
end function

function decodeNative(words, operation, name)
  endian.validateUInt64Words(words, "transaction.wal." + operation + "." + name)
  if words.high > endian.MAX_SCALAR_HIGH then return fail(UNSUPPORTED_FORMAT, operation, name + " exceeds native range") end if
  return endian.uint64ToInt(words)
end function

function validateRecordType(recordType, operation)
  if typeof(recordType) != "int" or recordType < RECORD_TX_BEGIN or recordType > RECORD_CHECKPOINT_END then
    return fail(INVALID_ARGUMENT, operation, "unknown WAL record type")
  end if
  return true
end function


function durableMarkerMagic()
  return bytes("MSWDL001")
end function

function durableMarkerPath(walPath)
  if typeof(walPath) != "string" or len(walPath) == 0 then return fail(INVALID_ARGUMENT, "durableMarkerPath", "walPath must be non-empty") end if
  return walPath + ".durable"
end function

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

function readDurableMarker(walPath)
  path = durableMarkerPath(walPath)
  if not file_api.fileExists(path) then return -1 end if
  encoded = file_api.readAllBytes(path, DURABLE_MARKER_SIZE)
  return decodeDurableMarker(encoded)
end function

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
function decode(source)
  return decodeRecord(source)
end function

function scanFile(file)
  file_api.validateOpen(file, "wal.scanFile")
  length = file_api.size(file)
  offset = 0
  records = []
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
    records = records + [record]
    offset = offset + totalLength
  end while
  return WalScan(records, offset, truncated)
end function

function scanSnapshot(source)
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "scanSnapshot", "source must be bytes") end if
  offset = 0
  records = []
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
    records = records + [decoded]
    offset = offset + totalLength
  end while
  return WalScan(records, offset, truncated)
end function

function validateSegmentBytes(segmentBytes, operation)
  if typeof(segmentBytes) != "int" or segmentBytes < 4096 or segmentBytes > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, "segmentBytes must be at least 4096")
  end if
  return true
end function

function create(path, segmentBytes)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "create", "path must be non-empty") end if
  validateSegmentBytes(segmentBytes, "create")
  file = file_api.createNewDurable(path)
  ignoredMarker = try(writeDurableMarker(path, 0))
  return WalWriter(path, file, segmentBytes, 0, 0, 0, false, false, false)
end function

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

function validateOpen(writer, operation)
  if writer is not WalWriter then return fail(INVALID_ARGUMENT, operation, "writer must be WalWriter") end if
  if writer.closed then return fail(CLOSED_HANDLE, operation, "WAL is closed") end if
  file_api.validateOpen(writer.file, "wal." + operation)
  return true
end function

function segmentNumber(writer, lsn)
  validateOpen(writer, "segmentNumber")
  validateNative(lsn, "segmentNumber", "lsn")
  return lsn / writer.segmentBytes
end function

function segmentOffset(writer, lsn)
  validateOpen(writer, "segmentOffset")
  validateNative(lsn, "segmentOffset", "lsn")
  return lsn % writer.segmentBytes
end function

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

function appendBegin(writer, transactionId)
  return appendRecord(writer, RECORD_TX_BEGIN, 0, transactionId, 0, 0, bytes())
end function

function appendPageImage(writer, transactionId, fileId, pageNumber, pageBytes)
  return appendRecord(writer, RECORD_PAGE_IMAGE, 0, transactionId, fileId, pageNumber, pageBytes)
end function

function appendCommit(writer, transactionId)
  return appendRecord(writer, RECORD_TX_COMMIT, 0, transactionId, 0, 0, bytes())
end function

function appendAbort(writer, transactionId)
  return appendRecord(writer, RECORD_TX_ABORT, 0, transactionId, 0, 0, bytes())
end function

function appendCheckpointBegin(writer, checkpointId, payload)
  return appendRecord(writer, RECORD_CHECKPOINT_BEGIN, 0, checkpointId, 0, 0, payload)
end function

function appendCheckpointEnd(writer, checkpointId, payload)
  return appendRecord(writer, RECORD_CHECKPOINT_END, 0, checkpointId, 0, 0, payload)
end function

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

function injectWriteFailure(writer)
  validateOpen(writer, "injectWriteFailure")
  writer.failNextWrite = true
  return true
end function

function injectFlushFailure(writer)
  validateOpen(writer, "injectFlushFailure")
  writer.failNextFlush = true
  return true
end function

function close(writer)
  validateOpen(writer, "close")
  flush(writer)
  file_api.close(writer.file)
  writer.closed = true
  return true
end function

function componentName()
  return "transaction.wal"
end function

function targetMilestone()
  return "M6"
end function

function isImplemented()
  return true
end function
