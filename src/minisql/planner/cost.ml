package minisql.planner.cost

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

// Integer cost model. Costs are abstract work units, deliberately deterministic
// so plans and acceptance tests do not depend on wall-clock timing.

const INVALID_ARGUMENT = 9001

// Groups the cost estimate state and preserves the field relationships documented below.
struct CostEstimate
  // Stores the startup associated with this value.
  startup
  // Stores the total associated with this value.
  total
  // Contains the ordered rows collection.
  rows
  // Stores the algorithm associated with this value.
  algorithm
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "planner.cost." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the cost estimate condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isCostEstimate(value)
  return value is CostEstimate
end function

// Validates rows using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function validateRows(value, operation, name)
  if typeof(value) != "int" or value < 0 then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative int") end if
  return true
end function

// Estimates estimate using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function estimate(startup, total, rows, algorithm)
  validateRows(startup, "estimate", "startup")
  validateRows(total, "estimate", "total")
  validateRows(rows, "estimate", "rows")
  if total < startup or typeof(algorithm) != "string" then return fail(INVALID_ARGUMENT, "estimate", "invalid cost") end if
  return CostEstimate(startup, total, rows, algorithm)
end function

// Implements sequential scan for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sequentialScan(pageCount, rowCount)
  validateRows(pageCount, "sequentialScan", "pageCount")
  validateRows(rowCount, "sequentialScan", "rowCount")
  return estimate(1, 1 + pageCount * 8 + rowCount, rowCount, "Sequential Scan")
end function

// Implements filter for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function filter(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "filter", "input must be CostEstimate") end if
  validateRows(outputRows, "filter", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Filter")
end function

// Implements nested loop for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nestedLoop(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "nestedLoop", "inputs must be CostEstimate") end if
  validateRows(outputRows, "nestedLoop", "outputRows")
  work = left.total + left.rows * (right.total + 1)
  return estimate(left.startup + right.startup, work, outputRows, "Nested Loop Join")
end function

// Implements hash join for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function hashJoin(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "hashJoin", "inputs must be CostEstimate") end if
  validateRows(outputRows, "hashJoin", "outputRows")
  work = left.total + right.total + (left.rows + right.rows) * 3
  return estimate(left.startup + right.startup + right.rows, work, outputRows, "Hash Join")
end function

// Implements aggregate for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function aggregate(input, groupRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "aggregate", "input must be CostEstimate") end if
  validateRows(groupRows, "aggregate", "groupRows")
  return estimate(input.startup, input.total + input.rows * 2, groupRows, "Hash Aggregate")
end function

// Sorts sort using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sort(input)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "sort", "input must be CostEstimate") end if
  factor = 1
  remaining = input.rows
  while remaining > 1
    remaining = remaining >> 1
    factor = factor + 1
  end while
  return estimate(input.startup + input.rows, input.total + input.rows * factor, input.rows, "Stable Merge Sort")
end function

// Implements external sort for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function externalSort(input)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "externalSort", "input must be CostEstimate") end if
  factor = 1
  remaining = input.rows
  while remaining > 1
    remaining = remaining >> 1
    factor = factor + 1
  end while
  // Run generation plus pairwise merge I/O. Costs are deterministic abstract
  // work units rather than wall-clock estimates.
  return estimate(input.startup + input.rows * 2, input.total + input.rows * factor * 2, input.rows, "External Merge Sort")
end function

// Implements project for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function project(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "project", "input must be CostEstimate") end if
  validateRows(outputRows, "project", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Projection")
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.cost"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M17"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
