package minisql.common.limits
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

// Shared format and protocol limits. Keeping these bounds in one module makes
// validation consistent between parsers, storage codecs, and network paths.

const DEFAULT_PORT = 7432
const DEFAULT_PAGE_SIZE = 4096
const MIN_PAGE_SIZE = 4096
const MAX_PAGE_SIZE = 32768
const MAX_IDENTIFIER_BYTES = 128
const MAX_SQL_NESTING = 64
const MAX_DECIMAL_PRECISION = 18
const MAX_TIME_PRECISION = 6

// Evaluates whether the supplied input satisfies the supported page size predicate.
// Inputs: `pageSize`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isSupportedPageSize(pageSize)
  return pageSize == 4096 or pageSize == 8192 or pageSize == 16384 or pageSize == 32768
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.limits"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
