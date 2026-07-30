import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeMySql(engine, sqlText)[0]
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M54 MySQL SELECT tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m54_mysql_select", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE `employee` (`id` INT PRIMARY KEY, `nickname` VARCHAR(20), `legal_name` VARCHAR(20) NOT NULL)")
  executeOne(engine, "CREATE TABLE `department` (`id` INT PRIMARY KEY, `label` VARCHAR(20) NOT NULL)")
  executeOne(engine, "INSERT INTO `employee` (`id`, `nickname`, `legal_name`) VALUES (1, NULL, 'Ada'), (2, 'Bob', 'Robert')")
  executeOne(engine, "INSERT INTO `department` (`id`, `label`) VALUES (1, 'core'), (2, 'edge')")

  joined = executeOne(engine, "SELECT IFNULL(`employee`.`nickname`, `employee`.`legal_name`) AS `display`, NOW() AS `seen` FROM `employee` JOIN `department` USING (`id`) WHERE `employee`.`id` = 1 && !(`department`.`label` = 'missing')")
  testkit.equal(state, len(joined.rows), 1, "JOIN USING with symbolic AND/NOT row count")
  testkit.equal(state, joined.rows[0][0].value, "Ada", "IFNULL returns fallback")
  testkit.equal(state, joined.rows[0][1].value.low, 0, "NOW returns timestamp literal")

  either = executeOne(engine, "SELECT COUNT(*) FROM `employee` JOIN `department` USING (`id`) WHERE `employee`.`id` = 2 || `department`.`label` = 'core'")
  testkit.equal(state, either.rows[0][0].value.low, 2, "mysql || behaves as OR")

  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M54 MySQL SELECT tests: SUCCESS", "MiniSQL M54 MySQL SELECT tests: FAIL")
end function
