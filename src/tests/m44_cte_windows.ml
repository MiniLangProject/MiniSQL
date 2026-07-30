import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function int64(value)
  return endian.int64ToInt(value.value)
end function

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

  executeOne(engine, "CREATE VIEW ranked_score AS WITH selected AS (SELECT id, group_id, score FROM score_item) SELECT id, ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY score DESC, id) AS position FROM selected")
  viewResult = executeOne(engine, "SELECT id, position FROM ranked_score WHERE id = 4")
  testkit.equal(state, int64(viewResult.rows[0][1]), 2, "view over CTE and window")

  testkit.errorCode(state, try(executor.executeSql(engine, "WITH RECURSIVE x AS (SELECT 1 AS n) SELECT n FROM x")), 9019, "recursive CTE is rejected")

  // Exercise the non-trusted authorization path as database superuser. Later
  // CTEs may reference earlier CTEs without being mistaken for catalog objects.
  engine.trusted = false
  engine.principalId = 1
  authorizedCte = executeOne(engine, "WITH base AS (SELECT id FROM score_item WHERE group_id = 1), later AS (SELECT id FROM base WHERE id >= 2) SELECT id FROM later ORDER BY id")
  testkit.equal(state, len(authorizedCte.rows), 2, "authorized chained CTE row count")
  engine.trusted = true

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M44 CTE and window tests: SUCCESS", "MiniSQL M44 CTE and window tests: FAIL")
end function
