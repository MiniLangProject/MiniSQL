// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

//! Provides apps minisql main facilities for this project.

import minisql.client.client as client
import minisql.client.formatter as formatter
import minisql.client.console as console

/// Prints command-line syntax for trusted, authenticated, and encrypted client modes.
/// Writes only to standard output and returns void.
function printUsage()
  print "MiniSQL console client"
  print ""
  print "Trusted loopback:"
  print "  minisql.exe --ping <port>"
  print "  minisql.exe --query <port> <sql>"
  print "  minisql.exe --shell <port>"
  print "  minisql.exe --script <port> <file>"
  print ""
  print "Authenticated loopback (password prompt):"
  print "  minisql.exe --auth-ping-prompt <port> <user>"
  print "  minisql.exe --auth-query-prompt <port> <user> <sql>"
  print "  minisql.exe --auth-shell-prompt <port> <user>"
  print "  minisql.exe --auth-script-prompt <port> <user> <file>"
  print ""
  print "Authenticated encrypted transport:"
  print "  minisql.exe --secure-ping <address> <port> <user>"
  print "  minisql.exe --secure-query <address> <port> <user> <sql>"
  print "  minisql.exe --secure-shell <address> <port> <user>"
  print "  minisql.exe --secure-script <address> <port> <user> <file>"
  print ""
  print "Native TLS 1.3 with Windows certificate trust:"
  print "  minisql.exe --tls-ping <address> <port> <server-name> <user>"
  print "  minisql.exe --tls-query <address> <port> <server-name> <user> <sql>"
  print "  minisql.exe --tls-shell <address> <port> <server-name> <user>"
  print "  minisql.exe --tls-script <address> <port> <server-name> <user> <file>"
  print "Native TLS 1.3 with a self-signed/leaf SHA-256 pin:"
  print "  minisql.exe --tls-pin-shell <address> <port> <server-name> <sha256-pin> <user>"
  print "  (ping, query, and script variants use the same argument order)"
end function

/// Prints a structured client error and returns the conventional failure status.
/// @param value Value consumed or transformed by the operation.
function printClientError(value)
  print "ERROR " + value.code + ": " + value.message
  return 1
end function

/// Closes a client after an operation and converts either error to a process status.
/// Returns zero only when both the operation and close completed successfully.
/// @param active active value consumed by this operation.
/// @param result Result object populated or inspected by the operation.
function closeAfter(active, result)
  closed = try(client.close(active))
  if typeof(result) == "error" then return printClientError(result) end if
  if typeof(closed) == "error" then return printClientError(closed) end if
  return 0
end function

/// Sends PING, closes the connection, and prints PONG on success.
/// Returns zero on success and one for protocol, close, or negative-ping failures.
/// @param active active value consumed by this operation.
function runPing(active)
  result = try(client.ping(active))
  closed = try(client.close(active))
  if typeof(result) == "error" then return printClientError(result) end if
  if typeof(closed) == "error" then return printClientError(closed) end if
  if not result then print "PING failed"; return 1 end if
  print "PONG"
  return 0
end function

/// Executes and formats one SQL query before closing the connection.
/// Returns one for protocol ERROR responses or client/formatting failures.
/// @param active active value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
function runQuery(active, sqlText)
  response = try(client.query(active, sqlText))
  closed = try(client.close(active))
  if typeof(response) == "error" then return printClientError(response) end if
  if typeof(closed) == "error" then return printClientError(closed) end if
  formatted = try(formatter.formatResponse(response))
  if typeof(formatted) == "error" then return printClientError(formatted) end if
  print formatted
  if response.status == 3 then return 1 end if
  return 0
end function

/// Runs the interactive shell and always closes its client afterward.
/// @param active active value consumed by this operation.
function runShell(active)
  result = try(console.runShell(active, "minisql> "))
  return closeAfter(active, result)
end function

/// Executes a SQL script, closes the client, and reports the statement count.
/// Returns a nonzero status for script or cleanup errors.
/// @param active active value consumed by this operation.
/// @param path Path of the file or directory used by the operation.
function runScript(active, path)
  result = try(console.runScript(active, path))
  status = closeAfter(active, result)
  if status != 0 then return status end if
  print "MiniSQL script completed statements=" + result
  return 0
end function

/// Opens an unauthenticated loopback client for the supplied port.
/// @param port port value consumed by this operation.
function openTrusted(port)
  return client.openLoopback(port)
end function

/// Prompts for credentials and opens an authenticated connection to the address.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param username username value consumed by this operation.
function openPrompt(address, port, username)
  return console.openAuthenticatedPrompt(address, port, username)
end function

/// Prompts for credentials and opens native TLS with Windows certificate trust.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
/// @param username username value consumed by this operation.
function openTlsPrompt(address, port, serverName, username)
  return console.openTlsAuthenticatedPrompt(address, port, serverName, username)
end function

/// Prompts for credentials and opens native TLS with exact leaf-certificate pinning.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
/// @param pinText pinText value consumed by this operation.
/// @param username username value consumed by this operation.
function openTlsPinnedPrompt(address, port, serverName, pinText, username)
  return console.openTlsPinnedAuthenticatedPrompt(address, port, serverName, pinText, username)
end function

/// Dispatches the public CLI modes after validating arity and numeric ports.
/// Returns zero on success, one on operational failure, or two for usage errors.
/// @param args Command-line or caller-supplied arguments.
function main(args)
  if len(args) == 1 and args[0] == "--version" then print client.versionLine(); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print client.m0SelfTestLine(); return 0 end if

  if len(args) >= 2 and (args[0] == "--ping" or args[0] == "--query" or args[0] == "--shell" or args[0] == "--script") then
    port = toNumber(args[1])
    if typeof(port) != "int" then printUsage(); return 2 end if
    expected = 2
    if args[0] == "--query" or args[0] == "--script" then expected = 3 end if
    if len(args) != expected then printUsage(); return 2 end if
    active = try(openTrusted(port))
    if typeof(active) == "error" then return printClientError(active) end if
    if args[0] == "--ping" then return runPing(active) end if
    if args[0] == "--query" then return runQuery(active, args[2]) end if
    if args[0] == "--shell" then return runShell(active) end if
    return runScript(active, args[2])
  end if

  if len(args) > 0 and (args[0] == "--auth-ping-prompt" or args[0] == "--auth-query-prompt" or args[0] == "--auth-shell-prompt" or args[0] == "--auth-script-prompt") then
    expected = 3
    if args[0] == "--auth-query-prompt" or args[0] == "--auth-script-prompt" then expected = 4 end if
    if len(args) != expected then printUsage(); return 2 end if
    port = toNumber(args[1])
    if typeof(port) != "int" then printUsage(); return 2 end if
    active = try(openPrompt("127.0.0.1", port, args[2]))
    if typeof(active) == "error" then return printClientError(active) end if
    if args[0] == "--auth-ping-prompt" then return runPing(active) end if
    if args[0] == "--auth-query-prompt" then return runQuery(active, args[3]) end if
    if args[0] == "--auth-shell-prompt" then return runShell(active) end if
    return runScript(active, args[3])
  end if

  if len(args) > 0 and (args[0] == "--secure-ping" or args[0] == "--secure-query" or args[0] == "--secure-shell" or args[0] == "--secure-script") then
    expected = 4
    if args[0] == "--secure-query" or args[0] == "--secure-script" then expected = 5 end if
    if len(args) != expected then printUsage(); return 2 end if
    port = toNumber(args[2])
    if typeof(port) != "int" then printUsage(); return 2 end if
    active = try(openPrompt(args[1], port, args[3]))
    if typeof(active) == "error" then return printClientError(active) end if
    if args[0] == "--secure-ping" then return runPing(active) end if
    if args[0] == "--secure-query" then return runQuery(active, args[4]) end if
    if args[0] == "--secure-shell" then return runShell(active) end if
    return runScript(active, args[4])
  end if

  if len(args) > 0 and (args[0] == "--tls-ping" or args[0] == "--tls-query" or args[0] == "--tls-shell" or args[0] == "--tls-script") then
    expected = 5
    if args[0] == "--tls-query" or args[0] == "--tls-script" then expected = 6 end if
    if len(args) != expected then printUsage(); return 2 end if
    port = toNumber(args[2])
    if typeof(port) != "int" then printUsage(); return 2 end if
    active = try(openTlsPrompt(args[1], port, args[3], args[4]))
    if typeof(active) == "error" then return printClientError(active) end if
    if args[0] == "--tls-ping" then return runPing(active) end if
    if args[0] == "--tls-query" then return runQuery(active, args[5]) end if
    if args[0] == "--tls-shell" then return runShell(active) end if
    return runScript(active, args[5])
  end if

  if len(args) > 0 and (args[0] == "--tls-pin-ping" or args[0] == "--tls-pin-query" or args[0] == "--tls-pin-shell" or args[0] == "--tls-pin-script") then
    expected = 6
    if args[0] == "--tls-pin-query" or args[0] == "--tls-pin-script" then expected = 7 end if
    if len(args) != expected then printUsage(); return 2 end if
    port = toNumber(args[2])
    if typeof(port) != "int" then printUsage(); return 2 end if
    active = try(openTlsPinnedPrompt(args[1], port, args[3], args[4], args[5]))
    if typeof(active) == "error" then return printClientError(active) end if
    if args[0] == "--tls-pin-ping" then return runPing(active) end if
    if args[0] == "--tls-pin-query" then return runQuery(active, args[6]) end if
    if args[0] == "--tls-pin-shell" then return runShell(active) end if
    return runScript(active, args[6])
  end if

  printUsage()
  return 2
end function
