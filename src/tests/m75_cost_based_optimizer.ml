// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.console as console
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.values as values
import tests.support.testkit as testkit

// Executes one SQL statement and exposes its first result to focused checks.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Searches rendered EXPLAIN rows for a trimmed operator-line prefix.
function planContains(result, prefix)
  for each row in result.rows
    if console.startsWithText(console.trimAscii(row[0].value), prefix) then return true end if
  end for
  return false
end function

// Exercises physical planning, bounded execution, caching, and regressions.
function main(args)
  if len(args) != 1 then print "MiniSQL M75 cost-based optimizer: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m75_optimizer", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE optimizer_fact (id INTEGER PRIMARY KEY, category INTEGER NOT NULL, payload TEXT)")
  insertSql = "INSERT INTO optimizer_fact(id, category, payload) VALUES "
  for index = 1 to 300
    if index > 1 then insertSql = insertSql + ", " end if
    insertSql = insertSql + "(" + index + ", " + (index % 10) + ", 'payload-value')"
  end for
  executeOne(engine, insertSql)
  executeOne(engine, "CREATE INDEX idx_optimizer_category ON optimizer_fact(category)")
  executeOne(engine, "ANALYZE optimizer_fact")

  countPlan = executeOne(engine, "EXPLAIN SELECT COUNT(*) FROM optimizer_fact")
  testkit.record(state, planContains(countPlan, "Count Slots"), "EXPLAIN exposes slot-count fast path")

  sumPlan = executeOne(engine, "EXPLAIN SELECT SUM(id) FROM optimizer_fact")
  testkit.record(state, planContains(sumPlan, "Streaming Aggregate"), "EXPLAIN exposes streaming scalar aggregate")
  summed = executeOne(engine, "SELECT SUM(id) FROM optimizer_fact")
  testkit.equal(state, values.asNumber(summed.rows[0][0]), 45150, "streaming SUM result")

  indexPlan = executeOne(engine, "EXPLAIN SELECT id FROM optimizer_fact WHERE category = 3")
  testkit.record(state, planContains(indexPlan, "Index Scan"), "cost model selects analyzed equality index")
  indexed = executeOne(engine, "SELECT id FROM optimizer_fact WHERE category = 3")
  testkit.equal(state, len(indexed.rows), 30, "planned index scan result")
  coveredPlan = executeOne(engine, "EXPLAIN SELECT category FROM optimizer_fact WHERE category = 3")
  testkit.record(state, planContains(coveredPlan, "Index Only Scan"), "covering key projection selects index-only scan")
  covered = executeOne(engine, "SELECT category FROM optimizer_fact WHERE category = 3")
  testkit.equal(state, len(covered.rows), 30, "index-only scan row count")
  testkit.equal(state, covered.rows[0][0].value, 3, "index-only scan decodes key value")
  filteredAggregatePlan = executeOne(engine, "EXPLAIN SELECT SUM(id) FROM optimizer_fact WHERE category = 3")
  testkit.record(state, planContains(filteredAggregatePlan, "Streaming Aggregate"), "filtered scalar aggregate streams")
  filteredAggregate = executeOne(engine, "SELECT SUM(id) FROM optimizer_fact WHERE category = 3")
  testkit.equal(state, values.asNumber(filteredAggregate.rows[0][0]), 4440, "filtered streaming aggregate result")
  conjunctPlan = executeOne(engine, "EXPLAIN SELECT id FROM optimizer_fact WHERE id > 100 AND category = 3")
  testkit.record(state, planContains(conjunctPlan, "Index Scan [optimizer_fact index=idx_optimizer_category"), "cost model selects the more selective conjunct index")
  conjunctIndex = executeOne(engine, "SELECT id FROM optimizer_fact WHERE id > 100 AND category = 3")
  testkit.equal(state, len(conjunctIndex.rows), 20, "index candidate scan retains residual conjunct")
  broadRangePlan = executeOne(engine, "EXPLAIN SELECT SUM(id) FROM optimizer_fact WHERE category >= 0")
  testkit.record(state, planContains(broadRangePlan, "Index Scan"), "calibrated one-reader range scan remains cost-effective")
  testkit.equal(state, broadRangePlan.rows[0][0].value, "Index Seek rows=300", "integral range bounds estimate full analyzed cardinality")
  testkit.record(state, planContains(broadRangePlan, "Streaming Aggregate"), "broad range aggregate remains streaming")
  broadRange = executeOne(engine, "SELECT SUM(id) FROM optimizer_fact WHERE category >= 0")
  testkit.equal(state, values.asNumber(broadRange.rows[0][0]), 45150, "broad range streaming result")

  executeOne(engine, "CREATE TABLE optimizer_skew (id INTEGER PRIMARY KEY, category INTEGER NOT NULL)")
  skewSql = "INSERT INTO optimizer_skew(id, category) VALUES "
  for index = 1 to 200
    if index > 1 then skewSql = skewSql + ", " end if
    category = 0
    if index > 180 then category = index - 180 end if
    skewSql = skewSql + "(" + index + ", " + category + ")"
  end for
  executeOne(engine, skewSql)
  executeOne(engine, "CREATE INDEX idx_optimizer_skew_category ON optimizer_skew(category)")
  executeOne(engine, "ANALYZE optimizer_skew")
  skewEqualityPlan = executeOne(engine, "EXPLAIN SELECT category FROM optimizer_skew WHERE category = 0")
  testkit.equal(state, skewEqualityPlan.rows[0][0].value, "Index Seek rows=180", "MCV estimates skewed equality cardinality")
  testkit.record(state, planContains(skewEqualityPlan, "Index Only Scan"), "skewed equality remains covering")
  skewRangePlan = executeOne(engine, "EXPLAIN SELECT category FROM optimizer_skew WHERE category <= 1")
  testkit.equal(state, skewRangePlan.rows[0][0].value, "Index Seek rows=181", "histogram estimates skewed range cardinality")

  executeOne(engine, "CREATE TABLE optimizer_correlated (id INTEGER PRIMARY KEY, first_key INTEGER NOT NULL, second_key INTEGER NOT NULL, payload TEXT)")
  correlatedSql = "INSERT INTO optimizer_correlated(id, first_key, second_key, payload) VALUES "
  for index = 1 to 200
    if index > 1 then correlatedSql = correlatedSql + ", " end if
    key = index % 10
    correlatedSql = correlatedSql + "(" + index + ", " + key + ", " + key + ", 'ignored')"
  end for
  executeOne(engine, correlatedSql)
  executeOne(engine, "CREATE INDEX idx_optimizer_correlated_pair ON optimizer_correlated(first_key, second_key)")
  executeOne(engine, "ANALYZE optimizer_correlated")
  correlatedPlan = executeOne(engine, "EXPLAIN SELECT first_key, second_key FROM optimizer_correlated WHERE first_key = 3 AND second_key = 3")
  testkit.equal(state, correlatedPlan.rows[0][0].value, "Index Seek rows=20", "joint NDV estimates correlated composite equality")
  testkit.record(state, planContains(correlatedPlan, "Index Only Scan"), "composite key supplies covering scan")
  correlated = executeOne(engine, "SELECT first_key, second_key FROM optimizer_correlated WHERE first_key = 3 AND second_key = 3")
  testkit.equal(state, len(correlated.rows), 20, "composite index-only scan result")
  testkit.equal(state, correlated.rows[0][0].value, 3, "composite index-only first key")
  testkit.equal(state, correlated.rows[0][1].value, 3, "composite index-only second key")

  topPlan = executeOne(engine, "EXPLAIN SELECT id FROM optimizer_fact ORDER BY id DESC LIMIT 5")
  testkit.record(state, planContains(topPlan, "Top-N"), "optimizer selects bounded Top-N")
  top = executeOne(engine, "SELECT id FROM optimizer_fact ORDER BY id DESC LIMIT 5")
  testkit.equal(state, len(top.rows), 5, "Top-N row count")
  testkit.equal(state, top.rows[0][0].value, 300, "Top-N first row")
  testkit.equal(state, top.rows[4][0].value, 296, "Top-N final row")

  emptyPlan = executeOne(engine, "EXPLAIN SELECT id FROM optimizer_fact WHERE FALSE")
  testkit.record(state, planContains(emptyPlan, "Empty Result"), "constant false eliminates source execution")
  empty = executeOne(engine, "SELECT id FROM optimizer_fact WHERE FALSE")
  testkit.equal(state, len(empty.rows), 0, "constant false result")
  shortCircuit = executeOne(engine, "SELECT id FROM optimizer_fact WHERE FALSE AND (1 / 0 = 1)")
  testkit.equal(state, len(shortCircuit.rows), 0, "constant folding preserves boolean short circuit")
  foldedTrue = executeOne(engine, "SELECT id FROM optimizer_fact WHERE 1 + 1 = 2")
  testkit.equal(state, len(foldedTrue.rows), 300, "literal predicate folds to true")

  executeOne(engine, "CREATE TABLE optimizer_small (id INTEGER PRIMARY KEY, join_key INTEGER NOT NULL)")
  executeOne(engine, "CREATE TABLE optimizer_medium (id INTEGER PRIMARY KEY, join_key INTEGER NOT NULL)")
  executeOne(engine, "CREATE TABLE optimizer_large (id INTEGER PRIMARY KEY, join_key INTEGER NOT NULL)")
  executeOne(engine, "INSERT INTO optimizer_small(id, join_key) VALUES (1, 0), (2, 1), (3, 2), (4, 3), (5, 4)")
  mediumSql = "INSERT INTO optimizer_medium(id, join_key) VALUES "
  for index = 1 to 20
    if index > 1 then mediumSql = mediumSql + ", " end if
    mediumSql = mediumSql + "(" + index + ", " + (index % 5) + ")"
  end for
  executeOne(engine, mediumSql)
  largeSql = "INSERT INTO optimizer_large(id, join_key) VALUES "
  for index = 1 to 200
    if index > 1 then largeSql = largeSql + ", " end if
    largeSql = largeSql + "(" + index + ", " + (index % 5) + ")"
  end for
  executeOne(engine, largeSql)
  executeOne(engine, "ANALYZE")
  hashPlan = executeOne(engine, "EXPLAIN SELECT s.id, l.id FROM optimizer_small s INNER JOIN optimizer_large l ON s.join_key = l.join_key")
  testkit.record(state, planContains(hashPlan, "Hash Join"), "optimizer selects hash join")
  joined = executeOne(engine, "SELECT s.id, l.id FROM optimizer_small s INNER JOIN optimizer_large l ON s.join_key = l.join_key")
  testkit.equal(state, len(joined.rows), 200, "left-build hash join preserves canonical output")
  pushed = executeOne(engine, "SELECT s.id, l.id FROM optimizer_small s INNER JOIN optimizer_large l ON s.join_key = l.join_key WHERE s.id = 1")
  testkit.equal(state, len(pushed.rows), 40, "single-source predicate pushdown preserves join result")

  reorderedPlan = executeOne(engine, "EXPLAIN SELECT l.id, m.id, s.id FROM optimizer_large l INNER JOIN optimizer_medium m ON l.join_key = m.join_key INNER JOIN optimizer_small s ON l.join_key = s.join_key")
  testkit.record(state, planContains(reorderedPlan, "Hash Join"), "reordered join graph retains costed hash operators")
  testkit.record(state, planContains(reorderedPlan, "Dynamic Join Order"), "bounded Selinger search is visible in EXPLAIN")
  reordered = executeOne(engine, "SELECT l.id, m.id, s.id FROM optimizer_large l INNER JOIN optimizer_medium m ON l.join_key = m.join_key INNER JOIN optimizer_small s ON l.join_key = s.join_key")
  testkit.equal(state, len(reordered.rows), 800, "cost-guided join reordering preserves canonical columns")
  joinCountPlan = executeOne(engine, "EXPLAIN SELECT COUNT(*) FROM optimizer_large l INNER JOIN optimizer_medium m ON l.join_key = m.join_key INNER JOIN optimizer_small s ON l.join_key = s.join_key")
  testkit.record(state, planContains(joinCountPlan, "Streaming Join Count"), "reordered COUNT avoids final join materialization")
  joinedCount = executeOne(engine, "SELECT COUNT(*) FROM optimizer_large l INNER JOIN optimizer_medium m ON l.join_key = m.join_key INNER JOIN optimizer_small s ON l.join_key = s.join_key")
  testkit.equal(state, values.asNumber(joinedCount.rows[0][0]), 800, "streaming reordered join count result")

  beforeHits = executor.planCacheHitCount(engine)
  executeOne(engine, "SELECT id FROM optimizer_fact WHERE category = 3")
  executeOne(engine, "SELECT id FROM optimizer_fact WHERE category = 3")
  executeOne(engine, "SELECT id FROM optimizer_fact WHERE category = 3")
  testkit.record(state, executor.planCacheEntryCount(engine) > 0, "physical plan cache retains entries")
  testkit.record(state, executor.planCacheHitCount(engine) >= beforeHits + 2, "repeated SELECTs reuse a physical plan")

  peer = executor.attach(managed)
  executeOne(peer, "SELECT id FROM optimizer_fact WHERE category = 3")
  executeOne(peer, "SELECT id FROM optimizer_fact WHERE category = 3")
  testkit.record(state, executor.planCacheHitCount(peer) > 0, "attached peer builds an independent cache")
  executeOne(engine, "ANALYZE optimizer_fact")
  executeOne(peer, "SELECT id FROM optimizer_fact WHERE category = 3")
  testkit.equal(state, executor.planCacheHitCount(peer), 0, "shared planning epoch invalidates peer cache")
  executor.close(peer)

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M75 cost-based optimizer: SUCCESS", "MiniSQL M75 cost-based optimizer: FAIL")
end function
