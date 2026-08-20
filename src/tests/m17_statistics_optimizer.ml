// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.statistics as statistics
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
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
  testkit.record(state, tableStats.pageCount >= 1, "page-count statistic")
  testkit.equal(state, len(tableStats.columns), 3, "column statistic count")
  testkit.equal(state, tableStats.columns[1].distinctCount, 3, "distinct category count")
  testkit.equal(state, tableStats.columns[2].nullCount, 1, "reading NULL count")
  testkit.equal(state, tableStats.columns[1].averageWidth, 1, "average text width")

  encoded = statistics.encode(stats)
  decoded = statistics.decode(encoded)
  testkit.equal(state, decoded.generation, 1, "statistics roundtrip generation")
  damaged = bytes(encoded)
  damaged[len(damaged) - 1] = damaged[len(damaged) - 1] ^ 1
  testkit.errorCode(state, try(statistics.decode(damaged)), 9004, "statistics CRC detects corruption")

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
