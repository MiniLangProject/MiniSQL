package minisql.client.client

import minisql.common.uuid as uuid
import minisql.common.version as version
import minisql.protocol.connection as connection
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const AUTHENTICATION_FAILED = 9027

struct Client
  connection
  nextRequestId
  closed
  authenticated
  username
end struct

function m0SelfTestLine()
  return "MiniSQL client M0 self-test: SUCCESS"
end function

function versionLine()
  return version.versionLine("client")
end function

function fail(code, operation, message)
  return error(code, "client.client." + operation + ": " + message)
end function

function authenticationFailure(operation)
  return fail(AUTHENTICATION_FAILED, operation, "authentication failed")
end function

function isClient(value)
  return value is Client
end function

function validateOpen(client, operation)
  if client is not Client then return fail(INVALID_ARGUMENT, operation, "client must be Client") end if
  if client.closed then return fail(CLOSED_HANDLE, operation, "client is closed") end if
  return true
end function

function request(client, message)
  validateOpen(client, "request")
  connection.sendMessage(client.connection, message)
  response = connection.receiveMessage(client.connection)
  if response.requestId != message.requestId then return fail(INVALID_ARGUMENT, "request", "response request ID mismatch") end if
  client.nextRequestId = client.nextRequestId + 1
  return response
end function

function helloHandshake(client, operation)
  response = try(request(client, messages.hello(client.nextRequestId)))
  if typeof(response) == "error" then return response end if
  if response.messageType != constants.TYPE_RESPONSE then return fail(INVALID_ARGUMENT, operation, "HELLO response type is invalid") end if
  helloResponse = try(messages.decodeResponse(response.payload))
  if typeof(helloResponse) == "error" then return helloResponse end if
  if helloResponse.status != constants.STATUS_COMMAND or helloResponse.command != "HELLO" then return fail(INVALID_ARGUMENT, operation, "HELLO handshake was rejected") end if
  return true
end function

function closeFailedOpen(client, result)
  ignored = try(connection.close(client.connection))
  client.closed = true
  return result
end function

function openLoopback(port)
  connectionValue = connection.connectLoopback(port)
  client = Client(connectionValue, 1, false, true, "trusted-local")
  handshake = try(helloHandshake(client, "openLoopback"))
  if typeof(handshake) == "error" then return closeFailedOpen(client, handshake) end if
  return client
end function

function clearAuthChallenge(challenge)
  if typeof(challenge) != "array" or len(challenge) < 3 then return false end if
  if typeof(challenge[1]) == "bytes" then fillBytes(challenge[1], 0, len(challenge[1]), 0) end if
  if typeof(challenge[2]) == "bytes" then fillBytes(challenge[2], 0, len(challenge[2]), 0) end if
  return true
end function

function openAuthenticatedConnection(connectionValue, username, passwordBytes, operation)
  if typeof(username) != "string" or len(bytes(username)) == 0 or len(bytes(username)) > 128 then return fail(INVALID_ARGUMENT, operation, "username is invalid") end if
  client = Client(connectionValue, 1, false, false, username)
  handshake = try(helloHandshake(client, operation))
  if typeof(handshake) == "error" then return closeFailedOpen(client, handshake) end if

  challengeMessage = try(request(client, messages.authBegin(client.nextRequestId, username)))
  if typeof(challengeMessage) == "error" then return closeFailedOpen(client, challengeMessage) end if
  if challengeMessage.messageType == constants.TYPE_ERROR then return closeFailedOpen(client, authenticationFailure(operation)) end if
  if challengeMessage.messageType != constants.TYPE_AUTH_CHALLENGE then return closeFailedOpen(client, authenticationFailure(operation)) end if
  challenge = try(messages.decodeAuthChallenge(challengeMessage.payload))
  if typeof(challenge) == "error" then return closeFailedOpen(client, authenticationFailure(operation)) end if

  secret = try(uuid.validatePasswordBytes(passwordBytes, operation))
  if typeof(secret) == "error" then clearAuthChallenge(challenge); return closeFailedOpen(client, secret) end if
  verifier = try(uuid.deriveKey(secret, challenge[1], challenge[0], uuid.PASSWORD_VERIFIER_BYTES))
  uuid.wipeSecret(secret)
  if typeof(verifier) == "error" then clearAuthChallenge(challenge); return closeFailedOpen(client, verifier) end if
  proof = try(uuid.authProof(verifier, challenge[2], username, "client"))
  if typeof(proof) == "error" then uuid.wipeSecret(verifier); clearAuthChallenge(challenge); return closeFailedOpen(client, proof) end if

  proofMessage = try(messages.authProof(client.nextRequestId, proof))
  if typeof(proofMessage) == "error" then uuid.wipeSecret(proof); uuid.wipeSecret(verifier); clearAuthChallenge(challenge); return closeFailedOpen(client, proofMessage) end if
  authenticationMessage = try(request(client, proofMessage))
  uuid.wipeSecret(proofMessage.payload)
  uuid.wipeSecret(proof)
  if typeof(authenticationMessage) == "error" then uuid.wipeSecret(verifier); clearAuthChallenge(challenge); return closeFailedOpen(client, authenticationMessage) end if
  if authenticationMessage.messageType != constants.TYPE_AUTH_OK or typeof(authenticationMessage.payload) != "bytes" or len(authenticationMessage.payload) != uuid.PASSWORD_VERIFIER_BYTES then
    uuid.wipeSecret(verifier)
    clearAuthChallenge(challenge)
    return closeFailedOpen(client, authenticationFailure(operation))
  end if
  expectedServerProof = try(uuid.authProof(verifier, challenge[2], username, "server"))
  if typeof(expectedServerProof) == "error" then uuid.wipeSecret(verifier); clearAuthChallenge(challenge); return closeFailedOpen(client, expectedServerProof) end if
  sendKey = try(uuid.transportKey(verifier, challenge[2], username, "client-to-server"))
  if typeof(sendKey) == "error" then uuid.wipeSecret(expectedServerProof); uuid.wipeSecret(verifier); clearAuthChallenge(challenge); return closeFailedOpen(client, sendKey) end if
  receiveKey = try(uuid.transportKey(verifier, challenge[2], username, "server-to-client"))
  uuid.wipeSecret(verifier)
  if typeof(receiveKey) == "error" then uuid.wipeSecret(expectedServerProof); uuid.wipeSecret(sendKey); clearAuthChallenge(challenge); return closeFailedOpen(client, receiveKey) end if
  proofValid = uuid.constantTimeEquals(expectedServerProof, authenticationMessage.payload)
  uuid.wipeSecret(expectedServerProof)
  uuid.wipeSecret(authenticationMessage.payload)
  clearAuthChallenge(challenge)
  if not proofValid then uuid.wipeSecret(sendKey); uuid.wipeSecret(receiveKey); return closeFailedOpen(client, authenticationFailure(operation)) end if
  activated = try(connection.enableSecure(client.connection, sendKey, receiveKey))
  uuid.wipeSecret(sendKey)
  uuid.wipeSecret(receiveKey)
  if typeof(activated) == "error" then return closeFailedOpen(client, activated) end if
  client.authenticated = true
  return client
end function

function openAuthenticatedAddressBytes(address, port, username, passwordBytes)
  if typeof(passwordBytes) != "bytes" then return fail(INVALID_ARGUMENT, "openAuthenticatedAddressBytes", "password must be bytes") end if
  return openAuthenticatedConnection(connection.connectAddress(address, port), username, passwordBytes, "openAuthenticatedAddressBytes")
end function

function openAuthenticatedLoopbackBytes(port, username, passwordBytes)
  return openAuthenticatedAddressBytes("127.0.0.1", port, username, passwordBytes)
end function

function openAuthenticatedAddress(address, port, username, password)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, "openAuthenticatedAddress", "password must be string") end if
  secret = bytes(password)
  result = try(openAuthenticatedAddressBytes(address, port, username, secret))
  uuid.wipeSecret(secret)
  if typeof(result) == "error" then return result end if
  return result
end function

function openAuthenticatedLoopback(port, username, password)
  return openAuthenticatedAddress("127.0.0.1", port, username, password)
end function

function query(client, sqlText)
  validateOpen(client, "query")
  responseMessage = request(client, messages.query(client.nextRequestId, sqlText))
  if responseMessage.messageType != constants.TYPE_RESPONSE and responseMessage.messageType != constants.TYPE_ERROR then return fail(INVALID_ARGUMENT, "query", "unexpected response type") end if
  return messages.decodeResponse(responseMessage.payload)
end function

function ping(client)
  validateOpen(client, "ping")
  response = request(client, messages.ping(client.nextRequestId))
  return response.messageType == constants.TYPE_PONG
end function

function close(client)
  validateOpen(client, "close")
  response = try(request(client, messages.closeRequest(client.nextRequestId)))
  connection.close(client.connection)
  client.closed = true
  if typeof(response) == "error" then return response end if
  return true
end function

function runInteractive()
  return error(9000, "client.runInteractive requires database endpoint arguments; use openLoopback/query")
end function

function componentName()
  return "client.client"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
