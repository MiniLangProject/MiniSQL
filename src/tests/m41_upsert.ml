import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

function main(args)
  if len(args) != 1 then print "MiniSQL M41 UPSERT tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m41_upsert", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE counter_item (id INTEGER PRIMARY KEY, code VARCHAR(30) UNIQUE, amount INTEGER NOT NULL CHECK (amount >= 0))")
  executeOne(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'alpha', 10)")

  updated = executeOne(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'alpha-new', 5) ON CONFLICT (id) DO UPDATE SET code = excluded.code, amount = counter_item.amount + excluded.amount RETURNING id, code, amount")
  testkit.equal(state, updated.affectedRows, 1, "UPSERT update affected rows")
  testkit.equal(state, updated.rows[0][0].value, 1, "UPSERT update id")
  testkit.equal(state, updated.rows[0][1].value, "alpha-new", "UPSERT EXCLUDED text")
  testkit.equal(state, updated.rows[0][2].value, 15, "UPSERT target plus EXCLUDED value")

  inserted = executeOne(engine, "INSERT INTO counter_item(id, code, amount) VALUES (2, 'beta', 20) ON CONFLICT (id) DO UPDATE SET amount = excluded.amount RETURNING id, amount")
  testkit.equal(state, inserted.affectedRows, 1, "UPSERT insert affected rows")
  testkit.equal(state, inserted.rows[0][0].value, 2, "UPSERT insert path id")
  testkit.equal(state, inserted.rows[0][1].value, 20, "UPSERT insert path value")

  filtered = executeOne(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'ignored', 0) ON CONFLICT (id) DO UPDATE SET amount = excluded.amount WHERE excluded.amount > 0 RETURNING id")
  testkit.equal(state, filtered.affectedRows, 0, "UPSERT WHERE false affects no row")
  testkit.equal(state, len(filtered.rows), 0, "UPSERT WHERE false returns no row")
  testkit.equal(state, executeOne(engine, "SELECT amount FROM counter_item WHERE id = 1").rows[0][0].value, 15, "UPSERT WHERE false preserves row")

  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO counter_item(id, code, amount) VALUES (3, 'beta', 30) ON CONFLICT (id) DO UPDATE SET amount = excluded.amount")), 9022, "UPSERT does not suppress non-target unique conflict")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'alpha-new', 1) ON CONFLICT (id) DO UPDATE SET amount = -1")), 9021, "UPSERT update validates final CHECK constraints")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'x', 1) ON CONFLICT DO UPDATE SET amount = 1")), 9020, "UPSERT requires explicit conflict target")

  executeOne(engine, "PREPARE add_counter AS INSERT INTO counter_item(id, code, amount) VALUES (?, ?, ?) ON CONFLICT (id) DO UPDATE SET amount = counter_item.amount + excluded.amount RETURNING id, amount")
  prepared = executeOne(engine, "EXECUTE add_counter USING 1, 'alpha-new', 2")
  testkit.equal(state, prepared.rows[0][1].value, 17, "prepared UPSERT substitutes EXCLUDED values")

  executeOne(engine, "BEGIN")
  staged = executeOne(engine, "INSERT INTO counter_item(id, code, amount) VALUES (1, 'rolled-back', 3) ON CONFLICT (id) DO UPDATE SET code = excluded.code, amount = counter_item.amount + excluded.amount RETURNING code, amount")
  testkit.equal(state, staged.rows[0][0].value, "rolled-back", "transactional UPSERT RETURNING")
  executeOne(engine, "ROLLBACK")
  durable = executeOne(engine, "SELECT code, amount FROM counter_item WHERE id = 1")
  testkit.equal(state, durable.rows[0][0].value, "alpha-new", "UPSERT rollback restores text")
  testkit.equal(state, durable.rows[0][1].value, 17, "UPSERT rollback restores number")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M41 UPSERT tests: SUCCESS", "MiniSQL M41 UPSERT tests: FAIL")
end function
