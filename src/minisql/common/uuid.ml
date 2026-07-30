package minisql.common.uuid

import minisql.common.endian as endian

const INVALID_ARGUMENT = 9001
const IO_FAILURE = 9005
const AUTHENTICATION_FAILED = 9027

const PASSWORD_SALT_BYTES = 16
const PASSWORD_VERIFIER_BYTES = 32
const AUTH_NONCE_BYTES = 32
const DEFAULT_PBKDF2_ITERATIONS = 600000
const MIN_PBKDF2_ITERATIONS = 10000
const MAX_PBKDF2_ITERATIONS = 5000000
const BCRYPT_ALG_HANDLE_HMAC_FLAG = 8
const BCRYPT_USE_SYSTEM_PREFERRED_RNG = 2
const AES_GCM_NONCE_BYTES = 12
const AES_GCM_TAG_BYTES = 16
const BCRYPT_AUTH_MODE_INFO_BYTES = 88

extern function CoCreateGuid(buffer as bytes) from "ole32.dll" symbol "CoCreateGuid" returns i32
extern function BCryptGenRandom(algorithm as ptr, buffer as bytes, count as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenRandom" returns i32
extern function BCryptOpenAlgorithmProvider(handleOut as bytes, algorithmId as wstr, implementation as wstr, flags as u32) from "bcrypt.dll" symbol "BCryptOpenAlgorithmProvider" returns i32
extern function BCryptDeriveKeyPBKDF2(algorithm as ptr, secret as bytes, secretLength as u32, salt as bytes, saltLength as u32, iterations as u64, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptDeriveKeyPBKDF2" returns i32
extern function BCryptCloseAlgorithmProvider(algorithm as ptr, flags as u32) from "bcrypt.dll" symbol "BCryptCloseAlgorithmProvider" returns i32
extern function BCryptGetProperty(object as ptr, propertyName as wstr, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptGetProperty" returns i32
extern function BCryptSetProperty(object as ptr, propertyName as wstr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptSetProperty" returns i32
extern function BCryptGenerateSymmetricKey(algorithm as ptr, keyOut as bytes, keyObject as bytes, keyObjectLength as u32, secret as bytes, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptGenerateSymmetricKey" returns i32
extern function BCryptDestroyKey(key as ptr) from "bcrypt.dll" symbol "BCryptDestroyKey" returns i32
extern function BCryptEncrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptEncrypt" returns i32
extern function BCryptDecrypt(key as ptr, input as bytes, inputLength as u32, paddingInfo as bytes, iv as ptr, ivLength as u32, output as bytes, outputLength as u32, resultLength as bytes, flags as u32) from "bcrypt.dll" symbol "BCryptDecrypt" returns i32
extern function BCryptCreateHash(algorithm as ptr, hashOut as bytes, hashObject as bytes, hashObjectLength as u32, secret as ptr, secretLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptCreateHash" returns i32
extern function BCryptHashData(hash as ptr, input as bytes, inputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptHashData" returns i32
extern function BCryptFinishHash(hash as ptr, output as bytes, outputLength as u32, flags as u32) from "bcrypt.dll" symbol "BCryptFinishHash" returns i32
extern function BCryptDestroyHash(hash as ptr) from "bcrypt.dll" symbol "BCryptDestroyHash" returns i32

struct PasswordMaterial
  salt
  iterations
  verifier
end struct

struct AeadPacket
  ciphertext
  tag
end struct

function fail(code, operation, message)
  return error(code, "common.uuid." + operation + ": " + message)
end function

function create()
  value = bytes(16, 0)
  result = CoCreateGuid(value)
  if result != 0 then return fail(IO_FAILURE, "create", "CoCreateGuid failed with HRESULT " + result) end if
  return value
end function

function validate(value)
  if typeof(value) != "bytes" or len(value) != 16 then
    return fail(INVALID_ARGUMENT, "validate", "UUID must be exactly 16 bytes")
  end if
  return true
end function

function equals(left, right)
  validate(left)
  validate(right)
  for index = 0 to 15
    if left[index] != right[index] then return false end if
  end for
  return true
end function

function toHex(value)
  validate(value)
  return hex(value)
end function

function parseHex(text)
  if typeof(text) != "string" then return fail(INVALID_ARGUMENT, "parseHex", "text must be string") end if
  value = fromHex(text)
  if typeof(value) != "bytes" or len(value) != 16 then return fail(INVALID_ARGUMENT, "parseHex", "UUID hex must contain 16 bytes") end if
  return value
end function

function randomBytes(count)
  if typeof(count) != "int" or count < 1 or count > 1048576 then return fail(INVALID_ARGUMENT, "randomBytes", "count must be 1..1048576") end if
  output = bytes(count, 0)
  status = BCryptGenRandom(void, output, count, BCRYPT_USE_SYSTEM_PREFERRED_RNG)
  if status != 0 then return fail(IO_FAILURE, "randomBytes", "BCryptGenRandom failed with NTSTATUS " + status) end if
  return output
end function

function openSha256Hmac()
  handleBytes = bytes(8, 0)
  status = BCryptOpenAlgorithmProvider(handleBytes, "SHA256", void, BCRYPT_ALG_HANDLE_HMAC_FLAG)
  if status != 0 then return fail(IO_FAILURE, "openSha256Hmac", "BCryptOpenAlgorithmProvider failed with NTSTATUS " + status) end if
  handle = endian.uint64ToInt(endian.readU64LE(handleBytes, 0))
  if typeof(handle) != "int" or handle == 0 then return fail(IO_FAILURE, "openSha256Hmac", "provider returned an invalid handle") end if
  return handle
end function

function deriveKey(secret, salt, iterations, outputLength)
  if typeof(secret) != "bytes" or len(secret) == 0 or len(secret) > 4096 then return fail(INVALID_ARGUMENT, "deriveKey", "secret must contain 1..4096 bytes") end if
  if typeof(salt) != "bytes" or len(salt) == 0 or len(salt) > 4096 then return fail(INVALID_ARGUMENT, "deriveKey", "salt must contain 1..4096 bytes") end if
  if typeof(iterations) != "int" or iterations < 1 or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "deriveKey", "iterations are outside the supported range") end if
  if typeof(outputLength) != "int" or outputLength < 16 or outputLength > 1024 then return fail(INVALID_ARGUMENT, "deriveKey", "outputLength must be 16..1024") end if
  provider = openSha256Hmac()
  output = bytes(outputLength, 0)
  status = BCryptDeriveKeyPBKDF2(provider, secret, len(secret), salt, len(salt), iterations, output, outputLength, 0)
  closeStatus = BCryptCloseAlgorithmProvider(provider, 0)
  if status != 0 then fillBytes(output, 0, len(output), 0); return fail(IO_FAILURE, "deriveKey", "BCryptDeriveKeyPBKDF2 failed with NTSTATUS " + status) end if
  if closeStatus != 0 then fillBytes(output, 0, len(output), 0); return fail(IO_FAILURE, "deriveKey", "BCryptCloseAlgorithmProvider failed with NTSTATUS " + closeStatus) end if
  return output
end function

function wipeSecret(secret)
  if typeof(secret) != "bytes" then return false end if
  fillBytes(secret, 0, len(secret), 0)
  return true
end function

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

function validatePassword(password, operation)
  if typeof(password) != "string" then return fail(INVALID_ARGUMENT, operation, "password must be string") end if
  return validatePasswordBytes(bytes(password), operation)
end function

function createPasswordMaterialBytes(passwordBytes)
  secret = validatePasswordBytes(passwordBytes, "createPasswordMaterialBytes")
  salt = try(randomBytes(PASSWORD_SALT_BYTES))
  if typeof(salt) == "error" then wipeSecret(secret); return salt end if
  verifier = try(deriveKey(secret, salt, DEFAULT_PBKDF2_ITERATIONS, PASSWORD_VERIFIER_BYTES))
  wipeSecret(secret)
  if typeof(verifier) == "error" then return verifier end if
  return PasswordMaterial(salt, DEFAULT_PBKDF2_ITERATIONS, verifier)
end function

function createPasswordMaterial(password)
  secret = validatePassword(password, "createPasswordMaterial")
  salt = try(randomBytes(PASSWORD_SALT_BYTES))
  if typeof(salt) == "error" then fillBytes(secret, 0, len(secret), 0); return salt end if
  verifier = try(deriveKey(secret, salt, DEFAULT_PBKDF2_ITERATIONS, PASSWORD_VERIFIER_BYTES))
  fillBytes(secret, 0, len(secret), 0)
  if typeof(verifier) == "error" then return verifier end if
  return PasswordMaterial(salt, DEFAULT_PBKDF2_ITERATIONS, verifier)
end function

function wipePasswordMaterial(material)
  if material is not PasswordMaterial then return false end if
  if typeof(material.salt) == "bytes" then fillBytes(material.salt, 0, len(material.salt), 0) end if
  if typeof(material.verifier) == "bytes" then fillBytes(material.verifier, 0, len(material.verifier), 0) end if
  material.iterations = 0
  return true
end function

function verifyPasswordBytes(passwordBytes, salt, iterations, expected)
  if typeof(salt) != "bytes" or len(salt) != PASSWORD_SALT_BYTES or typeof(expected) != "bytes" or len(expected) != PASSWORD_VERIFIER_BYTES then
    return fail(INVALID_ARGUMENT, "verifyPasswordBytes", "invalid password material")
  end if
  if typeof(iterations) != "int" or iterations < MIN_PBKDF2_ITERATIONS or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "verifyPasswordBytes", "invalid PBKDF2 work factor") end if
  secret = validatePasswordBytes(passwordBytes, "verifyPasswordBytes")
  actual = try(deriveKey(secret, salt, iterations, PASSWORD_VERIFIER_BYTES))
  wipeSecret(secret)
  if typeof(actual) == "error" then return actual end if
  result = constantTimeEquals(actual, expected)
  wipeSecret(actual)
  return result
end function

function verifyPassword(password, salt, iterations, expected)
  if typeof(salt) != "bytes" or len(salt) != PASSWORD_SALT_BYTES or typeof(expected) != "bytes" or len(expected) != PASSWORD_VERIFIER_BYTES then
    return fail(INVALID_ARGUMENT, "verifyPassword", "invalid password material")
  end if
  if typeof(iterations) != "int" or iterations < MIN_PBKDF2_ITERATIONS or iterations > MAX_PBKDF2_ITERATIONS then return fail(INVALID_ARGUMENT, "verifyPassword", "invalid PBKDF2 work factor") end if
  secret = validatePassword(password, "verifyPassword")
  actual = try(deriveKey(secret, salt, iterations, PASSWORD_VERIFIER_BYTES))
  fillBytes(secret, 0, len(secret), 0)
  if typeof(actual) == "error" then return actual end if
  result = constantTimeEquals(actual, expected)
  fillBytes(actual, 0, len(actual), 0)
  return result
end function

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

function authProof(verifier, nonce, username, label)
  if typeof(verifier) != "bytes" or len(verifier) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "authProof", "verifier must be 32 bytes") end if
  if typeof(nonce) != "bytes" or len(nonce) != AUTH_NONCE_BYTES then return fail(INVALID_ARGUMENT, "authProof", "nonce must be 32 bytes") end if
  if typeof(username) != "string" or len(username) == 0 or typeof(label) != "string" or len(label) == 0 then return fail(INVALID_ARGUMENT, "authProof", "username and label must be non-empty") end if
  transcript = bytes("MiniSQL-AUTH-1|" + label + "|" + username) + nonce
  return deriveKey(verifier, transcript, 1, PASSWORD_VERIFIER_BYTES)
end function


function sha256(input)
  if typeof(input) != "bytes" then return fail(INVALID_ARGUMENT, "sha256", "input must be bytes") end if
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
end function

function hmacSha256(key, input)
  if typeof(key) != "bytes" or len(key) == 0 or len(key) > 4096 then return fail(INVALID_ARGUMENT, "hmacSha256", "key must contain 1..4096 bytes") end if
  if typeof(input) != "bytes" then return fail(INVALID_ARGUMENT, "hmacSha256", "input must be bytes") end if
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
end function

function transportKey(verifier, nonce, username, label)
  if typeof(verifier) != "bytes" or len(verifier) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportKey", "verifier must be 32 bytes") end if
  if typeof(nonce) != "bytes" or len(nonce) != AUTH_NONCE_BYTES then return fail(INVALID_ARGUMENT, "transportKey", "nonce must be 32 bytes") end if
  if typeof(username) != "string" or len(username) == 0 or typeof(label) != "string" or len(label) == 0 then return fail(INVALID_ARGUMENT, "transportKey", "username and label must be non-empty") end if
  context = bytes("MiniSQL-TRANSPORT-1|" + label + "|" + username) + nonce
  return deriveKey(verifier, context, 1, PASSWORD_VERIFIER_BYTES)
end function

// Compatibility keyed authenticator used by the M30 audit-chain format.
// The domain, frame fields and authenticated bytes are all included so tags
// from one purpose cannot be replayed in another purpose.
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

function sequenceBytes(sequence)
  if typeof(sequence) != "int" or sequence < 0 then return fail(INVALID_ARGUMENT, "sequenceBytes", "sequence must be non-negative") end if
  output = bytes(8, 0)
  endian.writeU64LE(output, 0, endian.uint64FromInt(sequence))
  return output
end function

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

function nativeHandle(handleBytes, operation)
  handle = try(endian.uint64ToInt(endian.readU64LE(handleBytes, 0)))
  if typeof(handle) == "error" or handle == 0 then return fail(IO_FAILURE, operation, "native provider returned an invalid handle") end if
  return handle
end function

function openAesGcm(keyBytes)
  if typeof(keyBytes) != "bytes" or len(keyBytes) != 32 then return fail(INVALID_ARGUMENT, "openAesGcm", "key must be 32 bytes") end if
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
end function

function closeAesGcm(state)
  if typeof(state) != "array" or len(state) != 3 then return false end if
  if typeof(state[1]) == "int" and state[1] != 0 then ignoredKey = BCryptDestroyKey(state[1]) end if
  if typeof(state[0]) == "int" and state[0] != 0 then ignoredProvider = BCryptCloseAlgorithmProvider(state[0], 0) end if
  if typeof(state[2]) == "bytes" then wipeSecret(state[2]) end if
  return true
end function

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

function transportEncrypt(key, sequence, messageType, flags, requestId, plaintext)
  if typeof(key) != "bytes" or len(key) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportEncrypt", "key must be 32 bytes") end if
  if typeof(plaintext) != "bytes" then return fail(INVALID_ARGUMENT, "transportEncrypt", "plaintext must be bytes") end if
  nonce = transportNonce(key, sequence)
  aad = transportAssociatedData(messageType, flags, requestId, sequence, len(plaintext))
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
end function

function transportDecrypt(key, sequence, messageType, flags, requestId, ciphertext, tag)
  if typeof(key) != "bytes" or len(key) != PASSWORD_VERIFIER_BYTES then return fail(INVALID_ARGUMENT, "transportDecrypt", "key must be 32 bytes") end if
  if typeof(ciphertext) != "bytes" or typeof(tag) != "bytes" or len(tag) != AES_GCM_TAG_BYTES then return fail(INVALID_ARGUMENT, "transportDecrypt", "ciphertext or tag is invalid") end if
  nonce = transportNonce(key, sequence)
  aad = transportAssociatedData(messageType, flags, requestId, sequence, len(ciphertext))
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
end function

function isAeadPacket(value)
  return value is AeadPacket
end function

function authenticationFailure()
  return fail(AUTHENTICATION_FAILED, "authenticate", "authentication failed")
end function

function componentName()
  return "common.uuid"
end function

function targetMilestone()
  return "M8"
end function

function isImplemented()
  return true
end function
