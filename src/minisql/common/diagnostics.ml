//! Provides minisql common diagnostics facilities for this project.

package minisql.common.diagnostics
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.common.uuid as uuid
import minisql.platform.file as file_api
import std.time as time_api

/// Tamper-evident diagnostics and audit-log storage. Each record incorporates

const INVALID_ARGUMENT = 9001
/// Defines the corrupt data constant used by the minisql common diagnostics module.
const CORRUPT_DATA = 9004
/// Defines the io failure constant used by the minisql common diagnostics module.
const IO_FAILURE = 9005
/// Defines the closed handle constant used by the minisql common diagnostics module.
const CLOSED_HANDLE = 9008

/// Defines the audit version constant used by the minisql common diagnostics module.
const AUDIT_VERSION = 1
/// Defines the audit header bytes constant used by the minisql common diagnostics module.
const AUDIT_HEADER_BYTES = 120
/// Defines the audit hash bytes constant used by the minisql common diagnostics module.
const AUDIT_HASH_BYTES = 32
/// Defines the audit key bytes constant used by the minisql common diagnostics module.
const AUDIT_KEY_BYTES = 32
/// Defines the max audit detail bytes constant used by the minisql common diagnostics module.
const MAX_AUDIT_DETAIL_BYTES = 4096
/// Audit v1 snapshots are processed through one U32-sized byte buffer. Keep the
const MAX_AUDIT_FILE_BYTES = 4294967295

/// Defines the audit login constant used by the minisql common diagnostics module.
const AUDIT_LOGIN = 1
/// Defines the audit logout constant used by the minisql common diagnostics module.
const AUDIT_LOGOUT = 2
/// Defines the audit ddl constant used by the minisql common diagnostics module.
const AUDIT_DDL = 3
/// Defines the audit dcl constant used by the minisql common diagnostics module.
const AUDIT_DCL = 4
/// Defines the audit maintenance constant used by the minisql common diagnostics module.
const AUDIT_MAINTENANCE = 5
/// Defines the audit backup constant used by the minisql common diagnostics module.
const AUDIT_BACKUP = 6
/// Defines the audit restore constant used by the minisql common diagnostics module.
const AUDIT_RESTORE = 7
/// Defines the audit replication constant used by the minisql common diagnostics module.
const AUDIT_REPLICATION = 8
/// Defines the audit server constant used by the minisql common diagnostics module.
const AUDIT_SERVER = 9
/// Defines the audit rotation constant used by the minisql common diagnostics module.
const AUDIT_ROTATION = 10

/// Defines the audit failure constant used by the minisql common diagnostics module.
const AUDIT_FAILURE = 0
/// Defines the audit success constant used by the minisql common diagnostics module.
const AUDIT_SUCCESS = 1

/// Defines the diagnostic record used by this module.
struct Diagnostic
  /// Code field of the diagnostic.
  code
  /// Severity field of the diagnostic.
  severity
  /// Message field of the diagnostic.
  message
end struct

/// Defines the audit scan record used by this module.
struct AuditScan
  /// Record count field of the audit scan.
  recordCount
  /// Last sequence field of the audit scan.
  lastSequence
  /// Last hash field of the audit scan.
  lastHash
  /// Valid bytes field of the audit scan.
  validBytes
end struct

/// Defines the audit log record used by this module.
struct AuditLog
  /// Path field of the audit log.
  path
  /// File field of the audit log.
  file
  /// Key field of the audit log.
  key
  /// Next sequence field of the audit log.
  nextSequence
  /// Last hash field of the audit log.
  lastHash
  /// Closed field of the audit log.
  closed
end struct

/// Constructs the requested value.
/// Inputs: `code`, `severity`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param severity severity value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function make(code, severity, message)
  return Diagnostic(code, severity, message)
end function

/// Performs the fail operation for the minisql common diagnostics module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "common.diagnostics." + operation + ": " + message)
end function

/// Performs the audit magic operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function auditMagic()
  return bytes("MSAUD001")
end function

/// Performs the zero hash operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function zeroHash()
  return bytes(AUDIT_HASH_BYTES, 0)
end function

/// Performs the bytesEqual operation for the minisql common diagnostics module.
/// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  difference = 0
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      difference = difference | (left[index] ^ right[index])
    end for
  end if
  return difference == 0
end function

/// Performs the copyExact operation for the minisql common diagnostics module.
/// Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param destination destination value consumed by this operation.
/// @param destinationOffset destinationOffset value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param sourceOffset sourceOffset value consumed by this operation.
/// @param count Number of items or units to process.
function copyExact(destination, destinationOffset, source, sourceOffset, count)
  copyBytes(destination, destinationOffset, source, sourceOffset, count)
  return destinationOffset + count
end function

/// Reads whole for the minisql common diagnostics workflow.
/// Inputs: `path`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
/// @param maximum maximum value consumed by this operation.
function readWhole(path, maximum)
  if not file_api.fileExists(path) then return bytes(0) end if
  file = file_api.openRead(path)
  length = file_api.size(file)
  if length > maximum then file_api.close(file); return fail(CORRUPT_DATA, "readWhole", "audit file exceeds safety limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(file, 0, output, 0, length) end if
  file_api.close(file)
  return output
end function

/// Writes the whole durable.
/// Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param path Path of the file or directory used by the operation.
/// @param data Input data consumed by the operation.
function writeWholeDurable(path, data)
  file = file_api.createDurable(path)
  if len(data) > 0 then file_api.writeAt(file, 0, data, 0, len(data)) end if
  file_api.flush(file)
  file_api.close(file)
  return true
end function

/// Validates the detail.
/// Inputs: `detail`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param detail detail value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateDetail(detail, operation)
  if typeof(detail) != "string" then return fail(INVALID_ARGUMENT, operation, "detail must be string") end if
  raw = bytes(detail)
  if len(raw) > MAX_AUDIT_DETAIL_BYTES then return fail(INVALID_ARGUMENT, operation, "detail exceeds audit limit") end if
  for each value in raw
    if value == 0 then return fail(INVALID_ARGUMENT, operation, "detail must not contain NUL") end if
  end for
  return raw
end function

/// Performs the record digest operation for this module.
/// Inputs: `key`, `header`, `detailBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param key key value consumed by this operation.
/// @param header header value consumed by this operation.
/// @param detailBytes detailBytes value consumed by this operation.
function recordDigest(key, header, detailBytes)
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "recordDigest", "audit key is invalid") end if
  material = bytes(88 + len(detailBytes), 0)
  copyExact(material, 0, header, 0, 88)
  if len(detailBytes) > 0 then copyExact(material, 88, detailBytes, 0, len(detailBytes)) end if
  digest = uuid.hmacSha256(key, material)
  uuid.wipeSecret(material)
  return digest
end function

/// Encodes the audit record.
/// Inputs: `key`, `sequence`, `timestamp`, `eventType`, `outcome`, `sessionId`, `principalId`, `previousHash`, `detail`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param key key value consumed by this operation.
/// @param sequence sequence value consumed by this operation.
/// @param timestamp timestamp value consumed by this operation.
/// @param eventType eventType value consumed by this operation.
/// @param outcome outcome value consumed by this operation.
/// @param sessionId Identifier of session.
/// @param principalId Identifier of principal.
/// @param previousHash previousHash value consumed by this operation.
/// @param detail detail value consumed by this operation.
function encodeAuditRecord(key, sequence, timestamp, eventType, outcome, sessionId, principalId, previousHash, detail)
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "audit key is invalid") end if
  if typeof(sequence) != "int" or sequence < 1 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "sequence must be positive") end if
  if typeof(timestamp) != "int" or timestamp < 0 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "timestamp is invalid") end if
  if typeof(eventType) != "int" or eventType < 1 or eventType > AUDIT_ROTATION then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "event type is invalid") end if
  if outcome != AUDIT_FAILURE and outcome != AUDIT_SUCCESS then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "outcome is invalid") end if
  if typeof(sessionId) != "int" or sessionId < 0 or typeof(principalId) != "int" or principalId < 0 then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "identifiers are invalid") end if
  if typeof(previousHash) != "bytes" or len(previousHash) != AUDIT_HASH_BYTES then return fail(INVALID_ARGUMENT, "encodeAuditRecord", "previous hash is invalid") end if
  detailBytes = validateDetail(detail, "encodeAuditRecord")
  output = bytes(AUDIT_HEADER_BYTES + len(detailBytes), 0)
  copyExact(output, 0, auditMagic(), 0, 8)
  endian.writeU16LE(output, 8, AUDIT_VERSION)
  endian.writeU16LE(output, 10, eventType)
  endian.writeU16LE(output, 12, outcome)
  endian.writeU16LE(output, 14, 0)
  endian.writeU64LE(output, 16, endian.uint64FromInt(sequence))
  endian.writeU64LE(output, 24, endian.uint64FromInt(timestamp))
  endian.writeU64LE(output, 32, endian.uint64FromInt(sessionId))
  endian.writeU64LE(output, 40, endian.uint64FromInt(principalId))
  endian.writeU32LE(output, 48, len(detailBytes))
  endian.writeU32LE(output, 52, 0)
  copyExact(output, 56, previousHash, 0, AUDIT_HASH_BYTES)
  digest = recordDigest(key, output, detailBytes)
  copyExact(output, 88, digest, 0, AUDIT_HASH_BYTES)
  if len(detailBytes) > 0 then copyExact(output, AUDIT_HEADER_BYTES, detailBytes, 0, len(detailBytes)) end if
  uuid.wipeSecret(digest)
  return output
end function

/// Scans the audit bytes from sequence.
/// Inputs: `source`, `key`, `expectedPreviousHash`, `expectedPreviousSequence`, `allowTornTail`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param source source value consumed by this operation.
/// @param key key value consumed by this operation.
/// @param expectedPreviousHash expectedPreviousHash value consumed by this operation.
/// @param expectedPreviousSequence expectedPreviousSequence value consumed by this operation.
/// @param allowTornTail allowTornTail value consumed by this operation.
function scanAuditBytesFromSequence(source, key, expectedPreviousHash, expectedPreviousSequence, allowTornTail)
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "source must be bytes") end if
  if typeof(key) != "bytes" or len(key) != AUDIT_KEY_BYTES then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "audit key is invalid") end if
  if typeof(expectedPreviousHash) != "bytes" or len(expectedPreviousHash) != AUDIT_HASH_BYTES then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "expected hash is invalid") end if
  if typeof(expectedPreviousSequence) != "int" or expectedPreviousSequence < 0 then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "expected previous sequence is invalid") end if
  if typeof(allowTornTail) != "bool" then return fail(INVALID_ARGUMENT, "scanAuditBytesFromSequence", "allowTornTail must be bool") end if
  cursor = 0
  count = 0
  sequence = expectedPreviousSequence
  previous = bytes(expectedPreviousHash)
  while cursor < len(source)
    remaining = len(source) - cursor
    if remaining < AUDIT_HEADER_BYTES then
      if allowTornTail then break end if
      return fail(CORRUPT_DATA, "scanAuditBytes", "audit tail is truncated")
    end if
    header = slice(source, cursor, AUDIT_HEADER_BYTES)
    if not bytesEqual(slice(header, 0, 8), auditMagic()) then return fail(CORRUPT_DATA, "scanAuditBytes", "audit magic mismatch") end if
    if endian.readU16LE(header, 8) != AUDIT_VERSION or endian.readU16LE(header, 14) != 0 or endian.readU32LE(header, 52) != 0 then return fail(CORRUPT_DATA, "scanAuditBytes", "audit header is unsupported") end if
    eventType = endian.readU16LE(header, 10)
    outcome = endian.readU16LE(header, 12)
    if eventType < AUDIT_LOGIN or eventType > AUDIT_ROTATION then return fail(CORRUPT_DATA, "scanAuditBytes", "audit event type is invalid") end if
    if outcome != AUDIT_FAILURE and outcome != AUDIT_SUCCESS then return fail(CORRUPT_DATA, "scanAuditBytes", "audit outcome is invalid") end if
    detailLength = endian.readU32LE(header, 48)
    if detailLength > MAX_AUDIT_DETAIL_BYTES then return fail(CORRUPT_DATA, "scanAuditBytes", "audit detail exceeds limit") end if
    total = AUDIT_HEADER_BYTES + detailLength
    if remaining < total then
      if allowTornTail then break end if
      return fail(CORRUPT_DATA, "scanAuditBytes", "audit record is truncated")
    end if
    currentSequence = endian.uint64ToInt(endian.readU64LE(header, 16))
    if currentSequence != sequence + 1 then return fail(CORRUPT_DATA, "scanAuditBytes", "audit sequence is not continuous") end if
    if not bytesEqual(slice(header, 56, AUDIT_HASH_BYTES), previous) then return fail(CORRUPT_DATA, "scanAuditBytes", "audit hash chain is broken") end if
    detailBytes = slice(source, cursor + AUDIT_HEADER_BYTES, detailLength)
    expected = recordDigest(key, header, detailBytes)
    actual = slice(header, 88, AUDIT_HASH_BYTES)
    valid = bytesEqual(expected, actual)
    uuid.wipeSecret(expected)
    if not valid then return fail(CORRUPT_DATA, "scanAuditBytes", "audit record hash mismatch") end if
    uuid.wipeSecret(previous)
    previous = actual
    sequence = currentSequence
    count = count + 1
    cursor = cursor + total
  end while
  return AuditScan(count, sequence, previous, cursor)
end function

/// Scans the audit bytes.
/// Inputs: `source`, `key`, `expectedPreviousHash`, `allowTornTail`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param source source value consumed by this operation.
/// @param key key value consumed by this operation.
/// @param expectedPreviousHash expectedPreviousHash value consumed by this operation.
/// @param allowTornTail allowTornTail value consumed by this operation.
function scanAuditBytes(source, key, expectedPreviousHash, allowTornTail)
  return scanAuditBytesFromSequence(source, key, expectedPreviousHash, 0, allowTornTail)
end function

/// Ensures the directory.
/// Inputs: `path`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param path Path of the file or directory used by the operation.
function ensureDirectory(path)
  if file_api.directoryExists(path) then return true end if
  return file_api.createDirectory(path)
end function

/// Performs the audit key path operation for this module.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function auditKeyPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.key")
end function

/// Performs the audit anchor path operation for this module.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function auditAnchorPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.anchor")
end function

/// Performs the audit previous path operation for this module.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function auditPreviousPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.previous")
end function

/// Performs the audit previous anchor path operation for this module.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function auditPreviousAnchorPath(databasePath)
  return file_api.joinPath(file_api.joinPath(databasePath, "audit"), "audit.previous.anchor")
end function

/// Reads the audit key.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function readAuditKey(databasePath)
  path = auditKeyPath(databasePath)
  if not file_api.fileExists(path) then return fail(CORRUPT_DATA, "readAuditKey", "audit key is missing") end if
  key = readWhole(path, AUDIT_KEY_BYTES)
  if len(key) != AUDIT_KEY_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "readAuditKey", "audit key is invalid") end if
  return key
end function

/// Ensures the audit key.
/// Inputs: `databasePath`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param databasePath Path associated with database.
function ensureAuditKey(databasePath)
  path = auditKeyPath(databasePath)
  if file_api.fileExists(path) then return readAuditKey(databasePath) end if
  key = uuid.randomBytes(AUDIT_KEY_BYTES)
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then uuid.wipeSecret(key); return handle end if
  written = try(file_api.writeAt(handle, 0, key, 0, len(key)))
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(written) == "error" then uuid.wipeSecret(key); return written end if
  if typeof(flushed) == "error" then uuid.wipeSecret(key); return flushed end if
  if typeof(closed) == "error" then uuid.wipeSecret(key); return closed end if
  return key
end function

/// Opens the audit.
/// Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param databasePath Path associated with database.
function openAudit(databasePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "openAudit", "databasePath must be non-empty") end if
  auditDirectory = file_api.joinPath(databasePath, "audit")
  ensureDirectory(auditDirectory)
  anchorPath = file_api.joinPath(auditDirectory, "audit.anchor")
  logPath = file_api.joinPath(auditDirectory, "audit.log")
  key = try(ensureAuditKey(databasePath))
  if typeof(key) == "error" then return key end if
  if not file_api.fileExists(anchorPath) then writeWholeDurable(anchorPath, zeroHash()) end if
  anchor = readWhole(anchorPath, AUDIT_HASH_BYTES)
  if len(anchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "openAudit", "audit anchor is invalid") end if
  if not file_api.fileExists(logPath) then writeWholeDurable(logPath, bytes(0)) end if
  source = readWhole(logPath, MAX_AUDIT_FILE_BYTES)
  scanned = try(scanAuditBytes(source, key, anchor, true))
  if typeof(scanned) == "error" then uuid.wipeSecret(key); return scanned end if
  if scanned.validBytes != len(source) then
    repair = file_api.openReadWrite(logPath, false)
    file_api.truncate(repair, scanned.validBytes)
    file_api.flush(repair)
    file_api.close(repair)
  end if
  file = file_api.openReadWrite(logPath, false)
  return AuditLog(logPath, file, key, scanned.lastSequence + 1, bytes(scanned.lastHash), false)
end function

/// Validates the audit open.
/// Inputs: `log`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param log log value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateAuditOpen(log, operation)
  if log is not AuditLog then return fail(INVALID_ARGUMENT, operation, "log must be AuditLog") end if
  if log.closed then return fail(CLOSED_HANDLE, operation, "audit log is closed") end if
  return true
end function

/// Appends the audit.
/// Inputs: `log`, `eventType`, `outcome`, `sessionId`, `principalId`, `detail`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param eventType eventType value consumed by this operation.
/// @param outcome outcome value consumed by this operation.
/// @param sessionId Identifier of session.
/// @param principalId Identifier of principal.
/// @param detail detail value consumed by this operation.
function appendAudit(log, eventType, outcome, sessionId, principalId, detail)
  validateAuditOpen(log, "appendAudit")
  unixMilliseconds = time_api.datetime.nowUnixMillisUtc()
  if unixMilliseconds is void then return fail(IO_FAILURE, "appendAudit", "UTC clock is unavailable") end if
  // Keep the existing FILETIME epoch and 100-nanosecond unit in the durable
  // format so audit records are interchangeable between Windows and Linux.
  timestamp = (unixMilliseconds + 11644473600000) * 10000
  encoded = encodeAuditRecord(log.key, log.nextSequence, timestamp, eventType, outcome, sessionId, principalId, log.lastHash, detail)
  // Validate the one-record suffix before publishing it. A full segment starts
  // at sequence 1, but an append suffix may start at any later sequence and must
  // therefore carry its predecessor sequence explicitly.
  scanned = scanAuditBytesFromSequence(encoded, log.key, log.lastHash, log.nextSequence - 1, false)
  offset = file_api.append(log.file, encoded, 0, len(encoded))
  file_api.flush(log.file)
  uuid.wipeSecret(log.lastHash)
  log.lastHash = bytes(scanned.lastHash)
  log.nextSequence = scanned.lastSequence + 1
  return offset
end function

/// Verifies the audit.
/// Inputs: `databasePath`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param databasePath Path associated with database.
function verifyAudit(databasePath)
  auditDirectory = file_api.joinPath(databasePath, "audit")
  anchorPath = auditAnchorPath(databasePath)
  logPath = file_api.joinPath(auditDirectory, "audit.log")
  if not file_api.fileExists(anchorPath) or not file_api.fileExists(logPath) then return fail(CORRUPT_DATA, "verifyAudit", "audit files are missing") end if
  key = try(readAuditKey(databasePath))
  if typeof(key) == "error" then return key end if
  anchor = readWhole(anchorPath, AUDIT_HASH_BYTES)
  if len(anchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "audit anchor is invalid") end if
  previousPath = auditPreviousPath(databasePath)
  previousAnchorPath = auditPreviousAnchorPath(databasePath)
  if file_api.fileExists(previousPath) then
    if not file_api.fileExists(previousAnchorPath) then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor is missing") end if
    previousAnchor = readWhole(previousAnchorPath, AUDIT_HASH_BYTES)
    if len(previousAnchor) != AUDIT_HASH_BYTES then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor is invalid") end if
    previous = try(scanAuditBytes(readWhole(previousPath, MAX_AUDIT_FILE_BYTES), key, previousAnchor, false))
    if typeof(previous) == "error" then uuid.wipeSecret(key); return previous end if
    if not bytesEqual(previous.lastHash, anchor) then uuid.wipeSecret(key); return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor mismatch") end if
  else if file_api.fileExists(previousAnchorPath) then
    uuid.wipeSecret(key)
    return fail(CORRUPT_DATA, "verifyAudit", "rotated audit anchor exists without segment")
  end if
  result = try(scanAuditBytes(readWhole(logPath, MAX_AUDIT_FILE_BYTES), key, anchor, false))
  uuid.wipeSecret(key)
  if typeof(result) == "error" then return result end if
  return result
end function

/// Performs the rotate audit operation for this module.
/// Inputs: `log`, `databasePath`, `sessionId`, `principalId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param databasePath Path associated with database.
/// @param sessionId Identifier of session.
/// @param principalId Identifier of principal.
function rotateAudit(log, databasePath, sessionId, principalId)
  validateAuditOpen(log, "rotateAudit")
  // Preserve the starting hash of the segment being rotated. After the second
  // and later rotation this is intentionally non-zero; assuming zero would make
  // an otherwise valid retained segment unverifiable.
  startingAnchor = readWhole(auditAnchorPath(databasePath), AUDIT_HASH_BYTES)
  if len(startingAnchor) != AUDIT_HASH_BYTES then return fail(CORRUPT_DATA, "rotateAudit", "current audit anchor is invalid") end if
  appendAudit(log, AUDIT_ROTATION, AUDIT_SUCCESS, sessionId, principalId, "audit rotation")
  finalHash = bytes(log.lastHash)
  file_api.close(log.file)
  log.closed = true
  previousPath = auditPreviousPath(databasePath)
  previousAnchorPath = auditPreviousAnchorPath(databasePath)
  if file_api.fileExists(previousPath) then file_api.deletePath(previousPath) end if
  if file_api.fileExists(previousAnchorPath) then file_api.deletePath(previousAnchorPath) end if
  file_api.movePath(log.path, previousPath, false)
  writeWholeDurable(previousAnchorPath, startingAnchor)
  writeWholeDurable(auditAnchorPath(databasePath), finalHash)
  writeWholeDurable(log.path, bytes(0))
  return openAudit(databasePath)
end function

/// Performs the snapshot audit bytes operation for this module.
/// Inputs: `log`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
/// @param maximum maximum value consumed by this operation.
function snapshotAuditBytes(log, maximum)
  validateAuditOpen(log, "snapshotAuditBytes")
  if typeof(maximum) != "int" or maximum < 0 or maximum > MAX_AUDIT_FILE_BYTES then return fail(INVALID_ARGUMENT, "snapshotAuditBytes", "maximum is invalid") end if
  file_api.flush(log.file)
  length = file_api.size(log.file)
  if length > maximum then return fail(CORRUPT_DATA, "snapshotAuditBytes", "audit file exceeds snapshot limit") end if
  output = bytes(length, 0)
  if length > 0 then file_api.readExactAt(log.file, 0, output, 0, length) end if
  return output
end function

/// Performs the snapshot audit key operation for this module.
/// Inputs: `log`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param log log value consumed by this operation.
function snapshotAuditKey(log)
  validateAuditOpen(log, "snapshotAuditKey")
  return bytes(log.key)
end function

/// Closes the audit.
/// Inputs: `log`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param log log value consumed by this operation.
function closeAudit(log)
  validateAuditOpen(log, "closeAudit")
  file_api.flush(log.file)
  file_api.close(log.file)
  uuid.wipeSecret(log.lastHash)
  uuid.wipeSecret(log.key)
  log.key = void
  log.closed = true
  return true
end function

/// Performs the componentName operation for the minisql common diagnostics module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.diagnostics"
end function

/// Performs the targetMilestone operation for the minisql common diagnostics module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

/// Returns whether implemented satisfies the condition required by the minisql common diagnostics module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
