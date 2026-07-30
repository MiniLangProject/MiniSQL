package minisql.transaction.transaction

import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.transaction.wal as wal

const INVALID_ARGUMENT = 9001
const TRANSACTION_STATE = 9011
const READ_ONLY_VIOLATION = 9012

const ISOLATION_READ_COMMITTED = 1
const ISOLATION_SERIALIZABLE = 2

struct PageChange
  fileId
  pageNumber
  pageBytes
end struct

struct Savepoint
  name
  changes
end struct

struct Transaction
  transactionId
  state
  isolationLevel
  readOnly
  beginLsn
  commitLsn
  walWriter
  beginLogged
  changes
  committedChanges
  savepoints
end struct

struct TransactionManager
  nextTransactionId
end struct

enum TransactionState
  Idle = 0
  Active = 1
  Failed = 2
  Committing = 3
  Committed = 4
  Aborted = 5
end enum

function fail(code, operation, message)
  return error(code, "transaction.transaction." + operation + ": " + message)
end function

function validateId(value, operation)
  if typeof(value) != "int" or value <= 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, "transactionId must be positive") end if
  return true
end function

function validateIsolation(value, operation)
  if value != ISOLATION_READ_COMMITTED and value != ISOLATION_SERIALIZABLE then return fail(INVALID_ARGUMENT, operation, "unsupported isolation level") end if
  return true
end function

function validateTransaction(transaction, operation)
  if transaction is not Transaction then return fail(INVALID_ARGUMENT, operation, "value must be Transaction") end if
  return true
end function

function requireActive(transaction, operation)
  validateTransaction(transaction, operation)
  if transaction.state != TransactionState.Active then return fail(TRANSACTION_STATE, operation, "transaction is not active") end if
  return true
end function

function beginTransaction(transactionId, isolationLevel, readOnly, walWriter)
  validateId(transactionId, "beginTransaction")
  validateIsolation(isolationLevel, "beginTransaction")
  if typeof(readOnly) != "bool" then return fail(INVALID_ARGUMENT, "beginTransaction", "readOnly must be bool") end if
  wal.validateOpen(walWriter, "transaction.beginTransaction")
  return Transaction(transactionId, TransactionState.Active, isolationLevel, readOnly, 0, 0, walWriter, false, [], [], [])
end function

function createManager(firstTransactionId)
  validateId(firstTransactionId, "createManager")
  return TransactionManager(firstTransactionId)
end function

function beginManaged(manager, isolationLevel, readOnly, walWriter)
  if manager is not TransactionManager then return fail(INVALID_ARGUMENT, "beginManaged", "manager must be TransactionManager") end if
  id = manager.nextTransactionId
  if id >= endian.MAX_MINILANG_INT then return fail(TRANSACTION_STATE, "beginManaged", "transaction ID space is exhausted") end if
  manager.nextTransactionId = manager.nextTransactionId + 1
  return beginTransaction(id, isolationLevel, readOnly, walWriter)
end function

function findChange(transaction, fileId, pageNumber)
  if len(transaction.changes) == 0 then return -1 end if
  for index = 0 to len(transaction.changes) - 1
    change = transaction.changes[index]
    if change.fileId == fileId and change.pageNumber == pageNumber then return index end if
  end for
  return -1
end function

function stagePage(transaction, fileId, pageNumber, pageBytes)
  requireActive(transaction, "stagePage")
  if transaction.readOnly then return fail(READ_ONLY_VIOLATION, "stagePage", "read-only transaction cannot stage pages") end if
  if typeof(fileId) != "int" or fileId < 0 or typeof(pageNumber) != "int" or pageNumber < 0 then return fail(INVALID_ARGUMENT, "stagePage", "file/page IDs must be non-negative") end if
  if typeof(pageBytes) != "bytes" then return fail(INVALID_ARGUMENT, "stagePage", "pageBytes must be bytes") end if
  header = page.verify(pageBytes)
  if header.pageId.fileId != fileId or header.pageId.pageNumber != pageNumber then return fail(INVALID_ARGUMENT, "stagePage", "page identity mismatch") end if
  change = PageChange(fileId, pageNumber, bytes(pageBytes))
  index = findChange(transaction, fileId, pageNumber)
  if index < 0 then
    transaction.changes = transaction.changes + [change]
  else
    transaction.changes[index] = change
  end if
  return true
end function

function stagedPageCount(transaction)
  validateTransaction(transaction, "stagedPageCount")
  return len(transaction.changes)
end function

function readPrivatePage(transaction, fileId, pageNumber)
  validateTransaction(transaction, "readPrivatePage")
  index = findChange(transaction, fileId, pageNumber)
  if index < 0 then return void end if
  return bytes(transaction.changes[index].pageBytes)
end function

function markFailed(transaction)
  validateTransaction(transaction, "markFailed")
  transaction.state = TransactionState.Failed
  return true
end function

function cloneChanges(changes)
  output = []
  for each change in changes
    output = output + [PageChange(change.fileId, change.pageNumber, bytes(change.pageBytes))]
  end for
  return output
end function

function validateSavepointName(name, operation)
  if typeof(name) != "string" or len(name) == 0 or len(bytes(name)) > 128 then return fail(INVALID_ARGUMENT, operation, "savepoint name must be 1..128 UTF-8 bytes") end if
  return true
end function

function savepoint(transaction, name)
  requireActive(transaction, "savepoint")
  validateSavepointName(name, "savepoint")
  transaction.savepoints = transaction.savepoints + [Savepoint(name, cloneChanges(transaction.changes))]
  return len(transaction.savepoints)
end function

function findSavepoint(transaction, name)
  if len(transaction.savepoints) == 0 then return -1 end if
  index = len(transaction.savepoints) - 1
  while index >= 0
    if transaction.savepoints[index].name == name then return index end if
    index = index - 1
  end while
  return -1
end function

function rollbackToSavepoint(transaction, name)
  validateTransaction(transaction, "rollbackToSavepoint")
  validateSavepointName(name, "rollbackToSavepoint")
  if transaction.state != TransactionState.Active and transaction.state != TransactionState.Failed then return fail(TRANSACTION_STATE, "rollbackToSavepoint", "transaction is not active or failed") end if
  index = findSavepoint(transaction, name)
  if index < 0 then return fail(TRANSACTION_STATE, "rollbackToSavepoint", "savepoint not found: " + name) end if
  transaction.changes = cloneChanges(transaction.savepoints[index].changes)
  retained = []
  for position = 0 to index
    retained = retained + [transaction.savepoints[position]]
  end for
  transaction.savepoints = retained
  transaction.state = TransactionState.Active
  return true
end function

function releaseSavepoint(transaction, name)
  requireActive(transaction, "releaseSavepoint")
  validateSavepointName(name, "releaseSavepoint")
  index = findSavepoint(transaction, name)
  if index < 0 then return fail(TRANSACTION_STATE, "releaseSavepoint", "savepoint not found: " + name) end if
  retained = []
  if index > 0 then
    for position = 0 to index - 1
      retained = retained + [transaction.savepoints[position]]
    end for
  end if
  transaction.savepoints = retained
  return true
end function

function savepointCount(transaction)
  validateTransaction(transaction, "savepointCount")
  return len(transaction.savepoints)
end function

function failCommit(transaction, startLsn, failure)
  // A low-level write may have reached only part of a WAL record. Always return
  // the append region to its pre-transaction boundary before exposing failure.
  // Rewind is best-effort here so the original I/O error is preserved; opening
  // the WAL also repairs an incomplete physical tail after a process crash.
  ignored = try(wal.rewind(transaction.walWriter, startLsn))
  transaction.beginLsn = 0
  transaction.commitLsn = 0
  transaction.beginLogged = false
  transaction.state = TransactionState.Failed
  return failure
end function

function commit(transaction)
  requireActive(transaction, "commit")
  startLsn = transaction.walWriter.nextLsn
  transaction.state = TransactionState.Committing
  beginResult = try(wal.appendBegin(transaction.walWriter, transaction.transactionId))
  if typeof(beginResult) == "error" then return failCommit(transaction, startLsn, beginResult) end if
  transaction.beginLsn = beginResult.lsn
  transaction.beginLogged = true
  if len(transaction.changes) > 0 then
    for each change in transaction.changes
      pageResult = try(wal.appendPageImage(transaction.walWriter, transaction.transactionId, change.fileId, change.pageNumber, change.pageBytes))
      if typeof(pageResult) == "error" then return failCommit(transaction, startLsn, pageResult) end if
    end for
  end if
  commitResult = try(wal.appendCommit(transaction.walWriter, transaction.transactionId))
  if typeof(commitResult) == "error" then return failCommit(transaction, startLsn, commitResult) end if
  flushResult = try(wal.flush(transaction.walWriter))
  if typeof(flushResult) == "error" then return failCommit(transaction, startLsn, flushResult) end if
  transaction.commitLsn = commitResult.lsn
  transaction.state = TransactionState.Committed
  // Keep a private immutable batch until the storage layer has published the
  // committed pages into its buffer pool/base files. WAL durability is already
  // established, so a publication failure is recovered by M7 redo.
  transaction.committedChanges = transaction.changes
  transaction.changes = []
  transaction.savepoints = []
  return transaction.commitLsn
end function

function committedPageCount(transaction)
  validateTransaction(transaction, "committedPageCount")
  return len(transaction.committedChanges)
end function

function committedPages(transaction)
  validateTransaction(transaction, "committedPages")
  if transaction.state != TransactionState.Committed then return fail(TRANSACTION_STATE, "committedPages", "transaction is not committed") end if
  result = []
  for each change in transaction.committedChanges
    result = result + [PageChange(change.fileId, change.pageNumber, bytes(change.pageBytes))]
  end for
  return result
end function

function acknowledgeCommittedPages(transaction)
  validateTransaction(transaction, "acknowledgeCommittedPages")
  if transaction.state != TransactionState.Committed then return fail(TRANSACTION_STATE, "acknowledgeCommittedPages", "transaction is not committed") end if
  transaction.committedChanges = []
  return true
end function

function takeCommittedPages(transaction)
  // Compatibility helper. Storage publication paths should prefer
  // committedPages() followed by acknowledgeCommittedPages() only after every
  // affected data file has been durably flushed.
  result = committedPages(transaction)
  acknowledgeCommittedPages(transaction)
  return result
end function

function rollback(transaction)
  validateTransaction(transaction, "rollback")
  if transaction.state == TransactionState.Committed or transaction.state == TransactionState.Aborted then return fail(TRANSACTION_STATE, "rollback", "transaction is already final") end if
  if transaction.beginLogged then
    abortResult = try(wal.appendAbort(transaction.walWriter, transaction.transactionId))
    if typeof(abortResult) != "error" then ignored = try(wal.flush(transaction.walWriter)) end if
  end if
  transaction.changes = []
  transaction.committedChanges = []
  transaction.savepoints = []
  transaction.state = TransactionState.Aborted
  return true
end function

function componentName()
  return "transaction.transaction"
end function

function targetMilestone()
  return "M6"
end function

function isImplemented()
  return true
end function
