package minisql.server.database_manager

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

struct ManagedDatabase
  path
  catalogHandle
  lockFile
  lockToken
  walWriter
  checkpointFile
  lastRecovery
  lockManager
  nextSessionId
  auditLog
  standby
  closed
end struct

function isManagedDatabase(value)
  return value is ManagedDatabase
end function

function fail(code, operation, message)
  return error(code, "server.database_manager." + operation + ": " + message)
end function

function bytesEqual(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if left[index] != right[index] then return false end if
  end for
  return true
end function


function closeRecoveryFiles(files)
  for each current in files
    ignored = try(paged_file.close(current))
  end for
  return true
end function

function validateOpen(database, operation)
  if database is not ManagedDatabase then return fail(INVALID_ARGUMENT, operation, "database must be ManagedDatabase") end if
  if database.closed then return fail(CLOSED_HANDLE, operation, "database is closed") end if
  return true
end function

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
  return ManagedDatabase(path, catalogHandle, lockFile, lockToken, walWriter, checkpointFile, recoveryResult, lock_manager.create(), 1, auditLog, standbyMarker, false)
end function

function open(path)
  return openInternal(path, false)
end function

function openStandby(path)
  return openInternal(path, true)
end function

function create(dataRoot, name, defaults)
  created = catalog.createDatabase(dataRoot, name, defaults)
  path = created.path
  catalog.close(created)
  return open(path)
end function

function begin(database, isolationLevel, readOnly)
  validateOpen(database, "begin")
  transactionId = catalog.allocateTransactionId(database.catalogHandle)
  return transaction.beginTransaction(transactionId, isolationLevel, readOnly, database.walWriter)
end function


function allocateSessionId(database)
  validateOpen(database, "allocateSessionId")
  value = database.nextSessionId
  database.nextSessionId = database.nextSessionId + 1
  if database.nextSessionId <= 0 then database.nextSessionId = 1 end if
  return value
end function

function acquireStatementRead(database, transactionId, isolationLevel)
  validateOpen(database, "acquireStatementRead")
  return lock_manager.acquireStatementRead(database.lockManager, transactionId, isolationLevel)
end function

function finishStatement(database, lease)
  validateOpen(database, "finishStatement")
  return lock_manager.finishStatement(database.lockManager, lease)
end function

function acquireWrite(database, transactionId)
  validateOpen(database, "acquireWrite")
  return lock_manager.acquireWrite(database.lockManager, transactionId)
end function

function releaseLocks(database, transactionId)
  validateOpen(database, "releaseLocks")
  return lock_manager.finishTransaction(database.lockManager, transactionId)
end function

function cancelLockWait(database, transactionId)
  validateOpen(database, "cancelLockWait")
  return lock_manager.cancelWait(database.lockManager, transactionId)
end function

function waiterCount(database)
  validateOpen(database, "waiterCount")
  return lock_manager.waiterCount(database.lockManager)
end function

function activeWriter(database)
  validateOpen(database, "activeWriter")
  return database.lockManager.activeWriter
end function

function readerCount(database)
  validateOpen(database, "readerCount")
  return lock_manager.readerCount(database.lockManager)
end function

function audit(database, eventType, outcome, sessionId, principalId, detail)
  validateOpen(database, "audit")
  return diagnostics.appendAudit(database.auditLog, eventType, outcome, sessionId, principalId, detail)
end function

function rotateAudit(database, sessionId, principalId)
  validateOpen(database, "rotateAudit")
  database.auditLog = diagnostics.rotateAudit(database.auditLog, database.path, sessionId, principalId)
  return true
end function

function verifyAudit(database)
  validateOpen(database, "verifyAudit")
  return diagnostics.verifyAudit(database.path)
end function

function isStandby(database)
  validateOpen(database, "isStandby")
  return database.standby
end function

function findTable(database, name)
  validateOpen(database, "findTable")
  return catalog.findTable(database.catalogHandle, name)
end function

function createTable(database, name, definitions)
  validateOpen(database, "createTable")
  return catalog.createTable(database.catalogHandle, name, definitions)
end function

function close(database)
  validateOpen(database, "close")
  diagnostics.closeAudit(database.auditLog)
  checkpoint.close(database.checkpointFile)
  wal.close(database.walWriter)
  catalog.close(database.catalogHandle)
  file_lock.release(database.lockToken)
  file_api.close(database.lockFile)
  database.closed = true
  return true
end function

function componentName()
  return "server.database_manager"
end function

function targetMilestone()
  return "M8"
end function

function isImplemented()
  return true
end function
