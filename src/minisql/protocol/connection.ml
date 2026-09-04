//! Provides minisql protocol connection facilities for this project.

package minisql.protocol.connection

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.platform.network as network
#if TARGET_OS == "windows"
import minisql.platform.tls_schannel as tls_schannel
#else
import minisql.platform.tls_openssl as tls_schannel
#endif
import minisql.common.uuid as uuid
import minisql.common.endian as endian
import minisql.protocol.codec as codec
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

/// Defines the invalid argument constant used by the minisql protocol connection module.
const INVALID_ARGUMENT = 9001
/// Defines the closed handle constant used by the minisql protocol connection module.
const CLOSED_HANDLE = 9008
/// Defines the corrupt data constant used by the minisql protocol connection module.
const CORRUPT_DATA = 9004
/// Defines the secure transport constant used by the minisql protocol connection module.
const SECURE_TRANSPORT = 9030
/// Defines the poll receive bytes constant used by the minisql protocol connection module.
const POLL_RECEIVE_BYTES = 65536

/// Owns framed-protocol state for one TCP socket. Receive buffering permits
/// fragmented and coalesced frames; secure sequence counters must advance exactly
/// once per authenticated frame to prevent replay or reordering.
struct Connection
  /// Native socket handle owned until `close`.
  socket
  /// Prevents operations and duplicate cleanup after close.
  closed
  /// Unconsumed bytes that may contain partial or multiple frames.
  receiveBuffer
  /// Fixed-capacity buffer reused by nonblocking receives.
  receiveScratch
  /// Records a clean zero-byte receive from the peer.
  peerClosed
  /// Requires every subsequent payload to use authenticated transport protection.
  secure
  /// 256-bit key for outbound authenticated encryption.
  sendKey
  /// 256-bit key for inbound authenticated decryption.
  receiveKey
  /// Sequence number bound into the next outbound secure frame.
  sendSequence
  /// Only sequence number accepted for the next inbound secure frame.
  receiveSequence
  /// Indicates that native TLS record protection is active below framing.
  tls
  /// Schannel context that owns TLS keys and encrypted record buffers.
  tlsContext
  /// Framed protocol bytes successfully handed to the transport.
  bytesSent
  /// Framed protocol bytes obtained from the transport.
  bytesReceived
end struct

/// Groups the poll result state and preserves the field relationships documented below.
struct PollResult
  /// Stores the message associated with this value.
  message
  /// Indicates whether the closed condition is active.
  closed
end struct

/// Performs the fail operation for the minisql protocol connection module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "protocol.connection." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the connection condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isConnection(value)
  return value is Connection
end function

/// Creates create for the minisql protocol connection module.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param socketHandle socketHandle value consumed by this operation.
function create(socketHandle)
  if not network.isHandle(socketHandle) then return fail(INVALID_ARGUMENT, "create", "socket handle is invalid") end if
  return Connection(socketHandle, false, bytes(0), bytes(POLL_RECEIVE_BYTES, 0), false, false, void, void, 0, 0, false, void, 0, 0)
end function

/// Connects address using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
function connectAddress(address, port)
  return create(network.connectTcp(address, port))
end function

/// Connects a TCP socket and completes native TLS with Windows root-store trust.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
function connectTlsAddress(address, port, serverName)
  socketHandle = try(network.connectTcp(address, port))
  if typeof(socketHandle) == "error" then return socketHandle end if
  tlsContext = try(tls_schannel.connectClient(socketHandle, serverName))
  if typeof(tlsContext) == "error" then ignoredClose = try(network.close(socketHandle)); return tlsContext end if
  active = create(socketHandle)
  enabled = try(enableTls(active, tlsContext))
  if typeof(enabled) == "error" then ignoredContext = try(tls_schannel.closeContext(tlsContext)); ignoredClose = try(network.close(socketHandle)); return enabled end if
  return active
end function

/// Connects native TLS using an exact SHA-256 leaf pin for private certificates.
/// @param address address value consumed by this operation.
/// @param port port value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
/// @param pinText pinText value consumed by this operation.
function connectTlsPinnedAddress(address, port, serverName, pinText)
  socketHandle = try(network.connectTcp(address, port))
  if typeof(socketHandle) == "error" then return socketHandle end if
  tlsContext = try(tls_schannel.connectClientPinned(socketHandle, serverName, pinText))
  if typeof(tlsContext) == "error" then ignoredClose = try(network.close(socketHandle)); return tlsContext end if
  active = create(socketHandle)
  enabled = try(enableTls(active, tlsContext))
  if typeof(enabled) == "error" then ignoredContext = try(tls_schannel.closeContext(tlsContext)); ignoredClose = try(network.close(socketHandle)); return enabled end if
  return active
end function

/// Connects loopback using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param port port value consumed by this operation.
function connectLoopback(port)
  return connectAddress("127.0.0.1", port)
end function

/// Applies bounded socket I/O while a caller performs a protocol phase such as
/// the initial HELLO exchange. Passing zero restores normal unbounded query I/O.
/// @param connection connection value consumed by this operation.
/// @param receiveMs receiveMs value consumed by this operation.
/// @param sendMs sendMs value consumed by this operation.
function setTimeouts(connection, receiveMs, sendMs)
  validateOpen(connection, "setTimeouts")
  return network.setTimeouts(connection.socket, receiveMs, sendMs)
end function

/// Validates open for the minisql protocol connection workflow.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param connection connection value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateOpen(connection, operation)
  if connection is not Connection then return fail(INVALID_ARGUMENT, operation, "connection must be Connection") end if
  if connection.closed then return fail(CLOSED_HANDLE, operation, "connection is closed") end if
  return true
end function

/// Implements copy range for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param source source value consumed by this operation.
/// @param offset Zero-based offset at which processing starts.
/// @param count Number of items or units to process.
/// @param operation operation value consumed by this operation.
function copyRange(source, offset, count, operation)
  copied = try(network.copyByteRange(source, offset, count, operation))
  if typeof(copied) == "error" then return copied end if
  if typeof(copied) != "bytes" then return fail(CORRUPT_DATA, operation, "byte range materialization did not return bytes") end if
  return copied
end function

/// Appends receive scratch using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
/// @param count Number of items or units to process.
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

/// Appends plaintext obtained from Schannel while preserving the frame memory bound.
/// @param connection connection value consumed by this operation.
/// @param incoming incoming value consumed by this operation.
function appendReceiveBytes(connection, incoming)
  if typeof(incoming) != "bytes" then return fail(INVALID_ARGUMENT, "appendReceiveBytes", "incoming must be bytes") end if
  previousLength = len(connection.receiveBuffer)
  maximumBuffered = constants.HEADER_BYTES + constants.MAX_PAYLOAD_BYTES + POLL_RECEIVE_BYTES
  if previousLength > maximumBuffered - len(incoming) then return fail(CORRUPT_DATA, "appendReceiveBytes", "receive buffer exceeds bounded frame window") end if
  combined = bytes(previousLength + len(incoming), 0)
  if previousLength > 0 then copyBytes(combined, 0, connection.receiveBuffer, 0, previousLength) end if
  if len(incoming) > 0 then copyBytes(combined, previousLength, incoming, 0, len(incoming)) end if
  connection.receiveBuffer = combined
  return true
end function

/// Implements extract buffered message for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
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


/// Implements enable secure for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
/// @param sendKey sendKey value consumed by this operation.
/// @param receiveKey receiveKey value consumed by this operation.
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

/// Attaches a completed Schannel context below the MiniSQL framed protocol.
/// @param connection connection value consumed by this operation.
/// @param tlsContext tlsContext value consumed by this operation.
function enableTls(connection, tlsContext)
  validateOpen(connection, "enableTls")
  if not tls_schannel.isTlsContext(tlsContext) then return fail(INVALID_ARGUMENT, "enableTls", "TLS context is invalid") end if
  if connection.tls then return fail(INVALID_ARGUMENT, "enableTls", "TLS transport is already active") end if
  connection.tlsContext = tlsContext
  connection.tls = true
  return true
end function

/// Implements secure active for this module.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param connection connection value consumed by this operation.
function secureActive(connection)
  validateOpen(connection, "secureActive")
  return connection.secure
end function

/// Reports whether native TLS record protection is active.
/// @param connection connection value consumed by this operation.
function tlsActive(connection)
  validateOpen(connection, "tlsActive")
  return connection.tls
end function

/// Implements protect message for this module.
/// Returns the computed value or operation status.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
/// @param message Human-readable message associated with the operation.
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

/// Implements unprotect message for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
/// @param message Human-readable message associated with the operation.
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

/// Decodes inbound using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param connection connection value consumed by this operation.
/// @param frame frame value consumed by this operation.
function decodeInbound(connection, frame)
  return unprotectMessage(connection, codec.decodeMessage(frame))
end function

/// Returns whether the supplied value satisfies the poll result condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isPollResult(value)
  return value is PollResult
end function

/// Creates non blocking using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param connection connection value consumed by this operation.
function makeNonBlocking(connection)
  validateOpen(connection, "makeNonBlocking")
  network.setNonBlocking(connection.socket, true)
  return true
end function

/// Attempts one nonblocking framed receive.
/// Returns PollResult when a complete frame or clean EOF is available, void when
/// more bytes are needed, or an error for malformed/truncated/transport input.
/// @param connection connection value consumed by this operation.
function pollMessage(connection)
  validateOpen(connection, "pollMessage")
  buffered = try(extractBufferedMessage(connection))
  if typeof(buffered) == "error" then return buffered end if
  if buffered is not void then return buffered end if

  if connection.tls then
    incoming = try(tls_schannel.receiveAvailable(connection.tlsContext, connection.socket, len(connection.receiveScratch)))
    if typeof(incoming) == "error" then return incoming end if
    if incoming is void then return void end if
    if len(incoming) == 0 then
      connection.peerClosed = true
      if len(connection.receiveBuffer) != 0 then return fail(INVALID_ARGUMENT, "pollMessage", "TLS connection closed with a partial frame") end if
      return PollResult(void, true)
    end if
    connection.bytesReceived = connection.bytesReceived + len(incoming)
    appendedTls = try(appendReceiveBytes(connection, incoming))
    if typeof(appendedTls) == "error" then return appendedTls end if
    return extractBufferedMessage(connection)
  end if

  count = try(network.receiveAvailableInto(connection.socket, connection.receiveScratch, 0, len(connection.receiveScratch)))
  if typeof(count) == "error" then return count end if
  if count is void then return void end if
  if count == 0 then
    connection.peerClosed = true
    if len(connection.receiveBuffer) != 0 then return fail(INVALID_ARGUMENT, "pollMessage", "connection closed with a partial frame") end if
    return PollResult(void, true)
  end if

  connection.bytesReceived = connection.bytesReceived + count
  appended = try(appendReceiveScratch(connection, count))
  if typeof(appended) == "error" then return appended end if
  return extractBufferedMessage(connection)
end function

/// Sends message using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param connection connection value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function sendMessage(connection, message)
  validateOpen(connection, "sendMessage")
  outbound = protectMessage(connection, message)
  encoded = codec.encodeMessage(outbound)
  if connection.tls then
    tls_schannel.sendAll(connection.tlsContext, connection.socket, encoded)
  else
    network.sendAll(connection.socket, encoded)
  end if
  connection.bytesSent = connection.bytesSent + len(encoded)
  return len(encoded)
end function

/// Receives message using the supplied inputs.
/// Returns the computed value or operation status.
/// Performs I/O through its file, transport, or storage dependencies.
/// @param connection connection value consumed by this operation.
function receiveMessage(connection)
  validateOpen(connection, "receiveMessage")
  headerBytes = void
  if connection.tls then headerBytes = tls_schannel.receiveExact(connection.tlsContext, connection.socket, constants.HEADER_BYTES) else headerBytes = network.receiveExact(connection.socket, constants.HEADER_BYTES) end if
  header = codec.decodeHeader(headerBytes)
  payload = bytes(0)
  if header.payloadLength > 0 then
    if connection.tls then payload = tls_schannel.receiveExact(connection.tlsContext, connection.socket, header.payloadLength) else payload = network.receiveExact(connection.socket, header.payloadLength) end if
  end if
  connection.bytesReceived = connection.bytesReceived + constants.HEADER_BYTES + len(payload)
  frame = bytes(constants.HEADER_BYTES + len(payload), 0)
  copyBytes(frame, 0, headerBytes, 0, constants.HEADER_BYTES)
  if len(payload) > 0 then copyBytes(frame, constants.HEADER_BYTES, payload, 0, len(payload)) end if
  return decodeInbound(connection, frame)
end function

/// Returns framed protocol bytes written by this connection. TLS record overhead
/// is deliberately excluded so plain and protected protocol workloads compare.
/// @param connection connection value consumed by this operation.
function protocolBytesSent(connection)
  validateOpen(connection, "protocolBytesSent")
  return connection.bytesSent
end function

/// Returns framed protocol bytes read by this connection.
/// @param connection connection value consumed by this operation.
function protocolBytesReceived(connection)
  validateOpen(connection, "protocolBytesReceived")
  return connection.bytesReceived
end function

/// Closes close owned by the minisql protocol connection module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// May mutate supplied state and perform I/O through its dependencies.
/// @param connection connection value consumed by this operation.
function close(connection)
  validateOpen(connection, "close")
  shutdownResult = true
  tlsCloseResult = true
  if connection.tls and connection.tlsContext is not void then
    shutdownResult = try(tls_schannel.shutdown(connection.tlsContext, connection.socket))
    tlsCloseResult = try(tls_schannel.closeContext(connection.tlsContext))
  end if
  socketCloseResult = try(network.close(connection.socket))
  if typeof(connection.sendKey) == "bytes" then uuid.wipeSecret(connection.sendKey) end if
  if typeof(connection.receiveKey) == "bytes" then uuid.wipeSecret(connection.receiveKey) end if
  connection.sendKey = void
  connection.receiveKey = void
  if typeof(connection.receiveScratch) == "bytes" then fillBytes(connection.receiveScratch, 0, len(connection.receiveScratch), 0) end if
  connection.receiveBuffer = bytes(0)
  connection.receiveScratch = bytes(0)
  connection.tls = false
  connection.tlsContext = void
  connection.closed = true
  if typeof(shutdownResult) == "error" then return shutdownResult end if
  if typeof(tlsCloseResult) == "error" then return tlsCloseResult end if
  if typeof(socketCloseResult) == "error" then return socketCloseResult end if
  return true
end function

/// Aborts a potentially desynchronized transport without sending TLS or protocol shutdown data.
/// @param connection connection value consumed by this operation.
function abort(connection)
  if connection is not Connection then return fail(INVALID_ARGUMENT, "abort", "connection must be Connection") end if
  if connection.closed then return true end if
  socketCloseResult = try(network.close(connection.socket))
  tlsCloseResult = true
  if connection.tls and connection.tlsContext is not void then tlsCloseResult = try(tls_schannel.closeContext(connection.tlsContext)) end if
  if typeof(connection.sendKey) == "bytes" then uuid.wipeSecret(connection.sendKey) end if
  if typeof(connection.receiveKey) == "bytes" then uuid.wipeSecret(connection.receiveKey) end if
  connection.sendKey = void
  connection.receiveKey = void
  if typeof(connection.receiveScratch) == "bytes" then fillBytes(connection.receiveScratch, 0, len(connection.receiveScratch), 0) end if
  connection.receiveBuffer = bytes(0)
  connection.receiveScratch = bytes(0)
  connection.tls = false
  connection.tlsContext = void
  connection.closed = true
  if typeof(socketCloseResult) == "error" then return socketCloseResult end if
  if typeof(tlsCloseResult) == "error" then return tlsCloseResult end if
  return true
end function

/// Performs the componentName operation for the minisql protocol connection module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "protocol.connection"
end function

/// Performs the targetMilestone operation for the minisql protocol connection module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql protocol connection module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
