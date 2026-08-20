// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.server.listener as listener

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the secure concurrent server worker lifecycle test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 5 then print "MiniSQL M29 secure concurrent server worker: FAIL args"; return 2 end if
  root = args[0]
  port = toNumber(args[1])
  readyPath = args[2]
  maximumClients = toNumber(args[3])
  maximumRequests = toNumber(args[4])
  if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then return 2 end if

  file_api.createDirectory(root)
  managed = database_manager.create(root, "m29_secure_server", config_model.defaultDatabaseSettings(4096))
  path = managed.path
  admin = executor.attach(managed)
  executeOne(admin, "CREATE TABLE secure_item (id INTEGER PRIMARY KEY, body VARCHAR(80) NOT NULL)")
  executeOne(admin, "INSERT INTO secure_item(id, body) VALUES (1, 'encrypted-response')")
  executeOne(admin, "CREATE USER netuser WITH PASSWORD 'Network-M29-Password!'")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO netuser")
  executeOne(admin, "GRANT SELECT ON TABLE secure_item TO netuser")
  executor.close(admin)
  database_manager.close(managed)

  // The ready-file listener is bounded by both connection and request counts;
  // returning early, over-serving, or dropping a worker changes `handled` and
  // therefore fails the external multi-process orchestration.
  handled = try(listener.serveConcurrentWithReadyFile(path, port, maximumClients, maximumRequests, readyPath, true))
  if typeof(handled) == "error" then print "ERROR " + handled.code + ": " + handled.message; return 1 end if
  if handled != maximumRequests then print "MiniSQL M29 secure concurrent server worker: FAIL handled=" + handled; return 1 end if
  print "MiniSQL M29 secure concurrent server worker: SUCCESS requests=" + handled
  return 0
end function
