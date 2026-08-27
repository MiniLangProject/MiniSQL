package minisql.protocol.constants

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

const PROTOCOL_MAGIC = "MSQL"
const PROTOCOL_VERSION = 1
const HEADER_BYTES = 32
const HEADER_CRC_OFFSET = 24
const MAX_PAYLOAD_BYTES = 1048576
const MAX_COLUMNS = 1024
const MAX_ROWS_PER_MESSAGE = 512
const DEFAULT_RESULT_BATCH_ROWS = 512
const FLAG_SECURE = 1
// Indicates that another response frame with the same request identifier follows.
const FLAG_MORE = 2
const SECURE_OVERHEAD_BYTES = 24
const MAX_SECURE_PLAINTEXT_BYTES = MAX_PAYLOAD_BYTES - SECURE_OVERHEAD_BYTES

const TYPE_HELLO = 1
const TYPE_QUERY = 2
const TYPE_PING = 3
const TYPE_CLOSE = 4
const TYPE_AUTH_BEGIN = 5
const TYPE_AUTH_CHALLENGE = 6
const TYPE_AUTH_PROOF = 7
const TYPE_AUTH_OK = 8
const TYPE_RESPONSE = 100
const TYPE_PONG = 101
const TYPE_ERROR = 102

const STATUS_COMMAND = 1
const STATUS_ROWS = 2
const STATUS_ERROR = 3

// Implements known type for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function knownType(value)
  return value == TYPE_HELLO or value == TYPE_QUERY or value == TYPE_PING or value == TYPE_CLOSE or value == TYPE_AUTH_BEGIN or value == TYPE_AUTH_CHALLENGE or value == TYPE_AUTH_PROOF or value == TYPE_AUTH_OK or value == TYPE_RESPONSE or value == TYPE_PONG or value == TYPE_ERROR
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "protocol.constants"
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
