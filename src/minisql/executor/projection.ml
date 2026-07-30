package minisql.executor.projection

import minisql.common.endian as endian
import minisql.executor.scan as scan
import minisql.sql.expressions as expressions
import minisql.sql.types as types
import minisql.sql.values as values

const INVALID_ARGUMENT = 9001

struct ProjectedRow
  source
  values
  orderValues
end struct

function fail(code, operation, message)
  return error(code, "executor.projection." + operation + ": " + message)
end function

function isProjectedRow(value)
  return value is ProjectedRow
end function

function evaluateList(boundExpressions, context, operation)
  if typeof(boundExpressions) != "array" then return fail(INVALID_ARGUMENT, operation, "expressions must be array") end if
  output = []
  for each expression in boundExpressions
    output = output + [expressions.evaluate(expression, context)]
  end for
  return output
end function

function apply(rows, selectExpressions, orderExpressions)
  if typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "apply", "rows must be array") end if
  output = []
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "apply", "rows contain non-ScannedRow") end if
    context = expressions.rowContext(row.values)
    output = output + [ProjectedRow(row, evaluateList(selectExpressions, context, "apply.select"), evaluateList(orderExpressions, context, "apply.order"))]
  end for
  return output
end function

function sameValues(left, right)
  if len(left) != len(right) then return false end if
  if len(left) == 0 then return true end if
  for index = 0 to len(left) - 1
    if not sameValue(left[index], right[index]) then return false end if
  end for
  return true
end function

function windowPartitionKey(expression, row)
  context = expressions.rowContext(row.values)
  output = []
  for each item in expression.partitionBy
    output = output + [expressions.evaluate(item, context)]
  end for
  return output
end function

function windowOrderValues(expression, row)
  context = expressions.rowContext(row.values)
  output = []
  for each item in expression.orderBy
    output = output + [expressions.evaluate(item, context)]
  end for
  return output
end function

function compareWindowRows(left, right, expression)
  leftValues = windowOrderValues(expression, left)
  rightValues = windowOrderValues(expression, right)
  if len(leftValues) > 0 then
    for index = 0 to len(leftValues) - 1
      result = compareNullable(leftValues[index], rightValues[index], expression.descending[index], expression.nullsFirst[index], expression.nullsSpecified[index])
      if result != 0 then return result end if
    end for
  end if
  return 0
end function

function mergeWindow(left, right, expression)
  output = []
  leftIndex = 0
  rightIndex = 0
  while leftIndex < len(left) and rightIndex < len(right)
    if compareWindowRows(left[leftIndex], right[rightIndex], expression) <= 0 then
      output = output + [left[leftIndex]]
      leftIndex = leftIndex + 1
    else
      output = output + [right[rightIndex]]
      rightIndex = rightIndex + 1
    end if
  end while
  while leftIndex < len(left)
    output = output + [left[leftIndex]]
    leftIndex = leftIndex + 1
  end while
  while rightIndex < len(right)
    output = output + [right[rightIndex]]
    rightIndex = rightIndex + 1
  end while
  return output
end function

function sortWindowRows(rows, expression)
  if len(rows) <= 1 or len(expression.orderBy) == 0 then return rows end if
  middle = len(rows) >> 1
  left = []
  right = []
  for index = 0 to len(rows) - 1
    if index < middle then left = left + [rows[index]] else right = right + [rows[index]] end if
  end for
  return mergeWindow(sortWindowRows(left, expression), sortWindowRows(right, expression), expression)
end function

function windowAggregate(expression, partitionRows)
  name = expression.name
  candidates = []
  if name == "COUNT" and len(expression.arguments) == 0 then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(len(partitionRows))) end if
  for each row in partitionRows
    value = expressions.evaluate(expression.arguments[0], expressions.rowContext(row.values))
    if not value.isNull then candidates = candidates + [value] end if
  end for
  if name == "COUNT" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(len(candidates))) end if
  if len(candidates) == 0 then return values.nullValue(expression.typeInfo.kind) end if
  if name == "MIN" or name == "MAX" then
    selected = candidates[0]
    if len(candidates) > 1 then
      for index = 1 to len(candidates) - 1
        compared = values.compareNonNull(candidates[index], selected)
        if (name == "MIN" and compared < 0) or (name == "MAX" and compared > 0) then selected = candidates[index] end if
      end for
    end if
    return selected
  end if
  total = 0
  for each candidate in candidates
    total = total + values.asNumber(candidate)
  end for
  if name == "AVG" then return values.doubleValue((total + 0.0) / len(candidates)) end if
  if name == "SUM" then
    source = values.integer(total)
    if typeof(total) == "float" then source = values.doubleValue(total) end if
    return values.convert(source, expression.typeInfo)
  end if
  return fail(INVALID_ARGUMENT, "windowAggregate", "unsupported window aggregate " + name)
end function

function windowValue(expression, allRows, currentRow)
  partitionRows = []
  key = windowPartitionKey(expression, currentRow)
  for each candidate in allRows
    if sameValues(key, windowPartitionKey(expression, candidate)) then partitionRows = partitionRows + [candidate] end if
  end for
  if expression.name == "COUNT" or expression.name == "SUM" or expression.name == "AVG" or expression.name == "MIN" or expression.name == "MAX" then return windowAggregate(expression, partitionRows) end if
  ordered = sortWindowRows(partitionRows, expression)
  position = -1
  for index = 0 to len(ordered) - 1
    if ordered[index] == currentRow then position = index end if
  end for
  if position < 0 then return fail(INVALID_ARGUMENT, "windowValue", "current row is absent from its partition") end if
  if expression.name == "ROW_NUMBER" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(position + 1)) end if
  rank = 1
  dense = 1
  if position > 0 then
    for index = 1 to position
      changed = compareWindowRows(ordered[index - 1], ordered[index], expression) != 0
      if changed then
        dense = dense + 1
        rank = index + 1
      end if
    end for
  end if
  if expression.name == "RANK" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(rank)) end if
  if expression.name == "DENSE_RANK" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(dense)) end if
  return fail(INVALID_ARGUMENT, "windowValue", "unknown window function " + expression.name)
end function

function evaluateWindowList(boundExpressions, allRows, row)
  output = []
  context = expressions.rowContext(row.values)
  for each expression in boundExpressions
    if expressions.isBoundWindow(expression) then output = output + [windowValue(expression, allRows, row)] else output = output + [expressions.evaluate(expression, context)] end if
  end for
  return output
end function

function applyWindows(rows, selectExpressions, orderExpressions)
  if typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "applyWindows", "rows must be array") end if
  output = []
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "applyWindows", "rows contain non-ScannedRow") end if
    output = output + [ProjectedRow(row, evaluateWindowList(selectExpressions, rows, row), evaluateWindowList(orderExpressions, rows, row))]
  end for
  return output
end function

function sameValue(left, right)
  if not values.isSqlValue(left) or not values.isSqlValue(right) then return fail(INVALID_ARGUMENT, "sameValue", "values must be SqlValue") end if
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

function sameRow(left, right)
  if left is not ProjectedRow or right is not ProjectedRow or len(left.values) != len(right.values) then return false end if
  if len(left.values) == 0 then return true end if
  for index = 0 to len(left.values) - 1
    if not sameValue(left.values[index], right.values[index]) then return false end if
  end for
  return true
end function

function distinct(rows)
  if typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "distinct", "rows must be array") end if
  output = []
  for each candidate in rows
    if candidate is not ProjectedRow then return fail(INVALID_ARGUMENT, "distinct", "rows contain non-ProjectedRow") end if
    duplicate = false
    for each existing in output
      if sameRow(existing, candidate) then duplicate = true; break end if
    end for
    if not duplicate then output = output + [candidate] end if
  end for
  return output
end function

function compareNullable(left, right, descending, nullsFirst, nullsSpecified)
  if not values.isSqlValue(left) or not values.isSqlValue(right) then return fail(INVALID_ARGUMENT, "compareNullable", "values must be SqlValue") end if
  if left.isNull or right.isNull then
    if left.isNull and right.isNull then return 0 end if
    first = nullsFirst
    if not nullsSpecified then first = descending end if
    result = 1
    if left.isNull then result = -1 end if
    if not first then result = 0 - result end if
    return result
  end if
  result = values.compareNonNull(left, right)
  if descending then result = 0 - result end if
  return result
end function

function compareRows(left, right, orderItems)
  if left is not ProjectedRow or right is not ProjectedRow then return fail(INVALID_ARGUMENT, "compareRows", "rows must be ProjectedRow") end if
  if len(left.orderValues) != len(orderItems) or len(right.orderValues) != len(orderItems) then return fail(INVALID_ARGUMENT, "compareRows", "order value count mismatch") end if
  if len(orderItems) > 0 then
    for index = 0 to len(orderItems) - 1
      item = orderItems[index]
      result = compareNullable(left.orderValues[index], right.orderValues[index], item.descending, item.nullsFirst, item.nullsSpecified)
      if result != 0 then return result end if
    end for
  end if
  return 0
end function

function merge(left, right, orderItems)
  output = []
  leftIndex = 0
  rightIndex = 0
  while leftIndex < len(left) and rightIndex < len(right)
    if compareRows(left[leftIndex], right[rightIndex], orderItems) <= 0 then
      output = output + [left[leftIndex]]
      leftIndex = leftIndex + 1
    else
      output = output + [right[rightIndex]]
      rightIndex = rightIndex + 1
    end if
  end while
  while leftIndex < len(left)
    output = output + [left[leftIndex]]
    leftIndex = leftIndex + 1
  end while
  while rightIndex < len(right)
    output = output + [right[rightIndex]]
    rightIndex = rightIndex + 1
  end while
  return output
end function

function sort(rows, orderItems)
  if typeof(rows) != "array" or typeof(orderItems) != "array" then return fail(INVALID_ARGUMENT, "sort", "rows/orderItems must be arrays") end if
  if len(rows) <= 1 or len(orderItems) == 0 then return rows end if
  middle = len(rows) >> 1
  left = []
  right = []
  for index = 0 to len(rows) - 1
    if index < middle then left = left + [rows[index]] else right = right + [rows[index]] end if
  end for
  return merge(sort(left, orderItems), sort(right, orderItems), orderItems)
end function

function sliceRows(rows, offset, limit)
  if typeof(rows) != "array" or typeof(offset) != "int" or offset < 0 or typeof(limit) != "int" or limit < -1 then return fail(INVALID_ARGUMENT, "sliceRows", "invalid slice") end if
  output = []
  if offset >= len(rows) then return output end if
  ending = len(rows)
  if limit >= 0 and offset + limit < ending then ending = offset + limit end if
  if ending <= offset then return output end if
  for index = offset to ending - 1
    output = output + [rows[index]]
  end for
  return output
end function

function componentName()
  return "executor.projection"
end function

function targetMilestone()
  return "M15"
end function

function isImplemented()
  return true
end function
