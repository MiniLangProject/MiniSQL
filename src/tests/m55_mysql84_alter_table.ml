import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.parser as parser
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeMySql(engine, sqlText)[0]
end function

function findRow(rows, columnIndex, textValue)
  if len(rows) == 0 then return -1 end if
  for index = 0 to len(rows) - 1
    if rows[index][columnIndex].value == textValue then return index end if
  end for
  return -1
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M55 MySQL ALTER TABLE tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m55_mysql_alter", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE `product` (`id` INT PRIMARY KEY, `sku` VARCHAR(20) NOT NULL UNIQUE)")
  executeOne(engine, "ALTER TABLE `product` ADD COLUMN `title` VARCHAR(40) AFTER `sku`")
  described = executeOne(engine, "DESCRIBE `product`")
  testkit.record(state, findRow(described.rows, 1, "title") >= 0, "ALTER TABLE ADD COLUMN AFTER adds column")

  executeOne(engine, "ALTER TABLE `product` ADD INDEX `idx_title` (`title`)")
  indexes = executeOne(engine, "SHOW INDEXES FROM `product`")
  testkit.record(state, findRow(indexes.rows, 0, "idx_title") >= 0, "ALTER TABLE ADD INDEX creates index")

  executeOne(engine, "ALTER TABLE `product` DROP INDEX `idx_title`")
  afterDrop = executeOne(engine, "SHOW INDEXES FROM `product`")
  testkit.record(state, findRow(afterDrop.rows, 0, "idx_title") < 0, "ALTER TABLE DROP INDEX removes index")

  testkit.errorCode(state, try(parser.parseMySql("ALTER TABLE product MODIFY COLUMN sku VARCHAR(80)")), parser.SQL_SYNTAX, "MODIFY COLUMN has explicit unsupported diagnostic")
  testkit.errorCode(state, try(parser.parseMySql("ALTER TABLE product DROP COLUMN sku")), parser.SQL_SYNTAX, "DROP COLUMN has explicit unsupported diagnostic")

  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M55 MySQL ALTER TABLE tests: SUCCESS", "MiniSQL M55 MySQL ALTER TABLE tests: FAIL")
end function
