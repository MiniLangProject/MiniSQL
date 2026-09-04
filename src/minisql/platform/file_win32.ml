//! Provides minisql platform file win32 facilities for this project.

package minisql.platform.file_win32
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.threading as threading

/// Thin Win32 handle layer. The public platform.file module owns validation and

const INVALID_ARGUMENT = 9001
/// Defines the io failure constant used by the minisql platform file win32 module.
const IO_FAILURE = 9005
/// Defines the lock conflict constant used by the minisql platform file win32 module.
const LOCK_CONFLICT = 9007

/// Defines the generic read constant used by the minisql platform file win32 module.
const GENERIC_READ = 0x80000000
/// Defines the generic write constant used by the minisql platform file win32 module.
const GENERIC_WRITE = 0x40000000
/// Defines the file share read constant used by the minisql platform file win32 module.
const FILE_SHARE_READ = 0x00000001
/// Defines the file share write constant used by the minisql platform file win32 module.
const FILE_SHARE_WRITE = 0x00000002
/// Defines the file share delete constant used by the minisql platform file win32 module.
const FILE_SHARE_DELETE = 0x00000004
/// Defines the create new constant used by the minisql platform file win32 module.
const CREATE_NEW = 1
/// Defines the create always constant used by the minisql platform file win32 module.
const CREATE_ALWAYS = 2
/// Defines the open existing constant used by the minisql platform file win32 module.
const OPEN_EXISTING = 3
/// Defines the open always constant used by the minisql platform file win32 module.
const OPEN_ALWAYS = 4
/// Defines the truncate existing constant used by the minisql platform file win32 module.
const TRUNCATE_EXISTING = 5
/// Defines the file attribute normal constant used by the minisql platform file win32 module.
const FILE_ATTRIBUTE_NORMAL = 0x00000080
/// Defines the file flag write through constant used by the minisql platform file win32 module.
const FILE_FLAG_WRITE_THROUGH = 0x80000000
/// Defines the file flag overlapped constant used by the minisql platform file win32 module.
const FILE_FLAG_OVERLAPPED = 0x40000000
/// Defines the file begin constant used by the minisql platform file win32 module.
const FILE_BEGIN = 0
/// Defines the lockfile fail immediately constant used by the minisql platform file win32 module.
const LOCKFILE_FAIL_IMMEDIATELY = 0x00000001
/// Defines the lockfile exclusive lock constant used by the minisql platform file win32 module.
const LOCKFILE_EXCLUSIVE_LOCK = 0x00000002
/// Defines the error lock violation constant used by the minisql platform file win32 module.
const ERROR_LOCK_VIOLATION = 33
/// Defines the error access denied constant used by the minisql platform file win32 module.
const ERROR_ACCESS_DENIED = 5
/// Defines the error sharing violation constant used by the minisql platform file win32 module.
const ERROR_SHARING_VIOLATION = 32
/// Defines the error file not found constant used by the minisql platform file win32 module.
const ERROR_FILE_NOT_FOUND = 2
/// Defines the error path not found constant used by the minisql platform file win32 module.
const ERROR_PATH_NOT_FOUND = 3
/// Defines the error already exists constant used by the minisql platform file win32 module.
const ERROR_ALREADY_EXISTS = 183
/// Defines the error handle eof constant used by the minisql platform file win32 module.
const ERROR_HANDLE_EOF = 38
/// Defines the error io pending constant used by the minisql platform file win32 module.
const ERROR_IO_PENDING = 997
/// Defines the invalid file attributes constant used by the minisql platform file win32 module.
const INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
/// Defines the file attribute directory constant used by the minisql platform file win32 module.
const FILE_ATTRIBUTE_DIRECTORY = 0x00000010
/// Defines the movefile replace existing constant used by the minisql platform file win32 module.
const MOVEFILE_REPLACE_EXISTING = 0x00000001
/// Defines the movefile write through constant used by the minisql platform file win32 module.
const MOVEFILE_WRITE_THROUGH = 0x00000008
/// Defines the move retry attempts constant used by the minisql platform file win32 module.
const MOVE_RETRY_ATTEMPTS = 40
/// Defines the move retry delay ms constant used by the minisql platform file win32 module.
const MOVE_RETRY_DELAY_MS = 25

/// One manual-reset completion event reused by a sequential query or cursor.
/// ResetEvent is required before reuse because overlapped operations may finish
/// synchronously without consuming the event through a wait.
struct PositionedReadContext
  /// Manual-reset event stored in each operation's OVERLAPPED record.
  completion
  /// Prevents an event handle from being reused after close.
  closed
end struct

/// Opens or creates a Win32 file and returns its native handle or INVALID_HANDLE_VALUE.
/// @param path Path of the file or directory used by the operation.
/// @param desiredAccess desiredAccess value consumed by this operation.
/// @param shareMode shareMode value consumed by this operation.
/// @param security security value consumed by this operation.
/// @param creationDisposition creationDisposition value consumed by this operation.
/// @param flagsAndAttributes flagsAndAttributes value consumed by this operation.
/// @param templateFile templateFile value consumed by this operation.
/// @returns Native ptr result produced by the call.
extern function CreateFileW(path as wstr, desiredAccess as u32, shareMode as u32, security as ptr, creationDisposition as u32, flagsAndAttributes as u32, templateFile as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
/// Reads synchronously into `buffer`, writing the transferred count to `bytesRead`.
/// @param handle Native or runtime handle used by the operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param count Number of items or units to process.
/// @param bytesRead bytesRead value consumed by this operation.
/// @param overlapped overlapped value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function ReadFile(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as ptr) from "kernel32.dll" symbol "ReadFile" returns bool
/// Starts one read at the offset stored in a unique OVERLAPPED structure.
/// @param handle Native or runtime handle used by the operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param count Number of items or units to process.
/// @param bytesRead bytesRead value consumed by this operation.
/// @param overlapped overlapped value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function ReadFilePositioned(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as bytes) from "kernel32.dll" symbol "ReadFile" returns bool
/// Writes synchronously from `buffer`, storing the transferred count in `bytesWritten`.
/// @param handle Native or runtime handle used by the operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param count Number of items or units to process.
/// @param bytesWritten bytesWritten value consumed by this operation.
/// @param overlapped overlapped value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function WriteFile(handle as ptr, buffer as bytes, count as u32, bytesWritten as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
/// Waits for one particular overlapped operation and returns its byte count.
/// @param handle Native or runtime handle used by the operation.
/// @param overlapped overlapped value consumed by this operation.
/// @param bytesTransferred bytesTransferred value consumed by this operation.
/// @param wait wait value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetOverlappedResult(handle as ptr, overlapped as bytes, bytesTransferred as bytes, wait as bool) from "kernel32.dll" symbol "GetOverlappedResult" returns bool
/// Repositions the file cursor by `distance` relative to `moveMethod`.
/// @param handle Native or runtime handle used by the operation.
/// @param distance distance value consumed by this operation.
/// @param newPosition newPosition value consumed by this operation.
/// @param moveMethod moveMethod value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function SetFilePointerEx(handle as ptr, distance as i64, newPosition as ptr, moveMethod as u32) from "kernel32.dll" symbol "SetFilePointerEx" returns bool
/// Writes the handle's current 64-bit byte length to `sizeOut`.
/// @param handle Native or runtime handle used by the operation.
/// @param sizeOut sizeOut value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function GetFileSizeEx(handle as ptr, sizeOut as bytes) from "kernel32.dll" symbol "GetFileSizeEx" returns bool
/// Truncates or extends the file at its current cursor position.
/// @param handle Native or runtime handle used by the operation.
/// @returns Native bool result produced by the call.
extern function SetEndOfFile(handle as ptr) from "kernel32.dll" symbol "SetEndOfFile" returns bool
/// Forces buffered data and metadata for `handle` to stable storage.
/// @param handle Native or runtime handle used by the operation.
/// @returns Native bool result produced by the call.
extern function FlushFileBuffers(handle as ptr) from "kernel32.dll" symbol "FlushFileBuffers" returns bool
/// Acquires the requested byte-range lock described by `overlapped` and length words.
/// @param handle Native or runtime handle used by the operation.
/// @param flags Bit flags controlling the operation.
/// @param reserved reserved value consumed by this operation.
/// @param bytesLow bytesLow value consumed by this operation.
/// @param bytesHigh bytesHigh value consumed by this operation.
/// @param overlapped overlapped value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function LockFileEx(handle as ptr, flags as u32, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "LockFileEx" returns bool
/// Releases the byte-range lock described by `overlapped` and length words.
/// @param handle Native or runtime handle used by the operation.
/// @param reserved reserved value consumed by this operation.
/// @param bytesLow bytesLow value consumed by this operation.
/// @param bytesHigh bytesHigh value consumed by this operation.
/// @param overlapped overlapped value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function UnlockFileEx(handle as ptr, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "UnlockFileEx" returns bool
/// Releases one Win32 kernel handle and reports whether closing succeeded.
/// @param handle Native or runtime handle used by the operation.
/// @returns Native bool result produced by the call.
extern function CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
/// Deletes the file identified by a UTF-16 path and reports Win32 success.
/// @param path Path of the file or directory used by the operation.
/// @returns Native bool result produced by the call.
extern function DeleteFileW(path as wstr) from "kernel32.dll" symbol "DeleteFileW" returns bool
/// Returns Win32 attributes for a UTF-16 path or INVALID_FILE_ATTRIBUTES.
/// @param path Path of the file or directory used by the operation.
/// @returns Native u32 result produced by the call.
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" symbol "GetFileAttributesW" returns u32
/// Creates a directory at the UTF-16 path and reports Win32 success.
/// @param path Path of the file or directory used by the operation.
/// @param security security value consumed by this operation.
/// @returns Native bool result produced by the call.
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
/// Removes an empty directory at the UTF-16 path and reports Win32 success.
/// @param path Path of the file or directory used by the operation.
/// @returns Native bool result produced by the call.
extern function RemoveDirectoryW(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
/// Renames or replaces a path according to `flags` and reports Win32 success.
/// @param source source value consumed by this operation.
/// @param destination destination value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native bool result produced by the call.
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
/// Returns the calling thread's most recent Win32 error code.
/// @returns Native u32 result produced by the call.
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32
/// Suspends the calling thread for the requested number of milliseconds.
/// @param milliseconds milliseconds value consumed by this operation.
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void

/// Performs the fail operation for the minisql platform file win32 module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "platform.file_win32." + operation + ": " + message)
end function

/// Performs the last error operation for this module.
/// Inputs: `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param operation operation value consumed by this operation.
function lastError(operation)
  code = GetLastError()
  return fail(IO_FAILURE, operation, "Win32 error " + code)
end function

/// Evaluates whether the supplied input satisfies the invalid handle predicate.
/// Inputs: `handle`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param handle Native or runtime handle used by the operation.
function isInvalidHandle(handle)
  if typeof(handle) != "int" then return true end if
  return handle == -1 or handle == 0
end function

/// MiniLang's extern wstr conversion currently uses process-wide UTF-16 scratch
/// buffers. Serialize only path-bearing native calls; positioned file I/O stays
/// parallel because it uses independent handles and byte buffers.
/// @param path Path of the file or directory used by the operation.
/// @param desiredAccess desiredAccess value consumed by this operation.
/// @param shareMode shareMode value consumed by this operation.
/// @param creationDisposition creationDisposition value consumed by this operation.
/// @param writeThrough writeThrough value consumed by this operation.
/// @param extraFlags extraFlags value consumed by this operation.
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

/// Opens a conventional synchronous handle used by serialized write paths.
/// @param path Path of the file or directory used by the operation.
/// @param desiredAccess desiredAccess value consumed by this operation.
/// @param shareMode shareMode value consumed by this operation.
/// @param creationDisposition creationDisposition value consumed by this operation.
/// @param writeThrough writeThrough value consumed by this operation.
function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  return openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, 0)
end function

/// Opens a read-only handle whose operations carry explicit byte offsets and can
/// safely overlap on the same kernel file object.
/// @param path Path of the file or directory used by the operation.
/// @param desiredAccess desiredAccess value consumed by this operation.
/// @param shareMode shareMode value consumed by this operation.
/// @param creationDisposition creationDisposition value consumed by this operation.
/// @param writeThrough writeThrough value consumed by this operation.
function openNativePositionedRead(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  return openNativeWithFlags(path, desiredAccess, shareMode, creationDisposition, writeThrough, FILE_FLAG_OVERLAPPED)
end function

/// Performs the seek operation for this module.
/// Inputs: `handle`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handle Native or runtime handle used by the operation.
/// @param offset Zero-based offset at which processing starts.
function seek(handle, offset)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "seek", "invalid handle") end if
  if typeof(offset) != "int" or offset < 0 or offset > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "seek", "offset must be a non-negative native MiniLang int")
  end if
  if not SetFilePointerEx(handle, offset, void, FILE_BEGIN) then return lastError("seek") end if
  return true
end function

/// Reads the current.
/// Inputs: `handle`, `destination`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handle Native or runtime handle used by the operation.
/// @param destination destination value consumed by this operation.
/// @param count Number of items or units to process.
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

/// Creates one reusable completion event for a query-local positioned-read lease.
function createReadContext()
  completion = try(threading.Event.new(true, false))
  if typeof(completion) == "error" then return fail(IO_FAILURE, "createReadContext", completion.message) end if
  return PositionedReadContext(completion, false)
end function

/// Closes a query-local completion event after its final read has completed.
/// @param context Context that carries state for the operation.
function closeReadContext(context)
  if context is not PositionedReadContext then return fail(INVALID_ARGUMENT, "closeReadContext", "context must be PositionedReadContext") end if
  if context.closed then return fail(INVALID_ARGUMENT, "closeReadContext", "context is already closed") end if
  if not context.completion.close() then return fail(IO_FAILURE, "closeReadContext", "could not close completion event") end if
  context.closed = true
  return true
end function

/// Reads at an explicit byte offset with one caller-owned completion event. The
/// OVERLAPPED record remains unique to the operation while event creation is
/// amortized across every page read in the owning query lease.
/// @param handle Native or runtime handle used by the operation.
/// @param fileOffset fileOffset value consumed by this operation.
/// @param destination destination value consumed by this operation.
/// @param count Number of items or units to process.
/// @param context Context that carries state for the operation.
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

/// Compatibility positioned read whose temporary context owns exactly one read.
/// @param handle Native or runtime handle used by the operation.
/// @param fileOffset fileOffset value consumed by this operation.
/// @param destination destination value consumed by this operation.
/// @param count Number of items or units to process.
function readAt(handle, fileOffset, destination, count)
  context = try(createReadContext())
  if typeof(context) == "error" then return context end if
  result = try(readAtWithContext(handle, fileOffset, destination, count, context))
  closed = try(closeReadContext(context))
  if typeof(result) == "error" then return result end if
  if typeof(closed) == "error" then return closed end if
  return result
end function

/// Writes the current.
/// Inputs: `handle`, `source`, `count`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param handle Native or runtime handle used by the operation.
/// @param source source value consumed by this operation.
/// @param count Number of items or units to process.
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

/// Computes the size of the requested value.
/// Inputs: `handle`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handle Native or runtime handle used by the operation.
function size(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "size", "invalid handle") end if
  output = bytes(8, 0)
  if not GetFileSizeEx(handle, output) then return lastError("size") end if
  return endian.readI64AsIntLE(output, 0)
end function

/// Performs the truncate operation for this module.
/// Inputs: `handle`, `newSize`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handle Native or runtime handle used by the operation.
/// @param newSize newSize value consumed by this operation.
function truncate(handle, newSize)
  seek(handle, newSize)
  if not SetEndOfFile(handle) then return lastError("truncate") end if
  return true
end function

/// Performs the flush operation for the minisql platform file win32 module.
/// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param handle Native or runtime handle used by the operation.
function flush(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "flush", "invalid handle") end if
  if not FlushFileBuffers(handle) then return lastError("flush") end if
  return true
end function

/// Locks the whole.
/// Inputs: `handle`, `exclusive`, `failImmediately`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handle Native or runtime handle used by the operation.
/// @param exclusive exclusive value consumed by this operation.
/// @param failImmediately failImmediately value consumed by this operation.
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

/// Unlocks the whole.
/// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param handle Native or runtime handle used by the operation.
function unlockWhole(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "unlockWhole", "invalid handle") end if
  overlapped = bytes(32, 0)
  if not UnlockFileEx(handle, 0, endian.MAX_U32, endian.MAX_U32, overlapped) then return lastError("unlockWhole") end if
  return true
end function

/// Closes the native.
/// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param handle Native or runtime handle used by the operation.
function closeNative(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "closeNative", "invalid handle") end if
  if not CloseHandle(handle) then return lastError("closeNative") end if
  return true
end function

/// Deletes the path while holding the compiler-required wide-path call guard.
/// Input `path` must be non-empty; returns success or a mapped Win32 error.
/// @param path Path of the file or directory used by the operation.
function synchronized deletePath(path)
  if typeof(path) != "string" or len(path) == 0 then
    return fail(INVALID_ARGUMENT, "deletePath", "path must be a non-empty string")
  end if
  if not DeleteFileW(path) then return lastError("deletePath") end if
  return true
end function


/// Reads Win32 attributes while serializing access to the compiler's path buffer.
/// Input `path` must be non-empty; returns attributes, -1 when absent, or an error.
/// @param path Path of the file or directory used by the operation.
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

/// Performs the pathExists operation for the minisql platform file win32 module.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function pathExists(path)
  return pathAttributes(path) != -1
end function

/// Performs the directory exists operation for this module.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function directoryExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) != 0
end function

/// Performs the file exists operation for this module.
/// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param path Path of the file or directory used by the operation.
function fileExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0
end function

/// Creates one directory while holding the wide-path native-call guard.
/// Input `path` must be non-empty; an existing directory is treated as success.
/// @param path Path of the file or directory used by the operation.
function synchronized createDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "createDirectory", "path must be non-empty") end if
  if CreateDirectoryW(path, void) then return true end if
  code = GetLastError()
  if code == ERROR_ALREADY_EXISTS and directoryExists(path) then return true end if
  return fail(IO_FAILURE, "createDirectory", "Win32 error " + code)
end function

/// Removes an empty directory while holding the wide-path native-call guard.
/// Input `path` must be non-empty; returns success or a mapped Win32 error.
/// @param path Path of the file or directory used by the operation.
function synchronized removeDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "removeDirectory", "path must be non-empty") end if
  if RemoveDirectoryW(path) then return true end if
  return lastError("removeDirectory")
end function

/// Performs one atomic rename attempt while protecting compiler-managed UTF-16
/// path buffers. Returns zero on success or the captured Win32 error code.
/// Inputs: `source`, `destination`, and native move flags.
/// @param source source value consumed by this operation.
/// @param destination destination value consumed by this operation.
/// @param flags Bit flags controlling the operation.
function synchronized movePathAttempt(source, destination, flags)
  if MoveFileExW(source, destination, flags) then return 0 end if
  return GetLastError()
end function

/// Atomically renames a path and absorbs only short-lived Windows scanner locks.
/// Access-denied and sharing-violation errors are retried for at most one second;
/// invalid paths and permanent permission failures remain immediately visible.
/// Inputs identify source, destination, and replacement policy.
/// @param source source value consumed by this operation.
/// @param destination destination value consumed by this operation.
/// @param replaceExisting replaceExisting value consumed by this operation.
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

/// Performs the componentName operation for the minisql platform file win32 module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.file_win32"
end function

/// Performs the targetMilestone operation for the minisql platform file win32 module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M3"
end function

/// Returns whether implemented satisfies the condition required by the minisql platform file win32 module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
