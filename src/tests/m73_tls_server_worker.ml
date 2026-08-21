// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.common.logger as logger
import minisql.server.database_manager as database_manager
import minisql.server.server as server

// Prepares an administrator account and serves one bounded native TLS test run.
function main(args)
  if len(args) != 6 then print "MiniSQL M73 TLS server worker: FAIL arguments"; return 2 end if
  port = toNumber(args[2])
  maximumRequests = toNumber(args[5])
  if typeof(port) != "int" or typeof(maximumRequests) != "int" then print "MiniSQL M73 TLS server worker: FAIL numeric arguments"; return 2 end if
  configured = try(logger.configure("debug", ".", true, false, "m73-tls.log", 24, false, "m73-tls-bin.log"))
  if typeof(configured) == "error" then print "ERROR " + configured.code + ": " + configured.message; return 1 end if

  managed = try(database_manager.open(args[0]))
  if typeof(managed) == "error" then print "ERROR " + managed.code + ": " + managed.message; return 1 end if
  passwordSet = try(catalog.setUserPassword(managed.catalogHandle, "admin", "Admin-Native-TLS-73!"))
  closed = try(database_manager.close(managed))
  if typeof(passwordSet) == "error" then print "ERROR " + passwordSet.code + ": " + passwordSet.message; return 1 end if
  if typeof(closed) == "error" then print "ERROR " + closed.code + ": " + closed.message; return 1 end if

  handled = try(server.serveTlsAddressWithReadyFile(args[0], args[1], port, 8, maximumRequests, args[4], args[3]))
  if typeof(handled) == "error" then print "ERROR " + handled.code + ": " + handled.message; return 1 end if
  if handled != maximumRequests then print "MiniSQL M73 TLS server worker: FAIL requests=" + handled; return 1 end if
  print "MiniSQL M73 TLS server worker: SUCCESS requests=" + handled
  return 0
end function
