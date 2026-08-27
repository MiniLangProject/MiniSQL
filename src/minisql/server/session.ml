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

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const UNSUPPORTED_SQL = 9025
const AUTHENTICATION_FAILED = 9027
const IO_FAILURE = 9005
const AUTHENTICATION_REQUIRED = 9028
const AUTH_HANDSHAKE_TIMEOUT_MS = 30000
const SESSION_IDLE_TIMEOUT_MS = 300000
// A server cursor retains at most this many arbitrarily wide SQL rows before
// formatting. Payload-size framing may split the batch further.
const STREAM_RESULT_ROWS = 16

// Groups the session state and preserves the field relationships documented below.
struct Session
  // Stores the engine associated with this value.
  engine
  // Indicates whether the closed condition is active.
  closed
  // Stores the close requested associated with this value.
  closeRequested
  // Indicates whether the secure condition is active.
  secure
  // Indicates whether the authenticated condition is active.
  authenticated
  // Indicates whether the pending username condition is active.
  pendingUsername
  // Indicates whether the pending principal identifier condition is active.
  pendingPrincipalId
  // Indicates whether the pending nonce condition is active.
  pendingNonce
  // Indicates whether the pending verifier condition is active.
  pendingVerifier
  // Stores the attempts associated with this value.
  attempts
  // Stores the transport send key associated with this value.
  transportSendKey
  // Stores the transport receive key associated with this value.
  transportReceiveKey
  // Stores the transport pending associated with this value.
  transportPending
  // Stores the created at associated with this value.
  createdAt
  // Stores the last activity associated with this value.
  lastActivity
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "server.session." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the session condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isSession(value)
  return value is Session
end function

// Creates session using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function createSession(engine, secure, authenticated)
  configured = try(executor.setQueryMemoryLimit(engine, database_manager.queryMemoryLimit(engine.database)))
  if typeof(configured) == "error" then return configured end if
  now = clock.monotonicMilliseconds()
  return Session(engine, false, false, secure, authenticated, void, 0, void, void, 0, void, void, false, now, now)
end function

// Opens open using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function open(databasePath)
  return createSession(executor.open(databasePath), false, true)
end function

// Opens secure using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function openSecure(databasePath)
  return createSession(executor.open(databasePath), true, false)
end function

// Opens attached using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function openAttached(database)
  engine = try(executor.attach(database))
  if typeof(engine) == "error" then return engine end if
  return createSession(engine, false, true)
end function

// Completes process-local database preparation before the listener advertises
// readiness, so the first client's HELLO does not pay the full index audit cost.
function prepareAttachedDatabase(database)
  return executor.prepareDatabase(database)
end function

// Opens secure attached using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function openSecureAttached(database)
  engine = try(executor.attach(database))
  if typeof(engine) == "error" then return engine end if
  return createSession(engine, true, false)
end function

// Implements touch for this module.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function touch(session)
  validateOpen(session, "touch")
  session.lastActivity = clock.monotonicMilliseconds()
  return true
end function

// Returns whether the supplied value satisfies the expired condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isExpired(session)
  validateOpen(session, "isExpired")
  now = clock.monotonicMilliseconds()
  if session.secure and not session.authenticated and now - session.createdAt >= AUTH_HANDSHAKE_TIMEOUT_MS then return true end if
  return now - session.lastActivity >= SESSION_IDLE_TIMEOUT_MS
end function

// Implements idle timeout milliseconds for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function idleTimeoutMilliseconds()
  return SESSION_IDLE_TIMEOUT_MS
end function

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateOpen(session, operation)
  if session is not Session then return fail(INVALID_ARGUMENT, operation, "session must be Session") end if
  if session.closed then return fail(CLOSED_HANDLE, operation, "session is closed") end if
  return true
end function

// Implements response message for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function responseMessage(request, response)
  payload = messages.encodeResponse(response)
  kind = constants.TYPE_RESPONSE
  if response.status == constants.STATUS_ERROR then kind = constants.TYPE_ERROR end if
  return messages.create(kind, 0, request.requestId, payload)
end function

// Encodes bounded result batches and marks every non-final frame for the client.
function responseMessages(request, responses)
  if typeof(responses) != "array" or len(responses) == 0 then return fail(INVALID_ARGUMENT, "responseMessages", "responses must be non-empty") end if
  output = []
  for index = 0 to len(responses) - 1
    payload = messages.encodeResponse(responses[index])
    kind = constants.TYPE_RESPONSE
    if responses[index].status == constants.STATUS_ERROR then kind = constants.TYPE_ERROR end if
    flags = 0
    if index < len(responses) - 1 then flags = constants.FLAG_MORE end if
    output = output + [messages.create(kind, flags, request.requestId, payload)]
  end for
  return output
end function

// Implements authentication error for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authenticationError(request)
  return responseMessage(request, messages.errorResponse(AUTHENTICATION_FAILED, "authentication failed"))
end function

// Implements clear pending for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function clearPending(session)
  if typeof(session.pendingVerifier) == "bytes" then fillBytes(session.pendingVerifier, 0, len(session.pendingVerifier), 0) end if
  if typeof(session.pendingNonce) == "bytes" then fillBytes(session.pendingNonce, 0, len(session.pendingNonce), 0) end if
  session.pendingUsername = void
  session.pendingPrincipalId = 0
  session.pendingNonce = void
  session.pendingVerifier = void
  return true
end function

// Implements fake authentication material for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function fakeAuthenticationMaterial(session, username)
  seed = session.engine.database.catalogHandle.metadata.databaseId
  salt = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-SALT-1|" + username), 1, uuid.PASSWORD_SALT_BYTES)
  verifier = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-VERIFIER-1|" + username), 1, uuid.PASSWORD_VERIFIER_BYTES)
  return [uuid.DEFAULT_PBKDF2_ITERATIONS, salt, verifier]
end function

// Implements authentication backoff for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authenticationBackoff(session)
  delay = 50 * (session.attempts + 1)
  if delay > 250 then delay = 250 end if
  clock.sleepMilliseconds(delay)
  return true
end function

// Handles auth begin using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
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
  response = try(messages.authChallenge(request.requestId, iterations, salt, nonce))
  fillBytes(salt, 0, len(salt), 0)
  fillBytes(verifier, 0, len(verifier), 0)
  fillBytes(nonce, 0, len(nonce), 0)
  if typeof(response) == "error" then clearPending(session); return authenticationError(request) end if
  return response
end function

// Handles auth proof using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function handleAuthProof(session, request)
  if not session.secure or session.authenticated or session.pendingUsername is void then return authenticationError(request) end if
  if typeof(request.payload) != "bytes" or len(request.payload) != uuid.PASSWORD_VERIFIER_BYTES then clearPending(session); return authenticationError(request) end if
  expected = try(uuid.authProof(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "client"))
  if typeof(expected) == "error" then clearPending(session); return authenticationError(request) end if
  proofValid = uuid.constantTimeEquals(expected, request.payload)
  fillBytes(expected, 0, len(expected), 0)
  fillBytes(request.payload, 0, len(request.payload), 0)
  connectAllowed = false
  if session.pendingPrincipalId > 0 then
    connectAllowed = catalog.isSuperuser(session.engine.database.catalogHandle, session.pendingPrincipalId) or catalog.hasPrivilege(session.engine.database.catalogHandle, session.pendingPrincipalId, metadata.OBJECT_DATABASE, 0, metadata.PRIVILEGE_CONNECT, false)
  end if
  if proofValid and connectAllowed then
    sendKey = try(uuid.transportKey(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "server-to-client"))
    if typeof(sendKey) == "error" then clearPending(session); return authenticationError(request) end if
    receiveKey = try(uuid.transportKey(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "client-to-server"))
    if typeof(receiveKey) == "error" then uuid.wipeSecret(sendKey); clearPending(session); return authenticationError(request) end if
    serverProof = try(uuid.authProof(session.pendingVerifier, session.pendingNonce, session.pendingUsername, "server"))
    if typeof(serverProof) == "error" then uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); clearPending(session); return authenticationError(request) end if
    principalSet = try(executor.setPrincipal(session.engine, session.pendingPrincipalId))
    if typeof(principalSet) == "error" then uuid.wipeSecret(serverProof); uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); clearPending(session); return authenticationError(request) end if
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

// Implements transport ready for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function transportReady(session)
  validateOpen(session, "transportReady")
  return session.transportPending
end function

// Implements session identifier for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sessionIdentifier(session)
  validateOpen(session, "sessionIdentifier")
  return executor.sessionIdentifier(session.engine)
end function

// Implements abort for concurrency unlocked for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function abortForConcurrencyUnlocked(session)
  validateOpen(session, "abortForConcurrency")
  return executor.abortForConcurrency(session.engine)
end function

// Implements abort for concurrency for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function abortForConcurrency(session)
  validateOpen(session, "abortForConcurrency")
  if session.engine.ownsDatabase then return abortForConcurrencyUnlocked(session) end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(abortForConcurrencyUnlocked(session))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

// Implements activate transport for this module.
// Returns the computed value or operation status.
// May mutate supplied state and perform I/O through its dependencies.
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

// Returns whether this session still has a logical lock blocker. The check is
// side-effect free and lets the listener suspend a request without executing it
// repeatedly while another explicit transaction owns the writer lock.
function waitingForConcurrency(session)
  validateOpen(session, "waitingForConcurrency")
  return database_manager.isLockWaiting(session.engine.database, executor.sessionIdentifier(session.engine))
end function

// Handles query using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function handleQuery(session, request)
  if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
  sqlText = decode(request.payload)
  if typeof(sqlText) != "string" then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "query payload is not valid UTF-8")) end if
  sessionId = executor.sessionIdentifier(session.engine)
  if not logger.binlog("minisql.server.session.handleQuery session=" + sessionId, sqlText) then
    ignoredLog = logger.errorLog("minisql.server.session.handleQuery", "binlog persistence failed; statement rejected session=" + sessionId)
    return responseMessage(request, messages.errorResponse(IO_FAILURE, "SQL binlog persistence failed; statement was not executed"))
  end if
  ignoredLog = logger.debug("minisql.server.session.handleQuery", "received SQL statement session=" + sessionId + " bytes=" + len(request.payload))
  parsed = try(parser.parseSql(sqlText))
  if typeof(parsed) == "error" then ignoredLog = logger.warning("minisql.server.session.handleQuery", "SQL parse failed session=" + sessionId + " code=" + parsed.code); return responseMessage(request, messages.errorResponse(parsed.code, parsed.message)) end if
  if len(parsed) != 1 then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "one SQL statement per request is required")) end if
  return executeParsedQuery(session, request, parsed[0])
end function

// Executes an already parsed statement through the ordinary materializing API.
// Keeping this tail separate lets the network streaming path reuse parsing,
// authorization errors, and the exact fallback response contract.
function executeParsedQuery(session, request, statement)
  sessionId = executor.sessionIdentifier(session.engine)
  // The executor centrally selects the shared-reader or exclusive-writer path.
  result = try(executor.executeStatement(session.engine, statement))
  if typeof(result) == "error" then
    if result.code == 9007 then
      ignoredLog = logger.debug("minisql.server.session.handleQuery", "SQL waiting for logical lock session=" + sessionId)
    else
      ignoredLog = logger.errorLog("minisql.server.session.handleQuery", "SQL execution failed session=" + sessionId + " code=" + result.code + " message=" + result.message)
    end if
    return responseMessage(request, messages.errorResponse(result.code, result.message))
  end if
  converted = try(formatter.responsesFromResult(result))
  if typeof(converted) == "error" then return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
  ignoredLog = logger.info("minisql.server.session.handleQuery", "SQL completed session=" + sessionId + " command=" + converted[0].command + " rows=" + result.affectedRows + " frames=" + len(converted))
  framed = responseMessages(request, converted)
  if len(framed) == 1 then return framed[0] end if
  return framed
end function

// Streams an eligible non-blocking SELECT directly to one connection. One
// protocol frame plus one look-ahead frame are retained, so both server and
// cursor-aware client memory remain bounded while FLAG_MORE stays exact.
function handleQueryStreaming(session, request, connection)
  if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
  sqlText = decode(request.payload)
  if typeof(sqlText) != "string" then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "query payload is not valid UTF-8")) end if
  sessionId = executor.sessionIdentifier(session.engine)
  if not logger.binlog("minisql.server.session.handleQueryStreaming session=" + sessionId, sqlText) then
    ignoredLog = logger.errorLog("minisql.server.session.handleQueryStreaming", "binlog persistence failed; statement rejected session=" + sessionId)
    return responseMessage(request, messages.errorResponse(IO_FAILURE, "SQL binlog persistence failed; statement was not executed"))
  end if
  parsed = try(parser.parseSql(sqlText))
  if typeof(parsed) == "error" then return responseMessage(request, messages.errorResponse(parsed.code, parsed.message)) end if
  if len(parsed) != 1 then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "one SQL statement per request is required")) end if
  cursor = try(executor.openSelectCursor(session.engine, parsed[0]))
  if typeof(cursor) == "error" then return responseMessage(request, messages.errorResponse(cursor.code, cursor.message)) end if
  if cursor is void then return executeParsedQuery(session, request, parsed[0]) end if

  pending = void
  frameCount = 0
  rowCount = 0
  while true
    batch = try(executor.nextSelectBatch(cursor, STREAM_RESULT_ROWS))
    if typeof(batch) == "error" then
      executor.closeSelectCursor(cursor)
      if pending is not void then
        pending.flags = constants.FLAG_MORE
        sentPending = try(protocol_connection.sendMessage(connection, pending))
        if typeof(sentPending) == "error" then return sentPending end if
      end if
      failure = responseMessage(request, messages.errorResponse(batch.code, batch.message))
      sentFailure = try(protocol_connection.sendMessage(connection, failure))
      if typeof(sentFailure) == "error" then return sentFailure end if
      return []
    end if
    if batch is void then break end if
    rowCount = rowCount + len(batch.rows)
    converted = try(formatter.responsesFromResult(batch))
    if typeof(converted) == "error" then executor.closeSelectCursor(cursor); return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
    for each response in converted
      frame = responseMessage(request, response)
      if pending is not void then
        pending.flags = constants.FLAG_MORE
        sent = try(protocol_connection.sendMessage(connection, pending))
        if typeof(sent) == "error" then executor.closeSelectCursor(cursor); return sent end if
        frameCount = frameCount + 1
      end if
      pending = frame
    end for
  end while
  if pending is void then pending = responseMessage(request, messages.rowResponse(cursor.bound.itemNames, [])) end if
  sentFinal = try(protocol_connection.sendMessage(connection, pending))
  if typeof(sentFinal) == "error" then return sentFinal end if
  frameCount = frameCount + 1
  ignoredLog = logger.info("minisql.server.session.handleQueryStreaming", "SQL streamed session=" + sessionId + " rows=" + rowCount + " frames=" + frameCount)
  return []
end function

// Handles a request and, for eligible SELECTs, writes response batches directly
// to the supplied protocol connection. An empty array means delivery completed.
function handleToConnection(session, request, connection)
  validateOpen(session, "handleToConnection")
  if messages.isMessage(request) and request.messageType == constants.TYPE_QUERY then return handleQueryStreaming(session, request, connection) end if
  return handle(session, request)
end function

// Handles unlocked using the supplied inputs.
// Returns the computed value or operation status.
// May mutate supplied state as documented by the operation name.
function handleUnlocked(session, request)
  validateOpen(session, "handle")
  if isExpired(session) then session.closeRequested = true; return responseMessage(request, messages.errorResponse(AUTHENTICATION_FAILED, "session expired")) end if
  session.lastActivity = clock.monotonicMilliseconds()
  if not messages.isMessage(request) then return fail(INVALID_ARGUMENT, "handle", "request must be Message") end if
  if request.messageType == constants.TYPE_HELLO then
    message = "MiniSQL protocol 1"
    if session.secure and not session.authenticated then message = message + "; authentication required" end if
    return responseMessage(request, messages.commandResponse("HELLO", 0, message))
  end if
  if request.messageType == constants.TYPE_PING then return messages.create(constants.TYPE_PONG, 0, request.requestId, bytes(0)) end if
  if request.messageType == constants.TYPE_CLOSE then
    session.closeRequested = true
    return responseMessage(request, messages.commandResponse("CLOSE", 0, "session closing"))
  end if
  if request.messageType == constants.TYPE_AUTH_BEGIN then return handleAuthBegin(session, request) end if
  if request.messageType == constants.TYPE_AUTH_PROOF then return handleAuthProof(session, request) end if
  if request.messageType == constants.TYPE_QUERY then return handleQuery(session, request) end if
  return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "unsupported request type"))
end function

// Handles handle using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function handle(session, request)
  validateOpen(session, "handle")
  if session.engine.ownsDatabase then return handleUnlocked(session, request) end if
  // Frame decoding, simple protocol control messages and SQL parsing do not
  // touch shared database state and therefore stay fully concurrent.
  if messages.isMessage(request) and (request.messageType == constants.TYPE_HELLO or request.messageType == constants.TYPE_PING or request.messageType == constants.TYPE_CLOSE or request.messageType == constants.TYPE_QUERY) then
    return handleUnlocked(session, request)
  end if
  entered = try(database_manager.enterExecution(session.engine.database))
  result = try(handleUnlocked(session, request))
  released = try(database_manager.leaveExecution(session.engine.database))
  if typeof(released) == "error" then return released end if
  return result
end function

// Closes unlocked using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state as documented by the operation name.
function closeUnlocked(session)
  validateOpen(session, "close")
  clearPending(session)
  if typeof(session.transportSendKey) == "bytes" then uuid.wipeSecret(session.transportSendKey) end if
  if typeof(session.transportReceiveKey) == "bytes" then uuid.wipeSecret(session.transportReceiveKey) end if
  session.transportSendKey = void
  session.transportReceiveKey = void
  session.transportPending = false
  if session.authenticated then ignoredAudit = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGOUT, diagnostics.AUDIT_SUCCESS, executor.sessionIdentifier(session.engine), session.engine.principalId, "session closed")) end if
  ignoredLog = logger.info("minisql.server.session.close", "session closed id=" + executor.sessionIdentifier(session.engine))
  executor.close(session.engine)
  session.closed = true
  return true
end function

// Closes close using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "server.session"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
