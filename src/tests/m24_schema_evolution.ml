import minisql.catalog.catalog as catalog
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M24 schema evolution tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m24_schema", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE profile (id INTEGER PRIMARY KEY, name VARCHAR(40) NOT NULL, score INTEGER NOT NULL DEFAULT 0)")
  executeOne(engine, "INSERT INTO profile(id, name, score) VALUES (1, 'Ada', 10), (2, 'Bob', 20)")

  added = executeOne(engine, "ALTER TABLE profile ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE")
  testkit.equal(state, added.command, "ALTER TABLE", "ADD COLUMN command")
  oldRows = executeOne(engine, "SELECT id, active FROM profile ORDER BY id")
  testkit.equal(state, len(oldRows.rows), 2, "old row count after ADD COLUMN")
  testkit.record(state, oldRows.rows[0][1].value, "old row gets metadata default")
  testkit.record(state, oldRows.rows[1][1].value, "all old rows get metadata default")

  executeOne(engine, "INSERT INTO profile(id, name, score) VALUES (3, 'Cara', 30)")
  testkit.record(state, executeOne(engine, "SELECT active FROM profile WHERE id = 3").rows[0][0].value, "new row receives ADD COLUMN default")
  testkit.errorCode(state, try(executor.executeSql(engine, "ALTER TABLE profile ADD COLUMN required INTEGER NOT NULL")), 9021, "NOT NULL ADD COLUMN without default rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "ALTER TABLE profile ADD COLUMN changing TIMESTAMP DEFAULT CURRENT_TIMESTAMP")), 9025, "non-deterministic metadata default rejected")

  executeOne(engine, "BEGIN")
  executeOne(engine, "ALTER TABLE profile ADD COLUMN rolled_back INTEGER DEFAULT 9")
  executeOne(engine, "ROLLBACK")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT rolled_back FROM profile")), 9014, "rolled-back ADD COLUMN is absent")

  executeOne(engine, "ALTER TABLE profile RENAME COLUMN score TO points")
  renamed = executeOne(engine, "SELECT name, points FROM profile ORDER BY id")
  testkit.equal(state, renamed.rows[1][1].value, 20, "renamed column keeps data")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT score FROM profile")), 9014, "old column name rejected")

  executeOne(engine, "ALTER TABLE profile ADD CONSTRAINT uq_profile_name UNIQUE (name)")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO profile(id, name, points) VALUES (4, 'Ada', 99)")), 9022, "added UNIQUE constraint enforced")
  executeOne(engine, "ALTER TABLE profile ADD CONSTRAINT chk_profile_points CHECK (points >= 0)")
  testkit.errorCode(state, try(executor.executeSql(engine, "UPDATE profile SET points = -1 WHERE id = 1")), 9021, "added CHECK constraint enforced")

  executeOne(engine, "CREATE TABLE profile_ref (id INTEGER PRIMARY KEY, profile_name VARCHAR(40) NOT NULL)")
  executeOne(engine, "INSERT INTO profile_ref(id, profile_name) VALUES (1, 'Ada')")
  executeOne(engine, "ALTER TABLE profile_ref ADD CONSTRAINT fk_profile_name FOREIGN KEY (profile_name) REFERENCES profile(name)")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO profile_ref(id, profile_name) VALUES (2, 'Missing')")), 9021, "added FOREIGN KEY enforced")
  testkit.errorCode(state, try(executor.executeSql(engine, "ALTER TABLE profile DROP CONSTRAINT uq_profile_name")), 9021, "referenced UNIQUE constraint cannot be dropped")

  executeOne(engine, "ALTER TABLE profile_ref DROP CONSTRAINT fk_profile_name")
  executeOne(engine, "ALTER TABLE profile DROP CONSTRAINT uq_profile_name")
  duplicate = executeOne(engine, "INSERT INTO profile(id, name, points) VALUES (4, 'Ada', 99)")
  testkit.equal(state, duplicate.affectedRows, 1, "dropped UNIQUE permits duplicate")

  executeOne(engine, "ALTER TABLE profile DROP CONSTRAINT chk_profile_points")
  changed = executeOne(engine, "UPDATE profile SET points = -1 WHERE id = 1")
  testkit.equal(state, changed.affectedRows, 1, "dropped CHECK permits old-invalid value")

  executeOne(engine, "ALTER TABLE profile RENAME TO account_profile")
  testkit.record(state, catalog.findTable(managed.catalogHandle, "profile") is void, "old table name removed")
  testkit.record(state, catalog.findTable(managed.catalogHandle, "account_profile") is not void, "new table name published")
  afterRename = executeOne(engine, "SELECT id, name, points, active FROM account_profile ORDER BY id")
  testkit.equal(state, len(afterRename.rows), 4, "renamed table keeps rows")
  testkit.equal(state, afterRename.rows[0][2].value, -1, "renamed table keeps updates")
  testkit.record(state, dml.verifyAllIndexes(managed) >= 1, "remaining indexes verify after schema evolution")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT name, active FROM account_profile ORDER BY id")
  testkit.equal(state, len(durable.rows), 4, "schema evolution survives reopen")
  testkit.record(state, durable.rows[0][1].value, "metadata-added column survives reopen")
  testkit.errorCode(state, try(executor.executeSql(reopened, "SELECT id FROM profile")), 9014, "old table name remains absent after reopen")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M24 schema evolution tests: SUCCESS", "MiniSQL M24 schema evolution tests: FAIL")
end function
