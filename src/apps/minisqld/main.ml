// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.client.console as console
import minisql.common.limits as limits
import minisql.common.logger as logger
import minisql.common.uuid as uuid
import minisql.config.loader as config_loader
import minisql.config.model as config_model
import minisql.server.database_manager as database_manager
import minisql.server.server as server

// Prints usage using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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
  print "  minisqld.exe --serve-tls <database-path> <address> <port> <max-clients> <store:thumbprint|pfx:path> [max-requests]"
  print "  minisqld.exe --serve-config <database-path> <config-file>"
  print "  minisqld.exe --serve-authenticated-config <database-path> <config-file>"
  print "  minisqld.exe --serve-standby-config <database-path> <config-file>"
  print "  minisqld.exe --serve-tls-config <database-path> <config-file>"
  print ""
  print "Bounded compatibility/test servers:"
  print "  minisqld.exe --serve-one <database-path> <port> [max-requests]"
  print "  minisqld.exe --serve-auth <database-path> <port> [max-requests]"
  print "  minisqld.exe --serve-many <database-path> <port> <max-clients> [max-requests]"
  print "  minisqld.exe --serve-auth-many <database-path> <port> <max-clients> [max-requests]"
end function

// Prints app error using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function printAppError(value)
  print "ERROR " + value.code + ": " + value.message
  return 1
end function

// Implements server result for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function serverResult(result)
  code = 0
  if typeof(result) == "error" then
    ignoredLog = logger.errorLog("minisql.main.serverResult", "server stopped with error code=" + result.code + " message=" + result.message)
    code = printAppError(result)
  else
    ignoredLog = logger.info("minisql.main.serverResult", "server stopped requests=" + result)
    print "MiniSQL server completed requests=" + result
  end if
  ignoredClose = try(logger.close())
  return code
end function

// Applies validated configuration to the process-wide logger singleton.
// Inputs: `config`. Returns true after stdout, rolling file, threshold and binlog settings are active.
function configureLogger(config)
  return logger.configure(config.runtime.logLevel, config.paths.logDirectory, config.logging.stdoutEnabled, config.logging.fileEnabled, config.logging.fileName, config.logging.rotationHours, config.binlog.enabled, config.binlog.fileName)
end function

// Starts an operational server entirely from a JSON configuration file.
// Inputs: `mode`, `databasePath`, `configPath`. Returns the public process exit code.
function runConfiguredServer(mode, databasePath, configPath)
  config = try(config_loader.load(configPath))
  if typeof(config) == "error" then return printAppError(config) end if
  configured = try(configureLogger(config))
  if typeof(configured) == "error" then return printAppError(configured) end if
  ignoredLog = logger.info("minisql.main.runConfiguredServer", "starting mode=" + mode + " database=" + databasePath + " address=" + config.server.bindAddress + " port=" + config.server.port + " maxClients=" + config.server.maxConnections)
  if mode == "tls" then
    if not config.tls.enabled then ignoredClose = try(logger.close()); print "ERROR 9002: tls.enabled must be true for --serve-tls-config"; return 1 end if
    announceServer("native-tls1.3-authenticated", databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0)
    return serverResult(try(server.serveTlsAddress(databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0, config.tls.certificateReference)))
  end if
  if mode == "authenticated" then
    announceServer("authenticated-encrypted", databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0)
    return serverResult(try(server.serveSecureAddress(databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0)))
  end if
  if config.server.bindAddress != "127.0.0.1" then ignoredClose = try(logger.close()); print "ERROR 9002: trusted and standby config servers must bind 127.0.0.1"; return 1 end if
  if mode == "standby" then
    announceServer("read-only-hot-standby", databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0)
    return serverResult(try(server.serveStandbyConcurrent(databasePath, config.server.port, config.server.maxConnections, 0)))
  end if
  announceServer("trusted-local", databasePath, config.server.bindAddress, config.server.port, config.server.maxConnections, 0)
  return serverResult(try(server.serveConcurrent(databasePath, config.server.port, config.server.maxConnections, 0)))
end function

// Enables documented default logging for legacy explicit-argument server modes.
// Takes no caller inputs. Returns true after the singleton is configured.
function configureDefaultLogger()
  return configureLogger(config_model.defaultConfig(".\\data"))
end function

// Implements initialize database for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements set user password for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
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

// Implements announce server for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements main for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

  if len(args) == 3 and (args[0] == "--serve-config" or args[0] == "--serve-authenticated-config" or args[0] == "--serve-standby-config" or args[0] == "--serve-tls-config") then
    mode = "trusted"
    if args[0] == "--serve-authenticated-config" then mode = "authenticated" end if
    if args[0] == "--serve-standby-config" then mode = "standby" end if
    if args[0] == "--serve-tls-config" then mode = "tls" end if
    return runConfiguredServer(mode, args[1], args[2])
  end if

  if (len(args) == 3 or len(args) == 4) and (args[0] == "--serve" or args[0] == "--serve-authenticated" or args[0] == "--serve-standby") then
    configured = try(configureDefaultLogger())
    if typeof(configured) == "error" then return printAppError(configured) end if
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
    configured = try(configureDefaultLogger())
    if typeof(configured) == "error" then return printAppError(configured) end if
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
    configured = try(configureDefaultLogger())
    if typeof(configured) == "error" then return printAppError(configured) end if
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
    configured = try(configureDefaultLogger())
    if typeof(configured) == "error" then return printAppError(configured) end if
    port = toNumber(args[3])
    maximumClients = toNumber(args[4])
    maximumRequests = 0
    if len(args) == 6 then maximumRequests = toNumber(args[5]) end if
    if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then printUsage(); return 2 end if
    announceServer("authenticated-encrypted", args[1], args[2], port, maximumClients, maximumRequests)
    return serverResult(try(server.serveSecureAddress(args[1], args[2], port, maximumClients, maximumRequests)))
  end if

  if (len(args) == 6 or len(args) == 7) and args[0] == "--serve-tls" then
    configured = try(configureDefaultLogger())
    if typeof(configured) == "error" then return printAppError(configured) end if
    port = toNumber(args[3])
    maximumClients = toNumber(args[4])
    maximumRequests = 0
    if len(args) == 7 then maximumRequests = toNumber(args[6]) end if
    if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then printUsage(); return 2 end if
    announceServer("native-tls1.3-authenticated", args[1], args[2], port, maximumClients, maximumRequests)
    ignoredTlsLog = logger.info("minisql.main.main", "native TLS policy cipher=TLS_AES_256_GCM_SHA384 group=X25519 certificate=" + args[5])
    return serverResult(try(server.serveTlsAddress(args[1], args[2], port, maximumClients, maximumRequests, args[5])))
  end if

  printUsage()
  return 2
end function
