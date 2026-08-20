package minisql.server.database_manager

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.threading as threading
import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.common.diagnostics as diagnostics
import minisql.platform.file as file_api
import minisql.platform.lock as file_lock
import minisql.storage.paged_file as paged_file
import minisql.transaction.checkpoint as checkpoint
import minisql.transaction.recovery as recovery
import minisql.transaction.transaction as transaction
import minisql.transaction.lock_manager as lock_manager
import minisql.transaction.wal as wal

const INVALID_ARGUMENT = 9001
const CORRUPT_DATA = 9004
const CLOSED_HANDLE = 9008
const STANDBY_NOT_PROMOTED = 9033

// Writer-prioritized readers/writer gate. A waiting writer owns turnstile, so
// newly arriving readers cannot continuously postpone database mutations.
// Coordinates physical execution for one database. The three synchronization
// objects implement a writer-prioritized readers/writer gate; `readers` is
// accessed only while `stateLock` is held.
struct ExecutionGate
  // Protects `readers` and `peakReaders` from concurrent updates.
  stateLock
  // Serializes writers and prevents new readers from bypassing a waiting writer.
  turnstile
  // Is held by the first reader or the active writer until the database is empty.
  roomEmpty
  // Counts readers currently admitted to the database execution section.
  readers
  // Records the greatest observed reader count for diagnostics and tests.
  peakReaders
end struct

// Groups the managed database state and preserves the field relationships documented below.
struct ManagedDatabase
  // Stores the filesystem path.
  path
  // Stores the catalog handle associated with this value.
  catalogHandle
  // Stores the filesystem lock file.
  lockFile
  // Synchronizes access through the lock token.
  lockToken
  // Stores the WAL writer associated with this value.
  walWriter
  // Stores the filesystem checkpoint file.
  checkpointFile
  // Stores the last recovery associated with this value.
  lastRecovery
  // Synchronizes access through the lock manager.
  lockManager
  // Tracks the next session identifier numeric value.
  nextSessionId
  // Stores the audit log associated with this value.
  auditLog
  // Indicates whether the standby condition is active.
  standby
  // Stores the execution gate associated with this value.
  executionGate
  // Indicates whether the closed condition is active.
  closed
end struct

// Returns whether the supplied value satisfies the managed database condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isManagedDatabase(value)
  return value is ManagedDatabase
end function

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "server.database_manager." + operation + ": " + message)
end function

// Implements bytes equal for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function


// Closes recovery files using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function closeRecoveryFiles(files)
  for each current in files
    ignored = try(paged_file.close(current))
  end for
  return true
end function

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateOpen(database, operation)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, operation, "database must be ManagedDatabase") end if
  if database.closed then return fail(CLOSED_HANDLE, operation, "database is closed") end if
  return true
end function

// Creates a writer-prioritized gate in the empty state.
// Returns the gate or a threading error after closing any partially created primitive.
function createExecutionGate()
  stateLock = threading.Lock.new()
  turnstile = try(threading.Semaphore.new(1, 1))
  if typeof(turnstile) == "error" then stateLock.close(); return turnstile end if
  roomEmpty = try(threading.Semaphore.new(1, 1))
  if typeof(roomEmpty) == "error" then turnstile.close(); stateLock.close(); return roomEmpty end if
  return ExecutionGate(stateLock, turnstile, roomEmpty, 0, 0)
end function

// Admits one shared reader through the writer-priority turnstile.
// The first reader acquires `roomEmpty`; later readers only increment the
// protected count. Returns true or an unavailable/closed-gate error.
function enterReadExecution(database)
  validateOpen(database, "enterReadExecution")
  gate = database.executionGate
  if not gate.turnstile.acquire() then return fail(CLOSED_HANDLE, "enterReadExecution", "database execution gate is unavailable") end if
  gate.turnstile.release()
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "enterReadExecution", "database execution state is unavailable") end if
  gate.readers = gate.readers + 1
  if gate.readers == 1 and not gate.roomEmpty.acquire() then
    gate.readers = gate.readers - 1
    gate.stateLock.release()
    return fail(CLOSED_HANDLE, "enterReadExecution", "database read gate is unavailable")
  end if
  if gate.readers > gate.peakReaders then gate.peakReaders = gate.readers end if
  gate.stateLock.release()
  return true
end function

// Removes one shared reader and releases `roomEmpty` when the last reader exits.
// Returns an error for an invalid database, unavailable lock, or unbalanced leave.
function leaveReadExecution(database)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, "leaveReadExecution", "database must be ManagedDatabase") end if
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "leaveReadExecution", "database execution state is unavailable") end if
  if gate.readers <= 0 then
    gate.stateLock.release()
    return fail(INVALID_ARGUMENT, "leaveReadExecution", "database has no active reader")
  end if
  gate.readers = gate.readers - 1
  lastReader = gate.readers == 0
  if lastReader then gate.roomEmpty.release() end if
  gate.stateLock.release()
  return true
end function

// Backward-compatible names denote exclusive engine execution. Authentication,
// session lifecycle and every mutating SQL statement use this writer path.
// Acquires exclusive database execution in writer-priority order.
// Holding the turnstile while waiting for `roomEmpty` blocks newly arriving
// readers, so a sustained read workload cannot starve mutations.
function enterExecution(database)
  validateOpen(database, "enterExecution")
  gate = database.executionGate
  if not gate.turnstile.acquire() then return fail(CLOSED_HANDLE, "enterExecution", "database execution gate is unavailable") end if
  if not gate.roomEmpty.acquire() then
    gate.turnstile.release()
    return fail(CLOSED_HANDLE, "enterExecution", "database write gate is unavailable")
  end if
  return true
end function

// Releases exclusive database execution, opening the room before the turnstile.
// Returns an error if either synchronization primitive cannot be released.
function leaveExecution(database)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, "leaveExecution", "database must be ManagedDatabase") end if
  gate = database.executionGate
  roomReleased = gate.roomEmpty.release()
  turnstileReleased = gate.turnstile.release()
  if not roomReleased or not turnstileReleased then return fail(CLOSED_HANDLE, "leaveExecution", "database execution gate could not be released") end if
  return true
end function

// Implements peak concurrent readers for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function peakConcurrentReaders(database)
  validateOpen(database, "peakConcurrentReaders")
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "peakConcurrentReaders", "database execution state is unavailable") end if
  value = gate.peakReaders
  gate.stateLock.release()
  return value
end function

// Resets peak concurrent readers using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function resetPeakConcurrentReaders(database)
  validateOpen(database, "resetPeakConcurrentReaders")
  gate = database.executionGate
  if not gate.stateLock.acquire() then return fail(CLOSED_HANDLE, "resetPeakConcurrentReaders", "database execution state is unavailable") end if
  if gate.readers != 0 then
    gate.stateLock.release()
    return fail(INVALID_ARGUMENT, "resetPeakConcurrentReaders", "cannot reset while readers are active")
  end if
  gate.peakReaders = 0
  gate.stateLock.release()
  return true
end function

// Opens internal using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function openInternal(path, allowStandby)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "open", "path must be non-empty") end if
  if typeof(allowStandby) != "bool" then return fail(INVALID_ARGUMENT, "open", "allowStandby must be bool") end if
  standbyMarker = file_api.fileExists(catalog.joinPath(path, "standby.state"))
  if standbyMarker and not allowStandby then return fail(STANDBY_NOT_PROMOTED, "open", "standby is not promoted") end if
  if allowStandby and not standbyMarker then return fail(INVALID_ARGUMENT, "openStandby", "standby.state is missing") end if
  lockPath = catalog.joinPath(path, "db.lock")
  lockFile = file_api.openReadWrite(lockPath, false)
  lockToken = try(file_lock.acquireExclusive(lockFile, true))
  if typeof(lockToken) == "error" then file_api.close(lockFile); return lockToken end if

  maintenance = try(schema_history.recoverMaintenance(path))
  if typeof(maintenance) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return maintenance
  end if

  pending = try(schema_history.recoverPending(path))
  if typeof(pending) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return pending
  end if

  catalogHandle = try(catalog.openDatabase(path))
  if typeof(catalogHandle) == "error" then
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return catalogHandle
  end if

  // Initialize every file a read-only statement may consult before publishing
  // the database to worker threads. SELECT never creates schema or temp state.
  schemaState = try(schema_history.loadOrCreate(path, catalogHandle.metadata.databaseId))
  if typeof(schemaState) == "error" then
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return schemaState
  end if
  temporaryPath = catalog.joinPath(path, "tmp")
  if not file_api.directoryExists(temporaryPath) then
    createdTemporary = try(file_api.createDirectory(temporaryPath))
    if typeof(createdTemporary) == "error" then
      catalog.close(catalogHandle)
      file_lock.release(lockToken)
      file_api.close(lockFile)
      return createdTemporary
    end if
  end if

  walPath = catalog.joinPath(catalog.joinPath(path, "wal"), "wal.log")
  walWriter = try(wal.open(walPath, catalogHandle.metadata.walSegmentBytes))
  if typeof(walWriter) == "error" then
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return walWriter
  end if

  checkpointPath = catalog.joinPath(catalog.joinPath(path, "wal"), "checkpoint.meta")
  checkpointFile = try(checkpoint.open(checkpointPath))
  if typeof(checkpointFile) == "error" then
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return checkpointFile
  end if
  if not bytesEqual(checkpointFile.metadata.databaseId, catalogHandle.metadata.databaseId) then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return fail(CORRUPT_DATA, "open", "checkpoint belongs to another database")
  end if

  // Complete committed table-page writes before the database is exposed to a
  // session. Catalog/DDL WAL integration is introduced with transactional DDL;
  // M7 recovery currently targets all catalog-listed table files.
  recoveryFiles = []
  recoveryTargets = []
  for each table in catalogHandle.catalog.tables
    tableFile = try(paged_file.open(catalog.tableFilePath(path, table.tableId)))
    if typeof(tableFile) == "error" then
      closeRecoveryFiles(recoveryFiles)
      checkpoint.close(checkpointFile)
      wal.close(walWriter)
      catalog.close(catalogHandle)
      file_lock.release(lockToken)
      file_api.close(lockFile)
      return tableFile
    end if
    recoveryFiles = recoveryFiles + [tableFile]
    recoveryTargets = recoveryTargets + [recovery.target(table.tableId, tableFile)]
  end for
  recoveryResult = try(recovery.recover(walWriter, recoveryTargets, checkpointFile.metadata.redoStartLsn))
  closeRecoveryFiles(recoveryFiles)
  if typeof(recoveryResult) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return recoveryResult
  end if

  auditLog = try(diagnostics.openAudit(path))
  if typeof(auditLog) == "error" then
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return auditLog
  end if
  executionGate = try(createExecutionGate())
  if typeof(executionGate) == "error" then
    diagnostics.closeAudit(auditLog)
    checkpoint.close(checkpointFile)
    wal.close(walWriter)
    catalog.close(catalogHandle)
    file_lock.release(lockToken)
    file_api.close(lockFile)
    return executionGate
  end if
  return ManagedDatabase(path, catalogHandle, lockFile, lockToken, walWriter, checkpointFile, recoveryResult, lock_manager.create(), 1, auditLog, standbyMarker, executionGate, false)
end function

// Opens open using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function open(path)
  return openInternal(path, false)
end function

// Opens standby using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function openStandby(path)
  return openInternal(path, true)
end function

// Creates create using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function create(dataRoot, name, defaults)
  created = catalog.createDatabase(dataRoot, name, defaults)
  path = created.path
  catalog.close(created)
  return open(path)
end function

// Implements begin for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function begin(database, isolationLevel, readOnly)
  validateOpen(database, "begin")
  transactionId = catalog.allocateTransactionId(database.catalogHandle)
  return transaction.beginTransaction(transactionId, isolationLevel, readOnly, database.walWriter)
end function


// Implements allocate session identifier for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function allocateSessionId(database)
  validateOpen(database, "allocateSessionId")
  if not database.executionGate.stateLock.acquire() then return fail(CLOSED_HANDLE, "allocateSessionId", "database execution state is unavailable") end if
  value = database.nextSessionId
  database.nextSessionId = database.nextSessionId + 1
  if database.nextSessionId <= 0 then database.nextSessionId = 1 end if
  database.executionGate.stateLock.release()
  return value
end function

// Acquires statement read using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function acquireStatementRead(database, transactionId, isolationLevel)
  validateOpen(database, "acquireStatementRead")
  return lock_manager.acquireStatementRead(database.lockManager, transactionId, isolationLevel)
end function

// Implements finish statement for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function finishStatement(database, lease)
  validateOpen(database, "finishStatement")
  return lock_manager.finishStatement(database.lockManager, lease)
end function

// Acquires write using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function acquireWrite(database, transactionId)
  validateOpen(database, "acquireWrite")
  return lock_manager.acquireWrite(database.lockManager, transactionId)
end function

// Releases locks using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function releaseLocks(database, transactionId)
  validateOpen(database, "releaseLocks")
  return lock_manager.finishTransaction(database.lockManager, transactionId)
end function

// Implements cancel lock wait for this module.
// Returns the computed value or operation status.
// Does not modify its inputs.
function cancelLockWait(database, transactionId)
  validateOpen(database, "cancelLockWait")
  return lock_manager.cancelWait(database.lockManager, transactionId)
end function

// Implements waiter count for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function waiterCount(database)
  validateOpen(database, "waiterCount")
  return lock_manager.waiterCount(database.lockManager)
end function

// Implements active writer for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function activeWriter(database)
  validateOpen(database, "activeWriter")
  return lock_manager.activeWriter(database.lockManager)
end function

// Implements reader count for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function readerCount(database)
  validateOpen(database, "readerCount")
  return lock_manager.readerCount(database.lockManager)
end function

// Implements audit for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function audit(database, eventType, outcome, sessionId, principalId, detail)
  validateOpen(database, "audit")
  return diagnostics.appendAudit(database.auditLog, eventType, outcome, sessionId, principalId, detail)
end function

// Implements rotate audit for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function rotateAudit(database, sessionId, principalId)
  validateOpen(database, "rotateAudit")
  database.auditLog = diagnostics.rotateAudit(database.auditLog, database.path, sessionId, principalId)
  return true
end function

// Verifies audit using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function verifyAudit(database)
  validateOpen(database, "verifyAudit")
  return diagnostics.verifyAudit(database.path)
end function

// Returns whether the supplied value satisfies the standby condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isStandby(database)
  validateOpen(database, "isStandby")
  return database.standby
end function

// Finds table using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findTable(database, name)
  validateOpen(database, "findTable")
  return catalog.findTable(database.catalogHandle, name)
end function

// Creates table using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function createTable(database, name, definitions)
  validateOpen(database, "createTable")
  return catalog.createTable(database.catalogHandle, name, definitions)
end function

// Closes close using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state and perform I/O through its dependencies.
function close(database)
  entered = try(enterExecution(database))
  failure = void
  closedAudit = try(diagnostics.closeAudit(database.auditLog))
  if typeof(closedAudit) == "error" then failure = closedAudit end if
  closedCheckpoint = try(checkpoint.close(database.checkpointFile))
  if typeof(failure) != "error" and typeof(closedCheckpoint) == "error" then failure = closedCheckpoint end if
  closedWal = try(wal.close(database.walWriter))
  if typeof(failure) != "error" and typeof(closedWal) == "error" then failure = closedWal end if
  closedCatalog = try(catalog.close(database.catalogHandle))
  if typeof(failure) != "error" and typeof(closedCatalog) == "error" then failure = closedCatalog end if
  releasedFileLock = try(file_lock.release(database.lockToken))
  if typeof(failure) != "error" and typeof(releasedFileLock) == "error" then failure = releasedFileLock end if
  closedLockFile = try(file_api.close(database.lockFile))
  if typeof(failure) != "error" and typeof(closedLockFile) == "error" then failure = closedLockFile end if
  closedManager = try(lock_manager.close(database.lockManager))
  if typeof(failure) != "error" and typeof(closedManager) == "error" then failure = closedManager end if
  database.closed = true
  gate = database.executionGate
  gate.roomEmpty.release()
  gate.turnstile.release()
  gate.roomEmpty.close()
  gate.turnstile.close()
  gate.stateLock.close()
  if typeof(failure) == "error" then return failure end if
  return true
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.database_manager"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M8"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
