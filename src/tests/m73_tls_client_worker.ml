// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.client.client as client
import minisql.protocol.connection as connection

// Exercises system trust rejection, pin mismatch rejection, or a successful pinned session.
function main(args)
  if len(args) != 5 then print "MiniSQL M73 TLS client worker: FAIL arguments"; return 2 end if
  port = toNumber(args[1])
  if typeof(port) != "int" then print "MiniSQL M73 TLS client worker: FAIL port"; return 2 end if
  secret = bytes("Admin-Native-TLS-73!")
  active = void
  if args[4] == "system-reject" then
    active = try(client.openTlsAuthenticatedAddressBytes(args[0], port, args[2], "admin", secret))
  else
    active = try(client.openTlsPinnedAuthenticatedAddressBytes(args[0], port, args[2], args[3], "admin", secret))
  end if
  fillBytes(secret, 0, len(secret), 0)

  if args[4] == "system-reject" or args[4] == "pin-reject" or args[4] == "hostname-reject" then
    if typeof(active) == "error" then print "MiniSQL M73 TLS client worker: SUCCESS rejected=" + args[4]; return 0 end if
    ignoredClose = try(client.close(active))
    print "MiniSQL M73 TLS client worker: FAIL insecure acceptance=" + args[4]
    return 1
  end if

  if typeof(active) == "error" then print "ERROR " + active.code + ": " + active.message; return 1 end if
  tlsActive = try(connection.tlsActive(active.connection))
  secureActive = try(connection.secureActive(active.connection))
  if typeof(tlsActive) == "error" or not tlsActive or typeof(secureActive) == "error" or not secureActive then ignoredClose = try(client.close(active)); print "MiniSQL M73 TLS client worker: FAIL transport state"; return 1 end if
  pong = try(client.ping(active))
  closed = try(client.close(active))
  if typeof(pong) == "error" then print "ERROR " + pong.code + ": " + pong.message; return 1 end if
  if typeof(closed) == "error" then print "ERROR " + closed.code + ": " + closed.message; return 1 end if
  if not pong then print "MiniSQL M73 TLS client worker: FAIL ping"; return 1 end if
  print "MiniSQL M73 TLS client worker: SUCCESS pinned"
  return 0
end function
