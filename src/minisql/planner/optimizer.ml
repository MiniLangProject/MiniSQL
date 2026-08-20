package minisql.planner.optimizer

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

import minisql.catalog.statistics as statistics
import minisql.planner.cost as cost
import minisql.planner.physical_plan as physical_plan
import minisql.planner.rewrites as rewrites
import minisql.sql.ast as ast
import minisql.sql.binder as binder

// Costed physical-plan builder. The executor currently uses the safe baseline
// algorithms directly. M46 selects the integrated hash join/hash aggregation paths
// and exposes external merge sorting once the estimated row count exceeds the
// executor spill threshold.

const INVALID_ARGUMENT = 9001

// Groups the optimized plan state and preserves the field relationships documented below.
struct OptimizedPlan
  // Stores the root associated with this value.
  root
  // Stores the used statistics associated with this value.
  usedStatistics
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "planner.optimizer." + operation + ": " + message)
end function

// Implements integer divide for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function integerDivide(numerator, denominator)
  if typeof(numerator) != "int" or typeof(denominator) != "int" or numerator < 0 or denominator <= 0 then return fail(INVALID_ARGUMENT, "integerDivide", "invalid arguments") end if
  quotient = 0
  remainder = numerator
  scale = denominator
  bit = 1
  while scale <= remainder and scale <= (endian.MAX_MINILANG_INT >> 1)
    scale = scale << 1
    bit = bit << 1
  end while
  while bit > 0
    if scale <= remainder then remainder = remainder - scale; quotient = quotient + bit end if
    scale = scale >> 1
    bit = bit >> 1
  end while
  return quotient
end function

// Returns whether the supplied value satisfies the optimized plan condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isOptimizedPlan(value)
  return value is OptimizedPlan
end function

// Implements table stats for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function tableStats(state, tableId)
  if state is void then return void end if
  if not statistics.isStatisticsCatalog(state) then return fail(INVALID_ARGUMENT, "tableStats", "statistics must be catalog or void") end if
  return statistics.findTable(state, tableId)
end function

// Scans plan using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function scanPlan(source, state)
  found = tableStats(state, source.table.tableId)
  rows = 1000
  pages = 100
  detail = source.table.name + " (default estimates)"
  used = false
  if found is not void then
    rows = found.rowCount
    pages = found.pageCount
    detail = source.table.name + " pages=" + pages
    used = true
  end if
  estimate = cost.sequentialScan(pages, rows)
  return [physical_plan.PhysicalPlan(estimate.algorithm, detail, estimate.rows, estimate.total, []), estimate, used]
end function

// Implements join rows for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinRows(leftRows, rightRows, joinType, condition)
  if joinType == ast.JOIN_CROSS then return leftRows * rightRows end if
  estimate = integerDivide(leftRows * rightRows, 10)
  if estimate == 0 and leftRows > 0 and rightRows > 0 then estimate = 1 end if
  if (joinType == ast.JOIN_LEFT or joinType == ast.JOIN_FULL) and estimate < leftRows then estimate = leftRows end if
  if (joinType == ast.JOIN_RIGHT or joinType == ast.JOIN_FULL) and estimate < rightRows then estimate = rightRows end if
  return estimate
end function

// Implements join operator for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinOperator(joinType)
  if joinType == ast.JOIN_LEFT then return "Left Outer Join" end if
  if joinType == ast.JOIN_RIGHT then return "Right Outer Join" end if
  if joinType == ast.JOIN_FULL then return "Full Outer Join" end if
  if joinType == ast.JOIN_CROSS then return "Cross Join" end if
  return "Inner Join"
end function

// Builds the scan/join spine and its cumulative deterministic cost estimate.
// Equality INNER/LEFT joins compare hash and nested-loop costs; unsupported join
// shapes retain the semantic nested-loop fallback. Returns plan, cost, and stats-use flag.
function buildBase(bound, state)
  if len(bound.sources) == 0 then
    estimate = cost.estimate(0, 1, 1, "Values")
    return [physical_plan.PhysicalPlan("Values", "one row", 1, 1, []), estimate, false]
  end if
  first = scanPlan(bound.sources[0], state)
  root = first[0]
  currentCost = first[1]
  used = first[2]
  for each joined in bound.joins
    right = scanPlan(joined.source, state)
    outputRows = joinRows(currentCost.rows, right[1].rows, joined.joinType, joined.condition)
    nested = cost.nestedLoop(currentCost, right[1], outputRows)
    selected = nested
    operatorName = joinOperator(joined.joinType)
    detail = joined.source.table.name
    hashSupported = rewrites.isColumnEquality(joined.condition) and (joined.joinType == ast.JOIN_INNER or joined.joinType == ast.JOIN_LEFT)
    if hashSupported then
      hashed = cost.hashJoin(currentCost, right[1], outputRows)
      if hashed.total <= nested.total then
        selected = hashed
        operatorName = "Hash Join"
        detail = detail + " type=" + joinOperator(joined.joinType) + "; build=right"
      else
        detail = detail + " equality; hash-cost=" + hashed.total
      end if
    end if
    root = physical_plan.PhysicalPlan(operatorName, detail, outputRows, selected.total, [root, right[0]])
    currentCost = selected
    used = used or right[2]
  end for
  return [root, currentCost, used]
end function

// Lowers a bound SELECT into a costed physical operator tree.
// Operators are added in relational order; analyzed statistics replace defaults,
// large sorts select external merge sort, and set-operation branches recurse.
// Returns OptimizedPlan or a structured validation/dependency error.
function optimize(bound, state)
  if not binder.isBoundSelect(bound) then return fail(INVALID_ARGUMENT, "optimize", "bound must be BoundSelect") end if
  built = buildBase(bound, state)
  root = built[0]
  currentCost = built[1]
  used = built[2]
  if bound.whereExpression is not void then
    rows = rewrites.estimateFilteredRows(currentCost.rows, bound.whereExpression)
    currentCost = cost.filter(currentCost, rows)
    root = physical_plan.PhysicalPlan("Filter", "selectivity=" + rewrites.selectivityPermille(bound.whereExpression) + "/1000", rows, currentCost.total, [root])
  end if
  if bound.aggregateQuery then
    groups = currentCost.rows
    if len(bound.groupExpressions) == 0 then groups = 1 else if groups > 100 then groups = 100 end if
    currentCost = cost.aggregate(currentCost, groups)
    root = physical_plan.PhysicalPlan(currentCost.algorithm, "groups=" + len(bound.groupExpressions), groups, currentCost.total, [root])
  end if
  currentCost = cost.project(currentCost, currentCost.rows)
  root = physical_plan.PhysicalPlan("Projection", "columns=" + len(bound.items), currentCost.rows, currentCost.total, [root])
  if bound.statement.distinct then
    currentCost = cost.aggregate(currentCost, currentCost.rows)
    root = physical_plan.PhysicalPlan("Distinct", "", currentCost.rows, currentCost.total, [root])
  end if
  for each operation in bound.setOperations
    rightPlan = optimize(operation.query, state)
    rows = currentCost.rows + rightPlan.root.estimatedRows
    if not operation.all then rows = integerDivide(rows, 2) end if
    name = "Union"
    if operation.operator == ast.SET_INTERSECT then name = "Intersect" end if
    if operation.operator == ast.SET_EXCEPT then name = "Except" end if
    if operation.all then name = name + " All" end if
    total = currentCost.total + rightPlan.root.estimatedCost + rows
    root = physical_plan.PhysicalPlan(name, "", rows, total, [root, rightPlan.root])
    currentCost = cost.estimate(currentCost.startup, total, rows, name)
    used = used or rightPlan.usedStatistics
  end for
  if len(bound.statement.orderBy) > 0 then
    if currentCost.rows > 128 then
      currentCost = cost.externalSort(currentCost)
    else
      currentCost = cost.sort(currentCost)
    end if
    root = physical_plan.PhysicalPlan(currentCost.algorithm, "keys=" + len(bound.statement.orderBy), currentCost.rows, currentCost.total, [root])
  end if
  if bound.statement.limit >= 0 or bound.statement.offset > 0 then
    rows = currentCost.rows
    if bound.statement.offset >= rows then rows = 0 else rows = rows - bound.statement.offset end if
    if bound.statement.limit >= 0 and bound.statement.limit < rows then rows = bound.statement.limit end if
    root = physical_plan.PhysicalPlan("Limit", "offset=" + bound.statement.offset + ", limit=" + bound.statement.limit, rows, currentCost.total, [root])
  end if
  return OptimizedPlan(root, used)
end function

// Implements explain for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function explain(bound, state)
  optimized = optimize(bound, state)
  lines = physical_plan.render(optimized.root)
  prefix = "statistics=defaults"
  if optimized.usedStatistics then prefix = "statistics=analyzed" end if
  return [prefix] + lines
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.optimizer"
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
