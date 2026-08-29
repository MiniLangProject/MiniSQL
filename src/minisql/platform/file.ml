package minisql.platform.file
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.string as string_api
#if TARGET_OS == "windows"
import minisql.platform.file_win32 as native
#else
import minisql.platform.file_linux as native
#endif

// Validated, lifetime-safe file API layered over the raw Win32 bindings.
// Positioned operations preserve the caller's logical cursor and reject use of
// closed handles before crossing the native boundary.

const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const CLOSED_HANDLE = 9008

// Defines the file handle record used by this module.
struct FileHandle
  // Path field of the file handle.
  path
  // Native handle field of the file handle.
  nativeHandle
  // Readable field of the file handle.
  readable
  // Writable field of the file handle.
  writable
  // Closed field of the file handle.
  closed
  // Lock held field of the file handle.
  lockHeld
  // Write through field of the file handle.
  writeThrough
  // True when readAt uses a native explicit-offset operation.
  positionedRead
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "platform.file." + operation + ": " + message)
end function

// Validates the open.
// Inputs: `file`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateOpen(file, operation)
  if file is not FileHandle then return fail(INVALID_ARGUMENT, operation, "file must be FileHandle") end if
  if file.closed then return fail(CLOSED_HANDLE, operation, "file handle is closed") end if
  return true
end function

// Validates the slice.
// Inputs: `buffer`, `offset`, `count`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateSlice(buffer, offset, count, operation)
  if typeof(buffer) != "bytes" then return fail(INVALID_ARGUMENT, operation, "buffer must be bytes") end if
  if typeof(offset) != "int" or typeof(count) != "int" or offset < 0 or count < 0 then
    return fail(INVALID_ARGUMENT, operation, "offset and count must be non-negative int")
  end if
  if offset > len(buffer) or count > len(buffer) - offset then
    return fail(INVALID_ARGUMENT, operation, "buffer range exceeds bounds")
  end if
  return true
end function

// Performs the share all operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function shareAll()
  return native.FILE_SHARE_READ | native.FILE_SHARE_WRITE | native.FILE_SHARE_DELETE
end function

// Opens the read.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function openRead(path)
  handle = native.openNativePositionedRead(path, native.GENERIC_READ, shareAll(), native.OPEN_EXISTING, false)
  return FileHandle(path, handle, true, false, false, false, false, true)
end function

// Opens the read write.
// Inputs: `path`, `createIfMissing`. Returns the produced value or propagates a structured error from validation or delegated operations.
function openReadWrite(path, createIfMissing)
  if typeof(createIfMissing) != "bool" then return fail(INVALID_ARGUMENT, "openReadWrite", "createIfMissing must be bool") end if
  disposition = native.OPEN_EXISTING
  if createIfMissing then disposition = native.OPEN_ALWAYS end if
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), disposition, false)
  return FileHandle(path, handle, true, true, false, false, false, false)
end function

// Creates the requested value.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function create(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_ALWAYS, false)
  return FileHandle(path, handle, true, true, false, false, false, false)
end function

// Creates the new.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createNew(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_NEW, false)
  return FileHandle(path, handle, true, true, false, false, false, false)
end function

// Creates the durable.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createDurable(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_ALWAYS, true)
  return FileHandle(path, handle, true, true, false, false, true, false)
end function

// Creates the new durable.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createNewDurable(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_NEW, true)
  return FileHandle(path, handle, true, true, false, false, true, false)
end function

// Validates the file range.
// Inputs: `fileOffset`, `count`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validateFileRange(fileOffset, count, operation)
  if typeof(fileOffset) != "int" or fileOffset < 0 or fileOffset > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, operation, "fileOffset must be a non-negative native MiniLang int")
  end if
  if typeof(count) != "int" or count < 0 or count > endian.MAX_U32 then
    return fail(INVALID_ARGUMENT, operation, "count must fit U32")
  end if
  if count > endian.MAX_MINILANG_INT - fileOffset then
    return fail(INVALID_ARGUMENT, operation, "file range exceeds the native MiniLang integer range")
  end if
  return true
end function

// Reads the at.
// Inputs: `file`, `fileOffset`, `destination`, `destinationOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readAt(file, fileOffset, destination, destinationOffset, count)
  validateOpen(file, "readAt")
  if not file.readable then return fail(INVALID_ARGUMENT, "readAt", "file is not readable") end if
  validateSlice(destination, destinationOffset, count, "readAt")
  validateFileRange(fileOffset, count, "readAt")
  if count == 0 then return 0 end if

#if TARGET_OS == "linux"
  return native.readAt(file.nativeHandle, fileOffset, destination, destinationOffset, count)
#else
  if file.positionedRead then
    target = destination
    copyBack = destinationOffset != 0 or count != len(destination)
    if copyBack then target = bytes(count, 0) end if
    actual = try(native.readAt(file.nativeHandle, fileOffset, target, count))
    if typeof(actual) == "error" then return actual end if
    if actual > 0 and copyBack then copyBytes(destination, destinationOffset, target, 0, actual) end if
    return actual
  end if
  native.seek(file.nativeHandle, fileOffset)
  temporary = bytes(count, 0)
  total = 0
  while total < count
    remaining = count - total
    chunk = bytes(remaining, 0)
    actual = native.readCurrent(file.nativeHandle, chunk, remaining)
    if actual == 0 then break end if
    copyBytes(temporary, total, chunk, 0, actual)
    total = total + actual
  end while
  if total > 0 then copyBytes(destination, destinationOffset, temporary, 0, total) end if
  return total
#endif
end function

// Reads the exact at.
// Inputs: `file`, `fileOffset`, `destination`, `destinationOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readExactAt(file, fileOffset, destination, destinationOffset, count)
  actual = readAt(file, fileOffset, destination, destinationOffset, count)
  if actual != count then return fail(IO_FAILURE, "readExactAt", "short read: expected=" + count + " actual=" + actual) end if
  return actual
end function

// Writes the at.
// Inputs: `file`, `fileOffset`, `source`, `sourceOffset`, `count`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function writeAt(file, fileOffset, source, sourceOffset, count)
  validateOpen(file, "writeAt")
  if not file.writable then return fail(INVALID_ARGUMENT, "writeAt", "file is not writable") end if
  validateSlice(source, sourceOffset, count, "writeAt")
  validateFileRange(fileOffset, count, "writeAt")
  if count == 0 then return 0 end if

#if TARGET_OS == "linux"
  return native.writeAt(file.nativeHandle, fileOffset, source, sourceOffset, count)
#else
  native.seek(file.nativeHandle, fileOffset)
  payload = source
  if sourceOffset != 0 or count != len(source) then payload = slice(source, sourceOffset, count) end if
  total = 0
  while total < count
    remaining = count - total
    chunk = payload
    if total != 0 then chunk = slice(payload, total, remaining) end if
    actual = native.writeCurrent(file.nativeHandle, chunk, remaining)
    if actual <= 0 then return fail(IO_FAILURE, "writeAt", "write made no progress") end if
    total = total + actual
  end while
  return total
#endif
end function

// Appends the requested value.
// Inputs: `file`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function append(file, source, sourceOffset, count)
  offset = size(file)
  writeAt(file, offset, source, sourceOffset, count)
  return offset
end function

// Computes the size of the requested value.
// Inputs: `file`. Returns the produced value or propagates a structured error from validation or delegated operations.
function size(file)
  validateOpen(file, "size")
  return native.size(file.nativeHandle)
end function

// Performs the truncate operation for this module.
// Inputs: `file`, `newSize`. Returns the produced value or propagates a structured error from validation or delegated operations.
function truncate(file, newSize)
  validateOpen(file, "truncate")
  if not file.writable then return fail(INVALID_ARGUMENT, "truncate", "file is not writable") end if
  if typeof(newSize) != "int" or newSize < 0 or newSize > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "truncate", "newSize must be a non-negative native MiniLang int")
  end if
  return native.truncate(file.nativeHandle, newSize)
end function

// Flushes the requested value.
// Inputs: `file`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function flush(file)
  validateOpen(file, "flush")
  if not file.writable then return true end if
  return native.flush(file.nativeHandle)
end function

// Closes the requested value.
// Inputs: `file`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(file)
  validateOpen(file, "close")
  if file.lockHeld then
    native.unlockWhole(file.nativeHandle)
    file.lockHeld = false
  end if
  native.closeNative(file.nativeHandle)
  file.closed = true
  file.nativeHandle = 0
  return true
end function

// Deletes the path.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function deletePath(path)
  return native.deletePath(path)
end function


// Performs the path exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function pathExists(path)
  return native.pathExists(path)
end function

// Performs the file exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fileExists(path)
  return native.fileExists(path)
end function

// Performs the directory exists operation for this module.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function directoryExists(path)
  return native.directoryExists(path)
end function

// Creates the directory.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function createDirectory(path)
  return native.createDirectory(path)
end function

// Removes the directory.
// Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.
function removeDirectory(path)
  return native.removeDirectory(path)
end function

// Performs the move path operation for this module.
// Inputs: `source`, `destination`, `replaceExisting`. Returns the produced value or propagates a structured error from validation or delegated operations.
function movePath(source, destination, replaceExisting)
  return native.movePath(source, destination, replaceExisting)
end function

// Reads the all bytes.
// Inputs: `path`, `maximumBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readAllBytes(path, maximumBytes)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "readAllBytes", "path must be non-empty") end if
  if typeof(maximumBytes) != "int" or maximumBytes < 0 or maximumBytes > endian.MAX_MINILANG_INT then return fail(INVALID_ARGUMENT, "readAllBytes", "maximumBytes must be a non-negative native MiniLang int") end if
  handle = try(openRead(path))
  if typeof(handle) == "error" then return handle end if
  length = try(size(handle))
  if typeof(length) == "error" then ignoredClose = try(close(handle)); return length end if
  if length > maximumBytes then ignoredClose = try(close(handle)); return fail(INVALID_ARGUMENT, "readAllBytes", "file exceeds configured size limit") end if
  output = bytes(length, 0)
  if length > 0 then
    readResult = try(readExactAt(handle, 0, output, 0, length))
    if typeof(readResult) == "error" then ignoredClose = try(close(handle)); return readResult end if
  end if
  closed = try(close(handle))
  if typeof(closed) == "error" then return closed end if
  return output
end function

// Reads the all text.
// Inputs: `path`, `maximumBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
function readAllText(path, maximumBytes)
  encoded = try(readAllBytes(path, maximumBytes))
  if typeof(encoded) == "error" then return encoded end if
  decoded = decode(encoded)
  if typeof(decoded) != "string" then return fail(IO_FAILURE, "readAllText", "file is not valid UTF-8") end if
  return decoded
end function

// Performs the join path operation for this module.
// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
function joinPath(left, right)
  if typeof(left) != "string" or len(left) == 0 or typeof(right) != "string" or len(right) == 0 then
    return fail(INVALID_ARGUMENT, "joinPath", "path parts must be non-empty strings")
  end if
  normalizedLeft = left
  normalizedRight = right
#if TARGET_OS == "linux"
  normalizedLeft = string_api.replaceAll(normalizedLeft, "\\", "/")
  normalizedRight = string_api.replaceAll(normalizedRight, "\\", "/")
#endif
  raw = bytes(normalizedLeft)
  last = raw[len(raw) - 1]
  if last == 92 or last == 47 then return normalizedLeft + normalizedRight end if
#if TARGET_OS == "windows"
  return normalizedLeft + "\\" + normalizedRight
#else
  return normalizedLeft + "/" + normalizedRight
#endif
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.file"
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
