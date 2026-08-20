package minisql.platform.lock
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.platform.file as file_api
import minisql.platform.file_win32 as native

// Process-visible file-region locks used to coordinate database readers and
// writers. A FileLock owns the duplicated handle that carries the Windows lock;
// releasing or closing the lease must happen exactly once.

const INVALID_ARGUMENT = 9001
const LOCK_CONFLICT = 9007

// Defines the file lock record used by this module.
struct FileLock
  // File field of the file lock.
  file
  // Held field of the file lock.
  held
  // Exclusive field of the file lock.
  exclusive
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "platform.lock." + operation + ": " + message)
end function

// Acquires the exclusive.
// Inputs: `file`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireExclusive(file, failImmediately)
  file_api.validateOpen(file, "lock.acquireExclusive")
  if typeof(failImmediately) != "bool" then return fail(INVALID_ARGUMENT, "acquireExclusive", "failImmediately must be bool") end if
  if file.lockHeld then return fail(LOCK_CONFLICT, "acquireExclusive", "this handle already owns a lock") end if
  native.lockWhole(file.nativeHandle, true, failImmediately)
  file.lockHeld = true
  return FileLock(file, true, true)
end function

// Acquires the shared.
// Inputs: `file`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acquireShared(file, failImmediately)
  file_api.validateOpen(file, "lock.acquireShared")
  if typeof(failImmediately) != "bool" then return fail(INVALID_ARGUMENT, "acquireShared", "failImmediately must be bool") end if
  if file.lockHeld then return fail(LOCK_CONFLICT, "acquireShared", "this handle already owns a lock") end if
  native.lockWhole(file.nativeHandle, false, failImmediately)
  file.lockHeld = true
  return FileLock(file, true, false)
end function

// Releases the requested value.
// Inputs: `lock`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function release(lock)
  if lock is not FileLock then return fail(INVALID_ARGUMENT, "release", "lock must be FileLock") end if
  if not lock.held then return fail(INVALID_ARGUMENT, "release", "lock is already released") end if
  file_api.validateOpen(lock.file, "lock.release")
  native.unlockWhole(lock.file.nativeHandle)
  lock.file.lockHeld = false
  lock.held = false
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.lock"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M3"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
