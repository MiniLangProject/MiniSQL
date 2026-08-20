// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.client.client as client
import minisql.platform.clock as clock
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

// Recognizes protocol error responses so worker code can route them through its common diagnostic path.
function failed(response)
  if typeof(response) == "error" then return true end if
  if not messages.isResponse(response) then return true end if
  return response.status == constants.STATUS_ERROR
end function

// Attempts to close a client connection while deliberately suppressing cleanup errors on an already-failing path.
function closeQuiet(active)
  ignored = try(client.close(active))
  return true
end function

// Prints a worker-stage diagnostic, closes the active client when available, and returns a non-zero worker status.
function reportFailure(active, clientId, stage, value)
  if active is not void then closeQuiet(active) end if
  prefix = "MiniSQL M27 concurrent client worker: FAIL id=" + clientId + " stage=" + stage
  if typeof(value) == "error" then
    print prefix + " error=" + value.code + " message=" + value.message
  else if messages.isResponse(value) then
    print prefix + " status=" + value.status + " errorCode=" + value.errorCode + " message=" + value.message
  else
    print prefix + " valueType=" + typeName(value)
  end if
  return 1
end function

// Runs the concurrent client worker protocol test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 2 then print "MiniSQL M27 concurrent client worker: FAIL args"; return 2 end if
  port = toNumber(args[0])
  clientId = toNumber(args[1])
  if typeof(port) != "int" or typeof(clientId) != "int" then return 2 end if
  active = try(client.openLoopback(port))
  if typeof(active) == "error" then
    print "MiniSQL M27 concurrent client worker: FAIL id=" + clientId + " stage=open error=" + active.code + " message=" + active.message
    return 1
  end if

  if clientId == 1 then
    begun = try(client.query(active, "BEGIN"))
    if failed(begun) then return reportFailure(active, clientId, "begin", begun) end if
    inserted = try(client.query(active, "INSERT INTO shared_item(id, value) VALUES (1, 'writer-one')"))
    if failed(inserted) then return reportFailure(active, clientId, "insert", inserted) end if
    // Hold the writer lock long enough for the second connection worker to
    // enter its pending-lock retry path, then commit and release it.
    clock.sleepMilliseconds(250)
    committed = try(client.query(active, "COMMIT"))
    if failed(committed) then return reportFailure(active, clientId, "commit", committed) end if
  else if clientId == 2 then
    clock.sleepMilliseconds(50)
    inserted = try(client.query(active, "INSERT INTO shared_item(id, value) VALUES (2, 'writer-two')"))
    if failed(inserted) then return reportFailure(active, clientId, "insert", inserted) end if
    counted = try(client.query(active, "SELECT COUNT(*) AS c FROM shared_item"))
    if failed(counted) then return reportFailure(active, clientId, "count-query", counted) end if
    if len(counted.rows) != 1 or toNumber(counted.rows[0][0]) != 2 then
      closeQuiet(active)
      print "MiniSQL M27 concurrent client worker: FAIL id=" + clientId + " stage=count-result rows=" + len(counted.rows)
      return 1
    end if
  else
    selected = try(client.query(active, "SELECT " + clientId + " AS client_id"))
    if failed(selected) then return reportFailure(active, clientId, "select", selected) end if
    if len(selected.rows) != 1 or toNumber(selected.rows[0][0]) != clientId then
      closeQuiet(active)
      print "MiniSQL M27 concurrent client worker: FAIL id=" + clientId + " stage=select-result rows=" + len(selected.rows)
      return 1
    end if
  end if

  pong = try(client.ping(active))
  if typeof(pong) == "error" or not pong then return reportFailure(active, clientId, "ping", pong) end if
  closed = try(client.close(active))
  if typeof(closed) == "error" then return reportFailure(void, clientId, "close", closed) end if
  print "MiniSQL M27 concurrent client worker: SUCCESS id=" + clientId
  return 0
end function
