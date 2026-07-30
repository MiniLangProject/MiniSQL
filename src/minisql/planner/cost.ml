package minisql.planner.cost

// Integer cost model. Costs are abstract work units, deliberately deterministic
// so plans and acceptance tests do not depend on wall-clock timing.

const INVALID_ARGUMENT = 9001

struct CostEstimate
  startup
  total
  rows
  algorithm
end struct

function fail(code, operation, message)
  return error(code, "planner.cost." + operation + ": " + message)
end function

function isCostEstimate(value)
  return value is CostEstimate
end function

function validateRows(value, operation, name)
  if typeof(value) != "int" or value < 0 then return fail(INVALID_ARGUMENT, operation, name + " must be non-negative int") end if
  return true
end function

function estimate(startup, total, rows, algorithm)
  validateRows(startup, "estimate", "startup")
  validateRows(total, "estimate", "total")
  validateRows(rows, "estimate", "rows")
  if total < startup or typeof(algorithm) != "string" then return fail(INVALID_ARGUMENT, "estimate", "invalid cost") end if
  return CostEstimate(startup, total, rows, algorithm)
end function

function sequentialScan(pageCount, rowCount)
  validateRows(pageCount, "sequentialScan", "pageCount")
  validateRows(rowCount, "sequentialScan", "rowCount")
  return estimate(1, 1 + pageCount * 8 + rowCount, rowCount, "Sequential Scan")
end function

function filter(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "filter", "input must be CostEstimate") end if
  validateRows(outputRows, "filter", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Filter")
end function

function nestedLoop(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "nestedLoop", "inputs must be CostEstimate") end if
  validateRows(outputRows, "nestedLoop", "outputRows")
  work = left.total + left.rows * (right.total + 1)
  return estimate(left.startup + right.startup, work, outputRows, "Nested Loop Join")
end function

function hashJoin(left, right, outputRows)
  if left is not CostEstimate or right is not CostEstimate then return fail(INVALID_ARGUMENT, "hashJoin", "inputs must be CostEstimate") end if
  validateRows(outputRows, "hashJoin", "outputRows")
  work = left.total + right.total + (left.rows + right.rows) * 3
  return estimate(left.startup + right.startup + right.rows, work, outputRows, "Hash Join")
end function

function aggregate(input, groupRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "aggregate", "input must be CostEstimate") end if
  validateRows(groupRows, "aggregate", "groupRows")
  return estimate(input.startup, input.total + input.rows * 2, groupRows, "Hash Aggregate")
end function

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

function project(input, outputRows)
  if input is not CostEstimate then return fail(INVALID_ARGUMENT, "project", "input must be CostEstimate") end if
  validateRows(outputRows, "project", "outputRows")
  return estimate(input.startup, input.total + input.rows, outputRows, "Projection")
end function

function componentName()
  return "planner.cost"
end function

function targetMilestone()
  return "M17"
end function

function isImplemented()
  return true
end function
