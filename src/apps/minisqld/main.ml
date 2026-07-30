import minisql.catalog.catalog as catalog
import minisql.client.console as console
import minisql.common.limits as limits
import minisql.common.uuid as uuid
import minisql.config.model as config_model
import minisql.server.database_manager as database_manager
import minisql.server.server as server

function printUsage()
  print "MiniSQL database server"
  print ""
  print "Database setup:"
  print "  minisqld.exe --init <data-root> <database-name> [page-size]"
  print "  minisqld.exe --set-admin-password <database-path>"
  print "  minisqld.exe --set-user-password <database-path> <user>"
  print ""
  print "Operational servers (run until stopped with Ctrl+C):"
  print "  minisqld.exe --serve <database-path> <port> [max-clients]"
  print "  minisqld.exe --serve-authenticated <database-path> <port> [max-clients]"
  print "  minisqld.exe --serve-standby <standby-path> <port> [max-clients]"
  print "  minisqld.exe --serve-secure <database-path> <address> <port> <max-clients> [max-requests]"
  print ""
  print "Bounded compatibility/test servers:"
  print "  minisqld.exe --serve-one <database-path> <port> [max-requests]"
  print "  minisqld.exe --serve-auth <database-path> <port> [max-requests]"
  print "  minisqld.exe --serve-many <database-path> <port> <max-clients> [max-requests]"
  print "  minisqld.exe --serve-auth-many <database-path> <port> <max-clients> [max-requests]"
end function

function printAppError(value)
  print "ERROR " + value.code + ": " + value.message
  return 1
end function

function serverResult(result)
  if typeof(result) == "error" then return printAppError(result) end if
  print "MiniSQL server completed requests=" + result
  return 0
end function

function initializeDatabase(dataRoot, databaseName, pageSize)
  if typeof(pageSize) != "int" or not limits.isSupportedPageSize(pageSize) then
    print "ERROR 9001: page-size must be one of 4096, 8192, 16384 or 32768"
    return 2
  end if
  defaults = config_model.defaultDatabaseSettings(pageSize)
  created = try(database_manager.create(dataRoot, databaseName, defaults))
  if typeof(created) == "error" then return printAppError(created) end if
  createdPath = created.path
  closed = try(database_manager.close(created))
  if typeof(closed) == "error" then return printAppError(closed) end if
  print "MiniSQL database created: " + createdPath
  print "Database name: " + databaseName
  print "Page size: " + pageSize
  return 0
end function

function setUserPassword(databasePath, username)
  secret = try(console.readPasswordConfirmed("Password: ", "Confirm password: "))
  if typeof(secret) == "error" then return printAppError(secret) end if
  database = try(database_manager.open(databasePath))
  if typeof(database) == "error" then uuid.wipeSecret(secret); return printAppError(database) end if
  changed = try(catalog.setUserPasswordBytes(database.catalogHandle, username, secret))
  uuid.wipeSecret(secret)
  closed = try(database_manager.close(database))
  if typeof(changed) == "error" then return printAppError(changed) end if
  if typeof(closed) == "error" then return printAppError(closed) end if
  print "MiniSQL password updated for user: " + username
  return 0
end function

function announceServer(mode, databasePath, address, port, maximumClients, maximumRequests)
  budget = "unlimited"
  if maximumRequests > 0 then budget = "" + maximumRequests end if
  print "MiniSQL server starting"
  print "  mode: " + mode
  print "  database: " + databasePath
  print "  address: " + address
  print "  port: " + port
  print "  max clients: " + maximumClients
  print "  request budget: " + budget
  if maximumRequests == 0 then print "Press Ctrl+C to stop the server." end if
  return true
end function

function main(args)
  if len(args) == 1 and args[0] == "--version" then print server.versionLine(); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print server.m0SelfTestLine(); return 0 end if

  if len(args) >= 3 and len(args) <= 4 and args[0] == "--init" then
    pageSize = 4096
    if len(args) == 4 then pageSize = toNumber(args[3]) end if
    return initializeDatabase(args[1], args[2], pageSize)
  end if

  if len(args) == 2 and args[0] == "--set-admin-password" then
    return setUserPassword(args[1], "admin")
  end if

  if len(args) == 3 and args[0] == "--set-user-password" then
    return setUserPassword(args[1], args[2])
  end if

  if (len(args) == 3 or len(args) == 4) and (args[0] == "--serve" or args[0] == "--serve-authenticated" or args[0] == "--serve-standby") then
    port = toNumber(args[2])
    maximumClients = 32
    if len(args) == 4 then maximumClients = toNumber(args[3]) end if
    if typeof(port) != "int" or typeof(maximumClients) != "int" then printUsage(); return 2 end if
    result = void
    if args[0] == "--serve-authenticated" then
      announceServer("authenticated-loopback", args[1], "127.0.0.1", port, maximumClients, 0)
      result = try(server.serveAuthenticatedConcurrent(args[1], port, maximumClients, 0))
    else if args[0] == "--serve-standby" then
      announceServer("read-only-hot-standby", args[1], "127.0.0.1", port, maximumClients, 0)
      result = try(server.serveStandbyConcurrent(args[1], port, maximumClients, 0))
    else
      announceServer("trusted-local", args[1], "127.0.0.1", port, maximumClients, 0)
      result = try(server.serveConcurrent(args[1], port, maximumClients, 0))
    end if
    return serverResult(result)
  end if

  if (len(args) == 3 or len(args) == 4) and (args[0] == "--serve-one" or args[0] == "--serve-auth") then
    port = toNumber(args[2])
    maximumRequests = 0
    if len(args) == 4 then maximumRequests = toNumber(args[3]) end if
    if typeof(port) != "int" or typeof(maximumRequests) != "int" then printUsage(); return 2 end if
    result = void
    if args[0] == "--serve-auth" then
      announceServer("authenticated-single-session", args[1], "127.0.0.1", port, 1, maximumRequests)
      result = try(server.serveAuthenticatedOne(args[1], port, maximumRequests))
    else
      announceServer("trusted-single-session", args[1], "127.0.0.1", port, 1, maximumRequests)
      result = try(server.serveOne(args[1], port, maximumRequests))
    end if
    return serverResult(result)
  end if

  if (len(args) == 4 or len(args) == 5) and (args[0] == "--serve-many" or args[0] == "--serve-auth-many") then
    port = toNumber(args[2])
    maximumClients = toNumber(args[3])
    maximumRequests = 0
    if len(args) == 5 then maximumRequests = toNumber(args[4]) end if
    if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then printUsage(); return 2 end if
    result = void
    if args[0] == "--serve-auth-many" then
      announceServer("authenticated-loopback", args[1], "127.0.0.1", port, maximumClients, maximumRequests)
      result = try(server.serveAuthenticatedConcurrent(args[1], port, maximumClients, maximumRequests))
    else
      announceServer("trusted-local", args[1], "127.0.0.1", port, maximumClients, maximumRequests)
      result = try(server.serveConcurrent(args[1], port, maximumClients, maximumRequests))
    end if
    return serverResult(result)
  end if

  if (len(args) == 5 or len(args) == 6) and args[0] == "--serve-secure" then
    port = toNumber(args[3])
    maximumClients = toNumber(args[4])
    maximumRequests = 0
    if len(args) == 6 then maximumRequests = toNumber(args[5]) end if
    if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then printUsage(); return 2 end if
    announceServer("authenticated-encrypted", args[1], args[2], port, maximumClients, maximumRequests)
    return serverResult(try(server.serveSecureAddress(args[1], args[2], port, maximumClients, maximumRequests)))
  end if

  printUsage()
  return 2
end function
