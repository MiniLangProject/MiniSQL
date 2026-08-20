package minisql.storage.buffer_pool
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.limits as limits
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file

// Fixed-capacity buffer pool with explicit pin/unpin guards and CLOCK eviction.
// Dirty pages are resealed and written through the owning PagedFile before reuse.

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const BUFFER_POOL_EXHAUSTED = 9009
const PINNED_PAGE = 9010

// Defines the buffer frame record used by this module.
struct BufferFrame
  // Valid field of the buffer frame.
  valid
  // Path field of the buffer frame.
  path
  // Paged file field of the buffer frame.
  pagedFile
  // Page number field of the buffer frame.
  pageNumber
  // Data field of the buffer frame.
  data
  // Pin count field of the buffer frame.
  pinCount
  // Dirty field of the buffer frame.
  dirty
  // Referenced field of the buffer frame.
  referenced
end struct

// Defines the buffer pool record used by this module.
struct BufferPool
  // Capacity field of the buffer pool.
  capacity
  // Frames field of the buffer pool.
  frames
  // Clock hand field of the buffer pool.
  clockHand
  // Hits field of the buffer pool.
  hits
  // Misses field of the buffer pool.
  misses
  // Evictions field of the buffer pool.
  evictions
  // Dirty flushes field of the buffer pool.
  dirtyFlushes
  // Closed field of the buffer pool.
  closed
end struct

// Defines the page guard record used by this module.
struct PageGuard
  // Pool field of the page guard.
  pool
  // Frame index field of the page guard.
  frameIndex
  // Released field of the page guard.
  released
end struct

// Defines the buffer pool stats record used by this module.
struct BufferPoolStats
  // Hits field of the buffer pool stats.
  hits
  // Misses field of the buffer pool stats.
  misses
  // Evictions field of the buffer pool stats.
  evictions
  // Dirty flushes field of the buffer pool stats.
  dirtyFlushes
  // Resident pages field of the buffer pool stats.
  residentPages
  // Pinned pages field of the buffer pool stats.
  pinnedPages
end struct

// Creates the module's structured error with operation context.
// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(code, operation, message)
  return error(code, "storage.buffer_pool." + operation + ": " + message)
end function

// Performs the empty frame operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function emptyFrame()
  return BufferFrame(false, "", void, -1, bytes(), 0, false, false)
end function

// Creates the requested value.
// Inputs: `capacity`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Creates the for bytes.
// Inputs: `maxBytes`, `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Validates the pool.
// Inputs: `pool`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validatePool(pool, operation)
  if pool is not BufferPool then return fail(INVALID_ARGUMENT, operation, "pool must be BufferPool") end if
  if pool.closed then return fail(CLOSED_HANDLE, operation, "buffer pool is closed") end if
  return true
end function

// Validates the guard.
// Inputs: `guard`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
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

// Performs the frame matches file operation for this module.
// Inputs: `frame`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.
function frameMatchesFile(frame, pagedFile)
  if not frame.valid then return false end if
  if frame.pagedFile.closed or frame.pagedFile.file.closed then return false end if
  return frame.pagedFile.file.nativeHandle == pagedFile.file.nativeHandle and
    frame.pagedFile.fileId == pagedFile.fileId and
    frame.path == pagedFile.path
end function

// Finds the frame.
// Inputs: `pool`, `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
function findFrame(pool, pagedFile, pageNumber)
  for index = 0 to pool.capacity - 1
    frame = pool.frames[index]
    if frameMatchesFile(frame, pagedFile) and frame.pageNumber == pageNumber then return index end if
  end for
  return -1
end function

// Flushes the frame.
// Inputs: `pool`, `frameIndex`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
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

// Performs the choose victim operation for this module.
// Inputs: `pool`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Performs the pin operation for this module.
// Inputs: `pool`, `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Performs the data operation for this module.
// Inputs: `guard`. Returns the produced value or propagates a structured error from validation or delegated operations.
function data(guard)
  frame = validateGuard(guard, "data")
  return frame.data
end function

// Marks the dirty.
// Inputs: `guard`. Returns the produced value or propagates a structured error from validation or delegated operations.
function markDirty(guard)
  frame = validateGuard(guard, "markDirty")
  frame.dirty = true
  frame.referenced = true
  return true
end function

// Releases the requested value.
// Inputs: `guard`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function release(guard)
  frame = validateGuard(guard, "release")
  frame.pinCount = frame.pinCount - 1
  guard.released = true
  return true
end function

// Flushes the all.
// Inputs: `pool`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function flushAll(pool)
  validatePool(pool, "flushAll")
  flushed = 0
  for index = 0 to pool.capacity - 1
    if flushFrame(pool, index) then flushed = flushed + 1 end if
  end for
  return flushed
end function

// Performs the invalidate file operation for this module.
// Inputs: `pool`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Performs the stats operation for this module.
// Inputs: `pool`. Returns the produced value or propagates a structured error from validation or delegated operations.
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

// Closes the requested value.
// Inputs: `pool`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
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

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "storage.buffer_pool"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M5"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
