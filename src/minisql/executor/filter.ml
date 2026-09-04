//! Provides minisql executor filter facilities for this project.

package minisql.executor.filter

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.executor.scan as scan
import minisql.sql.expressions as expressions

/// Defines the invalid argument constant used by the minisql executor filter module.
const INVALID_ARGUMENT = 9001

/// Performs the fail operation for the minisql executor filter module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "executor.filter." + operation + ": " + message)
end function

/// Applies apply using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param rows rows value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
function apply(rows, predicate)
  if typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "apply", "rows must be array") end if
  if predicate is not void and not expressions.isBoundExpression(predicate) then return fail(INVALID_ARGUMENT, "apply", "predicate must be BoundExpression or void") end if
  output = []
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "apply", "rows contain non-ScannedRow") end if
    if expressions.predicatePasses(predicate, expressions.rowContext(row.values)) then output = output + [row] end if
  end for
  return output
end function

/// Performs the componentName operation for the minisql executor filter module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.filter"
end function

/// Performs the targetMilestone operation for the minisql executor filter module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M15"
end function

/// Returns whether implemented satisfies the condition required by the minisql executor filter module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
