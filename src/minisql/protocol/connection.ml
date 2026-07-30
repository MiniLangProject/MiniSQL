package minisql.protocol.connection

import minisql.platform.network as network
import minisql.common.uuid as uuid
import minisql.common.endian as endian
import minisql.protocol.codec as codec
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

const INVALID_ARGUMENT = 9001
const CLOSED_HANDLE = 9008
const CORRUPT_DATA = 9004
const SECURE_TRANSPORT = 9030
const POLL_RECEIVE_BYTES = 65536

struct Connection
  socket
  closed
  receiveBuffer
  receiveScratch
  peerClosed
  secure
  sendKey
  receiveKey
  sendSequence
  receiveSequence
end struct

struct PollResult
  message
  closed
end struct

function fail(code, operation, message)
  return error(code, "protocol.connection." + operation + ": " + message)
end function

function isConnection(value)
  return value is Connection
end function

function create(socketHandle)
  if not network.isHandle(socketHandle) then return fail(INVALID_ARGUMENT, "create", "socket handle is invalid") end if
  return Connection(socketHandle, false, bytes(0), bytes(POLL_RECEIVE_BYTES, 0), false, false, void, void, 0, 0)
end function

function connectAddress(address, port)
  return create(network.connectTcp(address, port))
end function

function connectLoopback(port)
  return connectAddress("127.0.0.1", port)
end function

function validateOpen(connection, operation)
  if connection is not Connection then return fail(INVALID_ARGUMENT, operation, "connection must be Connection") end if
  if connection.closed then return fail(CLOSED_HANDLE, operation, "connection is closed") end if
  return true
end function

function copyRange(source, offset, count, operation)
  copied = try(network.copyByteRange(source, offset, count, operation))
  if typeof(copied) == "error" then return copied end if
  if typeof(copied) != "bytes" then return fail(CORRUPT_DATA, operation, "byte range materialization did not return bytes") end if
  return copied
end function

function appendReceiveScratch(connection, count)
  if typeof(count) != "int" or count < 0 or count > len(connection.receiveScratch) then return fail(CORRUPT_DATA, "appendReceiveScratch", "received byte count is invalid") end if
  previousLength = len(connection.receiveBuffer)
  // A read can finish one maximum-sized frame and already contain the
  // beginning of the next frame. Keep one scratch-window of headroom while
  // still bounding per-connection memory deterministically.
  maximumBuffered = constants.HEADER_BYTES + constants.MAX_PAYLOAD_BYTES + POLL_RECEIVE_BYTES
  if previousLength > maximumBuffered - count then return fail(CORRUPT_DATA, "appendReceiveScratch", "receive buffer exceeds bounded frame window") end if
  combined = bytes(previousLength + count, 0)
  if previousLength > 0 then copyBytes(combined, 0, connection.receiveBuffer, 0, previousLength) end if
  if count > 0 then copyBytes(combined, previousLength, connection.receiveScratch, 0, count) end if
  connection.receiveBuffer = combined
  return true
end function

function extractBufferedMessage(connection)
  bufferedLength = len(connection.receiveBuffer)
  if bufferedLength < constants.HEADER_BYTES then return void end if
  headerBytes = try(copyRange(connection.receiveBuffer, 0, constants.HEADER_BYTES, "extractBufferedMessage"))
  if typeof(headerBytes) == "error" then return headerBytes end if
  header = try(codec.decodeHeader(headerBytes))
  if typeof(header) == "error" then return header end if
  total = constants.HEADER_BYTES + header.payloadLength
  if bufferedLength < total then return void end if
  frame = try(copyRange(connection.receiveBuffer, 0, total, "extractBufferedMessage"))
  if typeof(frame) == "error" then return frame end if
  remaining = bufferedLength - total
  nextBuffer = bytes(0)
  if remaining > 0 then
    nextBuffer = try(copyRange(connection.receiveBuffer, total, remaining, "extractBufferedMessage"))
    if typeof(nextBuffer) == "error" then return nextBuffer end if
  end if
  decoded = try(decodeInbound(connection, frame))
  if typeof(decoded) == "error" then return decoded end if
  connection.receiveBuffer = nextBuffer
  return PollResult(decoded, false)
end function


function enableSecure(connection, sendKey, receiveKey)
  validateOpen(connection, "enableSecure")
  if typeof(sendKey) != "bytes" or len(sendKey) != 32 or typeof(receiveKey) != "bytes" or len(receiveKey) != 32 then return fail(INVALID_ARGUMENT, "enableSecure", "transport keys must be 32 bytes") end if
  if connection.secure then return fail(INVALID_ARGUMENT, "enableSecure", "secure transport is already active") end if
  connection.sendKey = bytes(sendKey)
  connection.receiveKey = bytes(receiveKey)
  connection.sendSequence = 0
  connection.receiveSequence = 0
  connection.secure = true
  return true
end function

function secureActive(connection)
  validateOpen(connection, "secureActive")
  return connection.secure
end function

function protectMessage(connection, message)
  if not connection.secure then return message end if
  if len(message.payload) > constants.MAX_SECURE_PLAINTEXT_BYTES then return fail(INVALID_ARGUMENT, "protectMessage", "secure plaintext exceeds limit") end if
  sequenceRaw = bytes(8, 0)
  endian.writeU64LE(sequenceRaw, 0, endian.uint64FromInt(connection.sendSequence))
  protectedFlags = message.flags | constants.FLAG_SECURE
  packet = uuid.transportEncrypt(connection.sendKey, connection.sendSequence, message.messageType, protectedFlags, message.requestId, message.payload)
  ciphertext = packet.ciphertext
  tag = packet.tag
  payload = bytes(8 + len(ciphertext) + uuid.AES_GCM_TAG_BYTES, 0)
  copyBytes(payload, 0, sequenceRaw, 0, 8)
  if len(ciphertext) > 0 then copyBytes(payload, 8, ciphertext, 0, len(ciphertext)) end if
  copyBytes(payload, 8 + len(ciphertext), tag, 0, uuid.AES_GCM_TAG_BYTES)
  uuid.wipeSecret(sequenceRaw)
  uuid.wipeSecret(ciphertext)
  uuid.wipeSecret(tag)
  connection.sendSequence = connection.sendSequence + 1
  return messages.create(message.messageType, protectedFlags, message.requestId, payload)
end function

function unprotectMessage(connection, message)
  secureFlag = (message.flags & constants.FLAG_SECURE) != 0
  if not connection.secure then
    if secureFlag then return fail(SECURE_TRANSPORT, "unprotectMessage", "secure frame arrived before transport activation") end if
    return message
  end if
  if not secureFlag then return fail(SECURE_TRANSPORT, "unprotectMessage", "plaintext frame is forbidden after transport activation") end if
  if len(message.payload) < constants.SECURE_OVERHEAD_BYTES then return fail(CORRUPT_DATA, "unprotectMessage", "secure payload is truncated") end if
  sequenceWords = endian.readU64LE(message.payload, 0)
  sequence = try(endian.uint64ToInt(sequenceWords))
  if typeof(sequence) == "error" or sequence != connection.receiveSequence then return fail(SECURE_TRANSPORT, "unprotectMessage", "secure sequence mismatch") end if
  cipherLength = len(message.payload) - constants.SECURE_OVERHEAD_BYTES
  ciphertext = try(copyRange(message.payload, 8, cipherLength, "unprotectMessage"))
  if typeof(ciphertext) == "error" then return ciphertext end if
  receivedTag = try(copyRange(message.payload, 8 + cipherLength, uuid.AES_GCM_TAG_BYTES, "unprotectMessage"))
  if typeof(receivedTag) == "error" then uuid.wipeSecret(ciphertext); return receivedTag end if
  plaintext = try(uuid.transportDecrypt(connection.receiveKey, sequence, message.messageType, message.flags, message.requestId, ciphertext, receivedTag))
  uuid.wipeSecret(receivedTag)
  uuid.wipeSecret(ciphertext)
  if typeof(plaintext) == "error" then return fail(SECURE_TRANSPORT, "unprotectMessage", "secure authentication tag mismatch") end if
  connection.receiveSequence = connection.receiveSequence + 1
  return messages.create(message.messageType, message.flags & ~constants.FLAG_SECURE, message.requestId, plaintext)
end function

function decodeInbound(connection, frame)
  return unprotectMessage(connection, codec.decodeMessage(frame))
end function

function isPollResult(value)
  return value is PollResult
end function

function makeNonBlocking(connection)
  validateOpen(connection, "makeNonBlocking")
  network.setNonBlocking(connection.socket, true)
  return true
end function

function pollMessage(connection)
  validateOpen(connection, "pollMessage")
  buffered = try(extractBufferedMessage(connection))
  if typeof(buffered) == "error" then return buffered end if
  if buffered is not void then return buffered end if

  count = try(network.receiveAvailableInto(connection.socket, connection.receiveScratch, 0, len(connection.receiveScratch)))
  if typeof(count) == "error" then return count end if
  if count is void then return void end if
  if count == 0 then
    connection.peerClosed = true
    if len(connection.receiveBuffer) != 0 then return fail(INVALID_ARGUMENT, "pollMessage", "connection closed with a partial frame") end if
    return PollResult(void, true)
  end if

  appended = try(appendReceiveScratch(connection, count))
  if typeof(appended) == "error" then return appended end if
  return extractBufferedMessage(connection)
end function

function sendMessage(connection, message)
  validateOpen(connection, "sendMessage")
  outbound = protectMessage(connection, message)
  encoded = codec.encodeMessage(outbound)
  network.sendAll(connection.socket, encoded)
  return len(encoded)
end function

function receiveMessage(connection)
  validateOpen(connection, "receiveMessage")
  headerBytes = network.receiveExact(connection.socket, constants.HEADER_BYTES)
  header = codec.decodeHeader(headerBytes)
  payload = bytes(0)
  if header.payloadLength > 0 then payload = network.receiveExact(connection.socket, header.payloadLength) end if
  frame = bytes(constants.HEADER_BYTES + len(payload), 0)
  copyBytes(frame, 0, headerBytes, 0, constants.HEADER_BYTES)
  if len(payload) > 0 then copyBytes(frame, constants.HEADER_BYTES, payload, 0, len(payload)) end if
  return decodeInbound(connection, frame)
end function

function close(connection)
  validateOpen(connection, "close")
  network.close(connection.socket)
  if typeof(connection.sendKey) == "bytes" then uuid.wipeSecret(connection.sendKey) end if
  if typeof(connection.receiveKey) == "bytes" then uuid.wipeSecret(connection.receiveKey) end if
  connection.sendKey = void
  connection.receiveKey = void
  if typeof(connection.receiveScratch) == "bytes" then fillBytes(connection.receiveScratch, 0, len(connection.receiveScratch), 0) end if
  connection.receiveBuffer = bytes(0)
  connection.receiveScratch = bytes(0)
  connection.closed = true
  return true
end function

function componentName()
  return "protocol.connection"
end function

function targetMilestone()
  return "M18"
end function

function isImplemented()
  return true
end function
