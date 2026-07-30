import minisql.sql.ast as ast
import minisql.sql.lexer as lexer
import minisql.sql.parser as parser
import minisql.sql.token as token
import tests.support.testkit as testkit

function main(args)
  state = testkit.create()

  tokens = lexer.tokenizeMySql("SELECT `Mixed Name`, 'O\\'Brien' AS owner # tail\nFROM `customer` LIMIT 2, 3;")
  testkit.record(state, token.isKeyword(tokens[0], "SELECT"), "mysql SELECT keyword")
  testkit.record(state, token.isKind(tokens[1], token.TokenKind.Identifier), "mysql backtick identifier")
  testkit.equal(state, tokens[1].text, "Mixed Name", "mysql backtick identifier text")
  testkit.record(state, tokens[1].quoted, "mysql backtick identifier quoted flag")
  testkit.equal(state, tokens[3].value, "O'Brien", "mysql escaped string literal")

  statements = parser.parseMySql("SELECT `id` FROM `customer` LIMIT 2, 3;")
  testkit.equal(state, len(statements), 1, "mysql parse statement count")
  testkit.record(state, ast.isSelectStatement(statements[0]), "mysql SELECT AST")
  testkit.equal(state, statements[0].offset, 2, "mysql LIMIT comma offset")
  testkit.equal(state, statements[0].limit, 3, "mysql LIMIT comma row count")

  testkit.errorCode(state, try(parser.parseMySql("SELECT * FROM a FULL OUTER JOIN b ON a.id = b.id")), parser.SQL_SYNTAX, "mysql dialect rejects FULL OUTER JOIN")
  testkit.errorCode(state, try(parser.parseSql("SELECT `id` FROM customer")), lexer.SQL_SYNTAX, "minisql dialect keeps backticks disabled")

  return testkit.finish(state, "MiniSQL M51 MySQL 8.4 compatibility tests: SUCCESS", "MiniSQL M51 MySQL 8.4 compatibility tests: FAIL")
end function
