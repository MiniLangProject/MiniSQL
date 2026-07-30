import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.types as types
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M15 SQL engine tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m15_engine", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  created = executeOne(engine, "CREATE TABLE account (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name VARCHAR(40) NOT NULL UNIQUE, balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0))")
  testkit.equal(state, created.command, "CREATE TABLE", "CREATE TABLE command")

  inserted = executeOne(engine, "INSERT INTO account(name, balance) VALUES ('Ada', 10), ('Bob', 20)")
  testkit.equal(state, inserted.command, "INSERT", "INSERT command")
  testkit.equal(state, inserted.affectedRows, 2, "multi-row INSERT count")

  selected = executeOne(engine, "SELECT id, name, balance FROM account ORDER BY id")
  testkit.equal(state, selected.kind, executor.RESULT_ROWS, "SELECT result kind")
  testkit.equal(state, len(selected.columns), 3, "SELECT column count")
  testkit.equal(state, len(selected.rows), 2, "SELECT row count")
  testkit.equal(state, selected.rows[0][0].value, 1, "first identity value")
  testkit.equal(state, selected.rows[0][1].value, "Ada", "first name")
  testkit.equal(state, selected.rows[1][0].value, 2, "second identity value")
  testkit.equal(state, selected.rows[1][2].value, 20, "second balance")

  projected = executeOne(engine, "SELECT name AS customer, balance + 5 AS future FROM account WHERE balance >= 10 ORDER BY future DESC LIMIT 1")
  testkit.equal(state, len(projected.rows), 1, "filter/order/limit row count")
  testkit.equal(state, projected.columns[0], "customer", "projection alias")
  testkit.equal(state, projected.rows[0][0].value, "Bob", "descending order")
  testkit.equal(state, projected.rows[0][1].value, 25, "computed projection")

  updated = executeOne(engine, "UPDATE account SET balance = balance + 7 WHERE name = 'Ada'")
  testkit.equal(state, updated.affectedRows, 1, "UPDATE count")
  ada = executeOne(engine, "SELECT balance FROM account WHERE name = 'Ada'")
  testkit.equal(state, ada.rows[0][0].value, 17, "UPDATE persisted")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO account(name, balance) VALUES ('Ada', 1)")), 9022, "UNIQUE constraint enforced")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO account(name, balance) VALUES ('Negative', -1)")), 9021, "CHECK constraint enforced")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO account(name) VALUES (NULL)")), 9021, "NOT NULL constraint enforced")

  transactionResults = executor.executeSql(engine, "BEGIN; INSERT INTO account(name, balance) VALUES ('Rolled', 30); SELECT name FROM account WHERE name = 'Rolled'; ROLLBACK")
  testkit.equal(state, len(transactionResults), 4, "explicit rollback statement count")
  testkit.equal(state, len(transactionResults[2].rows), 1, "read-your-writes before rollback")
  afterRollback = executeOne(engine, "SELECT name FROM account WHERE name = 'Rolled'")
  testkit.equal(state, len(afterRollback.rows), 0, "ROLLBACK hides staged row")

  commitResults = executor.executeSql(engine, "BEGIN ISOLATION LEVEL SERIALIZABLE READ WRITE; INSERT INTO account(name, balance) VALUES ('Committed', 40); COMMIT")
  testkit.equal(state, len(commitResults), 3, "explicit commit statement count")
  afterCommit = executeOne(engine, "SELECT id, balance FROM account WHERE name = 'Committed'")
  testkit.equal(state, len(afterCommit.rows), 1, "COMMIT publishes row")
  testkit.equal(state, afterCommit.rows[0][1].value, 40, "committed value")

  readOnlyBegin = executeOne(engine, "BEGIN READ ONLY")
  testkit.equal(state, readOnlyBegin.command, "BEGIN", "read-only BEGIN")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO account(name) VALUES ('Forbidden')")), 9012, "read-only DML rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "COMMIT")), 9011, "failed transaction cannot commit")
  rolled = executeOne(engine, "ROLLBACK")
  testkit.equal(state, rolled.command, "ROLLBACK", "failed transaction can roll back")

  distinct = executeOne(engine, "SELECT DISTINCT balance FROM account ORDER BY balance")
  testkit.equal(state, len(distinct.rows), 3, "DISTINCT result count")
  deleted = executeOne(engine, "DELETE FROM account WHERE name = 'Bob'")
  testkit.equal(state, deleted.affectedRows, 1, "DELETE count")
  remaining = executeOne(engine, "SELECT name FROM account ORDER BY name")
  testkit.equal(state, len(remaining.rows), 2, "row count after DELETE")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT name, balance FROM account ORDER BY name")
  testkit.equal(state, len(durable.rows), 2, "rows survive database reopen")
  testkit.equal(state, durable.rows[0][0].value, "Ada", "durable first row")
  testkit.equal(state, durable.rows[0][1].value, 17, "durable updated value")
  testkit.equal(state, durable.rows[1][0].value, "Committed", "durable committed row")
  testkit.equal(state, durable.rows[0][0].typeKind, types.SqlTypeKind.VarChar, "result retains SQL type")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M15 SQL engine tests: SUCCESS", "MiniSQL M15 SQL engine tests: FAIL")
end function
