//! Provides minisql planner cost facilities for this project.

package minisql.planner.cost

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

/// Integer cost model. Costs are abstract work units, deliberately deterministic

const INVALID_ARGUMENT = 9001

/// Groups the cost estimate state and preserves the field relationships documented below.
struct CostEstimate
  /// Stores the startup associated with this value.
  startup
  /// Stores the total associated with this value.
  total
  /// Contains the ordered rows collection.
  rows
  /// Stores the algorithm associated with this value.
  algorithm
end struct

/// Performs the fail operation for the minisql planner cost module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "planner.cost." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the cost estimate condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isCostEstimate(value)
  return value is CostEstimate
end function

/// Validates rows using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
/// @param operation operation value consumed by this operation.
/// @param name Name of the affected item.
function validateRows(value, operation, name)
  if typeof(value) != "int" or value < 0 then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative int") end if
  return true
end function

/// Estimates estimate using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param startup startup value consumed by this operation.
/// @param total total value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param algorithm algorithm value consumed by this operation.
function estimate(startup, total, rows, algorithm)
  validateRows(startup, "estimate", "startup")
  validateRows(total, "estimate", "total")
  validateRows(rows, "estimate", "rows")
  if total < startup or typeof(algorithm) != "string" then return fail(INVALID_ARGUMENT, "estimate", "invalid cost") end if
  return CostEstimate(startup, total, rows, algorithm)
end function

/// Implements sequential scan for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param pageCount Number of page to process.
/// @param rowCount Number of row to process.
function sequentialScan(pageCount, rowCount)
  validateRows(pageCount, "sequentialScan", "pageCount")
  validateRows(rowCount, "sequentialScan", "rowCount")
  return estimate(1, 1 + pageCount * 8 + rowCount, rowCount, "Sequential Scan")
end function

/// Estimates a B+-tree lookup plus the heap fetches expected for qualifying
/// rows. `height` models random index-page reads; `heapRows` distinguishes a
/// covering/unique lookup from a broad range that would be cheaper to scan.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param heapRows heapRows value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
/// @param uniqueLookup uniqueLookup value consumed by this operation.
function indexScan(height, heapRows, outputRows, uniqueLookup)
  validateRows(height, "indexScan", "height")
  validateRows(heapRows, "indexScan", "heapRows")
  validateRows(outputRows, "indexScan", "outputRows")
  if typeof(uniqueLookup) != "bool" then return fail(INVALID_ARGUMENT, "indexScan", "uniqueLookup must be bool") end if
  startup = 1 + height * 12
  // One heap reader is shared by the complete candidate set. Warm index-order
  // fetches therefore cost less than independent random opens while output-row
  // decode remains explicit. Persisted bounds still supply the true range size.
  work = startup + heapRows * 4 + outputRows
  if uniqueLookup and work > startup + 8 then work = startup + 8 end if
  return estimate(startup, work, outputRows, "Index Scan")
end function

/// Estimates an index-only scan whose key contains every column needed by the
/// predicate and projection. No heap page or overflow value is fetched.
/// @param height Height in the coordinate or storage units used by the caller.
/// @param indexRows indexRows value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
/// @param uniqueLookup uniqueLookup value consumed by this operation.
function indexOnlyScan(height, indexRows, outputRows, uniqueLookup)
  validateRows(height, "indexOnlyScan", "height")
  validateRows(indexRows, "indexOnlyScan", "indexRows")
  validateRows(outputRows, "indexOnlyScan", "outputRows")
  if typeof(uniqueLookup) != "bool" then return fail(INVALID_ARGUMENT, "indexOnlyScan", "uniqueLookup must be bool") end if
  startup = 1 + height * 12
  work = startup + indexRows + outputRows
  if uniqueLookup and work > startup + 2 then work = startup + 2 end if
  return estimate(startup, work, outputRows, "Index Only Scan")
end function

/// Implements filter for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param input input value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function filter(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "filter", "input must be CostEstimate") end if
  validateRows(outputRows, "filter", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Filter")
end function

/// Implements nested loop for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function nestedLoop(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "nestedLoop", "inputs must be CostEstimate") end if
  validateRows(outputRows, "nestedLoop", "outputRows")
  work = left.total + left.rows * (right.total + 1)
  return estimate(left.startup + right.startup, work, outputRows, "Nested Loop Join")
end function

/// Implements hash join for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function hashJoin(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "hashJoin", "inputs must be CostEstimate") end if
  validateRows(outputRows, "hashJoin", "outputRows")
  work = left.total + right.total + (left.rows + right.rows) * 3
  return estimate(left.startup + right.startup + right.rows, work, outputRows, "Hash Join")
end function

/// Estimates a parameterized nested loop whose inner side performs one B+-tree
/// lookup per outer row. This is attractive for a small outer input but loses to
/// a hash join once repeated random access dominates.
/// @param left left value consumed by this operation.
/// @param indexHeight indexHeight value consumed by this operation.
/// @param expectedMatchesPerProbe expectedMatchesPerProbe value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function indexNestedLoop(left, indexHeight, expectedMatchesPerProbe, outputRows)
  if left is not CostEstimate then return fail(INVALID_ARGUMENT, "indexNestedLoop", "left must be CostEstimate") end if
  validateRows(indexHeight, "indexNestedLoop", "indexHeight")
  validateRows(expectedMatchesPerProbe, "indexNestedLoop", "expectedMatchesPerProbe")
  validateRows(outputRows, "indexNestedLoop", "outputRows")
  // The executor keeps one index/heap reader open for the complete probe, so
  // each matching heap row has the same warm-fetch weight as a regular
  // non-covering index scan rather than paying a fresh random-open penalty.
  probe = 1 + indexHeight * 12 + expectedMatchesPerProbe * 4
  work = left.total + left.rows * probe + outputRows
  return estimate(left.startup + probe, work, outputRows, "Index Nested Loop Join")
end function

/// Implements aggregate for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param input input value consumed by this operation.
/// @param groupRows groupRows value consumed by this operation.
function aggregate(input, groupRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "aggregate", "input must be CostEstimate") end if
  validateRows(groupRows, "aggregate", "groupRows")
  return estimate(input.startup, input.total + input.rows * 2, groupRows, "Hash Aggregate")
end function

/// Sorts sort using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param input input value consumed by this operation.
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

/// Implements external sort for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param input input value consumed by this operation.
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

/// Estimates a bounded top-N heap/insertion set. The executor uses this only for
/// small LIMIT+OFFSET windows, so work depends on log(window) rather than
/// log(input rows), and retained memory is bounded by the requested window.
/// @param input input value consumed by this operation.
/// @param windowRows windowRows value consumed by this operation.
function topN(input, windowRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "topN", "input must be CostEstimate") end if
  validateRows(windowRows, "topN", "windowRows")
  factor = 1
  remaining = windowRows
  while remaining > 1
    remaining = remaining >> 1
    factor = factor + 1
  end while
  return estimate(input.startup, input.total + input.rows * factor, input.rows, "Top-N")
end function

/// Implements project for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param input input value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function project(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "project", "input must be CostEstimate") end if
  validateRows(outputRows, "project", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Projection")
end function

/// Performs the componentName operation for the minisql planner cost module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.cost"
end function

/// Performs the targetMilestone operation for the minisql planner cost module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M17"
end function

/// Returns whether implemented satisfies the condition required by the minisql planner cost module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
