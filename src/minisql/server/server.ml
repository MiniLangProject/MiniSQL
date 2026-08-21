package minisql.server.server

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.version as version
import minisql.server.listener as listener

// Implements m0 self test line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function m0SelfTestLine()
  return "MiniSQL server M0 self-test: SUCCESS"
end function

// Implements version line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function versionLine()
  return version.versionLine("server")
end function

// Serves one using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveOne(databasePath, port, maximumRequests)
  return listener.serveOne(databasePath, port, maximumRequests)
end function

// Serves authenticated one using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveAuthenticatedOne(databasePath, port, maximumRequests)
  return listener.serveAuthenticatedOne(databasePath, port, maximumRequests)
end function

// Serves concurrent using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

// Serves authenticated concurrent using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveAuthenticatedConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

// Serves standby concurrent using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveStandbyConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

// Serves secure address using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveSecureAddress(databasePath, address, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
end function

// Serves authenticated MiniSQL over native TLS 1.3 using a store or PFX certificate.
function serveTlsAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
  return listener.serveTlsConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
end function

// Serves native TLS with an explicit in-memory PFX password for controlled callers.
function serveTlsAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes)
  return listener.serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, void)
end function

// Serves bounded native TLS and publishes a readiness marker for integration tests.
function serveTlsAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
  return listener.serveTlsConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
end function

// Implements start for this module.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function start(configPath)
  return error(9001, "server.start: use serveAuthenticatedConcurrent or serveSecureAddress")
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.server"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M0"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
