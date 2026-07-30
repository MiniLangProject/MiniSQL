import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeMySql(engine, sqlText)[0]
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M56 MySQL DML modifier tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m56_mysql_dml_modifiers", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE `item` (`id` INT PRIMARY KEY, `note` VARCHAR(20) NOT NULL)")
  first = executeOne(engine, "INSERT LOW_PRIORITY IGNORE INTO `item` VALUE (1, 'kept')")
  testkit.equal(state, first.affectedRows, 1, "INSERT LOW_PRIORITY IGNORE VALUE inserts")
  duplicate = executeOne(engine, "INSERT HIGH_PRIORITY IGNORE INTO `item` VALUE (1, 'ignored')")
  testkit.equal(state, duplicate.affectedRows, 0, "INSERT HIGH_PRIORITY IGNORE VALUE ignores duplicate")

  executeOne(engine, "INSERT DELAYED INTO `item` VALUES (2, 'old')")
  updated = executeOne(engine, "UPDATE LOW_PRIORITY IGNORE `item` SET `note` = 'changed' WHERE `id` = 2")
  testkit.equal(state, updated.affectedRows, 1, "UPDATE modifiers are accepted")

  deleted = executeOne(engine, "DELETE QUICK IGNORE FROM `item` WHERE `id` = 2")
  testkit.equal(state, deleted.affectedRows, 1, "DELETE modifiers are accepted")
  remaining = executeOne(engine, "SELECT COUNT(*) FROM `item`")
  testkit.equal(state, remaining.rows[0][0].value.low, 1, "modifier DML leaves one row")

  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M56 MySQL DML modifier tests: SUCCESS", "MiniSQL M56 MySQL DML modifier tests: FAIL")
end function
