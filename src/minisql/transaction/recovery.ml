package minisql.transaction.recovery

import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.transaction.wal as wal

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004

struct RecoveryTarget
  fileId
  pagedFile
end struct

struct TransactionStatus
  transactionId
  begun
  committed
  aborted
end struct

struct RecoveryResult
  scannedRecords
  committedTransactions
  pagesRedone
  pagesSkipped
  validWalBytes
  truncatedTail
end struct

function fail(code, operation, message)
  return error(code, "transaction.recovery." + operation + ": " + message)
end function

function target(fileId, pagedFile)
  if typeof(fileId) != "int" or fileId < 0 then return fail(INVALID_ARGUMENT, "target", "fileId must be non-negative") end if
  paged_file.validateOpen(pagedFile, "recovery.target")
  if pagedFile.fileId != fileId then return fail(INVALID_ARGUMENT, "target", "file ID mismatch") end if
  return RecoveryTarget(fileId, pagedFile)
end function

function findTarget(targets, fileId)
  for each current in targets
    if current is not RecoveryTarget then return fail(INVALID_ARGUMENT, "findTarget", "invalid recovery target") end if
    if current.fileId == fileId then return current end if
  end for
  return void
end function

function findStatus(statuses, transactionId)
  if len(statuses) == 0 then return -1 end if
  for index = 0 to len(statuses) - 1
    if statuses[index].transactionId == transactionId then return index end if
  end for
  return -1
end function

function buildStatuses(records, startLsn)
  statuses = []
  for each record in records
    if record.lsn >= startLsn and (record.recordType == wal.RECORD_TX_BEGIN or record.recordType == wal.RECORD_PAGE_IMAGE or record.recordType == wal.RECORD_TX_COMMIT or record.recordType == wal.RECORD_TX_ABORT) then
      index = findStatus(statuses, record.transactionId)
      if index < 0 then
        statuses = statuses + [TransactionStatus(record.transactionId, false, false, false)]
        index = len(statuses) - 1
      end if
      status = statuses[index]
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
  return statuses
end function

function isCommitted(statuses, transactionId)
  index = findStatus(statuses, transactionId)
  if index < 0 then return false end if
  return statuses[index].committed and not statuses[index].aborted
end function

function applyPage(record, destination)
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
  if page.compareLsn(currentHeader.pageLsn, header.pageLsn) >= 0 then return false end if
  paged_file.writePage(file, record.pageNumber, image)
  return true
end function

function recoverScan(scanResult, targets, startLsn)
  if not wal.isWalScan(scanResult) then return fail(INVALID_ARGUMENT, "recoverScan", "scanResult must be WalScan") end if
  if typeof(targets) != "array" then return fail(INVALID_ARGUMENT, "recoverScan", "targets must be array") end if
  if typeof(startLsn) != "int" or startLsn < 0 then return fail(INVALID_ARGUMENT, "recoverScan", "startLsn must be non-negative") end if
  statuses = buildStatuses(scanResult.records, startLsn)
  committed = 0
  for each status in statuses
    if status.committed and not status.aborted then committed = committed + 1 end if
  end for
  redone = 0
  skipped = 0
  touched = []
  for each record in scanResult.records
    if record.lsn >= startLsn and record.recordType == wal.RECORD_PAGE_IMAGE then
      if isCommitted(statuses, record.transactionId) then
        destination = findTarget(targets, record.fileId)
        if destination is void then return fail(CORRUPT_DATA, "recoverScan", "missing recovery target for file " + record.fileId) end if
        changed = applyPage(record, destination)
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

function recover(log, targets, startLsn)
  wal.validateOpen(log, "recovery.recover")
  scanned = wal.scan(log, true)
  return recoverScan(scanned, targets, startLsn)
end function

function recoverPath(path, segmentBytes, targets, startLsn)
  log = wal.open(path, segmentBytes)
  result = try(recover(log, targets, startLsn))
  wal.close(log)
  if typeof(result) == "error" then return result end if
  return result
end function

function componentName()
  return "transaction.recovery"
end function

function targetMilestone()
  return "M7"
end function

function isImplemented()
  return true
end function
