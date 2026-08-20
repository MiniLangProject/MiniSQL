// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.server.listener as listener

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Runs the auth concurrent server worker lifecycle test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 3 then
    print "MiniSQL M21 authenticated server worker: FAIL (expected data root, port and ready path)"
    return 1
  end if
  port = toNumber(args[1])
  if typeof(port) != "int" then
    print "MiniSQL M21 authenticated server worker: FAIL (invalid port)"
    return 1
  end if

  managed = database_manager.create(args[0], "m21_network", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  admin = executor.attach(managed)
  executeOne(admin, "CREATE TABLE message (id INTEGER PRIMARY KEY, body VARCHAR(80) NOT NULL)")
  executeOne(admin, "INSERT INTO message(id, body) VALUES (1, 'secure-server')")
  executeOne(admin, "CREATE USER netuser WITH PASSWORD 'Network-Password-21!'")
  executeOne(admin, "GRANT CONNECT ON DATABASE TO netuser")
  executeOne(admin, "GRANT SELECT ON TABLE message TO netuser")
  executor.close(admin)
  database_manager.close(managed)

  handled = listener.serveAuthenticatedOneWithReadyFile(databasePath, port, 16, args[2])
  if handled != 7 then
    print "MiniSQL M21 authenticated server worker: FAIL (handled=" + handled + ")"
    return 1
  end if
  print "MiniSQL M21 authenticated server worker: SUCCESS"
  return 0
end function
