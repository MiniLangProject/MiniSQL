// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.backup as backup
import minisql.tools.encryption as encryption
import tests.support.testkit as testkit

// Executes exactly one SQL statement and returns its result.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Searches a raw artifact for a forbidden plaintext byte sequence.
function containsBytes(source, wanted)
  if len(wanted) == 0 then return true end if
  if len(source) < len(wanted) then return false end if
  for offset = 0 to len(source) - len(wanted)
    matches = true
    for index = 0 to len(wanted) - 1
      if source[offset + index] != wanted[index] then matches = false; break end if
    end for
    if matches then return true end if
  end for
  return false
end function

// Copies one raw provider key to a different path to model backup transfer to
// another host without changing the underlying secret bytes.
function copyKeyFile(source, destination)
  data = try(file_api.readAllBytes(source, 32))
  if typeof(data) == "error" then return data end if
  handle = try(file_api.createNewDurable(destination))
  if typeof(handle) == "error" then uuid.wipeSecret(data); return handle end if
  written = try(file_api.writeAt(handle, 0, data, 0, len(data)))
  uuid.wipeSecret(data)
  if typeof(written) == "error" then ignoredClose = try(file_api.close(handle)); return written end if
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(flushed) == "error" then return flushed end if
  return closed
end function

// Runs the complete encryption-at-rest correctness and failure matrix.
function main(args)
  if len(args) != 1 then print "MiniSQL M79 security-at-rest tests: FAIL args"; return 2 end if
  state = testkit.create()
  file_api.createDirectory(args[0])
  firstKey = file_api.joinPath(args[0], "master-1.key")
  secondKey = file_api.joinPath(args[0], "master-2.key")
  backupKey = file_api.joinPath(args[0], "backup.key")
  relocatedBackupKey = file_api.joinPath(args[0], "relocated-backup.key")
  wrongKey = file_api.joinPath(args[0], "wrong.key")
  testkit.record(state, try(encryption.generateKeyFile(firstKey)), "master key generated")
  testkit.record(state, try(encryption.generateKeyFile(secondKey)), "rotation key generated")
  testkit.record(state, try(encryption.generateKeyFile(backupKey)), "backup key generated")
  testkit.record(state, try(encryption.generateKeyFile(wrongKey)), "wrong key generated")

  managed = database_manager.create(args[0], "m79_tde", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  blockedMigration = try(encryption.enable(databasePath, firstKey))
  testkit.errorCode(state, blockedMigration, 9007, "TDE migration refuses a database held open by another process")
  database_manager.close(managed)
  converted = encryption.enable(databasePath, firstKey)
  testkit.record(state, converted >= 5, "existing system paged files migrated")

  managed = database_manager.open(databasePath)
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE private_rows (id INTEGER PRIMARY KEY, secret VARCHAR(80))")
  executeOne(engine, "INSERT INTO private_rows(id, secret) VALUES (1, 'M79 plaintext sentinel must not persist')")
  tableId = catalog.findTable(managed.catalogHandle, "private_rows").tableId
  executor.close(engine)
  database_manager.close(managed)
  tableBytes = file_api.readAllBytes(catalog.tableFilePath(databasePath, tableId), 1048576)
  testkit.record(state, not containsBytes(tableBytes, bytes("M79 plaintext sentinel must not persist")), "table ciphertext hides row payload")
  walBytes = file_api.readAllBytes(file_api.joinPath(file_api.joinPath(databasePath, "wal"), "wal.log"), 1048576)
  testkit.record(state, not containsBytes(walBytes, bytes("M79 plaintext sentinel must not persist")), "WAL ciphertext hides row payload")

  testkit.record(state, try(encryption.rotate(databasePath, secondKey)), "online envelope rotation succeeds")
  reopened = database_manager.open(databasePath)
  reader = executor.attach(reopened)
  selected = executeOne(reader, "SELECT secret FROM private_rows WHERE id = 1")
  testkit.equal(state, selected.rows[0][0].value, "M79 plaintext sentinel must not persist", "rotated database remains readable")
  executor.close(reader)
  database_manager.close(reopened)

  backupPath = file_api.joinPath(args[0], "encrypted-backup")
  restoredPath = file_api.joinPath(args[0], "restored")
  report = backup.runEncrypted(databasePath, backupPath, backupKey)
  testkit.record(state, report.fileCount > 10, "encrypted backup captures complete database")
  testkit.record(state, try(copyKeyFile(backupKey, relocatedBackupKey)), "backup key can be relocated without changing its bytes")
  restored = backup.restoreEncrypted(backupPath, restoredPath, relocatedBackupKey)
  testkit.equal(state, restored.fileCount, report.fileCount, "encrypted restore file count")
  restoredDb = database_manager.open(restoredPath)
  restoredEngine = executor.attach(restoredDb)
  restoredSelect = executeOne(restoredEngine, "SELECT secret FROM private_rows WHERE id = 1")
  testkit.equal(state, restoredSelect.rows[0][0].value, "M79 plaintext sentinel must not persist", "encrypted backup round trip")
  executor.close(restoredEngine)
  database_manager.close(restoredDb)
  wrongRestore = try(backup.restoreEncrypted(backupPath, file_api.joinPath(args[0], "wrong-restore"), wrongKey))
  testkit.errorCode(state, wrongRestore, 9004, "wrong backup key is rejected")

  return testkit.finish(state, "MiniSQL M79 security-at-rest tests: SUCCESS", "MiniSQL M79 security-at-rest tests: FAIL")
end function
