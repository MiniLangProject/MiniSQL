import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.ast as ast
import minisql.sql.lexer as lexer
import minisql.sql.parser as parser
import minisql.sql.token as token
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
  if len(args) != 1 then print "MiniSQL M52 MySQL DDL tests: FAIL args"; return 2 end if
  state = testkit.create()

  tokens = lexer.tokenizeMySql("SELECT \"mysql string\" AS label")
  testkit.record(state, token.isKind(tokens[1], token.TokenKind.StringLiteral), "mysql double quoted string token")
  testkit.equal(state, tokens[1].value, "mysql string", "mysql double quoted string value")
  minisqlTokens = lexer.tokenizeSql("SELECT \"MiniSQL Identifier\"")
  testkit.record(state, token.isKind(minisqlTokens[1], token.TokenKind.Identifier), "minisql double quote remains identifier")

  parsedDrop = parser.parseMySql("DROP INDEX `idx_status` ON `customer`")
  testkit.record(state, ast.isDropIndexStatement(parsedDrop[0]), "mysql DROP INDEX AST")
  testkit.equal(state, parsedDrop[0].name, "idx_status", "mysql DROP INDEX name")
  testkit.equal(state, parsedDrop[0].tableName, "customer", "mysql DROP INDEX table")

  managed = database_manager.create(args[0], "m52_mysql_ddl", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine,
    "CREATE TABLE `customer` (" +
    "`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, " +
    "`status` ENUM('new', 'vip') NOT NULL DEFAULT 'new', " +
    "`payload` JSON, " +
    "`created_at` DATETIME, " +
    "`fiscal_year` YEAR, " +
    "PRIMARY KEY (`id`), " +
    "KEY `idx_status` (`status`), " +
    "UNIQUE KEY `ux_created` (`created_at`)" +
    ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='mysql dump'")

  described = executeOne(engine, "DESCRIBE `customer`")
  statusRow = findRow(described.rows, 1, "status")
  payloadRow = findRow(described.rows, 1, "payload")
  createdRow = findRow(described.rows, 1, "created_at")
  yearRow = findRow(described.rows, 1, "fiscal_year")
  testkit.equal(state, described.rows[statusRow][2].value, "TEXT", "ENUM maps to TEXT")
  testkit.equal(state, described.rows[payloadRow][2].value, "TEXT", "JSON maps to TEXT")
  testkit.equal(state, described.rows[createdRow][2].value, "TIMESTAMP(0)", "DATETIME maps to TIMESTAMP")
  testkit.equal(state, described.rows[yearRow][2].value, "INTEGER", "YEAR maps to INTEGER")

  indexes = executeOne(engine, "SHOW INDEXES FROM `customer`")
  testkit.record(state, findRow(indexes.rows, 0, "idx_status") >= 0, "inline KEY creates index")
  testkit.record(state, findRow(indexes.rows, 0, "ux_created") >= 0, "inline UNIQUE KEY creates unique index")

  executeOne(engine, "DROP INDEX `idx_status` ON `customer`")
  afterDrop = executeOne(engine, "SHOW INDEXES FROM `customer`")
  testkit.record(state, findRow(afterDrop.rows, 0, "idx_status") < 0, "DROP INDEX removes index")

  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M52 MySQL DDL tests: SUCCESS", "MiniSQL M52 MySQL DDL tests: FAIL")
end function
