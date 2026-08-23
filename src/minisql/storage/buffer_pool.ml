package minisql.storage.buffer_pool
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.limits as limits
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import std.ds.hashmap as hashmap
import std.threading as threading

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

// Immutable read-cache frame keyed by a stable file path and page number. It
// deliberately does not retain a PagedFile handle, allowing short-lived scan
// handles to close without leaving dangling cache ownership.
struct ReadCacheFrame
  // Stable file-path and page-number identity used by the lookup map.
  key
  // Immutable verified-size page image retained independently of file handles.
  data
  // CLOCK reference bit set by every successful lookup.
  referenced
end struct

// Thread-safe sparse CLOCK cache used by concurrent SQL table scans. Frames
// are allocated only when populated, so a large byte budget does not eagerly
// allocate one object per possible page.
struct ReadPageCache
  // Maximum number of page images derived from the configured byte budget.
  maxPages
  // Sparse CLOCK frame array; unused slots remain void.
  frames
  // Next CLOCK slot examined for insertion or eviction.
  clockHand
  // Maps stable page keys to their current frame indexes.
  index
  // Serializes lookups and metadata changes without covering disk I/O.
  guard
  // Number of requests served from resident page images.
  hits
  // Number of requests that required a physical page read.
  misses
  // Number of resident page images replaced by CLOCK.
  evictions
  // Prevents use after the database-owned cache has been released.
  closed
end struct

// Snapshot of read-cache counters used by diagnostics and regression tests.
struct ReadPageCacheStats
  // Snapshot of successful resident lookups.
  hits
  // Snapshot of physical-read lookups.
  misses
  // Snapshot of CLOCK replacements.
  evictions
  // Number of populated frames at snapshot time.
  residentPages
  // Configured maximum number of frames.
  maxPages
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

// Converts a byte budget to pages using the database's validated page size.
function pageCapacity(maxBytes, pageSize)
  if typeof(maxBytes) != "int" or maxBytes <= 0 then return fail(INVALID_ARGUMENT, "pageCapacity", "maxBytes must be a positive int") end if
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then return fail(INVALID_ARGUMENT, "pageCapacity", "unsupported page size") end if
  capacity = 0
  if pageSize == 4096 then capacity = maxBytes >> 12
  else if pageSize == 8192 then capacity = maxBytes >> 13
  else if pageSize == 16384 then capacity = maxBytes >> 14
  else if pageSize == 32768 then capacity = maxBytes >> 15
  end if
  if capacity < 1 then return fail(INVALID_ARGUMENT, "pageCapacity", "memory budget is smaller than one page") end if
  if capacity > 1048576 then capacity = 1048576 end if
  return capacity
end function

// Creates the concurrent read cache for a configured memory budget.
function createReadCache(maxBytes, pageSize)
  capacity = pageCapacity(maxBytes, pageSize)
  return ReadPageCache(capacity, array(capacity), 0, hashmap.HashMap.withCapacity(capacity * 2), threading.Lock.new(), 0, 0, 0, false)
end function

// Validates a read cache before synchronization or I/O.
function validateReadCache(cache, operation)
  if cache is not ReadPageCache then return fail(INVALID_ARGUMENT, operation, "cache must be ReadPageCache") end if
  if cache.closed then return fail(CLOSED_HANDLE, operation, "read cache is closed") end if
  return true
end function

// Builds an unambiguous cache key; page paths cannot contain a NUL character.
function readCacheKey(pagedFile, pageNumber)
  return pagedFile.path + "\0" + pageNumber
end function

// Chooses an empty frame or an unreferenced CLOCK victim while the cache guard
// is held. Read frames are never pinned or dirty, so two passes always suffice.
function chooseReadVictim(cache)
  for index = 0 to cache.maxPages - 1
    if cache.frames[index] is void then
      cache.clockHand = (index + 1) % cache.maxPages
      return index
    end if
  end for
  scanned = 0
  while scanned < cache.maxPages * 2
    index = cache.clockHand
    cache.clockHand = (cache.clockHand + 1) % cache.maxPages
    frame = cache.frames[index]
    if frame.referenced then frame.referenced = false else return index end if
    scanned = scanned + 1
  end while
  return 0
end function

// Reads through the concurrent cache. Disk I/O occurs without holding the
// cache guard; a second lookup collapses races when two readers miss together.
function readCached(cache, pagedFile, pageNumber)
  validateReadCache(cache, "readCached")
  paged_file.validateOpen(pagedFile, "buffer_pool.readCached")
  if typeof(pageNumber) != "int" or pageNumber < 0 or pageNumber >= pagedFile.pageCount then return fail(INVALID_ARGUMENT, "readCached", "page number is outside the paged file") end if
  key = readCacheKey(pagedFile, pageNumber)
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "readCached", "cache guard is unavailable") end if
  existing = cache.index.get(key)
  if typeof(existing) == "int" then
    frame = cache.frames[existing]
    frame.referenced = true
    cache.hits = cache.hits + 1
    result = bytes(frame.data)
    cache.guard.release()
    return result
  end if
  cache.misses = cache.misses + 1
  cache.guard.release()

  loaded = paged_file.readPage(pagedFile, pageNumber)
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "readCached", "cache guard is unavailable after read") end if
  raced = cache.index.get(key)
  if typeof(raced) == "int" then
    frame = cache.frames[raced]
    frame.referenced = true
    result = bytes(frame.data)
    cache.guard.release()
    return result
  end if
  victim = chooseReadVictim(cache)
  replaced = cache.frames[victim]
  if replaced is not void then
    cache.index.remove(replaced.key)
    cache.evictions = cache.evictions + 1
  end if
  cache.frames[victim] = ReadCacheFrame(key, bytes(loaded), true)
  cache.index.set(key, victim)
  cache.guard.release()
  return loaded
end function

// Invalidates all cached base pages after a successful database mutation.
function clearReadCache(cache)
  validateReadCache(cache, "clearReadCache")
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "clearReadCache", "cache guard is unavailable") end if
  cache.frames = array(cache.maxPages)
  cache.index.clear()
  cache.clockHand = 0
  cache.guard.release()
  return true
end function

// Returns a synchronized diagnostic snapshot.
function readCacheStats(cache)
  validateReadCache(cache, "readCacheStats")
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "readCacheStats", "cache guard is unavailable") end if
  result = ReadPageCacheStats(cache.hits, cache.misses, cache.evictions, cache.index.count(), cache.maxPages)
  cache.guard.release()
  return result
end function

// Closes a read cache after the owning database execution gate is empty.
function closeReadCache(cache)
  validateReadCache(cache, "closeReadCache")
  if not cache.guard.acquire() then return fail(CLOSED_HANDLE, "closeReadCache", "cache guard is unavailable") end if
  cache.frames = []
  cache.index.clear()
  cache.closed = true
  cache.guard.release()
  cache.guard.close()
  return true
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
