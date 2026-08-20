package minisql.protocol.codec

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.crc32c as crc32c
import minisql.common.endian as endian
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003
const CORRUPT_DATA = 9004

// Groups the header state and preserves the field relationships documented below.
struct Header
  // Stores the message type associated with this value.
  messageType
  // Stores the flags associated with this value.
  flags
  // Identifies the request identifier.
  requestId
  // Tracks the payload length numeric value.
  payloadLength
  // Stores the payload checksum associated with this value.
  payloadChecksum
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "protocol.codec." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the header condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isHeader(value)
  return value is Header
end function

// Implements copy range for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function copyRange(source, offset, count, operation)
  if typeof(source) != "bytes" or typeof(offset) != "int" or typeof(count) != "int" or offset < 0 or count < 0 or offset > len(source) - count then
    return fail(CORRUPT_DATA, operation, "byte range is invalid")
  end if
  output = bytes(count, 0)
  if count > 0 then copyBytes(output, 0, source, offset, count) end if
  return output
end function

// Writes magic using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function writeMagic(output)
  raw = bytes(constants.PROTOCOL_MAGIC)
  copyBytes(output, 0, raw, 0, 4)
  return true
end function

// Implements magic matches for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function magicMatches(source)
  raw = bytes(constants.PROTOCOL_MAGIC)
  if len(source) < 4 then return false end if
  for index = 0 to 3
    if source[index] != raw[index] then return false end if
  end for
  return true
end function

// Encodes header using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function encodeHeader(message)
  if not messages.isMessage(message) then return fail(INVALID_ARGUMENT, "encodeHeader", "message must be Message") end if
  output = bytes(constants.HEADER_BYTES, 0)
  writeMagic(output)
  endian.writeU16LE(output, 4, constants.PROTOCOL_VERSION)
  endian.writeU16LE(output, 6, message.messageType)
  endian.writeU32LE(output, 8, message.flags)
  endian.writeU32LE(output, 12, message.requestId)
  endian.writeU32LE(output, 16, len(message.payload))
  endian.writeU32LE(output, 20, crc32c.compute(message.payload))
  endian.writeU32LE(output, 24, 0)
  endian.writeU32LE(output, 28, 0)
  endian.writeU32LE(output, 24, crc32c.compute(output))
  return output
end function

// Decodes header using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function decodeHeader(source)
  if typeof(source) != "bytes" or len(source) != constants.HEADER_BYTES then return fail(CORRUPT_DATA, "decodeHeader", "header must have exact size") end if
  if not magicMatches(source) then return fail(CORRUPT_DATA, "decodeHeader", "magic mismatch") end if
  version = endian.readU16LE(source, 4)
  if version != constants.PROTOCOL_VERSION then return fail(UNSUPPORTED_FORMAT, "decodeHeader", "protocol version is unsupported") end if
  messageType = endian.readU16LE(source, 6)
  if not constants.knownType(messageType) then return fail(UNSUPPORTED_FORMAT, "decodeHeader", "unknown message type") end if
  payloadLength = endian.readU32LE(source, 16)
  if payloadLength > constants.MAX_PAYLOAD_BYTES then return fail(CORRUPT_DATA, "decodeHeader", "payload length exceeds limit") end if
  if endian.readU32LE(source, 28) != 0 then return fail(UNSUPPORTED_FORMAT, "decodeHeader", "reserved field is non-zero") end if
  expected = endian.readU32LE(source, 24)
  check = bytes(source)
  endian.writeU32LE(check, 24, 0)
  if crc32c.compute(check) != expected then return fail(CORRUPT_DATA, "decodeHeader", "header checksum mismatch") end if
  return Header(messageType, endian.readU32LE(source, 8), endian.readU32LE(source, 12), payloadLength, endian.readU32LE(source, 20))
end function

// Encodes message using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function encodeMessage(message)
  header = encodeHeader(message)
  output = bytes(len(header) + len(message.payload), 0)
  copyBytes(output, 0, header, 0, len(header))
  if len(message.payload) > 0 then copyBytes(output, len(header), message.payload, 0, len(message.payload)) end if
  return output
end function

// Decodes message using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function decodeMessage(source)
  if typeof(source) != "bytes" or len(source) < constants.HEADER_BYTES then return fail(CORRUPT_DATA, "decodeMessage", "frame is truncated") end if
  headerBytes = try(copyRange(source, 0, constants.HEADER_BYTES, "decodeMessage"))
  if typeof(headerBytes) == "error" then return headerBytes end if
  header = try(decodeHeader(headerBytes))
  if typeof(header) == "error" then return header end if
  if len(source) != constants.HEADER_BYTES + header.payloadLength then return fail(CORRUPT_DATA, "decodeMessage", "frame length mismatch") end if
  payload = try(copyRange(source, constants.HEADER_BYTES, header.payloadLength, "decodeMessage"))
  if typeof(payload) == "error" then return payload end if
  if crc32c.compute(payload) != header.payloadChecksum then return fail(CORRUPT_DATA, "decodeMessage", "payload checksum mismatch") end if
  return messages.create(header.messageType, header.flags, header.requestId, payload)
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "protocol.codec"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
