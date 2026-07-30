import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeMySql(engine, sqlText)[0]
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M53 MySQL DML tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m53_mysql_dml", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE `account` (`id` INT AUTO_INCREMENT PRIMARY KEY, `email` VARCHAR(80) NOT NULL UNIQUE, `score` INT NOT NULL DEFAULT 0, `note` TEXT)")

  insertedSet = executeOne(engine, "INSERT INTO `account` SET `email`='a@example.org', `score`=10 RETURNING `id`, `score`")
  testkit.equal(state, insertedSet.rows[0][0].value, 1, "INSERT SET assigns AUTO_INCREMENT")
  testkit.equal(state, insertedSet.rows[0][1].value, 10, "INSERT SET value")

  ignored = executeOne(engine, "INSERT IGNORE INTO `account` (`email`, `score`) VALUES ('a@example.org', 99)")
  testkit.equal(state, ignored.affectedRows, 0, "INSERT IGNORE ignores duplicate key")

  duplicate = executeOne(engine, "INSERT INTO `account` (`email`, `score`) VALUES ('a@example.org', 4) ON DUPLICATE KEY UPDATE `score` = `score` + VALUES(`score`), `note` = 'updated'")
  testkit.equal(state, duplicate.affectedRows, 1, "ON DUPLICATE KEY UPDATE affects existing row")

  upserted = executeOne(engine, "SELECT `score`, `note` FROM `account` WHERE `email` = 'a@example.org'")
  testkit.equal(state, upserted.rows[0][0].value, 14, "ON DUPLICATE KEY UPDATE can read old and inserted values")
  testkit.equal(state, upserted.rows[0][1].value, "updated", "ON DUPLICATE KEY UPDATE text assignment")

  executeOne(engine, "INSERT INTO `account` (`email`, `score`) VALUES ('b@example.org', 3), ('c@example.org', 7), ('d@example.org', 1)")
  limitedUpdate = executeOne(engine, "UPDATE `account` SET `score` = `score` + 100 ORDER BY `score` ASC LIMIT 2")
  testkit.equal(state, limitedUpdate.affectedRows, 2, "UPDATE ORDER BY LIMIT row count")
  ordered = executeOne(engine, "SELECT `email`, `score` FROM `account` ORDER BY `score` ASC")
  testkit.equal(state, ordered.rows[0][0].value, "c@example.org", "UPDATE LIMIT leaves third-lowest untouched first")
  testkit.equal(state, ordered.rows[0][1].value, 7, "UPDATE LIMIT untouched score")

  limitedDelete = executeOne(engine, "DELETE FROM `account` ORDER BY `score` DESC LIMIT 1")
  testkit.equal(state, limitedDelete.affectedRows, 1, "DELETE ORDER BY LIMIT row count")
  remaining = executeOne(engine, "SELECT COUNT(*) FROM `account`")
  testkit.equal(state, remaining.rows[0][0].value.low, 3, "DELETE ORDER BY LIMIT leaves three rows")

  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M53 MySQL DML tests: SUCCESS", "MiniSQL M53 MySQL DML tests: FAIL")
end function
