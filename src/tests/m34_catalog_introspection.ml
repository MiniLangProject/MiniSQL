import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function findRow(rows, columnIndex, textValue)
  if len(rows) == 0 then return -1 end if
  for index = 0 to len(rows) - 1
    if rows[index][columnIndex].value == textValue then return index end if
  end for
  return -1
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M34 catalog introspection tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m34_metadata", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE author (id INTEGER PRIMARY KEY, name VARCHAR(80) NOT NULL UNIQUE, active BOOLEAN NOT NULL DEFAULT TRUE)")
  executeOne(engine, "CREATE TABLE book (id INTEGER PRIMARY KEY, author_id INTEGER, title VARCHAR(120) NOT NULL)")
  executeOne(engine, "CREATE INDEX idx_book_author ON book(author_id)")

  tables = executeOne(engine, "SHOW TABLES")
  testkit.equal(state, tables.columns[0], "table_name", "SHOW TABLES column name")
  testkit.equal(state, len(tables.rows), 2, "SHOW TABLES row count")
  testkit.record(state, findRow(tables.rows, 0, "author") >= 0, "SHOW TABLES contains author")
  testkit.record(state, findRow(tables.rows, 0, "book") >= 0, "SHOW TABLES contains book")

  described = executeOne(engine, "DESCRIBE author")
  testkit.equal(state, len(described.rows), 3, "DESCRIBE column count")
  nameRow = findRow(described.rows, 1, "name")
  activeRow = findRow(described.rows, 1, "active")
  testkit.record(state, nameRow >= 0, "DESCRIBE contains name")
  testkit.equal(state, described.rows[nameRow][2].value, "VARCHAR(80)", "DESCRIBE type text")
  testkit.record(state, not described.rows[nameRow][3].value, "DESCRIBE NOT NULL")
  testkit.record(state, activeRow >= 0, "DESCRIBE contains active")
  testkit.equal(state, described.rows[activeRow][4].value, "TRUE", "DESCRIBE default SQL")

  indexes = executeOne(engine, "SHOW INDEXES FROM book")
  testkit.record(state, len(indexes.rows) >= 2, "SHOW INDEXES includes key and explicit index")
  explicitRow = findRow(indexes.rows, 0, "idx_book_author")
  testkit.record(state, explicitRow >= 0, "SHOW INDEXES contains explicit index")
  testkit.equal(state, indexes.rows[explicitRow][3].value, "author_id", "SHOW INDEXES column list")
  testkit.record(state, not indexes.rows[explicitRow][2].value, "explicit index is non-unique")

  testkit.errorCode(state, try(executor.executeSql(engine, "DESCRIBE missing_table")), 9020, "DESCRIBE unknown table rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "SHOW INDEXES FROM missing_table")), 9020, "SHOW INDEXES unknown table rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M34 catalog introspection tests: SUCCESS", "MiniSQL M34 catalog introspection tests: FAIL")
end function
