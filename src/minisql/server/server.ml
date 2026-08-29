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

// Serves trusted clients using the configured logical-lock wait timeout.
function serveConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

// Serves trusted clients with all configured runtime durability thresholds.
function serveConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Serves trusted clients with all production runtime and hard result limits.
function serveConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
  return listener.serveConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
end function

// Serves authenticated concurrent using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveAuthenticatedConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

// Serves authenticated loopback clients using the configured lock wait timeout.
function serveAuthenticatedConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveAuthenticatedConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

// Serves standby concurrent using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveStandbyConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

// Serves standby clients using the configured logical-lock wait timeout.
function serveStandbyConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveStandbyConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

// Serves standby clients with configured lock and WAL thresholds.
function serveStandbyConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveStandbyConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Serves standby clients with all production runtime and hard result limits.
function serveStandbyConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
  return listener.serveStandbyConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
end function

// Serves secure address using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function serveSecureAddress(databasePath, address, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
end function

// Serves authenticated address clients using the configured lock wait timeout.
function serveSecureAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveAuthenticatedConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
end function

// Serves authenticated clients with configured lock and WAL thresholds.
function serveSecureAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveAuthenticatedConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Serves authenticated clients with all production runtime and hard result limits.
function serveSecureAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
  return listener.serveAuthenticatedConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
end function

// Serves authenticated MiniSQL over native TLS 1.3 using a store or PFX certificate.
function serveTlsAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
  return listener.serveTlsConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
end function

// Serves native TLS clients using the configured logical-lock wait timeout.
function serveTlsAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
  return listener.serveTlsConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
end function

// Serves native TLS clients with configured lock and WAL thresholds.
function serveTlsAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveTlsConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

// Serves native TLS clients with all production runtime and hard result limits.
function serveTlsAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
  return listener.serveTlsConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
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
