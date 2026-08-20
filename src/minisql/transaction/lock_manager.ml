package minisql.transaction.lock_manager
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.threading as threading
import minisql.platform.clock as clock

// In-process writer-prioritized reader/writer gate shared by connections using
// one database. The manager serializes state transitions with a mutex, prevents
// new readers from starving queued writers, and exposes wait-for edges for
// deterministic timeout and deadlock diagnostics.

const INVALID_ARGUMENT = 9001
const LOCK_CONFLICT = 9007
const DEADLOCK_DETECTED = 9031
const LOCK_TIMEOUT = 9032

// Defines the wait edge record used by this module.
struct WaitEdge
  // Waiter id field of the wait edge.
  waiterId
  // Blocker id field of the wait edge.
  blockerId
  // Started at field of the wait edge.
  startedAt
end struct

// Defines the lock manager record used by this module.
struct LockManager
  // Guard field of the lock manager.
  guard
  // Active writer field of the lock manager.
  activeWriter
  // Readers field of the lock manager.
  readers
  // Waits field of the lock manager.
  waits
end struct

// Defines the read lease record used by this module.
struct ReadLease
  // Transaction id field of the read lease.
  transactionId
  // Isolation level field of the read lease.
  isolationLevel
  // Release on finish field of the read lease.
  releaseOnFinish
  // Active field of the read lease.
  active
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "transaction.lock_manager." + operation + ": " + message)
end function

// Creates the requested value.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function create()
  return LockManager(threading.Lock.new(), 0, [], [])
end function

// Validates the requested value.
// Inputs: `manager`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validate(manager, operation)
  if manager is not LockManager then return fail(INVALID_ARGUMENT, operation, "manager must be LockManager") end if
  return true
end function

// Performs the valid transaction id operation for this module.
// Inputs: `transactionId`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function validTransactionId(transactionId, operation)
  if typeof(transactionId) != "int" or transactionId <= 0 then return fail(INVALID_ARGUMENT, operation, "transactionId must be positive") end if
  return true
end function

// Performs the contains id operation for this module.
// Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.
function containsId(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Performs the contains reader operation for this module.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function containsReader(manager, transactionId)
  return containsId(manager.readers, transactionId)
end function

// Clears the waiter.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function clearWaiter(manager, transactionId)
  output = []
  for each edge in manager.waits
    if edge.waiterId != transactionId then output = output + [edge] end if
  end for
  manager.waits = output
  return true
end function

// Clears the transaction waits.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function clearTransactionWaits(manager, transactionId)
  output = []
  for each edge in manager.waits
    if edge.waiterId != transactionId and edge.blockerId != transactionId then output = output + [edge] end if
  end for
  manager.waits = output
  return true
end function

// Performs the path exists operation for this module.
// Inputs: `manager`, `current`, `target`, `visited`. Returns the produced value or propagates a structured error from validation or delegated operations.
function pathExists(manager, current, target, visited)
  if current == target then return true end if
  if containsId(visited, current) then return false end if
  nextVisited = visited + [current]
  for each edge in manager.waits
    if edge.waiterId == current then
      if pathExists(manager, edge.blockerId, target, nextVisited) then return true end if
    end if
  end for
  return false
end function

// Performs the register wait operation for this module.
// Inputs: `manager`, `transactionId`, `blockers`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function registerWait(manager, transactionId, blockers, operation)
  clearWaiter(manager, transactionId)
  started = clock.monotonicMilliseconds()
  for each blocker in blockers
    if blocker != transactionId then
      duplicate = false
      for each edge in manager.waits
        if edge.waiterId == transactionId and edge.blockerId == blocker then duplicate = true end if
      end for
      if not duplicate then manager.waits = manager.waits + [WaitEdge(transactionId, blocker, started)] end if
    end if
  end for
  for each blocker in blockers
    if blocker != transactionId and pathExists(manager, blocker, transactionId, []) then
      clearWaiter(manager, transactionId)
      return fail(DEADLOCK_DETECTED, operation, "deadlock detected; transaction selected as victim")
    end if
  end for
  return fail(LOCK_CONFLICT, operation, "lock is currently held by another session")
end function

// Reads the blockers.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readBlockers(manager, transactionId)
  blockers = []
  if manager.activeWriter != 0 and manager.activeWriter != transactionId then blockers = blockers + [manager.activeWriter] end if
  return blockers
end function

// Writes the blockers.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeBlockers(manager, transactionId)
  blockers = []
  if manager.activeWriter != 0 and manager.activeWriter != transactionId then blockers = blockers + [manager.activeWriter] end if
  for each reader in manager.readers
    if reader != transactionId and not containsId(blockers, reader) then blockers = blockers + [reader] end if
  end for
  return blockers
end function

// Acquires the read unlocked.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireReadUnlocked(manager, transactionId)
  blockers = readBlockers(manager, transactionId)
  if len(blockers) > 0 then return registerWait(manager, transactionId, blockers, "acquireRead") end if
  clearWaiter(manager, transactionId)
  if not containsReader(manager, transactionId) then manager.readers = manager.readers + [transactionId] end if
  return true
end function

// Acquires the read.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireRead(manager, transactionId)
  validate(manager, "acquireRead")
  validTransactionId(transactionId, "acquireRead")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "acquireRead", "manager lock is unavailable") end if
  result = try(acquireReadUnlocked(manager, transactionId))
  manager.guard.release()
  return result
end function

// Acquires the write unlocked.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireWriteUnlocked(manager, transactionId)
  blockers = writeBlockers(manager, transactionId)
  if len(blockers) > 0 then return registerWait(manager, transactionId, blockers, "acquireWrite") end if
  clearWaiter(manager, transactionId)
  manager.activeWriter = transactionId
  return true
end function

// Acquires the write.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireWrite(manager, transactionId)
  validate(manager, "acquireWrite")
  validTransactionId(transactionId, "acquireWrite")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "acquireWrite", "manager lock is unavailable") end if
  result = try(acquireWriteUnlocked(manager, transactionId))
  manager.guard.release()
  return result
end function

// Removes the transaction's pending wait edges after cancellation or timeout.
// Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function cancelWait(manager, transactionId)
  validate(manager, "cancelWait")
  validTransactionId(transactionId, "cancelWait")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "cancelWait", "manager lock is unavailable") end if
  result = clearWaiter(manager, transactionId)
  manager.guard.release()
  return result
end function

// Releases the unlocked.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function releaseUnlocked(manager, transactionId)
  if manager.activeWriter == transactionId then manager.activeWriter = 0 end if
  nextReaders = []
  for each reader in manager.readers
    if reader != transactionId then nextReaders = nextReaders + [reader] end if
  end for
  manager.readers = nextReaders
  clearTransactionWaits(manager, transactionId)
  return true
end function

// Releases the requested value.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function release(manager, transactionId)
  validate(manager, "release")
  validTransactionId(transactionId, "release")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "release", "manager lock is unavailable") end if
  result = releaseUnlocked(manager, transactionId)
  manager.guard.release()
  return result
end function

// Reads the er count.
// Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readerCount(manager)
  validate(manager, "readerCount")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "readerCount", "manager lock is unavailable") end if
  value = len(manager.readers)
  manager.guard.release()
  return value
end function

// Performs the waiter count operation for this module.
// Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.
function waiterCount(manager)
  validate(manager, "waiterCount")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "waiterCount", "manager lock is unavailable") end if
  unique = []
  for each edge in manager.waits
    if not containsId(unique, edge.waiterId) then unique = unique + [edge.waiterId] end if
  end for
  value = len(unique)
  manager.guard.release()
  return value
end function

// Evaluates whether the supplied input satisfies the waiting predicate.
// Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isWaiting(manager, transactionId)
  validate(manager, "isWaiting")
  validTransactionId(transactionId, "isWaiting")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "isWaiting", "manager lock is unavailable") end if
  waiting = false
  for each edge in manager.waits
    if edge.waiterId == transactionId then waiting = true end if
  end for
  manager.guard.release()
  return waiting
end function

// Releases the read unlocked.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function releaseReadUnlocked(manager, transactionId)
  nextReaders = []
  for each reader in manager.readers
    if reader != transactionId then nextReaders = nextReaders + [reader] end if
  end for
  manager.readers = nextReaders
  clearWaiter(manager, transactionId)
  return true
end function

// Releases the read.
// Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function releaseRead(manager, transactionId)
  validate(manager, "releaseRead")
  validTransactionId(transactionId, "releaseRead")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "releaseRead", "manager lock is unavailable") end if
  result = releaseReadUnlocked(manager, transactionId)
  manager.guard.release()
  return result
end function

// Acquires the statement read.
// Inputs: `manager`, `transactionId`, `isolationLevel`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireStatementRead(manager, transactionId, isolationLevel)
  validate(manager, "acquireStatementRead")
  validTransactionId(transactionId, "acquireStatementRead")
  if typeof(isolationLevel) != "int" or (isolationLevel != 1 and isolationLevel != 2) then return fail(INVALID_ARGUMENT, "acquireStatementRead", "unsupported isolation level") end if
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "acquireStatementRead", "manager lock is unavailable") end if
  alreadyWriter = manager.activeWriter == transactionId
  alreadyReader = containsReader(manager, transactionId)
  acquired = try(acquireReadUnlocked(manager, transactionId))
  if typeof(acquired) == "error" then manager.guard.release(); return acquired end if
  releaseOnFinish = isolationLevel == 1 and not alreadyWriter and not alreadyReader
  lease = ReadLease(transactionId, isolationLevel, releaseOnFinish, true)
  manager.guard.release()
  return lease
end function

// Performs the finish statement operation for this module.
// Inputs: `manager`, `lease`. Returns the produced value or propagates a structured error from validation or delegated operations.
function finishStatement(manager, lease)
  validate(manager, "finishStatement")
  if lease is not ReadLease or not lease.active then return fail(INVALID_ARGUMENT, "finishStatement", "lease is invalid") end if
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "finishStatement", "manager lock is unavailable") end if
  if lease.releaseOnFinish then releaseReadUnlocked(manager, lease.transactionId) end if
  lease.active = false
  manager.guard.release()
  return true
end function

// Performs the finish transaction operation for this module.
// Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.
function finishTransaction(manager, transactionId)
  return release(manager, transactionId)
end function

// Performs the active writer operation for this module.
// Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.
function activeWriter(manager)
  validate(manager, "activeWriter")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "activeWriter", "manager lock is unavailable") end if
  value = manager.activeWriter
  manager.guard.release()
  return value
end function

// Closes the requested value.
// Inputs: `manager`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(manager)
  validate(manager, "close")
  if not manager.guard.acquire() then return fail(INVALID_ARGUMENT, "close", "manager lock is unavailable") end if
  manager.activeWriter = 0
  manager.readers = []
  manager.waits = []
  manager.guard.release()
  return manager.guard.close()
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "transaction.lock_manager"
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
