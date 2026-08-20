package minisql.sql.expressions

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.types as types
import minisql.sql.values as values

const INVALID_ARGUMENT = 9001
const TYPE_MISMATCH = 9017
const BINDING_ERROR = 9020

const BOUND_LITERAL = 1
const BOUND_COLUMN = 2
const BOUND_UNARY = 3
const BOUND_BINARY = 4
const BOUND_IS_NULL = 5
const BOUND_AGGREGATE = 6
const BOUND_CASE = 7
const BOUND_CAST = 8
const BOUND_SCALAR = 9
const BOUND_IN = 10
const BOUND_BETWEEN = 11
const BOUND_TRUTH_TEST = 12
const BOUND_WINDOW = 13

// Groups the bound expression state and preserves the field relationships documented below.
struct BoundExpression
  // Stores the kind associated with this value.
  kind
  // Stores the operator associated with this value.
  operator
  // Stores the type info associated with this value.
  typeInfo
  // Stores the literal associated with this value.
  literal
  // Tracks the column index numeric value.
  columnIndex
  // Stores the left associated with this value.
  left
  // Stores the right associated with this value.
  right
end struct

// Groups the bound aggregate state and preserves the field relationships documented below.
struct BoundAggregate
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Stores the argument associated with this value.
  argument
  // Indicates whether the distinct condition is active.
  distinct
  // Stores the type info associated with this value.
  typeInfo
  // Stores the count star associated with this value.
  countStar
end struct

// Groups the bound case branch state and preserves the field relationships documented below.
struct BoundCaseBranch
  // Stores the condition associated with this value.
  condition
  // Stores the result associated with this value.
  result
end struct

// Groups the bound case state and preserves the field relationships documented below.
struct BoundCase
  // Stores the kind associated with this value.
  kind
  // Contains the ordered branches collection.
  branches
  // Stores the else expression associated with this value.
  elseExpression
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the bound cast state and preserves the field relationships documented below.
struct BoundCast
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the target type associated with this value.
  targetType
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the bound scalar state and preserves the field relationships documented below.
struct BoundScalar
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Contains the ordered arguments collection.
  arguments
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the bound in state and preserves the field relationships documented below.
struct BoundIn
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the candidates associated with this value.
  candidates
  // Indicates whether the negated condition is active.
  negated
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the bound between state and preserves the field relationships documented below.
struct BoundBetween
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the lower associated with this value.
  lower
  // Stores the upper associated with this value.
  upper
  // Indicates whether the negated condition is active.
  negated
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the bound truth test state and preserves the field relationships documented below.
struct BoundTruthTest
  // Stores the kind associated with this value.
  kind
  // Stores the operand associated with this value.
  operand
  // Stores the expected associated with this value.
  expected
  // Indicates whether the negated condition is active.
  negated
  // Stores the type info associated with this value.
  typeInfo
end struct


// Groups the bound window state and preserves the field relationships documented below.
struct BoundWindow
  // Stores the kind associated with this value.
  kind
  // Stores the name associated with this value.
  name
  // Contains the ordered arguments collection.
  arguments
  // Stores the partition by associated with this value.
  partitionBy
  // Contains the ordered order by collection.
  orderBy
  // Stores the descending associated with this value.
  descending
  // Stores the nulls first associated with this value.
  nullsFirst
  // Stores the nulls specified associated with this value.
  nullsSpecified
  // Stores the type info associated with this value.
  typeInfo
end struct

// Groups the row context state and preserves the field relationships documented below.
struct RowContext
  // Contains the ordered values collection.
  values
end struct

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "sql.expressions." + operation + ": " + message)
end function

// Returns whether the supplied value satisfies the bound expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundExpression(value)
  return value is BoundExpression or value is BoundAggregate or value is BoundCase or value is BoundCast or value is BoundScalar or value is BoundIn or value is BoundBetween or value is BoundTruthTest or value is BoundWindow
end function

// Returns whether the supplied value satisfies the bound aggregate condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundAggregate(value)
  return value is BoundAggregate
end function

// Returns whether the supplied value satisfies the bound literal condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundLiteral(value)
  return value is BoundExpression and value.kind == BOUND_LITERAL
end function

// Returns whether the supplied value satisfies the base bound expression condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBaseBoundExpression(value)
  return value is BoundExpression
end function

// Returns whether the supplied value satisfies the bound case condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundCase(value)
  return value is BoundCase
end function

// Returns whether the supplied value satisfies the bound cast condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundCast(value)
  return value is BoundCast
end function

// Returns whether the supplied value satisfies the bound scalar condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundScalar(value)
  return value is BoundScalar
end function

// Returns whether the supplied value satisfies the bound in condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundIn(value)
  return value is BoundIn
end function

// Returns whether the supplied value satisfies the bound between condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundBetween(value)
  return value is BoundBetween
end function

// Returns whether the supplied value satisfies the bound truth test condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundTruthTest(value)
  return value is BoundTruthTest
end function

// Returns whether the supplied value satisfies the bound window condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isBoundWindow(value)
  return value is BoundWindow
end function

// Implements literal for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function literal(value, typeInfo)
  if not values.isSqlValue(value) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "literal", "invalid literal") end if
  return BoundExpression(BOUND_LITERAL, "", typeInfo, value, -1, void, void)
end function

// Implements column for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function column(index, typeInfo)
  if typeof(index) != "int" or index < 0 or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "column", "invalid column binding") end if
  return BoundExpression(BOUND_COLUMN, "", typeInfo, void, index, void, void)
end function

// Implements unary for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function unary(operator, operand, typeInfo)
  if typeof(operator) != "string" or not isBoundExpression(operand) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "unary", "invalid unary binding") end if
  return BoundExpression(BOUND_UNARY, operator, typeInfo, void, -1, operand, void)
end function

// Implements binary for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function binary(operator, left, right, typeInfo)
  if typeof(operator) != "string" or not isBoundExpression(left) or not isBoundExpression(right) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "binary", "invalid binary binding") end if
  return BoundExpression(BOUND_BINARY, operator, typeInfo, void, -1, left, right)
end function

// Returns whether the supplied value satisfies the null condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isNull(operand, negated)
  if not isBoundExpression(operand) or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "isNull", "invalid IS NULL binding") end if
  operator = "IS NULL"
  if negated then operator = "IS NOT NULL" end if
  return BoundExpression(BOUND_IS_NULL, operator, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, false), void, -1, operand, void)
end function

// Implements aggregate for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function aggregate(name, argument, distinct, typeInfo, countStar)
  if typeof(name) != "string" or len(name) == 0 or typeof(distinct) != "bool" or not types.isSqlType(typeInfo) or typeof(countStar) != "bool" then return fail(INVALID_ARGUMENT, "aggregate", "invalid aggregate binding") end if
  if not countStar and not isBoundExpression(argument) then return fail(INVALID_ARGUMENT, "aggregate", "aggregate argument must be bound") end if
  return BoundAggregate(BOUND_AGGREGATE, name, argument, distinct, typeInfo, countStar)
end function

// Implements case branch for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function caseBranch(condition, result)
  if not isBoundExpression(condition) or not isBoundExpression(result) then return fail(INVALID_ARGUMENT, "caseBranch", "invalid CASE branch") end if
  return BoundCaseBranch(condition, result)
end function

// Implements case expression for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function caseExpression(branches, elseExpression, typeInfo)
  if typeof(branches) != "array" or len(branches) == 0 or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "caseExpression", "invalid CASE expression") end if
  for each branch in branches
    if branch is not BoundCaseBranch then return fail(INVALID_ARGUMENT, "caseExpression", "branch must be BoundCaseBranch") end if
  end for
  if elseExpression is not void and not isBoundExpression(elseExpression) then return fail(INVALID_ARGUMENT, "caseExpression", "invalid ELSE expression") end if
  return BoundCase(BOUND_CASE, branches, elseExpression, typeInfo)
end function

// Casts expression using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function castExpression(operand, targetType)
  if not isBoundExpression(operand) or not types.isSqlType(targetType) then return fail(INVALID_ARGUMENT, "castExpression", "invalid CAST expression") end if
  return BoundCast(BOUND_CAST, operand, targetType, targetType)
end function

// Implements scalar for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function scalar(name, arguments, typeInfo)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "scalar", "invalid scalar function") end if
  for each argument in arguments
    if not isBoundExpression(argument) then return fail(INVALID_ARGUMENT, "scalar", "argument must be bound") end if
  end for
  return BoundScalar(BOUND_SCALAR, name, arguments, typeInfo)
end function

// Implements in predicate for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function inPredicate(operand, candidates, negated)
  if not isBoundExpression(operand) or typeof(candidates) != "array" or len(candidates) == 0 or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "inPredicate", "invalid IN predicate") end if
  for each candidate in candidates
    if not isBoundExpression(candidate) then return fail(INVALID_ARGUMENT, "inPredicate", "candidate must be bound") end if
  end for
  nullable = operand.typeInfo.nullable
  for each candidate in candidates
    if candidate.typeInfo.nullable then nullable = true end if
  end for
  return BoundIn(BOUND_IN, operand, candidates, negated, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, nullable))
end function

// Implements between predicate for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function betweenPredicate(operand, lower, upper, negated)
  if not isBoundExpression(operand) or not isBoundExpression(lower) or not isBoundExpression(upper) or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "betweenPredicate", "invalid BETWEEN predicate") end if
  nullable = operand.typeInfo.nullable or lower.typeInfo.nullable or upper.typeInfo.nullable
  return BoundBetween(BOUND_BETWEEN, operand, lower, upper, negated, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, nullable))
end function

// Implements truth test for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function truthTest(operand, expected, negated)
  if not isBoundExpression(operand) or typeof(expected) != "string" or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "truthTest", "invalid truth test") end if
  return BoundTruthTest(BOUND_TRUTH_TEST, operand, expected, negated, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, false))
end function

// Implements window for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function window(name, arguments, partitionBy, orderBy, descending, nullsFirst, nullsSpecified, typeInfo)
  if typeof(name) != "string" or typeof(arguments) != "array" or typeof(partitionBy) != "array" or typeof(orderBy) != "array" or typeof(descending) != "array" or typeof(nullsFirst) != "array" or typeof(nullsSpecified) != "array" or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "window", "invalid window binding") end if
  if len(orderBy) != len(descending) or len(orderBy) != len(nullsFirst) or len(orderBy) != len(nullsSpecified) then return fail(INVALID_ARGUMENT, "window", "window order metadata mismatch") end if
  for each value in arguments
    if not isBoundExpression(value) then return fail(INVALID_ARGUMENT, "window", "argument must be bound") end if
  end for
  for each value in partitionBy
    if not isBoundExpression(value) then return fail(INVALID_ARGUMENT, "window", "partition expression must be bound") end if
  end for
  for each value in orderBy
    if not isBoundExpression(value) then return fail(INVALID_ARGUMENT, "window", "order expression must be bound") end if
  end for
  return BoundWindow(BOUND_WINDOW, name, arguments, partitionBy, orderBy, descending, nullsFirst, nullsSpecified, typeInfo)
end function

// Returns whether the supplied value satisfies the window condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function containsWindow(expression)
  if expression is void then return false end if
  if expression is BoundWindow then return true end if
  if expression is BoundExpression then
    if expression.kind == BOUND_UNARY or expression.kind == BOUND_IS_NULL then return containsWindow(expression.left) end if
    if expression.kind == BOUND_BINARY then return containsWindow(expression.left) or containsWindow(expression.right) end if
    return false
  end if
  if expression is BoundAggregate then return containsWindow(expression.argument) end if
  if expression is BoundCase then
    for each branch in expression.branches
      if containsWindow(branch.condition) or containsWindow(branch.result) then return true end if
    end for
    return expression.elseExpression is not void and containsWindow(expression.elseExpression)
  end if
  if expression is BoundCast then return containsWindow(expression.operand) end if
  if expression is BoundScalar then
    for each argument in expression.arguments
      if containsWindow(argument) then return true end if
    end for
    return false
  end if
  if expression is BoundIn then
    if containsWindow(expression.operand) then return true end if
    for each candidate in expression.candidates
      if containsWindow(candidate) then return true end if
    end for
    return false
  end if
  if expression is BoundBetween then return containsWindow(expression.operand) or containsWindow(expression.lower) or containsWindow(expression.upper) end if
  if expression is BoundTruthTest then return containsWindow(expression.operand) end if
  return false
end function

// Returns whether the supplied value satisfies the window list condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function containsWindowList(items)
  for each item in items
    if containsWindow(item) then return true end if
  end for
  return false
end function

// Implements references column at or after for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function referencesColumnAtOrAfter(expression, minimumIndex)
  if expression is void then return false end if
  if expression is BoundExpression then
    if expression.kind == BOUND_COLUMN then return expression.columnIndex >= minimumIndex end if
    if expression.kind == BOUND_UNARY or expression.kind == BOUND_IS_NULL then return referencesColumnAtOrAfter(expression.left, minimumIndex) end if
    if expression.kind == BOUND_BINARY then return referencesColumnAtOrAfter(expression.left, minimumIndex) or referencesColumnAtOrAfter(expression.right, minimumIndex) end if
    return false
  end if
  if expression is BoundAggregate then
    if expression.countStar then return false end if
    return referencesColumnAtOrAfter(expression.argument, minimumIndex)
  end if
  if expression is BoundCase then
    for each branch in expression.branches
      if referencesColumnAtOrAfter(branch.condition, minimumIndex) or referencesColumnAtOrAfter(branch.result, minimumIndex) then return true end if
    end for
    if expression.elseExpression is not void then return referencesColumnAtOrAfter(expression.elseExpression, minimumIndex) end if
    return false
  end if
  if expression is BoundCast then return referencesColumnAtOrAfter(expression.operand, minimumIndex) end if
  if expression is BoundScalar then
    for each argument in expression.arguments
      if referencesColumnAtOrAfter(argument, minimumIndex) then return true end if
    end for
    return false
  end if
  if expression is BoundIn then
    if referencesColumnAtOrAfter(expression.operand, minimumIndex) then return true end if
    for each candidate in expression.candidates
      if referencesColumnAtOrAfter(candidate, minimumIndex) then return true end if
    end for
    return false
  end if
  if expression is BoundBetween then return referencesColumnAtOrAfter(expression.operand, minimumIndex) or referencesColumnAtOrAfter(expression.lower, minimumIndex) or referencesColumnAtOrAfter(expression.upper, minimumIndex) end if
  if expression is BoundTruthTest then return referencesColumnAtOrAfter(expression.operand, minimumIndex) end if
  if expression is BoundWindow then
    for each argument in expression.arguments
      if referencesColumnAtOrAfter(argument, minimumIndex) then return true end if
    end for
    for each value in expression.partitionBy
      if referencesColumnAtOrAfter(value, minimumIndex) then return true end if
    end for
    for each value in expression.orderBy
      if referencesColumnAtOrAfter(value, minimumIndex) then return true end if
    end for
    return false
  end if
  return false
end function

// Returns whether the supplied value satisfies the aggregate condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function containsAggregate(expression)
  if expression is BoundWindow then return false end if
  if expression is BoundAggregate then return true end if
  if expression is BoundExpression then
    if expression.kind == BOUND_UNARY or expression.kind == BOUND_IS_NULL then return containsAggregate(expression.left) end if
    if expression.kind == BOUND_BINARY then return containsAggregate(expression.left) or containsAggregate(expression.right) end if
    return false
  end if
  if expression is BoundCase then
    for each branch in expression.branches
      if containsAggregate(branch.condition) or containsAggregate(branch.result) then return true end if
    end for
    if expression.elseExpression is not void then return containsAggregate(expression.elseExpression) end if
    return false
  end if
  if expression is BoundCast then return containsAggregate(expression.operand) end if
  if expression is BoundScalar then
    for each argument in expression.arguments
      if containsAggregate(argument) then return true end if
    end for
    return false
  end if
  if expression is BoundIn then
    if containsAggregate(expression.operand) then return true end if
    for each candidate in expression.candidates
      if containsAggregate(candidate) then return true end if
    end for
    return false
  end if
  if expression is BoundBetween then return containsAggregate(expression.operand) or containsAggregate(expression.lower) or containsAggregate(expression.upper) end if
  if expression is BoundTruthTest then return containsAggregate(expression.operand) end if
  return false
end function

// Implements same binding for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function sameBinding(left, right)
  if left is BoundAggregate or right is BoundAggregate then
    if left is not BoundAggregate or right is not BoundAggregate then return false end if
    if left.name != right.name or left.distinct != right.distinct or left.countStar != right.countStar then return false end if
    if left.countStar then return true end if
    return sameBinding(left.argument, right.argument)
  end if
  if left is BoundExpression or right is BoundExpression then
    if left is not BoundExpression or right is not BoundExpression or left.kind != right.kind or left.operator != right.operator then return false end if
    if left.kind == BOUND_LITERAL then
      if left.literal.isNull or right.literal.isNull then return left.literal.isNull and right.literal.isNull end if
      return values.compareNonNull(left.literal, right.literal) == 0
    end if
    if left.kind == BOUND_COLUMN then return left.columnIndex == right.columnIndex end if
    if left.kind == BOUND_UNARY or left.kind == BOUND_IS_NULL then return sameBinding(left.left, right.left) end if
    if left.kind == BOUND_BINARY then return sameBinding(left.left, right.left) and sameBinding(left.right, right.right) end if
    return false
  end if
  if left is BoundCase or right is BoundCase then
    if left is not BoundCase or right is not BoundCase or len(left.branches) != len(right.branches) then return false end if
    if len(left.branches) > 0 then
      for index = 0 to len(left.branches) - 1
        if not sameBinding(left.branches[index].condition, right.branches[index].condition) or not sameBinding(left.branches[index].result, right.branches[index].result) then return false end if
      end for
    end if
    if left.elseExpression is void or right.elseExpression is void then return left.elseExpression is void and right.elseExpression is void end if
    return sameBinding(left.elseExpression, right.elseExpression)
  end if
  if left is BoundCast or right is BoundCast then
    if left is not BoundCast or right is not BoundCast then return false end if
    return types.sameBase(left.targetType, right.targetType) and sameBinding(left.operand, right.operand)
  end if
  if left is BoundScalar or right is BoundScalar then
    if left is not BoundScalar or right is not BoundScalar or left.name != right.name or len(left.arguments) != len(right.arguments) then return false end if
    if len(left.arguments) > 0 then
      for index = 0 to len(left.arguments) - 1
        if not sameBinding(left.arguments[index], right.arguments[index]) then return false end if
      end for
    end if
    return true
  end if
  if left is BoundIn or right is BoundIn then
    if left is not BoundIn or right is not BoundIn or left.negated != right.negated or len(left.candidates) != len(right.candidates) or not sameBinding(left.operand, right.operand) then return false end if
    if len(left.candidates) > 0 then
      for index = 0 to len(left.candidates) - 1
        if not sameBinding(left.candidates[index], right.candidates[index]) then return false end if
      end for
    end if
    return true
  end if
  if left is BoundBetween or right is BoundBetween then
    if left is not BoundBetween or right is not BoundBetween or left.negated != right.negated then return false end if
    return sameBinding(left.operand, right.operand) and sameBinding(left.lower, right.lower) and sameBinding(left.upper, right.upper)
  end if
  if left is BoundTruthTest or right is BoundTruthTest then
    if left is not BoundTruthTest or right is not BoundTruthTest then return false end if
    return left.expected == right.expected and left.negated == right.negated and sameBinding(left.operand, right.operand)
  end if
  if left is BoundWindow and right is BoundWindow then
    if left.name != right.name or len(left.arguments) != len(right.arguments) or len(left.partitionBy) != len(right.partitionBy) or len(left.orderBy) != len(right.orderBy) then return false end if
    for index = 0 to len(left.arguments) - 1
      if not sameBinding(left.arguments[index], right.arguments[index]) then return false end if
    end for
    for index = 0 to len(left.partitionBy) - 1
      if not sameBinding(left.partitionBy[index], right.partitionBy[index]) then return false end if
    end for
    for index = 0 to len(left.orderBy) - 1
      if not sameBinding(left.orderBy[index], right.orderBy[index]) or left.descending[index] != right.descending[index] then return false end if
    end for
    return true
  end if
  return false
end function

// Implements row context for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function rowContext(rowValues)
  if typeof(rowValues) != "array" then return fail(INVALID_ARGUMENT, "rowContext", "values must be array") end if
  for each value in rowValues
    if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "rowContext", "row contains non-SqlValue") end if
  end for
  return RowContext(rowValues)
end function

// Implements numeric result for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function numericResult(left, right, operator, resultType)
  if left.isNull or right.isNull then return values.nullValue(resultType.kind) end if
  leftNumber = values.asNumber(left)
  rightNumber = values.asNumber(right)
  result = 0
  if operator == "+" then result = leftNumber + rightNumber end if
  if operator == "-" then result = leftNumber - rightNumber end if
  if operator == "*" then result = leftNumber * rightNumber end if
  if operator == "/" then
    if rightNumber == 0 then return fail(TYPE_MISMATCH, "numericResult", "division by zero") end if
    result = leftNumber / rightNumber
  end if
  if operator == "%" then
    if rightNumber == 0 then return fail(TYPE_MISMATCH, "numericResult", "modulo by zero") end if
    result = leftNumber % rightNumber
  end if
  sourceType = types.create(types.SqlTypeKind.Integer, 0, 0, 0, false)
  if typeof(result) == "float" then sourceType = types.create(types.SqlTypeKind.Double, 0, 0, 0, false) end if
  return values.convert(values.of(sourceType.kind, result), resultType)
end function

// Implements comparison result for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function comparisonResult(left, right, operator)
  if left.isNull or right.isNull then return values.nullValue(types.SqlTypeKind.Boolean) end if
  comparison = values.compareNonNull(left, right)
  result = false
  if operator == "=" then result = comparison == 0 end if
  if operator == "<>" or operator == "!=" then result = comparison != 0 end if
  if operator == "<" then result = comparison < 0 end if
  if operator == "<=" then result = comparison <= 0 end if
  if operator == ">" then result = comparison > 0 end if
  if operator == ">=" then result = comparison >= 0 end if
  return values.boolean(result)
end function

// Implements like recursive for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function likeRecursive(textBytes, patternBytes, textIndex, patternIndex)
  while patternIndex < len(patternBytes)
    patternByte = patternBytes[patternIndex]
    if patternByte == 37 then
      while patternIndex + 1 < len(patternBytes) and patternBytes[patternIndex + 1] == 37
        patternIndex = patternIndex + 1
      end while
      if patternIndex + 1 >= len(patternBytes) then return true end if
      candidate = textIndex
      while candidate <= len(textBytes)
        if likeRecursive(textBytes, patternBytes, candidate, patternIndex + 1) then return true end if
        candidate = candidate + 1
      end while
      return false
    end if
    if textIndex >= len(textBytes) then return false end if
    if patternByte != 95 and patternByte != textBytes[textIndex] then return false end if
    textIndex = textIndex + 1
    patternIndex = patternIndex + 1
  end while
  return textIndex == len(textBytes)
end function

// Implements like result for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function likeResult(left, right)
  if left.isNull or right.isNull then return values.nullValue(types.SqlTypeKind.Boolean) end if
  if typeof(left.value) != "string" or typeof(right.value) != "string" then return fail(TYPE_MISMATCH, "likeResult", "LIKE requires text operands") end if
  if len(bytes(left.value)) > 4096 or len(bytes(right.value)) > 4096 then return fail(INVALID_ARGUMENT, "likeResult", "LIKE input exceeds 4096 bytes") end if
  return values.boolean(likeRecursive(bytes(left.value), bytes(right.value), 0, 0))
end function

// Evaluates case using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateCase(expression, context)
  for each branch in expression.branches
    condition = evaluate(branch.condition, context)
    if values.truth(condition) == 1 then return values.convert(evaluate(branch.result, context), expression.typeInfo) end if
  end for
  if expression.elseExpression is void then return values.nullValue(expression.typeInfo.kind) end if
  return values.convert(evaluate(expression.elseExpression, context), expression.typeInfo)
end function

// Evaluates scalar using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateScalar(expression, context)
  if expression.name == "COALESCE" then
    for each argument in expression.arguments
      value = evaluate(argument, context)
      if not value.isNull then return values.convert(value, expression.typeInfo) end if
    end for
    return values.nullValue(expression.typeInfo.kind)
  end if
  if expression.name == "NULLIF" then
    left = evaluate(expression.arguments[0], context)
    if left.isNull then return values.nullValue(expression.typeInfo.kind) end if
    right = evaluate(expression.arguments[1], context)
    if not right.isNull and values.compareNonNull(left, right) == 0 then return values.nullValue(expression.typeInfo.kind) end if
    return values.convert(left, expression.typeInfo)
  end if
  return fail(BINDING_ERROR, "evaluateScalar", "unknown scalar function " + expression.name)
end function

// Evaluates in using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateIn(expression, context)
  operand = evaluate(expression.operand, context)
  if operand.isNull then return values.nullValue(types.SqlTypeKind.Boolean) end if
  sawNull = false
  for each candidateExpression in expression.candidates
    candidate = evaluate(candidateExpression, context)
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
end function

// Evaluates between using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateBetween(expression, context)
  operand = evaluate(expression.operand, context)
  lower = evaluate(expression.lower, context)
  upper = evaluate(expression.upper, context)
  result = values.logicalAnd(comparisonResult(operand, lower, ">="), comparisonResult(operand, upper, "<="))
  if expression.negated then result = values.logicalNot(result) end if
  return result
end function

// Evaluates truth test using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluateTruthTest(expression, context)
  truthValue = values.truth(evaluate(expression.operand, context))
  result = false
  if expression.expected == "TRUE" then result = truthValue == 1 end if
  if expression.expected == "FALSE" then result = truthValue == 0 end if
  if expression.expected == "UNKNOWN" then result = truthValue < 0 end if
  if expression.negated then result = not result end if
  return values.boolean(result)
end function

// Evaluates evaluate using the supplied inputs.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function evaluate(expression, context)
  if not isBoundExpression(expression) then return fail(INVALID_ARGUMENT, "evaluate", "expression must be bound") end if
  if expression is BoundAggregate then return fail(BINDING_ERROR, "evaluate", "aggregate requires a group context") end if
  if context is not RowContext then return fail(INVALID_ARGUMENT, "evaluate", "context must be RowContext") end if
  if expression is BoundCase then return evaluateCase(expression, context) end if
  if expression is BoundCast then return values.cast(evaluate(expression.operand, context), expression.targetType) end if
  if expression is BoundScalar then return evaluateScalar(expression, context) end if
  if expression is BoundIn then return evaluateIn(expression, context) end if
  if expression is BoundBetween then return evaluateBetween(expression, context) end if
  if expression is BoundTruthTest then return evaluateTruthTest(expression, context) end if
  if expression.kind == BOUND_LITERAL then return expression.literal end if
  if expression.kind == BOUND_COLUMN then
    if expression.columnIndex < 0 or expression.columnIndex >= len(context.values) then return fail(BINDING_ERROR, "evaluate", "column index is outside row") end if
    return context.values[expression.columnIndex]
  end if
  if expression.kind == BOUND_IS_NULL then
    operandValue = evaluate(expression.left, context)
    result = operandValue.isNull
    if expression.operator == "IS NOT NULL" then result = not result end if
    return values.boolean(result)
  end if
  if expression.kind == BOUND_UNARY then
    operandValue = evaluate(expression.left, context)
    if expression.operator == "NOT" then return values.logicalNot(operandValue) end if
    if operandValue.isNull then return values.nullValue(expression.typeInfo.kind) end if
    number = values.asNumber(operandValue)
    if expression.operator == "+" then return values.convert(values.of(operandValue.typeKind, number), expression.typeInfo) end if
    if expression.operator == "-" then return values.convert(values.of(operandValue.typeKind, 0 - number), expression.typeInfo) end if
    return fail(BINDING_ERROR, "evaluate", "unknown unary operator")
  end if
  if expression.kind == BOUND_BINARY then
    leftValue = evaluate(expression.left, context)
    if expression.operator == "AND" then
      leftTruth = values.truth(leftValue)
      if leftTruth == 0 then return values.boolean(false) end if
      return values.logicalAnd(leftValue, evaluate(expression.right, context))
    end if
    if expression.operator == "OR" then
      leftTruth = values.truth(leftValue)
      if leftTruth == 1 then return values.boolean(true) end if
      return values.logicalOr(leftValue, evaluate(expression.right, context))
    end if
    rightValue = evaluate(expression.right, context)
    if expression.operator == "+" or expression.operator == "-" or expression.operator == "*" or expression.operator == "/" or expression.operator == "%" then
      return numericResult(leftValue, rightValue, expression.operator, expression.typeInfo)
    end if
    if expression.operator == "=" or expression.operator == "<>" or expression.operator == "!=" or expression.operator == "<" or expression.operator == "<=" or expression.operator == ">" or expression.operator == ">=" then
      return comparisonResult(leftValue, rightValue, expression.operator)
    end if
    if expression.operator == "LIKE" or expression.operator == "NOT LIKE" then
      result = likeResult(leftValue, rightValue)
      if expression.operator == "NOT LIKE" then result = values.logicalNot(result) end if
      return result
    end if
    if expression.operator == "||" then
      if leftValue.isNull or rightValue.isNull then return values.nullValue(expression.typeInfo.kind) end if
      if typeof(leftValue.value) != "string" or typeof(rightValue.value) != "string" then return fail(TYPE_MISMATCH, "evaluate", "|| requires text") end if
      return values.of(expression.typeInfo.kind, leftValue.value + rightValue.value)
    end if
    return fail(BINDING_ERROR, "evaluate", "unknown binary operator " + expression.operator)
  end if
  return fail(BINDING_ERROR, "evaluate", "unknown bound expression kind")
end function

// Implements predicate passes for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function predicatePasses(expression, context)
  if expression is void then return true end if
  result = evaluate(expression, context)
  truthValue = values.truth(result)
  return truthValue == 1
end function

// Checks passes using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function checkPasses(expression, context)
  // SQL CHECK constraints reject FALSE; TRUE and UNKNOWN both satisfy them.
  if expression is void then return true end if
  result = evaluate(expression, context)
  return values.truth(result) != 0
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.expressions"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M13"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
