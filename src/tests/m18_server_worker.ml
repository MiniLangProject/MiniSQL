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

// Runs the concurrent server worker lifecycle test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 3 then
    print "MiniSQL M18 server worker: FAIL (expected data root, port and ready path)"
    return 1
  end if
  port = toNumber(args[1])
  if typeof(port) != "int" then
    print "MiniSQL M18 server worker: FAIL (invalid port)"
    return 1
  end if

  managed = database_manager.create(args[0], "m18_network", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE message (id INTEGER PRIMARY KEY, body VARCHAR(80) NOT NULL)")
  executeOne(engine, "INSERT INTO message(id, body) VALUES (1, 'from-server')")
  executor.close(engine)
  database_manager.close(managed)

  handled = listener.serveOneWithReadyFile(databasePath, port, 16, args[2])
  if handled != 7 then
    print "MiniSQL M18 server worker: FAIL (handled=" + handled + ")"
    return 1
  end if
  print "MiniSQL M18 server worker: SUCCESS"
  return 0
end function
