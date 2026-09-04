//! Provides minisql common limits facilities for this project.

package minisql.common.limits
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

/// Shared format and protocol limits. Keeping these bounds in one module makes

const DEFAULT_PORT = 7432
/// Defines the default page size constant used by the minisql common limits module.
const DEFAULT_PAGE_SIZE = 4096
/// Defines the min page size constant used by the minisql common limits module.
const MIN_PAGE_SIZE = 4096
/// Defines the max page size constant used by the minisql common limits module.
const MAX_PAGE_SIZE = 32768
/// Defines the max identifier bytes constant used by the minisql common limits module.
const MAX_IDENTIFIER_BYTES = 128
/// Defines the max sql nesting constant used by the minisql common limits module.
const MAX_SQL_NESTING = 64
/// Defines the max decimal precision constant used by the minisql common limits module.
const MAX_DECIMAL_PRECISION = 18
/// Defines the max time precision constant used by the minisql common limits module.
const MAX_TIME_PRECISION = 6

/// Evaluates whether the supplied input satisfies the supported page size predicate.
/// Inputs: `pageSize`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
/// @param pageSize pageSize value consumed by this operation.
function isSupportedPageSize(pageSize)
  return pageSize == 4096 or pageSize == 8192 or pageSize == 16384 or pageSize == 32768
end function

/// Performs the componentName operation for the minisql common limits module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.limits"
end function

/// Performs the targetMilestone operation for the minisql common limits module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

/// Returns whether implemented satisfies the condition required by the minisql common limits module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
