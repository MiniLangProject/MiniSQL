package minisql.platform.file

import minisql.common.endian as endian
import minisql.platform.file_win32 as native

const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const CLOSED_HANDLE = 9008

struct FileHandle
  path
  nativeHandle
  readable
  writable
  closed
  lockHeld
  writeThrough
end struct

function fail(code, operation, message)
  return error(code, "platform.file." + operation + ": " + message)
end function

function validateOpen(file, operation)
  if file is not FileHandle then return fail(INVALID_ARGUMENT, operation, "file must be FileHandle") end if
  if file.closed then return fail(CLOSED_HANDLE, operation, "file handle is closed") end if
  return true
end function

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

function shareAll()
  return native.FILE_SHARE_READ | native.FILE_SHARE_WRITE | native.FILE_SHARE_DELETE
end function

function openRead(path)
  handle = native.openNative(path, native.GENERIC_READ, shareAll(), native.OPEN_EXISTING, false)
  return FileHandle(path, handle, true, false, false, false, false)
end function

function openReadWrite(path, createIfMissing)
  if typeof(createIfMissing) != "bool" then return fail(INVALID_ARGUMENT, "openReadWrite", "createIfMissing must be bool") end if
  disposition = native.OPEN_EXISTING
  if createIfMissing then disposition = native.OPEN_ALWAYS end if
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), disposition, false)
  return FileHandle(path, handle, true, true, false, false, false)
end function

function create(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_ALWAYS, false)
  return FileHandle(path, handle, true, true, false, false, false)
end function

function createNew(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_NEW, false)
  return FileHandle(path, handle, true, true, false, false, false)
end function

function createDurable(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_ALWAYS, true)
  return FileHandle(path, handle, true, true, false, false, true)
end function

function createNewDurable(path)
  access = native.GENERIC_READ | native.GENERIC_WRITE
  handle = native.openNative(path, access, shareAll(), native.CREATE_NEW, true)
  return FileHandle(path, handle, true, true, false, false, true)
end function

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

function readAt(file, fileOffset, destination, destinationOffset, count)
  validateOpen(file, "readAt")
  if not file.readable then return fail(INVALID_ARGUMENT, "readAt", "file is not readable") end if
  validateSlice(destination, destinationOffset, count, "readAt")
  validateFileRange(fileOffset, count, "readAt")
  if count == 0 then return 0 end if

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
end function

function readExactAt(file, fileOffset, destination, destinationOffset, count)
  actual = readAt(file, fileOffset, destination, destinationOffset, count)
  if actual != count then return fail(IO_FAILURE, "readExactAt", "short read: expected=" + count + " actual=" + actual) end if
  return actual
end function

function writeAt(file, fileOffset, source, sourceOffset, count)
  validateOpen(file, "writeAt")
  if not file.writable then return fail(INVALID_ARGUMENT, "writeAt", "file is not writable") end if
  validateSlice(source, sourceOffset, count, "writeAt")
  validateFileRange(fileOffset, count, "writeAt")
  if count == 0 then return 0 end if

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
end function

function append(file, source, sourceOffset, count)
  offset = size(file)
  writeAt(file, offset, source, sourceOffset, count)
  return offset
end function

function size(file)
  validateOpen(file, "size")
  return native.size(file.nativeHandle)
end function

function truncate(file, newSize)
  validateOpen(file, "truncate")
  if not file.writable then return fail(INVALID_ARGUMENT, "truncate", "file is not writable") end if
  if typeof(newSize) != "int" or newSize < 0 or newSize > endian.MAX_MINILANG_INT then
    return fail(INVALID_ARGUMENT, "truncate", "newSize must be a non-negative native MiniLang int")
  end if
  return native.truncate(file.nativeHandle, newSize)
end function

function flush(file)
  validateOpen(file, "flush")
  if not file.writable then return true end if
  return native.flush(file.nativeHandle)
end function

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

function deletePath(path)
  return native.deletePath(path)
end function


function pathExists(path)
  return native.pathExists(path)
end function

function fileExists(path)
  return native.fileExists(path)
end function

function directoryExists(path)
  return native.directoryExists(path)
end function

function createDirectory(path)
  return native.createDirectory(path)
end function

function removeDirectory(path)
  return native.removeDirectory(path)
end function

function movePath(source, destination, replaceExisting)
  return native.movePath(source, destination, replaceExisting)
end function

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

function readAllText(path, maximumBytes)
  encoded = try(readAllBytes(path, maximumBytes))
  if typeof(encoded) == "error" then return encoded end if
  decoded = decode(encoded)
  if typeof(decoded) != "string" then return fail(IO_FAILURE, "readAllText", "file is not valid UTF-8") end if
  return decoded
end function

function joinPath(left, right)
  if typeof(left) != "string" or len(left) == 0 or typeof(right) != "string" or len(right) == 0 then
    return fail(INVALID_ARGUMENT, "joinPath", "path parts must be non-empty strings")
  end if
  raw = bytes(left)
  last = raw[len(raw) - 1]
  if last == 92 or last == 47 then return left + right end if
  return left + "\\" + right
end function

function componentName()
  return "platform.file"
end function

function targetMilestone()
  return "M3"
end function

function isImplemented()
  return true
end function
