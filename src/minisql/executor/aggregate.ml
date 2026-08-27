package minisql.executor.aggregate

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import std.concurrent.thread_pool as thread_pool
import minisql.executor.projection as projection
import minisql.executor.scan as scan
import minisql.executor.sort as sort
import minisql.platform.file as file_api
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
const INTRA_QUERY_WORKERS = 4

// Computes non-negative truncating integer division for spill partition sizing.
function integerDivide(numerator, denominator)
  if numerator < 0 or denominator <= 0 then return fail(INVALID_ARGUMENT, "integerDivide", "invalid arguments") end if
  return (numerator - (numerator % denominator)) / denominator
end function

// Owns one SQL grouping key and all input rows assigned to that key.
struct AggregateGroup
  // Evaluated GROUP BY values; NULL values compare equal for grouping.
  keyValues
  // Input rows in stable scan order for aggregate evaluation.
  rows
end struct

// Maps a collision-chain key to an index in the stable `groups` array.
struct HashGroupEntry
  // Full key retained to resolve hash collisions using SQL grouping equality.
  keyValues
  // Index of the corresponding AggregateGroup.
  groupIndex
end struct

// Immutable work package for one independent aggregate hash partition.
struct AggregatePartitionTask
  // Validated spill run containing every row for this hash partition.
  run
  // Bound SELECT expressions evaluated for each completed group.
  selectExpressions
  // Bound grouping expressions whose hash selected this partition.
  groupExpressions
  // Optional bound HAVING predicate.
  havingExpression
  // Bound ORDER BY expressions retained for the final merge/sort stage.
  orderExpressions
end struct

// Fixed-size state for one direct scalar aggregate in the streaming fast path.
struct AggregateAccumulator
  // Bound aggregate whose semantics this state implements.
  expression
  // Number of contributing non-NULL values, or input rows for COUNT(*).
  count
  // Running numeric SUM used by SUM and AVG.
  total
  // Current extremum used by MIN and MAX.
  selected
  // Current boolean fold used by BOOL_AND and BOOL_OR.
  booleanValue
  // Indicates whether any non-NULL input contributed.
  hasValue
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.aggregate." + operation + ": " + message)
end function

// Implements hash bytes for this module.
// Returns the computed value or operation status.
// Does not modify its inputs.
function hashBytes(input, seed)
  result = seed & HASH_MASK
  if len(input) > 0 then
    for index = 0 to len(input) - 1
      result = ((result ^ input[index]) * 16777619) & HASH_MASK
    end for
  end if
  return result
end function

// Implements hash value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
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

// Implements hash values for this module.
// Returns the computed value or operation status.
// Does not modify its inputs.
function hashValues(input)
  result = 2166136261 & HASH_MASK
  for each value in input
    result = ((result ^ hashValue(value)) * 16777619) & HASH_MASK
  end for
  return result
end function

// Implements same value for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sameValue(left, right)
  if left.isNull or right.isNull then return left.isNull and right.isNull end if
  return values.compareNonNull(left, right) == 0
end function

// Implements same values for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sameValues(left, right)
  if len(left) != len(right) then return false end if
  if len(left) > 0 then
    for index = 0 to len(left) - 1
      if not sameValue(left[index], right[index]) then return false end if
    end for
  end if
  return true
end function

// Implements distinct values for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Evaluates argument using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateArgument(expression, row)
  return expressions.evaluate(expression, expressions.rowContext(row.values))
end function

// Implements aggregate value for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function aggregateValue(expression, rows)
  if not expressions.isBoundAggregate(expression) then return fail(INVALID_ARGUMENT, "aggregateValue", "expression must be aggregate") end if
  if expression.name == "STRING_AGG" then
    entries = []
    for each row in rows
      value = evaluateArgument(expression.argument, row)
      if not value.isNull then
        duplicate = false
        if expression.distinct then
          for each entry in entries
            if sameValue(value, entry[0]) then duplicate = true end if
          end for
        end if
        if not duplicate then entries = entries + [[value, evaluateArgument(expression.separator, row)]] end if
      end if
    end for
    if len(entries) == 0 then return values.nullValue(expression.typeInfo.kind) end if
    outputSize = 0
    for index = 0 to len(entries) - 1
      outputSize = outputSize + len(bytes(entries[index][0].value))
      if index > 0 and not entries[index][1].isNull then outputSize = outputSize + len(bytes(entries[index][1].value)) end if
    end for
    output = bytes(outputSize)
    outputOffset = 0
    for index = 0 to len(entries) - 1
      if index > 0 and not entries[index][1].isNull then
        separatorBytes = bytes(entries[index][1].value)
        if len(separatorBytes) > 0 then
          for byteIndex = 0 to len(separatorBytes) - 1
            output[outputOffset] = separatorBytes[byteIndex]
            outputOffset = outputOffset + 1
          end for
        end if
      end if
      valueBytes = bytes(entries[index][0].value)
      if len(valueBytes) > 0 then
        for byteIndex = 0 to len(valueBytes) - 1
          output[outputOffset] = valueBytes[byteIndex]
          outputOffset = outputOffset + 1
        end for
      end if
    end for
    return values.text(decode(output))
  end if
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
  if expression.name == "BOOL_AND" or expression.name == "BOOL_OR" then
    result = expression.name == "BOOL_AND"
    for each candidate in candidates
      if expression.name == "BOOL_AND" then result = result and candidate.value else result = result or candidate.value end if
    end for
    return values.boolean(result)
  end if
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

// Creates an accumulator whose neutral state matches SQL empty-input rules.
function createAccumulator(expression)
  booleanValue = false
  if expression.name == "BOOL_AND" then booleanValue = true end if
  return AggregateAccumulator(expression, 0, 0, void, booleanValue, false)
end function

// Updates one accumulator from one row without retaining the row.
function accumulate(state, row)
  expression = state.expression
  if expression.countStar then state.count = state.count + 1; return true end if
  // Direct column aggregates are the dominant streaming case. Reading the
  // already decoded slot avoids allocating a RowContext and dispatching the
  // general expression evaluator once per input row; complex arguments retain
  // the full evaluator and identical SQL semantics.
  value = void
  if expressions.isBaseBoundExpression(expression.argument) and expression.argument.kind == expressions.BOUND_COLUMN then
    value = row.values[expression.argument.columnIndex]
  else
    value = evaluateArgument(expression.argument, row)
  end if
  if value.isNull then return true end if
  state.count = state.count + 1
  state.hasValue = true
  if expression.name == "COUNT" then return true end if
  if expression.name == "MIN" or expression.name == "MAX" then
    if state.selected is void then
      state.selected = value
    else
      comparison = values.compareNonNull(value, state.selected)
      if (expression.name == "MIN" and comparison < 0) or (expression.name == "MAX" and comparison > 0) then state.selected = value end if
    end if
    return true
  end if
  if expression.name == "BOOL_AND" then state.booleanValue = state.booleanValue and value.value; return true end if
  if expression.name == "BOOL_OR" then state.booleanValue = state.booleanValue or value.value; return true end if
  state.total = state.total + values.asNumber(value)
  return true
end function

// Converts an accumulator into the same SqlValue produced by aggregateValue.
function finishAccumulator(state)
  expression = state.expression
  if expression.name == "COUNT" then return values.of(types.SqlTypeKind.BigInt, endian.int64FromInt(state.count)) end if
  if not state.hasValue then return values.nullValue(expression.typeInfo.kind) end if
  if expression.name == "MIN" or expression.name == "MAX" then return state.selected end if
  if expression.name == "BOOL_AND" or expression.name == "BOOL_OR" then return values.boolean(state.booleanValue) end if
  if expression.name == "AVG" then return values.doubleValue((state.total + 0.0) / state.count) end if
  source = void
  if typeof(state.total) == "float" then source = values.doubleValue(state.total) else source = values.integer(state.total) end if
  return values.convert(source, expression.typeInfo)
end function

// Builds the narrowest safe source-column mask for direct aggregate arguments.
// Complex scalar arguments retain full decoding while still avoiding row
// materialization; direct column aggregates skip unrelated external values.
function streamingRequiredColumns(table, selectExpressions)
  required = array(len(table.columns), false)
  for each expression in selectExpressions
    if expression.countStar then
      // COUNT(*) requires no decoded column values.
    else if expressions.isBaseBoundExpression(expression.argument) and expression.argument.kind == expressions.BOUND_COLUMN then
      index = expression.argument.columnIndex
      if index < 0 or index >= len(required) then return void end if
      required[index] = true
    else
      return void
    end if
  end for
  return required
end function

// Creates accumulator state for a validated streaming scalar aggregate list.
function streamingAccumulators(selectExpressions, operation)
  states = []
  for each expression in selectExpressions
    if not expressions.isBoundAggregate(expression) or expression.distinct or expression.name == "STRING_AGG" then return fail(INVALID_ARGUMENT, operation, "unsupported streaming aggregate") end if
    states = states + [createAccumulator(expression)]
  end for
  return states
end function

// Finalizes fixed-size accumulators into the ordinary one-row projection shape.
function finishStreaming(states)
  output = []
  for each state in states
    output = output + [finishAccumulator(state)]
  end for
  return [projection.ProjectedRow(void, output, [])]
end function

// Streams already selected rows through a predicate and fixed-size scalar
// aggregate state. This is used by planned index scans without rebuilding the
// general grouping structures.
function projectStreamingRows(rows, selectExpressions, predicate)
  if typeof(rows) != "array" or typeof(selectExpressions) != "array" then return fail(INVALID_ARGUMENT, "projectStreamingRows", "invalid arguments") end if
  states = streamingAccumulators(selectExpressions, "projectStreamingRows")
  for each row in rows
    if not scan.isScannedRow(row) then return fail(INVALID_ARGUMENT, "projectStreamingRows", "rows contain non-ScannedRow") end if
    if predicate is void or expressions.predicatePasses(predicate, expressions.rowContext(row.values)) then
      for each state in states
        updated = try(accumulate(state, row))
        if typeof(updated) == "error" then return updated end if
      end for
    end if
  end for
  return finishStreaming(states)
end function

// Streams one filtered base table through fixed-size scalar aggregate
// accumulators. The caller-supplied mask includes both aggregate and predicate
// columns, and the reader closes on every reported failure path.
function projectStreamingTableFiltered(databasePath, table, pageTransaction, readCache, selectExpressions, predicate, requiredColumns)
  if typeof(databasePath) != "string" or typeof(selectExpressions) != "array" then return fail(INVALID_ARGUMENT, "projectStreamingTableFiltered", "invalid arguments") end if
  states = streamingAccumulators(selectExpressions, "projectStreamingTableFiltered")
  reader = try(scan.openCached(databasePath, table, pageTransaction, readCache))
  if typeof(reader) == "error" then return reader end if
  cursor = scan.openCursor(reader, requiredColumns)
  operationError = void
  while operationError is void
    row = try(scan.nextRow(cursor))
    if typeof(row) == "error" then
      operationError = row
    else if row is void then
      break
    else if predicate is void or expressions.predicatePasses(predicate, expressions.rowContext(row.values)) then
      for each state in states
        updated = try(accumulate(state, row))
        if typeof(updated) == "error" then operationError = updated; break end if
      end for
    end if
  end while
  closeResult = try(scan.close(reader))
  if operationError is not void then return operationError end if
  if typeof(closeResult) == "error" then return closeResult end if
  return finishStreaming(states)
end function

// Keeps the unfiltered hot path branch-free inside the row loop. This function
// is intentionally separate from projectStreamingTableFiltered because scalar
// whole-table aggregates are common and execute the loop once per stored row.
function projectStreamingTable(databasePath, table, pageTransaction, readCache, selectExpressions)
  if typeof(databasePath) != "string" or typeof(selectExpressions) != "array" then return fail(INVALID_ARGUMENT, "projectStreamingTable", "invalid arguments") end if
  states = streamingAccumulators(selectExpressions, "projectStreamingTable")
  reader = try(scan.openCached(databasePath, table, pageTransaction, readCache))
  if typeof(reader) == "error" then return reader end if
  cursor = scan.openCursor(reader, streamingRequiredColumns(table, selectExpressions))
  operationError = void
  while operationError is void
    row = try(scan.nextRow(cursor))
    if typeof(row) == "error" then
      operationError = row
    else if row is void then
      break
    else
      for each state in states
        updated = try(accumulate(state, row))
        if typeof(updated) == "error" then operationError = updated; break end if
      end for
    end if
  end while
  closeResult = try(scan.close(reader))
  if operationError is not void then return operationError end if
  if typeof(closeResult) == "error" then return closeResult end if
  return finishStreaming(states)
end function

// Evaluates group using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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
    arguments = []
    for each argument in expression.arguments
      arguments = arguments + [evaluateGroup(argument, rows, representative)]
    end for
    return expressions.evaluateScalarValues(expression, arguments)
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

// Evaluates list using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateList(boundExpressions, rows, representative)
  output = []
  for each expression in boundExpressions
    output = output + [evaluateGroup(expression, rows, representative)]
  end for
  return output
end function

// Partitions rows with a fixed-bucket hash table and explicit collision chains.
// Full-key comparison preserves SQL NULL/equality semantics; the separate groups
// array preserves first-key encounter order. Empty global aggregation yields one group.
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

// Implements project for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Converts scanned rows to the shared validated spill representation.
function projectedSpillRows(rows)
  output = []
  for each row in rows
    output = output + [projection.ProjectedRow(void, row.values, [])]
  end for
  return output
end function

// Restores value-only scanned rows from a validated spill partition.
function scannedSpillRows(rows)
  output = []
  for each row in rows
    output = output + [scan.ScannedRow(void, row.values)]
  end for
  return output
end function

// Reads, aggregates, and removes one partition. Different tasks own disjoint
// files and disjoint hash tables, so native workers require no shared lock.
function projectSpilledPartition(task)
  restored = try(sort.readRun(task.run))
  if typeof(restored) == "error" then sort.cleanupRuns([task.run]); return restored end if
  output = try(project(scannedSpillRows(restored), task.selectExpressions, task.groupExpressions, task.havingExpression, task.orderExpressions))
  cleanup = try(sort.cleanupRuns([task.run]))
  if typeof(output) == "error" then return output end if
  if typeof(cleanup) == "error" then return cleanup end if
  return output
end function

// Executes grouped aggregation one hash partition at a time when the input
// exceeds the configured threshold. Equal group keys always select the same
// partition; final ORDER BY, when present, restores requested output ordering.
function projectWithSpill(rows, selectExpressions, groupExpressions, havingExpression, orderExpressions, temporaryRoot, threshold)
  if typeof(temporaryRoot) != "string" or typeof(threshold) != "int" or threshold < 2 then return fail(INVALID_ARGUMENT, "projectWithSpill", "invalid spill configuration") end if
  if len(rows) <= threshold or len(groupExpressions) == 0 then return project(rows, selectExpressions, groupExpressions, havingExpression, orderExpressions) end if
  if not file_api.directoryExists(temporaryRoot) then
    created = try(file_api.createDirectory(temporaryRoot))
    if typeof(created) == "error" then return created end if
  end if
  partitionCount = integerDivide(len(rows) + threshold - 1, threshold)
  if partitionCount < 2 then partitionCount = 2 end if
  if partitionCount > HASH_BUCKET_COUNT then partitionCount = HASH_BUCKET_COUNT end if
  token = sort.nextSpillToken()
  partitions = array(partitionCount)
  for partitionIndex = 0 to partitionCount - 1
    partitions[partitionIndex] = []
  end for
  for each row in rows
    context = expressions.rowContext(row.values)
    key = []
    for each expression in groupExpressions
      key = key + [expressions.evaluate(expression, context)]
    end for
    partitionIndex = hashValues(key) % partitionCount
    partitions[partitionIndex] = partitions[partitionIndex] + [row]
  end for
  tasks = []
  for partitionIndex = 0 to partitionCount - 1
    partition = partitions[partitionIndex]
    if len(partition) > 0 then
      run = try(sort.writeRun(sort.runPath(temporaryRoot, "aggregate-" + token, partitionIndex), projectedSpillRows(partition), len(partition[0].values), 0))
      if typeof(run) == "error" then return run end if
      tasks = tasks + [AggregatePartitionTask(run, selectExpressions, groupExpressions, havingExpression, orderExpressions)]
    end if
    partitions[partitionIndex] = []
  end for
  workerCount = len(tasks)
  if workerCount > INTRA_QUERY_WORKERS then workerCount = INTRA_QUERY_WORKERS end if
  pool = try(thread_pool.ThreadPool.withQueueCapacity(workerCount, len(tasks)))
  if typeof(pool) == "error" then
    for each task in tasks
      sort.cleanupRuns([task.run])
    end for
    return pool
  end if
  jobs = []
  for each task in tasks
    job = pool.Submit(projectSpilledPartition, task)
    if job is void then
      pool.ShutdownNow()
      pool.AwaitTermination()
      for each pending in tasks
        sort.cleanupRuns([pending.run])
      end for
      pool.Dispose()
      return fail(INVALID_ARGUMENT, "projectWithSpill", "aggregate partition task was rejected")
    end if
    jobs = jobs + [job]
  end for
  pool.Shutdown()
  pool.AwaitTermination()
  output = []
  for each job in jobs
    partitionOutput = try(job.GetResult())
    disposed = job.Dispose()
    if typeof(partitionOutput) == "error" then pool.Dispose(); return partitionOutput end if
    output = output + partitionOutput
  end for
  pool.Dispose()
  return output
end function

// Finds matching using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function findMatching(rows, candidate, used)
  if len(rows) == 0 then return -1 end if
  for index = 0 to len(rows) - 1
    if not used[index] and projection.sameRow(rows[index], candidate) then return index end if
  end for
  return -1
end function

// Implements set operation for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
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

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.aggregate"
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
