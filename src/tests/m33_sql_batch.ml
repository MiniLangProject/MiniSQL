import minisql.client.console as console
import tests.support.testkit as testkit

function main(args)
  state = testkit.create()

  quoted = console.scanSqlBatch("SELECT 'a;b' AS value; SELECT \"semi;column\" FROM demo;", true)
  testkit.equal(state, len(quoted.statements), 2, "semicolons inside quoted values are preserved")
  testkit.record(state, console.startsWithText(quoted.statements[0], "SELECT 'a;b'"), "first quoted statement")
  testkit.record(state, console.startsWithText(quoted.statements[1], "SELECT \"semi;column\""), "quoted identifier statement")

  comments = console.scanSqlBatch("# shell comment\n-- SQL ; comment\nSELECT 1 /* ; block */;\nSELECT 2", true)
  testkit.equal(state, len(comments.statements), 2, "comments do not terminate statements")
  testkit.record(state, console.startsWithText(comments.statements[0], "-- SQL ; comment"), "leading SQL comment retained for lexer")
  testkit.equal(state, comments.statements[1], "SELECT 2", "final statement may omit semicolon")

  partial = console.scanSqlBatch("SELECT 1;\nSELECT\n  2", false)
  testkit.equal(state, len(partial.statements), 1, "complete prefix emitted")
  testkit.equal(state, partial.remainder, "SELECT\n  2", "incomplete suffix retained")

  stringPartial = console.scanSqlBatch("SELECT 'unfinished", false)
  testkit.equal(state, len(stringPartial.statements), 0, "unfinished string not emitted")
  testkit.equal(state, stringPartial.remainder, "SELECT 'unfinished", "unfinished string retained")

  testkit.errorCode(state, try(console.scanSqlBatch("SELECT 'unfinished", true)), 9001, "final unterminated string rejected")
  testkit.errorCode(state, try(console.scanSqlBatch("SELECT 1 /* unfinished", true)), 9001, "final unterminated block comment rejected")

  split = console.splitSqlStatements("BEGIN;\nINSERT INTO t VALUES ('x;y');\nCOMMIT;")
  testkit.equal(state, len(split), 3, "transaction script split into three statements")
  testkit.record(state, console.isSqlBatch(console.scanSqlBatch("SELECT 1;", true)), "scanner returns SqlBatch")

  legacy = console.splitLines("a\r\nb\n")
  testkit.equal(state, len(legacy), 3, "M32 line splitting compatibility")
  testkit.record(state, console.isScriptComment("# comment"), "M32 hash comment compatibility")

  return testkit.finish(state, "MiniSQL M33 SQL-aware client input tests: SUCCESS", "MiniSQL M33 SQL-aware client input tests: FAIL")
end function
