import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function intValue(value)
  if typeof(value.value) == "int" then return value.value end if
  return endian.int64ToInt(value.value)
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M35 scalar expression tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m35_scalar", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  searched = executeOne(engine, "SELECT CASE WHEN 2 > 1 THEN 'yes' ELSE 'no' END AS answer")
  testkit.equal(state, searched.rows[0][0].value, "yes", "searched CASE")

  simple = executeOne(engine, "SELECT CASE 2 WHEN 1 THEN 'one' WHEN 2 THEN 'two' ELSE 'other' END AS answer")
  testkit.equal(state, simple.rows[0][0].value, "two", "simple CASE")

  castInteger = executeOne(engine, "SELECT CAST('42' AS INTEGER) AS value")
  testkit.equal(state, castInteger.rows[0][0].value, 42, "CAST text to integer")
  castText = executeOne(engine, "SELECT CAST(7 AS VARCHAR(8)) AS value")
  testkit.equal(state, castText.rows[0][0].value, "7", "CAST integer to text")
  castBoolean = executeOne(engine, "SELECT CAST('TRUE' AS BOOLEAN) AS value")
  testkit.record(state, castBoolean.rows[0][0].value, "CAST text to boolean")

  coalesced = executeOne(engine, "SELECT COALESCE(NULL, NULL, 'fallback') AS value")
  testkit.equal(state, coalesced.rows[0][0].value, "fallback", "COALESCE first non-NULL")
  nullified = executeOne(engine, "SELECT NULLIF(5, 5) AS value, NULLIF(5, 6) AS retained")
  testkit.record(state, nullified.rows[0][0].isNull, "NULLIF equal values returns NULL")
  testkit.equal(state, nullified.rows[0][1].value, 5, "NULLIF unequal values retains first")

  executeOne(engine, "CREATE TABLE number_item (value INTEGER)")
  emptyAggregate = executeOne(engine, "SELECT COALESCE(SUM(value), 0) AS total FROM number_item")
  testkit.equal(state, intValue(emptyAggregate.rows[0][0]), 0, "COALESCE around aggregate")
  executeOne(engine, "INSERT INTO number_item(value) VALUES (2), (3)")
  aggregateCase = executeOne(engine, "SELECT CASE WHEN COUNT(*) > 0 THEN SUM(value) ELSE 0 END AS total FROM number_item")
  testkit.equal(state, intValue(aggregateCase.rows[0][0]), 5, "CASE around aggregates")

  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT COALESCE(1, 'text')")), 9017, "COALESCE incompatible result types rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT CAST('not-a-number' AS INTEGER)")), 9020, "invalid integer CAST rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M35 scalar expression tests: SUCCESS", "MiniSQL M35 scalar expression tests: FAIL")
end function
