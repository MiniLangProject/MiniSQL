import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function scaledDecimal(value)
  return endian.int64ToInt(value.value)
end function

function main(args)
  if len(args) != 1 then print "MiniSQL AUTO_INCREMENT and decimal INSERT tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m43_compatibility", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE numeric_input (id INTEGER AUTO_INCREMENT PRIMARY KEY, real_value REAL NOT NULL, double_value DOUBLE PRECISION NOT NULL, decimal_value DECIMAL(10,2) NOT NULL, whole_decimal DECIMAL(10,2) NOT NULL)")

  first = executeOne(engine, "INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (3.3, 4.4, 3.3, 3) RETURNING id, real_value, double_value, decimal_value, whole_decimal")
  testkit.equal(state, first.affectedRows, 1, "AUTO_INCREMENT first insert affected row")
  testkit.equal(state, first.rows[0][0].value, 1, "AUTO_INCREMENT starts at one")
  testkit.equal(state, first.rows[0][1].value, 3.3, "REAL accepts decimal literal")
  testkit.equal(state, first.rows[0][2].value, 4.4, "DOUBLE accepts decimal literal")
  testkit.equal(state, scaledDecimal(first.rows[0][3]), 330, "DECIMAL stores 3.3 at scale two")
  testkit.equal(state, scaledDecimal(first.rows[0][4]), 300, "integer DECIMAL input applies declared scale")

  second = executeOne(engine, "INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (-4.75, 1.25e2, -4.75, 1.25e2) RETURNING id, double_value, decimal_value, whole_decimal")
  testkit.equal(state, second.rows[0][0].value, 2, "AUTO_INCREMENT advances")
  testkit.equal(state, second.rows[0][1].value, 125.0, "DOUBLE accepts positive scientific notation")
  testkit.equal(state, scaledDecimal(second.rows[0][2]), -475, "negative DECIMAL literal")
  testkit.equal(state, scaledDecimal(second.rows[0][3]), 12500, "DECIMAL exponent literal")

  negativeExponent = executeOne(engine, "SELECT CAST('1.25e-2' AS DOUBLE PRECISION) AS value")
  testkit.equal(state, negativeExponent.rows[0][0].value, 0.0125, "CAST text accepts negative scientific exponent")

  executeOne(engine, "PREPARE add_numeric AS INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (?, ?, ?, ?) RETURNING id, decimal_value")
  prepared = executeOne(engine, "EXECUTE add_numeric USING 6.6, 7.7, 6.6, 8")
  testkit.equal(state, prepared.rows[0][0].value, 3, "prepared AUTO_INCREMENT advances")
  testkit.equal(state, scaledDecimal(prepared.rows[0][1]), 660, "prepared decimal parameter converts exactly")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO numeric_input(id, real_value, double_value, decimal_value, whole_decimal) VALUES (99, 1.0, 1.0, 1.0, 1.0)")), 9021, "explicit AUTO_INCREMENT value rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (1.0, 1.0, 3.333, 1.0)")), 9017, "DECIMAL excess fractional digits rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (1.0, 1.0, 123456789.01, 1.0)")), 9017, "DECIMAL precision overflow rejected")

  executeOne(engine, "CREATE TABLE compact_identity (id INTEGER AUTOINCREMENT PRIMARY KEY, value REAL)")
  compact = executeOne(engine, "INSERT INTO compact_identity(value) VALUES (3.3) RETURNING id, value")
  testkit.equal(state, compact.rows[0][0].value, 1, "AUTOINCREMENT compatibility spelling")
  testkit.equal(state, compact.rows[0][1].value, 3.3, "decimal REAL input with AUTOINCREMENT")

  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE TABLE bad_auto_type (id VARCHAR(20) AUTO_INCREMENT)")), 9017, "AUTO_INCREMENT requires integral type")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE TABLE bad_auto_count (left_id INTEGER AUTO_INCREMENT, right_id INTEGER AUTO_INCREMENT)")), 9020, "only one AUTO_INCREMENT column allowed")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE TABLE bad_auto_default (id INTEGER AUTO_INCREMENT DEFAULT 7)")), 9020, "AUTO_INCREMENT cannot have DEFAULT")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "INSERT INTO numeric_input(real_value, double_value, decimal_value, whole_decimal) VALUES (9.9, 10.1, 9.9, 10) RETURNING id, decimal_value")
  testkit.equal(state, durable.rows[0][0].value, 4, "AUTO_INCREMENT survives reopen")
  testkit.equal(state, scaledDecimal(durable.rows[0][1]), 990, "decimal literal survives storage reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL AUTO_INCREMENT and decimal INSERT tests: SUCCESS", "MiniSQL AUTO_INCREMENT and decimal INSERT tests: FAIL")
end function
