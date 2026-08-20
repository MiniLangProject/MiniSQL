// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.protocol.codec as codec
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.platform.network as network
import tests.support.testkit as testkit


// Closes a socket handle when valid and suppresses cleanup errors so the original network assertion remains visible.
function closeSocketQuiet(handle)
  if network.isHandle(handle) then
    ignored = try(network.close(handle))
  end if
  return true
end function

// Exercises signed WinSock return-value handling, asserting retryable, closed, and fatal socket outcomes without misclassification.
function testSignedWinSockResults(state, port)
  listener = void
  clientSocket = void
  serverSocket = void

  listener = network.listenLoopback(port, 4)
  network.setNonBlocking(listener, true)

  // A non-blocking accept before any connection must map the signed WinSock
  // SOCKET_ERROR sentinel to WSAEWOULDBLOCK, not to a huge positive count.
  pending = try(network.tryAccept(listener))
  testkit.record(state, pending is void, "nonblocking accept reports no pending client")

  clientSocket = network.connectTcp("127.0.0.1", port)
  for acceptAttempt = 0 to 100
    serverSocket = network.tryAccept(listener)
    if serverSocket is not void then break end if
    network.sleepMilliseconds(1)
  end for
  if serverSocket is void then return error(9026, "M18 WinSock ABI regression: loopback accept timed out") end if
  network.setNonBlocking(serverSocket, true)

  scratch = bytes(32, 0)
  wouldBlock = try(network.receiveAvailableInto(serverSocket, scratch, 0, len(scratch)))
  testkit.record(state, wouldBlock is void, "nonblocking recv maps signed SOCKET_ERROR to would-block")

  sent = network.sendAll(clientSocket, bytes("abc"))
  testkit.equal(state, sent, 3, "direct-offset send count")

  received = void
  for attempt = 0 to 100
    received = network.receiveAvailableInto(serverSocket, scratch, 0, len(scratch))
    if received is not void then break end if
    network.sleepMilliseconds(1)
  end for
  testkit.equal(state, received, 3, "nonblocking direct-offset receive count")
  testkit.equal(state, scratch[0], 97, "nonblocking receive byte 0")
  testkit.equal(state, scratch[1], 98, "nonblocking receive byte 1")
  testkit.equal(state, scratch[2], 99, "nonblocking receive byte 2")

  network.setNonBlocking(serverSocket, false)
  network.sendAll(serverSocket, bytes("reply"))
  exact = network.receiveExact(clientSocket, 5)
  testkit.equal(state, decode(exact), "reply", "blocking receiveExact uses signed i32 result")

  closeSocketQuiet(serverSocket)
  closeSocketQuiet(clientSocket)
  closeSocketQuiet(listener)
  return true
end function

// Runs the protocol test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = testkit.create()
  if len(args) != 1 then
    testkit.record(state, false, "one loopback port argument is required")
    return testkit.finish(state, "MiniSQL M18 protocol codec tests: SUCCESS", "MiniSQL M18 protocol codec tests: FAIL")
  end if
  port = toNumber(args[0])
  testkit.record(state, typeof(port) == "int" and port >= 1 and port <= 65535, "loopback port argument")
  // Validate the native signed-return ABI before exercising the pure frame
  // codec so a socket regression cannot hide behind successful serialization.
  testSignedWinSockResults(state, port)

  // Round-trip the request frame and independently validate its fixed header.
  request = messages.query(42, "SELECT id, name FROM account")
  encoded = codec.encodeMessage(request)
  decoded = codec.decodeMessage(encoded)
  testkit.equal(state, decoded.messageType, constants.TYPE_QUERY, "query frame type")
  testkit.equal(state, decoded.requestId, 42, "query frame request ID")
  testkit.equal(state, decode(decoded.payload), "SELECT id, name FROM account", "query frame payload")
  testkit.equal(state, len(encoded), constants.HEADER_BYTES + len(request.payload), "frame size")

  header = codec.decodeHeader(slice(encoded, 0, constants.HEADER_BYTES))
  testkit.equal(state, header.payloadLength, len(request.payload), "header payload length")
  testkit.equal(state, header.messageType, constants.TYPE_QUERY, "header message type")

  // Mutate each integrity/version region separately. Every damaged or
  // incomplete outer frame must fail before its payload is consumed.
  badMagic = bytes(encoded)
  badMagic[0] = badMagic[0] ^ 1
  testkit.errorCode(state, try(codec.decodeMessage(badMagic)), 9004, "magic corruption rejected")

  badHeader = bytes(encoded)
  badHeader[12] = badHeader[12] ^ 1
  testkit.errorCode(state, try(codec.decodeMessage(badHeader)), 9004, "header CRC corruption rejected")

  badVersion = bytes(encoded)
  endian.writeU16LE(badVersion, 4, 2)
  testkit.errorCode(state, try(codec.decodeMessage(badVersion)), 9003, "unsupported protocol version rejected")

  badPayload = bytes(encoded)
  badPayload[len(badPayload) - 1] = badPayload[len(badPayload) - 1] ^ 1
  testkit.errorCode(state, try(codec.decodeMessage(badPayload)), 9004, "payload CRC corruption rejected")

  testkit.errorCode(state, try(codec.decodeMessage(slice(encoded, 0, len(encoded) - 1))), 9004, "truncated frame rejected")
  testkit.errorCode(state, try(messages.create(constants.TYPE_QUERY, 0, 1, bytes(constants.MAX_PAYLOAD_BYTES + 1))), 9001, "oversized payload rejected")

  // Response codecs must preserve row, command, and error shapes while also
  // rejecting structural inconsistencies such as row-width mismatches.
  rows = messages.rowResponse(["id", "name"], [["1", "Ada"], ["2", "Bob"]])
  rowBytes = messages.encodeResponse(rows)
  rowDecoded = messages.decodeResponse(rowBytes)
  testkit.equal(state, rowDecoded.status, constants.STATUS_ROWS, "row response status")
  testkit.equal(state, len(rowDecoded.columns), 2, "row response columns")
  testkit.equal(state, len(rowDecoded.rows), 2, "row response row count")
  testkit.equal(state, rowDecoded.rows[1][1], "Bob", "row response value")

  command = messages.decodeResponse(messages.encodeResponse(messages.commandResponse("INSERT", 3, "ok")))
  testkit.equal(state, command.status, constants.STATUS_COMMAND, "command response status")
  testkit.equal(state, command.affectedRows, 3, "command response affected rows")
  testkit.equal(state, command.message, "ok", "command response message")

  failure = messages.decodeResponse(messages.encodeResponse(messages.errorResponse(9020, "binding failed")))
  testkit.equal(state, failure.status, constants.STATUS_ERROR, "error response status")
  testkit.equal(state, failure.errorCode, 9020, "error response code")
  testkit.equal(state, failure.message, "binding failed", "error response message")

  testkit.errorCode(state, try(messages.encodeResponse(messages.rowResponse(["one", "two"], [["only-one"]]))), 9001, "row width mismatch rejected")

  damagedResponse = bytes(rowBytes)
  damagedResponse[len(damagedResponse) - 1] = damagedResponse[len(damagedResponse) - 1] ^ 1
  // Response payloads are protected by the outer frame; a structurally valid text
  // mutation may decode, so verify that trailing bytes are independently rejected.
  trailing = bytes(len(rowBytes) + 1, 0)
  copyBytes(trailing, 0, rowBytes, 0, len(rowBytes))
  testkit.errorCode(state, try(messages.decodeResponse(trailing)), 9004, "trailing response bytes rejected")

  return testkit.finish(state, "MiniSQL M18 protocol codec tests: SUCCESS", "MiniSQL M18 protocol codec tests: FAIL")
end function
