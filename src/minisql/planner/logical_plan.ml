package minisql.planner.logical_plan

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.ast as ast
import minisql.sql.binder as binder

// Relational-algebra tree. Logical nodes contain semantics only; access paths
// and concrete algorithms are chosen by physical_plan/optimizer.

const INVALID_ARGUMENT = 9001

const NODE_VALUES = 1
const NODE_SCAN = 2
const NODE_JOIN = 3
const NODE_FILTER = 4
const NODE_AGGREGATE = 5
const NODE_PROJECT = 6
const NODE_DISTINCT = 7
const NODE_SET = 8
const NODE_SORT = 9
const NODE_LIMIT = 10

// Groups the logical plan state and preserves the field relationships documented below.
struct LogicalPlan
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Stores the details associated with this value.
  details
  // Stores the estimated rows associated with this value.
  estimatedRows
  // Stores the children associated with this value.
  children
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "planner.logical_plan." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the logical plan condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isLogicalPlan(value)
  return value is LogicalPlan
end function

// Implements node for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function node(kind, name, details, estimatedRows, children)
  if typeof(kind) != "int" or typeof(name) != "string" or typeof(details) != "string" or typeof(estimatedRows) != "int" or estimatedRows < 0 or typeof(children) != "array" then return fail(INVALID_ARGUMENT, "node", "invalid node") end if
  return LogicalPlan(kind, name, details, estimatedRows, children)
end function

// Implements join name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function joinName(joinType)
  if joinType == ast.JOIN_LEFT then return "Left Join" end if
  if joinType == ast.JOIN_RIGHT then return "Right Join" end if
  if joinType == ast.JOIN_FULL then return "Full Outer Join" end if
  if joinType == ast.JOIN_CROSS then return "Cross Join" end if
  return "Inner Join"
end function

// Implements set name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function setName(operator, all)
  suffix = ""
  if all then suffix = " All" end if
  if operator == ast.SET_INTERSECT then return "Intersect" + suffix end if
  if operator == ast.SET_EXCEPT then return "Except" + suffix end if
  return "Union" + suffix
end function

// Builds build using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function build(bound)
  if not binder.isBoundSelect(bound) then return fail(INVALID_ARGUMENT, "build", "query must be BoundSelect") end if
  current = node(NODE_VALUES, "Values", "one row", 1, [])
  if len(bound.sources) > 0 then
    first = bound.sources[0]
    current = node(NODE_SCAN, "Table Scan", first.table.name, 1000, [])
    for each joined in bound.joins
      right = node(NODE_SCAN, "Table Scan", joined.source.table.name, 1000, [])
      current = node(NODE_JOIN, joinName(joined.joinType), joined.source.table.name, 1000, [current, right])
    end for
  end if
  if bound.whereExpression is not void then current = node(NODE_FILTER, "Filter", "WHERE", 500, [current]) end if
  if bound.aggregateQuery then current = node(NODE_AGGREGATE, "Aggregate", "groups=" + len(bound.groupExpressions), 100, [current]) end if
  current = node(NODE_PROJECT, "Project", "columns=" + len(bound.items), current.estimatedRows, [current])
  if bound.statement.distinct then current = node(NODE_DISTINCT, "Distinct", "", current.estimatedRows, [current]) end if
  for each operation in bound.setOperations
    rightPlan = build(operation.query)
    current = node(NODE_SET, setName(operation.operator, operation.all), "", current.estimatedRows + rightPlan.estimatedRows, [current, rightPlan])
  end for
  if len(bound.statement.orderBy) > 0 then current = node(NODE_SORT, "Sort", "keys=" + len(bound.statement.orderBy), current.estimatedRows, [current]) end if
  if bound.statement.limit >= 0 or bound.statement.offset > 0 then
    estimate = current.estimatedRows
    if bound.statement.limit >= 0 and bound.statement.limit < estimate then estimate = bound.statement.limit end if
    current = node(NODE_LIMIT, "Limit", "offset=" + bound.statement.offset + ", limit=" + bound.statement.limit, estimate, [current])
  end if
  return current
end function

// Implements indent for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function indent(depth)
  output = ""
  if depth > 0 then
    for index = 1 to depth
      output = output + "  "
    end for
  end if
  return output
end function

// Renders into using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function renderInto(plan, depth, lines)
  line = indent(depth) + plan.name
  if len(plan.details) > 0 then line = line + " [" + plan.details + "]" end if
  line = line + " rows=" + plan.estimatedRows
  lines = lines + [line]
  for each child in plan.children
    lines = renderInto(child, depth + 1, lines)
  end for
  return lines
end function

// Renders render using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function render(plan)
  if plan is not LogicalPlan then return fail(INVALID_ARGUMENT, "render", "plan must be LogicalPlan") end if
  return renderInto(plan, 0, [])
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.logical_plan"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M16"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
