package minisql.server.session

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.client.formatter as formatter
import minisql.common.uuid as uuid
import minisql.common.diagnostics as diagnostics
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
const AUTHENTICATION_REQUIRED = 9028
const AUTH_HANDSHAKE_TIMEOUT_MS = 30000
const SESSION_IDLE_TIMEOUT_MS = 300000

struct Session
  engine
  closed
  closeRequested
  secure
  authenticated
  pendingUsername
  pendingPrincipalId
  pendingNonce
  pendingVerifier
  attempts
  transportSendKey
  transportReceiveKey
  transportPending
  createdAt
  lastActivity
end struct

function fail(code, operation, message)
  return error(code, "server.session." + operation + ": " + message)
end function

function isSession(value)
  return value is Session
end function

function createSession(engine, secure, authenticated)
  now = clock.monotonicMilliseconds()
  return Session(engine, false, false, secure, authenticated, void, 0, void, void, 0, void, void, false, now, now)
end function

function open(databasePath)
  return createSession(executor.open(databasePath), false, true)
end function

function openSecure(databasePath)
  return createSession(executor.open(databasePath), true, false)
end function

function openAttached(database)
  return createSession(executor.attach(database), false, true)
end function

function openSecureAttached(database)
  return createSession(executor.attach(database), true, false)
end function

function touch(session)
  validateOpen(session, "touch")
  session.lastActivity = clock.monotonicMilliseconds()
  return true
end function

function isExpired(session)
  validateOpen(session, "isExpired")
  now = clock.monotonicMilliseconds()
  if session.secure and not session.authenticated and now - session.createdAt >= AUTH_HANDSHAKE_TIMEOUT_MS then return true end if
  return now - session.lastActivity >= SESSION_IDLE_TIMEOUT_MS
end function

function idleTimeoutMilliseconds()
  return SESSION_IDLE_TIMEOUT_MS
end function

function validateOpen(session, operation)
  if session is not Session then return fail(INVALID_ARGUMENT, operation, "session must be Session") end if
  if session.closed then return fail(CLOSED_HANDLE, operation, "session is closed") end if
  return true
end function

function responseMessage(request, response)
  payload = messages.encodeResponse(response)
  kind = constants.TYPE_RESPONSE
  if response.status == constants.STATUS_ERROR then kind = constants.TYPE_ERROR end if
  return messages.create(kind, 0, request.requestId, payload)
end function

function authenticationError(request)
  return responseMessage(request, messages.errorResponse(AUTHENTICATION_FAILED, "authentication failed"))
end function

function clearPending(session)
  if typeof(session.pendingVerifier) == "bytes" then fillBytes(session.pendingVerifier, 0, len(session.pendingVerifier), 0) end if
  if typeof(session.pendingNonce) == "bytes" then fillBytes(session.pendingNonce, 0, len(session.pendingNonce), 0) end if
  session.pendingUsername = void
  session.pendingPrincipalId = 0
  session.pendingNonce = void
  session.pendingVerifier = void
  return true
end function

function fakeAuthenticationMaterial(session, username)
  seed = session.engine.database.catalogHandle.metadata.databaseId
  salt = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-SALT-1|" + username), 1, uuid.PASSWORD_SALT_BYTES)
  verifier = uuid.deriveKey(seed, bytes("MiniSQL-FAKE-VERIFIER-1|" + username), 1, uuid.PASSWORD_VERIFIER_BYTES)
  return [uuid.DEFAULT_PBKDF2_ITERATIONS, salt, verifier]
end function

function authenticationBackoff(session)
  delay = 50 * (session.attempts + 1)
  if delay > 250 then delay = 250 end if
  clock.sleepMilliseconds(delay)
  return true
end function

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
    session.transportSendKey = sendKey
    session.transportReceiveKey = receiveKey
    session.transportPending = true
    response = messages.authOk(request.requestId, serverProof)
    fillBytes(serverProof, 0, len(serverProof), 0)
    clearPending(session)
    return response
  end if
  ignoredAudit = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGIN, diagnostics.AUDIT_FAILURE, executor.sessionIdentifier(session.engine), session.pendingPrincipalId, "login failed"))
  authenticationBackoff(session)
  session.attempts = session.attempts + 1
  clearPending(session)
  if session.attempts >= 3 then session.closeRequested = true end if
  return authenticationError(request)
end function

function transportReady(session)
  validateOpen(session, "transportReady")
  return session.transportPending
end function

function sessionIdentifier(session)
  validateOpen(session, "sessionIdentifier")
  return executor.sessionIdentifier(session.engine)
end function

function abortForConcurrency(session)
  validateOpen(session, "abortForConcurrency")
  return executor.abortForConcurrency(session.engine)
end function

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

function handleQuery(session, request)
  if session.secure and not session.authenticated then return responseMessage(request, messages.errorResponse(AUTHENTICATION_REQUIRED, "authentication is required")) end if
  sqlText = decode(request.payload)
  if typeof(sqlText) != "string" then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "query payload is not valid UTF-8")) end if
  parsed = try(parser.parseSql(sqlText))
  if typeof(parsed) == "error" then return responseMessage(request, messages.errorResponse(parsed.code, parsed.message)) end if
  if len(parsed) != 1 then return responseMessage(request, messages.errorResponse(UNSUPPORTED_SQL, "one SQL statement per request is required")) end if
  result = try(executor.executeStatement(session.engine, parsed[0]))
  if typeof(result) == "error" then return responseMessage(request, messages.errorResponse(result.code, result.message)) end if
  converted = try(formatter.responseFromResult(result))
  if typeof(converted) == "error" then return responseMessage(request, messages.errorResponse(converted.code, converted.message)) end if
  return responseMessage(request, converted)
end function

function handle(session, request)
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

function close(session)
  validateOpen(session, "close")
  clearPending(session)
  if typeof(session.transportSendKey) == "bytes" then uuid.wipeSecret(session.transportSendKey) end if
  if typeof(session.transportReceiveKey) == "bytes" then uuid.wipeSecret(session.transportReceiveKey) end if
  session.transportSendKey = void
  session.transportReceiveKey = void
  session.transportPending = false
  if session.authenticated then ignoredAudit = try(database_manager.audit(session.engine.database, diagnostics.AUDIT_LOGOUT, diagnostics.AUDIT_SUCCESS, executor.sessionIdentifier(session.engine), session.engine.principalId, "session closed")) end if
  executor.close(session.engine)
  session.closed = true
  return true
end function

function componentName()
  return "server.session"
end function

function targetMilestone()
  return "M18"
end function

function isImplemented()
  return true
end function
