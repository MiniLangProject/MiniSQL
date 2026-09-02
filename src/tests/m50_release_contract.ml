// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.version as version
import std.string as string_api
import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.client.formatter as formatter
import minisql.common.logger as logger
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.protocol.messages as messages
import minisql.server.database_manager as database_manager
import minisql.server.session as server_session
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the release contract test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M50 release contract tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  testkit.equal(state, version.productName(), "MiniSQL", "release product name")
  testkit.equal(state, version.productVersion(), "1.1.0", "release semantic version")
  testkit.equal(state, version.milestone(), "M50", "release milestone freeze")
  testkit.equal(state, version.WIRE_PROTOCOL_VERSION, 1, "wire protocol remains v1")
  testkit.equal(state, version.DATABASE_FORMAT_VERSION, 1, "database format remains v1")

  for each pageSize in [4096, 8192, 16384, 32768]
    settings = config_model.defaultDatabaseSettings(pageSize)
    testkit.equal(state, settings.pageSize, pageSize, "release-supported page size")
  end for

  managed = database_manager.create(args[0], "m50_release", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE release_item (id INTEGER AUTO_INCREMENT PRIMARY KEY, amount DECIMAL(10,2) NOT NULL)")
  inserted = executeOne(engine, "INSERT INTO release_item(amount) VALUES (3.3) RETURNING id, amount")
  testkit.equal(state, len(inserted.rows), 1, "release smoke INSERT RETURNING")
  executor.close(engine)
  database_manager.close(managed)

  reopened = executor.open(databasePath)
  selected = executeOne(reopened, "SELECT id, amount FROM release_item")
  testkit.equal(state, len(selected.rows), 1, "release smoke database reopens")
  executor.close(reopened)

  // Cross the former one-page catalog ceiling by a wide margin, then verify
  // both table/column metadata and security generations survive a reopen.
  scalable = catalog.createDatabase(args[0], "m50_scalable", config_model.defaultDatabaseSettings(4096))
  scalablePath = scalable.path
  scalableId = bytes(scalable.metadata.databaseId)
  definitions = array(20)
  for columnIndex = 0 to 19
    definitions[columnIndex] = catalog.defineColumn("column_" + columnIndex, 10, true, 200, 0, 0)
  end for
  for tableIndex = 0 to 39
    catalog.createTable(scalable, "scale_table_" + tableIndex, definitions)
  end for
  for roleIndex = 0 to 149
    catalog.createRole(scalable, "scale_role_" + roleIndex)
  end for
  testkit.record(state, scalable.catalogFile.pageCount > 1, "catalog metadata spans multiple pages")
  newestSecuritySlot = (scalable.security.generation - 1) % 2
  testkit.record(state, scalable.securityGenerationFiles[newestSecuritySlot].pageCount > 1, "security metadata spans multiple pages")
  catalog.close(scalable)
  scalable = catalog.openDatabase(scalablePath)
  testkit.equal(state, len(scalable.catalog.tables), 40, "multi-page catalog table count survives reopen")
  testkit.equal(state, len(catalog.findTable(scalable, "scale_table_39").columns), 20, "multi-page catalog columns survive reopen")
  testkit.record(state, catalog.findPrincipal(scalable, "scale_role_149") is not void, "multi-page security generation survives reopen")
  catalog.close(scalable)

  // The schema extension sidecar previously rejected snapshots above 1 MiB.
  // A 1.1 MiB view definition now round-trips with no artificial metadata cap.
  largeSql = decode(bytes(1100000, 88))
  schemaState = schema_history.createState(scalableId)
  schemaState.views = [schema_history.viewDefinition(1, "large_view", largeSql, [])]
  schema_history.save(scalablePath, schemaState)
  loadedSchema = schema_history.loadOrCreate(scalablePath, scalableId)
  testkit.equal(state, len(bytes(loadedSchema.views[0].sqlText)), 1100000, "schema extension larger than 1 MiB round-trips")

  // Exercise the exact client formatting shape that used to allocate a new
  // cumulative string for every cell and could exhaust the 4 GiB heap.
  columns = array(64, "column")
  rows = array(512)
  for rowIndex = 0 to 511
    rows[rowIndex] = array(64, "client-value")
  end for
  formatted = formatter.formatResponse(messages.rowResponse(columns, rows))
  testkit.record(state, string_api.contains(formatted, "(512 rows)"), "large client result formats without heap exhaustion")
  formatted = void
  rows = void
  columns = void
  gc_collect()

  // Verify severity filtering, identical file records, independent SQL binlog,
  // and deterministic time-based rotation through the administrative trigger.
  logDirectory = file_api.joinPath(args[0], "m50-logs")
  file_api.createDirectory(logDirectory)
  logger.configure("debug", logDirectory, false, true, "server.log", 24, true, "sql.binlog")
  logger.debug("minisql.test.logger", "debug record")
  logger.info("minisql.test.logger", "info record")
  logger.warning("minisql.test.logger", "warning record")
  logger.errorLog("minisql.test.logger", "error record")
  // Exercise the real server-session hook rather than only the logger API:
  // every accepted UTF-8 SQL request is appended before parsing/execution.
  binlogDatabase = database_manager.open(scalablePath)
  binlogSession = server_session.openAttached(binlogDatabase)
  binlogReply = server_session.handle(binlogSession, messages.query(51, "SELECT 51 AS binlog_value"))
  testkit.equal(state, messages.decodeResponse(binlogReply.payload).errorCode, 0, "server session executes binlogged statement")
  server_session.close(binlogSession)
  database_manager.close(binlogDatabase)
  logger.binlog("minisql.test.logger", "SELECT 'Grüße'\nFROM scale_table_0")
  logger.rotateNow()
  logArchive = logger.lastLogArchivePath()
  binlogArchive = logger.lastBinlogArchivePath()
  logger.info("minisql.test.logger", "after rotation")
  logger.binlog("minisql.test.logger", "SELECT 2")
  logger.close()
  archivedLog = file_api.readAllText(logArchive, 1048576)
  archivedBinlog = file_api.readAllText(binlogArchive, 1048576)
  activeLog = file_api.readAllText(file_api.joinPath(logDirectory, "server.log"), 1048576)
  activeBinlog = file_api.readAllText(file_api.joinPath(logDirectory, "sql.binlog"), 1048576)
  testkit.record(state, string_api.contains(archivedLog, "[DEBUG]") and string_api.contains(archivedLog, "[INFO]") and string_api.contains(archivedLog, "[WARNING]") and string_api.contains(archivedLog, "[ERROR]"), "all logger severities are persisted")
  testkit.record(state, string_api.contains(archivedBinlog, "[BINLOG]") and string_api.contains(archivedBinlog, "SELECT 51 AS binlog_value") and string_api.contains(archivedBinlog, "SELECT 'Grüße'\\nFROM"), "server hook and binlog preserve complete SQL")
  testkit.record(state, string_api.contains(activeLog, "after rotation") and not string_api.contains(activeLog, "debug record"), "ordinary logfile rotation opens a fresh active file")
  testkit.record(state, string_api.contains(activeBinlog, "SELECT 2") and not string_api.contains(activeBinlog, "Grüße"), "binlog rotation opens a fresh active file")

  logger.configure("warning", logDirectory, false, true, "threshold.log", 24, false, "threshold.binlog")
  logger.debug("minisql.test.logger", "filtered debug")
  logger.info("minisql.test.logger", "filtered info")
  logger.warning("minisql.test.logger", "visible warning")
  logger.close()
  thresholdLog = file_api.readAllText(file_api.joinPath(logDirectory, "threshold.log"), 1048576)
  testkit.record(state, string_api.contains(thresholdLog, "visible warning") and not string_api.contains(thresholdLog, "filtered debug") and not string_api.contains(thresholdLog, "filtered info"), "configured logger threshold filters lower severities")

  return testkit.finish(state, "MiniSQL M50 release contract tests: SUCCESS", "MiniSQL M50 release contract tests: FAIL")
end function
