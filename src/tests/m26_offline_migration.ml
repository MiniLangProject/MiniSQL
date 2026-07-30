import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.check as checker
import minisql.tools.migrate as migrate
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

function repeatText(character, count)
  output = ""
  if count > 0 then
    for index = 1 to count
      output = output + character
    end for
  end if
  return output
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M26 offline migration tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  root = args[0]
  sourceRoot = file_api.joinPath(root, "source")
  targetRoot = file_api.joinPath(root, "target")
  file_api.createDirectory(sourceRoot)
  file_api.createDirectory(targetRoot)

  managed = database_manager.create(sourceRoot, "m26_source", config_model.defaultDatabaseSettings(4096))
  sourcePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE archive_item (id INTEGER PRIMARY KEY, code VARCHAR(40) NOT NULL UNIQUE, category VARCHAR(20) NOT NULL, payload TEXT NOT NULL)")
  executeOne(engine, "CREATE INDEX idx_archive_category_id ON archive_item(category, id)")
  large = repeatText("m", 2600)
  executeOne(engine, "INSERT INTO archive_item(id, code, category, payload) VALUES (1, 'one', 'a', 'small'), (2, 'two', 'a', '" + large + "'), (3, 'three', 'b', 'third')")

  // Exercise compatible schema evolution during the logical rewrite. Rows one
  // and two have an older physical schema and must materialize the persisted
  // default; row three stores an explicit value in the new schema.
  executeOne(engine, "ALTER TABLE archive_item ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE")
  executeOne(engine, "UPDATE archive_item SET active = FALSE WHERE id = 3")

  executeOne(engine, "CREATE USER migration_reader WITH PASSWORD 'Migration-Reader-2026!'")
  executeOne(engine, "CREATE ROLE migration_role")
  executeOne(engine, "GRANT CONNECT ON DATABASE TO migration_reader")
  executeOne(engine, "GRANT SELECT ON TABLE archive_item TO migration_role")
  executeOne(engine, "GRANT migration_role TO migration_reader")
  executor.close(engine)
  database_manager.close(managed)

  sourceBefore = checker.run(sourcePath)
  testkit.equal(state, sourceBefore.pageSize, 4096, "source starts at 4096-byte pages")
  testkit.equal(state, sourceBefore.rowCount, 3, "source row count before migration")

  sameSize = migrate.run(sourcePath, 4096)
  testkit.record(state, not sameSize.changed, "legacy same-size migration remains a no-op")
  testkit.errorCode(state, try(migrate.run(sourcePath, 8192)), 9003, "legacy in-place page-size change remains fail-closed")

  report = migrate.rewrite(sourcePath, targetRoot, "m26_target", 8192)
  testkit.record(state, migrate.isRewriteMigrationReport(report), "rewrite returns migration report")
  testkit.record(state, report.verified, "rewrite target verified before publication")
  testkit.equal(state, report.sourcePageSize, 4096, "reported source page size")
  testkit.equal(state, report.targetPageSize, 8192, "reported target page size")
  testkit.equal(state, report.tableCount, 1, "reported table count")
  testkit.equal(state, report.rowCount, 3, "reported row count")
  testkit.record(state, report.indexCount >= 3, "reported rebuilt index count")
  testkit.record(state, file_api.directoryExists(report.targetPath), "verified target published")

  sourceAfter = checker.run(sourcePath)
  testkit.equal(state, sourceAfter.pageSize, 4096, "source page size remains unchanged")
  testkit.equal(state, sourceAfter.rowCount, 3, "source rows remain unchanged")
  targetCheck = checker.run(report.targetPath)
  testkit.equal(state, targetCheck.pageSize, 8192, "target uses requested page size")
  testkit.equal(state, targetCheck.rowCount, 3, "target checker row count")
  testkit.record(state, targetCheck.indexCount >= 3, "target checker validates rebuilt indexes")

  sourceEngine = executor.open(sourcePath)
  sourceRows = executeOne(sourceEngine, "SELECT code, payload, active FROM archive_item ORDER BY id")
  testkit.equal(state, len(sourceRows.rows), 3, "source still queryable")
  testkit.equal(state, len(sourceRows.rows[1][1].value), 2600, "source LOB remains intact")
  testkit.record(state, sourceRows.rows[0][2].value, "source old row materializes TRUE default")
  testkit.record(state, not sourceRows.rows[2][2].value, "source explicit FALSE remains visible")
  executor.close(sourceEngine)

  targetEngine = executor.open(report.targetPath)
  targetRows = executeOne(targetEngine, "SELECT code, category, payload, active FROM archive_item ORDER BY id")
  testkit.equal(state, len(targetRows.rows), 3, "target row count")
  testkit.equal(state, targetRows.rows[0][0].value, "one", "target first text value")
  testkit.equal(state, len(targetRows.rows[1][2].value), 2600, "target overflow value rewritten")
  testkit.record(state, targetRows.rows[0][3].value, "migrated old row retains TRUE default")
  testkit.record(state, targetRows.rows[1][3].value, "second migrated old row retains TRUE default")
  testkit.record(state, not targetRows.rows[2][3].value, "migrated explicit FALSE retained")
  testkit.record(state, dml.verifyAllIndexes(targetEngine.database) >= 3, "target indexes match rewritten heap")
  testkit.errorCode(state, try(executor.executeSql(targetEngine, "INSERT INTO archive_item(id, code, category, payload, active) VALUES (4, 'two', 'x', 'duplicate', TRUE)")), 9022, "migrated UNIQUE constraint enforced")
  executor.close(targetEngine)

  targetManaged = database_manager.open(report.targetPath)
  testkit.record(state, catalog.authenticatePassword(targetManaged.catalogHandle, "migration_reader", "Migration-Reader-2026!"), "security catalog migrated")
  migratedUser = catalog.findPrincipal(targetManaged.catalogHandle, "migration_reader")
  targetTable = catalog.findTable(targetManaged.catalogHandle, "archive_item")
  testkit.record(state, migratedUser is not void, "migrated user exists")
  testkit.record(state, targetTable is not void, "migrated table exists in target catalog")
  if migratedUser is not void and targetTable is not void then
    testkit.record(state, catalog.hasPrivilege(targetManaged.catalogHandle, migratedUser.principalId, metadata.OBJECT_TABLE, targetTable.tableId, metadata.PRIVILEGE_SELECT, false), "migrated role privilege resolves")
  end if
  database_manager.close(targetManaged)

  testkit.errorCode(state, try(migrate.rewrite(sourcePath, targetRoot, "bad_target", 5000)), 9001, "unsupported target page size rejected")
  finalSource = checker.run(sourcePath)
  testkit.equal(state, finalSource.pageSize, 4096, "failed migration attempt never mutates source")
  testkit.equal(state, finalSource.rowCount, 3, "failed migration attempt preserves source rows")

  return testkit.finish(state, "MiniSQL M26 offline migration tests: SUCCESS", "MiniSQL M26 offline migration tests: FAIL")
end function
