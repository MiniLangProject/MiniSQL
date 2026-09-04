//! Provides minisql planner physical plan facilities for this project.

package minisql.planner.physical_plan

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.planner.logical_plan as logical_plan

/// Concrete executable-plan description. M16 maps relational operators to safe

const INVALID_ARGUMENT = 9001

/// Groups the physical plan state and preserves the field relationships documented below.
struct PhysicalPlan
  /// Stores the operator associated with this value.
  operator
  /// Stores the details associated with this value.
  details
  /// Stores the estimated rows associated with this value.
  estimatedRows
  /// Stores the estimated cost associated with this value.
  estimatedCost
  /// Stores the children associated with this value.
  children
end struct

/// Performs the fail operation for the minisql planner physical plan module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "planner.physical_plan." + operation + ": " + message)
end function

/// Implements operator for for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param kind kind value consumed by this operation.
function operatorFor(kind)
  if kind == logical_plan.NODE_SCAN then return "Sequential Scan" end if
  if kind == logical_plan.NODE_JOIN then return "Nested Loop Join" end if
  if kind == logical_plan.NODE_AGGREGATE then return "Hash Aggregate" end if
  if kind == logical_plan.NODE_SORT then return "Stable Merge Sort" end if
  if kind == logical_plan.NODE_SET then return "Set Operator" end if
  if kind == logical_plan.NODE_FILTER then return "Filter" end if
  if kind == logical_plan.NODE_PROJECT then return "Projection" end if
  if kind == logical_plan.NODE_DISTINCT then return "Distinct" end if
  if kind == logical_plan.NODE_LIMIT then return "Limit" end if
  return "Values"
end function

/// Implements from logical for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param plan plan value consumed by this operation.
function fromLogical(plan)
  if not logical_plan.isLogicalPlan(plan) then return fail(INVALID_ARGUMENT, "fromLogical", "plan must be LogicalPlan") end if
  children = []
  cost = plan.estimatedRows + 1
  for each child in plan.children
    converted = fromLogical(child)
    children = children + [converted]
    cost = cost + converted.estimatedCost
  end for
  return PhysicalPlan(operatorFor(plan.kind), plan.details, plan.estimatedRows, cost, children)
end function

/// Implements indent for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param depth depth value consumed by this operation.
function indent(depth)
  output = ""
  if depth > 0 then
    for index = 1 to depth
      output = output + "  "
    end for
  end if
  return output
end function

/// Renders into using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param plan plan value consumed by this operation.
/// @param depth depth value consumed by this operation.
/// @param lines lines value consumed by this operation.
function renderInto(plan, depth, lines)
  line = indent(depth) + plan.operator
  if len(plan.details) > 0 then line = line + " [" + plan.details + "]" end if
  line = line + " rows=" + plan.estimatedRows + " cost=" + plan.estimatedCost
  lines = lines + [line]
  for each child in plan.children
    lines = renderInto(child, depth + 1, lines)
  end for
  return lines
end function

/// Renders render using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param plan plan value consumed by this operation.
function render(plan)
  if plan is not PhysicalPlan then return fail(INVALID_ARGUMENT, "render", "plan must be PhysicalPlan") end if
  return renderInto(plan, 0, [])
end function

/// Performs the componentName operation for the minisql planner physical plan module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.physical_plan"
end function

/// Performs the targetMilestone operation for the minisql planner physical plan module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M16"
end function

/// Returns whether implemented satisfies the condition required by the minisql planner physical plan module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
