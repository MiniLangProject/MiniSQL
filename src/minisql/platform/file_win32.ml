package minisql.platform.file_win32
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.threading as threading

// Thin Win32 handle layer. The public platform.file module owns validation and
// object lifetime. Read-only handles can opt into offset-based overlapped reads,
// while serialized writers retain synchronous cursor operations.

const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const LOCK_CONFLICT = 9007

const GENERIC_READ = 0x80000000
const GENERIC_WRITE = 0x40000000
const FILE_SHARE_READ = 0x00000001
const FILE_SHARE_WRITE = 0x00000002
const FILE_SHARE_DELETE = 0x00000004
const CREATE_NEW = 1
const CREATE_ALWAYS = 2
const OPEN_EXISTING = 3
const OPEN_ALWAYS = 4
const TRUNCATE_EXISTING = 5
const FILE_ATTRIBUTE_NORMAL = 0x00000080
const FILE_FLAG_WRITE_THROUGH = 0x80000000
const FILE_FLAG_OVERLAPPED = 0x40000000
const FILE_BEGIN = 0
const LOCKFILE_FAIL_IMMEDIATELY = 0x00000001
const LOCKFILE_EXCLUSIVE_LOCK = 0x00000002
const ERROR_LOCK_VIOLATION = 33
const ERROR_ACCESS_DENIED = 5
const ERROR_SHARING_VIOLATION = 32
const ERROR_FILE_NOT_FOUND = 2
const ERROR_PATH_NOT_FOUND = 3
const ERROR_ALREADY_EXISTS = 183
const ERROR_HANDLE_EOF = 38
const ERROR_IO_PENDING = 997
const INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
const FILE_ATTRIBUTE_DIRECTORY = 0x00000010
const MOVEFILE_REPLACE_EXISTING = 0x00000001
const MOVEFILE_WRITE_THROUGH = 0x00000008
const MOVE_RETRY_ATTEMPTS = 40
const MOVE_RETRY_DELAY_MS = 25

// One manual-reset completion event reused by a sequential query or cursor.
// ResetEvent is required before reuse because overlapped operations may finish
// synchronously without consuming the event through a wait.
struct PositionedReadContext
  // Manual-reset event stored in each operation's OVERLAPPED record.
  completion
  // Prevents an event handle from being reused after close.
  closed
end struct

// Opens or creates a Win32 file and returns its native handle or INVALID_HANDLE_VALUE.
extern function CreateFileW(path as wstr, desiredAccess as u32, shareMode as u32, security as ptr, creationDisposition as u32, flagsAndAttributes as u32, templateFile as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
// Reads synchronously into `buffer`, writing the transferred count to `bytesRead`.
extern function ReadFile(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as ptr) from "kernel32.dll" symbol "ReadFile" returns bool
// Starts one read at the offset stored in a unique OVERLAPPED structure.
extern function ReadFilePositioned(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as bytes) from "kernel32.dll" symbol "ReadFile" returns bool
// Writes synchronously from `buffer`, storing the transferred count in `bytesWritten`.
extern function WriteFile(handle as ptr, buffer as bytes, count as u32, bytesWritten as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
// Waits for one particular overlapped operation and returns its byte count.
extern function GetOverlappedResult(handle as ptr, overlapped as bytes, bytesTransferred as bytes, wait as bool) from "kernel32.dll" symbol "GetOverlappedResult" returns bool
// Repositions the file cursor by `distance` relative to `moveMethod`.
extern function SetFilePointerEx(handle as ptr, distance as i64, newPosition as ptr, moveMethod as u32) from "kernel32.dll" symbol "SetFilePointerEx" returns bool
// Writes the handle's current 64-bit byte length to `sizeOut`.
extern function GetFileSizeEx(handle as ptr, sizeOut as bytes) from "kernel32.dll" symbol "GetFileSizeEx" returns bool
// Truncates or extends the file at its current cursor position.
extern function SetEndOfFile(handle as ptr) from "kernel32.dll" symbol "SetEndOfFile" returns bool
// Forces buffered data and metadata for `handle` to stable storage.
extern function FlushFileBuffers(handle as ptr) from "kernel32.dll" symbol "FlushFileBuffers" returns bool
// Acquires the requested byte-range lock described by `overlapped` and length words.
extern function LockFileEx(handle as ptr, flags as u32, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "LockFileEx" returns bool
// Releases the byte-range lock described by `overlapped` and length words.
extern function UnlockFileEx(handle as ptr, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "UnlockFileEx" returns bool
// Releases one Win32 kernel handle and reports whether closing succeeded.
extern function CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
// Deletes the file identified by a UTF-16 path and reports Win32 success.
extern function DeleteFileW(path as wstr) from "kernel32.dll" symbol "DeleteFileW" returns bool
// Returns Win32 attributes for a UTF-16 path or INVALID_FILE_ATTRIBUTES.
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" symbol "GetFileAttributesW" returns u32
// Creates a directory at the UTF-16 path and reports Win32 success.
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
// Removes an empty directory at the UTF-16 path and reports Win32 success.
extern function RemoveDirectoryW(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
// Renames or replaces a path according to `flags` and reports Win32 success.
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
// Returns the calling thread's most recent Win32 error code.
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
// Suspends the calling thread for the requested number of milliseconds.
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "platform.file_win32." + operation + ": " + message)
end function

// Performs the last error operation for this module.
// Inputs: `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function lastError(operation)
  code = GetLastError()
  return fail(IO_FAILURE, operation, "Win32 error " + code)
end function

// Evaluates whether the supplied input satisfies the invalid handle predicate.
// Inputs: `handle`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isInvalidHandle(handle)
  if typeof(handle) != "int" then return true end if
  return handle == -1 or handle == 0
end function

// MiniLang's extern wstr conversion currently uses process-wide UTF-16 scratch
// buffers. Serialize only path-bearing native calls; positioned file I/O stays
// parallel because it uses independent handles and byte buffers.
function synchronized openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, extraFlags)
  if typeof(path) != "string" or len(path) == 0 then
    return fail(INVALID_ARGUMENT, "openNative", "path must be a non-empty string")
  end if
  if typeof(desiredAccess) != "int" or typeof(shareMode) != "int" or typeof(creationDisposition) != "int" then
    return fail(INVALID_ARGUMENT, "openNative", "access, share and disposition must be int")
  end if
  if typeof(writeThrough) != "bool" then return fail(INVALID_ARGUMENT, "openNative", "writeThrough must be bool") end if
  if typeof(extraFlags) != "int" then return fail(INVALID_ARGUMENT, "openNative", "extraFlags must be int") end if
  flags = FILE_ATTRIBUTE_NORMAL | extraFlags
  if writeThrough then flags = flags | FILE_FLAG_WRITE_THROUGH end if
  handle = CreateFileW(path, desiredAccess, shareMode, void, creationDisposition, flags, void)
  if isInvalidHandle(handle) then return lastError("openNative") end if
  return handle
end function

// Opens a conventional synchronous handle used by serialized write paths.
function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  return openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, 0)
end function

// Opens a read-only handle whose operations carry explicit byte offsets and can
// safely overlap on the same kernel file object.
function openNativePositionedRead(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  return openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, FILE_FLAG_OVERLAPPED)
end function

// Performs the seek operation for this module.
// Inputs: `handle`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
function seek(handle, offset)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "seek", "invalid handle") end if
  if typeof(offset) != "int" or offset < 0 or offset > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "seek", "offset must be a non-negative native MiniLang int")
  end if
  if not SetFilePointerEx(handle, offset, void, FILE_BEGIN) then return lastError("seek") end if
  return true
end function

// Reads the current.
// Inputs: `handle`, `destination`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readCurrent(handle, destination, count)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "readCurrent", "invalid handle") end if
  if typeof(destination) != "bytes" then return fail(INVALID_ARGUMENT, "readCurrent", "destination must be bytes") end if
  if typeof(count) != "int" or count < 0 or count > len(destination) or count > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, "readCurrent", "count exceeds destination or U32")
  end if
  if count == 0 then return 0 end if
  countOut = bytes(4, 0)
  if not ReadFile(handle, destination, count, countOut, void) then return lastError("readCurrent") end if
  return endian.readU32LE(countOut, 0)
end function

// Creates one reusable completion event for a query-local positioned-read lease.
function createReadContext()
  completion = try(threading.Event.new(true, false))
  if typeof(completion) == "error" then return fail(IO_FAILURE, "createReadContext", completion.message) end if
  return PositionedReadContext(completion, false)
end function

// Closes a query-local completion event after its final read has completed.
function closeReadContext(context)
  if context is not PositionedReadContext then return fail(INVALID_ARGUMENT, "closeReadContext", "context must be PositionedReadContext") end if
  if context.closed then return fail(INVALID_ARGUMENT, "closeReadContext", "context is already closed") end if
  if not context.completion.close() then return fail(IO_FAILURE, "closeReadContext", "could not close completion event") end if
  context.closed = true
  return true
end function

// Reads at an explicit byte offset with one caller-owned completion event. The
// OVERLAPPED record remains unique to the operation while event creation is
// amortized across every page read in the owning query lease.
function readAtWithContext(handle, fileOffset, destination, count, context)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "readAt", "invalid handle") end if
  if typeof(fileOffset) != "int" or fileOffset < 0 or fileOffset > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "readAt", "fileOffset must be non-negative") end if
  if typeof(destination) != "bytes" then return fail(INVALID_ARGUMENT, "readAt", "destination must be bytes") end if
  if typeof(count) != "int" or count < 0 or count > len(destination) or count > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "readAt", "count exceeds destination or U32") end if
  if context is not PositionedReadContext or context.closed then return fail(INVALID_ARGUMENT, "readAt", "context must be open") end if
  if count == 0 then return 0 end if

  if not context.completion.reset() then return fail(IO_FAILURE, "readAt", "could not reset completion event") end if
  overlapped = bytes(32, 0)
  offsetWords = endian.uint64FromInt(fileOffset)
  endian.writeU32LE(overlapped, 16, offsetWords.low)
  endian.writeU32LE(overlapped, 20, offsetWords.high)
  endian.writeU64LE(overlapped, 24, endian.uint64FromInt(context.completion.handle))
  immediateCount = bytes(4, 0)
  started = ReadFilePositioned(handle, destination, count, immediateCount, overlapped)
  if not started then
    code = GetLastError()
    if code == ERROR_HANDLE_EOF then return 0 end if
    if code != ERROR_IO_PENDING then return fail(IO_FAILURE, "readAt", "Win32 error " + code) end if
  end if
  transferred = bytes(4, 0)
  if not GetOverlappedResult(handle, overlapped, transferred, true) then
    code = GetLastError()
    if code == ERROR_HANDLE_EOF then return 0 end if
    return fail(IO_FAILURE, "readAt", "Win32 completion error " + code)
  end if
  return endian.readU32LE(transferred, 0)
end function

// Compatibility positioned read whose temporary context owns exactly one read.
function readAt(handle, fileOffset, destination, count)
  context = try(createReadContext())
  if typeof(context) == "error" then return context end if
  result = try(readAtWithContext(handle, fileOffset, destination, count, context))
  closed = try(closeReadContext(context))
  if typeof(result) == "error" then return result end if
  if typeof(closed) == "error" then return closed end if
  return result
end function

// Writes the current.
// Inputs: `handle`, `source`, `count`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeCurrent(handle, source, count)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "writeCurrent", "invalid handle") end if
  if typeof(source) != "bytes" then return fail(INVALID_ARGUMENT, "writeCurrent", "source must be bytes") end if
  if typeof(count) != "int" or count < 0 or count > len(source) or count > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, "writeCurrent", "count exceeds source or U32")
  end if
  if count == 0 then return 0 end if
  countOut = bytes(4, 0)
  if not WriteFile(handle, source, count, countOut, void) then return lastError("writeCurrent") end if
  return endian.readU32LE(countOut, 0)
end function

// Computes the size of the requested value.
// Inputs: `handle`. Returns the produced value or propagates a structured error from validation or delegated operations.
function size(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "size", "invalid handle") end if
  output = bytes(8, 0)
  if not GetFileSizeEx(handle, output) then return lastError("size") end if
  return endian.readI64AsIntLE(output, 0)
end function

// Performs the truncate operation for this module.
// Inputs: `handle`, `newSize`. Returns the produced value or propagates a structured error from validation or delegated operations.
function truncate(handle, newSize)
  seek(handle, newSize)
  if not SetEndOfFile(handle) then return lastError("truncate") end if
  return true
end function

// Flushes the requested value.
// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function flush(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "flush", "invalid handle") end if
  if not FlushFileBuffers(handle) then return lastError("flush") end if
  return true
end function

// Locks the whole.
// Inputs: `handle`, `exclusive`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.
function lockWhole(handle, exclusive, failImmediately)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "lockWhole", "invalid handle") end if
  if typeof(exclusive) != "bool" or typeof(failImmediately) != "bool" then
    return fail(INVALID_ARGUMENT, "lockWhole", "lock flags must be bool")
  end if
  flags = 0
  if exclusive then flags = flags | LOCKFILE_EXCLUSIVE_LOCK end if
  if failImmediately then flags = flags | LOCKFILE_FAIL_IMMEDIATELY end if
  overlapped = bytes(32, 0)
  if not LockFileEx(handle, flags, 0, endian.MAX_U32, endian.MAX_U32, overlapped) then
    code = GetLastError()
    if code == ERROR_LOCK_VIOLATION then
      return fail(LOCK_CONFLICT, "lockWhole", "file is locked by another process")
    end if
    return fail(IO_FAILURE, "lockWhole", "Win32 error " + code)
  end if
  return true
end function

// Unlocks the whole.
// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function unlockWhole(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "unlockWhole", "invalid handle") end if
  overlapped = bytes(32, 0)
  if not UnlockFileEx(handle, 0, endian.MAX_U32, endian.MAX_U32, overlapped) then return lastError("unlockWhole") end if
  return true
end function

// Closes the native.
// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function closeNative(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "closeNative", "invalid handle") end if
  if not CloseHandle(handle) then return lastError("closeNative") end if
  return true
end function

// Deletes the path while holding the compiler-required wide-path call guard.
// Input `path` must be non-empty; returns success or a mapped Win32 error.
function synchronized deletePath(path)
  if typeof(path) != "string" or len(path) == 0 then
    return fail(INVALID_ARGUMENT, "deletePath", "path must be a non-empty string")
  end if
  if not DeleteFileW(path) then return lastError("deletePath") end if
  return true
end function


// Reads Win32 attributes while serializing access to the compiler's path buffer.
// Input `path` must be non-empty; returns attributes, -1 when absent, or an error.
function synchronized pathAttributes(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "pathAttributes", "path must be non-empty") end if
  attributes = GetFileAttributesW(path)
  if attributes == INVALID_FILE_ATTRIBUTES then
    code = GetLastError()
    if code == ERROR_FILE_NOT_FOUND or code == ERROR_PATH_NOT_FOUND then return -1 end if
    return fail(IO_FAILURE, "pathAttributes", "Win32 error " + code)
  end if
  return attributes
end function

// Performs the path exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function pathExists(path)
  return pathAttributes(path) != -1
end function

// Performs the directory exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function directoryExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) != 0
end function

// Performs the file exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fileExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0
end function

// Creates one directory while holding the wide-path native-call guard.
// Input `path` must be non-empty; an existing directory is treated as success.
function synchronized createDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "createDirectory", "path must be non-empty") end if
  if CreateDirectoryW(path, void) then return true end if
  code = GetLastError()
  if code == ERROR_ALREADY_EXISTS and directoryExists(path) then return true end if
  return fail(IO_FAILURE, "createDirectory", "Win32 error " + code)
end function

// Removes an empty directory while holding the wide-path native-call guard.
// Input `path` must be non-empty; returns success or a mapped Win32 error.
function synchronized removeDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "removeDirectory", "path must be non-empty") end if
  if RemoveDirectoryW(path) then return true end if
  return lastError("removeDirectory")
end function

// Performs one atomic rename attempt while protecting compiler-managed UTF-16
// path buffers. Returns zero on success or the captured Win32 error code.
// Inputs: `source`, `destination`, and native move flags.
function synchronized movePathAttempt(source, destination, flags)
  if MoveFileExW(source, destination, flags) then return 0 end if
  return GetLastError()
end function

// Atomically renames a path and absorbs only short-lived Windows scanner locks.
// Access-denied and sharing-violation errors are retried for at most one second;
// invalid paths and permanent permission failures remain immediately visible.
// Inputs identify source, destination, and replacement policy.
function movePath(source, destination, replaceExisting)
  if typeof(source) != "string" or len(source) == 0 or typeof(destination) != "string" or len(destination) == 0 then
    return fail(INVALID_ARGUMENT, "movePath", "source and destination must be non-empty")
  end if
  if typeof(replaceExisting) != "bool" then return fail(INVALID_ARGUMENT, "movePath", "replaceExisting must be bool") end if
  flags = MOVEFILE_WRITE_THROUGH
  if replaceExisting then flags = flags | MOVEFILE_REPLACE_EXISTING end if
  lastCode = 0
  for attempt = 0 to MOVE_RETRY_ATTEMPTS
    lastCode = movePathAttempt(source, destination, flags)
    if lastCode == 0 then return true end if
    if lastCode != ERROR_ACCESS_DENIED and lastCode != ERROR_SHARING_VIOLATION then return fail(IO_FAILURE, "movePath", "Win32 error " + lastCode) end if
    if attempt < MOVE_RETRY_ATTEMPTS then Sleep(MOVE_RETRY_DELAY_MS) end if
  end for
  return fail(IO_FAILURE, "movePath", "Win32 error " + lastCode)
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.file_win32"
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
