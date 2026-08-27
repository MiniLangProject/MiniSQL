// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the index integration test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M23 index integration tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m23_indexes", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE inventory (id INTEGER PRIMARY KEY, sku VARCHAR(40) NOT NULL UNIQUE, category VARCHAR(20) NOT NULL, code INTEGER NOT NULL, value INTEGER NOT NULL)")
  executeOne(engine, "CREATE INDEX idx_inventory_category_code ON inventory(category, code) INCLUDE (value)")
  executeOne(engine, "INSERT INTO inventory(id, sku, category, code, value) VALUES (1, 'a-1', 'a', 1, 10), (2, 'a-2', 'a', 2, 20), (3, 'b-1', 'b', 1, 30), (4, 'b-2', 'b', 2, 40)")

  verified = dml.verifyAllIndexes(managed)
  testkit.record(state, verified >= 3, "primary, unique and explicit indexes verify")
  listed = executeOne(engine, "SHOW INDEXES FROM inventory")
  listedExplicit = -1
  if len(listed.rows) > 0 then
    for rowIndex = 0 to len(listed.rows) - 1
      if listed.rows[rowIndex][0].value == "idx_inventory_category_code" then listedExplicit = rowIndex end if
    end for
  end if
  testkit.record(state, listedExplicit >= 0, "SHOW INDEXES lists covering index")
  if listedExplicit >= 0 then testkit.equal(state, listed.rows[listedExplicit][4].value, "value", "SHOW INDEXES exposes INCLUDE columns") end if
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE INDEX idx_bad_overlap ON inventory(category) INCLUDE (category)")), 9020, "INCLUDE rejects key overlap")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE INDEX idx_bad_missing ON inventory(category) INCLUDE (missing_column)")), 9014, "INCLUDE rejects missing columns")
  executeOne(engine, "CREATE TABLE include_ddl (id INTEGER PRIMARY KEY, lookup_key INTEGER NOT NULL, payload VARCHAR(80))")
  executeOne(engine, "INSERT INTO include_ddl(id, lookup_key, payload) VALUES (1, 7, 'rename-safe')")
  executeOne(engine, "CREATE INDEX idx_include_ddl ON include_ddl(lookup_key) INCLUDE (payload)")
  executeOne(engine, "ALTER TABLE include_ddl RENAME COLUMN payload TO label")
  renamedIndexes = executeOne(engine, "SHOW INDEXES FROM include_ddl")
  renamedFound = false
  for each row in renamedIndexes.rows
    if row[0].value == "idx_include_ddl" and row[4].value == "label" then renamedFound = true end if
  end for
  testkit.record(state, renamedFound, "column rename updates INCLUDE metadata")
  renamedPayload = executeOne(engine, "SELECT label FROM include_ddl WHERE lookup_key = 7")
  testkit.equal(state, renamedPayload.rows[0][0].value, "rename-safe", "renamed INCLUDE column remains readable")
  executeOne(engine, "CREATE TABLE include_drop_guard (id INTEGER PRIMARY KEY, lookup_key INTEGER, payload INTEGER)")
  executeOne(engine, "CREATE INDEX idx_include_drop_guard ON include_drop_guard(lookup_key) INCLUDE (payload)")
  testkit.errorCode(state, try(executor.executeSql(engine, "ALTER TABLE include_drop_guard DROP COLUMN payload")), 9021, "DROP COLUMN rejects INCLUDE dependency")

  explain = executeOne(engine, "EXPLAIN SELECT sku FROM inventory WHERE id = 2")
  testkit.record(state, len(explain.rows) > 0, "EXPLAIN has rows")
  testkit.record(state, explain.rows[0][0].value == "Index Seek rows=1", "EXPLAIN reports index seek")

  point = executeOne(engine, "SELECT sku, value FROM inventory WHERE id = 3")
  testkit.equal(state, len(point.rows), 1, "point lookup row count")
  testkit.equal(state, point.rows[0][0].value, "b-1", "point lookup result")

  rangeRows = executeOne(engine, "SELECT id FROM inventory WHERE id >= 2 ORDER BY id")
  testkit.equal(state, len(rangeRows.rows), 3, "index range row count")
  testkit.equal(state, rangeRows.rows[0][0].value, 2, "index range lower bound")
  testkit.equal(state, rangeRows.rows[2][0].value, 4, "index range upper value")

  composite = executeOne(engine, "SELECT sku FROM inventory WHERE category = 'a' AND code = 2")
  testkit.equal(state, len(composite.rows), 1, "composite index row count")
  testkit.equal(state, composite.rows[0][0].value, "a-2", "composite index result")

  executeOne(engine, "UPDATE inventory SET category = 'c', code = 9, sku = 'c-9' WHERE id = 2")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM inventory WHERE category = 'a' AND code = 2").rows), 0, "old composite key removed")
  moved = executeOne(engine, "SELECT id FROM inventory WHERE category = 'c' AND code = 9")
  testkit.equal(state, moved.rows[0][0].value, 2, "new composite key inserted")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM inventory WHERE sku = 'a-2'").rows), 0, "old unique key removed")
  testkit.equal(state, executeOne(engine, "SELECT id FROM inventory WHERE sku = 'c-9'").rows[0][0].value, 2, "new unique key inserted")

  executeOne(engine, "DELETE FROM inventory WHERE id = 4")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM inventory WHERE id = 4").rows), 0, "deleted primary key removed")
  testkit.record(state, dml.verifyAllIndexes(managed) >= 3, "indexes verify after update and delete")

  dml.markIndexesDirty(managed)
  testkit.record(state, file_api.fileExists(dml.indexDirtyPath(managed)), "durable dirty marker created")
  repaired = executeOne(engine, "SELECT sku FROM inventory WHERE id = 1")
  testkit.equal(state, repaired.rows[0][0].value, "a-1", "dirty index repaired before read")
  testkit.record(state, not file_api.fileExists(dml.indexDirtyPath(managed)), "dirty marker cleared after repair")

  executeOne(engine, "CREATE TABLE category_name (category VARCHAR(20) PRIMARY KEY, title VARCHAR(40) NOT NULL)")
  executeOne(engine, "INSERT INTO category_name(category, title) VALUES ('a', 'Alpha'), ('b', 'Beta'), ('c', 'Gamma')")
  joined = executeOne(engine, "SELECT i.sku, c.title FROM inventory i INNER JOIN category_name c ON i.category = c.category ORDER BY i.id")
  testkit.equal(state, len(joined.rows), 3, "index nested-loop join row count")
  testkit.equal(state, joined.rows[1][1].value, "Gamma", "index nested-loop join value")

  dropped = executeOne(engine, "DROP INDEX idx_inventory_category_code")
  testkit.equal(state, dropped.command, "DROP INDEX", "DROP INDEX command tag")
  indexesAfterDrop = executeOne(engine, "SHOW INDEXES FROM inventory")
  explicitFound = false
  for each row in indexesAfterDrop.rows
    if row[0].value == "idx_inventory_category_code" then explicitFound = true end if
  end for
  testkit.record(state, not explicitFound, "DROP INDEX removes explicit index metadata")
  testkit.errorCode(state, try(executor.executeSql(engine, "DROP INDEX idx_inventory_category_code")), 9014, "DROP INDEX rejects a missing index")
  ignoredMissing = executeOne(engine, "DROP INDEX IF EXISTS idx_inventory_category_code")
  testkit.equal(state, ignoredMissing.affectedRows, 0, "DROP INDEX IF EXISTS is idempotent")
  testkit.equal(state, executeOne(engine, "SELECT id FROM inventory WHERE category = 'c' AND code = 9").rows[0][0].value, 2, "queries remain correct after explicit index removal")

  executeOne(engine, "CREATE UNIQUE INDEX idx_inventory_value ON inventory(value) INCLUDE (category)")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO inventory(id, sku, category, code, value) VALUES (5, 'duplicate-value', 'a', 5, 10)")), 9022, "explicit unique index enforces uniqueness")
  executeOne(engine, "DROP INDEX idx_inventory_value")
  executeOne(engine, "INSERT INTO inventory(id, sku, category, code, value) VALUES (5, 'duplicate-value', 'a', 5, 10)")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM inventory WHERE value = 10 ORDER BY id").rows), 2, "DROP INDEX removes explicit unique enforcement")

  executeOne(engine, "CREATE TABLE partial_item (id INTEGER PRIMARY KEY, code INTEGER NOT NULL, active BOOLEAN NOT NULL, payload VARCHAR(80))")
  executeOne(engine, "INSERT INTO partial_item(id, code, active, payload) VALUES (1, 7, TRUE, 'visible'), (2, 7, FALSE, 'hidden'), (3, 8, TRUE, 'other')")
  executeOne(engine, "CREATE INDEX idx_partial_active_code ON partial_item(code) INCLUDE (active, payload) WHERE active = TRUE")
  partialIndexes = executeOne(engine, "SHOW INDEXES FROM partial_item")
  partialFound = false
  for each row in partialIndexes.rows
    if row[0].value == "idx_partial_active_code" and row[5].value == "(active = TRUE)" then partialFound = true end if
  end for
  testkit.record(state, partialFound, "SHOW INDEXES exposes partial predicate")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM partial_item WHERE code = 7 AND active = TRUE").rows), 1, "partial index returns qualifying row")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM partial_item WHERE code = 7").rows), 2, "query without implication retains non-indexed row")
  executeOne(engine, "UPDATE partial_item SET active = TRUE WHERE id = 2")
  testkit.equal(state, len(executeOne(engine, "SELECT id FROM partial_item WHERE code = 7 AND active = TRUE ORDER BY id").rows), 2, "UPDATE enters partial index")
  executeOne(engine, "DELETE FROM partial_item WHERE id = 1")
  testkit.equal(state, executeOne(engine, "SELECT id FROM partial_item WHERE code = 7 AND active = TRUE").rows[0][0].value, 2, "DELETE removes partial-index entry")
  testkit.record(state, dml.verifyAllIndexes(managed) >= 5, "partial index matches filtered heap after mutations")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE INDEX idx_partial_function ON partial_item(code) WHERE LOWER(payload) = 'visible'")), 9020, "partial predicate rejects function calls")

  executeOne(engine, "CREATE TABLE partial_unique (id INTEGER PRIMARY KEY, code INTEGER NOT NULL, active BOOLEAN NOT NULL)")
  executeOne(engine, "CREATE UNIQUE INDEX ux_partial_unique_code ON partial_unique(code) WHERE active = TRUE")
  executeOne(engine, "INSERT INTO partial_unique(id, code, active) VALUES (1, 9, TRUE)")
  executeOne(engine, "INSERT INTO partial_unique(id, code, active) VALUES (2, 9, FALSE)")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO partial_unique(id, code, active) VALUES (3, 9, TRUE)")), 9022, "partial unique index rejects qualifying duplicate")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO partial_unique(id, code, active) VALUES (4, 10, TRUE) ON CONFLICT(code) DO NOTHING")), 9020, "ON CONFLICT does not infer partial unique index")

  executeOne(engine, "CREATE TABLE partial_ddl (id INTEGER PRIMARY KEY, active BOOLEAN NOT NULL, code INTEGER, unused INTEGER)")
  executeOne(engine, "CREATE INDEX idx_partial_ddl ON partial_ddl(code) WHERE active = TRUE")
  executeOne(engine, "ALTER TABLE partial_ddl RENAME COLUMN active TO enabled")
  renamedPartial = executeOne(engine, "SHOW INDEXES FROM partial_ddl")
  renamedPredicate = false
  for each row in renamedPartial.rows
    if row[0].value == "idx_partial_ddl" and row[5].value == "(enabled = TRUE)" then renamedPredicate = true end if
  end for
  testkit.record(state, renamedPredicate, "column rename updates partial predicate")
  executeOne(engine, "ALTER TABLE partial_ddl DROP COLUMN unused")
  testkit.equal(state, len(executeOne(engine, "DESCRIBE partial_ddl").rows), 3, "DROP COLUMN permits unrelated partial-index column")
  testkit.errorCode(state, try(executor.executeSql(engine, "ALTER TABLE partial_ddl DROP COLUMN enabled")), 9021, "DROP COLUMN protects partial predicate dependencies")

  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  persistent = executeOne(reopened, "SELECT id, sku FROM inventory WHERE sku = 'c-9'")
  testkit.equal(state, persistent.rows[0][0].value, 2, "index survives reopen")
  testkit.record(state, dml.verifyAllIndexes(reopened.database) >= 3, "remaining reopened indexes match heaps")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M23 index integration tests: SUCCESS", "MiniSQL M23 index integration tests: FAIL")
end function
