package minisql.security.key_provider
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.common.uuid as uuid
import minisql.platform.file as file_api
import std.crypto.aes_gcm as aes_gcm

// The envelope is deliberately provider- and algorithm-tagged. Adding an OS
// keystore or KMS only requires another provider implementation; paged files,
// WAL and backup code consume the same unwrapped DatabaseKey.
const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004
const IO_FAILURE = 9005
const AUTHENTICATION_FAILED = 9027

const PROVIDER_FILE = 1
const WRAP_AES_256_GCM = 1
const META_VERSION = 1
const META_FIXED_BYTES = 112
const META_MAX_BYTES = 8192

// Describes one external key source without embedding secret bytes.
struct KeyProvider
  // Stable provider-kind discriminator.
  kind
  // Provider-specific key identifier or path.
  identifier
end struct

// Owns one unwrapped wipeable DEK and its envelope identity.
struct DatabaseKey
  // Root directory containing the database envelope.
  databaseRoot
  // Immutable 16-byte database identifier.
  databaseId
  // Provider used to unwrap the DEK.
  provider
  // Mutable 32-byte DEK that must be wiped after use.
  key
end struct

// Creates a structured key-provider error.
function fail(code, operation, message)
  return error(code, "security.key_provider." + operation + ": " + message)
end function

// Returns the UTF-8 parent path without filesystem-dependent normalization.
function parentPath(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "parentPath", "path must be non-empty") end if
  raw = bytes(path)
  index = len(raw) - 1
  while index >= 0 and raw[index] != 47 and raw[index] != 92
    index = index - 1
  end while
  if index <= 0 then return void end if
  decoded = decode(slice(raw, 0, index))
  if typeof(decoded) != "string" then return fail(INVALID_ARGUMENT, "parentPath", "path is not UTF-8") end if
  return decoded
end function

// Returns the fixed database envelope path.
function metadataPath(databaseRoot)
  return file_api.joinPath(databaseRoot, "encryption.meta")
end function

// Searches a small bounded ancestor chain so catalog, table, index, WAL and
// temporary paths all resolve the database-level key envelope consistently.
// Finds the nearest ancestor containing an encryption envelope.
function findDatabaseRoot(path)
  current = path
  for depth = 0 to 4
    if file_api.fileExists(metadataPath(current)) then return current end if
    current = parentPath(current)
    if current is void then return void end if
  end for
  return void
end function

// Creates the version-1 raw-file key provider descriptor.
function fileProvider(path)
  if typeof(path) != "string" or len(path) == 0 then return fail(INVALID_ARGUMENT, "fileProvider", "key path must be non-empty") end if
  return KeyProvider(PROVIDER_FILE, path)
end function

// Loads one wipeable 256-bit KEK from the selected provider.
function loadProviderKey(provider)
  if provider is not KeyProvider then return fail(INVALID_ARGUMENT, "loadProviderKey", "provider is invalid") end if
  if provider.kind != PROVIDER_FILE then return fail(UNSUPPORTED_FORMAT, "loadProviderKey", "provider kind is not installed") end if
  key = try(file_api.readAllBytes(provider.identifier, 32))
  if typeof(key) == "error" then return key end if
  if len(key) != 32 then uuid.wipeSecret(key); return fail(INVALID_ARGUMENT, "loadProviderKey", "key file must contain exactly 32 random bytes") end if
  return key
end function

// Creates domain-separated AAD for one DEK envelope.
function envelopeAad(databaseId, providerKind, providerIdentifier)
  return bytes("MiniSQL-TDE-1|") + databaseId + bytes("|" + providerKind + "|") + bytes(providerIdentifier)
end function

// Wraps a DEK and serializes authenticated crypto-agile metadata.
function encodeEnvelope(databaseId, provider, databaseKey)
  if typeof(databaseId) != "bytes" or len(databaseId) != 16 or provider is not KeyProvider or typeof(databaseKey) != "bytes" or len(databaseKey) != 32 then return fail(INVALID_ARGUMENT, "encodeEnvelope", "invalid envelope input") end if
  identifier = bytes(provider.identifier)
  if len(identifier) == 0 or len(identifier) > META_MAX_BYTES - META_FIXED_BYTES then return fail(INVALID_ARGUMENT, "encodeEnvelope", "provider identifier is too long") end if
  wrappingKey = try(loadProviderKey(provider))
  if typeof(wrappingKey) == "error" then return wrappingKey end if
  nonce = try(uuid.randomBytes(12))
  if typeof(nonce) == "error" then uuid.wipeSecret(wrappingKey); return nonce end if
  aad = envelopeAad(databaseId, provider.kind, provider.identifier)
  wrapped = try(aes_gcm.seal(wrappingKey, nonce, databaseKey, aad, 16))
  uuid.wipeSecret(wrappingKey)
  uuid.wipeSecret(aad)
  if typeof(wrapped) == "error" then uuid.wipeSecret(nonce); return wrapped end if
  output = bytes(META_FIXED_BYTES + len(identifier), 0)
  copyBytes(output, 0, bytes("MSTDE001"), 0, 8)
  endian.writeU16LE(output, 8, META_VERSION)
  endian.writeU16LE(output, 10, META_FIXED_BYTES)
  endian.writeU16LE(output, 12, provider.kind)
  endian.writeU16LE(output, 14, WRAP_AES_256_GCM)
  endian.writeU32LE(output, 16, len(identifier))
  copyBytes(output, 20, databaseId, 0, 16)
  copyBytes(output, 36, nonce, 0, 12)
  copyBytes(output, 48, wrapped, 0, 48)
  endian.writeU32LE(output, 96, 0)
  copyBytes(output, META_FIXED_BYTES, identifier, 0, len(identifier))
  endian.writeU32LE(output, 96, crc32c.compute(output))
  uuid.wipeSecret(nonce)
  uuid.wipeSecret(wrapped)
  return output
end function

// Validates and unwraps one serialized DEK envelope. A provider override lets
// portable backup restore use identical key bytes from a new machine-local
// path while the original provider identity remains part of authenticated AAD.
function decodeEnvelopeData(databaseRoot, encoded, providerOverride)
  if typeof(encoded) != "bytes" or len(encoded) > META_MAX_BYTES then return fail(INVALID_ARGUMENT, "decodeEnvelope", "encoded envelope must be bounded bytes") end if
  if len(encoded) < META_FIXED_BYTES or slice(encoded, 0, 8) != bytes("MSTDE001") then return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "metadata magic is invalid") end if
  if endian.readU16LE(encoded, 8) != META_VERSION or endian.readU16LE(encoded, 10) != META_FIXED_BYTES or endian.readU16LE(encoded, 14) != WRAP_AES_256_GCM then return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "metadata version or wrapping algorithm is unsupported") end if
  storedCrc = endian.readU32LE(encoded, 96)
  checksumCopy = bytes(encoded)
  endian.writeU32LE(checksumCopy, 96, 0)
  if crc32c.compute(checksumCopy) != storedCrc then return fail(CORRUPT_DATA, "decodeEnvelope", "metadata checksum mismatch") end if
  identifierLength = endian.readU32LE(encoded, 16)
  if identifierLength == 0 or len(encoded) != META_FIXED_BYTES + identifierLength then return fail(CORRUPT_DATA, "decodeEnvelope", "provider identifier length is invalid") end if
  identifier = decode(slice(encoded, META_FIXED_BYTES, identifierLength))
  if typeof(identifier) != "string" then return fail(CORRUPT_DATA, "decodeEnvelope", "provider identifier is not UTF-8") end if
  storedProvider = KeyProvider(endian.readU16LE(encoded, 12), identifier)
  provider = storedProvider
  if providerOverride is not void then
    if providerOverride is not KeyProvider or providerOverride.kind != storedProvider.kind then return fail(UNSUPPORTED_FORMAT, "decodeEnvelope", "provider override kind does not match envelope") end if
    provider = providerOverride
  end if
  databaseId = slice(encoded, 20, 16)
  wrappingKey = try(loadProviderKey(provider))
  if typeof(wrappingKey) == "error" then return wrappingKey end if
  aad = envelopeAad(databaseId, storedProvider.kind, storedProvider.identifier)
  databaseKey = try(aes_gcm.open(wrappingKey, slice(encoded, 36, 12), slice(encoded, 48, 48), aad, 16))
  uuid.wipeSecret(wrappingKey)
  uuid.wipeSecret(aad)
  if typeof(databaseKey) == "error" then return fail(AUTHENTICATION_FAILED, "decodeEnvelope", "master key is unavailable or incorrect") end if
  return DatabaseKey(databaseRoot, databaseId, provider, databaseKey)
end function

// Reads, validates and unwraps the database's current DEK envelope.
function decodeEnvelope(databaseRoot)
  encoded = try(file_api.readAllBytes(metadataPath(databaseRoot), META_MAX_BYTES))
  if typeof(encoded) == "error" then return encoded end if
  return decodeEnvelopeData(databaseRoot, encoded, void)
end function

// Resolves and loads the database key associated with an artifact path.
function loadForPath(path, expectedDatabaseId)
  root = findDatabaseRoot(path)
  if root is void then return void end if
  material = try(decodeEnvelope(root))
  if typeof(material) == "error" then return material end if
  if typeof(expectedDatabaseId) == "bytes" and material.databaseId != expectedDatabaseId then uuid.wipeSecret(material.key); return fail(CORRUPT_DATA, "loadForPath", "envelope belongs to another database") end if
  return material
end function

// Atomically publishes a durable wrapped-key envelope.
function writeEnvelope(databaseRoot, databaseId, provider, databaseKey)
  encoded = try(encodeEnvelope(databaseId, provider, databaseKey))
  if typeof(encoded) == "error" then return encoded end if
  temporary = metadataPath(databaseRoot) + ".new"
  handle = try(file_api.createDurable(temporary))
  if typeof(handle) == "error" then return handle end if
  written = try(file_api.writeAt(handle, 0, encoded, 0, len(encoded)))
  if typeof(written) == "error" then ignoredClose = try(file_api.close(handle)); return written end if
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(flushed) == "error" then return flushed end if
  if typeof(closed) == "error" then return closed end if
  return file_api.movePath(temporary, metadataPath(databaseRoot), true)
end function

// Creates and wraps a fresh random database encryption key.
function createEnvelope(databaseRoot, databaseId, provider)
  if file_api.fileExists(metadataPath(databaseRoot)) then return fail(INVALID_ARGUMENT, "createEnvelope", "database encryption is already enabled") end if
  key = try(uuid.randomBytes(32))
  if typeof(key) == "error" then return key end if
  result = try(writeEnvelope(databaseRoot, databaseId, provider, key))
  uuid.wipeSecret(key)
  return result
end function

// Rotation rewraps the DEK atomically; data pages never become half-keyed and
// no full database rewrite is required. The old key remains usable until the
// final metadata rename, which is the online cut-over point.
// Atomically rewraps the existing DEK with a new provider key.
function rotateEnvelope(databaseRoot, newProvider)
  material = try(decodeEnvelope(databaseRoot))
  if typeof(material) == "error" then return material end if
  result = try(writeEnvelope(databaseRoot, material.databaseId, newProvider, material.key))
  uuid.wipeSecret(material.key)
  return result
end function

// Wipes caller-owned database key material.
function closeDatabaseKey(material)
  if material is not DatabaseKey then return false end if
  uuid.wipeSecret(material.key)
  return true
end function

// Returns the stable component name.
function componentName()
  return "security.key_provider"
end function

// Returns the milestone introducing this component.
function targetMilestone()
  return "M79"
end function

// Reports that the component is implemented.
function isImplemented()
  return true
end function
