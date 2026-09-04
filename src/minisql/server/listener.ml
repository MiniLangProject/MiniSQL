//! Provides minisql server listener facilities for this project.

package minisql.server.listener

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.threading as threading
import std.concurrent.thread_pool as thread_pool
import minisql.platform.file as file_api
import minisql.common.logger as logger
import minisql.platform.network as network
#if TARGET_OS == "windows"
import minisql.platform.tls_schannel as tls_schannel
#else
import minisql.platform.tls_openssl as tls_schannel
#endif
import minisql.platform.clock as clock
import minisql.protocol.connection as connection
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.server.session as session
import minisql.server.database_manager as database_manager

/// Defines the invalid argument constant used by the minisql server listener module.
const INVALID_ARGUMENT = 9001

/// Performs the fail operation for the minisql server listener module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "server.listener." + operation + ": " + message)
end function

/// Validates arguments using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateArguments(databasePath, maximumRequests, operation)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(operation, "databasePath must be non-empty") end if
  if typeof(maximumRequests) != "int" or maximumRequests < 0 or maximumRequests > 1000000 then return fail(operation, "maximumRequests is invalid; zero means unlimited") end if
  return true
end function

/// Serves listener mode using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param listener listener value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param secure secure value consumed by this operation.
function serveListenerMode(databasePath, listener, maximumRequests, secure)
  socketHandle = try(network.acceptTcp(listener))
  if typeof(socketHandle) == "error" then network.close(listener); return socketHandle end if
  peer = network.peerName(socketHandle)
  ignoredLog = logger.info("minisql.server.listener.serveListenerMode", "client connected from " + peer)
  ignoredTimeout = try(network.setTimeouts(socketHandle, 60000, 60000))
  client = connection.create(socketHandle)
  active = void
  if secure then
    active = try(session.openSecure(databasePath))
  else
    active = try(session.open(databasePath))
  end if
  if typeof(active) == "error" then connection.close(client); network.close(listener); return active end if
  handled = 0
  failure = void
  while (maximumRequests == 0 or handled < maximumRequests) and not active.closeRequested
    request = try(connection.receiveMessage(client))
    if typeof(request) == "error" then failure = request; break end if
    response = try(session.handleToConnection(active, request, client))
    if typeof(response) == "error" then failure = response; break end if
    sent = try(sendResponse(client, response))
    if typeof(sent) == "error" then failure = sent; break end if
    if session.transportReady(active) then session.activateTransport(active, client) end if
    handled = handled + 1
  end while
  closeSession = try(session.close(active))
  closeClient = try(connection.close(client))
  closeListener = try(network.close(listener))
  ignoredLog = logger.info("minisql.server.listener.serveListenerMode", "client disconnected from " + peer + " requests=" + handled)
  if failure is not void then ignoredLog = logger.errorLog("minisql.server.listener.serveListenerMode", "client worker failed peer=" + peer + " message=" + failure.message); return failure end if
  if typeof(closeSession) == "error" then return closeSession end if
  if typeof(closeClient) == "error" then return closeClient end if
  if typeof(closeListener) == "error" then return closeListener end if
  return handled
end function

/// Serves listener using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param listener listener value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveListener(databasePath, listener, maximumRequests)
  return serveListenerMode(databasePath, listener, maximumRequests, false)
end function

/// Serves secure listener using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
/// @param listener listener value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveSecureListener(databasePath, listener, maximumRequests)
  return serveListenerMode(databasePath, listener, maximumRequests, true)
end function

/// Serves one using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveOne(databasePath, port, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveOne")
  listener = network.listenLoopback(port, 8)
  return serveListener(databasePath, listener, maximumRequests)
end function

/// Serves authenticated one using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveAuthenticatedOne(databasePath, port, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedOne")
  listener = network.listenLoopback(port, 8)
  return serveSecureListener(databasePath, listener, maximumRequests)
end function

/// Implements publish ready for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param listener listener value consumed by this operation.
/// @param readyPath Path associated with ready.
/// @param operation operation value consumed by this operation.
function publishReady(listener, readyPath, operation)
  if typeof(readyPath) != "string" or len(readyPath) == 0 then return fail(operation, "readyPath must be non-empty") end if
  ready = try(file_api.createNewDurable(readyPath))
  if typeof(ready) == "error" then network.close(listener); return ready end if
  flushed = try(file_api.flush(ready))
  closed = try(file_api.close(ready))
  if typeof(flushed) == "error" then network.close(listener); return flushed end if
  if typeof(closed) == "error" then network.close(listener); return closed end if
  return true
end function

/// Serves one with ready file using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveOneWithReadyFile")
  // Bind before publishing readiness so an independent client cannot race the
  // listener startup. The marker is test-only and is created durably.
  listener = network.listenLoopback(port, 8)
  published = try(publishReady(listener, readyPath, "serveOneWithReadyFile"))
  if typeof(published) == "error" then return published end if
  return serveListener(databasePath, listener, maximumRequests)
end function

/// Serves authenticated one with ready file using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveAuthenticatedOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedOneWithReadyFile")
  listener = network.listenLoopback(port, 8)
  published = try(publishReady(listener, readyPath, "serveAuthenticatedOneWithReadyFile"))
  if typeof(published) == "error" then return published end if
  return serveSecureListener(databasePath, listener, maximumRequests)
end function


/// Owns one accepted connection and its attached session for the lifetime of a
/// worker-pool job. Only that worker mutates the slot.
struct ClientSlot
  /// Framed protocol connection used for request polling and response writes.
  client
  /// Database session attached to the listener's shared ManagedDatabase.
  activeSession
  /// Number of responses successfully sent for this client.
  handled
  /// Prevents duplicate session and socket cleanup.
  closed
  /// Request retained while its logical database lock is unavailable.
  pendingRequest
  /// Monotonic timestamp at which the pending lock wait began.
  waitStarted
  /// Monotonic timestamp used to enforce listener idle limits.
  lastActivity
  /// Human-readable remote endpoint captured before worker ownership transfer.
  peerEndpoint
end struct

/// Closes slot using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param slot slot value consumed by this operation.
function closeSlot(slot)
  if slot is not ClientSlot or slot.closed then return true end if
  if slot.activeSession is not void then
    ignoredAbort = try(session.abortForConcurrency(slot.activeSession))
    ignoredSession = try(session.close(slot.activeSession))
  end if
  if slot.client is not void then ignoredClient = try(connection.close(slot.client)) end if
  slot.pendingRequest = void
  slot.closed = true
  ignoredLog = logger.info("minisql.server.listener.closeSlot", "client disconnected from " + slot.peerEndpoint + " requests=" + slot.handled)
  return true
end function

/// Implements response error code for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param response response value consumed by this operation.
function responseErrorCode(response)
  if typeof(response) == "array" then
    if len(response) == 0 then return 0 end if
    response = response[0]
  end if
  if response.messageType != constants.TYPE_ERROR then return 0 end if
  decoded = try(messages.decodeResponse(response.payload))
  if typeof(decoded) == "error" then return 0 end if
  return decoded.errorCode
end function

/// Sends either an ordinary response or a bounded sequence of result frames.
/// @param client client value consumed by this operation.
/// @param response response value consumed by this operation.
function sendResponse(client, response)
  if typeof(response) != "array" then return connection.sendMessage(client, response) end if
  for each frame in response
    sent = try(connection.sendMessage(client, frame))
    if typeof(sent) == "error" then return sent end if
  end for
  return true
end function

/// Gives the SHUTDOWN caller one bounded opportunity to perform the protocol
/// CLOSE handshake before the listener drains all workers and closes sockets.
/// @param slot slot value consumed by this operation.
function acknowledgeShutdownClose(slot)
  readable = try(network.waitReadable(slot.client.socket, 1000))
  if typeof(readable) == "error" or not readable then return true end if
  polled = try(connection.pollMessage(slot.client))
  if typeof(polled) == "error" or polled is void or polled.closed then return true end if
  if polled.message.messageType != constants.TYPE_CLOSE then return true end if
  response = try(session.handle(slot.activeSession, polled.message))
  if typeof(response) == "error" then return response end if
  sent = try(sendResponse(slot.client, response))
  if typeof(sent) == "error" then return sent end if
  slot.handled = slot.handled + 1
  return true
end function

/// Creates an error for message for using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param request request value consumed by this operation.
/// @param code code value consumed by this operation.
/// @param text Text consumed by the operation.
function errorMessageFor(request, code, text)
  payload = messages.encodeResponse(messages.errorResponse(code, text))
  return messages.create(constants.TYPE_ERROR, 0, request.requestId, payload)
end function

/// Executes or retries one request without blocking the worker on a logical lock.
/// Returns a response, void while error 9007 remains retryable, or a propagated
/// error. Exceeding `lockWaitMs` counts as a statement deadline while retaining
/// wire-compatible logical-lock error 9032 and transaction rollback semantics.
/// @param slot slot value consumed by this operation.
/// @param request request value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function processRequest(slot, request, lockWaitMs)
  if slot.pendingRequest is not void then
    now = clock.monotonicMilliseconds()
    if now - slot.waitStarted >= lockWaitMs then
      session.abortForConcurrencyTimeout(slot.activeSession)
      slot.pendingRequest = void
      return errorMessageFor(request, 9032, "lock wait timeout; transaction rolled back")
    end if
    waiting = try(session.waitingForConcurrency(slot.activeSession))
    if typeof(waiting) == "error" then return waiting end if
    if waiting then return void end if
  end if
  response = try(session.handleToConnection(slot.activeSession, request, slot.client))
  if typeof(response) == "error" then return response end if
  code = responseErrorCode(response)
  if code == 9007 then
    now = clock.monotonicMilliseconds()
    if slot.pendingRequest is void then
      slot.pendingRequest = request
      slot.waitStarted = now
    end if
    if now - slot.waitStarted < lockWaitMs then return void end if
    session.abortForConcurrencyTimeout(slot.activeSession)
    slot.pendingRequest = void
    return errorMessageFor(request, 9032, "lock wait timeout; transaction rolled back")
  end if
  if code == 9031 then session.abortForConcurrency(slot.activeSession) end if
  slot.pendingRequest = void
  return response
end function

/// Native-threaded server state. All fields are protected by guard; snapshots
/// let the acceptor and workers make decisions without retaining the mutex.
/// Shares listener accounting between the acceptor and all worker jobs.
/// Every field is read or written only while `guard` is held; callers use a
/// snapshot so they never retain the mutex while doing socket or SQL work.
struct ConcurrentServerState
  /// Mutex protecting all following fields.
  guard
  /// Global successful-request limit; zero means unlimited.
  maximumRequests
  /// Count of requests whose responses were sent successfully.
  handled
  /// Reservations claimed by workers but not yet completed.
  inFlight
  /// Number of live connection-owning worker jobs.
  activeClients
  /// First fatal listener/worker error; later errors never overwrite it.
  failure
  /// Monotonic timestamp of the latest accepted/completed client activity.
  lastProgress
  /// Requests cooperative shutdown of the acceptor and all workers.
  stopping
end struct

/// Immutable argument bundle submitted to one thread-pool worker.
struct ConcurrentClientTask
  /// Connection/session pair exclusively owned by the worker.
  slot
  /// Shared, guard-protected server accounting.
  state
  /// Maximum logical-lock retry duration in milliseconds.
  lockWaitMs
  /// Shared inbound Schannel credential, or void for a non-TLS listener.
  tlsCredential
end struct

/// Creates concurrent server state using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param maximumRequests maximumRequests value consumed by this operation.
function createConcurrentServerState(maximumRequests)
  return ConcurrentServerState(threading.Lock.new(), maximumRequests, 0, 0, 0, void, clock.monotonicMilliseconds(), false)
end function

/// Copies all shared counters and stop state while holding `guard` briefly.
/// Returns a positional snapshot; on lock failure, the failure slot contains an error.
/// @param state Mutable state inspected or updated by the operation.
function concurrentStateSnapshot(state)
  if not state.guard.acquire() then return [0, 0, 0, fail("concurrentStateSnapshot", "state lock is unavailable"), 0, true] end if
  snapshot = [state.handled, state.inFlight, state.activeClients, state.failure, state.lastProgress, state.stopping]
  state.guard.release()
  return snapshot
end function

/// Implements concurrent should stop for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
function concurrentShouldStop(state)
  snapshot = concurrentStateSnapshot(state)
  if snapshot[5] or typeof(snapshot[3]) == "error" then return true end if
  return state.maximumRequests > 0 and snapshot[0] >= state.maximumRequests
end function

/// Implements concurrent register client for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function concurrentRegisterClient(state)
  if not state.guard.acquire() then return false end if
  state.activeClients = state.activeClients + 1
  state.lastProgress = clock.monotonicMilliseconds()
  state.guard.release()
  return true
end function

/// Implements concurrent client done for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function concurrentClientDone(state)
  if not state.guard.acquire() then return false end if
  if state.activeClients > 0 then state.activeClients = state.activeClients - 1 end if
  state.lastProgress = clock.monotonicMilliseconds()
  state.guard.release()
  return true
end function

/// Atomically reserves capacity under the global request limit.
/// Returns false after shutdown/failure or when handled plus in-flight work has
/// reached the limit; a true result must be paired with `concurrentFinishRequest`.
/// @param state Mutable state inspected or updated by the operation.
function concurrentReserveRequest(state)
  if not state.guard.acquire() then return false end if
  allowed = not state.stopping and typeof(state.failure) != "error"
  if allowed and state.maximumRequests > 0 and state.handled + state.inFlight >= state.maximumRequests then allowed = false end if
  if allowed then state.inFlight = state.inFlight + 1 end if
  state.guard.release()
  return allowed
end function

/// Completes one reservation, optionally adding it to the successful count.
/// Updates the progress clock and returns false only when the guard is unavailable.
/// @param state Mutable state inspected or updated by the operation.
/// @param successful successful value consumed by this operation.
function concurrentFinishRequest(state, successful)
  if not state.guard.acquire() then return false end if
  if state.inFlight > 0 then state.inFlight = state.inFlight - 1 end if
  if successful then state.handled = state.handled + 1 end if
  state.lastProgress = clock.monotonicMilliseconds()
  state.guard.release()
  return true
end function

/// Implements concurrent set failure for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
/// @param failure failure value consumed by this operation.
function concurrentSetFailure(state, failure)
  if not state.guard.acquire() then return false end if
  if typeof(state.failure) != "error" then state.failure = failure end if
  state.stopping = true
  state.lastProgress = clock.monotonicMilliseconds()
  state.guard.release()
  ignoredLog = logger.errorLog("minisql.server.listener.concurrentSetFailure", "concurrent server failure: " + failure.message)
  return true
end function

/// Implements concurrent request stop for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param state Mutable state inspected or updated by the operation.
function concurrentRequestStop(state)
  if not state.guard.acquire() then return false end if
  state.stopping = true
  state.guard.release()
  return true
end function

/// Disposes completed pool jobs and returns the still-running handles.
/// The returned list is the sole ownership set retained by the accept loop.
/// @param jobs jobs value consumed by this operation.
function reapConcurrentJobs(jobs)
  active = []
  for each job in jobs
    if job.IsDone() then job.Dispose() else active = active + [job] end if
  end for
  return active
end function

/// One long-lived pool job owns exactly one client connection. Slow or idle
/// peers therefore never stall accepts or unrelated sessions. SQL engine calls
/// enter the per-database reader/writer gate in executor.executor.
/// Runs the nonblocking receive/execute/send loop for one connection-owning job.
/// Request reservations make the global limit race-free; pending lock conflicts
/// are retried cooperatively. Always closes the slot and unregisters the client.
/// @param task task value consumed by this operation.
function serveConcurrentClient(task)
  slot = task.slot
  claimed = false
  if task.tlsCredential is not void then
    blockingTls = try(network.setNonBlocking(slot.client.socket, false))
    if typeof(blockingTls) == "error" then closeSlot(slot); concurrentClientDone(task.state); return 0 end if
    ignoredTimeouts = try(network.setTimeouts(slot.client.socket, 15000, 15000))
    tlsContext = try(tls_schannel.acceptServer(slot.client.socket, task.tlsCredential))
    if typeof(tlsContext) == "error" then
      ignoredLog = logger.warning("minisql.server.listener.serveConcurrentClient", "TLS handshake rejected peer=" + slot.peerEndpoint + " message=" + tlsContext.message)
      closeSlot(slot)
      concurrentClientDone(task.state)
      return 0
    end if
    enabled = try(connection.enableTls(slot.client, tlsContext))
    if typeof(enabled) == "error" then
      ignoredContext = try(tls_schannel.closeContext(tlsContext))
      closeSlot(slot)
      concurrentClientDone(task.state)
      return 0
    end if
    nonBlockingTls = try(connection.makeNonBlocking(slot.client))
    if typeof(nonBlockingTls) == "error" then
      closeSlot(slot)
      concurrentClientDone(task.state)
      return 0
    end if
    ignoredTlsLog = logger.info("minisql.server.listener.serveConcurrentClient", "TLS established peer=" + slot.peerEndpoint + " protocol=TLS1.3 cipher=TLS_AES_256_GCM_SHA384 group=X25519")
  end if
  while not concurrentShouldStop(task.state)
    request = slot.pendingRequest
    if request is void then
      polled = try(connection.pollMessage(slot.client))
      if typeof(polled) == "error" then break end if
      if polled is void then
        expired = try(session.isExpired(slot.activeSession))
        if typeof(expired) == "error" then concurrentSetFailure(task.state, expired); break end if
        if expired then break end if
        // WSAPoll wakes as soon as another frame arrives. This avoids the
        // roughly 15.6 ms Windows timer quantum imposed by threadSleep(1).
        readable = try(network.waitReadable(slot.client.socket, 100))
        if typeof(readable) == "error" then break end if
        continue
      end if
      if polled.closed then break end if
      if not concurrentReserveRequest(task.state) then break end if
      claimed = true
      request = polled.message
      slot.lastActivity = clock.monotonicMilliseconds()
    end if

    response = try(processRequest(slot, request, task.lockWaitMs))
    if typeof(response) == "error" then
      if claimed then concurrentFinishRequest(task.state, false); claimed = false end if
      // A reset/broken client socket is scoped to this connection. Database,
      // executor, and listener failures remain fatal to the server process.
      if response.code != network.NETWORK_ERROR then concurrentSetFailure(task.state, response) end if
      break
    end if
    if response is void then
      threadSleep(1)
      continue
    end if

    sent = try(sendResponse(slot.client, response))
    if typeof(sent) == "error" then
      if claimed then concurrentFinishRequest(task.state, false); claimed = false end if
      break
    end if
    // A request may legitimately run longer than the idle limit. Refresh the
    // session clock after its response is delivered so execution time is never
    // mistaken for client inactivity on the following poll iteration.
    touched = try(session.touch(slot.activeSession))
    if typeof(touched) == "error" then
      if claimed then concurrentFinishRequest(task.state, false); claimed = false end if
      concurrentSetFailure(task.state, touched)
      break
    end if
    transportReady = try(session.transportReady(slot.activeSession))
    if typeof(transportReady) == "error" then
      if claimed then concurrentFinishRequest(task.state, false); claimed = false end if
      concurrentSetFailure(task.state, transportReady)
      break
    end if
    if transportReady then
      activated = try(session.activateTransport(slot.activeSession, slot.client))
      if typeof(activated) == "error" then
        if claimed then concurrentFinishRequest(task.state, false); claimed = false end if
        concurrentSetFailure(task.state, activated)
        break
      end if
    end if
    slot.handled = slot.handled + 1
    slot.lastActivity = clock.monotonicMilliseconds()
    concurrentFinishRequest(task.state, true)
    claimed = false
    // Publish the stop only after the SHUTDOWN response reached its caller.
    // The acceptor therefore cannot close the socket before acknowledgement.
    if database_manager.isShutdownRequested(slot.activeSession.engine.database) then
      acknowledgedClose = try(acknowledgeShutdownClose(slot))
      if typeof(acknowledgedClose) == "error" then concurrentSetFailure(task.state, acknowledgedClose) end if
      concurrentRequestStop(task.state)
      break
    end if
    if slot.activeSession.closeRequested then break end if
  end while

  if claimed then concurrentFinishRequest(task.state, false) end if
  closeSlot(slot)
  concurrentClientDone(task.state)
  return slot.handled
end function

/// Opens and completes recovery/index preparation before a TCP listener becomes
/// visible, preventing early clients from timing out against a bound-but-unready port.
/// @param databasePath Path associated with database.
/// @param standby standby value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
function openPreparedDatabaseWithCheckpoint(databasePath, standby, checkpointWalBytes)
  return openPreparedDatabaseWithRuntime(databasePath, standby, checkpointWalBytes, 268435456, 67108864)
end function

/// Opens and prepares a shared database using storage and query-memory budgets.
/// @param databasePath Path associated with database.
/// @param standby standby value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function openPreparedDatabaseWithRuntime(databasePath, standby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  shared = void
  if standby then
    shared = try(database_manager.openStandbyWithRuntime(databasePath, checkpointWalBytes, bufferPoolBytes))
  else
    shared = try(database_manager.openWithRuntime(databasePath, checkpointWalBytes, bufferPoolBytes))
  end if
  if typeof(shared) == "error" then return shared end if
  configuredMemory = try(database_manager.setQueryMemoryLimit(shared, queryMemoryBytes))
  if typeof(configuredMemory) == "error" then database_manager.close(shared); return configuredMemory end if
  prepared = try(session.prepareAttachedDatabase(shared))
  if typeof(prepared) == "error" then database_manager.close(shared); return prepared end if
  return shared
end function

/// Opens, prepares, and applies the hard per-connection operational limits.
/// @param databasePath Path associated with database.
/// @param standby standby value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
/// @param maxStatementBytes maxStatementBytes value consumed by this operation.
/// @param maxFrameBytes maxFrameBytes value consumed by this operation.
/// @param maxResultRows maxResultRows value consumed by this operation.
/// @param maxResultBytes maxResultBytes value consumed by this operation.
/// @param idleTimeoutMs idleTimeoutMs value consumed by this operation.
/// @param queryTimeoutMs queryTimeoutMs value consumed by this operation.
/// @param processMemoryBytes processMemoryBytes value consumed by this operation.
/// @param temporaryStorageBytes temporaryStorageBytes value consumed by this operation.
/// @param slowQueryMs slowQueryMs value consumed by this operation.
function openPreparedDatabaseWithOperationalLimits(databasePath, standby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, queryTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  shared = try(openPreparedDatabaseWithRuntime(databasePath, standby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes))
  if typeof(shared) == "error" then return shared end if
  configured = try(database_manager.configureOperationalLimits(shared, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs))
  if typeof(configured) == "error" then database_manager.close(shared); return configured end if
  production = try(database_manager.configureProductionControls(shared, queryTimeoutMs, maxResultBytes, processMemoryBytes, temporaryStorageBytes, slowQueryMs))
  if typeof(production) == "error" then database_manager.close(shared); return production end if
  return shared
end function

/// Preserves the legacy server API with the documented 64 MiB WAL threshold.
/// @param databasePath Path associated with database.
/// @param standby standby value consumed by this operation.
function openPreparedDatabase(databasePath, standby)
  return openPreparedDatabaseWithCheckpoint(databasePath, standby, 67108864)
end function

/// Accepts clients into a bounded native thread pool backed by one already
/// prepared shared database. This function owns both database and listener.
/// @param databasePath Path associated with database.
/// @param listener listener value consumed by this operation.
/// @param shared shared value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param secure secure value consumed by this operation.
/// @param idleLimitMs idleLimitMs value consumed by this operation.
/// @param standby standby value consumed by this operation.
/// @param tlsCredential tlsCredential value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, secure, idleLimitMs, standby, tlsCredential, lockWaitMs)
  if typeof(maximumClients) != "int" or maximumClients < 1 or maximumClients > 128 then database_manager.close(shared); network.close(listener); return fail("serveConcurrent", "maximumClients is invalid") end if
  if typeof(idleLimitMs) != "int" or idleLimitMs < 0 or idleLimitMs > 600000 or (idleLimitMs > 0 and idleLimitMs < 100) then database_manager.close(shared); network.close(listener); return fail("serveConcurrent", "idleLimitMs is invalid; zero means unlimited") end if
  if typeof(lockWaitMs) != "int" or lockWaitMs <= 0 then database_manager.close(shared); network.close(listener); return fail("serveConcurrent", "lockWaitMs must be positive") end if
  ignoredLog = logger.info("minisql.server.listener.serveConcurrentListenerMode", "database listener ready path=" + databasePath + " maxClients=" + maximumClients + " secure=" + secure + " standby=" + standby)
  nonBlocking = try(network.setNonBlocking(listener, true))
  if typeof(nonBlocking) == "error" then database_manager.close(shared); network.close(listener); return nonBlocking end if
  state = createConcurrentServerState(maximumRequests)
  pool = try(thread_pool.ThreadPool.withQueueCapacity(maximumClients, maximumClients))
  if typeof(pool) == "error" then
    state.guard.close()
    database_manager.close(shared)
    network.close(listener)
    return pool
  end if
  jobs = []

  while not concurrentShouldStop(state)
    jobs = reapConcurrentJobs(jobs)
    snapshot = concurrentStateSnapshot(state)
    if idleLimitMs > 0 and clock.monotonicMilliseconds() - snapshot[4] >= idleLimitMs then break end if
    if snapshot[2] >= maximumClients then
      threadSleep(1)
      continue
    end if

    socketHandle = try(network.tryAccept(listener))
    if typeof(socketHandle) == "error" then concurrentSetFailure(state, socketHandle); break end if
    if socketHandle is void then
      readable = try(network.waitReadable(listener, 100))
      if typeof(readable) == "error" then concurrentSetFailure(state, readable); break end if
      continue
    end if

    peer = network.peerName(socketHandle)
    ignoredLog = logger.info("minisql.server.listener.serveConcurrentListenerMode", "client connected from " + peer)

    client = try(connection.create(socketHandle))
    if typeof(client) == "error" then ignoredSocket = try(network.close(socketHandle)); concurrentSetFailure(state, client); break end if
    if tlsCredential is void then
      madeNonBlocking = try(connection.makeNonBlocking(client))
      if typeof(madeNonBlocking) == "error" then ignoredClient = try(connection.close(client)); concurrentSetFailure(state, madeNonBlocking); break end if
    end if
    active = void
    if secure then active = try(session.openSecureAttached(shared)) else active = try(session.openAttached(shared)) end if
    if typeof(active) == "error" then
      ignoredClient = try(connection.close(client))
      concurrentSetFailure(state, active)
      break
    end if
    registeredPeer = try(database_manager.registerSessionPeer(shared, session.sessionIdentifier(active), peer, tlsCredential is not void, active.authenticated))
    if typeof(registeredPeer) == "error" then
      ignoredSession = try(session.close(active))
      ignoredClient = try(connection.close(client))
      concurrentSetFailure(state, registeredPeer)
      break
    end if
    now = clock.monotonicMilliseconds()
    slot = ClientSlot(client, active, 0, false, void, 0, now, peer)
    task = ConcurrentClientTask(slot, state, lockWaitMs, tlsCredential)
    concurrentRegisterClient(state)
    job = pool.Submit(serveConcurrentClient, task)
    if job is void then
      closeSlot(slot)
      concurrentClientDone(state)
      concurrentSetFailure(state, fail("serveConcurrent", "thread-pool queue rejected a client"))
      break
    end if
    jobs = jobs + [job]
  end while

  concurrentRequestStop(state)
  pool.Shutdown()
  pool.AwaitTermination()
  for each job in jobs
    job.Dispose()
  end for
  pool.Dispose()
  finalState = concurrentStateSnapshot(state)
  handled = finalState[0]
  failure = finalState[3]
  closedDatabase = try(database_manager.close(shared))
  closedListener = try(network.close(listener))
  state.guard.close()
  if failure is not void then return failure end if
  if typeof(closedDatabase) == "error" then return closedDatabase end if
  if typeof(closedListener) == "error" then return closedListener end if
  if maximumRequests > 0 and handled < maximumRequests then return fail("serveConcurrent", "threaded server idle timeout before request budget was reached") end if
  ignoredLog = logger.info("minisql.server.listener.serveConcurrentListenerMode", "database listener stopped requests=" + handled)
  return handled
end function

/// Preserves the lower-level API for callers that already created a listener.
/// Public address/loopback entry points prepare before binding and should be preferred.
/// @param databasePath Path associated with database.
/// @param listener listener value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param secure secure value consumed by this operation.
/// @param idleLimitMs idleLimitMs value consumed by this operation.
/// @param standby standby value consumed by this operation.
/// @param tlsCredential tlsCredential value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, secure, idleLimitMs, standby, tlsCredential, lockWaitMs)
  shared = try(openPreparedDatabase(databasePath, standby))
  if typeof(shared) == "error" then network.close(listener); return shared end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, secure, idleLimitMs, standby, tlsCredential, lockWaitMs)
end function

/// Serves concurrent loopback using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopback")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, false, void, 5000)
end function

/// Serves a writable loopback primary whose authority is continuously proven by
/// the controller-owned lease and persistent database epoch.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param leasePath Path associated with lease.
/// @param epoch epoch value consumed by this operation.
/// @param nodeId Identifier of node.
/// @param clockSkewMs clockSkewMs value consumed by this operation.
function serveConcurrentLoopbackFenced(databasePath, port, maximumClients, maximumRequests, leasePath, epoch, nodeId, clockSkewMs)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopbackFenced")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  fenced = try(database_manager.configureWriteFencing(shared, leasePath, epoch, nodeId, clockSkewMs))
  if typeof(fenced) == "error" then database_manager.close(shared); return fenced end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, false, void, 5000)
end function

/// Serves trusted loopback clients with a configured logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopbackWithLockWait")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, false, void, lockWaitMs)
end function

/// Serves trusted loopback clients with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopbackWithRuntime")
  shared = try(openPreparedDatabaseWithRuntime(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, false, void, lockWaitMs)
end function

/// Serves trusted clients with storage, memory, protocol, result, and idle limits.
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
function serveConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopbackWithOperationalLimits")
  shared = try(openPreparedDatabaseWithOperationalLimits(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, lockWaitMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, 0, false, void, lockWaitMs)
end function

/// Serves authenticated concurrent loopback using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentLoopback")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, 5000)
end function

/// Serves authenticated loopback clients with a configured logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveAuthenticatedConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentLoopbackWithLockWait")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, lockWaitMs)
end function

/// Serves concurrent with ready file using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param readyPath Path associated with ready.
/// @param secure secure value consumed by this operation.
function serveConcurrentWithReadyFile(databasePath, port, maximumClients, maximumRequests, readyPath, secure)
  validateArguments(databasePath, maximumRequests, "serveConcurrentWithReadyFile")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  published = try(publishReady(listener, readyPath, "serveConcurrentWithReadyFile"))
  if typeof(published) == "error" then database_manager.close(shared); return published end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, secure, idleLimit, false, void, 5000)
end function

/// Serves standby concurrent loopback using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveStandbyConcurrentLoopback")
  shared = try(openPreparedDatabase(databasePath, true))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, true, void, 5000)
end function

/// Serves a standby listener with a configured logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveStandbyConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
  validateArguments(databasePath, maximumRequests, "serveStandbyConcurrentLoopbackWithLockWait")
  shared = try(openPreparedDatabase(databasePath, true))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, true, void, lockWaitMs)
end function

/// Serves a standby with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveStandbyConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  validateArguments(databasePath, maximumRequests, "serveStandbyConcurrentLoopbackWithRuntime")
  shared = try(openPreparedDatabaseWithRuntime(databasePath, true, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, idleLimit, true, void, lockWaitMs)
end function

/// Serves a standby with the complete configured operational limit set.
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
function serveStandbyConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  validateArguments(databasePath, maximumRequests, "serveStandbyConcurrentLoopbackWithOperationalLimits")
  shared = try(openPreparedDatabaseWithOperationalLimits(databasePath, true, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, lockWaitMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenLoopback(port, maximumClients))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, false, 0, true, void, lockWaitMs)
end function

/// Serves authenticated concurrent address using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
function serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddress")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, 5000)
end function

/// Serves authenticated address clients with a configured logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveAuthenticatedConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddressWithLockWait")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, lockWaitMs)
end function

/// Serves authenticated address clients with configured lock and WAL thresholds.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveAuthenticatedConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddressWithRuntime")
  shared = try(openPreparedDatabaseWithRuntime(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, lockWaitMs)
end function

/// Serves authenticated clients with the complete configured operational limit set.
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
function serveAuthenticatedConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddressWithOperationalLimits")
  shared = try(openPreparedDatabaseWithOperationalLimits(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, lockWaitMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, 0, false, void, lockWaitMs)
end function

/// Serves authenticated concurrent address with ready file using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveAuthenticatedConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddressWithReadyFile")
  shared = try(openPreparedDatabase(databasePath, false))
  if typeof(shared) == "error" then return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); return listener end if
  published = try(publishReady(listener, readyPath, "serveAuthenticatedConcurrentAddressWithReadyFile"))
  if typeof(published) == "error" then database_manager.close(shared); return published end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, void, 5000)
end function

/// Serves concurrent authenticated sessions over native TLS 1.3 and Schannel.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param readyPath Path associated with ready.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
/// @param checkpointWalBytes checkpointWalBytes value consumed by this operation.
/// @param bufferPoolBytes bufferPoolBytes value consumed by this operation.
/// @param queryMemoryBytes queryMemoryBytes value consumed by this operation.
function serveTlsConcurrentAddressWithPasswordRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  validateArguments(databasePath, maximumRequests, "serveTlsConcurrentAddressWithPassword")
  if typeof(certificateReference) != "string" or len(certificateReference) == 0 then return fail("serveTlsConcurrentAddressWithPassword", "certificateReference must be non-empty") end if
  credential = try(tls_schannel.acquireServerCredentialWithPassword(certificateReference, passwordBytes))
  if typeof(credential) == "error" then return credential end if
  shared = try(openPreparedDatabaseWithRuntime(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes))
  if typeof(shared) == "error" then ignoredCredential = try(tls_schannel.closeCredential(credential)); return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); ignoredCredential = try(tls_schannel.closeCredential(credential)); return listener end if
  if readyPath is not void then
    published = try(publishReady(listener, readyPath, "serveTlsConcurrentAddressWithPassword"))
    if typeof(published) == "error" then database_manager.close(shared); ignoredCredential = try(tls_schannel.closeCredential(credential)); return published end if
  end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  result = try(servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, idleLimit, false, credential, lockWaitMs))
  closedCredential = try(tls_schannel.closeCredential(credential))
  if typeof(result) == "error" then return result end if
  if typeof(closedCredential) == "error" then return closedCredential end if
  return result
end function

/// Serves TLS with the legacy 64 MiB automatic checkpoint threshold.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param readyPath Path associated with ready.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveTlsConcurrentAddressWithPasswordAndLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, lockWaitMs)
  return serveTlsConcurrentAddressWithPasswordRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, lockWaitMs, 67108864, 268435456, 67108864)
end function

/// Serves TLS with configured lock and WAL thresholds.
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
function serveTlsConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
  return serveTlsConcurrentAddressWithPasswordRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, void, void, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
end function

/// Serves native TLS with the complete configured operational limit set.
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
function serveTlsConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
  validateArguments(databasePath, maximumRequests, "serveTlsConcurrentAddressWithOperationalLimits")
  credential = try(tls_schannel.acquireServerCredentialWithPassword(certificateReference, void))
  if typeof(credential) == "error" then return credential end if
  shared = try(openPreparedDatabaseWithOperationalLimits(databasePath, false, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, lockWaitMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs))
  if typeof(shared) == "error" then tls_schannel.closeCredential(credential); return shared end if
  listener = try(network.listenAddress(address, port, maximumClients, true))
  if typeof(listener) == "error" then database_manager.close(shared); tls_schannel.closeCredential(credential); return listener end if
  result = try(servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, true, 0, false, credential, lockWaitMs))
  closedCredential = try(tls_schannel.closeCredential(credential))
  if typeof(result) == "error" then return result end if
  if typeof(closedCredential) == "error" then return closedCredential end if
  return result
end function

/// Serves TLS with the legacy five-second logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath)
  return serveTlsConcurrentAddressWithPasswordAndLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, 5000)
end function

/// Serves native TLS using a store or PFX certificate and environment PFX secret.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
function serveTlsConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
  return serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, void, void)
end function

/// Serves native TLS with a configured logical-lock timeout.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param lockWaitMs lockWaitMs value consumed by this operation.
function serveTlsConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
  return serveTlsConcurrentAddressWithPasswordAndLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, void, void, lockWaitMs)
end function

/// Publishes a readiness marker only after the native TLS credential and listener exist.
/// @param databasePath Path associated with database.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param maximumClients maximumClients value consumed by this operation.
/// @param maximumRequests maximumRequests value consumed by this operation.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param readyPath Path associated with ready.
function serveTlsConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
  return serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, void, readyPath)
end function

/// Performs the componentName operation for the minisql server listener module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.listener"
end function

/// Performs the targetMilestone operation for the minisql server listener module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql server listener module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
