package minisql.storage.buffer_pool

import minisql.common.limits as limits
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file

// Fixed-capacity buffer pool with explicit pin/unpin guards and CLOCK eviction.
// Dirty pages are resealed and written through the owning PagedFile before reuse.

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const BUFFER_POOL_EXHAUSTED = 9009
const PINNED_PAGE = 9010

struct BufferFrame
  valid
  path
  pagedFile
  pageNumber
  data
  pinCount
  dirty
  referenced
end struct

struct BufferPool
  capacity
  frames
  clockHand
  hits
  misses
  evictions
  dirtyFlushes
  closed
end struct

struct PageGuard
  pool
  frameIndex
  released
end struct

struct BufferPoolStats
  hits
  misses
  evictions
  dirtyFlushes
  residentPages
  pinnedPages
end struct

function fail(code, operation, message)
  return error(code, "storage.buffer_pool." + operation + ": " + message)
end function

function emptyFrame()
  return BufferFrame(false, "", void, -1, bytes(), 0, false, false)
end function

function create(capacity)
  if typeof(capacity) != "int" or capacity <= 0 or capacity > 1048576 then
    return fail(INVALID_ARGUMENT, "create", "capacity must be an int in 1..1048576")
  end if
  frames = array(capacity)
  for index = 0 to capacity - 1
    frames[index] = emptyFrame()
  end for
  return BufferPool(capacity, frames, 0, 0, 0, 0, 0, false)
end function

function createForBytes(maxBytes, pageSize)
  if typeof(maxBytes) != "int" or maxBytes <= 0 then
    return fail(INVALID_ARGUMENT, "createForBytes", "maxBytes must be a positive int")
  end if
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    return fail(INVALID_ARGUMENT, "createForBytes", "unsupported page size")
  end if
  capacity = 0
  if pageSize == 4096 then
    capacity = maxBytes >> 12
  else if pageSize == 8192 then
    capacity = maxBytes >> 13
  else if pageSize == 16384 then
    capacity = maxBytes >> 14
  else if pageSize == 32768 then
    capacity = maxBytes >> 15
  end if
  if capacity < 1 then
    return fail(INVALID_ARGUMENT, "createForBytes", "memory budget is smaller than one page")
  end if
  return create(capacity)
end function

function validatePool(pool, operation)
  if pool is not BufferPool then return fail(INVALID_ARGUMENT, operation, "pool must be BufferPool") end if
  if pool.closed then return fail(CLOSED_HANDLE, operation, "buffer pool is closed") end if
  return true
end function

function validateGuard(guard, operation)
  if guard is not PageGuard then return fail(INVALID_ARGUMENT, operation, "guard must be PageGuard") end if
  validatePool(guard.pool, operation)
  if guard.released then return fail(INVALID_ARGUMENT, operation, "page guard is already released") end if
  if typeof(guard.frameIndex) != "int" or guard.frameIndex < 0 or guard.frameIndex >= guard.pool.capacity then
    return fail(INVALID_ARGUMENT, operation, "page guard frame index is invalid")
  end if
  frame = guard.pool.frames[guard.frameIndex]
  if not frame.valid or frame.pinCount <= 0 then
    return fail(INVALID_ARGUMENT, operation, "page guard no longer owns a pinned frame")
  end if
  return frame
end function

function frameMatchesFile(frame, pagedFile)
  if not frame.valid then return false end if
  if frame.pagedFile.closed or frame.pagedFile.file.closed then return false end if
  return frame.pagedFile.file.nativeHandle == pagedFile.file.nativeHandle and
    frame.pagedFile.fileId == pagedFile.fileId and
    frame.path == pagedFile.path
end function

function findFrame(pool, pagedFile, pageNumber)
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frameMatchesFile(frame, pagedFile) and frame.pageNumber == pageNumber then return index end if
  end for
  return -1
end function

function flushFrame(pool, frameIndex)
  frame = pool.frames[frameIndex]
  if not frame.valid or not frame.dirty then return false end if
  page.reseal(frame.data)
  paged_file.writePage(frame.pagedFile, frame.pageNumber, frame.data)
  paged_file.flush(frame.pagedFile)
  frame.dirty = false
  pool.dirtyFlushes = pool.dirtyFlushes + 1
  return true
end function

function chooseVictim(pool)
  for index = 0 to pool.capacity - 1
    if not pool.frames[index].valid then
      pool.clockHand = (index + 1) % pool.capacity
      return index
    end if
  end for

  scanned = 0
  while scanned < pool.capacity * 2
    index = pool.clockHand
    pool.clockHand = (pool.clockHand + 1) % pool.capacity
    frame = pool.frames[index]
    if frame.pinCount == 0 then
      if frame.referenced then
        frame.referenced = false
      else
        return index
      end if
    end if
    scanned = scanned + 1
  end while
  return fail(BUFFER_POOL_EXHAUSTED, "chooseVictim", "all frames are pinned")
end function

function pin(pool, pagedFile, pageNumber)
  validatePool(pool, "pin")
  paged_file.validateOpen(pagedFile, "buffer_pool.pin")
  if typeof(pageNumber) != "int" or pageNumber < 0 or pageNumber >= pagedFile.pageCount then
    return fail(INVALID_ARGUMENT, "pin", "page number is outside the paged file")
  end if

  existing = findFrame(pool, pagedFile, pageNumber)
  if existing >= 0 then
    frame = pool.frames[existing]
    frame.pinCount = frame.pinCount + 1
    frame.referenced = true
    pool.hits = pool.hits + 1
    return PageGuard(pool, existing, false)
  end if

  pool.misses = pool.misses + 1
  victim = chooseVictim(pool)
  frame = pool.frames[victim]
  if frame.valid then
    flushFrame(pool, victim)
    pool.evictions = pool.evictions + 1
  end if

  loaded = paged_file.readPage(pagedFile, pageNumber)
  pool.frames[victim] = BufferFrame(
    true,
    pagedFile.path,
    pagedFile,
    pageNumber,
    loaded,
    1,
    false,
    true
  )
  return PageGuard(pool, victim, false)
end function

function data(guard)
  frame = validateGuard(guard, "data")
  return frame.data
end function

function markDirty(guard)
  frame = validateGuard(guard, "markDirty")
  frame.dirty = true
  frame.referenced = true
  return true
end function

function release(guard)
  frame = validateGuard(guard, "release")
  frame.pinCount = frame.pinCount - 1
  guard.released = true
  return true
end function

function flushAll(pool)
  validatePool(pool, "flushAll")
  flushed = 0
  for index = 0 to pool.capacity - 1
    if flushFrame(pool, index) then flushed = flushed + 1 end if
  end for
  return flushed
end function

function invalidateFile(pool, pagedFile)
  validatePool(pool, "invalidateFile")
  paged_file.validateOpen(pagedFile, "buffer_pool.invalidateFile")
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frameMatchesFile(frame, pagedFile) and frame.pinCount > 0 then
      return fail(PINNED_PAGE, "invalidateFile", "cannot invalidate a pinned page")
    end if
  end for
  invalidated = 0
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frameMatchesFile(frame, pagedFile) then
      flushFrame(pool, index)
      pool.frames[index] = emptyFrame()
      invalidated = invalidated + 1
    end if
  end for
  return invalidated
end function

function stats(pool)
  validatePool(pool, "stats")
  resident = 0
  pinned = 0
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frame.valid then
      resident = resident + 1
      if frame.pinCount > 0 then pinned = pinned + 1 end if
    end if
  end for
  return BufferPoolStats(pool.hits, pool.misses, pool.evictions, pool.dirtyFlushes, resident, pinned)
end function

function close(pool)
  validatePool(pool, "close")
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frame.valid and frame.pinCount > 0 then
      return fail(PINNED_PAGE, "close", "cannot close while pages are pinned")
    end if
  end for
  flushAll(pool)
  pool.closed = true
  return true
end function

function componentName()
  return "storage.buffer_pool"
end function

function targetMilestone()
  return "M5"
end function

function isImplemented()
  return true
end function
