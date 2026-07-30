package minisql.planner.physical_plan

import minisql.planner.logical_plan as logical_plan

// Concrete executable-plan description. M16 maps relational operators to safe
// baseline algorithms; M17 may substitute cheaper access paths using statistics.

const INVALID_ARGUMENT = 9001

struct PhysicalPlan
  operator
  details
  estimatedRows
  estimatedCost
  children
end struct

function fail(code, operation, message)
  return error(code, "planner.physical_plan." + operation + ": " + message)
end function

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

function indent(depth)
  output = ""
  if depth > 0 then
    for index = 1 to depth
      output = output + "  "
    end for
  end if
  return output
end function

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

function render(plan)
  if plan is not PhysicalPlan then return fail(INVALID_ARGUMENT, "render", "plan must be PhysicalPlan") end if
  return renderInto(plan, 0, [])
end function

function componentName()
  return "planner.physical_plan"
end function

function targetMilestone()
  return "M16"
end function

function isImplemented()
  return true
end function
