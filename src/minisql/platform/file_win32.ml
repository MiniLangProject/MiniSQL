package minisql.platform.file_win32

import minisql.common.endian as endian

// Thin synchronous Win32 handle layer. The public platform.file module owns
// validation and object lifetime. A handle must not be used concurrently because
// positioned I/O is implemented with SetFilePointerEx followed by ReadFile/WriteFile.

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
const FILE_BEGIN = 0
const LOCKFILE_FAIL_IMMEDIATELY = 0x00000001
const LOCKFILE_EXCLUSIVE_LOCK = 0x00000002
const ERROR_LOCK_VIOLATION = 33
const ERROR_FILE_NOT_FOUND = 2
const ERROR_PATH_NOT_FOUND = 3
const ERROR_ALREADY_EXISTS = 183
const INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF
const FILE_ATTRIBUTE_DIRECTORY = 0x00000010
const MOVEFILE_REPLACE_EXISTING = 0x00000001
const MOVEFILE_WRITE_THROUGH = 0x00000008

extern function CreateFileW(path as wstr, desiredAccess as u32, shareMode as u32, security as ptr, creationDisposition as u32, flagsAndAttributes as u32, templateFile as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
extern function ReadFile(handle as ptr, buffer as bytes, count as u32, bytesRead as bytes, overlapped as ptr) from "kernel32.dll" symbol "ReadFile" returns bool
extern function WriteFile(handle as ptr, buffer as bytes, count as u32, bytesWritten as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
extern function SetFilePointerEx(handle as ptr, distance as i64, newPosition as ptr, moveMethod as u32) from "kernel32.dll" symbol "SetFilePointerEx" returns bool
extern function GetFileSizeEx(handle as ptr, sizeOut as bytes) from "kernel32.dll" symbol "GetFileSizeEx" returns bool
extern function SetEndOfFile(handle as ptr) from "kernel32.dll" symbol "SetEndOfFile" returns bool
extern function FlushFileBuffers(handle as ptr) from "kernel32.dll" symbol "FlushFileBuffers" returns bool
extern function LockFileEx(handle as ptr, flags as u32, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "LockFileEx" returns bool
extern function UnlockFileEx(handle as ptr, reserved as u32, bytesLow as u32, bytesHigh as u32, overlapped as bytes) from "kernel32.dll" symbol "UnlockFileEx" returns bool
extern function CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
extern function DeleteFileW(path as wstr) from "kernel32.dll" symbol "DeleteFileW" returns bool
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" symbol "GetFileAttributesW" returns u32
extern function CreateDirectoryW(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
extern function RemoveDirectoryW(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
extern function GetLastError() from "kernel32.dll" symbol "GetLastError" returns u32

function fail(code, operation, message)
  return error(code, "platform.file_win32." + operation + ": " + message)
end function

function lastError(operation)
  code = GetLastError()
  return fail(IO_FAILURE, operation, "Win32 error " + code)
end function

function isInvalidHandle(handle)
  if typeof(handle) != "int" then return true end if
  return handle == -1 or handle == 0
end function

function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  if typeof(path) != "string" or len(path) == 0 then
    return fail(INVALID_ARGUMENT, "openNative", "path must be a non-empty string")
  end if
  if typeof(desiredAccess) != "int" or typeof(shareMode) != "int" or typeof(creationDisposition) != "int" then
    return fail(INVALID_ARGUMENT, "openNative", "access, share and disposition must be int")
  end if
  if typeof(writeThrough) != "bool" then return fail(INVALID_ARGUMENT, "openNative", "writeThrough must be bool") end if
  flags = FILE_ATTRIBUTE_NORMAL
  if writeThrough then flags = flags | FILE_FLAG_WRITE_THROUGH end if
  handle = CreateFileW(path, desiredAccess, shareMode, void, creationDisposition, flags, void)
  if isInvalidHandle(handle) then return lastError("openNative") end if
  return handle
end function

function seek(handle, offset)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "seek", "invalid handle") end if
  if typeof(offset) != "int" or offset < 0 or offset > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "seek", "offset must be a non-negative native MiniLang int")
  end if
  if not SetFilePointerEx(handle, offset, void, FILE_BEGIN) then return lastError("seek") end if
  return true
end function

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

function size(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "size", "invalid handle") end if
  output = bytes(8, 0)
  if not GetFileSizeEx(handle, output) then return lastError("size") end if
  return endian.readI64AsIntLE(output, 0)
end function

function truncate(handle, newSize)
  seek(handle, newSize)
  if not SetEndOfFile(handle) then return lastError("truncate") end if
  return true
end function

function flush(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "flush", "invalid handle") end if
  if not FlushFileBuffers(handle) then return lastError("flush") end if
  return true
end function

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

function unlockWhole(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "unlockWhole", "invalid handle") end if
  overlapped = bytes(32, 0)
  if not UnlockFileEx(handle, 0, endian.MAX_U32, endian.MAX_U32, overlapped) then return lastError("unlockWhole") end if
  return true
end function

function closeNative(handle)
  if isInvalidHandle(handle) then return fail(INVALID_ARGUMENT, "closeNative", "invalid handle") end if
  if not CloseHandle(handle) then return lastError("closeNative") end if
  return true
end function

function deletePath(path)
  if typeof(path) != "string" or len(path) == 0 then
    return fail(INVALID_ARGUMENT, "deletePath", "path must be a non-empty string")
  end if
  if not DeleteFileW(path) then return lastError("deletePath") end if
  return true
end function


function pathAttributes(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "pathAttributes", "path must be non-empty") end if
  attributes = GetFileAttributesW(path)
  if attributes == INVALID_FILE_ATTRIBUTES then
    code = GetLastError()
    if code == ERROR_FILE_NOT_FOUND or code == ERROR_PATH_NOT_FOUND then return -1 end if
    return fail(IO_FAILURE, "pathAttributes", "Win32 error " + code)
  end if
  return attributes
end function

function pathExists(path)
  return pathAttributes(path) != -1
end function

function directoryExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) != 0
end function

function fileExists(path)
  attributes = pathAttributes(path)
  if attributes == -1 then return false end if
  return (attributes & FILE_ATTRIBUTE_DIRECTORY) == 0
end function

function createDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "createDirectory", "path must be non-empty") end if
  if CreateDirectoryW(path, void) then return true end if
  code = GetLastError()
  if code == ERROR_ALREADY_EXISTS and directoryExists(path) then return true end if
  return fail(IO_FAILURE, "createDirectory", "Win32 error " + code)
end function

function removeDirectory(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "removeDirectory", "path must be non-empty") end if
  if RemoveDirectoryW(path) then return true end if
  return lastError("removeDirectory")
end function

function movePath(source, destination, replaceExisting)
  if typeof(source) != "string" or len(source) == 0 or typeof(destination) != "string" or len(destination) == 0 then
    return fail(INVALID_ARGUMENT, "movePath", "source and destination must be non-empty")
  end if
  if typeof(replaceExisting) != "bool" then return fail(INVALID_ARGUMENT, "movePath", "replaceExisting must be bool") end if
  flags = MOVEFILE_WRITE_THROUGH
  if replaceExisting then flags = flags | MOVEFILE_REPLACE_EXISTING end if
  if not MoveFileExW(source, destination, flags) then return lastError("movePath") end if
  return true
end function

function componentName()
  return "platform.file_win32"
end function

function targetMilestone()
  return "M3"
end function

function isImplemented()
  return true
end function
