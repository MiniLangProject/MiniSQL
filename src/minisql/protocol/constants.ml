// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

//! Provides minisql protocol constants facilities for this project.

package minisql.protocol.constants

/// Defines the protocol magic identifier used on every MiniSQL wire frame.
const PROTOCOL_MAGIC = "MSQL"
/// Defines the protocol version constant used by the minisql protocol constants module.
const PROTOCOL_VERSION = 1
/// Defines the header bytes constant used by the minisql protocol constants module.
const HEADER_BYTES = 32
/// Defines the header crc offset constant used by the minisql protocol constants module.
const HEADER_CRC_OFFSET = 24
/// Hard framing guard for one exceptionally wide SQL value or SQL statement.
const MAX_PAYLOAD_BYTES = 16777216
/// Defines the max columns constant used by the minisql protocol constants module.
const MAX_COLUMNS = 1024
/// Defines the max rows per message constant used by the minisql protocol constants module.
const MAX_ROWS_PER_MESSAGE = 512
/// Defines the default result batch rows constant used by the minisql protocol constants module.
const DEFAULT_RESULT_BATCH_ROWS = 512
/// Defines the flag secure constant used by the minisql protocol constants module.
const FLAG_SECURE = 1
/// Indicates that another response frame with the same request identifier follows.
const FLAG_MORE = 2
/// Defines the secure overhead bytes constant used by the minisql protocol constants module.
const SECURE_OVERHEAD_BYTES = 24
/// Defines the max secure plaintext bytes constant used by the minisql protocol constants module.
const MAX_SECURE_PLAINTEXT_BYTES = MAX_PAYLOAD_BYTES - SECURE_OVERHEAD_BYTES
/// Preferred response payload size used for backpressure-friendly batching.
const TARGET_RESULT_FRAME_BYTES = 1048576 - SECURE_OVERHEAD_BYTES

/// Defines the type hello constant used by the minisql protocol constants module.
const TYPE_HELLO = 1
/// Defines the type query constant used by the minisql protocol constants module.
const TYPE_QUERY = 2
/// Defines the type ping constant used by the minisql protocol constants module.
const TYPE_PING = 3
/// Defines the type close constant used by the minisql protocol constants module.
const TYPE_CLOSE = 4
/// Defines the type auth begin constant used by the minisql protocol constants module.
const TYPE_AUTH_BEGIN = 5
/// Defines the type auth challenge constant used by the minisql protocol constants module.
const TYPE_AUTH_CHALLENGE = 6
/// Defines the type auth proof constant used by the minisql protocol constants module.
const TYPE_AUTH_PROOF = 7
/// Defines the type auth ok constant used by the minisql protocol constants module.
const TYPE_AUTH_OK = 8
/// Administrative request that cooperatively cancels another session's query.
const TYPE_CANCEL = 9
/// Defines the type response constant used by the minisql protocol constants module.
const TYPE_RESPONSE = 100
/// Defines the type pong constant used by the minisql protocol constants module.
const TYPE_PONG = 101
/// Defines the type error constant used by the minisql protocol constants module.
const TYPE_ERROR = 102

/// Defines the status command constant used by the minisql protocol constants module.
const STATUS_COMMAND = 1
/// Defines the status rows constant used by the minisql protocol constants module.
const STATUS_ROWS = 2
/// Defines the status error constant used by the minisql protocol constants module.
const STATUS_ERROR = 3

/// Implements known type for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
function knownType(value)
  return value == TYPE_HELLO or value == TYPE_QUERY or value == TYPE_PING or value == TYPE_CLOSE or value == TYPE_AUTH_BEGIN or value == TYPE_AUTH_CHALLENGE or value == TYPE_AUTH_PROOF or value == TYPE_AUTH_OK or value == TYPE_CANCEL or value == TYPE_RESPONSE or value == TYPE_PONG or value == TYPE_ERROR
end function

/// Performs the componentName operation for the minisql protocol constants module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "protocol.constants"
end function

/// Performs the targetMilestone operation for the minisql protocol constants module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M18"
end function

/// Returns whether implemented satisfies the condition required by the minisql protocol constants module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
