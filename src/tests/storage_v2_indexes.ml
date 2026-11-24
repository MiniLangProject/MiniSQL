// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.metadata as metadata
import minisql.client.console as console
import minisql.common.endian as endian
import minisql.common.float_codec as float_codec
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.sql.types as types
import minisql.sql.values as values
import minisql.storage.btree as btree
import minisql.storage.page as page
import minisql.storage.paged_file as paged_file
import tests.support.testkit as testkit

// Creates one integral SQL key through the production encoder.
function integerKey(value)
  return dml.encodeIndexKey([values.integer(value)])
end function

// Creates one binary64 SQL key through the production encoder.
function floatKey(value)
  return dml.encodeIndexKey([values.of(types.SqlTypeKind.Double, value)])
end function

// Wraps independent IEEE-754 goldens without invoking the floating encoder.
function binaryFloatKey(encodedHex)
  return btree.sqlKeyPrefix() + bytes([4]) + fromHex(encodedHex)
end function

// Verifies persisted bytes and rejects malformed or unsupported key formats.
function checkGoldenCodec(state)
  testkit.equal(state, hex(integerKey(1)), "4d534b02030100000000000000", "INT key uses plain I64LE")
  testkit.equal(state, hex(integerKey(-1)), "4d534b0203ffffffffffffffff", "negative INT key has unmodified two's complement")
  testkit.equal(state, hex(integerKey(255)), "4d534b0203ff00000000000000", "255 key golden")
  testkit.equal(state, hex(integerKey(256)), "4d534b02030001000000000000", "256 key golden")
  minimum = dml.encodeIndexKey([values.of(types.SqlTypeKind.BigInt, endian.minInt64())])
  maximum = dml.encodeIndexKey([values.of(types.SqlTypeKind.BigInt, endian.maxInt64())])
  testkit.equal(state, hex(minimum), "4d534b02030000000000000080", "INT64 minimum golden")
  testkit.equal(state, hex(maximum), "4d534b0203ffffffffffffff7f", "INT64 maximum golden")
  testkit.record(state, btree.compareKeys(minimum, integerKey(-1)) < 0, "full INT64 negative range ordering")
  testkit.record(state, btree.compareKeys(maximum, integerKey(256)) > 0, "full INT64 positive range ordering")
  testkit.record(state, btree.compareKeys(integerKey(255), integerKey(256)) < 0, "numeric ordering differs from LE byte ordering")
  testkit.equal(state, hex(floatKey(0.1)), "4d534b02049a9999999999b93f", "DOUBLE key binary64LE golden")
  testkit.equal(state, hex(dml.encodeIndexKey([values.of(types.SqlTypeKind.Real, 0.1)])), "4d534b02049a9999999999b93f", "REAL key also uses binary64LE")
  negativeZero = float_codec.decodeFloat64LE(fromHex("0000000000000080"), 0)
  testkit.equal(state, hex(float_codec.encodeFloat64LE(values.floatingNumberFromText("-0.0e5"))), "0000000000000080", "scientific floating parse preserves negative zero")
  testkit.equal(state, hex(floatKey(negativeZero)), "4d534b02040000000000000080", "persisted key preserves negative zero")
  testkit.equal(state, hex(dml.encodeConstraintHashKey([values.of(types.SqlTypeKind.Double, negativeZero)])), hex(dml.encodeConstraintHashKey([values.of(types.SqlTypeKind.Double, 0.0)])), "ephemeral unique hash keys equate zero signs")
  zeroPart = dml.indexValuePart(values.of(types.SqlTypeKind.Double, negativeZero))
  testkit.equal(state, hex(zeroPart), "040000000000000080", "INCLUDE binary64 preserves negative zero")
  doubleColumn = metadata.createColumn(1, "double_value", types.SqlTypeKind.Double, true, 0, 0, 0)
  restored = dml.decodeIndexPart(doubleColumn, zeroPart, 0, "test")
  testkit.equal(state, hex(float_codec.encodeFloat64LE(restored[0].value)), "0000000000000080", "INCLUDE decoding preserves binary64 bits")
  testkit.equal(state, restored[1], 9, "floating index component has fixed width")
  textKey = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "Nils")])
  testkit.equal(state, hex(textKey), "4d534b02054e696c730000", "text key version and terminator")
  binaryKey = dml.encodeIndexKey([values.of(types.SqlTypeKind.Blob, bytes([65, 0, 255]))])
  testkit.equal(state, hex(binaryKey), "4d534b02064100ffff0000", "binary zero escaping remains self delimiting")
  testkit.equal(state, hex(dml.encodeIndexKey([values.nullValue(types.SqlTypeKind.Integer)])), "4d534b0201", "NULL key component")
  testkit.equal(state, hex(dml.encodeIndexKey([values.boolean(true)])), "4d534b020201", "Boolean key component")
  testkit.errorCode(state, try(btree.entry(fromHex("4d534b01030100000000000000"), bytes([1]))), btree.UNSUPPORTED_FORMAT, "v1 typed key rejected")
  testkit.errorCode(state, try(btree.entry(fromHex("4d534b020301"), bytes([1]))), btree.CORRUPT_DATA, "truncated numeric key rejected")
  testkit.errorCode(state, try(btree.entry(fromHex("4d534b0205410001"), bytes([1]))), btree.CORRUPT_DATA, "invalid text escape rejected")
  testkit.errorCode(state, try(btree.entry(binaryFloatKey("000000000000f07f"), bytes([1]))), btree.CORRUPT_DATA, "infinity key rejected")
  testkit.errorCode(state, try(btree.entry(binaryFloatKey("010000000000f87f"), bytes([1]))), btree.CORRUPT_DATA, "NaN key rejected")
  testkit.errorCode(state, try(btree.entry(btree.sqlKeyPrefix(), bytes([1]))), btree.CORRUPT_DATA, "empty typed key rejected")
end function

// Verifies semantic ordering independently of the encoder and heap execution.
function checkComparator(state)
  // Independent IEEE-754 vectors cover both signs, subnormals and extreme
  // finite values. Comparing encoded words must never stringify a number.
  vectors = ["ffffffffffffefff", "00000000000024c0", "00000000000004c0", "0100000000000080", "0000000000000000", "0100000000000000", "000000000000e03f", "0000000000000040", "0000000000002440", "ffffffffffffef7f"]
  for left = 0 to len(vectors) - 1
    for right = 0 to len(vectors) - 1
      comparison = btree.compareKeys(binaryFloatKey(vectors[left]), binaryFloatKey(vectors[right]))
      if left < right then testkit.record(state, comparison < 0, "finite float vector increasing") end if
      if left > right then testkit.record(state, comparison > 0, "finite float vector decreasing") end if
      if left == right then testkit.equal(state, comparison, 0, "finite float vector equal") end if
    end for
  end for
  testkit.equal(state, btree.compareKeys(binaryFloatKey("0000000000000000"), binaryFloatKey("0000000000000080")), 0, "comparator equates raw signed zero keys")
  prefix = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a")])
  first = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a"), values.integer(255)])
  second = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a"), values.integer(256)])
  nextPrefix = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "b")])
  testkit.record(state, btree.compareKeys(prefix, first) < 0, "short component prefix precedes extension")
  testkit.record(state, btree.compareKeys(first, second) < 0, "composite secondary component compares numerically")
  testkit.record(state, btree.compareKeys(second, nextPrefix) < 0, "composite prefix boundary")
  escaped = dml.encodeIndexKey([values.of(types.SqlTypeKind.Blob, bytes([65, 0]))])
  unescaped = dml.encodeIndexKey([values.of(types.SqlTypeKind.Blob, bytes([65, 1]))])
  shorter = dml.encodeIndexKey([values.of(types.SqlTypeKind.Blob, bytes([65]))])
  testkit.record(state, btree.compareKeys(shorter, escaped) < 0 and btree.compareKeys(escaped, unescaped) < 0, "binary escaped byte ordering")
  testkit.record(state, btree.compareKeys(bytes([255]), integerKey(-1)) < 0, "raw and SQL domains have a stable total order")
  testkit.record(state, btree.compareKeys(bytes([255]), bytes([0, 1])) > 0, "raw keys keep lexicographic ordering")
  // A value can coincidentally begin MSK. It is still opaque, not a SQL key.
  leftEntry = btree.entry(integerKey(7), integerKey(255))
  rightEntry = btree.entry(integerKey(7), integerKey(256))
  testkit.record(state, btree.compareEntries(leftEntry, rightEntry) > 0, "leaf values keep raw byte tie ordering")
end function

// Exercises durable typed trees, ranges, unique keys, reopen and version checks.
function checkTrees(state, root)
  databaseId = fromHex("0123456789abcdeffedcba9876543210")
  path = file_api.joinPath(root, "typed-index.msi")
  tree = btree.create(path, 4096, 9101, databaseId, true)
  entries = []
  for number = 270 to 240
    entries = entries + [btree.entry(integerKey(number), bytes("row-" + number))]
  end for
  entries = entries + [btree.entry(integerKey(-256), bytes("negative")), btree.entry(integerKey(0), bytes("zero"))]
  testkit.equal(state, btree.bulkLoad(tree, entries), 33, "typed multi-leaf tree built")
  testkit.record(state, btree.height(tree) >= 2 and btree.verify(tree), "typed leaf and separator ordering verifies")
  selected = btree.range(tree, integerKey(255), true, integerKey(257), false, 0)
  testkit.equal(state, len(selected), 2, "typed half-open range across endian boundary")
  testkit.equal(state, decode(selected[0].value), "row-255", "range first value")
  testkit.equal(state, decode(selected[1].value), "row-256", "range second value")
  testkit.errorCode(state, try(btree.insert(tree, integerKey(256), bytes("duplicate"))), btree.OBJECT_EXISTS, "typed unique duplicate rejected")
  metaPage = paged_file.readPage(tree.pagedFile, tree.activeMetaPage)
  testkit.equal(state, endian.readU16LE(metaPage, 68), 2, "on-disk B+ tree metadata version is 2")
  btree.close(tree)
  reopened = btree.open(path)
  testkit.record(state, btree.verify(reopened), "typed tree verifies after reopen")
  testkit.equal(state, decode(btree.find(reopened, integerKey(256))[0]), "row-256", "typed point read after reopen")
  btree.close(reopened)

  floatPath = file_api.joinPath(root, "floating-index.msi")
  floatTree = btree.create(floatPath, 4096, 9102, databaseId, true)
  btree.bulkLoad(floatTree, [btree.entry(floatKey(10.0), bytes("ten")), btree.entry(floatKey(2.0), bytes("two")), btree.entry(floatKey(-2.5), bytes("negative")), btree.entry(floatKey(0.0), bytes("zero")), btree.entry(floatKey(0.1), bytes("fraction"))])
  selectedFloats = btree.range(floatTree, floatKey(0.1), true, floatKey(10.0), true, 0)
  testkit.equal(state, len(selectedFloats), 3, "floating numeric range length")
  testkit.equal(state, decode(selectedFloats[1].value), "two", "floating range is numeric not textual")
  testkit.errorCode(state, try(btree.insert(floatTree, binaryFloatKey("0000000000000080"), bytes("negative-zero"))), btree.OBJECT_EXISTS, "signed zero cannot bypass unique tree")
  btree.close(floatTree)
  reopenedFloat = btree.open(floatPath)
  testkit.equal(state, decode(btree.find(reopenedFloat, floatKey(2.0))[0]), "two", "floating lookup after reopen")
  btree.close(reopenedFloat)

  compositeTree = btree.create(file_api.joinPath(root, "composite-index.msi"), 4096, 9103, databaseId, false)
  prefix = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a")])
  endPrefix = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "b")])
  a255 = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a"), values.integer(255)])
  a256 = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "a"), values.integer(256)])
  b0 = dml.encodeIndexKey([values.of(types.SqlTypeKind.Text, "b"), values.integer(0)])
  btree.bulkLoad(compositeTree, [btree.entry(b0, bytes("b")), btree.entry(a256, bytes("a256")), btree.entry(a255, bytes("a255"))])
  compositeRange = btree.range(compositeTree, prefix, true, endPrefix, false, 0)
  testkit.equal(state, len(compositeRange), 2, "component-prefix range retains only matching domain")
  testkit.equal(state, decode(compositeRange[1].value), "a256", "component-prefix range preserves numeric order")
  btree.close(compositeTree)

  // Old metadata must be rejected, even with a fresh valid page checksum.
  oldTree = btree.create(file_api.joinPath(root, "old-index.msi"), 4096, 9104, databaseId, true)
  oldMeta = paged_file.readPage(oldTree.pagedFile, 0)
  endian.writeU16LE(oldMeta, 68, 1)
  page.reseal(oldMeta)
  paged_file.writePage(oldTree.pagedFile, 0, oldMeta)
  testkit.errorCode(state, try(btree.decodeMetaPage(oldTree.pagedFile, 0)), btree.UNSUPPORTED_FORMAT, "version-1 B+ tree metadata rejected")
  btree.close(oldTree)
end function

// Executes SQL and returns the first statement result without hiding failures.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Compares complete ordered results, including exact finite binary64 payloads.
function equalRows(state, left, right, label)
  testkit.equal(state, len(left.rows), len(right.rows), label + " row count")
  if len(left.rows) != len(right.rows) then return false end if
  for rowIndex = 0 to len(left.rows) - 1
    testkit.equal(state, len(left.rows[rowIndex]), len(right.rows[rowIndex]), label + " column count")
    for columnIndex = 0 to len(left.rows[rowIndex]) - 1
      leftValue = left.rows[rowIndex][columnIndex]
      rightValue = right.rows[rowIndex][columnIndex]
      testkit.equal(state, values.compareNonNull(leftValue, rightValue), 0, label + " value equality")
      if leftValue.typeKind == types.SqlTypeKind.Real or leftValue.typeKind == types.SqlTypeKind.Double then
        testkit.equal(state, hex(float_codec.encodeFloat64LE(leftValue.value)), hex(float_codec.encodeFloat64LE(rightValue.value)), label + " exact floating bits")
      end if
    end for
  end for
  return true
end function

// Searches rendered EXPLAIN rows for a trimmed operator prefix.
function planContains(result, text)
  for each row in result.rows
    if console.startsWithText(console.trimAscii(row[0].value), text) then return true end if
  end for
  return false
end function

// Compares indexed SQL execution with heap results and repeats after reopening.
function checkSql(state, root)
  managed = database_manager.create(root, "index_v2", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE samples (id INTEGER PRIMARY KEY, n BIGINT UNIQUE, f DOUBLE, r REAL, payload DOUBLE, category VARCHAR(20))")
  executeOne(engine, "INSERT INTO samples VALUES (1,-257,-10.0,0.1,0.1,'a'),(2,-256,2.0,0.2,0.2,'a'),(3,-1,10.0,0.3,0.3,'a'),(4,0,-2.5,0.4,0.4,'a'),(5,1,CAST('-0.0' AS DOUBLE),CAST('-0.0' AS REAL),CAST('-0.0' AS DOUBLE),'a'),(6,2,0.25,0.6,0.6,'a'),(7,254,2.25,0.7,0.7,'b'),(8,255,255.0,0.8,0.8,'b'),(9,256,256.0,0.9,0.9,'b'),(10,257,1000.0,1.1,1.1,'b'),(11,511,-0.5,1.2,1.2,'b'),(12,512,1.25,1.3,1.3,'b')")
  query = "SELECT f,n,payload,r FROM samples WHERE f >= -2.5 ORDER BY f,n"
  heapBaseline = executeOne(engine, query)
  zeroQuery = "SELECT f,r,payload FROM samples WHERE f = 0.0"
  zeroBaseline = executeOne(engine, zeroQuery)
  testkit.equal(state, len(zeroBaseline.rows), 1, "signed-zero heap fixture has one row")
  for columnIndex = 0 to 2
    testkit.equal(state, hex(float_codec.encodeFloat64LE(zeroBaseline.rows[0][columnIndex].value)), "0000000000000080", "heap fixture contains actual negative-zero bits")
  end for
  executeOne(engine, "CREATE INDEX ix_samples_f ON samples(f) INCLUDE(n,payload,r)")
  indexed = executeOne(engine, query)
  equalRows(state, heapBaseline, indexed, "heap vs binary64 covering index")
  equalRows(state, zeroBaseline, executeOne(engine, zeroQuery), "positive-zero seek preserves stored negative-zero key")
  testkit.record(state, planContains(executeOne(engine, "EXPLAIN SELECT f,r,payload FROM samples WHERE f = 0.0"), "Index Only Scan"), "signed-zero equality uses covering DOUBLE key")
  executeOne(engine, "CREATE INDEX ix_samples_r ON samples(r) INCLUDE(f,payload)")
  realZeroQuery = "SELECT f,r,payload FROM samples WHERE r = 0.0"
  equalRows(state, zeroBaseline, executeOne(engine, realZeroQuery), "positive-zero seek preserves stored REAL key")
  executeOne(engine, "CREATE INDEX ix_samples_category_f ON samples(category,f) INCLUDE(r,payload)")
  compositeZeroQuery = "SELECT f,r,payload FROM samples WHERE category = 'a' AND f = 0.0"
  equalRows(state, zeroBaseline, executeOne(engine, compositeZeroQuery), "composite equality preserves stored negative-zero component")
  testkit.record(state, planContains(executeOne(engine, "EXPLAIN SELECT f,n,payload,r FROM samples WHERE f >= -2.5 ORDER BY f,n"), "Index Only Scan"), "floating key/INCLUDE fields enable index-only plan")
  integral = executeOne(engine, "SELECT n FROM samples WHERE n >= 255 AND n < 511 ORDER BY n")
  testkit.equal(state, len(integral.rows), 3, "SQL signed little-endian index range")
  testkit.equal(state, endian.int64ToInt(integral.rows[0][0].value), 255, "SQL index lower endian boundary")
  testkit.equal(state, endian.int64ToInt(integral.rows[2][0].value), 257, "SQL index upper endian boundary")
  executeOne(engine, "CREATE INDEX ix_samples_composite ON samples(category,n) INCLUDE(f)")
  composite = executeOne(engine, "SELECT f FROM samples WHERE category = 'b' AND n = 256")
  testkit.equal(state, composite.rows[0][0].value, 256.0, "composite typed key decodes floating INCLUDE")
  executeOne(engine, "CREATE TABLE floating_unique (f DOUBLE UNIQUE)")
  executeOne(engine, "INSERT INTO floating_unique VALUES (0.0)")
  testkit.errorCode(state, try(executeOne(engine, "INSERT INTO floating_unique VALUES (CAST('-0.0' AS DOUBLE))")), 9022, "SQL unique index equates actual zero signs")
  executeOne(engine, "INSERT INTO floating_unique VALUES (2.0),(10.0),(-2.5),(NULL),(NULL)")
  ordered = executeOne(engine, "SELECT f FROM floating_unique WHERE f > 0.0 ORDER BY f")
  testkit.equal(state, len(ordered.rows), 2, "SQL floating range excludes NULL")
  testkit.equal(state, ordered.rows[0][0].value, 2.0, "SQL floating range numeric order")
  testkit.equal(state, ordered.rows[1][0].value, 10.0, "SQL floating range final value")
  testkit.record(state, dml.verifyAllIndexes(managed) >= 5, "all binary index representations match heaps")
  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  equalRows(state, heapBaseline, executeOne(reopened, query), "covering index after database reopen")
  equalRows(state, zeroBaseline, executeOne(reopened, zeroQuery), "signed-zero DOUBLE equality after reopen")
  equalRows(state, zeroBaseline, executeOne(reopened, realZeroQuery), "signed-zero REAL equality after reopen")
  equalRows(state, zeroBaseline, executeOne(reopened, compositeZeroQuery), "signed-zero composite equality after reopen")
  executeOne(reopened, "UPDATE samples SET f = 3.5, payload = 0.123456789012345 WHERE id = 8")
  updated = executeOne(reopened, "SELECT f,payload FROM samples WHERE f = 3.5")
  testkit.equal(state, len(updated.rows), 1, "binary float index update adds new key")
  testkit.equal(state, updated.rows[0][0].value, 3.5, "updated floating key decodes")
  testkit.equal(state, len(executeOne(reopened, "SELECT f FROM samples WHERE f = 255.0").rows), 0, "binary float index update removes old key")
  testkit.record(state, dml.verifyAllIndexes(reopened.database) >= 5, "reopened updated float indexes match heaps")
  executor.close(reopened)
end function

// Runs the regression against one caller-owned fresh data directory.
function main(args)
  if len(args) != 1 then print "MiniSQL storage v2 index tests: FAIL (missing fresh data root)"; return 1 end if
  file_api.createDirectory(args[0])
  state = testkit.create()
  checkGoldenCodec(state)
  checkComparator(state)
  checkTrees(state, args[0])
  checkSql(state, args[0])
  return testkit.finish(state, "MiniSQL storage v2 index tests: SUCCESS", "MiniSQL storage v2 index tests: FAIL")
end function
