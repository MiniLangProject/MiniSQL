package minisql.platform.file_linux
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.io.file as portable

// POSIX adapter matching the historical file_win32 contract. Keeping this
// boundary lets the storage engine retain its validated FileHandle API while
// Linux uses positioned I/O, fsync, flock, and atomic rename from std.io.file.
const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const LOCK_CONFLICT = 9007

const GENERIC_READ = 0x80000000
const GENERIC_WRITE = 0x40000000
const FILE_SHARE_READ = 1
const FILE_SHARE_WRITE = 2
const FILE_SHARE_DELETE = 4
const CREATE_NEW = 1
const CREATE_ALWAYS = 2
const OPEN_EXISTING = 3
const OPEN_ALWAYS = 4
const TRUNCATE_EXISTING = 5
const FILE_ATTRIBUTE_DIRECTORY = 0x10
const INVALID_FILE_ATTRIBUTES = 0xFFFFFFFF

// Holds the portable file object and the compatibility cursor used by sequential calls.
struct NativeFile
  // Open `std.io.file` object that owns the native descriptor.
  file
  // Logical offset used only by seek plus readCurrent/writeCurrent.
  cursor
end struct

// Creates a MiniSQL platform error with consistent Linux component context.
function fail(code, operation, message)
  return error(code, "platform.file_linux." + operation + ": " + message)
end function

// Converts a portable file result to MiniSQL's stable storage error codes.
function convert(result, operation)
  if typeof(result) != "error" then return result end if
  if result.code == portable.LOCK_CONFLICT then return fail(LOCK_CONFLICT, operation, result.message) end if
  return fail(IO_FAILURE, operation, result.message)
end function

// Opens a portable descriptor using the established Win32-like facade contract.
function openNative(path, desiredAccess, shareMode, creationDisposition, writeThrough)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "openNative", "path must be non-empty") end if
  if typeof(writeThrough) != "bool" then return fail(INVALID_ARGUMENT, "openNative", "writeThrough must be bool") end if
  readable = (desiredAccess & GENERIC_READ) != 0
  writable = (desiredAccess & GENERIC_WRITE) != 0
  opened = void
  if creationDisposition == OPEN_EXISTING then
    if writable then opened = try(portable.openReadWrite(path, false)) else opened = try(portable.openRead(path)) end if
  else if creationDisposition == OPEN_ALWAYS then
    if writeThrough then opened = try(portable.openReadWriteDurable(path, true)) else opened = try(portable.openReadWrite(path, true)) end if
  else if creationDisposition == CREATE_ALWAYS then
    if writeThrough then opened = try(portable.createDurable(path)) else opened = try(portable.create(path)) end if
  else if creationDisposition == CREATE_NEW then
    if writeThrough then opened = try(portable.createNewDurable(path)) else opened = try(portable.createNew(path)) end if
  else if creationDisposition == TRUNCATE_EXISTING then
    opened = try(portable.openReadWrite(path, false))
    if typeof(opened) != "error" then truncated = try(portable.truncate(opened, 0)); if typeof(truncated) == "error" then ignoredClose = try(portable.close(opened)); opened = truncated end if end if
  else
    return fail(INVALID_ARGUMENT, "openNative", "unsupported creation disposition")
  end if
  opened = convert(opened, "openNative")
  if typeof(opened) == "error" then return opened end if
  return NativeFile(opened, 0)
end function

// Moves the compatibility cursor without changing the native descriptor offset.
function seek(handle, offset)
  if handle is not NativeFile or typeof(offset) != "int" or offset < 0 then return fail(INVALID_ARGUMENT, "seek", "invalid handle or offset") end if
  handle.cursor = offset
  return true
end function

// Reads from the compatibility cursor and advances it by the transferred count.
function readCurrent(handle, destination, count)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "readCurrent", "invalid handle") end if
  actual = convert(try(portable.readAt(handle.file, handle.cursor, destination, 0, count)), "readCurrent")
  if typeof(actual) == "error" then return actual end if
  handle.cursor = handle.cursor + actual
  return actual
end function

// Positioned operations avoid a shared logical cursor when database readers
// use the same handle concurrently.
function readAt(handle, fileOffset, destination, destinationOffset, count)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "readAt", "invalid handle") end if
  return convert(try(portable.readAt(handle.file, fileOffset, destination, destinationOffset, count)), "readAt")
end function

// Writes from the compatibility cursor and advances it by the transferred count.
function writeCurrent(handle, source, count)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "writeCurrent", "invalid handle") end if
  actual = convert(try(portable.writeAt(handle.file, handle.cursor, source, 0, count)), "writeCurrent")
  if typeof(actual) == "error" then return actual end if
  handle.cursor = handle.cursor + actual
  return actual
end function

// Writes a source range at an explicit file offset without changing the cursor.
function writeAt(handle, fileOffset, source, sourceOffset, count)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "writeAt", "invalid handle") end if
  return convert(try(portable.writeAt(handle.file, fileOffset, source, sourceOffset, count)), "writeAt")
end function

// Returns the current physical file size.
function size(handle)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "size", "invalid handle") end if
  return convert(try(portable.size(handle.file)), "size")
end function

// Changes the physical file size through the portable backend.
function truncate(handle, newSize)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "truncate", "invalid handle") end if
  return convert(try(portable.truncate(handle.file, newSize)), "truncate")
end function

// Forces writable data and metadata to stable storage.
function flush(handle)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "flush", "invalid handle") end if
  return convert(try(portable.flush(handle.file)), "flush")
end function

// Acquires a shared or exclusive whole-file lock.
function lockWhole(handle, exclusive, failImmediately)
  if handle is not NativeFile or typeof(exclusive) != "bool" or typeof(failImmediately) != "bool" then return fail(INVALID_ARGUMENT, "lockWhole", "invalid arguments") end if
  mode = "shared"
  if exclusive then mode = "exclusive" end if
  return convert(try(portable.lock(handle.file, mode, not failImmediately)), "lockWhole")
end function

// Releases the whole-file lock owned by this descriptor.
function unlockWhole(handle)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "unlockWhole", "invalid handle") end if
  return convert(try(portable.unlock(handle.file)), "unlockWhole")
end function

// Closes the portable descriptor after its caller has released any lock.
function closeNative(handle)
  if handle is not NativeFile then return fail(INVALID_ARGUMENT, "closeNative", "invalid handle") end if
  return convert(try(portable.close(handle.file)), "closeNative")
end function

// Deletes one file-system path.
function deletePath(path) return convert(try(portable.deletePath(path)), "deletePath") end function
// Reports whether either a file or directory exists at the path.
function pathExists(path) return portable.pathExists(path) end function
// Reports whether a directory exists at the path.
function directoryExists(path) return portable.directoryExists(path) end function
// Reports whether a regular file exists at the path.
function fileExists(path) return portable.fileExists(path) end function
// Creates one directory and retains the failing path in diagnostic errors.
function createDirectory(path)
  result = try(portable.createDirectory(path))
  if typeof(result) == "error" then return fail(IO_FAILURE, "createDirectory", result.message + " (path=" + path + ")") end if
  return result
end function
// Removes one empty directory, including portable error translation.
function removeDirectory(path) return convert(try(portable.removeDirectory(path)), "removeDirectory") end function
// Atomically renames a path and optionally replaces the destination.
function movePath(source, destination, replaceExisting) return convert(try(portable.movePath(source, destination, replaceExisting)), "movePath") end function

// Returns the directory attribute bit, zero for files, or the invalid sentinel.
function pathAttributes(path)
  if directoryExists(path) then return FILE_ATTRIBUTE_DIRECTORY end if
  if fileExists(path) then return 0 end if
  return INVALID_FILE_ATTRIBUTES
end function

// Returns the stable diagnostic name used by the module catalog.
function componentName()
  return "platform.file_linux"
end function

// Returns the first MiniSQL milestone whose file contract this adapter implements.
function targetMilestone()
  return "M3"
end function

// Reports that the Linux backend is complete.
function isImplemented()
  return true
end function
