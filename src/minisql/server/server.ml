//! Provides minisql server server facilities for this project.

package minisql.server.server

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.version as version
import minisql.server.listener as listener

/// Performs the m0SelfTestLine operation for the minisql server server module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function m0SelfTestLine()
  return "MiniSQL server M0 self-test: SUCCESS"
end function

/// Performs the versionLine operation for the minisql server server module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function versionLine()
  return version.versionLine("server")
end function

/// Serves one using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveOne(databasePath, port, maximumRequests)
  return listener.serveOne(databasePath, port, maximumRequests)
end function

/// Serves authenticated one using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveAuthenticatedOne(databasePath, port, maximumRequests)
  return listener.serveAuthenticatedOne(databasePath, port, maximumRequests)
end function

/// Serves concurrent using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

/// Serves a controller-fenced writable primary on loopback.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param leasePath Path associated with lease.
/// @param epoch epoch value consumed by this operation.
/// @param nodeId Identifier of node.
/// @param clockSkewMs clockSkewMs value consumed by this operation.
function serveConcurrentFenced(databasePath, port, maximumClients, maximumRequests, leasePath, epoch, nodeId, clockSkewMs)
  return listener.serveConcurrentLoopbackFenced(databasePath, port, maximumClients, maximumRequests, leasePath, epoch, nodeId, clockSkewMs)
end function

/// Serves trusted clients using the configured logical-lock wait timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

/// Serves trusted clients with all configured runtime durability thresholds.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

/// Serves trusted clients with all production runtime and hard result limits.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
/// @param maxStatementBytes maxStatementBytes value consumed by this operation.
/// @param maxFrameBytes maxFrameBytes value consumed by this operation.
/// @param maxResultRows maxResultRows value consumed by this operation.
/// @param maxResultBytes maxResultBytes value consumed by this operation.
/// @param idleTimeoutMs idleTimeoutMs value consumed by this operation.
/// @param processMemoryBytes processMemoryBytes value consumed by this operation.
/// @param temporaryStorageBytes temporaryStorageBytes value consumed by this operation.
/// @param slowQueryMs slowQueryMs value consumed by this operation.
function serveConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  return listener.serveConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
end function

/// Serves authenticated concurrent using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveAuthenticatedConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

/// Serves authenticated loopback clients using the configured lock wait timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveAuthenticatedConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveAuthenticatedConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

/// Serves standby concurrent using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveStandbyConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

/// Serves standby clients using the configured logical-lock wait timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveStandbyConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveStandbyConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
end function

/// Serves standby clients with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveStandbyConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveStandbyConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

/// Serves standby clients with all production runtime and hard result limits.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
/// @param maxStatementBytes maxStatementBytes value consumed by this operation.
/// @param maxFrameBytes maxFrameBytes value consumed by this operation.
/// @param maxResultRows maxResultRows value consumed by this operation.
/// @param maxResultBytes maxResultBytes value consumed by this operation.
/// @param idleTimeoutMs idleTimeoutMs value consumed by this operation.
/// @param processMemoryBytes processMemoryBytes value consumed by this operation.
/// @param temporaryStorageBytes temporaryStorageBytes value consumed by this operation.
/// @param slowQueryMs slowQueryMs value consumed by this operation.
function serveStandbyConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  return listener.serveStandbyConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
end function

/// Serves secure address using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveSecureAddress(databasePath, address, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
end function

/// Serves authenticated address clients using the configured lock wait timeout.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveSecureAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
  return listener.serveAuthenticatedConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
end function

/// Serves authenticated clients with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveSecureAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveAuthenticatedConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

/// Serves authenticated clients with all production runtime and hard result limits.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
/// @param maxStatementBytes maxStatementBytes value consumed by this operation.
/// @param maxFrameBytes maxFrameBytes value consumed by this operation.
/// @param maxResultRows maxResultRows value consumed by this operation.
/// @param maxResultBytes maxResultBytes value consumed by this operation.
/// @param idleTimeoutMs idleTimeoutMs value consumed by this operation.
/// @param processMemoryBytes processMemoryBytes value consumed by this operation.
/// @param temporaryStorageBytes temporaryStorageBytes value consumed by this operation.
/// @param slowQueryMs slowQueryMs value consumed by this operation.
function serveSecureAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  return listener.serveAuthenticatedConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
end function

/// Serves authenticated MiniSQL over native TLS 1.3 using a store or PFX certificate.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
function serveTlsAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
  return listener.serveTlsConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
end function

/// Serves native TLS clients using the configured logical-lock wait timeout.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveTlsAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
  return listener.serveTlsConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
end function

/// Serves native TLS clients with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveTlsAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return listener.serveTlsConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

/// Serves native TLS clients with all production runtime and hard result limits.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
/// @param maxStatementBytes maxStatementBytes value consumed by this operation.
/// @param maxFrameBytes maxFrameBytes value consumed by this operation.
/// @param maxResultRows maxResultRows value consumed by this operation.
/// @param maxResultBytes maxResultBytes value consumed by this operation.
/// @param idleTimeoutMs idleTimeoutMs value consumed by this operation.
/// @param processMemoryBytes processMemoryBytes value consumed by this operation.
/// @param temporaryStorageBytes temporaryStorageBytes value consumed by this operation.
/// @param slowQueryMs slowQueryMs value consumed by this operation.
function serveTlsAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  return listener.serveTlsConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
end function

/// Serves native TLS with an explicit in-memory PFX password for controlled callers.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
function serveTlsAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes)
  return listener.serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, void)
end function

/// Serves bounded native TLS and publishes a readiness marker for integration tests.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveTlsAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
  return listener.serveTlsConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
end function

/// Implements start for this module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param configPath Path associated with config.
function start(configPath)
  return error(9001, "server.start: use serveAuthenticatedConcurrent or serveSecureAddress")
end function

/// Performs the componentName operation for the minisql server server module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.server"
end function

/// Performs the targetMilestone operation for the minisql server server module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M0"
end function

/// Returns whether implemented satisfies the condition required by the minisql server server module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
