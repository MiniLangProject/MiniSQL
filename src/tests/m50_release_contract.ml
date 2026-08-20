// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.version as version
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
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
  testkit.equal(state, version.productVersion(), "1.0.0", "release semantic version")
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

  return testkit.finish(state, "MiniSQL M50 release contract tests: SUCCESS", "MiniSQL M50 release contract tests: FAIL")
end function
