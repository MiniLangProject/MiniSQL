package minisql.executor.join

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian
import minisql.executor.scan as scan
import minisql.sql.ast as ast
import minisql.sql.expressions as expressions
import minisql.sql.types as types
import minisql.sql.values as values

// Join executor. M16 provides the correctness-first nested-loop implementation.
// M46 adds a deterministic hash path for INNER/LEFT equality joins while keeping
// nested loops as the semantic fallback for all other predicates and outer joins.

const INVALID_ARGUMENT = 9001
const HASH_BUCKET_COUNT = 257
const HASH_MASK = 2147483647

// Stores one build-side row in a hash-bucket collision chain.
struct HashJoinEntry
  // Non-NULL equality key retained for collision verification.
  key
  // Right/build-side row associated with the key.
  row
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "executor.join." + operation + ": " + message)
end function

// Implements combine for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function combine(left, right)
  if not scan.isScannedRow(left) or not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "combine", "rows must be ScannedRow") end if
  return scan.ScannedRow([left.reference, right.reference], left.values + right.values)
end function

// Implements null values for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nullValues(table)
  output = []
  for each column in table.columns
    output = output + [values.nullValue(column.typeCode)]
  end for
  return output
end function

// Implements null values for types for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function nullValuesForTypes(typeInfos)
  if typeof(typeInfos) != "array" then return fail(INVALID_ARGUMENT, "nullValuesForTypes", "types must be array") end if
  output = []
  for each typeInfo in typeInfos
    if not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "nullValuesForTypes", "entry must be SqlType") end if
    output = output + [values.nullValue(typeInfo.kind)]
  end for
  return output
end function

// Implements condition passes for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function conditionPasses(condition, row)
  if condition is void then return true end if
  return expressions.predicatePasses(condition, expressions.rowContext(row.values))
end function

// Implements hash bytes for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function hashBytes(input, seed)
  if typeof(input) != "bytes" or typeof(seed) != "int" then return fail(INVALID_ARGUMENT, "hashBytes", "invalid hash input") end if
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
  if typeof(value.value) == "float" and value.value == 0.0 then return hashBytes(bytes("0.0"), result) end if
  if typeof(value.value) == "int" then
    result = ((result ^ (value.value & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value >> 24) & 255)) * 16777619) & HASH_MASK
    return result
  end if
  if endian.isInt64Words(value.value) then
    result = ((result ^ (value.value.low & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.low >> 24) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ (value.value.high & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 8) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 16) & 255)) * 16777619) & HASH_MASK
    result = ((result ^ ((value.value.high >> 24) & 255)) * 16777619) & HASH_MASK
    return result
  end if
  // Floating values use the same canonical rendering as row_codec v1.
  return hashBytes(bytes("" + value.value), result)
end function

// Implements equality columns for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function equalityColumns(boundJoin)
  if typeof(boundJoin) != "struct" or not expressions.isBoundExpression(boundJoin.condition) then return void end if
  condition = boundJoin.condition
  if condition.kind != expressions.BOUND_BINARY or condition.operator != "=" then return void end if
  if not expressions.isBoundExpression(condition.left) or not expressions.isBoundExpression(condition.right) then return void end if
  if condition.left.kind != expressions.BOUND_COLUMN or condition.right.kind != expressions.BOUND_COLUMN then return void end if
  leftCount = len(boundJoin.leftTypes)
  leftIndex = condition.left.columnIndex
  rightIndex = condition.right.columnIndex
  if leftIndex >= 0 and leftIndex < leftCount and rightIndex >= leftCount then return [leftIndex, rightIndex - leftCount] end if
  if rightIndex >= 0 and rightIndex < leftCount and leftIndex >= leftCount then return [rightIndex, leftIndex - leftCount] end if
  return void
end function

// Returns whether the supplied value satisfies the hash condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function canHash(boundJoin)
  if typeof(boundJoin) != "struct" then return false end if
  if boundJoin.joinType != ast.JOIN_INNER and boundJoin.joinType != ast.JOIN_LEFT then return false end if
  columns = equalityColumns(boundJoin)
  if columns is void then return false end if
  // Hash equality requires the same physical type. Mixed numeric/text comparisons
  // remain on the nested-loop path so equal values can never land in different
  // buckets merely because their runtime representations differ.
  return types.sameBase(boundJoin.condition.left.typeInfo, boundJoin.condition.right.typeInfo)
end function

// Executes an INNER or LEFT equi-join with a right-side hash table.
// NULL keys never match, full value comparison resolves collisions, and the
// original predicate is rechecked before emission. Unsupported shapes fall back.
function applyHashRight(leftRows, rightRows, boundJoin)
  if not canHash(boundJoin) then return apply(leftRows, rightRows, boundJoin) end if
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "applyHash", "row inputs must be arrays") end if
  columns = equalityColumns(boundJoin)
  leftColumn = columns[0]
  rightColumn = columns[1]
  buckets = array(HASH_BUCKET_COUNT, void)
  for each right in rightRows
    if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "applyHash", "right input contains non-row") end if
    if rightColumn < 0 or rightColumn >= len(right.values) then return fail(INVALID_ARGUMENT, "applyHash", "right join column is out of range") end if
    key = right.values[rightColumn]
    if not key.isNull then
      bucketIndex = hashValue(key) % HASH_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      bucket = bucket + [HashJoinEntry(key, right)]
      buckets[bucketIndex] = bucket
    end if
  end for

  output = []
  for each left in leftRows
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "applyHash", "left input contains non-row") end if
    if leftColumn < 0 or leftColumn >= len(left.values) then return fail(INVALID_ARGUMENT, "applyHash", "left join column is out of range") end if
    matched = false
    key = left.values[leftColumn]
    if not key.isNull then
      bucket = buckets[hashValue(key) % HASH_BUCKET_COUNT]
      if bucket is not void then
        for each entry in bucket
          if values.compareNonNull(key, entry.key) == 0 then
            candidate = combine(left, entry.row)
            if conditionPasses(boundJoin.condition, candidate) then
              output = output + [candidate]
              matched = true
            end if
          end if
        end for
      end if
    end if
    if boundJoin.joinType == ast.JOIN_LEFT and not matched then
      output = output + [scan.ScannedRow([left.reference, void], left.values + nullValues(boundJoin.source.table))]
    end if
  end for
  return output
end function

// Executes an INNER equi-join with the left input as the hash-build side. The
// emitted row remains `left.values + right.values`, so choosing the smaller
// build side never changes bound column indexes.
function applyHashLeft(leftRows, rightRows, boundJoin)
  if not canHash(boundJoin) or boundJoin.joinType != ast.JOIN_INNER then return applyHashRight(leftRows, rightRows, boundJoin) end if
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "applyHashLeft", "row inputs must be arrays") end if
  columns = equalityColumns(boundJoin)
  leftColumn = columns[0]
  rightColumn = columns[1]
  buckets = array(HASH_BUCKET_COUNT, void)
  for each left in leftRows
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "applyHashLeft", "left input contains non-row") end if
    key = left.values[leftColumn]
    if not key.isNull then
      bucketIndex = hashValue(key) % HASH_BUCKET_COUNT
      bucket = buckets[bucketIndex]
      if bucket is void then bucket = [] end if
      bucket = bucket + [HashJoinEntry(key, left)]
      buckets[bucketIndex] = bucket
    end if
  end for
  output = []
  for each right in rightRows
    if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "applyHashLeft", "right input contains non-row") end if
    key = right.values[rightColumn]
    if not key.isNull then
      bucket = buckets[hashValue(key) % HASH_BUCKET_COUNT]
      if bucket is not void then
        for each entry in bucket
          if values.compareNonNull(entry.key, key) == 0 then
            candidate = combine(entry.row, right)
            if conditionPasses(boundJoin.condition, candidate) then output = output + [candidate] end if
          end if
        end for
      end if
    end if
  end for
  return output
end function

// Executes the optimizer-selected hash build orientation. LEFT joins keep the
// right build side because unmatched-left tracking is part of that algorithm.
function applyHashBuild(leftRows, rightRows, boundJoin, buildRight)
  if typeof(buildRight) != "bool" then return fail(INVALID_ARGUMENT, "applyHashBuild", "buildRight must be bool") end if
  if not buildRight and boundJoin.joinType == ast.JOIN_INNER then return applyHashLeft(leftRows, rightRows, boundJoin) end if
  return applyHashRight(leftRows, rightRows, boundJoin)
end function

// Backward-compatible entry point used by direct executor tests.
function applyHash(leftRows, rightRows, boundJoin)
  return applyHashBuild(leftRows, rightRows, boundJoin, true)
end function

// Executes the semantic nested-loop fallback for every supported join type.
// Tracks matched right rows for RIGHT/FULL padding and emits typed NULL padding
// for unmatched outer rows. Returns rows in deterministic left-major order.
function apply(leftRows, rightRows, boundJoin)
  if typeof(leftRows) != "array" or typeof(rightRows) != "array" then return fail(INVALID_ARGUMENT, "apply", "row inputs must be arrays") end if
  if typeof(boundJoin) != "struct" then return fail(INVALID_ARGUMENT, "apply", "join must be bound") end if
  output = []
  rightMatched = array(len(rightRows), false)
  for each left in leftRows
    if not scan.isScannedRow(left) then return fail(INVALID_ARGUMENT, "apply", "left input contains non-row") end if
    matched = false
    if len(rightRows) > 0 then
      for rightIndex = 0 to len(rightRows) - 1
        right = rightRows[rightIndex]
        if not scan.isScannedRow(right) then return fail(INVALID_ARGUMENT, "apply", "right input contains non-row") end if
        candidate = combine(left, right)
        if boundJoin.joinType == ast.JOIN_CROSS or conditionPasses(boundJoin.condition, candidate) then
          output = output + [candidate]
          matched = true
          rightMatched[rightIndex] = true
        end if
      end for
    end if
    if (boundJoin.joinType == ast.JOIN_LEFT or boundJoin.joinType == ast.JOIN_FULL) and not matched then
      output = output + [scan.ScannedRow([left.reference, void], left.values + nullValues(boundJoin.source.table))]
    end if
  end for
  if boundJoin.joinType == ast.JOIN_RIGHT or boundJoin.joinType == ast.JOIN_FULL then
    if len(rightRows) > 0 then
      leftNulls = nullValuesForTypes(boundJoin.leftTypes)
      for rightIndex = 0 to len(rightRows) - 1
        if not rightMatched[rightIndex] then
          right = rightRows[rightIndex]
          output = output + [scan.ScannedRow([void, right.reference], leftNulls + right.values)]
        end if
      end for
    end if
  end if
  return output
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "executor.join"
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
