// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.config.model as config_model
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.sql.binder as binder
import minisql.sql.parser as parser
import minisql.storage.btree as btree
import minisql.storage.heap_file as heap_file
import minisql.storage.paged_file as paged_file
import tests.support.testkit as testkit

// Parses SQL and returns its first statement, relying on callers to provide a non-empty statement list.
function firstStatement(sqlText)
  parsed = parser.parseSql(sqlText)
  return parsed[0]
end function

// Parses and binds exactly one SQL statement against the supplied catalog, returning the bound statement or the binder error.
function bindOne(database, sqlText)
  return binder.bindStatement(firstStatement(sqlText), database)
end function

// Finds a schema index by exact name and returns void when no matching index exists.
function findNamedIndex(tableSchemaValue, name)
  for each value in tableSchemaValue.constraints
    if value.indexName == name or value.name == name then return value end if
  end for
  return void
end function

// Runs the transactional ddl test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M14 transactional DDL tests: FAIL (missing data root)"
    return 1
  end if
  state = testkit.create()
  defaults = config_model.defaultDatabaseSettings(4096)
  database = catalog.createDatabase(args[0], "m14_ddl", defaults)
  databasePath = database.path

  // db.meta and catalog.tbl are already held under exclusive LockFileEx ranges.
  // Snapshotting through their owner handles must remain valid on Windows.
  metaImage = paged_file.snapshotDurableBytes(database.metaFile, 4194304)
  catalogImage = paged_file.snapshotDurableBytes(database.catalogFile, 4194304)
  testkit.record(state, typeof(metaImage) == "bytes" and len(metaImage) > 0, "locked db.meta owner-handle snapshot")
  testkit.record(state, typeof(catalogImage) == "bytes" and len(catalogImage) > 0, "locked catalog owner-handle snapshot")

  createSql = "CREATE TABLE category (" +
    "id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, " +
    "name VARCHAR(80) NOT NULL UNIQUE, " +
    "parent_id BIGINT, " +
    "score INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0), " +
    "CONSTRAINT fk_parent FOREIGN KEY (parent_id) REFERENCES category(id) ON DELETE RESTRICT" +
    ")"
  createBound = bindOne(database, createSql)
  ddl = schema_history.begin(database)
  schema_history.stageCreateTable(ddl, createBound)
  testkit.record(state, schema_history.commit(ddl), "CREATE TABLE committed")

  table = catalog.findTable(database, "category")
  testkit.record(state, table is not void, "table visible after commit")
  testkit.equal(state, len(table.columns), 4, "column count")
  testkit.record(state, file_api.fileExists(catalog.tableFilePath(databasePath, table.tableId)), "table file published")
  schemaState = schema_history.loadOrCreate(databasePath, database.metadata.databaseId)
  tableSchema = schema_history.findTableSchema(schemaState, table.tableId)
  testkit.record(state, tableSchema is not void, "schema history contains table")
  testkit.equal(state, len(tableSchema.columnRules), 4, "column rules persisted")
  testkit.record(state, len(tableSchema.constraints) >= 4, "PK, UNIQUE, CHECK and self-FK persisted")
  pk = schema_history.findConstraint(tableSchema, "pk_category_id")
  testkit.record(state, pk is not void, "generated primary-key constraint")
  testkit.record(state, pk.indexId > 0, "primary key owns index")
  pkPath = schema_history.indexFilePath(databasePath, pk.indexId)
  testkit.record(state, file_api.fileExists(pkPath), "primary-key index file published")
  pkTree = btree.open(pkPath)
  testkit.record(state, btree.isUnique(pkTree), "primary-key index is unique")
  btree.close(pkTree)
  fk = schema_history.findConstraint(tableSchema, "fk_parent")
  testkit.record(state, fk is not void, "self-referencing foreign key accepted")
  testkit.equal(state, fk.referenceTable, "category", "self-FK target")

  // Explicit secondary-index DDL is also transactional and produces a B+ tree.
  indexBound = bindOne(database, "CREATE INDEX idx_category_parent ON category(parent_id)")
  indexDdl = schema_history.begin(database)
  schema_history.stageCreateIndex(indexDdl, indexBound)
  schema_history.commit(indexDdl)
  schemaState = schema_history.loadOrCreate(databasePath, database.metadata.databaseId)
  tableSchema = schema_history.findTableSchema(schemaState, table.tableId)
  indexDefinition = findNamedIndex(tableSchema, "idx_category_parent")
  testkit.record(state, indexDefinition is not void, "secondary index metadata")
  indexPath = schema_history.indexFilePath(databasePath, indexDefinition.indexId)
  testkit.record(state, file_api.fileExists(indexPath), "secondary index file")
  indexTree = btree.open(indexPath)
  testkit.record(state, not btree.isUnique(indexTree), "ordinary index is non-unique")
  btree.close(indexTree)

  // Rollback must leave neither catalog metadata nor files behind.
  rolledId = database.metadata.nextObjectId
  rolledBound = bindOne(database, "CREATE TABLE rolled_back (id INTEGER PRIMARY KEY)")
  rolledDdl = schema_history.begin(database)
  schema_history.stageCreateTable(rolledDdl, rolledBound)
  schema_history.rollback(rolledDdl)
  testkit.record(state, catalog.findTable(database, "rolled_back") is void, "rolled-back table absent")
  testkit.record(state, not file_api.fileExists(catalog.tableFilePath(databasePath, rolledId)), "rolled-back table file absent")

  // Create and then transactionally drop an auxiliary table.
  auxiliaryBound = bindOne(database, "CREATE TABLE auxiliary (id INTEGER PRIMARY KEY, value VARCHAR(20))")
  auxiliaryDdl = schema_history.begin(database)
  schema_history.stageCreateTable(auxiliaryDdl, auxiliaryBound)
  schema_history.commit(auxiliaryDdl)
  auxiliary = catalog.findTable(database, "auxiliary")
  auxiliaryPath = catalog.tableFilePath(databasePath, auxiliary.tableId)
  testkit.record(state, file_api.fileExists(auxiliaryPath), "auxiliary table created")
  auxiliaryFile = paged_file.open(auxiliaryPath)
  auxiliaryPages = heap_file.heapPageNumbers(auxiliaryFile)
  paged_file.close(auxiliaryFile)
  auxiliaryDirectory = heap_file.pageDirectoryPath(auxiliaryPath)
  testkit.equal(state, len(auxiliaryPages), 0, "empty table directory contains no heap pages")
  testkit.record(state, file_api.fileExists(auxiliaryDirectory), "auxiliary page directory created")
  dropBound = bindOne(database, "DROP TABLE auxiliary")
  dropDdl = schema_history.begin(database)
  schema_history.stageDropTable(dropDdl, dropBound)
  schema_history.commit(dropDdl)
  testkit.record(state, catalog.findTable(database, "auxiliary") is void, "DROP TABLE removes catalog entry")
  testkit.record(state, not file_api.fileExists(auxiliaryPath), "DROP TABLE removes physical file")
  testkit.record(state, not file_api.fileExists(auxiliaryDirectory), "DROP TABLE removes derived page directory")

  // Simulate process death after new files were moved but before catalog
  // publication. database_manager.open must invoke journal recovery first.
  crashTableId = database.metadata.nextObjectId
  crashBound = bindOne(database, "CREATE TABLE crash_candidate (id INTEGER PRIMARY KEY)")
  crashDdl = schema_history.begin(database)
  schema_history.stageCreateTable(crashDdl, crashBound)
  testkit.equal(state, schema_history.commitStoppingAfter(crashDdl, 2), 2, "DDL crash seam reached")
  testkit.record(state, file_api.fileExists(schema_history.journalPath(databasePath)), "prepared DDL journal exists")
  testkit.record(state, file_api.fileExists(catalog.tableFilePath(databasePath, crashTableId)), "unpublished file exists before recovery")
  catalog.close(database)

  managed = database_manager.open(databasePath)
  testkit.record(state, catalog.findTable(managed.catalogHandle, "crash_candidate") is void, "prepared DDL rolled back during open")
  testkit.record(state, not file_api.fileExists(catalog.tableFilePath(databasePath, crashTableId)), "unpublished table file removed by recovery")
  testkit.record(state, not file_api.fileExists(schema_history.journalPath(databasePath)), "DDL journal cleaned after recovery")
  testkit.record(state, catalog.findTable(managed.catalogHandle, "category") is not void, "previous committed DDL survives recovery")
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M14 transactional DDL tests: SUCCESS", "MiniSQL M14 transactional DDL tests: FAIL")
end function
