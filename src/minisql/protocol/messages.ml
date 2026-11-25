//! Provides minisql protocol messages facilities for this project.

package minisql.protocol.messages

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.protocol.constants as constants

/// Defines the invalid argument constant used by the minisql protocol messages module.
const INVALID_ARGUMENT = 9001
/// Defines the corrupt data constant used by the minisql protocol messages module.
const CORRUPT_DATA = 9004

/// Groups the message state and preserves the field relationships documented below.
struct Message
  /// Stores the message type associated with this value.
  messageType
  /// Stores the flags associated with this value.
  flags
  /// Identifies the request identifier.
  requestId
  /// Stores the payload associated with this value.
  payload
end struct

/// Groups the response state and preserves the field relationships documented below.
struct Response
  /// Stores the status associated with this value.
  status
  /// Stores the command associated with this value.
  command
  /// Contains the ordered columns collection.
  columns
  /// Contains the ordered rows collection.
  rows
  /// Stores the affected rows associated with this value.
  affectedRows
  /// Stores the message associated with this value.
  message
  /// Stores the error code associated with this value.
  errorCode
  /// Client/server framing metadata; true at a new result boundary, not encoded in the payload.
  resultStart
  /// Optional negotiated metadata; absent on legacy responses.
  metadata
end struct

/// One structured SQL condition, independent of localized message text.
struct Condition
  /// Five-character SQLSTATE.
  sqlState
  /// Condition error number, including application MYSQL_ERRNO values.
  code
  /// Human-readable diagnostic text.
  message
end struct

/// One successful outer CALL output, identified by declaration ordinal.
struct OutputParameter
  /// One-based parameter declaration position.
  ordinal
  /// Parameter name from the routine declaration.
  name
  /// Native SqlTypeKind code from zero through sixteen.
  typeKind
  /// Distinguishes SQL NULL from the literal text NULL.
  isNull
  /// Canonical textual value; empty for SQL NULL.
  value
end struct

/// Optional response trailer negotiated through the results-v2 capability.
struct ResultMetadata
  /// Statement SQLSTATE; successful responses use 00000.
  sqlState
  /// Ordered statement warnings, emitted on the terminal response only.
  warnings
  /// Row-major SQL NULL bits, least-significant bit first.
  nullBitmap
  /// Native column SqlTypeKind codes; zero denotes an unknown type.
  columnTypes
  /// Successful outer CALL output values, emitted on its final command.
  outputs
end struct

/// Creates an empty metadata trailer without enabling it for legacy peers.
function newMetadata()
  return ResultMetadata("00000", [], bytes(0), [], [])
end function

/// Performs the fail operation for the minisql protocol messages module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "protocol.messages." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the message condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isMessage(value)
  return value is Message
end function

/// Returns whether the supplied value satisfies the response condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isResponse(value)
  return value is Response
end function

/// Creates create for the minisql protocol messages module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param messageType messageType value consumed by this operation.
/// @param flags Bit flags controlling the operation.
/// @param requestId Identifier of request.
/// @param payload payload value consumed by this operation.
function create(messageType, flags, requestId, payload)
  if typeof(messageType) != "int" or not constants.knownType(messageType) then return fail(INVALID_ARGUMENT, "create", "unknown message type") end if
  if typeof(flags) != "int" or flags < 0 or flags > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "create", "flags must fit U32") end if
  if typeof(requestId) != "int" or requestId < 0 or requestId > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "create", "requestId must fit U32") end if
  if typeof(payload) != "bytes" or len(payload) > constants.MAX_PAYLOAD_BYTES then return fail(INVALID_ARGUMENT, "create", "payload is invalid") end if
  return Message(messageType, flags, requestId, bytes(payload))
end function

/// Implements hello for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
function hello(requestId)
  return create(constants.TYPE_HELLO, 0, requestId, bytes("MiniSQL/1"))
end function

/// Requests the optional structured-result extension while retaining protocol v1.
function helloExtended(requestId)
  return create(constants.TYPE_HELLO, 0, requestId, bytes("MiniSQL/1; capabilities=results-v2"))
end function

/// Implements query for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
/// @param sqlText sqlText value consumed by this operation.
function query(requestId, sqlText)
  if typeof(sqlText) != "string" or len(bytes(sqlText)) > constants.MAX_PAYLOAD_BYTES then return fail(INVALID_ARGUMENT, "query", "SQL text is invalid") end if
  return create(constants.TYPE_QUERY, 0, requestId, bytes(sqlText))
end function

/// Implements auth begin for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
/// @param username username value consumed by this operation.
function authBegin(requestId, username)
  if typeof(username) != "string" or len(bytes(username)) == 0 or len(bytes(username)) > 128 then return fail(INVALID_ARGUMENT, "authBegin", "username is invalid") end if
  raw = bytes(username)
  payload = bytes(2 + len(raw), 0)
  endian.writeU16LE(payload, 0, len(raw))
  copyBytes(payload, 2, raw, 0, len(raw))
  return create(constants.TYPE_AUTH_BEGIN, 0, requestId, payload)
end function

/// Decodes auth begin using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param payload payload value consumed by this operation.
function decodeAuthBegin(payload)
  if typeof(payload) != "bytes" or len(payload) < 3 then return fail(CORRUPT_DATA, "decodeAuthBegin", "authentication-begin payload is truncated") end if
  length = endian.readU16LE(payload, 0)
  if length == 0 or length > 128 or len(payload) != 2 + length then return fail(CORRUPT_DATA, "decodeAuthBegin", "authentication username length is invalid") end if
  username = decode(slice(payload, 2, length))
  if typeof(username) != "string" then return fail(CORRUPT_DATA, "decodeAuthBegin", "authentication username is not UTF-8") end if
  return username
end function

/// Implements auth challenge for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
/// @param iterations iterations value consumed by this operation.
/// @param salt salt value consumed by this operation.
/// @param nonce nonce value consumed by this operation.
/// @param scheme scheme value consumed by this operation.
function authChallenge(requestId, iterations, salt, nonce, scheme)
  if typeof(iterations) != "int" or iterations < 10000 or iterations > 5000000 then return fail(INVALID_ARGUMENT, "authChallenge", "iterations are invalid") end if
  if typeof(salt) != "bytes" or len(salt) != 16 or typeof(nonce) != "bytes" or len(nonce) != 32 then return fail(INVALID_ARGUMENT, "authChallenge", "salt or nonce is invalid") end if
  if typeof(scheme) != "int" or (scheme != 1 and scheme != 2) then return fail(INVALID_ARGUMENT, "authChallenge", "authentication scheme is invalid") end if
  payload = bytes(56, 0)
  endian.writeU32LE(payload, 0, iterations)
  copyBytes(payload, 4, salt, 0, 16)
  copyBytes(payload, 20, nonce, 0, 32)
  endian.writeU16LE(payload, 52, scheme)
  return create(constants.TYPE_AUTH_CHALLENGE, 0, requestId, payload)
end function

/// Decodes auth challenge using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param payload payload value consumed by this operation.
function decodeAuthChallenge(payload)
  if typeof(payload) != "bytes" or (len(payload) != 52 and len(payload) != 56) then return fail(CORRUPT_DATA, "decodeAuthChallenge", "challenge payload size is invalid") end if
  iterations = endian.readU32LE(payload, 0)
  if iterations < 10000 or iterations > 5000000 then return fail(CORRUPT_DATA, "decodeAuthChallenge", "challenge work factor is invalid") end if
  scheme = 1
  if len(payload) == 56 then
    scheme = endian.readU16LE(payload, 52)
    reserved = endian.readU16LE(payload, 54)
    if (scheme != 1 and scheme != 2) or reserved != 0 then return fail(CORRUPT_DATA, "decodeAuthChallenge", "challenge authentication scheme is invalid") end if
  end if
  return [iterations, slice(payload, 4, 16), slice(payload, 20, 32), scheme]
end function

/// Implements auth proof for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
/// @param proof proof value consumed by this operation.
function authProof(requestId, proof)
  if typeof(proof) != "bytes" or len(proof) != 32 then return fail(INVALID_ARGUMENT, "authProof", "proof must be 32 bytes") end if
  return create(constants.TYPE_AUTH_PROOF, 0, requestId, proof)
end function

/// Implements auth ok for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
/// @param serverProof serverProof value consumed by this operation.
function authOk(requestId, serverProof)
  if typeof(serverProof) != "bytes" or len(serverProof) != 32 then return fail(INVALID_ARGUMENT, "authOk", "server proof must be 32 bytes") end if
  return create(constants.TYPE_AUTH_OK, 0, requestId, serverProof)
end function

/// Implements ping for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
function ping(requestId)
  return create(constants.TYPE_PING, 0, requestId, bytes(0))
end function

/// Closes request using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param requestId Identifier of request.
function closeRequest(requestId)
  return create(constants.TYPE_CLOSE, 0, requestId, bytes(0))
end function

/// Creates an administrative cancellation request for one active session.
/// @param requestId Identifier of request.
/// @param sessionId Identifier of session.
function cancelRequest(requestId, sessionId)
  if typeof(sessionId) != "int" or sessionId < 1 or sessionId > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "cancelRequest", "sessionId must fit positive U32") end if
  payload = bytes(4, 0)
  endian.writeU32LE(payload, 0, sessionId)
  return create(constants.TYPE_CANCEL, 0, requestId, payload)
end function

/// Decodes and validates an administrative cancellation target.
/// @param payload payload value consumed by this operation.
function decodeCancelRequest(payload)
  if typeof(payload) != "bytes" or len(payload) != 4 then return fail(CORRUPT_DATA, "decodeCancelRequest", "cancel payload must be four bytes") end if
  sessionId = endian.readU32LE(payload, 0)
  if sessionId < 1 then return fail(CORRUPT_DATA, "decodeCancelRequest", "sessionId must be positive") end if
  return sessionId
end function

/// Implements command response for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param command command value consumed by this operation.
/// @param affectedRows affectedRows value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function commandResponse(command, affectedRows, message)
  return Response(constants.STATUS_COMMAND, command, [], [], affectedRows, message, 0, false, void)
end function

/// Implements row response for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param columns columns value consumed by this operation.
/// @param rows rows value consumed by this operation.
function rowResponse(columns, rows)
  return Response(constants.STATUS_ROWS, "SELECT", columns, rows, len(rows), "", 0, false, void)
end function

/// Collects separate responses without conflating equal-schema result sets.
/// The aggregate is client-only; its rows contain Response objects, not SQL cells.
function multipleResponse(responses)
  return Response(constants.STATUS_MULTIPLE, "CALL", [], responses, 0, "", 0, false, void)
end function

/// Returns the individual responses of one command or stored procedure call.
function individualResponses(response)
  if not isResponse(response) then return fail(INVALID_ARGUMENT, "individualResponses", "response must be Response") end if
  if response.status != constants.STATUS_MULTIPLE then return [response] end if
  output = []
  for each child in response.rows
    output = output + individualResponses(child)
  end for
  return output
end function

/// Creates a protocol error response without changing the wire payload shape.
function errorResponse(code, message)
  return Response(constants.STATUS_ERROR, "ERROR", [], [], 0, message, code, false, void)
end function

/// Implements string bytes for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function stringBytes(value)
  if typeof(value) != "string" then return fail(INVALID_ARGUMENT, "stringBytes", "value must be string") end if
  return bytes(value)
end function

/// Implements field size for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function fieldSize(value)
  raw = stringBytes(value)
  return 4 + len(raw)
end function

/// Writes field using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param output Output collection or buffer populated by the operation.
/// @param offset Zero-based offset at which processing starts.
/// @param value Value consumed or transformed by the operation.
function writeField(output, offset, value)
  raw = stringBytes(value)
  endian.writeU32LE(output, offset, len(raw))
  if len(raw) > 0 then copyBytes(output, offset + 4, raw, 0, len(raw)) end if
  return offset + 4 + len(raw)
end function

/// Reads field using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param source source value consumed by this operation.
/// @param offset Zero-based offset at which processing starts.
function readField(source, offset)
  if offset < 0 or offset > len(source) - 4 then return fail(CORRUPT_DATA, "readField", "field length is truncated") end if
  length = endian.readU32LE(source, offset)
  if length > constants.MAX_PAYLOAD_BYTES or offset + 4 > len(source) - length then return fail(CORRUPT_DATA, "readField", "field data is truncated") end if
  value = decode(slice(source, offset + 4, length))
  if typeof(value) != "string" then return fail(CORRUPT_DATA, "readField", "field is not valid UTF-8") end if
  return [value, offset + 4 + length]
end function

/// Implements response payload size for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param response response value consumed by this operation.
function responsePayloadSize(response)
  size = 24 + fieldSize(response.command) + fieldSize(response.message)
  for each column in response.columns
    size = size + fieldSize(column)
  end for
  for each row in response.rows
    for each value in row
      size = size + fieldSize(value)
    end for
  end for
  return size
end function

/// Encodes response using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param response response value consumed by this operation.
function encodeResponse(response)
  if response is not Response then return fail(INVALID_ARGUMENT, "encodeResponse", "response must be Response") end if
  if typeof(response.status) != "int" or response.status < 1 or response.status > 3 then return fail(INVALID_ARGUMENT, "encodeResponse", "status is invalid") end if
  if typeof(response.affectedRows) != "int" or response.affectedRows < 0 or response.affectedRows > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodeResponse", "affectedRows must fit U32") end if
  if typeof(response.errorCode) != "int" or response.errorCode < 0 or response.errorCode > endian.MAX_U32 then return fail(INVALID_ARGUMENT, "encodeResponse", "errorCode must fit U32") end if
  if typeof(response.command) != "string" or typeof(response.message) != "string" then return fail(INVALID_ARGUMENT, "encodeResponse", "command/message must be strings") end if
  if typeof(response.columns) != "array" or len(response.columns) > constants.MAX_COLUMNS then return fail(INVALID_ARGUMENT, "encodeResponse", "columns are invalid") end if
  if typeof(response.rows) != "array" or len(response.rows) > constants.MAX_ROWS_PER_MESSAGE then return fail(INVALID_ARGUMENT, "encodeResponse", "rows are invalid") end if
  for each row in response.rows
    if typeof(row) != "array" or len(row) != len(response.columns) then return fail(INVALID_ARGUMENT, "encodeResponse", "row width mismatch") end if
  end for
  size = responsePayloadSize(response)
  if size > constants.MAX_PAYLOAD_BYTES then return fail(INVALID_ARGUMENT, "encodeResponse", "response exceeds payload limit") end if
  output = bytes(size, 0)
  endian.writeU16LE(output, 0, response.status)
  endian.writeU16LE(output, 2, 0)
  endian.writeU32LE(output, 4, len(response.columns))
  endian.writeU32LE(output, 8, len(response.rows))
  endian.writeU32LE(output, 12, response.affectedRows)
  endian.writeU32LE(output, 16, response.errorCode)
  endian.writeU32LE(output, 20, 0)
  cursor = 24
  cursor = writeField(output, cursor, response.command)
  cursor = writeField(output, cursor, response.message)
  for each column in response.columns
    cursor = writeField(output, cursor, column)
  end for
  for each row in response.rows
    for each value in row
      cursor = writeField(output, cursor, value)
    end for
  end for
  return output
end function

/// Returns metadata with an explicit all-non-NULL bitmap for manually built rows.
function normalizedMetadata(response)
  value = response.metadata
  if value is not ResultMetadata then value = newMetadata() end if
  bitmapLength = (len(response.rows) * len(response.columns) + 7) >> 3
  if len(value.nullBitmap) == 0 then value.nullBitmap = bytes(bitmapLength, 0) end if
  if len(value.nullBitmap) != bitmapLength then return fail(INVALID_ARGUMENT, "normalizedMetadata", "NULL bitmap length differs from row shape") end if
  if len(value.columnTypes) == 0 then
    value.columnTypes = array(len(response.columns))
    if len(response.columns) > 0 then
      for index = 0 to len(response.columns) - 1
        value.columnTypes[index] = 0
      end for
    end if
  end if
  if len(value.columnTypes) != len(response.columns) then return fail(INVALID_ARGUMENT, "normalizedMetadata", "column type count differs from schema") end if
  return value
end function

/// Validates an exact SQLSTATE without accepting malformed server metadata.
function validSqlState(value)
  if typeof(value) != "string" or len(bytes(value)) != 5 then return false end if
  for each character in bytes(value)
    if not ((character >= 48 and character <= 57) or (character >= 65 and character <= 90)) then return false end if
  end for
  return true
end function

/// Encodes the opt-in trailer; legacy encodeResponse remains byte-for-byte stable.
function encodeResponseExtended(response)
  base = encodeResponse(response)
  extra = normalizedMetadata(response)
  if response.status == constants.STATUS_ERROR and extra.sqlState == "00000" then extra.sqlState = "HY000" end if
  if not validSqlState(extra.sqlState) then return fail(INVALID_ARGUMENT, "encodeResponseExtended", "SQLSTATE is invalid") end if
  size = 4 + fieldSize(extra.sqlState) + 4 + 4 + len(extra.nullBitmap) + 4 + len(extra.columnTypes) * 2 + 4
  for each warning in extra.warnings
    if warning is not Condition or not validSqlState(warning.sqlState) then return fail(INVALID_ARGUMENT, "encodeResponseExtended", "warning is invalid") end if
    size = size + fieldSize(warning.sqlState) + 4 + fieldSize(warning.message)
  end for
  for each output in extra.outputs
    if output is not OutputParameter then return fail(INVALID_ARGUMENT, "encodeResponseExtended", "output parameter is invalid") end if
    size = size + 4 + fieldSize(output.name) + 4 + fieldSize(output.value)
  end for
  if size + len(base) > constants.MAX_PAYLOAD_BYTES then return fail(INVALID_ARGUMENT, "encodeResponseExtended", "response exceeds payload limit") end if
  encoded = bytes(len(base) + size, 0)
  copyBytes(encoded, 0, base, 0, len(base))
  endian.writeU32LE(encoded, 20, size)
  cursor = len(base)
  copyBytes(encoded, cursor, bytes("MDV1"), 0, 4)
  cursor = writeField(encoded, cursor + 4, extra.sqlState)
  endian.writeU32LE(encoded, cursor, len(extra.warnings)); cursor = cursor + 4
  for each warning in extra.warnings
    cursor = writeField(encoded, cursor, warning.sqlState)
    endian.writeU32LE(encoded, cursor, warning.code); cursor = cursor + 4
    cursor = writeField(encoded, cursor, warning.message)
  end for
  endian.writeU32LE(encoded, cursor, len(extra.nullBitmap)); cursor = cursor + 4
  if len(extra.nullBitmap) > 0 then copyBytes(encoded, cursor, extra.nullBitmap, 0, len(extra.nullBitmap)) end if
  cursor = cursor + len(extra.nullBitmap)
  endian.writeU32LE(encoded, cursor, len(extra.columnTypes)); cursor = cursor + 4
  for each kind in extra.columnTypes
    if typeof(kind) != "int" or kind < 0 or kind > 16 then return fail(INVALID_ARGUMENT, "encodeResponseExtended", "column type is invalid") end if
    endian.writeU16LE(encoded, cursor, kind); cursor = cursor + 2
  end for
  endian.writeU32LE(encoded, cursor, len(extra.outputs)); cursor = cursor + 4
  for each output in extra.outputs
    endian.writeU32LE(encoded, cursor, output.ordinal); cursor = cursor + 4
    cursor = writeField(encoded, cursor, output.name)
    endian.writeU16LE(encoded, cursor, output.typeKind)
    nullFlag = 0
    if output.isNull then nullFlag = 1 end if
    endian.writeU16LE(encoded, cursor + 2, nullFlag); cursor = cursor + 4
    cursor = writeField(encoded, cursor, output.value)
  end for
  return encoded
end function

/// Decodes bounded metadata after the ordinary v1 response fields.
function decodeMetadata(source, cursor, columnCount, rowCount)
  if cursor > len(source) - 4 or decode(slice(source, cursor, 4)) != "MDV1" then return fail(CORRUPT_DATA, "decodeMetadata", "metadata version is invalid") end if
  field = readField(source, cursor + 4)
  sqlState = field[0]; cursor = field[1]
  if not validSqlState(sqlState) or cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "SQLSTATE is invalid") end if
  warningCount = endian.readU32LE(source, cursor); cursor = cursor + 4
  if warningCount > 65535 or warningCount > len(source) then return fail(CORRUPT_DATA, "decodeMetadata", "warning count exceeds bounds") end if
  warnings = []
  if warningCount > 0 then
    for index = 0 to warningCount - 1
      field = readField(source, cursor); state = field[0]; cursor = field[1]
      if not validSqlState(state) or cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "warning SQLSTATE is invalid") end if
      code = endian.readU32LE(source, cursor); cursor = cursor + 4
      field = readField(source, cursor); cursor = field[1]
      warnings = warnings + [Condition(state, code, field[0])]
    end for
  end if
  if cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "NULL bitmap is truncated") end if
  bitmapLength = endian.readU32LE(source, cursor); cursor = cursor + 4
  if bitmapLength != ((rowCount * columnCount + 7) >> 3) or cursor > len(source) - bitmapLength then return fail(CORRUPT_DATA, "decodeMetadata", "NULL bitmap shape is invalid") end if
  bitmap = slice(source, cursor, bitmapLength); cursor = cursor + bitmapLength
  if cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "column type count is truncated") end if
  typeCount = endian.readU32LE(source, cursor); cursor = cursor + 4
  if typeCount != columnCount or cursor > len(source) - typeCount * 2 then return fail(CORRUPT_DATA, "decodeMetadata", "column types are invalid") end if
  columnTypes = []
  if typeCount > 0 then
    for index = 0 to typeCount - 1
      kind = endian.readU16LE(source, cursor); cursor = cursor + 2
      if kind > 16 then return fail(CORRUPT_DATA, "decodeMetadata", "column type is invalid") end if
      columnTypes = columnTypes + [kind]
    end for
  end if
  if cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "output parameter count is truncated") end if
  outputCount = endian.readU32LE(source, cursor); cursor = cursor + 4
  if outputCount > 65535 or outputCount > len(source) then return fail(CORRUPT_DATA, "decodeMetadata", "output parameter count exceeds bounds") end if
  outputs = []
  if outputCount > 0 then
    for index = 0 to outputCount - 1
      if cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "output parameter is truncated") end if
      ordinal = endian.readU32LE(source, cursor); cursor = cursor + 4
      field = readField(source, cursor); name = field[0]; cursor = field[1]
      if ordinal < 1 or cursor > len(source) - 4 then return fail(CORRUPT_DATA, "decodeMetadata", "output parameter ordinal is invalid") end if
      kind = endian.readU16LE(source, cursor); nullFlag = endian.readU16LE(source, cursor + 2); cursor = cursor + 4
      if kind > 16 or nullFlag > 1 then return fail(CORRUPT_DATA, "decodeMetadata", "output parameter type is invalid") end if
      field = readField(source, cursor); cursor = field[1]
      outputs = outputs + [OutputParameter(ordinal, name, kind, nullFlag == 1, field[0])]
    end for
  end if
  if cursor != len(source) then return fail(CORRUPT_DATA, "decodeMetadata", "trailing metadata bytes") end if
  return ResultMetadata(sqlState, warnings, bitmap, columnTypes, outputs)
end function

/// Tests SQL NULL explicitly for negotiated responses, with legacy token fallback.
function isNullCell(response, rowIndex, columnIndex)
  if response.metadata is not ResultMetadata then return response.rows[rowIndex][columnIndex] == "NULL" end if
  position = rowIndex * len(response.columns) + columnIndex
  return (response.metadata.nullBitmap[position >> 3] & (1 << (position & 7))) != 0
end function

/// Appends compatible continuation rows while preserving row-major NULL positions.
function appendRows(target, source)
  if target.metadata is ResultMetadata and source.metadata is ResultMetadata then
    oldCells = len(target.rows) * len(target.columns)
    newCells = len(source.rows) * len(source.columns)
    bitmap = bytes((oldCells + newCells + 7) >> 3, 0)
    if len(target.metadata.nullBitmap) > 0 then copyBytes(bitmap, 0, target.metadata.nullBitmap, 0, len(target.metadata.nullBitmap)) end if
    if newCells > 0 then
      for index = 0 to newCells - 1
        if (source.metadata.nullBitmap[index >> 3] & (1 << (index & 7))) != 0 then
          position = oldCells + index
          bitmap[position >> 3] = bitmap[position >> 3] | (1 << (position & 7))
        end if
      end for
    end if
    target.metadata.nullBitmap = bitmap
    target.metadata.warnings = target.metadata.warnings + source.metadata.warnings
  end if
  target.rows = target.rows + source.rows
  target.affectedRows = target.affectedRows + source.affectedRows
  return target
end function

/// Decodes response using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param source source value consumed by this operation.
function decodeResponse(source)
  if typeof(source) != "bytes" or len(source) < 24 or len(source) > constants.MAX_PAYLOAD_BYTES then return fail(CORRUPT_DATA, "decodeResponse", "payload size is invalid") end if
  status = endian.readU16LE(source, 0)
  if status < 1 or status > 3 or endian.readU16LE(source, 2) != 0 then return fail(CORRUPT_DATA, "decodeResponse", "response header is invalid") end if
  metadataLength = endian.readU32LE(source, 20)
  if metadataLength > len(source) - 24 then return fail(CORRUPT_DATA, "decodeResponse", "metadata length is invalid") end if
  columnCount = endian.readU32LE(source, 4)
  rowCount = endian.readU32LE(source, 8)
  if columnCount > constants.MAX_COLUMNS or rowCount > constants.MAX_ROWS_PER_MESSAGE then return fail(CORRUPT_DATA, "decodeResponse", "response counts exceed limits") end if
  cursor = 24
  commandField = readField(source, cursor)
  command = commandField[0]
  cursor = commandField[1]
  messageField = readField(source, cursor)
  message = messageField[0]
  cursor = messageField[1]
  columns = array(columnCount)
  if columnCount > 0 then
    for index = 0 to columnCount - 1
      field = readField(source, cursor)
      columns[index] = field[0]
      cursor = field[1]
    end for
  end if
  rows = array(rowCount)
  if rowCount > 0 then
    for rowIndex = 0 to rowCount - 1
      row = array(columnCount)
      if columnCount > 0 then
        for columnIndex = 0 to columnCount - 1
          field = readField(source, cursor)
          row[columnIndex] = field[0]
          cursor = field[1]
        end for
      end if
      rows[rowIndex] = row
    end for
  end if
  if cursor != len(source) - metadataLength then return fail(CORRUPT_DATA, "decodeResponse", "trailing response bytes") end if
  extra = void
  if metadataLength > 0 then extra = decodeMetadata(source, cursor, columnCount, rowCount) end if
  return Response(status, command, columns, rows, endian.readU32LE(source, 12), message, endian.readU32LE(source, 16), false, extra)
end function

/// Performs the componentName operation for the minisql protocol messages module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "protocol.messages"
end function

/// Performs the targetMilestone operation for the minisql protocol messages module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql protocol messages module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
