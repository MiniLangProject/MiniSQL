// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

//! Provides apps minisql admin main facilities for this project.

import minisql.admin.fullclient as fullclient
import minisql.admin.win32_client as win32_client
import minisql.client.console as console
import minisql.common.uuid as uuid
import minisql.common.version as version
import minisql.platform.win32_gui as gui

/// Prints command-line entry points for the native MiniSQL Workbench.
function printUsage()
  print "MiniSQL Workbench"
  print ""
  print "  minisql-admin.exe"
  print "  minisql-admin.exe --version"
  print "  minisql-admin.exe --m0-self-test"
  print "  minisql-admin.exe --smoke"
  print "  minisql-admin.exe --connect-local <port> [database-label]"
  print "  minisql-admin.exe --connect <address> <port> <user> [database-label]"
  print "  minisql-admin.exe --connect-tls <address> <port> <server-name> <user> [database-label] [sha256-pin]"
end function

/// Prints one structured application error and returns a failing exit code.
/// @param value Value consumed or transformed by the operation.
function printAppError(value)
  print "ERROR " + value.code + ": " + value.message
  return 1
end function

/// Opens a profile in the native workbench and wipes the supplied password bytes.
/// @param profile profile value consumed by this operation.
/// @param password password value consumed by this operation.
function runProfile(profile, password)
  session = try(win32_client.openProfile(profile, password, true))
  uuid.wipeSecret(password)
  if typeof(session) == "error" then return session end if
  return win32_client.runSession(session)
end function

/// Converts a direct-connect failure into a GUI error followed by a retryable manager.
/// @param value Value consumed or transformed by the operation.
function recoverConnectionFailure(value)
  gui.showError(0, "MiniSQL connection failed", win32_client.connectionFailureText(value))
  return win32_client.launchConnectionManager()
end function

/// Dispatches GUI launch, smoke diagnostics, and explicit connection command lines.
/// @param args Command-line or caller-supplied arguments.
function main(args)
  if len(args) == 0 then
    result = try(win32_client.launchConnectionManager())
    if typeof(result) == "error" then return printAppError(result) end if
    return 0
  end if
  if len(args) == 1 and args[0] == "--version" then print version.versionLine("workbench"); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print "MiniSQL Workbench M0 self-test: SUCCESS"; return 0 end if
  if len(args) == 1 and args[0] == "--smoke" then
    smoke = try(gui.hiddenWindowSmoke())
    if typeof(smoke) == "error" then return printAppError(smoke) end if
    layout = try(win32_client.layoutSmoke())
    if typeof(layout) == "error" then return printAppError(layout) end if
    print "MiniSQL Workbench Win32 smoke: SUCCESS"
    return 0
  end if
  if len(args) >= 2 and len(args) <= 3 and args[0] == "--connect-local" then
    port = toNumber(args[1])
    if typeof(port) != "int" then printUsage(); return 2 end if
    databaseName = "main"
    if len(args) == 3 then databaseName = args[2] end if
    profile = try(fullclient.createProfile("Local MiniSQL", "127.0.0.1", port, "localhost", databaseName, "", false, "", true))
    if typeof(profile) == "error" then return printAppError(profile) end if
    result = try(runProfile(profile, bytes(0)))
    if typeof(result) == "error" then
      recovered = try(recoverConnectionFailure(result))
      if typeof(recovered) == "error" then return printAppError(recovered) end if
    end if
    return 0
  end if
  if len(args) >= 4 and len(args) <= 5 and args[0] == "--connect" then
    port = toNumber(args[2])
    if typeof(port) != "int" then printUsage(); return 2 end if
    databaseName = "main"
    if len(args) == 5 then databaseName = args[4] end if
    password = try(console.readPassword("Password: "))
    if typeof(password) == "error" then return printAppError(password) end if
    profile = try(fullclient.createProfile(args[1] + ":" + port, args[1], port, args[1], databaseName, args[3], false, "", false))
    if typeof(profile) == "error" then uuid.wipeSecret(password); return printAppError(profile) end if
    result = try(runProfile(profile, password))
    if typeof(result) == "error" then
      recovered = try(recoverConnectionFailure(result))
      if typeof(recovered) == "error" then return printAppError(recovered) end if
    end if
    return 0
  end if
  if len(args) >= 5 and len(args) <= 7 and args[0] == "--connect-tls" then
    port = toNumber(args[2])
    if typeof(port) != "int" then printUsage(); return 2 end if
    databaseName = "main"
    pinSha256 = ""
    if len(args) >= 6 then databaseName = args[5] end if
    if len(args) == 7 then pinSha256 = args[6] end if
    password = try(console.readPassword("Password: "))
    if typeof(password) == "error" then return printAppError(password) end if
    profile = try(fullclient.createProfile("TLS " + args[1], args[1], port, args[3], databaseName, args[4], true, pinSha256, false))
    if typeof(profile) == "error" then uuid.wipeSecret(password); return printAppError(profile) end if
    result = try(runProfile(profile, password))
    if typeof(result) == "error" then
      recovered = try(recoverConnectionFailure(result))
      if typeof(recovered) == "error" then return printAppError(recovered) end if
    end if
    return 0
  end if
  printUsage()
  return 2
end function
