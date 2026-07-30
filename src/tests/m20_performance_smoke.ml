import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M20 deterministic workload tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m20_workload", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE sample (id INTEGER PRIMARY KEY, bucket INTEGER NOT NULL, value INTEGER NOT NULL)")

  started = clock.monotonicMilliseconds()
  executeOne(engine, "BEGIN")
  for id = 1 to 128
    bucket = id % 8
    value = id * 3
    executeOne(engine, "INSERT INTO sample(id, bucket, value) VALUES (" + id + ", " + bucket + ", " + value + ")")
  end for
  executeOne(engine, "COMMIT")
  executeOne(engine, "ANALYZE sample")

  grouped = executeOne(engine, "SELECT bucket, COUNT(id) AS entries, SUM(value) AS total FROM sample GROUP BY bucket ORDER BY bucket")
  testkit.equal(state, len(grouped.rows), 8, "grouped workload bucket count")
  counted = 0
  for each row in grouped.rows
    counted = counted + endian.int64ToInt(row[1].value)
  end for
  testkit.equal(state, counted, 128, "grouped workload total rows")

  for id = 1 to 64
    selected = executeOne(engine, "SELECT value FROM sample WHERE id = " + id)
    testkit.equal(state, len(selected.rows), 1, "deterministic point lookup row")
    testkit.equal(state, selected.rows[0][0].value, id * 3, "deterministic point lookup value")
  end for

  explained = executeOne(engine, "EXPLAIN ANALYZE SELECT bucket, COUNT(id) FROM sample GROUP BY bucket")
  testkit.record(state, len(explained.rows) >= 2, "workload EXPLAIN ANALYZE output")
  elapsed = clock.monotonicMilliseconds() - started
  testkit.record(state, elapsed >= 0 and elapsed < 300000, "bounded deterministic workload runtime")

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT COUNT(*) FROM sample")
  testkit.equal(state, endian.int64ToInt(durable.rows[0][0].value), 128, "workload survives reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M20 deterministic workload tests: SUCCESS", "MiniSQL M20 deterministic workload tests: FAIL")
end function
