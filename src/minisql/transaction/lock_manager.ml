package minisql.transaction.lock_manager

import minisql.platform.clock as clock

const INVALID_ARGUMENT = 9001
const LOCK_CONFLICT = 9007
const DEADLOCK_DETECTED = 9031
const LOCK_TIMEOUT = 9032

struct WaitEdge
  waiterId
  blockerId
  startedAt
end struct

struct LockManager
  activeWriter
  readers
  waits
end struct

struct ReadLease
  transactionId
  isolationLevel
  releaseOnFinish
  active
end struct

function fail(code, operation, message)
  return error(code, "transaction.lock_manager." + operation + ": " + message)
end function

function create()
  return LockManager(0, [], [])
end function

function validate(manager, operation)
  if manager is not LockManager then return fail(INVALID_ARGUMENT, operation, "manager must be LockManager") end if
  return true
end function

function validTransactionId(transactionId, operation)
  if typeof(transactionId) != "int" or transactionId <= 0 then return fail(INVALID_ARGUMENT, operation, "transactionId must be positive") end if
  return true
end function

function containsId(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

function containsReader(manager, transactionId)
  return containsId(manager.readers, transactionId)
end function

function clearWaiter(manager, transactionId)
  output = []
  for each edge in manager.waits
    if edge.waiterId != transactionId then output = output + [edge] end if
  end for
  manager.waits = output
  return true
end function

function clearTransactionWaits(manager, transactionId)
  output = []
  for each edge in manager.waits
    if edge.waiterId != transactionId and edge.blockerId != transactionId then output = output + [edge] end if
  end for
  manager.waits = output
  return true
end function

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

function readBlockers(manager, transactionId)
  blockers = []
  if manager.activeWriter != 0 and manager.activeWriter != transactionId then blockers = blockers + [manager.activeWriter] end if
  return blockers
end function

function writeBlockers(manager, transactionId)
  blockers = []
  if manager.activeWriter != 0 and manager.activeWriter != transactionId then blockers = blockers + [manager.activeWriter] end if
  for each reader in manager.readers
    if reader != transactionId and not containsId(blockers, reader) then blockers = blockers + [reader] end if
  end for
  return blockers
end function

function acquireRead(manager, transactionId)
  validate(manager, "acquireRead")
  validTransactionId(transactionId, "acquireRead")
  blockers = readBlockers(manager, transactionId)
  if len(blockers) > 0 then return registerWait(manager, transactionId, blockers, "acquireRead") end if
  clearWaiter(manager, transactionId)
  if not containsReader(manager, transactionId) then manager.readers = manager.readers + [transactionId] end if
  return true
end function

function acquireWrite(manager, transactionId)
  validate(manager, "acquireWrite")
  validTransactionId(transactionId, "acquireWrite")
  blockers = writeBlockers(manager, transactionId)
  if len(blockers) > 0 then return registerWait(manager, transactionId, blockers, "acquireWrite") end if
  clearWaiter(manager, transactionId)
  manager.activeWriter = transactionId
  return true
end function

function cancelWait(manager, transactionId)
  validate(manager, "cancelWait")
  validTransactionId(transactionId, "cancelWait")
  return clearWaiter(manager, transactionId)
end function

function release(manager, transactionId)
  validate(manager, "release")
  validTransactionId(transactionId, "release")
  if manager.activeWriter == transactionId then manager.activeWriter = 0 end if
  nextReaders = []
  for each reader in manager.readers
    if reader != transactionId then nextReaders = nextReaders + [reader] end if
  end for
  manager.readers = nextReaders
  clearTransactionWaits(manager, transactionId)
  return true
end function

function readerCount(manager)
  validate(manager, "readerCount")
  return len(manager.readers)
end function

function waiterCount(manager)
  validate(manager, "waiterCount")
  unique = []
  for each edge in manager.waits
    if not containsId(unique, edge.waiterId) then unique = unique + [edge.waiterId] end if
  end for
  return len(unique)
end function

function isWaiting(manager, transactionId)
  validate(manager, "isWaiting")
  for each edge in manager.waits
    if edge.waiterId == transactionId then return true end if
  end for
  return false
end function

function releaseRead(manager, transactionId)
  validate(manager, "releaseRead")
  validTransactionId(transactionId, "releaseRead")
  nextReaders = []
  for each reader in manager.readers
    if reader != transactionId then nextReaders = nextReaders + [reader] end if
  end for
  manager.readers = nextReaders
  clearWaiter(manager, transactionId)
  return true
end function

function acquireStatementRead(manager, transactionId, isolationLevel)
  if typeof(isolationLevel) != "int" or (isolationLevel != 1 and isolationLevel != 2) then return fail(INVALID_ARGUMENT, "acquireStatementRead", "unsupported isolation level") end if
  alreadyWriter = manager.activeWriter == transactionId
  alreadyReader = containsReader(manager, transactionId)
  acquireRead(manager, transactionId)
  releaseOnFinish = isolationLevel == 1 and not alreadyWriter and not alreadyReader
  return ReadLease(transactionId, isolationLevel, releaseOnFinish, true)
end function

function finishStatement(manager, lease)
  validate(manager, "finishStatement")
  if lease is not ReadLease or not lease.active then return fail(INVALID_ARGUMENT, "finishStatement", "lease is invalid") end if
  if lease.releaseOnFinish then releaseRead(manager, lease.transactionId) end if
  lease.active = false
  return true
end function

function finishTransaction(manager, transactionId)
  return release(manager, transactionId)
end function

function componentName()
  return "transaction.lock_manager"
end function

function targetMilestone()
  return "M6"
end function

function isImplemented()
  return true
end function
