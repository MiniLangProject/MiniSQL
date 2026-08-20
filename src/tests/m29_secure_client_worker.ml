// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.client as client
import minisql.common.uuid as uuid
import minisql.protocol.constants as constants

// Runs the secure concurrent client worker protocol test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 2 then print "MiniSQL M29 secure concurrent client worker: FAIL args"; return 2 end if
  port = toNumber(args[0])
  clientId = toNumber(args[1])
  if typeof(port) != "int" or typeof(clientId) != "int" then return 2 end if

  password = bytes("Network-M29-Password!")
  // Authentication consumes the mutable password buffer; wipe the caller's
  // copy before issuing any application request over the secure connection.
  active = try(client.openAuthenticatedLoopbackBytes(port, "netuser", password))
  uuid.wipeSecret(password)
  if typeof(active) == "error" then print "ERROR " + active.code + ": " + active.message; return 1 end if
  if not active.authenticated or not active.connection.secure then ignored = try(client.close(active)); print "MiniSQL M29 secure concurrent client worker: FAIL transport"; return 1 end if

  // Each independent worker verifies a data request, a control request, and a
  // clean close so the harness covers complete concurrent connection lifecycles.
  selected = try(client.query(active, "SELECT id, body FROM secure_item WHERE id = 1"))
  if typeof(selected) == "error" then ignored = try(client.close(active)); print "ERROR " + selected.code + ": " + selected.message; return 1 end if
  if selected.status != constants.STATUS_ROWS or len(selected.rows) != 1 or selected.rows[0][1] != "encrypted-response" then ignored = try(client.close(active)); print "MiniSQL M29 secure concurrent client worker: FAIL row"; return 1 end if
  pong = try(client.ping(active))
  closed = try(client.close(active))
  if typeof(pong) == "error" then print "ERROR " + pong.code + ": " + pong.message; return 1 end if
  if typeof(closed) == "error" then print "ERROR " + closed.code + ": " + closed.message; return 1 end if
  if not pong then print "MiniSQL M29 secure concurrent client worker: FAIL ping"; return 1 end if
  print "MiniSQL M29 secure concurrent client worker: SUCCESS id=" + clientId
  return 0
end function
