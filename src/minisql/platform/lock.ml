package minisql.platform.lock

import minisql.platform.file as file_api
import minisql.platform.file_win32 as native

const INVALID_ARGUMENT = 9001
const LOCK_CONFLICT = 9007

struct FileLock
  file
  held
  exclusive
end struct

function fail(code, operation, message)
  return error(code, "platform.lock." + operation + ": " + message)
end function

function acquireExclusive(file, failImmediately)
  file_api.validateOpen(file, "lock.acquireExclusive")
  if typeof(failImmediately) != "bool" then return fail(INVALID_ARGUMENT, "acquireExclusive", "failImmediately must be bool") end if
  if file.lockHeld then return fail(LOCK_CONFLICT, "acquireExclusive", "this handle already owns a lock") end if
  native.lockWhole(file.nativeHandle, true, failImmediately)
  file.lockHeld = true
  return FileLock(file, true, true)
end function

function release(lock)
  if lock is not FileLock then return fail(INVALID_ARGUMENT, "release", "lock must be FileLock") end if
  if not lock.held then return fail(INVALID_ARGUMENT, "release", "lock is already released") end if
  file_api.validateOpen(lock.file, "lock.release")
  native.unlockWhole(lock.file.nativeHandle)
  lock.file.lockHeld = false
  lock.held = false
  return true
end function

function componentName()
  return "platform.lock"
end function

function targetMilestone()
  return "M3"
end function

function isImplemented()
  return true
end function
