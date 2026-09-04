//! Provides minisql common crc32c facilities for this project.

package minisql.common.crc32c
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import std.checksum.crc32c as stdCrc32c

/// MiniSQL's stable CRC-32C facade preserves its structured error contract while

const INVALID_ARGUMENT = 9001
/// Defines the max u32 constant used by the minisql common crc32c module.
const MAX_U32 = 0xFFFFFFFF

/// Performs the invalid operation for the minisql common crc32c module.
/// Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function invalid(operation, message)
  return error(INVALID_ARGUMENT, "common.crc32c." + operation + ": " + message)
end function

/// Validates the range.
/// Inputs: `buffer`, `offset`, `length`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
/// @param operation operation value consumed by this operation.
function validateRange(buffer, offset, length, operation)
  if typeof(buffer) != "bytes" then
    return invalid(operation, "buffer must be bytes")
  end if
  if typeof(offset) != "int" or typeof(length) != "int" then
    return invalid(operation, "offset and length must be int")
  end if
  if offset < 0 or length < 0 or offset > len(buffer) or length > len(buffer) - offset then
    return invalid(operation, "range exceeds buffer bounds")
  end if
  return true
end function

/// Continues a finalized CRC-32C value over the requested byte range.
/// Inputs: `previous`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param previous previous value consumed by this operation.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
function update(previous, buffer, offset, length)
  if typeof(previous) != "int" or previous < 0 or previous > MAX_U32 then
    return invalid("update", "previous checksum must fit U32")
  end if
  validateRange(buffer, offset, length, "update")
  return stdCrc32c.update(previous, buffer, offset, length)
end function

/// Computes the range.
/// Inputs: `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
function computeRange(buffer, offset, length)
  return update(0, buffer, offset, length)
end function

/// Computes the requested value.
/// Inputs: `buffer`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param buffer Buffer that receives or supplies the operation data.
function compute(buffer)
  if typeof(buffer) != "bytes" then
    return invalid("compute", "buffer must be bytes")
  end if
  return computeRange(buffer, 0, len(buffer))
end function

/// Verifies the range.
/// Inputs: `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param buffer Buffer that receives or supplies the operation data.
/// @param offset Zero-based offset at which processing starts.
/// @param length length value consumed by this operation.
/// @param expected expected value consumed by this operation.
function verifyRange(buffer, offset, length, expected)
  if typeof(expected) != "int" or expected < 0 or expected > MAX_U32 then
    return invalid("verifyRange", "expected checksum must fit U32")
  end if
  return computeRange(buffer, offset, length) == expected
end function

/// Performs the componentName operation for the minisql common crc32c module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.crc32c"
end function

/// Performs the targetMilestone operation for the minisql common crc32c module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M2"
end function

/// Returns whether implemented satisfies the condition required by the minisql common crc32c module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
