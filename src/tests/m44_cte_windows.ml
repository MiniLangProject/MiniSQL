// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Extracts the host integer from the SQL 64-bit wrapper used in result assertions.
function int64(value)
  return endian.int64ToInt(value.value)
end function

// Runs the cte windows test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M44 CTE and window tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m44_cte", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE score_item (id INTEGER PRIMARY KEY, group_id INTEGER NOT NULL, score INTEGER NOT NULL)")
  executeOne(engine, "INSERT INTO score_item(id, group_id, score) VALUES (1, 1, 10), (2, 1, 20), (3, 1, 20), (4, 2, 5), (5, 2, 15)")

  cte = executeOne(engine, "WITH base AS (SELECT id, score FROM score_item WHERE group_id = 1), high AS (SELECT id, score FROM base WHERE score >= 20) SELECT id FROM high ORDER BY id")
  testkit.equal(state, len(cte.rows), 2, "chained CTE row count")
  testkit.equal(state, cte.rows[0][0].value, 2, "chained CTE first row")
  testkit.equal(state, cte.rows[1][0].value, 3, "chained CTE second row")

  windowed = executeOne(engine, "SELECT id, group_id, score, ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY score DESC, id) AS row_number, RANK() OVER (PARTITION BY group_id ORDER BY score DESC) AS rank_value, DENSE_RANK() OVER (PARTITION BY group_id ORDER BY score DESC) AS dense_value, SUM(score) OVER (PARTITION BY group_id) AS group_total, COUNT(*) OVER (PARTITION BY group_id) AS group_count FROM score_item ORDER BY id")
  testkit.equal(state, len(windowed.rows), 5, "window row count")
  testkit.equal(state, int64(windowed.rows[0][3]), 3, "ROW_NUMBER partition ordering")
  testkit.equal(state, int64(windowed.rows[1][3]), 1, "ROW_NUMBER first peer")
  testkit.equal(state, int64(windowed.rows[2][3]), 2, "ROW_NUMBER second peer")
  testkit.equal(state, int64(windowed.rows[1][4]), 1, "RANK first peer")
  testkit.equal(state, int64(windowed.rows[2][4]), 1, "RANK tied peer")
  testkit.equal(state, int64(windowed.rows[0][4]), 3, "RANK gap")
  testkit.equal(state, int64(windowed.rows[0][5]), 2, "DENSE_RANK no gap")
  testkit.equal(state, int64(windowed.rows[0][6]), 50, "window SUM first partition")
  testkit.equal(state, int64(windowed.rows[4][6]), 20, "window SUM second partition")
  testkit.equal(state, int64(windowed.rows[0][7]), 3, "window COUNT star first partition")
  testkit.equal(state, int64(windowed.rows[4][7]), 2, "window COUNT star second partition")

  advanced = executeOne(engine, "SELECT id, NTILE(2) OVER (PARTITION BY group_id ORDER BY score, id) AS tile, PERCENT_RANK() OVER (PARTITION BY group_id ORDER BY score) AS percent_rank, CUME_DIST() OVER (PARTITION BY group_id ORDER BY score) AS cumulative_distribution, LAG(score, 1, -1) OVER (PARTITION BY group_id ORDER BY score, id) AS previous_score, LEAD(score, 1, -1) OVER (PARTITION BY group_id ORDER BY score, id) AS next_score, FIRST_VALUE(score) OVER (PARTITION BY group_id ORDER BY score, id) AS first_score, LAST_VALUE(score) OVER (PARTITION BY group_id ORDER BY score, id) AS last_score, NTH_VALUE(score, 2) OVER (PARTITION BY group_id ORDER BY score, id) AS second_score FROM score_item ORDER BY id")
  testkit.equal(state, int64(advanced.rows[0][1]), 1, "NTILE assigns larger buckets first")
  testkit.equal(state, int64(advanced.rows[2][1]), 2, "NTILE advances to second bucket")
  testkit.equal(state, advanced.rows[1][2].value, 0.5, "PERCENT_RANK observes peer rank")
  testkit.equal(state, advanced.rows[1][3].value, 1.0, "CUME_DIST includes all peers")
  testkit.equal(state, advanced.rows[0][4].value, -1, "LAG uses default before partition")
  testkit.equal(state, advanced.rows[1][4].value, 10, "LAG returns previous value")
  testkit.equal(state, advanced.rows[2][5].value, -1, "LEAD uses default after partition")
  testkit.equal(state, advanced.rows[2][6].value, 10, "FIRST_VALUE reads partition start")
  testkit.equal(state, advanced.rows[0][7].value, 20, "LAST_VALUE reads partition end")
  testkit.equal(state, advanced.rows[0][8].value, 20, "NTH_VALUE uses one-based position")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT LAG(score) OVER () FROM score_item")), 9020, "navigation window requires ordering")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT NTILE(0) OVER (ORDER BY id) FROM score_item")), 9001, "NTILE rejects non-positive buckets")
  convertedNavigation = executeOne(engine, "SELECT LAG(CAST(score AS BIGINT), 1, -1) OVER (ORDER BY id) AS previous_score FROM score_item ORDER BY id")
  testkit.equal(state, int64(convertedNavigation.rows[0][0]), -1, "LAG converts its default to the declared result type")

  executeOne(engine, "CREATE VIEW ranked_score AS WITH selected AS (SELECT id, group_id, score FROM score_item) SELECT id, ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY score DESC, id) AS position FROM selected")
  viewResult = executeOne(engine, "SELECT id, position FROM ranked_score WHERE id = 4")
  testkit.equal(state, int64(viewResult.rows[0][1]), 2, "view over CTE and window")

  recursiveNumbers = executeOne(engine, "WITH RECURSIVE numbers(n) AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 5) SELECT n FROM numbers ORDER BY n")
  testkit.equal(state, len(recursiveNumbers.rows), 5, "recursive CTE reaches its fixpoint")
  testkit.equal(state, recursiveNumbers.rows[4][0].value, 5, "recursive CTE final value")

  recursiveDistinct = executeOne(engine, "WITH RECURSIVE walk(n) AS (SELECT 1 AS n UNION SELECT CASE WHEN n = 1 THEN 2 ELSE 1 END FROM walk), labels AS (SELECT n FROM walk) SELECT n FROM labels ORDER BY n")
  testkit.equal(state, len(recursiveDistinct.rows), 2, "recursive UNION removes previously visited rows")
  testkit.equal(state, recursiveDistinct.rows[1][0].value, 2, "recursive UNION retains newly discovered row")
  testkit.errorCode(state, try(executor.executeSql(engine, "WITH RECURSIVE broken(n) AS (SELECT n FROM broken) SELECT n FROM broken")), 9020, "recursive CTE requires anchor and recursive term")

  executeOne(engine, "CREATE VIEW recursive_numbers AS WITH RECURSIVE numbers(n) AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM numbers WHERE n < 3) SELECT n FROM numbers")
  recursiveView = executeOne(engine, "SELECT n FROM recursive_numbers ORDER BY n")
  testkit.equal(state, len(recursiveView.rows), 3, "recursive CTE view executes before reopen")

  // Exercise the non-trusted authorization path as database superuser. Later
  // CTEs may reference earlier CTEs without being mistaken for catalog objects.
  engine.trusted = false
  engine.principalId = 1
  authorizedCte = executeOne(engine, "WITH base AS (SELECT id FROM score_item WHERE group_id = 1), later AS (SELECT id FROM base WHERE id >= 2) SELECT id FROM later ORDER BY id")
  testkit.equal(state, len(authorizedCte.rows), 2, "authorized chained CTE row count")
  engine.trusted = true

  databasePath = managed.path
  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  durableRecursiveView = executeOne(reopened, "SELECT n FROM recursive_numbers ORDER BY n")
  testkit.equal(state, len(durableRecursiveView.rows), 3, "recursive CTE view preserves WITH RECURSIVE across reopen")
  executor.close(reopened)
  return testkit.finish(state, "MiniSQL M44 CTE and window tests: SUCCESS", "MiniSQL M44 CTE and window tests: FAIL")
end function
