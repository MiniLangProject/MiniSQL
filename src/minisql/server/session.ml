//! Provides minisql server session facilities for this project.

package minisql.server.session

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.client.formatter as formatter
import minisql.common.uuid as uuid
import minisql.common.diagnostics as diagnostics
import minisql.common.logger as logger
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.protocol.constants as constants
import minisql.protocol.connection as protocol_connection
import minisql.protocol.messages as messages
import minisql.server.database_manager as database_manager
import minisql.sql.parser as parser

/// Defines the invalid argument constant used by the minisql server session module.
const INVALID_ARGUMENT = 9001
/// Defines the closed handle constant used by the minisql server session module.
const CLOSED_HANDLE = 9008
/// Defines the unsupported sql constant used by the minisql server session module.
const UNSUPPORTED_SQL = 9025
/// Defines the authentication failed constant used by the minisql server session module.
const AUTHENTICATION_FAILED = 9027
/// Defines the io failure constant used by the minisql server session module.
const IO_FAILURE = 9005
/// Defines the authentication required constant used by the minisql server session module.
const AUTHENTICATION_REQUIRED = 9028
/// Defines the auth handshake timeout ms constant used by the minisql server session module.
const AUTH_HANDSHAKE_TIMEOUT_MS = 30000
/// Legacy public default retained for embedded callers and compatibility tests.
const SESSION_IDLE_TIMEOUT_MS = 300000
/// A server cursor retains at most this many arbitrarily wide SQL rows before
const STREAM_RESULT_ROWS = 64

/// Groups the session state and preserves the field relationships documented below.
struct Session
  /// Stores the engine associated with this value.
  engine
  /// Indicates whether the closed condition is active.
  closed
  /// Stores the close requested associated with this value.
  closeRequested
  /// Indicates whether the secure condition is active.
  secure
  /// Indicates whether the authenticated condition is active.
  authenticated
  /// Indicates whether the pending username condition is active.
  pendingUsername
  /// Indicates whether the pending principal identifier condition is active.
  pendingPrincipalId
  /// Indicates whether the pending nonce condition is active.
  pendingNonce
  /// Indicates whether the pending verifier condition is active.
  pendingVerifier
  /// Stores the attempts associated with this value.
  attempts
  /// Stores the transport send key associated with this value.
  transportSendKey
  /// Stores the transport receive key associated with this value.
  transportReceiveKey
  /// Stores the transport pending associated with this value.
  transportPending
  /// Stores the created at associated with this value.
  createdAt
  /// Stores the last activity associated with this value.
  lastActivity
  /// Prevents lock-wait retries from double-counting one logical statement.
  statementTracked
  /// Monotonic timestamp at which the tracked statement began.
  statementStartedAt
  /// Complete encoded response bytes accumulated by the tracked statement.
  statementResultBytes
  /// True only after the peer explicitly negotiates structured results-v2 metadata.
  extendedResults
end struct

/// State owned by one synchronously streamed CALL while its executor runs.
struct RoutineStream
  /// Server session owning accounting, diagnostics, and resource limits.
  session
  /// Original request, including negotiated metadata flag and request identifier.
  request
  /// Connection receiving frames with transport backpressure.
  connection
  /// Number of row frames already sent; prevents unsafe whole-CALL retries.
  frames
  /// Accumulated emitted row count across all result sets.
  rows
  /// True when the latest logical row result has completed successfully.
  resultComplete
  /// True after an I/O failure makes a terminal response unsafe.
  transportFailed
end struct

/// Performs the fail operation for the minisql server session module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "server.session." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the session condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isSession(value)
  return value is Session
end function

/// Creates session using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param engine engine value consumed by this operation.
/// @param secure secure value consumed by this operation.
/// @param authenticated authenticated value consumed by this operation.
function createSession(engine, secure, authenticated)
  configured = try(executor.setQueryMemoryLimit(engine, database_manager.queryMemoryLimit(engine.database)))
  if typeof(configured) == "error" then return configured end if
  registered = try(database_manager.registerSessionPeer(engine.database, executor.sessionIdentifier(engine), "embedded", false, authenticated))
  if typeof(registered) == "error" then return registered end if
  now = clock.monotonicMilliseconds()
  return Session(engine, false, false, secure, authenticated, void, 0, void, void, 0, void, void, false, now, now, false, 0, 0, false)
end function

/// Opens open for the minisql server session module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
function open(databasePath)
  return createSession(executor.open(databasePath), false, true)
end function

/// Opens secure using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param databasePath Path associated with database.
function openSecure(databasePath)
  return createSession(executor.open(databasePath), true, false)
end function

/// Opens attached using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param database database value consumed by this operation.
function openAttached(database)
  engine = try(executor.attach(database))
  if typeof(engine) == "error" then return engine end if
  return createSession(engine, false, true)
end function

/// Completes process-local database preparation before the listener advertises
/// readiness, so the first client's HELLO does not pay the full index audit cost.
/// @param database database value consumed by this operation.
function prepareAttachedDatabase(database)
  return executor.prepareDatabase(database)
end function

/// Opens secure attached using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param database database value consumed by this operation.
function openSecureAttached(database)
  engine = try(executor.attach(database))
  if typeof(engine) == "error" then return engine end if
  return createSession(engine, true, false)
end function

/// Implements touch for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
function touch(session)
  validateOpen(session, "touch")
  session.lastActivity = clock.monotonicMilliseconds()
  return true
end function

/// Returns whether the supplied value satisfies the expired condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param session session value consumed by this operation.
function isExpired(session)
  validateOpen(session, "isExpired")
  now = clock.monotonicMilliseconds()
  if session.secure and not session.authenticated and now - session.createdAt >= AUTH_HANDSHAKE_TIMEOUT_MS then return true end if
  return now - session.lastActivity >= database_manager.idleTimeoutMs(session.engine.database)
end function

/// Implements idle timeout milliseconds for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function idleTimeoutMilliseconds()
  return SESSION_IDLE_TIMEOUT_MS
end function

/// Begins metrics tracking exactly once across cooperative lock-wait retries.
/// @param session session value consumed by this operation.
/// @param sqlText sqlText value consumed by this operation.
function beginTrackedStatement(session, sqlText)
  if session.statementTracked then return true end if
  admitted = try(executor.beginQueryControl(session.engine))
  if typeof(admitted) == "error" then return admitted end if
  started = try(database_manager.beginOperationalStatement(session.engine.database, executor.sessionIdentifier(session.engine), session.engine.principalId, sqlText))
  if typeof(started) == "error" then executor.finishQueryControl(session.engine); return started end if
  session.statementTracked = true
  session.statementStartedAt = clock.monotonicMilliseconds()
  session.statementResultBytes = 0
  return true
end function

/// Completes metrics, latency, budget and slow-query tracking.
/// @param session session value consumed by this operation.
/// @param success success value consumed by this operation.
/// @param rowCount Number of row to process.
/// @param errorCode errorCode value consumed by this operation.
function finishTrackedStatementWithCode(session, success, rowCount, errorCode)
  if not session.statementTracked then return true end if
  elapsed = clock.monotonicMilliseconds() - session.statementStartedAt
  slow = try(database_manager.recordStatementDiagnostics(session.engine.database, elapsed, session.statementResultBytes, errorCode))
  if slow == true then ignoredSlow = logger.warning("minisql.server.session.slowQuery", "session=" + executor.sessionIdentifier(session.engine) + " durationMs=" + elapsed + " rows=" + rowCount + " resultBytes=" + session.statementResultBytes + " success=" + success) end if
  executor.finishQueryControl(session.engine)
  finished = try(database_manager.finishOperationalStatement(session.engine.database, executor.sessionIdentifier(session.engine), success, rowCount))
  session.statementTracked = false
  session.statementStartedAt = 0
  session.statementResultBytes = 0
  return finished
end function

/// Compatibility helper for ordinary outcomes without a production-control code.
/// @param session session value consumed by this operation.
/// @param success success value consumed by this operation.
/// @param rowCount Number of row to process.
function finishTrackedStatement(session, success, rowCount)
  return finishTrackedStatementWithCode(session, success, rowCount, 0)
end function

/// Validates open for the minisql server session workflow.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateOpen(session, operation)
  if session is not Session then return fail(INVALID_ARGUMENT, operation, "session must be Session") end if
  if session.closed then return fail(CLOSED_HANDLE, operation, "session is closed") end if
  return true
end function

/// Implements response message for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param request request value consumed by this operation.
/// @param response response value consumed by this operation.
function responseMessage(request, response)
  payload = messages.encodeResponse(response)
  flags = 0
  if (request.flags & constants.FLAG_METADATA) != 0 then payload = messages.encodeResponseExtended(response); flags = constants.FLAG_METADATA end if
  kind = constants.TYPE_RESPONSE
  if response.status == constants.STATUS_ERROR then kind = constants.TYPE_ERROR end if
  if response.resultStart then flags = flags | constants.FLAG_RESULT_START end if
  return messages.create(kind, flags, request.requestId, payload)
end function

/// Encodes bounded result batches and marks every non-final frame for the client.
/// @param request request value consumed by this operation.
/// @param responses responses value consumed by this operation.
function responseMessages(request, responses)
  if typeof(responses) != "array" or len(responses) == 0 then return fail(INVALID_ARGUMENT, "responseMessages", "responses must be non-empty") end if
  output = []
  for index = 0 to len(responses) - 1
    payload = messages.encodeResponse(responses[index])
    kind = constants.TYPE_RESPONSE
    if responses[index].status == constants.STATUS_ERROR then kind = constants.TYPE_ERROR end if
    flags = 0
    if (request.flags & constants.FLAG_METADATA) != 0 then payload = messages.encodeResponseExtended(responses[index]); flags = constants.FLAG_METADATA end if
    if index < len(responses) - 1 then flags = flags | constants.FLAG_MORE end if
    if responses[index].resultStart then flags = flags | constants.FLAG_RESULT_START end if
    output = output + [messages.create(kind, flags, request.requestId, payload)]
  end for
  return output
end function

/// Adds structured conditions and committed CALL outputs to a terminal response.
function statementMetadata(session, response, nativeError)
  extra = messages.normalizedMetadata(response)
  if nativeError is not void then
    diagnostic = executor.statementDiagnostic(session.engine, nativeError)
    extra.sqlState = diagnostic.sqlstate
  end if
  for each warning in executor.statementWarnings(session.engine)
    extra.warnings = extra.warnings + [messages.Condition(warning.sqlstate, warning.errno, warning.message)]
  end for
  if nativeError is void and response.status == constants.STATUS_COMMAND and response.command == "CALL" then
    for each output in executor.routineOutputParameters(session.engine)
      value = output[2]
      text = ""
      scale = 0
      if len(output) > 3 then scale = output[3] end if
      if not value.isNull then text = formatter.outputValueText(value, scale) end if
      extra.outputs = extra.outputs + [messages.OutputParameter(output[0], output[1], value.typeKind, value.isNull, text)]
    end for
  end if
  response.metadata = extra
  return response
end function

/// Builds an SQL error without overloading native retry codes with SQLSTATE data.
function sqlErrorResponse(session, nativeError, replaceArea = false)
  executor.recordStatementError(session.engine, nativeError, replaceArea)
  return statementMetadata(session, messages.errorResponse(nativeError.code, nativeError.message), nativeError)
end function

/// Implements authentication error for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param request request value consumed by this operation.
function authenticationError(request)
  return responseMessage(request, messages.errorResponse(AUTHENTICATION_FAILED, "authentication failed"))
end function

/// Implements clear pending for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
function clearPending(session)
  if typeof(session.pendingVerifier) == "bytes" then fillBytes(session.pendingVerifier, 0, len(session.pendingVerifier), 0) end if
  if typeof(session.pendingNonce) == "bytes" then fillBytes(session.pendingNonce, 0, len(session.pendingNonce), 0) end if
  session.pendingUsername = void
  session.pendingPrincipalId = 0
  session.pendingNonce = void
  session.pendingVerifier = void
  return true
end function

/// Implements fake authentication material for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
/// @param username username value consumed by this operation.
function fakeAuthenticationMaterial(session, username)
  seed = session.engine.database.catalogHandle.metadata.databaseId
  salt = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-SALT-1|" + username), 1, uuid.PASSWORD_SALT_BYTES)
  saltedPassword = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-VERIFIER-1|" + username), 1, uuid.PASSWORD_VERIFIER_BYTES)
  verifier = uuid.scramCredential(saltedPassword)
  uuid.wipeSecret(saltedPassword)
  return [uuid.DEFAULT_PBKDF2_ITERATIONS, salt, verifier]
end function

/// Implements authentication backoff for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
function authenticationBackoff(session)
  delay = 50 * (session.attempts + 1)
  if delay > 250 then delay = 250 end if
  clock.sleepMilliseconds(delay)
  return true
end function

/// Handles auth begin using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
function handleAuthBegin(session, request)
  if not session.secure or session.authenticated then return authenticationError(request) end if
  clearPending(session)
  username = try(messages.decodeAuthBegin(request.payload))
  if typeof(username) == "error" then return authenticationError(request) end if
  principal = catalog.authenticationMaterial(session.engine.database.catalogHandle, username)
  fake = try(fakeAuthenticationMaterial(session, username))
  if typeof(fake) == "error" then return authenticationError(request) end if
  iterations = fake[0]
  salt = fake[1]
  verifier = fake[2]
  principalId = 0
  if principal is not void then
    uuid.wipeSecret(salt)
    uuid.wipeSecret(verifier)
    iterations = principal.iterations
    salt = bytes(principal.salt)
    verifier = bytes(principal.verifier)
    principalId = principal.principalId
  end if
  nonce = try(uuid.randomBytes(uuid.AUTH_NONCE_BYTES))
  if typeof(nonce) == "error" then fillBytes(salt, 0, len(salt), 0); fillBytes(verifier, 0, len(verifier), 0); return authenticationError(request) end if
  session.pendingUsername = username
  session.pendingPrincipalId = principalId
  session.pendingNonce = bytes(nonce)
  session.pendingVerifier = bytes(verifier)
  scheme = try(uuid.authenticationScheme(verifier))
  if typeof(scheme) == "error" then fillBytes(salt, 0, len(salt), 0); fillBytes(verifier, 0, len(verifier), 0); fillBytes(nonce, 0, len(nonce), 0); clearPending(session); return authenticationError(request) end if
  response = try(messages.authChallenge(request.requestId, iterations, salt, nonce, scheme))
  fillBytes(salt, 0, len(salt), 0)
  fillBytes(verifier, 0, len(verifier), 0)
  fillBytes(nonce, 0, len(nonce), 0)
  if typeof(response) == "error" then clearPending(session); return authenticationError(request) end if
  return response
end function

/// Handles auth proof using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
function handleAuthProof(session, request)
  if not session.secure or session.authenticated or session.pendingUsername is void then return authenticationError(request) end if
  if typeof(request.payload) != "bytes" or len(request.payload) != uuid.PASSWORD_VERIFIER_BYTES then clearPending(session); return authenticationError(request) end if
  scheme = try(uuid.authenticationScheme(session.pendingVerifier))
  if typeof(scheme) == "error" then clearPending(session); return authenticationError(request) end if
  proofValid = false
  if scheme == uuid.AUTH_SCHEME_SCRAM_SHA256 then
    proofValid = try(uuid.verifyScramClientProof(session.pendingVerifier, session.pendingNonce, session.pendingUsername, request.payload))
  else
    expected = try(uuid.authProof(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "client"))
    if typeof(expected) == "error" then clearPending(session); return authenticationError(request) end if
    proofValid = uuid.constantTimeEquals(expected, request.payload)
    fillBytes(expected, 0, len(expected), 0)
  end if
  fillBytes(request.payload, 0, len(request.payload), 0)
  connectAllowed = false
  if session.pendingPrincipalId > 0 then
    connectAllowed = catalog.isSuperuser(session.engine.database.catalogHandle, session.pendingPrincipalId) or catalog.hasPrivilege(session.engine.database.catalogHandle, session.pendingPrincipalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, false)
  end if
  if proofValid and connectAllowed then
    sessionSecret = bytes(session.pendingVerifier)
    serverProof = void
    if scheme == uuid.AUTH_SCHEME_SCRAM_SHA256 then
      sessionSecret = try(uuid.scramSessionSecretFromCredential(session.pendingVerifier, session.pendingNonce, session.pendingUsername))
      if typeof(sessionSecret) == "error" then clearPending(session); return authenticationError(request) end if
      serverProof = try(uuid.scramServerProofFromCredential(session.pendingVerifier, session.pendingNonce, session.pendingUsername))
    else
      serverProof = try(uuid.authProof(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "server"))
    end if
    if typeof(serverProof) == "error" then uuid.wipeSecret(sessionSecret); clearPending(session); return authenticationError(request) end if
    sendKey = try(uuid.transportKey(sessionSecret, session.pendingNonce, session.pendingUsername, "server-to-client"))
    if typeof(sendKey) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sessionSecret); clearPending(session); return authenticationError(request) end if
    receiveKey = try(uuid.transportKey(sessionSecret, session.pendingNonce, session.pendingUsername, "client-to-server"))
    uuid.wipeSecret(sessionSecret)
    if typeof(receiveKey) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sendKey); clearPending(session); return authenticationError(request) end if
    principalSet = try(executor.setPrincipal(session.engine, session.pendingPrincipalId))
    if typeof(principalSet) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); clearPending(session); return authenticationError(request) end if
    operationalPrincipal = try(database_manager.setOperationalPrincipal(session.engine.database, executor.sessionIdentifier(session.engine), session.pendingPrincipalId))
    if typeof(operationalPrincipal) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); clearPending(session); return authenticationError(request) end if
    audited = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGIN, diagnostics.AUDIT_SUCCESS, executor.sessionIdentifier(session.engine), session.pendingPrincipalId, "login succeeded"))
    if typeof(audited) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); clearPending(session); return authenticationError(request) end if
    session.authenticated = true
    ignoredLog = logger.info("minisql.server.session.handleAuthProof", "authenticated session=" + executor.sessionIdentifier(session.engine) + " user=" + session.pendingUsername)
    session.transportSendKey = sendKey
    session.transportReceiveKey = receiveKey
    session.transportPending = true
    response = messages.authOk(request.requestId, serverProof)
    fillBytes(serverProof, 0, len(serverProof), 0)
    clearPending(session)
    return response
  end if
  ignoredAudit = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGIN, diagnostics.AUDIT_FAILURE, executor.sessionIdentifier(session.engine), session.pendingPrincipalId, "login failed"))
  ignoredLog = logger.warning("minisql.server.session.handleAuthProof", "authentication failed session=" + executor.sessionIdentifier(session.engine) + " user=" + session.pendingUsername)
  authenticationBackoff(session)
  session.attempts = session.attempts + 1
  clearPending(session)
  if session.attempts >= 3 then session.closeRequested = true end if
  return authenticationError(request)
end function

/// Implements transport ready for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
function transportReady(session)
  validateOpen(session, "transportReady")
  return session.transportPending
end function

/// Implements session identifier for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
function sessionIdentifier(session)
  validateOpen(session, "sessionIdentifier")
  return executor.sessionIdentifier(session.engine)
end function

/// Implements abort for concurrency unlocked for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
/// @param errorCode errorCode value consumed by this operation.
function abortForConcurrencyUnlockedWithCode(session, errorCode)
  validateOpen(session, "abortForConcurrency")
  result = try(executor.abortForConcurrency(session.engine))
  finishTrackedStatementWithCode(session, false, 0, errorCode)
  return result
end function

/// Aborts an ordinary lock conflict without assigning a terminal control code.
/// @param session session value consumed by this operation.
function abortForConcurrencyUnlocked(session)
  return abortForConcurrencyUnlockedWithCode(session, 0)
end function

/// Implements abort for concurrency for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
function abortForConcurrency(session)
  validateOpen(session, "abortForConcurrency")
  if session.engine.ownsDatabase then return abortForConcurrencyUnlocked(session) end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(abortForConcurrencyUnlocked(session))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

/// Aborts a logical lock wait at the absolute statement deadline while keeping
/// the wire-compatible lock-timeout response code in the listener.
/// @param session session value consumed by this operation.
function abortForConcurrencyTimeout(session)
  validateOpen(session, "abortForConcurrencyTimeout")
  if session.engine.ownsDatabase then return abortForConcurrencyUnlockedWithCode(session, 9036) end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(abortForConcurrencyUnlockedWithCode(session, 9036))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

/// Implements activate transport for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param session session value consumed by this operation.
/// @param connection connection value consumed by this operation.
function activateTransport(session, connection)
  validateOpen(session, "activateTransport")
  if not session.transportPending then return true end if
  protocol_connection.enableSecure(connection, session.transportSendKey, session.transportReceiveKey)
  uuid.wipeSecret(session.transportSendKey)
  uuid.wipeSecret(session.transportReceiveKey)
  session.transportSendKey = void
  session.transportReceiveKey = void
  session.transportPending = false
  return true
end function

/// Returns whether this session still has a logical lock blocker. The check is
/// side-effect free and lets the listener suspend a request without executing it
/// repeatedly while another explicit transaction owns the writer lock.
/// @param session session value consumed by this operation.
function waitingForConcurrency(session)
  validateOpen(session, "waitingForConcurrency")
  return database_manager.isLockWaiting(session.engine.database, executor.sessionIdentifier(session.engine))
end function

/// Handles query using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
function handleQuery(session, request)
  if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
  if len(request.payload) > database_manager.maxStatementBytes(session.engine.database) then return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "query exceeds configured maxStatementBytes")) end if
  sqlText = decode(request.payload)
  if typeof(sqlText) != "string" then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "query payload is not valid UTF-8")) end if
  tracked = try(beginTrackedStatement(session, sqlText))
  if typeof(tracked) == "error" then return responseMessage(request, messages.errorResponse(tracked.code, tracked.message)) end if
  sessionId = executor.sessionIdentifier(session.engine)
  if not logger.binlog("minisql.server.session.handleQuery session=" + sessionId, sqlText) then
    ignoredLog = logger.errorLog("minisql.server.session.handleQuery", "binlog persistence failed; statement rejected session=" + sessionId)
    finishTrackedStatement(session, false, 0)
    return responseMessage(request, messages.errorResponse(IO_FAILURE, "SQL binlog persistence failed; statement was not executed"))
  end if
  ignoredLog = logger.debug("minisql.server.session.handleQuery", "received SQL statement session=" + sessionId + " bytes=" + len(request.payload))
  parsed = try(parser.parseSql(sqlText))
  if typeof(parsed) == "error" then ignoredLog = logger.warning("minisql.server.session.handleQuery", "SQL parse failed session=" + sessionId + " code=" + parsed.code); finishTrackedStatement(session, false, 0); return responseMessage(request, sqlErrorResponse(session, parsed, true)) end if
  if len(parsed) != 1 then finishTrackedStatement(session, false, 0); return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "one SQL statement per request is required")) end if
  return executeParsedQuery(session, request, parsed[0])
end function

/// Counts all rows exposed by a CALL, including nested result collections.
function resultRowCount(result)
  if result.kind == executor.RESULT_ROWS then return len(result.rows) end if
  if result.kind != executor.RESULT_MULTIPLE then return 0 end if
  total = 0
  for each child in result.rows
    total = total + resultRowCount(child)
  end for
  return total
end function

/// Executes a parsed statement, preserving CALL result boundaries and response limits.
/// Shared by materialized queries and the streaming SELECT fallback.
/// @param session Session owning the engine and resource budget.
/// @param request Request whose identifier is repeated in every result frame.
/// @param statement Parsed SQL statement.
function executeParsedQuery(session, request, statement)
  sessionId = executor.sessionIdentifier(session.engine)
  // The executor centrally selects the shared-reader or exclusive-writer path.
  result = try(executor.executeStatement(session.engine, statement))
  if typeof(result) == "error" then
    completed = executor.failedRoutineResults(session.engine)
    retryableLock = result.code == 9007 and len(completed) == 0 and not executor.isApplicationError(session.engine, result.code) and not executor.routineStarted(session.engine)
    if retryableLock then
      ignoredLog = logger.debug("minisql.server.session.handleQuery", "SQL waiting for logical lock session=" + sessionId)
    else
      ignoredLog = logger.errorLog("minisql.server.session.handleQuery", "SQL execution failed session=" + sessionId + " code=" + result.code + " message=" + result.message)
    end if
    failure = sqlErrorResponse(session, result)
    if result.code == 9007 and not retryableLock then
      ignoredWait = try(database_manager.cancelLockWait(session.engine.database, sessionId))
    end if
    if len(completed) == 0 then
      if not retryableLock then finishTrackedStatementWithCode(session, false, 0, result.code) end if
      return responseMessage(request, failure)
    end if
    // Completed SELECT results remain observable when a later routine statement
    // fails. The error is its own terminal result, never a failed row batch.
    partial = executor.QueryResult(executor.RESULT_MULTIPLE, "CALL", [], completed, 0, "")
    if resultRowCount(partial) > database_manager.maxResultRows(session.engine.database) then finishTrackedStatementWithCode(session, false, 0, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultRows")) end if
    converted = try(formatter.responsesFromResult(partial))
    if typeof(converted) == "error" then finishTrackedStatementWithCode(session, false, 0, converted.code); return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
    failure.resultStart = true
    framed = responseMessages(request, converted + [failure])
    for each frame in framed
      if len(frame.payload) > database_manager.maxFrameBytes(session.engine.database) then finishTrackedStatementWithCode(session, false, 0, INVALID_ARGUMENT); return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "response exceeds configured maxFrameBytes")) end if
      session.statementResultBytes = session.statementResultBytes + constants.HEADER_BYTES + len(frame.payload)
      if session.statementResultBytes > database_manager.maxResultBytes(session.engine.database) then finishTrackedStatementWithCode(session, false, 0, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultBytes")) end if
    end for
    finishTrackedStatementWithCode(session, false, 0, result.code)
    return framed
  end if
  resultRows = resultRowCount(result)
  if resultRows > database_manager.maxResultRows(session.engine.database) then
    finishTrackedStatementWithCode(session, false, 0, 9037)
    return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultRows"))
  end if
  converted = try(formatter.responsesFromResult(result))
  if typeof(converted) == "error" then finishTrackedStatement(session, false, 0); return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
  converted[len(converted) - 1] = statementMetadata(session, converted[len(converted) - 1], void)
  ignoredLog = logger.info("minisql.server.session.handleQuery", "SQL completed session=" + sessionId + " command=" + converted[0].command + " rows=" + result.affectedRows + " frames=" + len(converted))
  framed = responseMessages(request, converted)
  for each frame in framed
    if len(frame.payload) > database_manager.maxFrameBytes(session.engine.database) then finishTrackedStatement(session, false, 0); return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "response exceeds configured maxFrameBytes")) end if
    session.statementResultBytes = session.statementResultBytes + constants.HEADER_BYTES + len(frame.payload)
    if session.statementResultBytes > database_manager.maxResultBytes(session.engine.database) then finishTrackedStatementWithCode(session, false, 0, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultBytes")) end if
  end for
  finishTrackedStatement(session, true, result.affectedRows)
  if len(framed) == 1 then return framed[0] end if
  return framed
end function

/// Writes one routine batch immediately; a void batch marks a completed result.
/// Errors propagate to the executor so no further routine statements can run.
function streamRoutineResult(context, result, resultStart)
  if result is void then context.resultComplete = true; return true end if
  if resultStart then context.resultComplete = false end if
  context.rows = context.rows + resultRowCount(result)
  session = context.session
  if context.rows > database_manager.maxResultRows(session.engine.database) then return fail(9037, "streamRoutineResult", "result exceeds configured maxResultRows") end if
  responses = formatter.responsesFromResult(result)
  first = true
  for each response in responses
    response.resultStart = first and resultStart
    frame = responseMessage(context.request, response)
    frame.flags = frame.flags | constants.FLAG_MORE
    if len(frame.payload) > database_manager.maxFrameBytes(session.engine.database) then return fail(INVALID_ARGUMENT, "streamRoutineResult", "response exceeds configured maxFrameBytes") end if
    session.statementResultBytes = session.statementResultBytes + constants.HEADER_BYTES + len(frame.payload)
    if session.statementResultBytes > database_manager.maxResultBytes(session.engine.database) then return fail(9037, "streamRoutineResult", "result exceeds configured maxResultBytes") end if
    sent = try(protocol_connection.sendMessage(context.connection, frame))
    if typeof(sent) == "error" then context.transportFailed = true; return sent end if
    context.frames = context.frames + 1
    first = false
  end for
  return true
end function

/// Executes CALL/EXECUTE with bounded row callbacks and a final command/error.
/// Ordinary statements retain their existing response contract through this fallback.
function executeParsedQueryStreaming(session, request, statement, connection)
  context = RoutineStream(session, request, connection, 0, 0, true, false)
  result = try(executor.executeStatementStreaming(session.engine, statement, streamRoutineResult, context))
  if typeof(result) == "error" then
    application = executor.isApplicationError(session.engine, result.code)
    retryableLock = result.code == 9007 and not application and context.frames == 0 and not executor.routineStarted(session.engine)
    if result.code == 9007 and not retryableLock then ignoredWait = try(database_manager.cancelLockWait(session.engine.database, executor.sessionIdentifier(session.engine))) end if
    response = sqlErrorResponse(session, result)
    if not retryableLock then finishTrackedStatementWithCode(session, false, context.rows, result.code) end if
    if context.transportFailed then return result end if
    if context.frames == 0 then return responseMessage(request, response) end if
    response.resultStart = context.resultComplete
    frame = responseMessage(request, response)
    sent = try(protocol_connection.sendMessage(connection, frame))
    if result.code == 9031 and not application then ignoredAbort = try(abortForConcurrency(session)) end if
    if typeof(sent) == "error" then return sent end if
    return []
  end if
  remainingRows = resultRowCount(result)
  if context.rows + remainingRows > database_manager.maxResultRows(session.engine.database) then
    failure = error(9037, "result exceeds configured maxResultRows")
    finishTrackedStatementWithCode(session, false, context.rows, failure.code)
    response = sqlErrorResponse(session, failure)
    response.resultStart = context.frames > 0
    return responseMessage(request, response)
  end if
  responses = formatter.responsesFromResult(result)
  if context.frames > 0 then responses[0].resultStart = true end if
  responses[len(responses) - 1] = statementMetadata(session, responses[len(responses) - 1], void)
  frames = responseMessages(request, responses)
  for each frame in frames
    if len(frame.payload) > database_manager.maxFrameBytes(session.engine.database) then finishTrackedStatementWithCode(session, false, context.rows, INVALID_ARGUMENT); return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "response exceeds configured maxFrameBytes")) end if
    session.statementResultBytes = session.statementResultBytes + constants.HEADER_BYTES + len(frame.payload)
    if session.statementResultBytes > database_manager.maxResultBytes(session.engine.database) then finishTrackedStatementWithCode(session, false, context.rows, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultBytes")) end if
  end for
  finishTrackedStatement(session, true, result.affectedRows)
  if context.frames == 0 then
    if len(frames) == 1 then return frames[0] end if
    return frames
  end if
  for each frame in frames
    sent = try(protocol_connection.sendMessage(connection, frame))
    if typeof(sent) == "error" then return sent end if
  end for
  return []
end function

/// Streams an eligible non-blocking SELECT directly to one connection. One
/// protocol frame plus one look-ahead frame are retained, so both server and
/// cursor-aware client memory remain bounded while FLAG_MORE stays exact.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
/// @param connection connection value consumed by this operation.
function handleQueryStreaming(session, request, connection)
  if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
  if len(request.payload) > database_manager.maxStatementBytes(session.engine.database) then return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "query exceeds configured maxStatementBytes")) end if
  sqlText = decode(request.payload)
  if typeof(sqlText) != "string" then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "query payload is not valid UTF-8")) end if
  tracked = try(beginTrackedStatement(session, sqlText))
  if typeof(tracked) == "error" then return responseMessage(request, messages.errorResponse(tracked.code, tracked.message)) end if
  sessionId = executor.sessionIdentifier(session.engine)
  if not logger.binlog("minisql.server.session.handleQueryStreaming session=" + sessionId, sqlText) then
    ignoredLog = logger.errorLog("minisql.server.session.handleQueryStreaming", "binlog persistence failed; statement rejected session=" + sessionId)
    finishTrackedStatement(session, false, 0)
    return responseMessage(request, messages.errorResponse(IO_FAILURE, "SQL binlog persistence failed; statement was not executed"))
  end if
  parsed = try(parser.parseSql(sqlText))
  if typeof(parsed) == "error" then finishTrackedStatement(session, false, 0); return responseMessage(request, sqlErrorResponse(session, parsed, true)) end if
  if len(parsed) != 1 then finishTrackedStatement(session, false, 0); return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "one SQL statement per request is required")) end if
  cursor = try(executor.openSelectCursor(session.engine, parsed[0]))
  if typeof(cursor) == "error" then if cursor.code != 9007 or executor.isApplicationError(session.engine, cursor.code) then finishTrackedStatementWithCode(session, false, 0, cursor.code) end if; return responseMessage(request, sqlErrorResponse(session, cursor, true)) end if
  if cursor is void then return executeParsedQueryStreaming(session, request, parsed[0], connection) end if

  pending = void
  frameCount = 0
  rowCount = 0
  while true
    batch = try(executor.nextSelectBatch(cursor, STREAM_RESULT_ROWS))
    if typeof(batch) == "error" then
      executor.closeSelectCursor(cursor)
      if pending is not void then
        pending.flags = pending.flags | constants.FLAG_MORE
        sentPending = try(protocol_connection.sendMessage(connection, pending))
        if typeof(sentPending) == "error" then return sentPending end if
      end if
      failure = responseMessage(request, sqlErrorResponse(session, batch))
      sentFailure = try(protocol_connection.sendMessage(connection, failure))
      finishTrackedStatementWithCode(session, false, rowCount, batch.code)
      if typeof(sentFailure) == "error" then return sentFailure end if
      return []
    end if
    if batch is void then break end if
    rowCount = rowCount + len(batch.rows)
    if rowCount > database_manager.maxResultRows(session.engine.database) then executor.closeSelectCursor(cursor); finishTrackedStatementWithCode(session, false, rowCount, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultRows")) end if
    converted = try(formatter.responsesFromResult(batch))
    if typeof(converted) == "error" then executor.closeSelectCursor(cursor); finishTrackedStatement(session, false, rowCount); return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
    for each response in converted
      frame = responseMessage(request, response)
      if len(frame.payload) > database_manager.maxFrameBytes(session.engine.database) then executor.closeSelectCursor(cursor); finishTrackedStatement(session, false, rowCount); return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "response exceeds configured maxFrameBytes")) end if
      session.statementResultBytes = session.statementResultBytes + constants.HEADER_BYTES + len(frame.payload)
      if session.statementResultBytes > database_manager.maxResultBytes(session.engine.database) then executor.closeSelectCursor(cursor); finishTrackedStatementWithCode(session, false, rowCount, 9037); return responseMessage(request, messages.errorResponse(9037, "result exceeds configured maxResultBytes")) end if
      if pending is not void then
        pending.flags = pending.flags | constants.FLAG_MORE
        sent = try(protocol_connection.sendMessage(connection, pending))
        if typeof(sent) == "error" then executor.closeSelectCursor(cursor); return sent end if
        frameCount = frameCount + 1
      end if
      pending = frame
    end for
  end while
  if pending is void then pending = responseMessage(request, messages.rowResponse(cursor.bound.itemNames, [])) end if
  finalResponse = messages.decodeResponse(pending.payload)
  finalResponse = statementMetadata(session, finalResponse, void)
  pending = responseMessage(request, finalResponse)
  sentFinal = try(protocol_connection.sendMessage(connection, pending))
  if typeof(sentFinal) == "error" then return sentFinal end if
  frameCount = frameCount + 1
  ignoredLog = logger.info("minisql.server.session.handleQueryStreaming", "SQL streamed session=" + sessionId + " rows=" + rowCount + " frames=" + frameCount)
  finishTrackedStatement(session, true, rowCount)
  return []
end function

/// Handles a request and, for eligible SELECTs, writes response batches directly
/// to the supplied protocol connection. An empty array means delivery completed.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
/// @param connection connection value consumed by this operation.
function handleToConnection(session, request, connection)
  validateOpen(session, "handleToConnection")
  if messages.isMessage(request) and (request.flags & constants.FLAG_METADATA) != 0 and not session.extendedResults then request.flags = request.flags & (~constants.FLAG_METADATA); return responseMessage(request, messages.errorResponse(INVALID_ARGUMENT, "results-v2 must be negotiated before use")) end if
  if messages.isMessage(request) and request.messageType == constants.TYPE_QUERY then return handleQueryStreaming(session, request, connection) end if
  return handle(session, request)
end function

/// Handles unlocked using the supplied inputs.
/// Returns the computed value or operation status.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
function handleUnlocked(session, request)
  validateOpen(session, "handle")
  if isExpired(session) then session.closeRequested = true; return responseMessage(request, messages.errorResponse(AUTHENTICATION_FAILED, "session expired")) end if
  session.lastActivity = clock.monotonicMilliseconds()
  if not messages.isMessage(request) then return fail(INVALID_ARGUMENT, "handle", "request must be Message") end if
  if request.messageType == constants.TYPE_HELLO then
    // Publish the server-assigned identifier so standards-based clients can
    // cancel this session through an independent administrative connection.
    // The semicolon-delimited suffix is backward compatible: legacy clients
    // treat the HELLO message as informational text.
    message = "MiniSQL protocol 1; session=" + executor.sessionIdentifier(session.engine)
    session.extendedResults = decode(request.payload) == "MiniSQL/1; capabilities=results-v2"
    if session.extendedResults then message = message + "; capabilities=results-v2" end if
    if session.secure and not session.authenticated then message = message + "; authentication required" end if
    return responseMessage(request, messages.commandResponse("HELLO", 0, message))
  end if
  if request.messageType == constants.TYPE_PING then return messages.create(constants.TYPE_PONG, 0, request.requestId, bytes(0)) end if
  if request.messageType == constants.TYPE_CLOSE then
    session.closeRequested = true
    return responseMessage(request, messages.commandResponse("CLOSE", 0, "session closing"))
  end if
  if request.messageType == constants.TYPE_CANCEL then
    if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
    if not executor.hasDatabaseAdmin(session.engine) then return responseMessage(request, messages.errorResponse(9029, "DATABASE ADMIN privilege is required")) end if
    targetSessionId = try(messages.decodeCancelRequest(request.payload))
    if typeof(targetSessionId) == "error" then return responseMessage(request, messages.errorResponse(targetSessionId.code, targetSessionId.message)) end if
    cancelled = try(database_manager.requestSessionCancellation(session.engine.database, targetSessionId))
    if typeof(cancelled) == "error" then return responseMessage(request, messages.errorResponse(cancelled.code, cancelled.message)) end if
    ignoredCancelLog = logger.info("minisql.server.session.handleCancel", "requester=" + executor.sessionIdentifier(session.engine) + " target=" + targetSessionId)
    return responseMessage(request, messages.commandResponse("CANCEL", 0, "cancellation requested for session " + targetSessionId))
  end if
  if request.messageType == constants.TYPE_AUTH_BEGIN then return handleAuthBegin(session, request) end if
  if request.messageType == constants.TYPE_AUTH_PROOF then return handleAuthProof(session, request) end if
  if request.messageType == constants.TYPE_QUERY then return handleQuery(session, request) end if
  return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "unsupported request type"))
end function

/// Handles handle using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
/// @param request request value consumed by this operation.
function handle(session, request)
  validateOpen(session, "handle")
  if session.engine.ownsDatabase then return handleUnlocked(session, request) end if
  // Frame decoding, simple protocol control messages and SQL parsing do not
  // touch shared database state and therefore stay fully concurrent.
  if messages.isMessage(request) and (request.messageType == constants.TYPE_HELLO or request.messageType == constants.TYPE_PING or request.messageType == constants.TYPE_CLOSE or request.messageType == constants.TYPE_QUERY or request.messageType == constants.TYPE_CANCEL) then
    return handleUnlocked(session, request)
  end if
  // Authentication reads immutable credential metadata and mutates only this
  // session plus the append-only audit stream. A shared gate keeps it coherent
  // with DCL writers while allowing a privileged control connection to
  // authenticate and cancel a concurrently executing reader.
  if messages.isMessage(request) and (request.messageType == constants.TYPE_AUTH_BEGIN or request.messageType == constants.TYPE_AUTH_PROOF) then
    enteredRead = try(database_manager.enterReadExecution(session.engine.database))
    if typeof(enteredRead) == "error" then return enteredRead end if
    authResult = try(handleUnlocked(session, request))
    releasedRead = try(database_manager.leaveReadExecution(session.engine.database))
    if typeof(releasedRead) == "error" then return releasedRead end if
    return authResult
  end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(handleUnlocked(session, request))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

/// Closes unlocked using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state as documented by the operation name.
/// @param session session value consumed by this operation.
function closeUnlocked(session)
  validateOpen(session, "close")
  clearPending(session)
  if typeof(session.transportSendKey) == "bytes" then uuid.wipeSecret(session.transportSendKey) end if
  if typeof(session.transportReceiveKey) == "bytes" then uuid.wipeSecret(session.transportReceiveKey) end if
  session.transportSendKey = void
  session.transportReceiveKey = void
  session.transportPending = false
  if session.authenticated then ignoredAudit = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGOUT, diagnostics.AUDIT_SUCCESS, executor.sessionIdentifier(session.engine), session.engine.principalId, "session closed")) end if
  finishTrackedStatement(session, false, 0)
  ignoredLog = logger.info("minisql.server.session.close", "session closed id=" + executor.sessionIdentifier(session.engine))
  executor.close(session.engine)
  session.closed = true
  return true
end function

/// Closes close owned by the minisql server session module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param session session value consumed by this operation.
function close(session)
  validateOpen(session, "close")
  // A standalone session owns and closes its database, including the lock.
  if session.engine.ownsDatabase then return closeUnlocked(session) end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(closeUnlocked(session))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

/// Performs the componentName operation for the minisql server session module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.session"
end function

/// Performs the targetMilestone operation for the minisql server session module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql server session module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
