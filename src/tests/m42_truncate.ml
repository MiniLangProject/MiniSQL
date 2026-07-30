import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M42 TRUNCATE tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m42_truncate", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE identity_item (id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, label VARCHAR(30) NOT NULL)")
  executeOne(engine, "INSERT INTO identity_item(label) VALUES ('one'), ('two'), ('three')")

  executeOne(engine, "BEGIN")
  staged = executeOne(engine, "TRUNCATE TABLE identity_item")
  testkit.equal(state, staged.command, "TRUNCATE", "transactional TRUNCATE command")
  testkit.equal(state, staged.affectedRows, 3, "transactional TRUNCATE affected rows")
  testkit.equal(state, endian.int64ToInt(executeOne(engine, "SELECT COUNT(*) AS c FROM identity_item").rows[0][0].value), 0, "TRUNCATE visible inside transaction")
  executeOne(engine, "ROLLBACK")
  testkit.equal(state, endian.int64ToInt(executeOne(engine, "SELECT COUNT(*) AS c FROM identity_item").rows[0][0].value), 3, "TRUNCATE rollback restores rows")

  committed = executeOne(engine, "TRUNCATE identity_item RESTART IDENTITY")
  testkit.equal(state, committed.affectedRows, 3, "autocommit TRUNCATE affected rows")
  testkit.equal(state, endian.int64ToInt(executeOne(engine, "SELECT COUNT(*) AS c FROM identity_item").rows[0][0].value), 0, "autocommit TRUNCATE empties table")
  restarted = executeOne(engine, "INSERT INTO identity_item(label) VALUES ('after') RETURNING id")
  testkit.equal(state, restarted.rows[0][0].value, 1, "TRUNCATE restarts derived identity")

  testkit.errorCode(state, try(executor.executeSql(engine, "TRUNCATE identity_item CONTINUE IDENTITY")), 9025, "CONTINUE IDENTITY rejected before persistent sequences")

  executeOne(engine, "CREATE TABLE parent_item (id INTEGER PRIMARY KEY)")
  executeOne(engine, "CREATE TABLE child_item (id INTEGER PRIMARY KEY, parent_id INTEGER NOT NULL, FOREIGN KEY (parent_id) REFERENCES parent_item(id))")
  executeOne(engine, "INSERT INTO parent_item(id) VALUES (1)")
  executeOne(engine, "INSERT INTO child_item(id, parent_id) VALUES (1, 1)")
  testkit.errorCode(state, try(executor.executeSql(engine, "TRUNCATE parent_item")), 9021, "TRUNCATE protects referenced rows")
  childTruncate = executeOne(engine, "TRUNCATE TABLE child_item")
  testkit.equal(state, childTruncate.affectedRows, 1, "dependent table can be truncated")
  parentTruncate = executeOne(engine, "TRUNCATE TABLE parent_item")
  testkit.equal(state, parentTruncate.affectedRows, 1, "parent can truncate after dependents removed")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT id, label FROM identity_item")
  testkit.equal(state, len(durable.rows), 1, "TRUNCATE survives reopen")
  testkit.equal(state, durable.rows[0][0].value, 1, "restarted identity survives reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M42 TRUNCATE tests: SUCCESS", "MiniSQL M42 TRUNCATE tests: FAIL")
end function
