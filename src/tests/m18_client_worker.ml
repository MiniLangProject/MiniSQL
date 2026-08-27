// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.client as client
import minisql.protocol.constants as constants
import tests.support.testkit as testkit

// Runs the concurrent client worker protocol test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M18 client worker: FAIL (expected port)"
    return 1
  end if
  port = toNumber(args[0])
  if typeof(port) != "int" then
    print "MiniSQL M18 client worker: FAIL (invalid port)"
    return 1
  end if

  state = testkit.create()
  connection = client.openLoopback(port)
  testkit.record(state, client.ping(connection), "PING/PONG")

  initial = client.query(connection, "SELECT id, body FROM message ORDER BY id")
  testkit.equal(state, initial.status, constants.STATUS_ROWS, "initial SELECT status")
  testkit.equal(state, len(initial.rows), 1, "initial SELECT rows")
  testkit.equal(state, initial.rows[0][1], "from-server", "initial SELECT value")

  inserted = client.query(connection, "INSERT INTO message(id, body) VALUES (2, 'from-client')")
  testkit.equal(state, inserted.status, constants.STATUS_COMMAND, "INSERT status")
  testkit.equal(state, inserted.affectedRows, 1, "INSERT affected rows")

  selected = client.query(connection, "SELECT body FROM message ORDER BY id")
  testkit.equal(state, len(selected.rows), 2, "SELECT after INSERT rows")
  testkit.equal(state, selected.rows[1][0], "from-client", "SELECT after INSERT value")

  streamed = client.query(connection, "SELECT id, body FROM streamed_result ORDER BY id")
  testkit.equal(state, len(streamed.rows), 1200, "multi-frame SELECT row count")
  testkit.equal(state, streamed.rows[0][1], "row-1", "multi-frame SELECT first row")
  testkit.equal(state, streamed.rows[1199][1], "row-1200", "multi-frame SELECT final row")

  rejected = client.query(connection, "SELECT 1; SELECT 2")
  testkit.equal(state, rejected.status, constants.STATUS_ERROR, "multiple statements rejected")
  testkit.equal(state, rejected.errorCode, 9025, "multiple statements error code")

  testkit.record(state, client.close(connection), "clean CLOSE handshake")
  return testkit.finish(state, "MiniSQL M18 loopback client tests: SUCCESS", "MiniSQL M18 loopback client tests: FAIL")
end function
