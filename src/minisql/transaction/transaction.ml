//! Provides minisql transaction transaction facilities for this project.

package minisql.transaction.transaction
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import minisql.storage.page as page
import minisql.transaction.wal as wal
import std.ds.hashmap as hashmap
import std.ds.list as list

/// Transaction state machine and page-level change tracking. Write-ahead-log

const INVALID_ARGUMENT = 9001
/// Defines the transaction state constant used by the minisql transaction transaction module.
const TRANSACTION_STATE = 9011
/// Defines the read only violation constant used by the minisql transaction transaction module.
const READ_ONLY_VIOLATION = 9012

/// Defines the isolation read committed constant used by the minisql transaction transaction module.
const ISOLATION_READ_COMMITTED = 1
/// Defines the isolation serializable constant used by the minisql transaction transaction module.
const ISOLATION_SERIALIZABLE = 2

/// Defines the page change record used by this module.
struct PageChange
  /// File id field of the page change.
  fileId
  /// Page number field of the page change.
  pageNumber
  /// Page bytes field of the page change.
  pageBytes
end struct

/// Defines the savepoint record used by this module.
struct Savepoint
  /// Name field of the savepoint.
  name
  /// Changes field of the savepoint.
  changes
end struct

/// Defines the transaction record used by this module.
struct Transaction
  /// Transaction id field of the transaction.
  transactionId
  /// State field of the transaction.
  state
  /// Isolation level field of the transaction.
  isolationLevel
  /// Read only field of the transaction.
  readOnly
  /// Begin lsn field of the transaction.
  beginLsn
  /// Commit lsn field of the transaction.
  commitLsn
  /// Wal writer field of the transaction.
  walWriter
  /// Begin logged field of the transaction.
  beginLogged
  /// Changes field of the transaction.
  changes
  /// Maps a stable file/page key to its position in the growable change list.
  changeIndexes
  /// Committed changes field of the transaction.
  committedChanges
  /// Savepoints field of the transaction.
  savepoints
end struct

/// Defines the transaction manager record used by this module.
struct TransactionManager
  /// Next transaction id field of the transaction manager.
  nextTransactionId
end struct

/// Defines the transaction state enumeration used by this module.
enum TransactionState
  /// Idle variant of the transaction state.
  Idle = 0
  /// Active variant of the transaction state.
  Active = 1
  /// Failed variant of the transaction state.
  Failed = 2
  /// Committing variant of the transaction state.
  Committing = 3
  /// Committed variant of the transaction state.
  Committed = 4
  /// Aborted variant of the transaction state.
  Aborted = 5
end enum

/// Performs the fail operation for the minisql transaction transaction module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "transaction.transaction." + operation + ": " + message)
end function

/// Validates the id.
/// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
function validateId(value, operation)
  if typeof(value) != "int" or value <= 0 or value > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, operation, "transactionId must be positive") end if
  return true
end function

/// Validates the isolation.
/// Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
function validateIsolation(value, operation)
  if value != ISOLATION_READ_COMMITTED and value != ISOLATION_SERIALIZABLE then return fail(INVALID_ARGUMENT, operation, "unsupported isolation level") end if
  return true
end function

/// Validates the transaction.
/// Inputs: `transaction`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param transaction transaction value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateTransaction(transaction, operation)
  if transaction is not Transaction then return fail(INVALID_ARGUMENT, operation, "value must be Transaction") end if
  return true
end function

/// Performs the require active operation for this module.
/// Inputs: `transaction`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
/// @param operation operation value consumed by this operation.
function requireActive(transaction, operation)
  validateTransaction(transaction, operation)
  if transaction.state != TransactionState.Active then return fail(TRANSACTION_STATE, operation, "transaction is not active") end if
  return true
end function

/// Begins the transaction.
/// Inputs: `transactionId`, `isolationLevel`, `readOnly`, `walWriter`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transactionId Identifier of transaction.
/// @param isolationLevel isolationLevel value consumed by this operation.
/// @param readOnly readOnly value consumed by this operation.
/// @param walWriter walWriter value consumed by this operation.
function beginTransaction(transactionId, isolationLevel, readOnly, walWriter)
  validateId(transactionId, "beginTransaction")
  validateIsolation(isolationLevel, "beginTransaction")
  if typeof(readOnly) != "bool" then return fail(INVALID_ARGUMENT, "beginTransaction", "readOnly must be bool") end if
  wal.validateOpen(walWriter, "transaction.beginTransaction")
  return Transaction(
    transactionId,
    TransactionState.Active,
    isolationLevel,
    readOnly,
    0,
    0,
    walWriter,
    false,
    list.List.new(),
    hashmap.HashMap.new(),
    list.List.new(),
    []
  )
end function

/// Creates the manager.
/// Inputs: `firstTransactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param firstTransactionId Identifier of first transaction.
function createManager(firstTransactionId)
  validateId(firstTransactionId, "createManager")
  return TransactionManager(firstTransactionId)
end function

/// Begins the managed.
/// Inputs: `manager`, `isolationLevel`, `readOnly`, `walWriter`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param manager manager value consumed by this operation.
/// @param isolationLevel isolationLevel value consumed by this operation.
/// @param readOnly readOnly value consumed by this operation.
/// @param walWriter walWriter value consumed by this operation.
function beginManaged(manager, isolationLevel, readOnly, walWriter)
  if manager is not TransactionManager then return fail(INVALID_ARGUMENT, "beginManaged", "manager must be TransactionManager") end if
  id = manager.nextTransactionId
  if id >= endian.MAX_MINILANG_INT then return fail(TRANSACTION_STATE, "beginManaged", "transaction ID space is exhausted") end if
  manager.nextTransactionId = manager.nextTransactionId + 1
  return beginTransaction(id, isolationLevel, readOnly, walWriter)
end function

/// Builds the collision-free textual key used by the transaction's change index.
/// File and page identifiers are non-negative decimal integers, so the separator
/// makes every pair unambiguous without imposing an artificial numeric limit.
/// @param fileId Identifier of file.
/// @param pageNumber pageNumber value consumed by this operation.
function changeKey(fileId, pageNumber)
  return fileId + ":" + pageNumber
end function

/// Finds a staged page in expected constant time through the private hash index.
/// Inputs: `transaction`, `fileId`, `pageNumber`. Returns its list index or `-1`.
/// @param transaction transaction value consumed by this operation.
/// @param fileId Identifier of file.
/// @param pageNumber pageNumber value consumed by this operation.
function findChange(transaction, fileId, pageNumber)
  index = transaction.changeIndexes.get(changeKey(fileId, pageNumber))
  if typeof(index) == "void" then return -1 end if
  return index
end function

/// Rebuilds the change index after restoring an array-backed savepoint snapshot.
/// @param changes changes value consumed by this operation.
function indexChanges(changes)
  indexes = hashmap.HashMap.withCapacity(len(changes) * 2)
  if len(changes) > 0 then
    for index = 0 to len(changes) - 1
      change = changes[index]
      indexes.set(changeKey(change.fileId, change.pageNumber), index)
    end for
  end if
  return indexes
end function

/// Performs the stage page operation for this module.
/// Inputs: `transaction`, `fileId`, `pageNumber`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
/// @param fileId Identifier of file.
/// @param pageNumber pageNumber value consumed by this operation.
/// @param pageBytes pageBytes value consumed by this operation.
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
    transaction.changes.add(change)
    transaction.changeIndexes.set(changeKey(fileId, pageNumber), transaction.changes.len() - 1)
  else
    transaction.changes.set(index, change)
  end if
  return true
end function

/// Performs the staged page count operation for this module.
/// Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
function stagedPageCount(transaction)
  validateTransaction(transaction, "stagedPageCount")
  return transaction.changes.len()
end function

/// Reads the private page.
/// Inputs: `transaction`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
/// @param fileId Identifier of file.
/// @param pageNumber pageNumber value consumed by this operation.
function readPrivatePage(transaction, fileId, pageNumber)
  validateTransaction(transaction, "readPrivatePage")
  index = findChange(transaction, fileId, pageNumber)
  if index < 0 then return void end if
  return bytes(transaction.changes.get(index).pageBytes)
end function

/// Marks the failed.
/// Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
function markFailed(transaction)
  validateTransaction(transaction, "markFailed")
  transaction.state = TransactionState.Failed
  return true
end function

/// Clones the changes.
/// Inputs: `changes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param changes changes value consumed by this operation.
function cloneChanges(changes)
  output = array(len(changes))
  if len(changes) > 0 then
    for index = 0 to len(changes) - 1
      change = changes[index]
      output[index] = PageChange(change.fileId, change.pageNumber, bytes(change.pageBytes))
    end for
  end if
  return output
end function

/// Validates the savepoint name.
/// Inputs: `name`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param name Name of the affected item.
/// @param operation operation value consumed by this operation.
function validateSavepointName(name, operation)
  if typeof(name) != "string" or len(name) == 0 or len(bytes(name)) > 128 then return fail(INVALID_ARGUMENT, operation, "savepoint name must be 1..128 UTF-8 bytes") end if
  return true
end function

/// Persists the point.
/// Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
/// @param name Name of the affected item.
function savepoint(transaction, name)
  requireActive(transaction, "savepoint")
  validateSavepointName(name, "savepoint")
  transaction.savepoints = transaction.savepoints + [Savepoint(name, cloneChanges(transaction.changes.toArray()))]
  return len(transaction.savepoints)
end function

/// Finds the savepoint.
/// Inputs: `transaction`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
/// @param name Name of the affected item.
function findSavepoint(transaction, name)
  if len(transaction.savepoints) == 0 then return -1 end if
  index = len(transaction.savepoints) - 1
  while index >= 0
    if transaction.savepoints[index].name == name then return index end if
    index = index - 1
  end while
  return -1
end function

/// Rolls back the to savepoint.
/// Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
/// @param name Name of the affected item.
function rollbackToSavepoint(transaction, name)
  validateTransaction(transaction, "rollbackToSavepoint")
  validateSavepointName(name, "rollbackToSavepoint")
  if transaction.state != TransactionState.Active and transaction.state != TransactionState.Failed then return fail(TRANSACTION_STATE, "rollbackToSavepoint", "transaction is not active or failed") end if
  index = findSavepoint(transaction, name)
  if index < 0 then return fail(TRANSACTION_STATE, "rollbackToSavepoint", "savepoint not found: " + name) end if
  restored = cloneChanges(transaction.savepoints[index].changes)
  transaction.changes = list.List.fromArray(restored)
  transaction.changeIndexes = indexChanges(restored)
  retained = []
  for position = 0 to index
    retained = retained + [transaction.savepoints[position]]
  end for
  transaction.savepoints = retained
  transaction.state = TransactionState.Active
  return true
end function

/// Releases the savepoint.
/// Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
/// @param name Name of the affected item.
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

/// Persists the point count.
/// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
function savepointCount(transaction)
  validateTransaction(transaction, "savepointCount")
  return len(transaction.savepoints)
end function

/// Performs the fail commit operation for this module.
/// Inputs: `transaction`, `startLsn`, `failure`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
/// @param startLsn startLsn value consumed by this operation.
/// @param failure failure value consumed by this operation.
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

/// Commits the requested value.
/// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
function commit(transaction)
  requireActive(transaction, "commit")
  startLsn = transaction.walWriter.nextLsn
  transaction.state = TransactionState.Committing
  appended = try(wal.appendTransaction(transaction.walWriter, transaction.transactionId, transaction.changes.toArray()))
  if typeof(appended) == "error" then return failCommit(transaction, startLsn, appended) end if
  transaction.beginLsn = appended[0]
  transaction.beginLogged = true
  flushResult = try(wal.flush(transaction.walWriter))
  if typeof(flushResult) == "error" then return failCommit(transaction, startLsn, flushResult) end if
  transaction.commitLsn = appended[1]
  transaction.state = TransactionState.Committed
  // Keep a private immutable batch until the storage layer has published the
  // committed pages into its buffer pool/base files. WAL durability is already
  // established, so a publication failure is recovered by M7 redo.
  transaction.committedChanges = transaction.changes
  transaction.changes = list.List.new()
  transaction.changeIndexes = hashmap.HashMap.new()
  transaction.savepoints = []
  return transaction.commitLsn
end function

/// Commits the ted page count.
/// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
function committedPageCount(transaction)
  validateTransaction(transaction, "committedPageCount")
  return transaction.committedChanges.len()
end function

/// Commits the ted pages.
/// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
function committedPages(transaction)
  validateTransaction(transaction, "committedPages")
  if transaction.state != TransactionState.Committed then return fail(TRANSACTION_STATE, "committedPages", "transaction is not committed") end if
  result = array(transaction.committedChanges.len())
  if transaction.committedChanges.len() > 0 then
    for index = 0 to transaction.committedChanges.len() - 1
      change = transaction.committedChanges.get(index)
      result[index] = PageChange(change.fileId, change.pageNumber, bytes(change.pageBytes))
    end for
  end if
  return result
end function

/// Returns a shallow publication view of the immutable committed page batch.
/// Only the storage publisher may use this helper; unlike committedPages(), its
/// page buffers are intentionally not cloned so publishing a large transaction
/// does not temporarily duplicate every full-page image in the MiniLang heap.
/// @param transaction transaction value consumed by this operation.
function committedPagesForPublication(transaction)
  validateTransaction(transaction, "committedPagesForPublication")
  if transaction.state != TransactionState.Committed then return fail(TRANSACTION_STATE, "committedPagesForPublication", "transaction is not committed") end if
  return transaction.committedChanges.toArray()
end function

/// Performs the acknowledge committed pages operation for this module.
/// Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
function acknowledgeCommittedPages(transaction)
  validateTransaction(transaction, "acknowledgeCommittedPages")
  if transaction.state != TransactionState.Committed then return fail(TRANSACTION_STATE, "acknowledgeCommittedPages", "transaction is not committed") end if
  transaction.committedChanges = list.List.new()
  return true
end function

/// Performs the take committed pages operation for this module.
/// Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param transaction transaction value consumed by this operation.
function takeCommittedPages(transaction)
  // Compatibility helper. Storage publication paths should prefer
  // committedPages() followed by acknowledgeCommittedPages() only after every
  // affected data file has been durably flushed.
  result = committedPages(transaction)
  acknowledgeCommittedPages(transaction)
  return result
end function

/// Rolls back the requested value.
/// Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param transaction transaction value consumed by this operation.
function rollback(transaction)
  validateTransaction(transaction, "rollback")
  if transaction.state == TransactionState.Committed or transaction.state == TransactionState.Aborted then return fail(TRANSACTION_STATE, "rollback", "transaction is already final") end if
  if transaction.beginLogged then
    abortResult = try(wal.appendAbort(transaction.walWriter, transaction.transactionId))
    if typeof(abortResult) != "error" then ignored = try(wal.flush(transaction.walWriter)) end if
  end if
  transaction.changes = list.List.new()
  transaction.changeIndexes = hashmap.HashMap.new()
  transaction.committedChanges = list.List.new()
  transaction.savepoints = []
  transaction.state = TransactionState.Aborted
  return true
end function

/// Performs the componentName operation for the minisql transaction transaction module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "transaction.transaction"
end function

/// Performs the targetMilestone operation for the minisql transaction transaction module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M6"
end function

/// Returns whether implemented satisfies the condition required by the minisql transaction transaction module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
