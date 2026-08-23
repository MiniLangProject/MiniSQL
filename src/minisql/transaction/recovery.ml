package minisql.transaction.recovery
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.ds.hashmap as hashmap
import std.ds.list as list
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.transaction.wal as wal

// Crash recovery reconstructs transaction status from the WAL, redoes committed
// page images in log order, and restores before-images for incomplete work in
// reverse order. Page LSN checks make repeated recovery idempotent.

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004

// Defines the recovery target record used by this module.
struct RecoveryTarget
  // File id field of the recovery target.
  fileId
  // Open paged file that receives redo, or void for a deliberately retired file ID.
  pagedFile
  // Distinguishes a dropped file from an accidentally omitted live recovery target.
  retired
end struct

// Defines the transaction status record used by this module.
struct TransactionStatus
  // Transaction id field of the transaction status.
  transactionId
  // Begun field of the transaction status.
  begun
  // Committed field of the transaction status.
  committed
  // Aborted field of the transaction status.
  aborted
end struct

// Defines the recovery result record used by this module.
struct RecoveryResult
  // Scanned records field of the recovery result.
  scannedRecords
  // Committed transactions field of the recovery result.
  committedTransactions
  // Pages redone field of the recovery result.
  pagesRedone
  // Pages skipped field of the recovery result.
  pagesSkipped
  // Valid wal bytes field of the recovery result.
  validWalBytes
  // Truncated tail field of the recovery result.
  truncatedTail
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "transaction.recovery." + operation + ": " + message)
end function

// Performs the target operation for this module.
// Inputs: `fileId`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.
function target(fileId, pagedFile)
  if typeof(fileId) != "int" or fileId < 0 then return fail(INVALID_ARGUMENT, "target", "fileId must be non-negative") end if
  paged_file.validateOpen(pagedFile, "recovery.target")
  if pagedFile.fileId != fileId then return fail(INVALID_ARGUMENT, "target", "file ID mismatch") end if
  return RecoveryTarget(fileId, pagedFile, false)
end function

// Marks one durable object ID as intentionally retired so historical committed
// WAL images for a dropped file are counted as skipped instead of treated as an
// accidentally omitted live target. Callers must prove retirement from their
// current durable catalog; the generic recovery entry points remain strict.
// Inputs: `fileId`. Returns a target without an open paged file.
function retiredTarget(fileId)
  if typeof(fileId) != "int" or fileId < 0 then return fail(INVALID_ARGUMENT, "retiredTarget", "fileId must be non-negative") end if
  return RecoveryTarget(fileId, void, true)
end function

// Finds the target.
// Inputs: `targets`, `fileId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findTarget(targets, fileId)
  for each current in targets
    if current is not RecoveryTarget then return fail(INVALID_ARGUMENT, "findTarget", "invalid recovery target") end if
    if current.fileId == fileId then return current end if
  end for
  return void
end function

// Finds the status.
// Inputs: `statuses`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findStatus(statuses, transactionId)
  if len(statuses) == 0 then return -1 end if
  for index = 0 to len(statuses) - 1
    if statuses[index].transactionId == transactionId then return index end if
  end for
  return -1
end function

// Builds the statuses.
// Inputs: `records`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function buildStatuses(records, startLsn)
  statuses = list.List.new()
  statusMap = hashmap.HashMap.new()
  for each record in records
    if record.lsn >= startLsn and (record.recordType == wal.RECORD_TX_BEGIN or record.recordType == wal.RECORD_PAGE_IMAGE or record.recordType == wal.RECORD_TX_COMMIT or record.recordType == wal.RECORD_TX_ABORT) then
      status = statusMap.get(record.transactionId)
      if typeof(status) == "void" then
        status = TransactionStatus(record.transactionId, false, false, false)
        statuses.add(status)
        statusMap.set(record.transactionId, status)
      end if
      if record.recordType == wal.RECORD_TX_BEGIN then
        if status.begun then return fail(CORRUPT_DATA, "buildStatuses", "duplicate TX_BEGIN") end if
        status.begun = true
      else if record.recordType == wal.RECORD_PAGE_IMAGE then
        if not status.begun or status.committed or status.aborted then return fail(CORRUPT_DATA, "buildStatuses", "PAGE_IMAGE outside active transaction") end if
      else if record.recordType == wal.RECORD_TX_COMMIT then
        if not status.begun or status.committed or status.aborted then return fail(CORRUPT_DATA, "buildStatuses", "invalid TX_COMMIT sequence") end if
        status.committed = true
      else
        if not status.begun or status.committed or status.aborted then return fail(CORRUPT_DATA, "buildStatuses", "invalid TX_ABORT sequence") end if
        status.aborted = true
      end if
    end if
  end for
  return statuses.toArray()
end function

// Evaluates whether the supplied input satisfies the committed predicate.
// Inputs: `statuses`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isCommitted(statuses, transactionId)
  index = findStatus(statuses, transactionId)
  if index < 0 then return false end if
  return statuses[index].committed and not statuses[index].aborted
end function

// Applies the page.
// Inputs: `record`, `destination`. Returns the produced value or propagates a structured error from validation or delegated operations.
function applyPage(record, destination, forceRedo)
  image = bytes(record.payload)
  header = page.verify(image)
  if header.pageId.fileId != record.fileId or header.pageId.pageNumber != record.pageNumber then return fail(CORRUPT_DATA, "applyPage", "page identity mismatch") end if
  if page.compareLsn(header.pageLsn, endian.uint64FromInt(record.pageLsn)) != 0 then return fail(CORRUPT_DATA, "applyPage", "pageLSN mismatch") end if
  file = destination.pagedFile
  if len(image) != file.pageSize then return fail(CORRUPT_DATA, "applyPage", "page-size mismatch") end if
  if record.pageNumber > file.pageCount then return fail(CORRUPT_DATA, "applyPage", "page image would create a gap") end if
  if record.pageNumber == file.pageCount then
    paged_file.appendPage(file, image)
    return true
  end if
  current = paged_file.readPage(file, record.pageNumber)
  currentHeader = page.verify(current)
  if not forceRedo and page.compareLsn(currentHeader.pageLsn, header.pageLsn) >= 0 then return false end if
  paged_file.writePage(file, record.pageNumber, image)
  return true
end function

// Recovers the scan.
// Inputs: `scanResult`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function recoverScanMode(scanResult, targets, startLsn, forceRedo)
  if not wal.isWalScan(scanResult) then return fail(INVALID_ARGUMENT, "recoverScan", "scanResult must be WalScan") end if
  if typeof(targets) != "array" then return fail(INVALID_ARGUMENT, "recoverScan", "targets must be array") end if
  if typeof(startLsn) != "int" or startLsn < 0 then return fail(INVALID_ARGUMENT, "recoverScan", "startLsn must be non-negative") end if
  if typeof(forceRedo) != "bool" then return fail(INVALID_ARGUMENT, "recoverScan", "forceRedo must be bool") end if
  effectiveStart = startLsn
  if forceRedo then effectiveStart = 0 end if
  // Build the immutable lookup once. Recovery cost is linear in WAL records
  // even when a database owns thousands of live or retired table file IDs.
  targetMap = hashmap.HashMap.new()
  for each current in targets
    if current is not RecoveryTarget then return fail(INVALID_ARGUMENT, "recoverScan", "invalid recovery target") end if
    if targetMap.has(current.fileId) then return fail(INVALID_ARGUMENT, "recoverScan", "duplicate recovery target for file " + current.fileId) end if
    targetMap.set(current.fileId, current)
  end for
  statuses = buildStatuses(scanResult.records, effectiveStart)
  statusMap = hashmap.HashMap.withCapacity(len(statuses) * 2)
  committed = 0
  for each status in statuses
    statusMap.set(status.transactionId, status)
    if status.committed and not status.aborted then committed = committed + 1 end if
  end for
  redone = 0
  skipped = 0
  touched = []
  for each record in scanResult.records
    if record.lsn >= effectiveStart and record.recordType == wal.RECORD_PAGE_IMAGE then
      status = statusMap.get(record.transactionId)
      if typeof(status) != "void" and status.committed and not status.aborted then
        destination = void
        if targetMap.has(record.fileId) then destination = targetMap.get(record.fileId) end if
        if destination is void then return fail(CORRUPT_DATA, "recoverScan", "missing recovery target for file " + record.fileId) end if
        if destination.retired then
          // Object IDs are never reused. Once the durable catalog proves that a
          // file was dropped, replaying its older images would resurrect data.
          skipped = skipped + 1
        else
          changed = applyPage(record, destination, forceRedo)
          if changed then
            redone = redone + 1
            already = false
            for each existing in touched
              if existing.fileId == destination.fileId then already = true end if
            end for
            if not already then touched = touched + [destination] end if
          else
            skipped = skipped + 1
          end if
        end if
      else
        skipped = skipped + 1
      end if
    end if
  end for
  for each destination in touched
    paged_file.flush(destination.pagedFile)
  end for
  return RecoveryResult(len(scanResult.records), committed, redone, skipped, scanResult.validBytes, scanResult.truncatedTail)
end function

// Recovers a conventional monotonically increasing WAL using page-LSN skips.
function recoverScan(scanResult, targets, startLsn)
  return recoverScanMode(scanResult, targets, startLsn, false)
end function

// Replays every committed image in the bounded post-reset WAL. Page LSNs from
// an earlier physical WAL epoch may be numerically larger, so they cannot be a
// skip predicate. Full page-image replay is still idempotent and log ordered.
function recoverScanForced(scanResult, targets)
  return recoverScanMode(scanResult, targets, 0, true)
end function

// Recovers the requested value.
// Inputs: `log`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function recover(log, targets, startLsn)
  wal.validateOpen(log, "recovery.recover")
  scanned = wal.scan(log, true)
  return recoverScan(scanned, targets, startLsn)
end function

// Recovers the path.
// Inputs: `path`, `segmentBytes`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.
function recoverPath(path, segmentBytes, targets, startLsn)
  log = wal.open(path, segmentBytes)
  result = try(recover(log, targets, startLsn))
  wal.close(log)
  if typeof(result) == "error" then return result end if
  return result
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "transaction.recovery"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M7"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
