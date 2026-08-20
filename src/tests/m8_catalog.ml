// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.catalog as catalog
import minisql.common.uuid as uuid
import minisql.config.loader as loader
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.transaction.transaction as transaction
import tests.support.testkit as testkit

// Copies the source file in bounded chunks and flushes the destination, providing a durable fixture for corruption tests.
function copyFile(sourcePath, destinationPath)
  source = file_api.openRead(sourcePath)
  length = file_api.size(source)
  data = bytes(length, 0)
  file_api.readExactAt(source, 0, data, 0, length)
  file_api.close(source)
  destination = file_api.create(destinationPath)
  file_api.writeAt(destination, 0, data, 0, length)
  file_api.flush(destination)
  file_api.close(destination)
  return true
end function

// Runs the catalog test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 2 then
    print "MiniSQL M8 database/catalog tests: FAIL (missing paths)"
    return 1
  end if
  configPath = args[0]
  dataRoot = args[1]
  state = testkit.create()
  config = loader.load(configPath)

  id1 = uuid.create()
  id2 = uuid.create()
  testkit.equal(state, len(id1), 16, "UUID length")
  testkit.record(state, not uuid.equals(id1, id2), "UUID uniqueness")
  testkit.record(state, uuid.equals(uuid.parseHex(uuid.toHex(id1)), id1), "UUID hex roundtrip")

  testkit.errorCode(state, try(catalog.createDatabase(dataRoot, "invalid_defaults", [])), catalog.INVALID_ARGUMENT, "wrong defaults struct rejected")
  first = catalog.createDatabase(dataRoot, "first_db", config.databaseDefaults)
  firstPath = first.path
  firstId = bytes(first.metadata.databaseId)
  testkit.equal(state, first.metadata.pageSize, 4096, "first database persisted page size")
  testkit.record(state, file_api.directoryExists(catalog.joinPath(first.path, "tables")), "tables directory")
  testkit.record(state, file_api.directoryExists(catalog.joinPath(first.path, "indexes")), "indexes directory")
  testkit.record(state, file_api.directoryExists(catalog.joinPath(first.path, "wal")), "wal directory")

  columns = [
    catalog.defineColumn("id", 4, false, 0, 0, 0),
    catalog.defineColumn("name", 10, true, 200, 0, 0)
  ]
  testkit.errorCode(state, try(catalog.createTable(first, "invalid_columns", [[]])), catalog.INVALID_ARGUMENT, "wrong column metadata struct rejected")
  table = catalog.createTable(first, "customer", columns)
  testkit.record(state, table.tableId >= 3, "table object id assigned")
  testkit.equal(state, len(table.columns), 2, "columns persisted")
  testkit.record(state, table.columns[0].columnId != table.columns[1].columnId, "column ids unique")
  tablePath = catalog.tableFilePath(first.path, table.tableId)
  testkit.record(state, file_api.fileExists(tablePath), "one physical file created per table")
  tx1 = catalog.allocateTransactionId(first)
  tx2 = catalog.allocateTransactionId(first)
  testkit.equal(state, tx1, 1, "first transaction id")
  testkit.equal(state, tx2, 2, "second transaction id")
  catalog.close(first)

  // Global defaults change only future databases.
  config.databaseDefaults.pageSize = 8192
  reopened = catalog.openDatabase(firstPath)
  testkit.equal(state, reopened.metadata.pageSize, 4096, "existing database ignores changed global default")
  testkit.record(state, uuid.equals(reopened.metadata.databaseId, firstId), "database identity stable")
  persistedTable = catalog.findTable(reopened, "customer")
  testkit.record(state, persistedTable is not void, "table metadata survives reopen")
  testkit.equal(state, persistedTable.columns[1].name, "name", "column metadata survives reopen")
  testkit.equal(state, catalog.allocateTransactionId(reopened), 3, "transaction id survives reopen")
  catalog.close(reopened)

  managed = database_manager.open(firstPath)
  testkit.equal(state, managed.lastRecovery.pagesRedone, 0, "database manager performs startup recovery before sessions")
  managedTransaction = database_manager.begin(managed, transaction.ISOLATION_SERIALIZABLE, false)
  testkit.equal(state, managedTransaction.transactionId, 4, "database manager allocates durable transaction IDs")
  transaction.rollback(managedTransaction)
  database_manager.close(managed)

  // Missing physical table files are detected rather than silently recreated.
  tableBackup = tablePath + ".backup"
  copyFile(tablePath, tableBackup)
  file_api.deletePath(tablePath)
  testkit.errorCode(state, try(catalog.openDatabase(firstPath)), catalog.CORRUPT_DATA, "missing table file rejected")
  copyFile(tableBackup, tablePath)
  file_api.deletePath(tableBackup)

  second = catalog.createDatabase(dataRoot, "second_db", config.databaseDefaults)
  secondPath = second.path
  testkit.equal(state, second.metadata.pageSize, 8192, "new database receives new default")
  testkit.record(state, not uuid.equals(second.metadata.databaseId, firstId), "database UUIDs differ")
  catalog.close(second)

  // Replacing a catalog with one from another database must be detected.
  sourceCatalog = catalog.joinPath(catalog.joinPath(secondPath, "catalog"), "catalog.tbl")
  destinationCatalog = catalog.joinPath(catalog.joinPath(firstPath, "catalog"), "catalog.tbl")
  copyFile(sourceCatalog, destinationCatalog)
  testkit.errorCode(state, try(catalog.openDatabase(firstPath)), catalog.CORRUPT_DATA, "foreign catalog file rejected")

  return testkit.finish(state, "MiniSQL M8 database/catalog tests: SUCCESS", "MiniSQL M8 database/catalog tests: FAIL")
end function
