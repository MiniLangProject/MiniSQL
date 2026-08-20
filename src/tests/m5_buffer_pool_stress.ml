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
    value[index] = (index * 19 + 5) % 256
  end for
  return value
end function

// Runs the buffer pool stress test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = test.create()
  if len(args) != 1 then
    print "MiniSQL M5 buffer-pool stress tests: FAIL (expected one path argument)"
    return 2
  end if

  pageCount = 32
  model = array(pageCount, 0)
  file = paged_file.create(args[0], 4096, superblock.FILE_TYPE_GENERIC, 777, databaseId())
  for pageNumber = 0 to pageCount - 1
    paged_file.allocatePage(file, page.TYPE_GENERIC)
  end for

  pool = buffer_pool.create(5)
  for iteration = 0 to 383
    pageNumber = (iteration * 17 + 3) % pageCount
    guard = buffer_pool.pin(pool, file, pageNumber)
    bytesValue = buffer_pool.data(guard)
    test.equal(state, bytesValue[page.HEADER_SIZE], model[pageNumber], "model before operation " + iteration)

    if iteration % 3 == 0 then
      marker = (iteration * 29 + 7) % 256
      bytesValue[page.HEADER_SIZE] = marker
      model[pageNumber] = marker
      buffer_pool.markDirty(guard)
    end if

    if iteration % 7 == 0 then
      second = buffer_pool.pin(pool, file, pageNumber)
      test.equal(state, buffer_pool.data(second)[page.HEADER_SIZE], model[pageNumber], "same-page repin " + iteration)
      buffer_pool.release(second)
    end if
    buffer_pool.release(guard)

    if iteration % 96 == 95 then
      buffer_pool.flushAll(pool)
    end if
  end for

  finalStats = buffer_pool.stats(pool)
  test.record(state, finalStats.hits > 0, "stress produced hits")
  test.record(state, finalStats.misses > pool.capacity, "stress produced misses")
  test.record(state, finalStats.evictions > 0, "stress produced evictions")
  test.record(state, finalStats.dirtyFlushes > 0, "stress flushed dirty pages")
  buffer_pool.close(pool)
  paged_file.close(file)

  reopened = paged_file.open(args[0])
  for pageNumber = 0 to pageCount - 1
    persisted = paged_file.readPage(reopened, pageNumber)
    test.equal(state, persisted[page.HEADER_SIZE], model[pageNumber], "persisted model page " + pageNumber)
  end for
  paged_file.close(reopened)

  return test.finish(state, "MiniSQL M5 buffer-pool stress tests: SUCCESS", "MiniSQL M5 buffer-pool stress tests: FAIL")
end function
