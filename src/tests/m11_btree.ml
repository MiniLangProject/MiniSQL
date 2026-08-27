// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.platform.file as file_api
import minisql.storage.btree as btree
import tests.support.testkit as testkit

// Removes a test artifact when present; absence is accepted so repeated test runs start from the same state.
function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

// Returns the deterministic database identifier used to make on-disk test fixtures reproducible.
function databaseId()
  return fromHex("0123456789abcdeffedcba9876543210")
end function

// Formats a small non-negative integer as a two-character decimal suffix for deterministic keys.
function twoDigits(value)
  if value < 10 then return "0" + value end if
  return "" + value
end function

// Builds the fixed-width sortable B-tree key for a numeric fixture value.
function key(value)
  return bytes("key-" + twoDigits(value))
end function

// Builds the deterministic B-tree payload associated with a fixture key.
function payload(value)
  return bytes("row-" + twoDigits(value))
end function

// Runs the btree test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M11 B+ tree tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  nonUniquePath = path + ".nonunique"
  bulkPath = path + ".bulk"
  cleanup(path)
  cleanup(nonUniquePath)
  cleanup(bulkPath)
  state = testkit.create()

  tree = btree.create(path, 4096, 7001, databaseId(), true)
  testkit.record(state, btree.isUnique(tree), "unique flag persisted in memory")
  testkit.equal(state, btree.count(tree), 0, "new tree empty")
  testkit.equal(state, btree.height(tree), 0, "empty tree height")

  // Insert in reverse order so every generation must restore canonical key order.
  for value = 35 to 0
    btree.insert(tree, key(value), payload(value))
  end for
  testkit.equal(state, btree.count(tree), 36, "entry count after inserts")
  testkit.record(state, btree.height(tree) >= 2, "multiple leaf pages create internal root")
  testkit.record(state, btree.verify(tree), "tree verifies after inserts")

  found = btree.find(tree, key(17))
  testkit.equal(state, len(found), 1, "unique lookup count")
  testkit.equal(state, decode(found[0]), "row-17", "unique lookup payload")
  testkit.record(state, btree.containsEntry(tree, btree.entry(key(17), payload(17))), "streaming membership finds exact unique entry")
  testkit.record(state, not btree.containsEntry(tree, btree.entry(key(17), bytes("wrong-row"))), "streaming membership rejects wrong unique value")
  testkit.record(state, not btree.containsEntry(tree, btree.entry(bytes("missing"), bytes("row"))), "streaming membership rejects missing key")
  testkit.equal(state, len(btree.find(tree, bytes("missing"))), 0, "missing key lookup")
  testkit.errorCode(state, try(btree.insert(tree, key(17), bytes("duplicate"))), btree.OBJECT_EXISTS, "duplicate unique key rejected")

  ranged = btree.range(tree, key(10), true, key(15), false, 0)
  testkit.equal(state, len(ranged), 5, "half-open range count")
  testkit.equal(state, decode(ranged[0].key), "key-10", "range first key")
  testkit.equal(state, decode(ranged[4].key), "key-14", "range last key")
  limited = btree.range(tree, key(5), true, void, true, 3)
  testkit.equal(state, len(limited), 3, "range maximum")
  testkit.equal(state, decode(limited[2].key), "key-07", "range maximum order")

  btree.remove(tree, key(17), payload(17))
  testkit.equal(state, btree.count(tree), 35, "count after remove")
  testkit.equal(state, len(btree.find(tree, key(17))), 0, "removed key absent")
  testkit.errorCode(state, try(btree.remove(tree, key(17), payload(17))), btree.OBJECT_NOT_FOUND, "missing pair remove rejected")
  btree.close(tree)

  reopened = btree.open(path)
  testkit.record(state, btree.isUnique(reopened), "unique flag survives reopen")
  testkit.equal(state, btree.count(reopened), 35, "count survives reopen")
  testkit.record(state, btree.verify(reopened), "reopened tree verifies")
  testkit.equal(state, decode(btree.find(reopened, key(35))[0]), "row-35", "last key survives reopen")
  btree.close(reopened)

  nonUnique = btree.create(nonUniquePath, 4096, 7002, databaseId(), false)
  btree.insert(nonUnique, bytes("same"), bytes("b"))
  btree.insert(nonUnique, bytes("same"), bytes("a"))
  duplicates = btree.find(nonUnique, bytes("same"))
  testkit.equal(state, len(duplicates), 2, "non-unique duplicate count")
  testkit.equal(state, decode(duplicates[0]), "a", "non-unique values sorted")
  testkit.equal(state, decode(duplicates[1]), "b", "non-unique second value")
  testkit.record(state, btree.containsEntry(nonUnique, btree.entry(bytes("same"), bytes("a"))), "streaming membership finds first duplicate")
  testkit.record(state, btree.containsEntry(nonUnique, btree.entry(bytes("same"), bytes("b"))), "streaming membership finds second duplicate")
  testkit.record(state, not btree.containsEntry(nonUnique, btree.entry(bytes("same"), bytes("c"))), "streaming membership rejects absent duplicate value")
  widePayload = bytes(512, 7)
  btree.insert(nonUnique, bytes("wide"), widePayload)
  wideFound = btree.find(nonUnique, bytes("wide"))
  testkit.equal(state, len(wideFound[0]), 512, "covering payload above legacy 64-byte limit roundtrips")
  testkit.equal(state, wideFound[0][511], 7, "covering payload final byte survives")
  testkit.errorCode(state, try(btree.entry(bytes("too-wide"), bytes(btree.MAX_VALUE_BYTES + 1, 0))), btree.INVALID_ARGUMENT, "leaf payload above page-safe limit rejected")
  testkit.record(state, btree.verify(nonUnique), "non-unique tree verifies")
  btree.close(nonUnique)

  // More than 128 leaf pages exercises bounded multi-write generation append
  // followed by one superblock publication instead of per-page durability.
  bulk = btree.create(bulkPath, 4096, 7003, databaseId(), true)
  bulkEntries = array(2048)
  for value = 0 to len(bulkEntries) - 1
    bulkEntries[value] = btree.entry(bytes("bulk-key-" + value), bytes("bulk-row-" + value))
  end for
  testkit.equal(state, btree.bulkLoad(bulk, bulkEntries), 2048, "bulk generation entry count")
  testkit.record(state, btree.verify(bulk), "multi-write bulk generation verifies")
  testkit.equal(state, len(btree.find(bulk, bytes("bulk-key-1024"))), 1, "bulk generation lookup")
  btree.close(bulk)

  cleanup(path)
  cleanup(nonUniquePath)
  cleanup(bulkPath)
  return testkit.finish(state, "MiniSQL M11 B+ tree tests: SUCCESS", "MiniSQL M11 B+ tree tests: FAIL")
end function
