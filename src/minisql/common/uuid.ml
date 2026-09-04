//! Provides minisql common uuid facilities for this project.

package minisql.common.uuid
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.crypto as crypto
import std.crypto.aes_gcm as aes_gcm
import std.uuid as uuid_api

/// Cryptographic utility layer for identifiers, password verification, message

const INVALID_ARGUMENT = 9001
/// Defines the io failure constant used by the minisql common uuid module.
const IO_FAILURE = 9005
/// Defines the authentication failed constant used by the minisql common uuid module.
const AUTHENTICATION_FAILED = 9027

/// Defines the password salt bytes constant used by the minisql common uuid module.
const PASSWORD_SALT_BYTES = 16
/// Defines the password verifier bytes constant used by the minisql common uuid module.
const PASSWORD_VERIFIER_BYTES = 32
/// New credentials keep a SCRAM-style StoredKey and ServerKey rather than a
const PASSWORD_CREDENTIAL_BYTES = 64
/// Defines the auth scheme legacy constant used by the minisql common uuid module.
const AUTH_SCHEME_LEGACY = 1
/// Defines the auth scheme scram sha256 constant used by the minisql common uuid module.
const AUTH_SCHEME_SCRAM_SHA256 = 2
/// Defines the auth nonce bytes constant used by the minisql common uuid module.
const AUTH_NONCE_BYTES = 32
/// Defines the default pbkdf2 iterations constant used by the minisql common uuid module.
const DEFAULT_PBKDF2_ITERATIONS = 600000
/// Defines the min pbkdf2 iterations constant used by the minisql common uuid module.
const MIN_PBKDF2_ITERATIONS = 10000
/// Defines the max pbkdf2 iterations constant used by the minisql common uuid module.
const MAX_PBKDF2_ITERATIONS = 5000000
/// Defines the bcrypt alg handle hmac flag constant used by the minisql common uuid module.
const BCRYPT_ALG_HANDLE_HMAC_FLAG = 8
/// Defines the bcrypt use system preferred rng constant used by the minisql common uuid module.
const BCRYPT_USE_SYSTEM_PREFERRED_RNG = 2
/// Defines the aes gcm nonce bytes constant used by the minisql common uuid module.
const AES_GCM_NONCE_BYTES = 12
/// Defines the aes gcm tag bytes constant used by the minisql common uuid module.
const AES_GCM_TAG_BYTES = 16
/// Defines the bcrypt auth mode info bytes constant used by the minisql common uuid module.
const BCRYPT_AUTH_MODE_INFO_BYTES = 88

#if TARGET_OS == "windows"
/// Writes a new RFC-compatible GUID to `buffer` and returns the HRESULT status.
/// @param buffer Buffer that receives or supplies the operation data.
/// @returns Native i32 result produced by the call.
extern function CoCreateGuid(buffer as bytes) from "ole32.dll" symbol "CoCreateGuid" returns i32
/// Fills `buffer` with cryptographically secure random bytes and returns NTSTATUS.
/// @param algorithm algorithm value consumed by this operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param count Number of items or units to process.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptGenRandom(algorithm as ptr, buffer as bytes, count as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenRandom" returns i32
/// Opens the requested CNG algorithm provider and writes its handle to `handleOut`.
/// @param handleOut handleOut value consumed by this operation.
/// @param algorithmId Identifier of algorithm.
/// @param implementation implementation value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptOpenAlgorithmProvider(handleOut as bytes, algorithmId as wstr, implementation as wstr, flags as u32) from "bcrypt.dll" symbol "BCryptOpenAlgorithmProvider" returns i32
/// Derives `outputLength` PBKDF2 bytes from the supplied secret, salt, and iteration count.
/// @param algorithm algorithm value consumed by this operation.
/// @param secret secret value consumed by this operation.
/// @param secretLength secretLength value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param saltLength saltLength value consumed by this operation.
/// @param iterations iterations value consumed by this operation.
/// @param output Output collection or buffer populated by the operation.
/// @param outputLength outputLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptDeriveKeyPBKDF2(algorithm as ptr, secret as bytes, secretLength as u32, salt as bytes, saltLength as u32, iterations as u64, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptDeriveKeyPBKDF2" returns i32
/// Closes an algorithm-provider handle and returns its NTSTATUS result.
/// @param algorithm algorithm value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptCloseAlgorithmProvider(algorithm as ptr, flags as u32) from "bcrypt.dll" symbol "BCryptCloseAlgorithmProvider" returns i32
/// Reads a named CNG property into `output` and reports the produced length.
/// @param object object value consumed by this operation.
/// @param propertyName propertyName value consumed by this operation.
/// @param output Output collection or buffer populated by the operation.
/// @param outputLength outputLength value consumed by this operation.
/// @param resultLength resultLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptGetProperty(object as ptr, propertyName as wstr, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptGetProperty" returns i32
/// Updates a named CNG property from the supplied byte representation.
/// @param object object value consumed by this operation.
/// @param propertyName propertyName value consumed by this operation.
/// @param input input value consumed by this operation.
/// @param inputLength inputLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptSetProperty(object as ptr, propertyName as wstr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptSetProperty" returns i32
/// Expands secret bytes into a CNG symmetric-key object and returns its handle.
/// @param algorithm algorithm value consumed by this operation.
/// @param keyOut keyOut value consumed by this operation.
/// @param keyObject keyObject value consumed by this operation.
/// @param keyObjectLength keyObjectLength value consumed by this operation.
/// @param secret secret value consumed by this operation.
/// @param secretLength secretLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptGenerateSymmetricKey(algorithm as ptr, keyOut as bytes, keyObject as bytes, keyObjectLength as u32, secret as bytes, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenerateSymmetricKey" returns i32
/// Destroys a CNG symmetric-key handle and returns its NTSTATUS result.
/// @param key key value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function BCryptDestroyKey(key as ptr) from "bcrypt.dll" symbol "BCryptDestroyKey" returns i32
/// Encrypts one buffer with the supplied key, AEAD metadata, and output bounds.
/// @param key key value consumed by this operation.
/// @param input input value consumed by this operation.
/// @param inputLength inputLength value consumed by this operation.
/// @param paddingInfo paddingInfo value consumed by this operation.
/// @param iv iv value consumed by this operation.
/// @param ivLength ivLength value consumed by this operation.
/// @param output Output collection or buffer populated by the operation.
/// @param outputLength outputLength value consumed by this operation.
/// @param resultLength resultLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptEncrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptEncrypt" returns i32
/// Authenticates and decrypts one buffer, returning NTSTATUS on tag mismatch or failure.
/// @param key key value consumed by this operation.
/// @param input input value consumed by this operation.
/// @param inputLength inputLength value consumed by this operation.
/// @param paddingInfo paddingInfo value consumed by this operation.
/// @param iv iv value consumed by this operation.
/// @param ivLength ivLength value consumed by this operation.
/// @param output Output collection or buffer populated by the operation.
/// @param outputLength outputLength value consumed by this operation.
/// @param resultLength resultLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptDecrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptDecrypt" returns i32
/// Allocates a keyed or unkeyed CNG hash object and writes its handle to `hashOut`.
/// @param algorithm algorithm value consumed by this operation.
/// @param hashOut hashOut value consumed by this operation.
/// @param hashObject hashObject value consumed by this operation.
/// @param hashObjectLength hashObjectLength value consumed by this operation.
/// @param secret secret value consumed by this operation.
/// @param secretLength secretLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptCreateHash(algorithm as ptr, hashOut as bytes, hashObject as bytes, hashObjectLength as u32, secret as ptr, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptCreateHash" returns i32
/// Incorporates `inputLength` bytes into the in-progress CNG hash.
/// @param hash hash value consumed by this operation.
/// @param input input value consumed by this operation.
/// @param inputLength inputLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptHashData(hash as ptr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptHashData" returns i32
/// Finalizes a CNG hash into the bounded output buffer and returns NTSTATUS.
/// @param hash hash value consumed by this operation.
/// @param output Output collection or buffer populated by the operation.
/// @param outputLength outputLength value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @returns Native i32 result produced by the call.
extern function BCryptFinishHash(hash as ptr, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptFinishHash" returns i32
/// Destroys a CNG hash handle and returns its NTSTATUS result.
/// @param hash hash value consumed by this operation.
/// @returns Native i32 result produced by the call.
extern function BCryptDestroyHash(hash as ptr) from "bcrypt.dll" symbol "BCryptDestroyHash" returns i32
#endif

/// Defines the password material record used by this module.
struct PasswordMaterial
  /// Salt field of the password material.
  salt
  /// Iterations field of the password material.
  iterations
  /// Verifier field of the password material.
  verifier
end struct

/// Defines the aead packet record used by this module.
struct AeadPacket
  /// Ciphertext field of the aead packet.
  ciphertext
  /// Tag field of the aead packet.
  tag
end struct

/// Performs the fail operation for the minisql common uuid module.
/// Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "common.uuid." + operation + ": " + message)
end function

/// Creates create for the minisql common uuid module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function create()
#if TARGET_OS == "windows"
  value = bytes(16, 0)
  result = CoCreateGuid(value)
  if result != 0 then return fail(IO_FAILURE, "create", "CoCreateGuid failed with HRESULT " + result) end if
  return value
#else
  value = try(uuid_api.v4Bytes())
  if typeof(value) == "error" then return fail(IO_FAILURE, "create", value.message) end if
  return value
#endif
end function

/// Validates validate for the minisql common uuid workflow.
/// Inputs: `value`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function validate(value)
  if typeof(value) != "bytes" or len(value) != 16 then
    return fail(INVALID_ARGUMENT, "validate", "UUID must be exactly 16 bytes")
  end if
  return true
end function

/// Compares the s.
/// Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function equals(left, right)
  validate(left)
  validate(right)
  for index = 0 to 15
    if left[index] != right[index] then return false end if
  end for
  return true
end function

/// Converts the hex.
/// Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param value Value consumed or transformed by the operation.
function toHex(value)
  validate(value)
  return hex(value)
end function

/// Parses the hex.
/// Inputs: `text`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param text Text consumed by the operation.
function parseHex(text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "parseHex", "text must be string") end if
  value = fromHex(text)
  if typeof(value) != "bytes" or len(value) != 16 then return fail(INVALID_ARGUMENT, "parseHex", "UUID hex must contain 16 bytes") end if
  return value
end function

/// Performs the random bytes operation under the common native-crypto monitor.
/// Inputs: `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param count Number of items or units to process.
function synchronized randomBytes(count)
  if typeof(count) != "int" or count < 1 or count > 1048576 then return fail(INVALID_ARGUMENT, "randomBytes", "count must be 1..1048576") end if
#if TARGET_OS == "windows"
  output = bytes(count, 0)
  status = BCryptGenRandom(void, output, count, BCRYPT_USE_SYSTEM_PREFERRED_RNG)
  if status != 0 then return fail(IO_FAILURE, "randomBytes", "BCryptGenRandom failed with NTSTATUS " + status) end if
  return output
#else
  output = try(crypto.secureRandom(count))
  if typeof(output) == "error" then return fail(IO_FAILURE, "randomBytes", output.message) end if
  return output
#endif
end function

/// Opens the sha256 hmac.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function openSha256Hmac()
#if TARGET_OS == "windows"
  handleBytes = bytes(8, 0)
  status = BCryptOpenAlgorithmProvider(handleBytes, "SHA256", void, BCRYPT_ALG_HANDLE_HMAC_FLAG)
  if status != 0 then return fail(IO_FAILURE, "openSha256Hmac", "BCryptOpenAlgorithmProvider failed with NTSTATUS " + status) end if
  handle = endian.uint64ToInt(endian.readU64LE(handleBytes, 0))
  if typeof(handle) != "int" or handle == 0 then return fail(IO_FAILURE, "openSha256Hmac", "provider returned an invalid handle") end if
  return handle
#else
  return true
#endif
end function

/// Performs the PBKDF2 sequence under the same process-wide monitor as all
/// other CNG calls, protecting compiler-managed native argument buffers.
/// Inputs: `secret`, `salt`, `iterations`, `outputLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param secret secret value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param iterations iterations value consumed by this operation.
/// @param outputLength outputLength value consumed by this operation.
function synchronized deriveKey(secret, salt, iterations, outputLength)
  if typeof(secret) != "bytes" or len(secret) == 0 or len(secret) > 4096 then return fail(INVALID_ARGUMENT, "deriveKey", "secret must contain 1..4096 bytes") end if
  if typeof(salt) != "bytes" or len(salt) == 0 or len(salt) > 4096 then return fail(INVALID_ARGUMENT, "deriveKey", "salt must contain 1..4096 bytes") end if
  if typeof(iterations) != "int" or iterations < 1 or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "deriveKey", "iterations are outside the supported range") end if
  if typeof(outputLength) != "int" or outputLength < 16 or outputLength > 1024 then return fail(INVALID_ARGUMENT, "deriveKey", "outputLength must be 16..1024") end if
#if TARGET_OS == "windows"
  provider = openSha256Hmac()
  output = bytes(outputLength, 0)
  status = BCryptDeriveKeyPBKDF2(provider, secret, len(secret), salt, len(salt), iterations, output, outputLength, 0)
  closeStatus = BCryptCloseAlgorithmProvider(provider, 0)
  if status != 0 then fillBytes(output, 0, len(output), 0); return fail(IO_FAILURE, "deriveKey", "BCryptDeriveKeyPBKDF2 failed with NTSTATUS " + status) end if
  if closeStatus != 0 then fillBytes(output, 0, len(output), 0); return fail(IO_FAILURE, "deriveKey", "BCryptCloseAlgorithmProvider failed with NTSTATUS " + closeStatus) end if
  return output
#else
  output = try(crypto.pbkdf2Sha256(secret, salt, iterations, outputLength))
  if typeof(output) == "error" then return fail(IO_FAILURE, "deriveKey", output.message) end if
  return output
#endif
end function

/// Performs the wipe secret operation for this module.
/// Inputs: `secret`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param secret secret value consumed by this operation.
function wipeSecret(secret)
  if typeof(secret) != "bytes" then return false end if
  fillBytes(secret, 0, len(secret), 0)
  return true
end function

/// Validates the password bytes.
/// Inputs: `passwordBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validatePasswordBytes(passwordBytes, operation)
  if typeof(passwordBytes) != "bytes" then return fail(INVALID_ARGUMENT, operation, "password must be bytes") end if
  raw = bytes(passwordBytes)
  if len(raw) < 12 or len(raw) > 1024 then
    wipeSecret(raw)
    return fail(INVALID_ARGUMENT, operation, "password must contain 12..1024 UTF-8 bytes")
  end if
  for each value in raw
    if value == 0 then
      wipeSecret(raw)
      return fail(INVALID_ARGUMENT, operation, "password must not contain NUL")
    end if
  end for
  return raw
end function

/// Validates the password.
/// Inputs: `password`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param password password value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validatePassword(password, operation)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, operation, "password must be string") end if
  return validatePasswordBytes(bytes(password), operation)
end function

/// Creates the password material bytes.
/// Inputs: `passwordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param passwordBytes passwordBytes value consumed by this operation.
function createPasswordMaterialBytes(passwordBytes)
  secret = validatePasswordBytes(passwordBytes, "createPasswordMaterialBytes")
  salt = try(randomBytes(PASSWORD_SALT_BYTES))
  if typeof(salt) == "error" then wipeSecret(secret); return salt end if
  saltedPassword = try(deriveKey(secret, salt, DEFAULT_PBKDF2_ITERATIONS, PASSWORD_VERIFIER_BYTES))
  wipeSecret(secret)
  if typeof(saltedPassword) == "error" then return saltedPassword end if
  verifier = try(scramCredential(saltedPassword))
  wipeSecret(saltedPassword)
  if typeof(verifier) == "error" then return verifier end if
  return PasswordMaterial(salt, DEFAULT_PBKDF2_ITERATIONS, verifier)
end function

/// Creates the password material.
/// Inputs: `password`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param password password value consumed by this operation.
function createPasswordMaterial(password)
  secret = validatePassword(password, "createPasswordMaterial")
  salt = try(randomBytes(PASSWORD_SALT_BYTES))
  if typeof(salt) == "error" then fillBytes(secret, 0, len(secret), 0); return salt end if
  saltedPassword = try(deriveKey(secret, salt, DEFAULT_PBKDF2_ITERATIONS, PASSWORD_VERIFIER_BYTES))
  fillBytes(secret, 0, len(secret), 0)
  if typeof(saltedPassword) == "error" then return saltedPassword end if
  verifier = try(scramCredential(saltedPassword))
  wipeSecret(saltedPassword)
  if typeof(verifier) == "error" then return verifier end if
  return PasswordMaterial(salt, DEFAULT_PBKDF2_ITERATIONS, verifier)
end function

/// Performs the wipe password material operation for this module.
/// Inputs: `material`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param material material value consumed by this operation.
function wipePasswordMaterial(material)
  if material is not PasswordMaterial then return false end if
  if typeof(material.salt) == "bytes" then fillBytes(material.salt, 0, len(material.salt), 0) end if
  if typeof(material.verifier) == "bytes" then fillBytes(material.verifier, 0, len(material.verifier), 0) end if
  material.iterations = 0
  return true
end function

/// Verifies the password bytes.
/// Inputs: `passwordBytes`, `salt`, `iterations`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param passwordBytes passwordBytes value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param iterations iterations value consumed by this operation.
/// @param expected expected value consumed by this operation.
function verifyPasswordBytes(passwordBytes, salt, iterations, expected)
  if typeof(salt) != "bytes" or len(salt) != PASSWORD_SALT_BYTES or typeof(expected) != "bytes" or (len(expected) != PASSWORD_VERIFIER_BYTES and len(expected) != PASSWORD_CREDENTIAL_BYTES) then
    return fail(INVALID_ARGUMENT, "verifyPasswordBytes", "invalid password material")
  end if
  if typeof(iterations) != "int" or iterations < MIN_PBKDF2_ITERATIONS or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "verifyPasswordBytes", "invalid PBKDF2 work factor") end if
  secret = validatePasswordBytes(passwordBytes, "verifyPasswordBytes")
  actual = try(deriveKey(secret, salt, iterations, PASSWORD_VERIFIER_BYTES))
  wipeSecret(secret)
  if typeof(actual) == "error" then return actual end if
  if len(expected) == PASSWORD_CREDENTIAL_BYTES then
    credential = try(scramCredential(actual))
    wipeSecret(actual)
    if typeof(credential) == "error" then return credential end if
    result = constantTimeEquals(credential, expected)
    wipeSecret(credential)
    return result
  end if
  result = constantTimeEquals(actual, expected)
  wipeSecret(actual)
  return result
end function

/// Verifies the password.
/// Inputs: `password`, `salt`, `iterations`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param password password value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param iterations iterations value consumed by this operation.
/// @param expected expected value consumed by this operation.
function verifyPassword(password, salt, iterations, expected)
  if typeof(salt) != "bytes" or len(salt) != PASSWORD_SALT_BYTES or typeof(expected) != "bytes" or (len(expected) != PASSWORD_VERIFIER_BYTES and len(expected) != PASSWORD_CREDENTIAL_BYTES) then
    return fail(INVALID_ARGUMENT, "verifyPassword", "invalid password material")
  end if
  if typeof(iterations) != "int" or iterations < MIN_PBKDF2_ITERATIONS or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "verifyPassword", "invalid PBKDF2 work factor") end if
  secret = validatePassword(password, "verifyPassword")
  actual = try(deriveKey(secret, salt, iterations, PASSWORD_VERIFIER_BYTES))
  fillBytes(secret, 0, len(secret), 0)
  if typeof(actual) == "error" then return actual end if
  if len(expected) == PASSWORD_CREDENTIAL_BYTES then
    credential = try(scramCredential(actual))
    wipeSecret(actual)
    if typeof(credential) == "error" then return credential end if
    result = constantTimeEquals(credential, expected)
    wipeSecret(credential)
    return result
  end if
  result = constantTimeEquals(actual, expected)
  fillBytes(actual, 0, len(actual), 0)
  return result
end function

/// Performs the constant time equals operation for this module.
/// Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function constantTimeEquals(left, right)
  if typeof(left) != "bytes" or typeof(right) != "bytes" or len(left) != len(right) then return false end if
  difference = 0
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      difference = difference | (left[index] ^ right[index])
    end for
  end if
  return difference == 0
end function

/// Returns the wire authentication scheme implied by persisted credential
/// material. Length is the backwards-compatible discriminator in catalog v1.
/// @param credential credential value consumed by this operation.
function authenticationScheme(credential)
  if typeof(credential) != "bytes" then return fail(INVALID_ARGUMENT, "authenticationScheme", "credential must be bytes") end if
  if len(credential) == PASSWORD_VERIFIER_BYTES then return AUTH_SCHEME_LEGACY end if
  if len(credential) == PASSWORD_CREDENTIAL_BYTES then return AUTH_SCHEME_SCRAM_SHA256 end if
  return fail(INVALID_ARGUMENT, "authenticationScheme", "credential length is unsupported")
end function

/// Derives the non-password-equivalent StoredKey || ServerKey representation
/// used by the hardened authentication scheme.
/// @param saltedPassword saltedPassword value consumed by this operation.
function scramCredential(saltedPassword)
  if typeof(saltedPassword) != "bytes" or len(saltedPassword) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "scramCredential", "salted password must be 32 bytes") end if
  clientKey = try(hmacSha256(saltedPassword, bytes("MiniSQL Client Key")))
  if typeof(clientKey) == "error" then return clientKey end if
  storedKey = try(sha256(clientKey))
  wipeSecret(clientKey)
  if typeof(storedKey) == "error" then return storedKey end if
  serverKey = try(hmacSha256(saltedPassword, bytes("MiniSQL Server Key")))
  if typeof(serverKey) == "error" then wipeSecret(storedKey); return serverKey end if
  output = storedKey + serverKey
  wipeSecret(storedKey)
  wipeSecret(serverKey)
  return output
end function

/// Produces the single transcript shared by client proof, server proof and
/// transport-key derivation. Domain separation prevents cross-protocol reuse.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramTranscript(nonce, username)
  if typeof(nonce) != "bytes" or len(nonce) != AUTH_NONCE_BYTES then return fail(INVALID_ARGUMENT, "scramTranscript", "nonce must be 32 bytes") end if
  if typeof(username) != "string" or len(bytes(username)) == 0 then return fail(INVALID_ARGUMENT, "scramTranscript", "username must be non-empty") end if
  return bytes("MiniSQL-AUTH-2|" + username + "|") + nonce
end function

/// Creates the client proof from the password-derived salted secret. The proof
/// does not disclose that secret to a server storing only StoredKey/ServerKey.
/// @param saltedPassword saltedPassword value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramClientProof(saltedPassword, nonce, username)
  if typeof(saltedPassword) != "bytes" or len(saltedPassword) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "scramClientProof", "salted password must be 32 bytes") end if
  clientKey = try(hmacSha256(saltedPassword, bytes("MiniSQL Client Key")))
  if typeof(clientKey) == "error" then return clientKey end if
  storedKey = try(sha256(clientKey))
  if typeof(storedKey) == "error" then wipeSecret(clientKey); return storedKey end if
  transcript = try(scramTranscript(nonce, username))
  if typeof(transcript) == "error" then wipeSecret(clientKey); wipeSecret(storedKey); return transcript end if
  signature = try(hmacSha256(storedKey, transcript))
  wipeSecret(storedKey)
  wipeSecret(transcript)
  if typeof(signature) == "error" then wipeSecret(clientKey); return signature end if
  proof = bytes(PASSWORD_VERIFIER_BYTES, 0)
  for index = 0 to PASSWORD_VERIFIER_BYTES - 1
    proof[index] = clientKey[index] ^ signature[index]
  end for
  wipeSecret(clientKey)
  wipeSecret(signature)
  return proof
end function

/// Verifies a hardened client proof without reconstructing or storing the
/// password-equivalent salted secret.
/// @param credential credential value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
/// @param proof proof value consumed by this operation.
function verifyScramClientProof(credential, nonce, username, proof)
  if typeof(credential) != "bytes" or len(credential) != PASSWORD_CREDENTIAL_BYTES or typeof(proof) != "bytes" or len(proof) != PASSWORD_VERIFIER_BYTES then return false end if
  storedKey = slice(credential, 0, PASSWORD_VERIFIER_BYTES)
  transcript = try(scramTranscript(nonce, username))
  if typeof(transcript) == "error" then wipeSecret(storedKey); return transcript end if
  signature = try(hmacSha256(storedKey, transcript))
  wipeSecret(transcript)
  if typeof(signature) == "error" then wipeSecret(storedKey); return signature end if
  recoveredClientKey = bytes(PASSWORD_VERIFIER_BYTES, 0)
  for index = 0 to PASSWORD_VERIFIER_BYTES - 1
    recoveredClientKey[index] = proof[index] ^ signature[index]
  end for
  actualStoredKey = try(sha256(recoveredClientKey))
  wipeSecret(recoveredClientKey)
  wipeSecret(signature)
  if typeof(actualStoredKey) == "error" then wipeSecret(storedKey); return actualStoredKey end if
  valid = constantTimeEquals(actualStoredKey, storedKey)
  wipeSecret(actualStoredKey)
  wipeSecret(storedKey)
  return valid
end function

/// Computes the server's transcript signature. A client derives the same
/// ServerKey from its password and rejects a credential-phishing endpoint.
/// @param credential credential value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramServerProofFromCredential(credential, nonce, username)
  if typeof(credential) != "bytes" or len(credential) != PASSWORD_CREDENTIAL_BYTES then return fail(INVALID_ARGUMENT, "scramServerProofFromCredential", "credential must be 64 bytes") end if
  serverKey = slice(credential, PASSWORD_VERIFIER_BYTES, PASSWORD_VERIFIER_BYTES)
  transcript = try(scramTranscript(nonce, username))
  if typeof(transcript) == "error" then wipeSecret(serverKey); return transcript end if
  proof = try(hmacSha256(serverKey, transcript))
  wipeSecret(serverKey)
  wipeSecret(transcript)
  return proof
end function

/// Derives the reciprocal server proof from a client-owned salted password.
/// @param saltedPassword saltedPassword value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramServerProofFromPassword(saltedPassword, nonce, username)
  credential = try(scramCredential(saltedPassword))
  if typeof(credential) == "error" then return credential end if
  proof = try(scramServerProofFromCredential(credential, nonce, username))
  wipeSecret(credential)
  return proof
end function

/// Derives a shared session secret from both stored halves. Possession of this
/// value alone is insufficient to generate a valid future client proof.
/// @param credential credential value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramSessionSecretFromCredential(credential, nonce, username)
  if typeof(credential) != "bytes" or len(credential) != PASSWORD_CREDENTIAL_BYTES then return fail(INVALID_ARGUMENT, "scramSessionSecretFromCredential", "credential must be 64 bytes") end if
  transcript = try(scramTranscript(nonce, username))
  if typeof(transcript) == "error" then return transcript end if
  secret = try(hmacSha256(slice(credential, PASSWORD_VERIFIER_BYTES, PASSWORD_VERIFIER_BYTES), bytes("MiniSQL-SESSION-2|") + transcript + slice(credential, 0, PASSWORD_VERIFIER_BYTES)))
  wipeSecret(transcript)
  return secret
end function

/// Derives the shared session secret from a client-owned salted password.
/// @param saltedPassword saltedPassword value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
function scramSessionSecretFromPassword(saltedPassword, nonce, username)
  credential = try(scramCredential(saltedPassword))
  if typeof(credential) == "error" then return credential end if
  secret = try(scramSessionSecretFromCredential(credential, nonce, username))
  wipeSecret(credential)
  return secret
end function

/// Performs the auth proof operation for this module.
/// Inputs: `verifier`, `nonce`, `username`, `label`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param verifier verifier value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
/// @param label label value consumed by this operation.
function authProof(verifier, nonce, username, label)
  if typeof(verifier) != "bytes" or len(verifier) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "authProof", "verifier must be 32 bytes") end if
  if typeof(nonce) != "bytes" or len(nonce) != AUTH_NONCE_BYTES then return fail(INVALID_ARGUMENT, "authProof", "nonce must be 32 bytes") end if
  if typeof(username) != "string" or len(username) == 0 or typeof(label) != "string" or len(label) == 0 then return fail(INVALID_ARGUMENT, "authProof", "username and label must be non-empty") end if
  transcript = bytes("MiniSQL-AUTH-1|" + label + "|" + username) + nonce
  return deriveKey(verifier, transcript, 1, PASSWORD_VERIFIER_BYTES)
end function


/// Performs the SHA-256 provider lifecycle under the native-crypto monitor.
/// Inputs: `input`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param input input value consumed by this operation.
function synchronized sha256(input)
  if typeof(input) != "bytes" then return fail(INVALID_ARGUMENT, "sha256", "input must be bytes") end if
#if TARGET_OS == "windows"
  providerOut = bytes(8, 0)
  status = BCryptOpenAlgorithmProvider(providerOut, "SHA256", void, 0)
  if status != 0 then return fail(IO_FAILURE, "sha256", "cannot open SHA-256 provider; NTSTATUS=" + status) end if
  provider = nativeHandle(providerOut, "sha256")
  objectLengthBytes = bytes(4, 0)
  actualBytes = bytes(4, 0)
  status = BCryptGetProperty(provider, "ObjectLength", objectLengthBytes, 4, actualBytes, 0)
  if status != 0 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "sha256", "cannot query hash object length; NTSTATUS=" + status) end if
  objectLength = endian.readU32LE(objectLengthBytes, 0)
  if objectLength < 16 or objectLength > 1048576 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "sha256", "invalid hash object length") end if
  object = bytes(objectLength, 0)
  hashOut = bytes(8, 0)
  status = BCryptCreateHash(provider, hashOut, object, objectLength, void, 0, 0)
  if status != 0 then wipeSecret(object); BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "sha256", "cannot create hash; NTSTATUS=" + status) end if
  hashHandle = nativeHandle(hashOut, "sha256")
  if len(input) > 0 then status = BCryptHashData(hashHandle, input, len(input), 0) end if
  output = bytes(32, 0)
  if status == 0 then status = BCryptFinishHash(hashHandle, output, 32, 0) end if
  ignoredHash = BCryptDestroyHash(hashHandle)
  ignoredProvider = BCryptCloseAlgorithmProvider(provider, 0)
  wipeSecret(object)
  if status != 0 then wipeSecret(output); return fail(IO_FAILURE, "sha256", "SHA-256 failed; NTSTATUS=" + status) end if
  return output
#else
  output = try(crypto.sha256(input))
  if typeof(output) == "error" then return fail(IO_FAILURE, "sha256", output.message) end if
  return output
#endif
end function

/// Performs the HMAC provider lifecycle under the native-crypto monitor.
/// Inputs: `key`, `input`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param key key value consumed by this operation.
/// @param input input value consumed by this operation.
function synchronized hmacSha256(key, input)
  if typeof(key) != "bytes" or len(key) == 0 or len(key) > 4096 then return fail(INVALID_ARGUMENT, "hmacSha256", "key must contain 1..4096 bytes") end if
  if typeof(input) != "bytes" then return fail(INVALID_ARGUMENT, "hmacSha256", "input must be bytes") end if
#if TARGET_OS == "windows"
  providerOut = bytes(8, 0)
  status = BCryptOpenAlgorithmProvider(providerOut, "SHA256", void, BCRYPT_ALG_HANDLE_HMAC_FLAG)
  if status != 0 then return fail(IO_FAILURE, "hmacSha256", "cannot open HMAC-SHA-256 provider; NTSTATUS=" + status) end if
  provider = nativeHandle(providerOut, "hmacSha256")
  objectLengthBytes = bytes(4, 0)
  actualBytes = bytes(4, 0)
  status = BCryptGetProperty(provider, "ObjectLength", objectLengthBytes, 4, actualBytes, 0)
  if status != 0 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "hmacSha256", "cannot query hash object length; NTSTATUS=" + status) end if
  objectLength = endian.readU32LE(objectLengthBytes, 0)
  if objectLength < 16 or objectLength > 1048576 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "hmacSha256", "invalid hash object length") end if
  object = bytes(objectLength, 0)
  hashOut = bytes(8, 0)
  status = BCryptCreateHash(provider, hashOut, object, objectLength, nativeBytesPtr(key), len(key), 0)
  if status != 0 then wipeSecret(object); BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "hmacSha256", "cannot create HMAC; NTSTATUS=" + status) end if
  hashHandle = nativeHandle(hashOut, "hmacSha256")
  if len(input) > 0 then status = BCryptHashData(hashHandle, input, len(input), 0) end if
  output = bytes(32, 0)
  if status == 0 then status = BCryptFinishHash(hashHandle, output, 32, 0) end if
  ignoredHash = BCryptDestroyHash(hashHandle)
  ignoredProvider = BCryptCloseAlgorithmProvider(provider, 0)
  wipeSecret(object)
  if status != 0 then wipeSecret(output); return fail(IO_FAILURE, "hmacSha256", "HMAC-SHA-256 failed; NTSTATUS=" + status) end if
  return output
#else
  output = try(crypto.hmacSha256(key, input))
  if typeof(output) == "error" then return fail(IO_FAILURE, "hmacSha256", output.message) end if
  return output
#endif
end function

/// Performs the transport key operation for this module.
/// Inputs: `verifier`, `nonce`, `username`, `label`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param verifier verifier value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param username username value consumed by this operation.
/// @param label label value consumed by this operation.
function transportKey(verifier, nonce, username, label)
  if typeof(verifier) != "bytes" or len(verifier) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportKey", "verifier must be 32 bytes") end if
  if typeof(nonce) != "bytes" or len(nonce) != AUTH_NONCE_BYTES then return fail(INVALID_ARGUMENT, "transportKey", "nonce must be 32 bytes") end if
  if typeof(username) != "string" or len(username) == 0 or typeof(label) != "string" or len(label) == 0 then return fail(INVALID_ARGUMENT, "transportKey", "username and label must be non-empty") end if
  context = bytes("MiniSQL-TRANSPORT-1|" + label + "|" + username) + nonce
  return deriveKey(verifier, context, 1, PASSWORD_VERIFIER_BYTES)
end function

/// Compatibility keyed authenticator used by the M30 audit-chain format.
/// The domain, frame fields and authenticated bytes are all included so tags
/// from one purpose cannot be replayed in another purpose.
/// Performs the transport tag operation for this module.
/// Inputs: `key`, `messageType`, `flags`, `requestId`, `sequence`, `authenticated`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param key key value consumed by this operation.
/// @param messageType messageType value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param requestId Identifier of request.
/// @param sequence sequence value consumed by this operation.
/// @param authenticated authenticated value consumed by this operation.
function transportTag(key, messageType, flags, requestId, sequence, authenticated)
  if typeof(key) != "bytes" or len(key) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportTag", "key must be 32 bytes") end if
  if typeof(messageType) != "int" or typeof(flags) != "int" or typeof(requestId) != "int" or typeof(sequence) != "int" or sequence < 0 then return fail(INVALID_ARGUMENT, "transportTag", "frame fields are invalid") end if
  if typeof(authenticated) != "bytes" then return fail(INVALID_ARGUMENT, "transportTag", "authenticated data must be bytes") end if
  header = bytes(24, 0)
  endian.writeU32LE(header, 0, messageType)
  endian.writeU32LE(header, 4, flags)
  endian.writeU32LE(header, 8, requestId)
  endian.writeU64LE(header, 12, endian.uint64FromInt(sequence))
  endian.writeU32LE(header, 20, len(authenticated))
  transcript = bytes("MiniSQL-TAG-1|") + header + authenticated
  tag = deriveKey(key, transcript, 1, PASSWORD_VERIFIER_BYTES)
  wipeSecret(header)
  wipeSecret(transcript)
  return tag
end function

/// Performs the sequence bytes operation for this module.
/// Inputs: `sequence`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param sequence sequence value consumed by this operation.
function sequenceBytes(sequence)
  if typeof(sequence) != "int" or sequence < 0 then return fail(INVALID_ARGUMENT, "sequenceBytes", "sequence must be non-negative") end if
  output = bytes(8, 0)
  endian.writeU64LE(output, 0, endian.uint64FromInt(sequence))
  return output
end function

/// Performs the utf16 ascii operation for this module.
/// Inputs: `text`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param text Text consumed by the operation.
function utf16Ascii(text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "utf16Ascii", "text must be string") end if
  raw = bytes(text)
  output = bytes((len(raw) + 1) * 2, 0)
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      if raw[index] > 127 then return fail(INVALID_ARGUMENT, "utf16Ascii", "text must be ASCII") end if
      endian.writeU16LE(output, index * 2, raw[index])
    end for
  end if
  return output
end function

/// Performs the native handle operation for this module.
/// Inputs: `handleBytes`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param handleBytes handleBytes value consumed by this operation.
/// @param operation operation value consumed by this operation.
function nativeHandle(handleBytes, operation)
  handle = try(endian.uint64ToInt(endian.readU64LE(handleBytes, 0)))
  if typeof(handle) == "error" or handle == 0 then return fail(IO_FAILURE, operation, "native provider returned an invalid handle") end if
  return handle
end function

/// Opens the aes gcm.
/// Inputs: `keyBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param keyBytes keyBytes value consumed by this operation.
function openAesGcm(keyBytes)
  if typeof(keyBytes) != "bytes" or len(keyBytes) != 32 then return fail(INVALID_ARGUMENT, "openAesGcm", "key must be 32 bytes") end if
#if TARGET_OS == "windows"
  providerOut = bytes(8, 0)
  status = BCryptOpenAlgorithmProvider(providerOut, "AES", void, 0)
  if status != 0 then return fail(IO_FAILURE, "openAesGcm", "cannot open AES provider; NTSTATUS=" + status) end if
  provider = nativeHandle(providerOut, "openAesGcm")
  mode = utf16Ascii("ChainingModeGCM")
  status = BCryptSetProperty(provider, "ChainingMode", mode, len(mode), 0)
  wipeSecret(mode)
  if status != 0 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "openAesGcm", "cannot select GCM; NTSTATUS=" + status) end if
  objectLengthBytes = bytes(4, 0)
  actualBytes = bytes(4, 0)
  status = BCryptGetProperty(provider, "ObjectLength", objectLengthBytes, 4, actualBytes, 0)
  if status != 0 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "openAesGcm", "cannot query key object length; NTSTATUS=" + status) end if
  objectLength = endian.readU32LE(objectLengthBytes, 0)
  if objectLength < 16 or objectLength > 1048576 then BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "openAesGcm", "invalid AES key object length") end if
  keyObject = bytes(objectLength, 0)
  keyOut = bytes(8, 0)
  status = BCryptGenerateSymmetricKey(provider, keyOut, keyObject, objectLength, keyBytes, len(keyBytes), 0)
  if status != 0 then wipeSecret(keyObject); BCryptCloseAlgorithmProvider(provider, 0); return fail(IO_FAILURE, "openAesGcm", "cannot create AES key; NTSTATUS=" + status) end if
  keyHandle = nativeHandle(keyOut, "openAesGcm")
  return [provider, keyHandle, keyObject]
#else
  return [0, 0, bytes(keyBytes)]
#endif
end function

/// Closes the aes gcm.
/// Inputs: `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
/// @param state Mutable state inspected or updated by the operation.
function closeAesGcm(state)
  if typeof(state) != "array" or len(state) != 3 then return false end if
#if TARGET_OS == "windows"
  if typeof(state[1]) == "int" and state[1] != 0 then ignoredKey = BCryptDestroyKey(state[1]) end if
  if typeof(state[0]) == "int" and state[0] != 0 then ignoredProvider = BCryptCloseAlgorithmProvider(state[0], 0) end if
#endif
  if typeof(state[2]) == "bytes" then wipeSecret(state[2]) end if
  return true
end function

/// Performs the transport nonce operation for this module.
/// Inputs: `key`, `sequence`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param key key value consumed by this operation.
/// @param sequence sequence value consumed by this operation.
function transportNonce(key, sequence)
  if typeof(key) != "bytes" or len(key) != 32 then return fail(INVALID_ARGUMENT, "transportNonce", "key must be 32 bytes") end if
  sequenceRaw = sequenceBytes(sequence)
  nonce = bytes(AES_GCM_NONCE_BYTES, 0)
  for index = 0 to 3
    nonce[index] = key[index] ^ 0xA5
  end for
  copyBytes(nonce, 4, sequenceRaw, 0, 8)
  wipeSecret(sequenceRaw)
  return nonce
end function

/// Performs the transport associated data operation for this module.
/// Inputs: `messageType`, `flags`, `requestId`, `sequence`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param messageType messageType value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param requestId Identifier of request.
/// @param sequence sequence value consumed by this operation.
/// @param payloadLength payloadLength value consumed by this operation.
function transportAssociatedData(messageType, flags, requestId, sequence, payloadLength)
  if typeof(messageType) != "int" or typeof(flags) != "int" or typeof(requestId) != "int" or typeof(payloadLength) != "int" then return fail(INVALID_ARGUMENT, "transportAssociatedData", "header fields must be int") end if
  header = bytes(24, 0)
  endian.writeU32LE(header, 0, messageType)
  endian.writeU32LE(header, 4, flags)
  endian.writeU32LE(header, 8, requestId)
  endian.writeU64LE(header, 12, endian.uint64FromInt(sequence))
  endian.writeU32LE(header, 20, payloadLength)
  return header
end function

/// Performs the auth mode info operation for this module.
/// Inputs: `nonce`, `aad`, `tag`, `dataLength`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param nonce nonce value consumed by this operation.
/// @param aad aad value consumed by this operation.
/// @param tag tag value consumed by this operation.
/// @param dataLength dataLength value consumed by this operation.
function authModeInfo(nonce, aad, tag, dataLength)
  info = bytes(BCRYPT_AUTH_MODE_INFO_BYTES, 0)
  endian.writeU32LE(info, 0, BCRYPT_AUTH_MODE_INFO_BYTES)
  endian.writeU32LE(info, 4, 1)
  endian.writeU64LE(info, 8, endian.uint64FromInt(nativeBytesPtr(nonce)))
  endian.writeU32LE(info, 16, len(nonce))
  endian.writeU64LE(info, 24, endian.uint64FromInt(nativeBytesPtr(aad)))
  endian.writeU32LE(info, 32, len(aad))
  endian.writeU64LE(info, 40, endian.uint64FromInt(nativeBytesPtr(tag)))
  endian.writeU32LE(info, 48, len(tag))
  endian.writeU64LE(info, 72, endian.uint64FromInt(dataLength))
  return info
end function

/// The CNG AEAD setup passes pointers into several managed temporary buffers.
/// All synchronized functions share MiniLang's recursive process monitor, so
/// AES, PBKDF2, SHA, HMAC, and RNG native sequences cannot overlap.
/// @param key key value consumed by this operation.
/// @param sequence sequence value consumed by this operation.
/// @param messageType messageType value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param requestId Identifier of request.
/// @param plaintext plaintext value consumed by this operation.
function synchronized transportEncrypt(key, sequence, messageType, flags, requestId, plaintext)
  if typeof(key) != "bytes" or len(key) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportEncrypt", "key must be 32 bytes") end if
  if typeof(plaintext) != "bytes" then return fail(INVALID_ARGUMENT, "transportEncrypt", "plaintext must be bytes") end if
  nonce = transportNonce(key, sequence)
  aad = transportAssociatedData(messageType, flags, requestId, sequence, len(plaintext))
#if TARGET_OS == "windows"
  tag = bytes(AES_GCM_TAG_BYTES, 0)
  info = authModeInfo(nonce, aad, tag, len(plaintext))
  state = try(openAesGcm(key))
  if typeof(state) == "error" then wipeSecret(nonce); wipeSecret(aad); wipeSecret(info); return state end if
  ciphertext = bytes(len(plaintext), 0)
  resultLength = bytes(4, 0)
  status = BCryptEncrypt(state[1], plaintext, len(plaintext), info, void, 0, ciphertext, len(ciphertext), resultLength, 0)
  closeAesGcm(state)
  wipeSecret(nonce)
  wipeSecret(aad)
  wipeSecret(info)
  if status != 0 or endian.readU32LE(resultLength, 0) != len(plaintext) then wipeSecret(ciphertext); wipeSecret(tag); return fail(IO_FAILURE, "transportEncrypt", "AES-256-GCM encryption failed; NTSTATUS=" + status) end if
  return AeadPacket(ciphertext, tag)
#else
  encrypted = try(aes_gcm.encrypt(key, nonce, plaintext, aad, AES_GCM_TAG_BYTES))
  wipeSecret(nonce)
  wipeSecret(aad)
  if typeof(encrypted) == "error" then return fail(IO_FAILURE, "transportEncrypt", encrypted.message) end if
  return AeadPacket(encrypted.ciphertext, encrypted.tag)
#endif
end function

/// Authenticates and decrypts one transport frame under the synchronized native guard.
/// Header fields form associated data; tag failure returns AuthenticationFailed.
/// @param key key value consumed by this operation.
/// @param sequence sequence value consumed by this operation.
/// @param messageType messageType value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param requestId Identifier of request.
/// @param ciphertext ciphertext value consumed by this operation.
/// @param tag tag value consumed by this operation.
function synchronized transportDecrypt(key, sequence, messageType, flags, requestId, ciphertext, tag)
  if typeof(key) != "bytes" or len(key) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportDecrypt", "key must be 32 bytes") end if
  if typeof(ciphertext) != "bytes" or typeof(tag) != "bytes" or len(tag) != AES_GCM_TAG_BYTES then return fail(INVALID_ARGUMENT, "transportDecrypt", "ciphertext or tag is invalid") end if
  nonce = transportNonce(key, sequence)
  aad = transportAssociatedData(messageType, flags, requestId, sequence, len(ciphertext))
#if TARGET_OS == "windows"
  tagCopy = bytes(tag)
  info = authModeInfo(nonce, aad, tagCopy, len(ciphertext))
  state = try(openAesGcm(key))
  if typeof(state) == "error" then wipeSecret(nonce); wipeSecret(aad); wipeSecret(tagCopy); wipeSecret(info); return state end if
  plaintext = bytes(len(ciphertext), 0)
  resultLength = bytes(4, 0)
  status = BCryptDecrypt(state[1], ciphertext, len(ciphertext), info, void, 0, plaintext, len(plaintext), resultLength, 0)
  closeAesGcm(state)
  wipeSecret(nonce)
  wipeSecret(aad)
  wipeSecret(tagCopy)
  wipeSecret(info)
  if status != 0 or endian.readU32LE(resultLength, 0) != len(ciphertext) then wipeSecret(plaintext); return fail(AUTHENTICATION_FAILED, "transportDecrypt", "secure transport authentication failed") end if
  return plaintext
#else
  plaintext = try(aes_gcm.decrypt(key, nonce, ciphertext, tag, aad))
  wipeSecret(nonce)
  wipeSecret(aad)
  if typeof(plaintext) == "error" then return fail(AUTHENTICATION_FAILED, "transportDecrypt", "secure transport authentication failed") end if
  return plaintext
#endif
end function

/// Evaluates whether the supplied input satisfies the aead packet predicate.
/// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param value Value consumed or transformed by the operation.
function isAeadPacket(value)
  return value is AeadPacket
end function

/// Performs the authentication failure operation for this module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function authenticationFailure()
  return fail(AUTHENTICATION_FAILED, "authenticate", "authentication failed")
end function

/// Performs the componentName operation for the minisql common uuid module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.uuid"
end function

/// Performs the targetMilestone operation for the minisql common uuid module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M8"
end function

/// Returns whether implemented satisfies the condition required by the minisql common uuid module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
