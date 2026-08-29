// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Returns the first catalog row whose selected column renders to the requested text, or void when absent.
function findRow(rows, columnIndex, textValue)
  if len(rows) == 0 then return -1 end if
  for index = 0 to len(rows) - 1
    if rows[index][columnIndex].value == textValue then return index end if
  end for
  return -1
end function

// Runs the catalog introspection test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M34 catalog introspection tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m34_metadata", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE author (id INTEGER PRIMARY KEY, name VARCHAR(80) NOT NULL UNIQUE, active BOOLEAN NOT NULL DEFAULT TRUE)")
  executeOne(engine, "CREATE TABLE book (id INTEGER PRIMARY KEY, author_id INTEGER, title VARCHAR(120) NOT NULL)")
  executeOne(engine, "CREATE INDEX idx_book_author ON book(author_id)")
  publicQualified = executeOne(engine, "SELECT name FROM public.author")
  testkit.equal(state, len(publicQualified.rows), 0, "public-qualified name resolves a legacy unqualified table")
  executeOne(engine, "CREATE TABLE public.public_item (id INTEGER PRIMARY KEY)")
  publicCreated = executeOne(engine, "SELECT id FROM public.public_item")
  testkit.equal(state, len(publicCreated.rows), 0, "explicit public schema canonicalizes new objects")
  executeOne(engine, "DROP TABLE public.public_item")
  executeOne(engine, "CREATE SCHEMA shop")
  executeOne(engine, "CREATE TABLE shop.product (id INTEGER PRIMARY KEY, name VARCHAR(80) NOT NULL)")
  executeOne(engine, "INSERT INTO shop.product(id, name) VALUES (1, 'Keyboard')")
  executeOne(engine, "CREATE VIEW shop.product_names AS SELECT id, name FROM shop.product")

  tables = executeOne(engine, "SHOW TABLES")
  testkit.equal(state, tables.columns[0], "table_name", "SHOW TABLES column name")
  testkit.equal(state, len(tables.rows), 3, "SHOW TABLES row count")
  testkit.record(state, findRow(tables.rows, 0, "author") >= 0, "SHOW TABLES contains author")
  testkit.record(state, findRow(tables.rows, 0, "book") >= 0, "SHOW TABLES contains book")
  testkit.record(state, findRow(tables.rows, 0, "shop.product") >= 0, "SHOW TABLES contains qualified table")

  qualified = executeOne(engine, "SELECT product.id, product.name FROM shop.product ORDER BY product.id")
  testkit.equal(state, qualified.rows[0][1].value, "Keyboard", "qualified table uses local-name qualifier")

  schemata = executeOne(engine, "SELECT schema_name FROM information_schema.schemata ORDER BY schema_name")
  testkit.record(state, findRow(schemata.rows, 0, "public") >= 0, "SCHEMATA contains public")
  testkit.record(state, findRow(schemata.rows, 0, "information_schema") >= 0, "SCHEMATA contains information_schema")
  testkit.record(state, findRow(schemata.rows, 0, "shop") >= 0, "SCHEMATA contains created schema")

  informationTables = executeOne(engine, "SELECT table_name, table_type FROM information_schema.tables WHERE table_schema = 'shop' ORDER BY table_name")
  testkit.equal(state, len(informationTables.rows), 2, "INFORMATION_SCHEMA.TABLES includes table and view")
  testkit.equal(state, informationTables.rows[0][0].value, "product", "information table local name")
  testkit.equal(state, informationTables.rows[0][1].value, "BASE TABLE", "information table type")

  informationColumns = executeOne(engine, "SELECT column_name, ordinal_position, data_type, is_nullable FROM information_schema.columns WHERE table_schema = 'shop' AND table_name = 'product' ORDER BY ordinal_position")
  testkit.equal(state, len(informationColumns.rows), 2, "INFORMATION_SCHEMA.COLUMNS row count")
  testkit.equal(state, informationColumns.rows[1][0].value, "name", "information column name")
  testkit.equal(state, informationColumns.rows[1][3].value, "NO", "information nullability")

  informationConstraints = executeOne(engine, "SELECT constraint_type FROM information_schema.table_constraints WHERE table_schema = 'shop' AND table_name = 'product'")
  testkit.record(state, findRow(informationConstraints.rows, 0, "PRIMARY KEY") >= 0, "INFORMATION_SCHEMA constraints include primary key")
  informationViews = executeOne(engine, "SELECT table_name FROM information_schema.views WHERE table_schema = 'shop'")
  testkit.equal(state, informationViews.rows[0][0].value, "product_names", "INFORMATION_SCHEMA views expose local name")
  testkit.errorCode(state, try(executor.executeSql(engine, "DROP SCHEMA shop")), 9021, "non-empty schema cannot be dropped")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE TABLE missing_namespace.item (id INTEGER)")), 9020, "qualified DDL requires existing schema")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE INDEX missing_namespace.idx_product_name ON shop.product(name)")), 9020, "qualified index requires existing schema")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE VIEW __minisql_schema__forged AS SELECT 1 AS value")), 9020, "internal schema marker names cannot be forged as views")
  testkit.errorCode(state, try(executor.executeSql(engine, "DROP VIEW __minisql_schema__shop")), 9020, "internal schema marker cannot be dropped through view DDL")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT * FROM __minisql_schema__shop")), 9014, "internal schema marker is not query-visible")

  executeOne(engine, "CREATE TABLE shop.rename_source (id INTEGER PRIMARY KEY)")
  executeOne(engine, "ALTER TABLE shop.rename_source RENAME TO rename_target")
  renamedQualified = executeOne(engine, "SELECT id FROM shop.rename_target")
  testkit.equal(state, len(renamedQualified.rows), 0, "qualified table rename remains in its schema")
  executeOne(engine, "DROP TABLE shop.rename_target")

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

  // Operational metadata uses real result tables and includes the calling session.
  status = executeOne(engine, "SHOW STATUS")
  testkit.equal(state, status.columns[0], "variable_name", "SHOW STATUS variable column")
  testkit.record(state, findRow(status.rows, 0, "active_sessions") >= 0, "SHOW STATUS exposes active session count")
  testkit.record(state, findRow(status.rows, 0, "max_result_rows") >= 0, "SHOW STATUS exposes hard row limit")
  processes = executeOne(engine, "SHOW PROCESSLIST")
  testkit.equal(state, processes.columns[0], "session_id", "SHOW PROCESSLIST session identifier column")
  testkit.equal(state, len(processes.rows), 1, "SHOW PROCESSLIST includes attached engine")
  testkit.equal(state, processes.rows[0][2].value, "embedded", "embedded process-list peer is explicit")

  executeOne(engine, "DROP VIEW shop.product_names")
  executeOne(engine, "DROP TABLE shop.product")
  executeOne(engine, "CREATE TABLE schema_anchor (id INTEGER PRIMARY KEY)")
  executeOne(engine, "CREATE INDEX shop.idx_schema_anchor ON schema_anchor(id)")
  testkit.errorCode(state, try(executor.executeSql(engine, "DROP SCHEMA shop")), 9021, "DROP SCHEMA detects qualified index on a public table")
  executeOne(engine, "DROP INDEX shop.idx_schema_anchor")
  executeOne(engine, "CREATE TRIGGER shop.schema_anchor_trigger AFTER INSERT ON schema_anchor FOR EACH ROW UPDATE schema_anchor SET id = id WHERE id = NEW.id")
  testkit.errorCode(state, try(executor.executeSql(engine, "DROP SCHEMA shop")), 9021, "DROP SCHEMA detects qualified trigger on a public table")
  executeOne(engine, "DROP TRIGGER shop.schema_anchor_trigger")
  executeOne(engine, "DROP SCHEMA shop")
  remainingSchemas = executeOne(engine, "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'shop'")
  testkit.equal(state, len(remainingSchemas.rows), 0, "DROP SCHEMA removes durable namespace")

  shutdown = executeOne(engine, "SHUTDOWN")
  testkit.equal(state, shutdown.command, "SHUTDOWN", "SHUTDOWN returns administrative command result")
  testkit.record(state, database_manager.isShutdownRequested(managed), "SHUTDOWN publishes cooperative stop request")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M34 catalog introspection tests: SUCCESS", "MiniSQL M34 catalog introspection tests: FAIL")
end function
