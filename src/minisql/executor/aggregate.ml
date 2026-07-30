package minisql.executor.aggregate

import minisql.common.endian as endian
import minisql.executor.projection as projection
import minisql.executor.scan as scan
import minisql.sql.ast as ast
import minisql.sql.expressions as expressions
import minisql.sql.types as types
import minisql.sql.values as values

// Grouping, SQL aggregates and set operations. The first implementation uses
// deterministic linear group lookup. M17 statistics and planning can replace the
// grouping container with a hash table while preserving this operator contract.

const INVALID_ARGUMENT = 9001
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020
const HASH_BUCKET_COUNT = 257
const HASH_MASK = 2147483647

struct AggregateGroup
  keyValues
  rows
end struct

struct HashGroupEntry
  keyValues
  groupIndex
end struct

function fail(code, operation, message)
  return error(code, "executor.aggregate." + operation + ": " + message)
end function

function hashBytes(input, seed)
  result = seed & HASH_MASK
  if len(input) > 0 then
    for index = 0 to len(input) - 1
      result = ((result ^ input[index]) * 16777619) & HASH_MASK
    end for
  end if
  return result
end function

function hashValue(value)
  if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "hashValue", "value must be SqlValue") end if
  if value.isNull then return 0 end if
  result = (2166136261 ^ value.typeKind) & HASH_MASK
  if typeof(value.value) == "string" then return hashBytes(bytes(value.value), result) end if
  if typeof(value.value) == "bytes" then return hashBytes(value.value, result) end if
  if typeof(value.value) == "bool" then
    if value.value then return ((result ^ 1) * 16777619) & HASH_MASK end if
    return ((result ^ 0) * 16777619) & HASH_MASK
  end if
  // SQL numeric equality treats -0.0 and 0.0 as equal, so they must hash to
  // the same bucket before the full equality check below.
  if typeof(value.value) == "float" and value.value == 0.0 then return hashBytes(bytes("0.0"), result) end if
  if typeof(value.value) == "int" then
    result = ((result ^ (value.value & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 16) & 255)) * 16777619) & HASH_MASK
    return ((result ^ ((value.value >> 24) & 255)) * 16777619) & HASH_MASK
  end if
  if endian.isInt64Words(value.value) then
    result = ((result ^ (value.value.low & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 24) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ (value.value.high & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 16) & 255)) * 16777619) & HASH_MASK
    return ((result ^ ((value.value.high >> 24) & 255)) * 16777619) & HASH_MASK
  end if
  return hashBytes(bytes("" + value.value), result)
end function

function hashValues(input)
  result = 2166136261 & HASH_MASK
  for each value in input
    result = ((result ^ hashValue(value)) * 16777619) & HASH_MASK
  end for
  return result
end function

function sameValue(left, right)
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

function sameValues(left, right)
  if len(left) != len(right) then return false end if
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      if not sameValue(left[index], right[index]) then return false end if
    end for
  end if
  return true
end function

function distinctValues(input)
  output = []
  for each candidate in input
    duplicate = false
    for each existing in output
      if sameValue(candidate, existing) then duplicate = true; break end if
    end for
    if not duplicate then output = output + [candidate] end if
  end for
  return output
end function

function evaluateArgument(expression, row)
  return expressions.evaluate(expression, expressions.rowContext(row.values))
end function

function aggregateValue(expression, rows)
  if not expressions.isBoundAggregate(expression) then return fail(INVALID_ARGUMENT, "aggregateValue", "expression must be aggregate") end if
  candidates = []
  if expression.countStar then
    return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(len(rows)))
  end if
  for each row in rows
    value = evaluateArgument(expression.argument, row)
    if not value.isNull then candidates = candidates + [value] end if
  end for
  if expression.distinct then candidates = distinctValues(candidates) end if
  if expression.name == "COUNT" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(len(candidates))) end if
  if len(candidates) == 0 then return values.nullValue(expression.typeInfo.kind) end if
  if expression.name == "MIN" or expression.name == "MAX" then
    selected = candidates[0]
    if len(candidates) > 1 then
      for index = 1 to len(candidates) - 1
        comparison = values.compareNonNull(candidates[index], selected)
        if (expression.name == "MIN" and comparison < 0) or (expression.name == "MAX" and comparison > 0) then selected = candidates[index] end if
      end for
    end if
    return selected
  end if
  total = 0
  for each candidate in candidates
    total = total + values.asNumber(candidate)
  end for
  if expression.name == "AVG" then return values.doubleValue((total + 0.0) / len(candidates)) end if
  if expression.name == "SUM" then
    source = void
    if typeof(total) == "float" then source = values.doubleValue(total) else source = values.integer(total) end if
    return values.convert(source, expression.typeInfo)
  end if
  return fail(BINDING_ERROR, "aggregateValue", "unknown aggregate " + expression.name)
end function

function evaluateGroup(expression, rows, representative)
  if expressions.isBoundAggregate(expression) then return aggregateValue(expression, rows) end if
  if not expressions.containsAggregate(expression) then return expressions.evaluate(expression, representative) end if
  if expressions.isBoundCase(expression) then
    for each branch in expression.branches
      condition = evaluateGroup(branch.condition, rows, representative)
      if values.truth(condition) == 1 then return values.convert(evaluateGroup(branch.result, rows, representative), expression.typeInfo) end if
    end for
    if expression.elseExpression is void then return values.nullValue(expression.typeInfo.kind) end if
    return values.convert(evaluateGroup(expression.elseExpression, rows, representative), expression.typeInfo)
  end if
  if expressions.isBoundCast(expression) then return values.cast(evaluateGroup(expression.operand, rows, representative), expression.targetType) end if
  if expressions.isBoundScalar(expression) then
    if expression.name == "COALESCE" then
      for each argument in expression.arguments
        value = evaluateGroup(argument, rows, representative)
        if not value.isNull then return values.convert(value, expression.typeInfo) end if
      end for
      return values.nullValue(expression.typeInfo.kind)
    end if
    if expression.name == "NULLIF" then
      left = evaluateGroup(expression.arguments[0], rows, representative)
      if left.isNull then return values.nullValue(expression.typeInfo.kind) end if
      right = evaluateGroup(expression.arguments[1], rows, representative)
      if not right.isNull and values.compareNonNull(left, right) == 0 then return values.nullValue(expression.typeInfo.kind) end if
      return values.convert(left, expression.typeInfo)
    end if
  end if
  if expressions.isBoundIn(expression) then
    operand = evaluateGroup(expression.operand, rows, representative)
    if operand.isNull then return values.nullValue(types.SqlTypeKind.Boolean) end if
    sawNull = false
    for each candidateExpression in expression.candidates
      candidate = evaluateGroup(candidateExpression, rows, representative)
      if candidate.isNull then
        sawNull = true
      else if values.compareNonNull(operand, candidate) == 0 then
        result = values.boolean(true)
        if expression.negated then result = values.logicalNot(result) end if
        return result
      end if
    end for
    result = values.boolean(false)
    if sawNull then result = values.nullValue(types.SqlTypeKind.Boolean) end if
    if expression.negated then result = values.logicalNot(result) end if
    return result
  end if
  if expressions.isBoundBetween(expression) then
    operand = evaluateGroup(expression.operand, rows, representative)
    lower = evaluateGroup(expression.lower, rows, representative)
    upper = evaluateGroup(expression.upper, rows, representative)
    result = values.logicalAnd(expressions.comparisonResult(operand, lower, ">="), expressions.comparisonResult(operand, upper, "<="))
    if expression.negated then result = values.logicalNot(result) end if
    return result
  end if
  if expressions.isBoundTruthTest(expression) then
    truthValue = values.truth(evaluateGroup(expression.operand, rows, representative))
    result = false
    if expression.expected == "TRUE" then result = truthValue == 1 end if
    if expression.expected == "FALSE" then result = truthValue == 0 end if
    if expression.expected == "UNKNOWN" then result = truthValue < 0 end if
    if expression.negated then result = not result end if
    return values.boolean(result)
  end if
  if not expressions.isBaseBoundExpression(expression) then return fail(BINDING_ERROR, "evaluateGroup", "unsupported grouped expression") end if
  if expression.kind == expressions.BOUND_LITERAL or expression.kind == expressions.BOUND_COLUMN then return expressions.evaluate(expression, representative) end if
  if expression.kind == expressions.BOUND_IS_NULL then
    operand = evaluateGroup(expression.left, rows, representative)
    result = operand.isNull
    if expression.operator == "IS NOT NULL" then result = not result end if
    return values.boolean(result)
  end if
  if expression.kind == expressions.BOUND_UNARY then
    operand = evaluateGroup(expression.left, rows, representative)
    if expression.operator == "NOT" then return values.logicalNot(operand) end if
    if operand.isNull then return values.nullValue(expression.typeInfo.kind) end if
    number = values.asNumber(operand)
    if expression.operator == "+" then return values.convert(values.of(operand.typeKind, number), expression.typeInfo) end if
    if expression.operator == "-" then return values.convert(values.of(operand.typeKind, 0 - number), expression.typeInfo) end if
    return fail(BINDING_ERROR, "evaluateGroup", "unknown unary operator")
  end if
  if expression.kind == expressions.BOUND_BINARY then
    left = evaluateGroup(expression.left, rows, representative)
    if expression.operator == "AND" then
      if values.truth(left) == 0 then return values.boolean(false) end if
      return values.logicalAnd(left, evaluateGroup(expression.right, rows, representative))
    end if
    if expression.operator == "OR" then
      if values.truth(left) == 1 then return values.boolean(true) end if
      return values.logicalOr(left, evaluateGroup(expression.right, rows, representative))
    end if
    right = evaluateGroup(expression.right, rows, representative)
    if expression.operator == "+" or expression.operator == "-" or expression.operator == "*" or expression.operator == "/" or expression.operator == "%" then return expressions.numericResult(left, right, expression.operator, expression.typeInfo) end if
    if expression.operator == "=" or expression.operator == "<>" or expression.operator == "!=" or expression.operator == "<" or expression.operator == "<=" or expression.operator == ">" or expression.operator == ">=" then return expressions.comparisonResult(left, right, expression.operator) end if
    if expression.operator == "LIKE" or expression.operator == "NOT LIKE" then
      result = expressions.likeResult(left, right)
      if expression.operator == "NOT LIKE" then result = values.logicalNot(result) end if
      return result
    end if
    if expression.operator == "||" then
      if left.isNull or right.isNull then return values.nullValue(expression.typeInfo.kind) end if
      return values.of(expression.typeInfo.kind, left.value + right.value)
    end if
  end if
  return fail(BINDING_ERROR, "evaluateGroup", "unsupported grouped expression")
end function

function evaluateList(boundExpressions, rows, representative)
  output = []
  for each expression in boundExpressions
    output = output + [evaluateGroup(expression, rows, representative)]
  end for
  return output
end function

function groupRows(rows, groupExpressions, aggregateQuery)
  if not aggregateQuery then return fail(INVALID_ARGUMENT, "groupRows", "query is not aggregate") end if
  groups = []
  buckets = array(HASH_BUCKET_COUNT, void)
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "groupRows", "rows contain non-ScannedRow") end if
    context = expressions.rowContext(row.values)
    key = []
    for each expression in groupExpressions
      key = key + [expressions.evaluate(expression, context)]
    end for
    bucketIndex = hashValues(key) % HASH_BUCKET_COUNT
    bucket = buckets[bucketIndex]
    if bucket is void then bucket = [] end if
    groupIndex = -1
    for each entry in bucket
      if sameValues(entry.keyValues, key) then groupIndex = entry.groupIndex; break end if
    end for
    if groupIndex < 0 then
      groupIndex = len(groups)
      groups = groups + [AggregateGroup(key, [row])]
      bucket = bucket + [HashGroupEntry(key, groupIndex)]
      buckets[bucketIndex] = bucket
    else
      groups[groupIndex].rows = groups[groupIndex].rows + [row]
    end if
  end for
  if len(groupExpressions) == 0 and len(groups) == 0 then groups = [AggregateGroup([], [])] end if
  return groups
end function

function project(rows, selectExpressions, groupExpressions, havingExpression, orderExpressions)
  if typeof(rows) != "array" then return fail(INVALID_ARGUMENT, "project", "rows must be array") end if
  groups = groupRows(rows, groupExpressions, true)
  output = []
  for each group in groups
    representative = expressions.rowContext([])
    source = void
    if len(group.rows) > 0 then
      source = group.rows[0]
      representative = expressions.rowContext(source.values)
    end if
    include = true
    if havingExpression is not void then include = values.truth(evaluateGroup(havingExpression, group.rows, representative)) == 1 end if
    if include then
      output = output + [projection.ProjectedRow(source, evaluateList(selectExpressions, group.rows, representative), evaluateList(orderExpressions, group.rows, representative))]
    end if
  end for
  return output
end function

function findMatching(rows, candidate, used)
  if len(rows) == 0 then return -1 end if
  for index = 0 to len(rows) - 1
    if not used[index] and projection.sameRow(rows[index], candidate) then return index end if
  end for
  return -1
end function

function setOperation(leftRows, rightRows, operator, all)
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" or typeof(operator) != "int" or typeof(all) != "bool" then return fail(INVALID_ARGUMENT, "setOperation", "invalid arguments") end if
  if operator == ast.SET_UNION then
    output = leftRows + rightRows
    if not all then output = projection.distinct(output) end if
    return output
  end if
  left = leftRows
  right = rightRows
  if not all then
    left = projection.distinct(left)
    right = projection.distinct(right)
  end if
  used = array(len(right), false)
  output = []
  for each candidate in left
    matchIndex = findMatching(right, candidate, used)
    if operator == ast.SET_INTERSECT then
      if matchIndex >= 0 then
        output = output + [candidate]
        used[matchIndex] = true
      end if
    else if operator == ast.SET_EXCEPT then
      if matchIndex < 0 then
        output = output + [candidate]
      else
        used[matchIndex] = true
      end if
    else
      return fail(INVALID_ARGUMENT, "setOperation", "unknown set operator")
    end if
  end for
  return output
end function

function componentName()
  return "executor.aggregate"
end function

function targetMilestone()
  return "M16"
end function

function isImplemented()
  return true
end function
