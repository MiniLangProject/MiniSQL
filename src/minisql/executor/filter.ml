package minisql.executor.filter

import minisql.executor.scan as scan
import minisql.sql.expressions as expressions

const INVALID_ARGUMENT = 9001

function fail(code, operation, message)
  return error(code, "executor.filter." + operation + ": " + message)
end function

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

function componentName()
  return "executor.filter"
end function

function targetMilestone()
  return "M15"
end function

function isImplemented()
  return true
end function
