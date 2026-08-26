// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.statistics as statistics
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.executor.scan as scan
import minisql.server.database_manager as database_manager
import minisql.common.endian as endian
import minisql.storage.checksum as checksum
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the statistics optimizer test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M17 statistics and optimizer tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m17_statistics", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE measurement (id INTEGER PRIMARY KEY, category VARCHAR(20), reading INTEGER)")
  executeOne(engine, "INSERT INTO measurement(id, category, reading) VALUES (1, 'a', 10), (2, 'a', 20), (3, 'b', NULL), (4, 'c', 40)")

  before = executeOne(engine, "EXPLAIN SELECT category, reading FROM measurement WHERE reading >= 20 ORDER BY category")
  testkit.equal(state, before.columns[0], "QUERY PLAN", "EXPLAIN column")
  testkit.equal(state, before.rows[0][0].value, "statistics=defaults", "EXPLAIN uses defaults before ANALYZE")
  testkit.record(state, len(before.rows) >= 4, "EXPLAIN emits physical operators")

  analyzed = executeOne(engine, "ANALYZE measurement")
  testkit.equal(state, analyzed.command, "ANALYZE", "ANALYZE command")
  testkit.equal(state, analyzed.affectedRows, 1, "ANALYZE table count")

  stats = statistics.loadOrCreate(databasePath, managed.catalogHandle.metadata.databaseId)
  testkit.record(state, statistics.isStatisticsCatalog(stats), "loadOrCreate returns StatisticsCatalog")
  testkit.equal(state, stats.generation, 1, "statistics generation persisted")
  table = catalog.findTable(managed.catalogHandle, "measurement")
  tableStats = statistics.findTable(stats, table.tableId)
  testkit.equal(state, tableStats.rowCount, 4, "row-count statistic")
  testkit.equal(state, tableStats.sampleCount, 4, "small-table statistics are exact")
  testkit.record(state, tableStats.pageCount >= 1, "page-count statistic")
  testkit.equal(state, len(tableStats.columns), 3, "column statistic count")
  testkit.equal(state, tableStats.columns[1].distinctCount, 3, "distinct category count")
  testkit.equal(state, tableStats.columns[2].nullCount, 1, "reading NULL count")
  testkit.equal(state, tableStats.columns[1].averageWidth, 1, "average text width")
  testkit.record(state, tableStats.columns[0].hasIntegralBounds, "integral id bounds recorded")
  testkit.equal(state, tableStats.columns[0].minimumIntegral, 1, "integral id minimum")
  testkit.equal(state, tableStats.columns[0].maximumIntegral, 4, "integral id maximum")
  testkit.record(state, not tableStats.columns[1].hasIntegralBounds, "text column omits compact integral bounds")
  testkit.equal(state, tableStats.columns[2].minimumIntegral, 10, "nullable integral minimum")
  testkit.equal(state, tableStats.columns[2].maximumIntegral, 40, "nullable integral maximum")

  encoded = statistics.encode(stats)
  decoded = statistics.decode(encoded)
  testkit.equal(state, decoded.generation, 1, "statistics roundtrip generation")
  v2Payload = checksum.decodeEnvelope(encoded, statistics.magic(), 3, 50).payload
  columnCount = endian.readU16LE(v2Payload, 32 + 24)
  if columnCount > 0 then
    for columnIndex = 0 to columnCount - 1
      columnOffset = 64 + columnIndex * 32
      endian.writeU16LE(v2Payload, columnOffset + 2, 0)
      endian.writeU32LE(v2Payload, columnOffset + 24, 0)
      endian.writeU32LE(v2Payload, columnOffset + 28, 0)
    end for
  end if
  v2 = checksum.encodeEnvelope(statistics.magic(), 2, 50, 0, v2Payload)
  v2Decoded = statistics.decode(v2)
  testkit.equal(state, v2Decoded.tables[0].sampleCount, v2Decoded.tables[0].rowCount, "v2 sampled statistics remain readable")
  testkit.record(state, not v2Decoded.tables[0].columns[0].hasIntegralBounds, "v2 columns migrate without invented bounds")
  legacyPayload = bytes(v2Payload)
  endian.writeU32LE(legacyPayload, 32 + 28, 0)
  legacy = checksum.encodeEnvelope(statistics.magic(), 1, 50, 0, legacyPayload)
  legacyDecoded = statistics.decode(legacy)
  testkit.equal(state, legacyDecoded.tables[0].sampleCount, legacyDecoded.tables[0].rowCount, "v1 statistics migrate as exact samples")
  sampledRows = scan.scanTable(databasePath, table, void)
  sampled = statistics.analyzeSample(table, 40, sampledRows, tableStats.pageCount)
  testkit.equal(state, sampled.rowCount, 40, "sampled ANALYZE retains exact population")
  testkit.equal(state, sampled.sampleCount, 4, "sampled ANALYZE records bounded sample size")
  damaged = bytes(encoded)
  damaged[len(damaged) - 1] = damaged[len(damaged) - 1] ^ 1
  testkit.errorCode(state, try(statistics.decode(damaged)), 9004, "statistics CRC detects corruption")
  invalidCountsPayload = checksum.decodeEnvelope(encoded, statistics.magic(), 3, 50).payload
  endian.writeU64LE(invalidCountsPayload, 64 + 4, endian.uint64FromInt(5))
  invalidCounts = checksum.encodeEnvelope(statistics.magic(), 3, 50, 0, invalidCountsPayload)
  testkit.errorCode(state, try(statistics.decode(invalidCounts)), 9004, "statistics reject column counts beyond table population")

  after = executeOne(engine, "EXPLAIN SELECT category, reading FROM measurement WHERE reading >= 20 ORDER BY category")
  testkit.equal(state, after.rows[0][0].value, "statistics=analyzed", "EXPLAIN uses persisted statistics")
  testkit.record(state, len(after.rows) >= 4, "analyzed plan emits operators")

  actual = executeOne(engine, "EXPLAIN ANALYZE SELECT category FROM measurement WHERE reading >= 20")
  last = actual.rows[len(actual.rows) - 1][0].value
  testkit.equal(state, last, "actual rows=2", "EXPLAIN ANALYZE actual row count")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  persisted = executeOne(reopened, "EXPLAIN SELECT id FROM measurement")
  testkit.equal(state, persisted.rows[0][0].value, "statistics=analyzed", "statistics survive reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M17 statistics and optimizer tests: SUCCESS", "MiniSQL M17 statistics and optimizer tests: FAIL")
end function
