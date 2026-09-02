// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.encryption as encryption

// Executes exactly one benchmark SQL statement.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Returns one closed artifact's physical size.
function pathSize(path)
  handle = file_api.openRead(path)
  length = file_api.size(handle)
  file_api.close(handle)
  return length
end function

// Runs the identical write/read workload for one storage mode.
function runCase(root, name, encrypted, keyPath)
  database = database_manager.create(root, name, config_model.defaultDatabaseSettings(4096))
  path = database.path
  database_manager.close(database)
  if encrypted then encryption.enable(path, keyPath) end if
  database = database_manager.open(path)
  engine = executor.attach(database)
  executeOne(engine, "CREATE TABLE bench (id INTEGER PRIMARY KEY, bucket INTEGER, payload VARCHAR(120))")
  tableId = catalog.findTable(database.catalogHandle, "bench").tableId
  startedWrite = clock.monotonicMilliseconds()
  executeOne(engine, "BEGIN")
  for id = 1 to 500
    executeOne(engine, "INSERT INTO bench(id, bucket, payload) VALUES (" + id + ", " + (id % 32) + ", '0123456789abcdef0123456789abcdef0123456789abcdef')")
  end for
  executeOne(engine, "COMMIT")
  writeMs = clock.monotonicMilliseconds() - startedWrite
  startedRead = clock.monotonicMilliseconds()
  checksum = 0
  for id = 1 to 500
    result = executeOne(engine, "SELECT bucket FROM bench WHERE id = " + id)
    checksum = checksum + result.rows[0][0].value
  end for
  readMs = clock.monotonicMilliseconds() - startedRead
  executor.close(engine)
  database_manager.close(database)
  tableBytes = pathSize(catalog.tableFilePath(path, tableId))
  walBytes = pathSize(file_api.joinPath(file_api.joinPath(path, "wal"), "wal.log"))
  return [writeMs, readMs, tableBytes, walBytes, checksum]
end function

// Runs one or both reproducible TDE overhead cases.
function main(args)
  if len(args) < 1 or len(args) > 2 then print "usage: tde-overhead <data-root> [plain|tde]"; return 2 end if
  file_api.createDirectory(args[0])
  keyPath = file_api.joinPath(args[0], "benchmark.key")
  encryption.generateKeyFile(keyPath)
  if len(args) == 2 then
    if args[1] != "plain" and args[1] != "tde" then return 2 end if
    result = runCase(args[0], args[1], args[1] == "tde", keyPath)
    print args[1] + " write_ms=" + result[0] + " read_ms=" + result[1] + " table_bytes=" + result[2] + " wal_bytes=" + result[3] + " checksum=" + result[4]
    return 0
  end if
  plain = runCase(args[0], "plain", false, keyPath)
  encrypted = runCase(args[0], "encrypted", true, keyPath)
  print "plain write_ms=" + plain[0] + " read_ms=" + plain[1] + " table_bytes=" + plain[2] + " wal_bytes=" + plain[3] + " checksum=" + plain[4]
  print "tde write_ms=" + encrypted[0] + " read_ms=" + encrypted[1] + " table_bytes=" + encrypted[2] + " wal_bytes=" + encrypted[3] + " checksum=" + encrypted[4]
  return 0
end function
