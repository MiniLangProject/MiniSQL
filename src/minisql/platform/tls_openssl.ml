//! Provides minisql platform tls openssl facilities for this project.

package minisql.platform.tls_openssl
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.tls._openssl as openssl
import minisql.platform.tls_policy as tls_policy
import minisql.platform.network as network

/// OpenSSL-backed compatibility adapter for MiniSQL's established Schannel
const INVALID_ARGUMENT = 9001
/// Defines the tls error constant used by the minisql platform tls openssl module.
const TLS_ERROR = 9034

/// Owns immutable OpenSSL server options until listener shutdown.
struct ServerCredential
  /// Certificate, private-key, client-auth, and protocol settings.
  options
  /// True after the listener has released this credential.
  closed
end struct

/// Owns one established OpenSSL TLS stream.
struct TlsContext
  /// Native `std.tls._openssl` stream wrapper.
  stream
  /// True after the stream has been closed.
  closed
end struct

/// These option records mirror the backend-neutral std.tls contract without
/// importing its conditional facade into a Linux-only adapter.
struct ClientOptions
  /// DNS name required for SNI and hostname validation.
  serverName
  /// Whether the server certificate chain must be verified.
  verifyPeer
  /// Optional exact SHA-256 leaf pin bytes.
  sha256Pin
  /// Minimum TLS protocol version.
  minimumVersion
  /// Optional explicit CA bundle path.
  caFile
end struct

/// Describes the server certificate and protocol settings passed to OpenSSL.
struct ServerOptions
  /// PEM certificate-chain path.
  certificateReference
  /// PEM private-key path.
  privateKeyReference
  /// Whether the server requires a client certificate.
  requireClientCertificate
  /// Minimum encoded TLS protocol version.
  minimumVersion
end struct

/// Creates a stable MiniSQL TLS error with provider context.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(TLS_ERROR, "platform.tls_openssl." + operation + ": " + message)
end function

/// Reports whether a value is an OpenSSL server credential.
/// @param value Value consumed or transformed by the operation.
function isCredential(value) return value is ServerCredential end function
/// Reports whether a value is an open OpenSSL TLS context.
/// @param value Value consumed or transformed by the operation.
function isTlsContext(value) return value is TlsContext and not value.closed end function

/// Performs a verified TLS client handshake using system trust and hostname checks.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
function connectClient(socketHandle, serverName)
  options = ClientOptions(serverName, true, void, "1.3", void)
  stream = try(openssl.openClient(socketHandle, options))
  if typeof(stream) == "error" then return fail("connectClient", stream.message) end if
  return TlsContext(stream, false)
end function

/// Performs a verified TLS client handshake with an additional exact leaf pin.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param serverName serverName value consumed by this operation.
/// @param pinText pinText value consumed by this operation.
function connectClientPinned(socketHandle, serverName, pinText)
  pin = try(tls_policy.parseSha256Pin(pinText))
  if typeof(pin) == "error" then return pin end if
  options = ClientOptions(serverName, true, pin, "1.3", void)
  stream = try(openssl.openClient(socketHandle, options))
  if typeof(stream) == "error" then return fail("connectClientPinned", stream.message) end if
  return TlsContext(stream, false)
end function

/// Parses the Linux `pem:certificate|private-key` server reference.
/// @param certificateReference certificateReference value consumed by this operation.
function splitPemReference(certificateReference)
  if typeof(certificateReference) != "string" or len(certificateReference) == 0 then return fail("splitPemReference", "certificate reference must be non-empty") end if
  raw = bytes(certificateReference)
  start = 0
  if len(raw) >= 4 and raw[0] == 112 and raw[1] == 101 and raw[2] == 109 and raw[3] == 58 then start = 4 end if
  separator = -1
  index = start
  while index < len(raw)
    if raw[index] == 124 then separator = index; break end if
    index = index + 1
  end while
  if separator <= start or separator + 1 >= len(raw) then return fail("splitPemReference", "Linux TLS certificate reference must be pem:CERT_PATH|KEY_PATH") end if
  certificatePath = decode(slice(raw, start, separator - start))
  privateKeyPath = decode(slice(raw, separator + 1, len(raw) - separator - 1))
  if typeof(certificatePath) != "string" or typeof(privateKeyPath) != "string" then return fail("splitPemReference", "certificate paths must be UTF-8") end if
  return [certificatePath, privateKeyPath]
end function

/// Rejects credential acquisition without an explicit Linux PEM reference.
function acquireServerCredential()
  return fail("acquireServerCredential", "a PEM certificate and private key are required on Linux")
end function

/// Creates server options from an unencrypted PEM certificate and key reference.
/// @param certificateReference certificateReference value consumed by this operation.
/// @param passwordBytes passwordBytes value consumed by this operation.
function acquireServerCredentialWithPassword(certificateReference, passwordBytes)
  if passwordBytes is not void and (typeof(passwordBytes) != "bytes" or len(passwordBytes) != 0) then
    return fail("acquireServerCredentialWithPassword", "encrypted PEM private keys are not supported")
  end if
  paths = splitPemReference(certificateReference)
  if typeof(paths) == "error" then return paths end if
  options = ServerOptions(paths[0], paths[1], false, "1.3")
  return ServerCredential(options, false)
end function

/// Marks a server credential closed after listener shutdown.
/// @param credential credential value consumed by this operation.
function closeCredential(credential)
  if credential is not ServerCredential then return error(INVALID_ARGUMENT, "platform.tls_openssl.closeCredential: invalid credential") end if
  credential.closed = true
  return true
end function

/// Accepts one TLS server stream on an already connected socket.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param credential credential value consumed by this operation.
function acceptServer(socketHandle, credential)
  if credential is not ServerCredential or credential.closed then return error(INVALID_ARGUMENT, "platform.tls_openssl.acceptServer: open server credential required") end if
  stream = try(openssl.openServer(socketHandle, credential.options))
  if typeof(stream) == "error" then return fail("acceptServer", stream.message) end if
  return TlsContext(stream, false)
end function

/// Sends the complete byte buffer over an established TLS stream.
/// @param context Context that carries state for the operation.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param data Input data consumed by the operation.
function sendAll(context, socketHandle, data)
  if not isTlsContext(context) then return error(INVALID_ARGUMENT, "platform.tls_openssl.sendAll: invalid TLS context") end if
  result = try(openssl.sendBytes(context.stream, data))
  if typeof(result) == "error" then return fail("sendAll", result.message) end if
  return result
end function

/// Receives up to the requested bounded count from a TLS stream.
/// @param context Context that carries state for the operation.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param maximum maximum value consumed by this operation.
function receiveAvailable(context, socketHandle, maximum)
  if not isTlsContext(context) then return error(INVALID_ARGUMENT, "platform.tls_openssl.receiveAvailable: invalid TLS context") end if
  if typeof(maximum) != "int" or maximum < 1 or maximum > network.MAX_RECEIVE_BYTES then return error(INVALID_ARGUMENT, "platform.tls_openssl.receiveAvailable: maximum is invalid") end if
  result = try(openssl.receiveBytes(context.stream, maximum))
  if typeof(result) == "error" then return fail("receiveAvailable", result.message) end if
  return result
end function

/// Receives exactly the requested count or reports premature connection closure.
/// @param context Context that carries state for the operation.
/// @param socketHandle socketHandle value consumed by this operation.
/// @param count Number of items or units to process.
function receiveExact(context, socketHandle, count)
  if not isTlsContext(context) then return error(INVALID_ARGUMENT, "platform.tls_openssl.receiveExact: invalid TLS context") end if
  if typeof(count) != "int" or count < 0 or count > network.MAX_RECEIVE_BYTES then return error(INVALID_ARGUMENT, "platform.tls_openssl.receiveExact: count is invalid") end if
  output = bytes(count, 0)
  cursor = 0
  while cursor < count
    incoming = try(openssl.receiveBytes(context.stream, count - cursor))
    if typeof(incoming) == "error" then return fail("receiveExact", incoming.message) end if
    if len(incoming) == 0 then return fail("receiveExact", "connection closed before frame completed") end if
    copyBytes(output, cursor, incoming, 0, len(incoming))
    cursor = cursor + len(incoming)
  end while
  return output
end function

/// Sends and receives the provider's authenticated TLS shutdown notification.
/// @param context Context that carries state for the operation.
/// @param socketHandle socketHandle value consumed by this operation.
function shutdown(context, socketHandle)
  if context is not TlsContext then return error(INVALID_ARGUMENT, "platform.tls_openssl.shutdown: invalid TLS context") end if
  if context.closed then return true end if
  result = try(openssl.shutdownStream(context.stream))
  if typeof(result) == "error" then return fail("shutdown", result.message) end if
  return true
end function

/// Releases one TLS stream and marks the wrapper closed.
/// @param context Context that carries state for the operation.
function closeContext(context)
  if context is not TlsContext then return error(INVALID_ARGUMENT, "platform.tls_openssl.closeContext: invalid TLS context") end if
  if context.closed then return true end if
  result = try(openssl.closeStream(context.stream))
  context.closed = true
  if typeof(result) == "error" then return fail("closeContext", result.message) end if
  return true
end function

/// Returns the diagnostic provider name.
function providerName() return "OpenSSL 3" end function

/// Returns the stable diagnostic name used by the module catalog.
function componentName()
  return "platform.tls_openssl"
end function

/// Returns the milestone whose TLS contract this provider implements.
function targetMilestone()
  return "M73"
end function

/// Reports that the OpenSSL backend is complete.
function isImplemented()
  return true
end function
