package minisql.client.client

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.uuid as uuid
import minisql.common.version as version
import minisql.protocol.connection as connection
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const AUTHENTICATION_FAILED = 9027
const HANDSHAKE_TIMEOUT_MS = 5000

// Groups the client state and preserves the field relationships documented below.
struct Client
  // Stores the connection associated with this value.
  connection
  // Tracks the next request identifier numeric value.
  nextRequestId
  // Indicates whether the closed condition is active.
  closed
  // Indicates whether the authenticated condition is active.
  authenticated
  // Stores the username associated with this value.
  username
end struct

// Implements m0 self test line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function m0SelfTestLine()
  return "MiniSQL client M0 self-test: SUCCESS"
end function

// Implements version line for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function versionLine()
  return version.versionLine("client")
end function

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "client.client." + operation + ": " + message)
end function

// Implements authentication failure for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function authenticationFailure(operation)
  return fail(AUTHENTICATION_FAILED, operation, "authentication failed")
end function

// Returns whether the supplied value satisfies the client condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isClient(value)
  return value is Client
end function

// Validates open using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateOpen(client, operation)
  if client is not Client then return fail(INVALID_ARGUMENT, operation, "client must be Client") end if
  if client.closed then return fail(CLOSED_HANDLE, operation, "client is closed") end if
  return true
end function

// Implements request for this module.
// Returns the computed value or operation status.
// May mutate supplied state and perform I/O through its dependencies.
function request(client, message)
  validateOpen(client, "request")
  connection.sendMessage(client.connection, message)
  response = connection.receiveMessage(client.connection)
  if response.requestId != message.requestId then return fail(INVALID_ARGUMENT, "request", "response request ID mismatch") end if
  client.nextRequestId = client.nextRequestId + 1
  return response
end function

// Compares response schemas across continuation frames without relying on
// aggregate-array identity semantics.
function sameColumns(left, right)
  if typeof(left) != "array" or typeof(right) != "array" or len(left) != len(right) then return false end if
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      if left[index] != right[index] then return false end if
    end for
  end if
  return true
end function

// Implements hello handshake for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function helloHandshake(client, operation)
  bounded = try(connection.setTimeouts(client.connection, HANDSHAKE_TIMEOUT_MS, HANDSHAKE_TIMEOUT_MS))
  if typeof(bounded) == "error" then return bounded end if
  response = try(request(client, messages.hello(client.nextRequestId)))
  restored = try(connection.setTimeouts(client.connection, 0, 0))
  if typeof(response) == "error" then return response end if
  if typeof(restored) == "error" then return restored end if
  if response.messageType != constants.TYPE_RESPONSE then return fail(INVALID_ARGUMENT, operation, "HELLO response type is invalid") end if
  helloResponse = try(messages.decodeResponse(response.payload))
  if typeof(helloResponse) == "error" then return helloResponse end if
  if helloResponse.status != constants.STATUS_COMMAND or helloResponse.command != "HELLO" then return fail(INVALID_ARGUMENT, operation, "HELLO handshake was rejected") end if
  return true
end function

// Closes failed open using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state and perform I/O through its dependencies.
function closeFailedOpen(client, result)
  ignored = try(connection.close(client.connection))
  client.closed = true
  return result
end function

// Opens loopback using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Performs I/O through its file, transport, or storage dependencies.
function openLoopback(port)
  connectionValue = connection.connectLoopback(port)
  client = Client(connectionValue, 1, false, true, "trusted-local")
  handshake = try(helloHandshake(client, "openLoopback"))
  if typeof(handshake) == "error" then return closeFailedOpen(client, handshake) end if
  return client
end function

// Implements clear auth challenge for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function clearAuthChallenge(challenge)
  if typeof(challenge) != "array" or len(challenge) < 3 then return false end if
  if typeof(challenge[1]) == "bytes" then fillBytes(challenge[1], 0, len(challenge[1]), 0) end if
  if typeof(challenge[2]) == "bytes" then fillBytes(challenge[2], 0, len(challenge[2]), 0) end if
  return true
end function

// Opens authenticated connection using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state and perform I/O through its dependencies.
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

// Opens authenticated address bytes using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Performs I/O through its file, transport, or storage dependencies.
function openAuthenticatedAddressBytes(address, port, username, passwordBytes)
  if typeof(passwordBytes) != "bytes" then return fail(INVALID_ARGUMENT, "openAuthenticatedAddressBytes", "password must be bytes") end if
  return openAuthenticatedConnection(connection.connectAddress(address, port), username, passwordBytes, "openAuthenticatedAddressBytes")
end function

// Opens authenticated MiniSQL over native TLS with Windows X.509 trust.
function openTlsAuthenticatedAddressBytes(address, port, serverName, username, passwordBytes)
  if typeof(passwordBytes) != "bytes" then return fail(INVALID_ARGUMENT, "openTlsAuthenticatedAddressBytes", "password must be bytes") end if
  transport = try(connection.connectTlsAddress(address, port, serverName))
  if typeof(transport) == "error" then return transport end if
  return openAuthenticatedConnection(transport, username, passwordBytes, "openTlsAuthenticatedAddressBytes")
end function

// Opens authenticated MiniSQL over native TLS with exact SHA-256 leaf pinning.
function openTlsPinnedAuthenticatedAddressBytes(address, port, serverName, pinText, username, passwordBytes)
  if typeof(passwordBytes) != "bytes" then return fail(INVALID_ARGUMENT, "openTlsPinnedAuthenticatedAddressBytes", "password must be bytes") end if
  transport = try(connection.connectTlsPinnedAddress(address, port, serverName, pinText))
  if typeof(transport) == "error" then return transport end if
  return openAuthenticatedConnection(transport, username, passwordBytes, "openTlsPinnedAuthenticatedAddressBytes")
end function

// Opens authenticated loopback bytes using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function openAuthenticatedLoopbackBytes(port, username, passwordBytes)
  return openAuthenticatedAddressBytes("127.0.0.1", port, username, passwordBytes)
end function

// Opens authenticated address using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function openAuthenticatedAddress(address, port, username, password)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, "openAuthenticatedAddress", "password must be string") end if
  secret = bytes(password)
  result = try(openAuthenticatedAddressBytes(address, port, username, secret))
  uuid.wipeSecret(secret)
  if typeof(result) == "error" then return result end if
  return result
end function

// Opens native TLS with Windows trust while wiping the temporary password bytes.
function openTlsAuthenticatedAddress(address, port, serverName, username, password)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, "openTlsAuthenticatedAddress", "password must be string") end if
  secret = bytes(password)
  result = try(openTlsAuthenticatedAddressBytes(address, port, serverName, username, secret))
  uuid.wipeSecret(secret)
  if typeof(result) == "error" then return result end if
  return result
end function

// Opens pinned native TLS while wiping the temporary password bytes.
function openTlsPinnedAuthenticatedAddress(address, port, serverName, pinText, username, password)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, "openTlsPinnedAuthenticatedAddress", "password must be string") end if
  secret = bytes(password)
  result = try(openTlsPinnedAuthenticatedAddressBytes(address, port, serverName, pinText, username, secret))
  uuid.wipeSecret(secret)
  if typeof(result) == "error" then return result end if
  return result
end function

// Opens authenticated loopback using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function openAuthenticatedLoopback(port, username, password)
  return openAuthenticatedAddress("127.0.0.1", port, username, password)
end function

// Implements query for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function query(client, sqlText)
  validateOpen(client, "query")
  requestId = client.nextRequestId
  sent = try(connection.sendMessage(client.connection, messages.query(requestId, sqlText)))
  if typeof(sent) == "error" then return sent end if
  combined = void
  while true
    responseMessage = try(connection.receiveMessage(client.connection))
    if typeof(responseMessage) == "error" then return responseMessage end if
    if responseMessage.requestId != requestId then return fail(INVALID_ARGUMENT, "query", "response request ID mismatch") end if
    if responseMessage.messageType != constants.TYPE_RESPONSE and responseMessage.messageType != constants.TYPE_ERROR then return fail(INVALID_ARGUMENT, "query", "unexpected response type") end if
    decoded = try(messages.decodeResponse(responseMessage.payload))
    if typeof(decoded) == "error" then return decoded end if
    if combined is void then
      combined = decoded
    else
      if combined.status != constants.STATUS_ROWS or decoded.status != constants.STATUS_ROWS or not sameColumns(combined.columns, decoded.columns) then return fail(INVALID_ARGUMENT, "query", "inconsistent result batch") end if
      combined.rows = combined.rows + decoded.rows
      combined.affectedRows = combined.affectedRows + decoded.affectedRows
    end if
    if (responseMessage.flags & constants.FLAG_MORE) == 0 then break end if
  end while
  client.nextRequestId = client.nextRequestId + 1
  return combined
end function

// Implements ping for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function ping(client)
  validateOpen(client, "ping")
  response = request(client, messages.ping(client.nextRequestId))
  return response.messageType == constants.TYPE_PONG
end function

// Closes close using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// May mutate supplied state and perform I/O through its dependencies.
function close(client)
  validateOpen(client, "close")
  response = try(request(client, messages.closeRequest(client.nextRequestId)))
  connection.close(client.connection)
  client.closed = true
  if typeof(response) == "error" then return response end if
  return true
end function

// Aborts a client whose request/response framing may have been interrupted.
function abort(client)
  if client is not Client then return fail(INVALID_ARGUMENT, "abort", "client must be Client") end if
  if client.closed then return true end if
  result = try(connection.abort(client.connection))
  client.closed = true
  return result
end function

// Runs interactive using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function runInteractive()
  return error(9000, "client.runInteractive requires database endpoint arguments; use openLoopback/query")
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "client.client"
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
