import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.catalog.statistics as statistics
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.storage.paged_file as paged_file
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

function tablePages(databasePath, table)
  file = paged_file.open(catalog.tableFilePath(databasePath, table.tableId))
  count = file.pageCount
  paged_file.close(file)
  return count
end function

function writeText(path, text)
  handle = file_api.createDurable(path)
  encoded = bytes(text)
  file_api.writeAt(handle, 0, encoded, 0, len(encoded))
  file_api.truncate(handle, len(encoded))
  file_api.flush(handle)
  file_api.close(handle)
  return true
end function

function readText(path)
  handle = file_api.openRead(path)
  length = file_api.size(handle)
  encoded = bytes(length, 0)
  if length > 0 then file_api.readExactAt(handle, 0, encoded, 0, length) end if
  file_api.close(handle)
  return decode(encoded)
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M25 maintenance tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m25_maintenance", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE document (id INTEGER PRIMARY KEY, code VARCHAR(40) NOT NULL UNIQUE, body TEXT NOT NULL)")
  executeOne(engine, "CREATE INDEX idx_document_code_id ON document(code, id)")
  longText = repeatText("x", 2600)
  valuesSql = ""
  for id = 1 to 24
    if id > 1 then valuesSql = valuesSql + ", " end if
    valuesSql = valuesSql + "(" + id + ", 'doc-" + id + "', '" + longText + "')"
  end for
  inserted = executeOne(engine, "INSERT INTO document(id, code, body) VALUES " + valuesSql)
  testkit.equal(state, inserted.affectedRows, 24, "large multi-row insert")
  executeOne(engine, "ANALYZE document")

  table = catalog.findTable(managed.catalogHandle, "document")
  initialPages = tablePages(databasePath, table)
  testkit.record(state, initialPages > 12, "overflow workload allocates many pages")

  deleted = executeOne(engine, "DELETE FROM document WHERE id <= 12")
  testkit.equal(state, deleted.affectedRows, 12, "delete creates reclaimable storage")
  updated = executeOne(engine, "UPDATE document SET body = 'short' WHERE id = 13")
  testkit.equal(state, updated.affectedRows, 1, "update creates obsolete overflow chain")
  beforeVacuum = tablePages(databasePath, table)

  vacuumed = executeOne(engine, "VACUUM document")
  testkit.equal(state, vacuumed.command, "VACUUM", "VACUUM command")
  testkit.equal(state, vacuumed.affectedRows, 12, "VACUUM rewrites live rows")
  afterVacuum = tablePages(databasePath, table)
  testkit.record(state, afterVacuum < beforeVacuum, "VACUUM reclaims heap and overflow pages")

  rows = executeOne(engine, "SELECT id, code, body FROM document ORDER BY id")
  testkit.equal(state, len(rows.rows), 12, "VACUUM preserves live row count")
  testkit.equal(state, rows.rows[0][0].value, 13, "VACUUM preserves first live id")
  testkit.equal(state, rows.rows[0][2].value, "short", "VACUUM preserves updated inline text")
  testkit.equal(state, len(rows.rows[1][2].value), 2600, "VACUUM preserves external text")

  stats = statistics.loadOrCreate(databasePath, managed.catalogHandle.metadata.databaseId)
  tableStats = statistics.findTable(stats, table.tableId)
  testkit.record(state, tableStats is not void, "VACUUM refreshes table statistics")
  if tableStats is not void then
    testkit.equal(state, tableStats.rowCount, 12, "VACUUM statistics row count")
    testkit.equal(state, tableStats.pageCount, afterVacuum, "VACUUM statistics page count")
  end if

  oneIndex = executeOne(engine, "REINDEX idx_document_code_id")
  testkit.equal(state, oneIndex.command, "REINDEX", "named REINDEX command")
  testkit.equal(state, oneIndex.affectedRows, 1, "named REINDEX count")
  tableIndexes = executeOne(engine, "REINDEX document")
  testkit.record(state, tableIndexes.affectedRows >= 3, "table REINDEX rebuilds all table indexes")
  allIndexes = executeOne(engine, "REINDEX")
  testkit.record(state, allIndexes.affectedRows >= 3, "global REINDEX rebuilds all indexes")
  verifiedIndexCount = dml.verifyAllIndexes(managed)
  testkit.record(state, verifiedIndexCount >= 3, "indexes match compacted heap")

  point = executeOne(engine, "SELECT body FROM document WHERE code = 'doc-24'")
  testkit.equal(state, len(point.rows), 1, "index lookup works after REINDEX")
  testkit.equal(state, len(point.rows[0][0].value), 2600, "index lookup returns intact LOB")

  executeOne(engine, "BEGIN")
  testkit.errorCode(state, try(executor.executeSql(engine, "VACUUM document")), 9025, "VACUUM rejected inside transaction")
  executeOne(engine, "ROLLBACK")
  executeOne(engine, "BEGIN")
  testkit.errorCode(state, try(executor.executeSql(engine, "REINDEX document")), 9025, "REINDEX rejected inside transaction")
  executeOne(engine, "ROLLBACK")

  executor.close(engine)
  database_manager.close(managed)

  // PREPARED means the file swap was not committed. Opening the database must
  // restore the old generation and remove both replacement debris and journal.
  original = file_api.joinPath(file_api.joinPath(databasePath, "tmp"), "journal-original.bin")
  temporary = original + ".new"
  backup = original + ".old"
  writeText(original, "old-generation")
  writeText(temporary, "new-generation")
  preparedJournal = schema_history.beginMaintenance(databasePath, original, temporary, backup)
  file_api.movePath(original, backup, false)
  file_api.movePath(temporary, original, false)

  managed = database_manager.open(databasePath)
  testkit.equal(state, readText(original), "old-generation", "PREPARED maintenance recovery restores old generation")
  testkit.record(state, not file_api.pathExists(backup), "PREPARED recovery removes backup")
  testkit.record(state, not file_api.pathExists(temporary), "PREPARED recovery removes temporary replacement")
  testkit.record(state, not file_api.pathExists(schema_history.maintenancePath(databasePath)), "PREPARED recovery removes journal")
  database_manager.close(managed)

  // COMMITTED means the replacement is authoritative even if cleanup did not
  // run. Recovery keeps the new file and discards the obsolete generation.
  writeText(temporary, "committed-generation")
  committedJournal = schema_history.beginMaintenance(databasePath, original, temporary, backup)
  file_api.movePath(original, backup, false)
  file_api.movePath(temporary, original, false)
  schema_history.markMaintenanceCommitted(databasePath, committedJournal)

  managed = database_manager.open(databasePath)
  testkit.equal(state, readText(original), "committed-generation", "COMMITTED maintenance recovery preserves replacement")
  testkit.record(state, not file_api.pathExists(backup), "COMMITTED recovery removes obsolete backup")
  testkit.record(state, not file_api.pathExists(temporary), "COMMITTED recovery removes temporary replacement")
  testkit.record(state, not file_api.pathExists(schema_history.maintenancePath(databasePath)), "COMMITTED recovery removes journal")

  engine = executor.attach(managed)
  durable = executeOne(engine, "SELECT id, code, body FROM document ORDER BY id")
  testkit.equal(state, len(durable.rows), 12, "compacted database reopens")
  testkit.equal(state, durable.rows[11][0].value, 24, "final compacted row survives reopen")
  testkit.equal(state, len(durable.rows[11][2].value), 2600, "reopened LOB remains intact")
  testkit.equal(state, dml.verifyAllIndexes(managed), verifiedIndexCount, "reopened indexes verify")
  executor.close(engine)
  database_manager.close(managed)

  return testkit.finish(state, "MiniSQL M25 maintenance tests: SUCCESS", "MiniSQL M25 maintenance tests: FAIL")
end function
