// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.storage.buffer_pool as buffer_pool
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import minisql.storage.superblock as superblock
import tests.support.testkit as test

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  value = bytes(16, 0)
  for index = 0 to 15
    value[index] = index + 1
  end for
  return value
end function

// Creates, appends, and unpins a deterministic page so buffer-pool eviction tests begin with known bytes.
function initializePage(file, pageNumber, marker)
  data = paged_file.readPage(file, pageNumber)
  data[page.HEADER_SIZE] = marker
  page.reseal(data)
  paged_file.writePage(file, pageNumber, data)
end function

// Runs the buffer pool test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 1 then
    print "MiniSQL M5 buffer-pool tests: FAIL (expected one path argument)"
    return 2
  end if

  file = paged_file.create(args[0], 4096, superblock.FILE_TYPE_GENERIC, 501, databaseId())
  for pageNumber = 0 to 4
    paged_file.allocatePage(file, page.TYPE_GENERIC)
    initializePage(file, pageNumber, pageNumber + 1)
  end for
  paged_file.flush(file)

  budgetPool = buffer_pool.createForBytes(8192, 4096)
  test.equal(state, budgetPool.capacity, 2, "byte budget converted to frames")
  buffer_pool.close(budgetPool)
  test.errorCode(state, try(buffer_pool.createForBytes(1024, 4096)), 9001, "byte budget below one page")

  readCache = buffer_pool.createReadCache(8192, 4096)
  cachedRead = buffer_pool.readCached(readCache, file, 0)
  cachedReadAgain = buffer_pool.readCached(readCache, file, 0)
  test.equal(state, cachedRead[page.HEADER_SIZE], 1, "read cache initial marker")
  test.equal(state, cachedReadAgain[page.HEADER_SIZE], 1, "read cache hit marker")
  readStats = buffer_pool.readCacheStats(readCache)
  test.equal(state, readStats.misses, 1, "read cache miss count")
  test.equal(state, readStats.hits, 1, "read cache hit count")
  test.equal(state, readStats.residentPages, 1, "read cache resident count")
  buffer_pool.clearReadCache(readCache)
  test.equal(state, buffer_pool.readCacheStats(readCache).residentPages, 0, "read cache invalidation")
  buffer_pool.closeReadCache(readCache)
  test.errorCode(state, try(buffer_pool.readCacheStats(readCache)), 9008, "closed read cache rejected")

  pool = buffer_pool.create(2)
  guard0 = buffer_pool.pin(pool, file, 0)
  test.equal(state, buffer_pool.data(guard0)[page.HEADER_SIZE], 1, "page zero marker")
  guard0Again = buffer_pool.pin(pool, file, 0)
  guard1 = buffer_pool.pin(pool, file, 1)
  test.equal(state, buffer_pool.data(guard0Again)[page.HEADER_SIZE], 1, "cache hit marker")
  test.errorCode(state, try(buffer_pool.pin(pool, file, 2)), 9009, "all frames pinned")

  buffer_pool.release(guard0Again)
  buffer_pool.release(guard0)
  guard2 = buffer_pool.pin(pool, file, 2)
  test.equal(state, buffer_pool.data(guard2)[page.HEADER_SIZE], 3, "evicted frame replacement")
  page2 = buffer_pool.data(guard2)
  page2[page.HEADER_SIZE] = 99
  buffer_pool.markDirty(guard2)
  buffer_pool.release(guard2)
  test.errorCode(state, try(buffer_pool.release(guard2)), 9001, "double release")

  guard1Again = buffer_pool.pin(pool, file, 1)
  test.equal(state, buffer_pool.data(guard1Again)[page.HEADER_SIZE], 2, "second cache hit")
  buffer_pool.release(guard1Again)
  buffer_pool.release(guard1)

  flushed = buffer_pool.flushAll(pool)
  test.record(state, flushed >= 1, "dirty page flushed")
  stats = buffer_pool.stats(pool)
  test.record(state, stats.hits >= 2, "hit statistics")
  test.record(state, stats.misses >= 3, "miss statistics")
  test.record(state, stats.evictions >= 1, "eviction statistics")
  test.record(state, stats.dirtyFlushes >= 1, "dirty flush statistics")
  test.record(state, stats.residentPages <= 2, "capacity respected")
  test.equal(state, stats.pinnedPages, 0, "no pinned pages")

  guard4 = buffer_pool.pin(pool, file, 4)
  test.errorCode(state, try(buffer_pool.close(pool)), 9010, "close rejects pinned page")
  buffer_pool.release(guard4)
  test.record(state, buffer_pool.close(pool), "buffer pool close")
  test.errorCode(state, try(buffer_pool.stats(pool)), 9008, "closed pool rejected")
  paged_file.close(file)

  reopened = paged_file.open(args[0])
  persisted = paged_file.readPage(reopened, 2)
  test.equal(state, persisted[page.HEADER_SIZE], 99, "dirty page persisted")
  paged_file.close(reopened)

  // A clean frame from a closed handle must never become a path-only stale hit.
  reopenPool = buffer_pool.create(1)
  firstHandle = paged_file.open(args[0])
  cached = buffer_pool.pin(reopenPool, firstHandle, 0)
  test.equal(state, buffer_pool.data(cached)[page.HEADER_SIZE], 1, "initial clean cached marker")
  buffer_pool.release(cached)
  paged_file.close(firstHandle)

  mutator = paged_file.open(args[0])
  changed = paged_file.readPage(mutator, 0)
  changed[page.HEADER_SIZE] = 77
  page.reseal(changed)
  paged_file.writePage(mutator, 0, changed)
  paged_file.flush(mutator)
  paged_file.close(mutator)

  freshHandle = paged_file.open(args[0])
  fresh = buffer_pool.pin(reopenPool, freshHandle, 0)
  test.equal(state, buffer_pool.data(fresh)[page.HEADER_SIZE], 77, "reopened handle does not reuse stale path cache")
  reopenStats = buffer_pool.stats(reopenPool)
  test.equal(state, reopenStats.hits, 0, "reopen identity produced no false cache hit")
  test.equal(state, reopenStats.misses, 2, "reopen identity produced a second miss")
  buffer_pool.release(fresh)
  buffer_pool.close(reopenPool)
  paged_file.close(freshHandle)

  return test.finish(state, "MiniSQL M5 buffer-pool tests: SUCCESS", "MiniSQL M5 buffer-pool tests: FAIL")
end function
