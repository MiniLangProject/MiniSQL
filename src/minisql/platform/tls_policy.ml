//! Provides minisql platform tls policy facilities for this project.

package minisql.platform.tls_policy

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

/// This module is the fail-closed MiniSQL TLS profile. Schannel performs the

const INVALID_ARGUMENT = 9001
/// Defines the tls error constant used by the minisql platform tls policy module.
const TLS_ERROR = 9034
/// Defines the tls 1 2 legacy version constant used by the minisql platform tls policy module.
const TLS_1_2_LEGACY_VERSION = 0x0303
/// Defines the tls 1 3 version constant used by the minisql platform tls policy module.
const TLS_1_3_VERSION = 0x0304
/// Defines the tls aes 256 gcm sha384 id constant used by the minisql platform tls policy module.
const TLS_AES_256_GCM_SHA384_ID = 0x1302
/// Defines the x25519 id constant used by the minisql platform tls policy module.
const X25519_ID = 0x001D
/// Defines the tls handshake record constant used by the minisql platform tls policy module.
const TLS_HANDSHAKE_RECORD = 22
/// Defines the server hello message constant used by the minisql platform tls policy module.
const SERVER_HELLO_MESSAGE = 2
/// Defines the supported versions extension constant used by the minisql platform tls policy module.
const SUPPORTED_VERSIONS_EXTENSION = 0x002B
/// Defines the key share extension constant used by the minisql platform tls policy module.
const KEY_SHARE_EXTENSION = 0x0033
/// Defines the max handshake transcript bytes constant used by the minisql platform tls policy module.
const MAX_HANDSHAKE_TRANSCRIPT_BYTES = 262144

/// Describes one TLS 1.3 cipher suite independently of the platform provider.
struct TlsCipherSuite
  /// Two-byte IANA cipher-suite identifier carried in ServerHello.
  wireId
  /// Stable IANA cipher-suite name used by configuration and diagnostics.
  name
  /// AEAD primitive that protects TLS application records.
  aead
  /// Number of traffic-key bytes required by the AEAD primitive.
  keyBytes
  /// Number of static IV bytes used by the TLS record nonce construction.
  ivBytes
  /// Authentication-tag size emitted for every encrypted TLS record.
  tagBytes
  /// HKDF transcript hash selected by this TLS 1.3 cipher suite.
  hash
  /// Digest size of the selected transcript hash.
  hashBytes
end struct

/// Describes one TLS named group independently of the platform provider.
struct TlsNamedGroup
  /// Two-byte IANA NamedGroup identifier carried in the key_share extension.
  wireId
  /// Stable IANA group name used by configuration and diagnostics.
  name
  /// Key-agreement family used for security review and diagnostics.
  family
  /// Encoded public-key length expected in a ServerHello key share.
  publicKeyBytes
  /// Shared-secret length produced by the key agreement.
  sharedSecretBytes
end struct

/// Defines how a client authenticates the peer certificate.
struct CertificatePolicy
  /// Either `system` for Windows trust or `pin-sha256` for an exact leaf pin.
  mode
  /// DNS name checked against the certificate and sent as TLS SNI.
  serverName
  /// Exact SHA-256 digest of the leaf certificate DER, or empty for system trust.
  pinnedLeafSha256
end struct

/// Collects all independently extensible TLS policy dimensions.
struct TlsPolicy
  /// Minimum accepted TLS protocol version.
  minimumVersion
  /// Maximum accepted TLS protocol version.
  maximumVersion
  /// Explicit allow-list of accepted TLS 1.3 cipher suites.
  cipherSuites
  /// Explicit allow-list of accepted key-exchange groups.
  groups
  /// Peer certificate authentication policy used by a client.
  certificatePolicy
end struct

/// Captures the security-relevant plaintext fields selected by ServerHello.
struct ServerHelloSelection
  /// Version selected by the supported_versions extension.
  protocolVersion
  /// Cipher suite selected by the server.
  cipherSuiteId
  /// Named group selected by the server key_share extension.
  groupId
end struct

/// Creates a structured TLS-policy failure.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(operation, message)
  return error(TLS_ERROR, "platform.tls_policy." + operation + ": " + message)
end function

/// Returns the only cipher suite enabled by the MiniSQL 1.0 TLS profile.
function tlsAes256GcmSha384()
  return TlsCipherSuite(TLS_AES_256_GCM_SHA384_ID, "TLS_AES_256_GCM_SHA384", "AES-256-GCM", 32, 12, 16, "SHA-384", 48)
end function

/// Returns the only key-exchange group enabled by the MiniSQL 1.0 TLS profile.
function x25519()
  return TlsNamedGroup(X25519_ID, "X25519", "ECDHE Montgomery curve", 32, 32)
end function

/// Returns the complete compiled cipher registry; new versions extend this list.
function supportedCipherSuites()
  return [tlsAes256GcmSha384()]
end function

/// Returns the complete compiled named-group registry; new versions extend this list.
function supportedGroups()
  return [x25519()]
end function

/// Finds a registered cipher suite by its wire identifier.
/// @param wireId Identifier of wire.
function cipherSuiteById(wireId)
  if typeof(wireId) != "int" then return error(INVALID_ARGUMENT, "platform.tls_policy.cipherSuiteById: wireId must be int") end if
  suites = supportedCipherSuites()
  for index = 0 to len(suites) - 1
    if suites[index].wireId == wireId then return suites[index] end if
  end for
  return void
end function

/// Finds a registered named group by its wire identifier.
/// @param wireId Identifier of wire.
function groupById(wireId)
  if typeof(wireId) != "int" then return error(INVALID_ARGUMENT, "platform.tls_policy.groupById: wireId must be int") end if
  groups = supportedGroups()
  for index = 0 to len(groups) - 1
    if groups[index].wireId == wireId then return groups[index] end if
  end for
  return void
end function

/// Converts one ASCII hexadecimal digit to its numeric value.
/// @param value Value consumed or transformed by the operation.
function hexValue(value)
  if value >= 48 and value <= 57 then return value - 48 end if
  if value >= 65 and value <= 70 then return value - 55 end if
  if value >= 97 and value <= 102 then return value - 87 end if
  return -1
end function

/// Parses an exact SHA-256 certificate pin, accepting an optional sha256 prefix.
/// @param text Text consumed by the operation.
function parseSha256Pin(text)
  if typeof(text) != "string" then return error(INVALID_ARGUMENT, "platform.tls_policy.parseSha256Pin: pin must be string") end if
  raw = bytes(text)
  offset = 0
  if len(raw) == 71 and raw[0] == 115 and raw[1] == 104 and raw[2] == 97 and raw[3] == 50 and raw[4] == 53 and raw[5] == 54 and raw[6] == 58 then offset = 7 end if
  if len(raw) - offset != 64 then return error(INVALID_ARGUMENT, "platform.tls_policy.parseSha256Pin: pin must contain exactly 64 hexadecimal digits") end if
  result = bytes(32, 0)
  for index = 0 to 31
    high = hexValue(raw[offset + index * 2])
    low = hexValue(raw[offset + index * 2 + 1])
    if high < 0 or low < 0 then fillBytes(result, 0, len(result), 0); return error(INVALID_ARGUMENT, "platform.tls_policy.parseSha256Pin: pin contains non-hexadecimal data") end if
    result[index] = (high << 4) | low
  end for
  return result
end function

/// Builds Windows trust-store validation with mandatory DNS-name verification.
/// @param serverName serverName value consumed by this operation.
function systemCertificatePolicy(serverName)
  if typeof(serverName) != "string" or len(bytes(serverName)) == 0 then return error(INVALID_ARGUMENT, "platform.tls_policy.systemCertificatePolicy: serverName must be non-empty") end if
  return CertificatePolicy("system", serverName, bytes(0))
end function

/// Builds exact leaf-certificate pinning for private or self-signed deployments.
/// @param serverName serverName value consumed by this operation.
/// @param pinText pinText value consumed by this operation.
function pinnedCertificatePolicy(serverName, pinText)
  if typeof(serverName) != "string" or len(bytes(serverName)) == 0 then return error(INVALID_ARGUMENT, "platform.tls_policy.pinnedCertificatePolicy: serverName must be non-empty") end if
  pin = try(parseSha256Pin(pinText))
  if typeof(pin) == "error" then return pin end if
  return CertificatePolicy("pin-sha256", serverName, pin)
end function

/// Validates the complete policy without silently substituting algorithms.
/// @param policy policy value consumed by this operation.
function validate(policy)
  if policy is not TlsPolicy then return error(INVALID_ARGUMENT, "platform.tls_policy.validate: policy must be TlsPolicy") end if
  if policy.minimumVersion != TLS_1_3_VERSION or policy.maximumVersion != TLS_1_3_VERSION then return fail("validate", "MiniSQL requires TLS 1.3 exactly") end if
  if typeof(policy.cipherSuites) != "array" or len(policy.cipherSuites) == 0 then return fail("validate", "cipher-suite allow-list must not be empty") end if
  if typeof(policy.groups) != "array" or len(policy.groups) == 0 then return fail("validate", "named-group allow-list must not be empty") end if
  for index = 0 to len(policy.cipherSuites) - 1
    if policy.cipherSuites[index] is not TlsCipherSuite or cipherSuiteById(policy.cipherSuites[index].wireId) is void then return fail("validate", "cipher-suite allow-list contains an unsupported entry") end if
  end for
  for index = 0 to len(policy.groups) - 1
    if policy.groups[index] is not TlsNamedGroup or groupById(policy.groups[index].wireId) is void then return fail("validate", "named-group allow-list contains an unsupported entry") end if
  end for
  if policy.certificatePolicy is not CertificatePolicy then return fail("validate", "certificate policy is invalid") end if
  if policy.certificatePolicy.mode != "system" and policy.certificatePolicy.mode != "pin-sha256" then return fail("validate", "certificate mode is unsupported") end if
  if typeof(policy.certificatePolicy.serverName) != "string" or len(bytes(policy.certificatePolicy.serverName)) == 0 then return fail("validate", "certificate server name must be non-empty") end if
  if policy.certificatePolicy.mode == "pin-sha256" and (typeof(policy.certificatePolicy.pinnedLeafSha256) != "bytes" or len(policy.certificatePolicy.pinnedLeafSha256) != 32) then return fail("validate", "certificate pin must be a 32-byte SHA-256 digest") end if
  return true
end function

/// Creates the current default client policy using the Windows root store.
/// @param serverName serverName value consumed by this operation.
function defaultClientPolicy(serverName)
  certificatePolicy = try(systemCertificatePolicy(serverName))
  if typeof(certificatePolicy) == "error" then return certificatePolicy end if
  return TlsPolicy(TLS_1_3_VERSION, TLS_1_3_VERSION, [tlsAes256GcmSha384()], [x25519()], certificatePolicy)
end function

/// Creates the current client policy for exact SHA-256 certificate pinning.
/// @param serverName serverName value consumed by this operation.
/// @param pinText pinText value consumed by this operation.
function pinnedClientPolicy(serverName, pinText)
  certificatePolicy = try(pinnedCertificatePolicy(serverName, pinText))
  if typeof(certificatePolicy) == "error" then return certificatePolicy end if
  return TlsPolicy(TLS_1_3_VERSION, TLS_1_3_VERSION, [tlsAes256GcmSha384()], [x25519()], certificatePolicy)
end function

/// Creates the server-side algorithm policy; servers do not validate a peer certificate.
function defaultServerPolicy()
  return TlsPolicy(TLS_1_3_VERSION, TLS_1_3_VERSION, [tlsAes256GcmSha384()], [x25519()], CertificatePolicy("system", "server", bytes(0)))
end function

/// Appends a bounded handshake fragment without exposing unbounded allocations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function appendHandshakeBytes(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" then return error(INVALID_ARGUMENT, "platform.tls_policy.appendHandshakeBytes: values must be bytes") end if
  if len(left) > MAX_HANDSHAKE_TRANSCRIPT_BYTES - len(right) then return fail("appendHandshakeBytes", "TLS handshake transcript exceeds the safety bound") end if
  output = bytes(len(left) + len(right), 0)
  if len(left) > 0 then copyBytes(output, 0, left, 0, len(left)) end if
  if len(right) > 0 then copyBytes(output, len(left), right, 0, len(right)) end if
  return output
end function

/// Returns true for the RFC 8446 HelloRetryRequest sentinel random value.
/// @param body body value consumed by this operation.
function isHelloRetryRequest(body)
  expected = [207, 33, 173, 116, 229, 154, 97, 17, 190, 29, 140, 2, 30, 101, 184, 145, 194, 162, 17, 22, 122, 187, 140, 94, 7, 158, 9, 226, 200, 168, 51, 156]
  if len(body) < 34 then return false end if
  for index = 0 to 31
    if body[index + 2] != expected[index] then return false end if
  end for
  return true
end function

/// Parses one complete ServerHello body and returns only policy-relevant fields.
/// @param body body value consumed by this operation.
function parseServerHelloBody(body)
  if typeof(body) != "bytes" or len(body) < 40 then return fail("parseServerHelloBody", "ServerHello is truncated") end if
  if endian.readU16BE(body, 0) != TLS_1_2_LEGACY_VERSION then return fail("parseServerHelloBody", "ServerHello legacy_version is invalid") end if
  sessionLength = body[34]
  cipherOffset = 35 + sessionLength
  if cipherOffset > len(body) - 5 then return fail("parseServerHelloBody", "ServerHello session identifier is truncated") end if
  cipherSuiteId = endian.readU16BE(body, cipherOffset)
  if body[cipherOffset + 2] != 0 then return fail("parseServerHelloBody", "ServerHello compression method is not null") end if
  extensionBytes = endian.readU16BE(body, cipherOffset + 3)
  cursor = cipherOffset + 5
  if extensionBytes != len(body) - cursor then return fail("parseServerHelloBody", "ServerHello extension block length is invalid") end if
  selectedVersion = 0
  selectedGroup = 0
  while cursor < len(body)
    if cursor > len(body) - 4 then return fail("parseServerHelloBody", "ServerHello extension header is truncated") end if
    extensionType = endian.readU16BE(body, cursor)
    extensionLength = endian.readU16BE(body, cursor + 2)
    cursor = cursor + 4
    if cursor > len(body) - extensionLength then return fail("parseServerHelloBody", "ServerHello extension value is truncated") end if
    if extensionType == SUPPORTED_VERSIONS_EXTENSION then
      if extensionLength != 2 then return fail("parseServerHelloBody", "supported_versions selection is invalid") end if
      selectedVersion = endian.readU16BE(body, cursor)
    else if extensionType == KEY_SHARE_EXTENSION then
      if isHelloRetryRequest(body) then
        if extensionLength != 2 then return fail("parseServerHelloBody", "HelloRetryRequest key_share is invalid") end if
        selectedGroup = endian.readU16BE(body, cursor)
      else
        if extensionLength < 4 then return fail("parseServerHelloBody", "ServerHello key_share is truncated") end if
        selectedGroup = endian.readU16BE(body, cursor)
        keyLength = endian.readU16BE(body, cursor + 2)
        if keyLength != extensionLength - 4 then return fail("parseServerHelloBody", "ServerHello key_share length is invalid") end if
      end if
    end if
    cursor = cursor + extensionLength
  end while
  return ServerHelloSelection(selectedVersion, cipherSuiteId, selectedGroup)
end function

/// Extracts plaintext handshake payloads from complete TLS records in one direction.
/// @param transcript transcript value consumed by this operation.
function collectHandshakeMessages(transcript)
  if typeof(transcript) != "bytes" then return error(INVALID_ARGUMENT, "platform.tls_policy.collectHandshakeMessages: transcript must be bytes") end if
  if len(transcript) > MAX_HANDSHAKE_TRANSCRIPT_BYTES then return fail("collectHandshakeMessages", "TLS handshake transcript exceeds the safety bound") end if
  messages = bytes(0)
  cursor = 0
  while cursor <= len(transcript) - 5
    recordLength = endian.readU16BE(transcript, cursor + 3)
    if recordLength > 18432 then return fail("collectHandshakeMessages", "TLS record exceeds the protocol bound") end if
    if cursor + 5 > len(transcript) - recordLength then break end if
    if transcript[cursor] == TLS_HANDSHAKE_RECORD and recordLength > 0 then
      payload = slice(transcript, cursor + 5, recordLength)
      messages = try(appendHandshakeBytes(messages, payload))
      if typeof(messages) == "error" then return messages end if
    end if
    cursor = cursor + 5 + recordLength
  end while
  return messages
end function

/// Finds the final non-HelloRetryRequest ServerHello in a directional transcript.
/// @param transcript transcript value consumed by this operation.
function serverHelloSelection(transcript)
  handshake = try(collectHandshakeMessages(transcript))
  if typeof(handshake) == "error" then return handshake end if
  cursor = 0
  selected = void
  while cursor <= len(handshake) - 4
    messageLength = (handshake[cursor + 1] << 16) | (handshake[cursor + 2] << 8) | handshake[cursor + 3]
    if cursor + 4 > len(handshake) - messageLength then return void end if
    if handshake[cursor] == SERVER_HELLO_MESSAGE then
      body = slice(handshake, cursor + 4, messageLength)
      parsed = try(parseServerHelloBody(body))
      if typeof(parsed) == "error" then return parsed end if
      if not isHelloRetryRequest(body) then selected = parsed end if
    end if
    cursor = cursor + 4 + messageLength
  end while
  return selected
end function

/// Returns whether a cipher suite is explicitly allowed by the policy.
/// @param policy policy value consumed by this operation.
/// @param wireId Identifier of wire.
function cipherAllowed(policy, wireId)
  for index = 0 to len(policy.cipherSuites) - 1
    if policy.cipherSuites[index].wireId == wireId then return true end if
  end for
  return false
end function

/// Returns whether a named group is explicitly allowed by the policy.
/// @param policy policy value consumed by this operation.
/// @param wireId Identifier of wire.
function groupAllowed(policy, wireId)
  for index = 0 to len(policy.groups) - 1
    if policy.groups[index].wireId == wireId then return true end if
  end for
  return false
end function

/// Enforces the negotiated ServerHello against every fail-closed policy dimension.
/// @param policy policy value consumed by this operation.
/// @param transcript transcript value consumed by this operation.
function verifyServerHello(policy, transcript)
  valid = try(validate(policy))
  if typeof(valid) == "error" then return valid end if
  selection = try(serverHelloSelection(transcript))
  if typeof(selection) == "error" then return selection end if
  if selection is void then return fail("verifyServerHello", "a complete plaintext ServerHello was not observed") end if
  if selection.protocolVersion != TLS_1_3_VERSION then return fail("verifyServerHello", "TLS 1.3 was not selected") end if
  if not cipherAllowed(policy, selection.cipherSuiteId) then return fail("verifyServerHello", "server selected a forbidden cipher suite: " + selection.cipherSuiteId) end if
  if not groupAllowed(policy, selection.groupId) then return fail("verifyServerHello", "server selected a forbidden key-exchange group: " + selection.groupId) end if
  group = groupById(selection.groupId)
  if group is TlsNamedGroup and group.publicKeyBytes == 32 then
    accepted = true
  end if
  return selection
end function

/// Returns the stable module name used by diagnostics and documentation.
function componentName()
  return "platform.tls_policy"
end function

/// Returns the implementation milestone for native TLS 1.3.
function targetMilestone()
  return "M73"
end function

/// Reports that the native TLS policy implementation is available.
function isImplemented()
  return true
end function

