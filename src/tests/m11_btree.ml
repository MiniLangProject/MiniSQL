import minisql.platform.file as file_api
import minisql.storage.btree as btree
import tests.support.testkit as testkit

function cleanup(path)
  ignored = try(file_api.deletePath(path))
  return true
end function

function databaseId()
  return fromHex("0123456789abcdeffedcba9876543210")
end function

function twoDigits(value)
  if value < 10 then return "0" + value end if
  return "" + value
end function

function key(value)
  return bytes("key-" + twoDigits(value))
end function

function payload(value)
  return bytes("row-" + twoDigits(value))
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M11 B+ tree tests: FAIL (missing path)"
    return 1
  end if
  path = args[0]
  nonUniquePath = path + ".nonunique"
  cleanup(path)
  cleanup(nonUniquePath)
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
  testkit.record(state, btree.verify(nonUnique), "non-unique tree verifies")
  btree.close(nonUnique)

  cleanup(path)
  cleanup(nonUniquePath)
  return testkit.finish(state, "MiniSQL M11 B+ tree tests: SUCCESS", "MiniSQL M11 B+ tree tests: FAIL")
end function
