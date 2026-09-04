//! Provides minisql sql expressions facilities for this project.

package minisql.sql.expressions

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.math as math
import std.bytes as bytes_api
import minisql.common.endian as endian
import minisql.sql.types as types
import minisql.sql.values as values

/// Defines the invalid argument constant used by the minisql sql expressions module.
const INVALID_ARGUMENT = 9001
/// Defines the type mismatch constant used by the minisql sql expressions module.
const TYPE_MISMATCH = 9017
/// Defines the binding error constant used by the minisql sql expressions module.
const BINDING_ERROR = 9020

/// Defines the bound literal constant used by the minisql sql expressions module.
const BOUND_LITERAL = 1
/// Defines the bound column constant used by the minisql sql expressions module.
const BOUND_COLUMN = 2
/// Defines the bound unary constant used by the minisql sql expressions module.
const BOUND_UNARY = 3
/// Defines the bound binary constant used by the minisql sql expressions module.
const BOUND_BINARY = 4
/// Defines the bound is null constant used by the minisql sql expressions module.
const BOUND_IS_NULL = 5
/// Defines the bound aggregate constant used by the minisql sql expressions module.
const BOUND_AGGREGATE = 6
/// Defines the bound case constant used by the minisql sql expressions module.
const BOUND_CASE = 7
/// Defines the bound cast constant used by the minisql sql expressions module.
const BOUND_CAST = 8
/// Defines the bound scalar constant used by the minisql sql expressions module.
const BOUND_SCALAR = 9
/// Defines the bound in constant used by the minisql sql expressions module.
const BOUND_IN = 10
/// Defines the bound between constant used by the minisql sql expressions module.
const BOUND_BETWEEN = 11
/// Defines the bound truth test constant used by the minisql sql expressions module.
const BOUND_TRUTH_TEST = 12
/// Defines the bound window constant used by the minisql sql expressions module.
const BOUND_WINDOW = 13
/// Defines the bound subquery constant used by the minisql sql expressions module.
const BOUND_SUBQUERY = 14

/// Defines the subquery scalar constant used by the minisql sql expressions module.
const SUBQUERY_SCALAR = 1
/// Defines the subquery exists constant used by the minisql sql expressions module.
const SUBQUERY_EXISTS = 2
/// Defines the subquery in constant used by the minisql sql expressions module.
const SUBQUERY_IN = 3

/// Groups the bound expression state and preserves the field relationships documented below.
struct BoundExpression
  /// Stores the kind associated with this value.
  kind
  /// Stores the operator associated with this value.
  operator
  /// Stores the type info associated with this value.
  typeInfo
  /// Stores the literal associated with this value.
  literal
  /// Tracks the column index numeric value.
  columnIndex
  /// Stores the left associated with this value.
  left
  /// Stores the right associated with this value.
  right
end struct

/// Groups the bound aggregate state and preserves the field relationships documented below.
struct BoundAggregate
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Stores the argument associated with this value.
  argument
  /// Stores the optional delimiter or secondary aggregate argument.
  separator
  /// Indicates whether the distinct condition is active.
  distinct
  /// Stores the type info associated with this value.
  typeInfo
  /// Stores the count star associated with this value.
  countStar
end struct

/// Groups the bound case branch state and preserves the field relationships documented below.
struct BoundCaseBranch
  /// Stores the condition associated with this value.
  condition
  /// Stores the result associated with this value.
  result
end struct

/// Groups the bound case state and preserves the field relationships documented below.
struct BoundCase
  /// Stores the kind associated with this value.
  kind
  /// Contains the ordered branches collection.
  branches
  /// Stores the else expression associated with this value.
  elseExpression
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the bound cast state and preserves the field relationships documented below.
struct BoundCast
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the target type associated with this value.
  targetType
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the bound scalar state and preserves the field relationships documented below.
struct BoundScalar
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Contains the ordered arguments collection.
  arguments
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the bound in state and preserves the field relationships documented below.
struct BoundIn
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the candidates associated with this value.
  candidates
  /// Indicates whether the negated condition is active.
  negated
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the bound between state and preserves the field relationships documented below.
struct BoundBetween
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the lower associated with this value.
  lower
  /// Stores the upper associated with this value.
  upper
  /// Indicates whether the negated condition is active.
  negated
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the bound truth test state and preserves the field relationships documented below.
struct BoundTruthTest
  /// Stores the kind associated with this value.
  kind
  /// Stores the operand associated with this value.
  operand
  /// Stores the expected associated with this value.
  expected
  /// Indicates whether the negated condition is active.
  negated
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Carries a SELECT that must be evaluated against the current outer row.
/// The binder records its SQL result type while the executor substitutes
/// qualified outer references immediately before running the nested query.
struct BoundSubquery
  /// Identifies scalar, EXISTS, or IN result semantics.
  subqueryKind
  /// Retains the parsed nested SELECT until an outer row is available.
  query
  /// Stores the bound left operand for IN, or void for scalar and EXISTS forms.
  operand
  /// Indicates whether an IN result is negated.
  negated
  /// Stores the statically inferred SQL result type.
  typeInfo
end struct


/// Groups the bound window state and preserves the field relationships documented below.
struct BoundWindow
  /// Stores the kind associated with this value.
  kind
  /// Stores the name associated with this value.
  name
  /// Contains the ordered arguments collection.
  arguments
  /// Stores the partition by associated with this value.
  partitionBy
  /// Contains the ordered order by collection.
  orderBy
  /// Stores the descending associated with this value.
  descending
  /// Stores the nulls first associated with this value.
  nullsFirst
  /// Stores the nulls specified associated with this value.
  nullsSpecified
  /// Stores the type info associated with this value.
  typeInfo
end struct

/// Groups the row context state and preserves the field relationships documented below.
struct RowContext
  /// Contains the ordered values collection.
  values
end struct

/// Performs the fail operation for the minisql sql expressions module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "sql.expressions." + operation + ": " + message)
end function

/// Returns whether the supplied value satisfies the bound expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundExpression(value)
  return value is BoundExpression or value is BoundAggregate or value is BoundCase or value is BoundCast or value is BoundScalar or value is BoundIn or value is BoundBetween or value is BoundTruthTest or value is BoundWindow or value is BoundSubquery
end function

/// Returns whether the supplied value satisfies the bound aggregate condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundAggregate(value)
  return value is BoundAggregate
end function

/// Returns whether the supplied value satisfies the bound literal condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundLiteral(value)
  return value is BoundExpression and value.kind == BOUND_LITERAL
end function

/// Returns whether the supplied value satisfies the base bound expression condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBaseBoundExpression(value)
  return value is BoundExpression
end function

/// Returns whether the supplied value satisfies the bound case condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundCase(value)
  return value is BoundCase
end function

/// Returns whether the supplied value satisfies the bound cast condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundCast(value)
  return value is BoundCast
end function

/// Returns whether the supplied value satisfies the bound scalar condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundScalar(value)
  return value is BoundScalar
end function

/// Returns whether the supplied value satisfies the bound in condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundIn(value)
  return value is BoundIn
end function

/// Returns whether the supplied value satisfies the bound between condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundBetween(value)
  return value is BoundBetween
end function

/// Returns whether the supplied value satisfies the bound truth test condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundTruthTest(value)
  return value is BoundTruthTest
end function

/// Returns whether the supplied value satisfies the bound window condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isBoundWindow(value)
  return value is BoundWindow
end function

/// Returns whether a bound expression defers a nested SELECT to row evaluation.
/// @param value Value consumed or transformed by the operation.
function isBoundSubquery(value)
  return value is BoundSubquery
end function

/// Implements literal for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param value Value consumed or transformed by the operation.
/// @param typeInfo typeInfo value consumed by this operation.
function literal(value, typeInfo)
  if not values.isSqlValue(value) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "literal", "invalid literal") end if
  return BoundExpression(BOUND_LITERAL, "", typeInfo, value, -1, void, void)
end function

/// Implements column for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param index Zero-based index of the affected item.
/// @param typeInfo typeInfo value consumed by this operation.
function column(index, typeInfo)
  if typeof(index) != "int" or index < 0 or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "column", "invalid column binding") end if
  return BoundExpression(BOUND_COLUMN, "", typeInfo, void, index, void, void)
end function

/// Implements unary for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operator operator value consumed by this operation.
/// @param operand operand value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
function unary(operator, operand, typeInfo)
  if typeof(operator) != "string" or not isBoundExpression(operand) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "unary", "invalid unary binding") end if
  return BoundExpression(BOUND_UNARY, operator, typeInfo, void, -1, operand, void)
end function

/// Implements binary for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operator operator value consumed by this operation.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
function binary(operator, left, right, typeInfo)
  if typeof(operator) != "string" or not isBoundExpression(left) or not isBoundExpression(right) or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "binary", "invalid binary binding") end if
  return BoundExpression(BOUND_BINARY, operator, typeInfo, void, -1, left, right)
end function

/// Returns whether the supplied value satisfies the null condition.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param operand operand value consumed by this operation.
/// @param negated negated value consumed by this operation.
function isNull(operand, negated)
  if not isBoundExpression(operand) or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "isNull", "invalid IS NULL binding") end if
  operator = "IS NULL"
  if negated then operator = "IS NOT NULL" end if
  return BoundExpression(BOUND_IS_NULL, operator, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, false), void, -1, operand, void)
end function

/// Implements aggregate for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param argument argument value consumed by this operation.
/// @param separator separator value consumed by this operation.
/// @param distinct distinct value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
/// @param countStar countStar value consumed by this operation.
function aggregate(name, argument, separator, distinct, typeInfo, countStar)
  if typeof(name) != "string" or len(name) == 0 or typeof(distinct) != "bool" or not types.isSqlType(typeInfo) or typeof(countStar) != "bool" then return fail(INVALID_ARGUMENT, "aggregate", "invalid aggregate binding") end if
  if not countStar and not isBoundExpression(argument) then return fail(INVALID_ARGUMENT, "aggregate", "aggregate argument must be bound") end if
  if separator is not void and not isBoundExpression(separator) then return fail(INVALID_ARGUMENT, "aggregate", "aggregate separator must be bound") end if
  return BoundAggregate(BOUND_AGGREGATE, name, argument, separator, distinct, typeInfo, countStar)
end function

/// Implements case branch for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param condition condition value consumed by this operation.
/// @param result Result object populated or inspected by the operation.
function caseBranch(condition, result)
  if not isBoundExpression(condition) or not isBoundExpression(result) then return fail(INVALID_ARGUMENT, "caseBranch", "invalid CASE branch") end if
  return BoundCaseBranch(condition, result)
end function

/// Implements case expression for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param branches branches value consumed by this operation.
/// @param elseExpression elseExpression value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
function caseExpression(branches, elseExpression, typeInfo)
  if typeof(branches) != "array" or len(branches) == 0 or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "caseExpression", "invalid CASE expression") end if
  for each branch in branches
    if branch is not BoundCaseBranch then return fail(INVALID_ARGUMENT, "caseExpression", "branch must be BoundCaseBranch") end if
  end for
  if elseExpression is not void and not isBoundExpression(elseExpression) then return fail(INVALID_ARGUMENT, "caseExpression", "invalid ELSE expression") end if
  return BoundCase(BOUND_CASE, branches, elseExpression, typeInfo)
end function

/// Casts expression using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param targetType targetType value consumed by this operation.
function castExpression(operand, targetType)
  if not isBoundExpression(operand) or not types.isSqlType(targetType) then return fail(INVALID_ARGUMENT, "castExpression", "invalid CAST expression") end if
  return BoundCast(BOUND_CAST, operand, targetType, targetType)
end function

/// Implements scalar for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param arguments arguments value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
function scalar(name, arguments, typeInfo)
  if typeof(name) != "string" or len(name) == 0 or typeof(arguments) != "array" or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "scalar", "invalid scalar function") end if
  for each argument in arguments
    if not isBoundExpression(argument) then return fail(INVALID_ARGUMENT, "scalar", "argument must be bound") end if
  end for
  return BoundScalar(BOUND_SCALAR, name, arguments, typeInfo)
end function

/// Implements in predicate for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param candidates candidates value consumed by this operation.
/// @param negated negated value consumed by this operation.
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

/// Implements between predicate for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param lower lower value consumed by this operation.
/// @param upper upper value consumed by this operation.
/// @param negated negated value consumed by this operation.
function betweenPredicate(operand, lower, upper, negated)
  if not isBoundExpression(operand) or not isBoundExpression(lower) or not isBoundExpression(upper) or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "betweenPredicate", "invalid BETWEEN predicate") end if
  nullable = operand.typeInfo.nullable or lower.typeInfo.nullable or upper.typeInfo.nullable
  return BoundBetween(BOUND_BETWEEN, operand, lower, upper, negated, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, nullable))
end function

/// Implements truth test for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param operand operand value consumed by this operation.
/// @param expected expected value consumed by this operation.
/// @param negated negated value consumed by this operation.
function truthTest(operand, expected, negated)
  if not isBoundExpression(operand) or typeof(expected) != "string" or typeof(negated) != "bool" then return fail(INVALID_ARGUMENT, "truthTest", "invalid truth test") end if
  return BoundTruthTest(BOUND_TRUTH_TEST, operand, expected, negated, types.create(types.SqlTypeKind.Boolean, 0, 0, 0, false))
end function

/// Creates a deferred subquery binding after its shape and result type have been validated.
/// @param subqueryKind subqueryKind value consumed by this operation.
/// @param query query value consumed by this operation.
/// @param operand operand value consumed by this operation.
/// @param negated negated value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
function subquery(subqueryKind, query, operand, negated, typeInfo)
  if typeof(subqueryKind) != "int" or typeof(negated) != "bool" or not types.isSqlType(typeInfo) then return fail(INVALID_ARGUMENT, "subquery", "invalid subquery binding") end if
  if subqueryKind != SUBQUERY_SCALAR and subqueryKind != SUBQUERY_EXISTS and subqueryKind != SUBQUERY_IN then return fail(INVALID_ARGUMENT, "subquery", "unknown subquery kind") end if
  if subqueryKind == SUBQUERY_IN and not isBoundExpression(operand) then return fail(INVALID_ARGUMENT, "subquery", "IN subquery requires a bound operand") end if
  if subqueryKind != SUBQUERY_IN and operand is not void then return fail(INVALID_ARGUMENT, "subquery", "unexpected subquery operand") end if
  return BoundSubquery(subqueryKind, query, operand, negated, typeInfo)
end function

/// Returns true when an expression tree contains a row-dependent nested SELECT.
/// @param expression expression value consumed by this operation.
function containsSubquery(expression)
  if expression is void then return false end if
  if expression is BoundSubquery then return true end if
  if expression is BoundExpression then
    if expression.kind == BOUND_UNARY or expression.kind == BOUND_IS_NULL then return containsSubquery(expression.left) end if
    if expression.kind == BOUND_BINARY then return containsSubquery(expression.left) or containsSubquery(expression.right) end if
    return false
  end if
  if expression is BoundAggregate then
    if expression.countStar then return false end if
    if containsSubquery(expression.argument) then return true end if
    return expression.separator is not void and containsSubquery(expression.separator)
  end if
  if expression is BoundCase then
    for each branch in expression.branches
      if containsSubquery(branch.condition) or containsSubquery(branch.result) then return true end if
    end for
    return expression.elseExpression is not void and containsSubquery(expression.elseExpression)
  end if
  if expression is BoundCast then return containsSubquery(expression.operand) end if
  if expression is BoundScalar then
    for each argument in expression.arguments
      if containsSubquery(argument) then return true end if
    end for
    return false
  end if
  if expression is BoundIn then
    if containsSubquery(expression.operand) then return true end if
    for each candidate in expression.candidates
      if containsSubquery(candidate) then return true end if
    end for
    return false
  end if
  if expression is BoundBetween then return containsSubquery(expression.operand) or containsSubquery(expression.lower) or containsSubquery(expression.upper) end if
  if expression is BoundTruthTest then return containsSubquery(expression.operand) end if
  if expression is BoundWindow then
    for each argument in expression.arguments
      if containsSubquery(argument) then return true end if
    end for
    for each value in expression.partitionBy
      if containsSubquery(value) then return true end if
    end for
    for each value in expression.orderBy
      if containsSubquery(value) then return true end if
    end for
  end if
  return false
end function

/// Returns true when at least one expression in a list contains a subquery.
/// @param items Items consumed or updated by the operation.
function containsSubqueryList(items)
  for each item in items
    if containsSubquery(item) then return true end if
  end for
  return false
end function

/// Implements window for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param name Name of the affected item.
/// @param arguments arguments value consumed by this operation.
/// @param partitionBy partitionBy value consumed by this operation.
/// @param orderBy orderBy value consumed by this operation.
/// @param descending descending value consumed by this operation.
/// @param nullsFirst nullsFirst value consumed by this operation.
/// @param nullsSpecified nullsSpecified value consumed by this operation.
/// @param typeInfo typeInfo value consumed by this operation.
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

/// Returns whether the supplied value satisfies the window condition.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param expression expression value consumed by this operation.
function containsWindow(expression)
  if expression is void then return false end if
  if expression is BoundWindow then return true end if
  if expression is BoundSubquery then return false end if
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

/// Returns whether the supplied value satisfies the window list condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param items Items consumed or updated by the operation.
function containsWindowList(items)
  for each item in items
    if containsWindow(item) then return true end if
  end for
  return false
end function

/// Implements references column at or after for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param minimumIndex Zero-based index of minimum.
function referencesColumnAtOrAfter(expression, minimumIndex)
  if expression is void then return false end if
  if expression is BoundSubquery then return referencesColumnAtOrAfter(expression.operand, minimumIndex) end if
  if expression is BoundExpression then
    if expression.kind == BOUND_COLUMN then return expression.columnIndex >= minimumIndex end if
    if expression.kind == BOUND_UNARY or expression.kind == BOUND_IS_NULL then return referencesColumnAtOrAfter(expression.left, minimumIndex) end if
    if expression.kind == BOUND_BINARY then return referencesColumnAtOrAfter(expression.left, minimumIndex) or referencesColumnAtOrAfter(expression.right, minimumIndex) end if
    return false
  end if
  if expression is BoundAggregate then
    if expression.countStar then return false end if
    if referencesColumnAtOrAfter(expression.argument, minimumIndex) then return true end if
    return expression.separator is not void and referencesColumnAtOrAfter(expression.separator, minimumIndex)
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

/// Returns whether the supplied value satisfies the aggregate condition.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param expression expression value consumed by this operation.
function containsAggregate(expression)
  if expression is BoundWindow then return false end if
  if expression is BoundSubquery then return false end if
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

/// Implements same binding for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function sameBinding(left, right)
  if left is BoundSubquery or right is BoundSubquery then return false end if
  if left is BoundAggregate or right is BoundAggregate then
    if left is not BoundAggregate or right is not BoundAggregate then return false end if
    if left.name != right.name or left.distinct != right.distinct or left.countStar != right.countStar then return false end if
    if left.countStar then return true end if
    if not sameBinding(left.argument, right.argument) then return false end if
    if left.separator is void or right.separator is void then return left.separator is void and right.separator is void end if
    return sameBinding(left.separator, right.separator)
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

/// Implements row context for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param rowValues rowValues value consumed by this operation.
function rowContext(rowValues)
  if typeof(rowValues) != "array" then return fail(INVALID_ARGUMENT, "rowContext", "values must be array") end if
  for each value in rowValues
    if not values.isSqlValue(value) then return fail(INVALID_ARGUMENT, "rowContext", "row contains non-SqlValue") end if
  end for
  return RowContext(rowValues)
end function

/// Implements numeric result for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
/// @param operator operator value consumed by this operation.
/// @param resultType resultType value consumed by this operation.
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

/// Implements comparison result for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
/// @param operator operator value consumed by this operation.
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

/// Implements like result for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function likeResult(left, right)
  if left.isNull or right.isNull then return values.nullValue(types.SqlTypeKind.Boolean) end if
  if typeof(left.value) != "string" or typeof(right.value) != "string" then return fail(TYPE_MISMATCH, "likeResult", "LIKE requires text operands") end if
  textBytes = bytes(left.value)
  patternBytes = bytes(right.value)
  wildcardCount = 0
  underscore = false
  for each patternByte in patternBytes
    if patternByte == 37 then wildcardCount = wildcardCount + 1 end if
    if patternByte == 95 then underscore = true end if
  end for
  // The compiler's std.bytes searches dispatch to SSE2/AVX2. Common literal,
  // prefix, suffix, and contains shapes therefore avoid the general matcher.
  if not underscore and wildcardCount == 0 then return values.boolean(bytes_api.equals(textBytes, patternBytes)) end if
  if not underscore and wildcardCount == 1 and len(patternBytes) > 0 then
    if patternBytes[0] == 37 then return values.boolean(bytes_api.endsWith(textBytes, slice(patternBytes, 1, len(patternBytes) - 1))) end if
    if patternBytes[len(patternBytes) - 1] == 37 then return values.boolean(bytes_api.startsWith(textBytes, slice(patternBytes, 0, len(patternBytes) - 1))) end if
  end if
  if not underscore and wildcardCount == 2 and len(patternBytes) >= 2 and patternBytes[0] == 37 and patternBytes[len(patternBytes) - 1] == 37 then
    needle = slice(patternBytes, 1, len(patternBytes) - 2)
    return values.boolean(bytes_api.indexOf(textBytes, needle, 0) >= 0)
  end if
  // Greedy wildcard matching uses constant memory and cannot exhaust the call
  // stack. It replaces the former recursive backtracking and its 4096-byte cap.
  textIndex = 0
  patternIndex = 0
  starPattern = -1
  starText = -1
  while textIndex < len(textBytes)
    if patternIndex < len(patternBytes) and (patternBytes[patternIndex] == 95 or patternBytes[patternIndex] == textBytes[textIndex]) then
      textIndex = textIndex + 1
      patternIndex = patternIndex + 1
    else if patternIndex < len(patternBytes) and patternBytes[patternIndex] == 37 then
      starPattern = patternIndex
      patternIndex = patternIndex + 1
      starText = textIndex
    else if starPattern >= 0 then
      patternIndex = starPattern + 1
      starText = starText + 1
      textIndex = starText
    else
      return values.boolean(false)
    end if
  end while
  while patternIndex < len(patternBytes) and patternBytes[patternIndex] == 37
    patternIndex = patternIndex + 1
  end while
  return values.boolean(patternIndex == len(patternBytes))
end function

/// Evaluates case using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function evaluateCase(expression, context)
  for each branch in expression.branches
    condition = evaluate(branch.condition, context)
    if values.truth(condition) == 1 then return values.convert(evaluate(branch.result, context), expression.typeInfo) end if
  end for
  if expression.elseExpression is void then return values.nullValue(expression.typeInfo.kind) end if
  return values.convert(evaluate(expression.elseExpression, context), expression.typeInfo)
end function

/// Applies ASCII case conversion while preserving every non-ASCII UTF-8 byte.
/// @param value Value consumed or transformed by the operation.
/// @param upper upper value consumed by this operation.
function asciiCase(value, upper)
  raw = bytes(value)
  output = bytes(len(raw))
  if len(raw) > 0 then
    for index = 0 to len(raw) - 1
      code = raw[index]
      if upper and code >= 97 and code <= 122 then code = code - 32 end if
      if not upper and code >= 65 and code <= 90 then code = code + 32 end if
      output[index] = code
    end for
  end if
  return decode(output)
end function

/// Counts Unicode scalar starts in validated UTF-8 text.
/// @param raw raw value consumed by this operation.
function utf8CharacterCount(raw)
  count = 0
  for each value in raw
    if (value & 0xC0) != 0x80 then count = count + 1 end if
  end for
  return count
end function

/// Maps a zero-based Unicode character index to a UTF-8 byte offset.
/// @param raw raw value consumed by this operation.
/// @param characterIndex Zero-based index of character.
function utf8ByteOffset(raw, characterIndex)
  if characterIndex <= 0 then return 0 end if
  seen = 0
  for index = 0 to len(raw) - 1
    if (raw[index] & 0xC0) != 0x80 then
      if seen == characterIndex then return index end if
      seen = seen + 1
    end if
  end for
  return len(raw)
end function

/// Returns whether `needle` occurs in `source` at the supplied byte offset.
/// @param source source value consumed by this operation.
/// @param needle needle value consumed by this operation.
/// @param offset Zero-based offset at which processing starts.
function bytesMatchAt(source, needle, offset)
  if len(needle) == 0 or offset < 0 or offset > len(source) - len(needle) then return false end if
  for index = 0 to len(needle) - 1
    if source[offset + index] != needle[index] then return false end if
  end for
  return true
end function

/// Replaces all non-overlapping UTF-8 byte sequences without changing unaffected bytes.
/// @param sourceText sourceText value consumed by this operation.
/// @param searchText searchText value consumed by this operation.
/// @param replacementText replacementText value consumed by this operation.
function replaceText(sourceText, searchText, replacementText)
  source = bytes(sourceText)
  search = bytes(searchText)
  if len(search) == 0 then return sourceText end if
  replacement = bytes(replacementText)
  matchCount = 0
  index = 0
  while index < len(source)
    if bytesMatchAt(source, search, index) then
      matchCount = matchCount + 1
      index = index + len(search)
    else
      index = index + 1
    end if
  end while
  output = bytes(len(source) + matchCount * (len(replacement) - len(search)))
  sourceIndex = 0
  outputIndex = 0
  while sourceIndex < len(source)
    if bytesMatchAt(source, search, sourceIndex) then
      if len(replacement) > 0 then
        for replacementIndex = 0 to len(replacement) - 1
          output[outputIndex] = replacement[replacementIndex]
          outputIndex = outputIndex + 1
        end for
      end if
      sourceIndex = sourceIndex + len(search)
    else
      output[outputIndex] = source[sourceIndex]
      sourceIndex = sourceIndex + 1
      outputIndex = outputIndex + 1
    end if
  end while
  return decode(output)
end function

/// Computes exact floor division for native integers.
/// @param left left value consumed by this operation.
/// @param right right value consumed by this operation.
function integerDivide(left, right)
  remainder = left % right
  quotient = (left - remainder) / right
  if remainder != 0 and ((remainder < 0 and right > 0) or (remainder > 0 and right < 0)) then quotient = quotient - 1 end if
  return quotient
end function

/// Converts days since 1970-01-01 to Gregorian year, month and day.
/// @param days days value consumed by this operation.
function civilDateFromEpochDays(days)
  shifted = days + 719468
  eraInput = shifted
  if shifted < 0 then eraInput = shifted - 146096 end if
  era = integerDivide(eraInput, 146097)
  dayOfEra = shifted - era * 146097
  yearOfEra = integerDivide(dayOfEra - integerDivide(dayOfEra, 1460) + integerDivide(dayOfEra, 36524) - integerDivide(dayOfEra, 146096), 365)
  year = yearOfEra + era * 400
  dayOfYear = dayOfEra - (365 * yearOfEra + integerDivide(yearOfEra, 4) - integerDivide(yearOfEra, 100))
  monthPrime = integerDivide(5 * dayOfYear + 2, 153)
  day = dayOfYear - integerDivide(153 * monthPrime + 2, 5) + 1
  month = monthPrime + 3
  if monthPrime >= 10 then month = monthPrime - 9 end if
  if month <= 2 then year = year + 1 end if
  return [year, month, day]
end function

/// Returns the absolute value while preserving full-width signed integer semantics.
/// @param value Value consumed or transformed by the operation.
function absoluteValue(value)
  if value.isNull then return values.nullValue(value.typeKind) end if
  if endian.isInt64Words(value.value) then
    words = value.value
    if not endian.int64IsNegative(words) then return value end if
    if words.high == 2147483648 and words.low == 0 then return fail(TYPE_MISMATCH, "absoluteValue", "ABS overflows signed 64-bit minimum") end if
    low = endian.MAX_U32 - words.low + 1
    carry = 0
    if low > endian.MAX_U32 then low = 0; carry = 1 end if
    high = endian.MAX_U32 - words.high + carry
    return values.of(value.typeKind, endian.makeInt64(high, low))
  end if
  number = values.asNumber(value)
  if number < 0 then number = 0 - number end if
  return values.of(value.typeKind, number)
end function

/// Evaluates a scalar after its arguments have already been evaluated.
/// This entry point is also used by grouped expressions containing aggregates.
/// @param expression expression value consumed by this operation.
/// @param arguments arguments value consumed by this operation.
function evaluateScalarValues(expression, arguments)
  name = expression.name
  if name != "COALESCE" then
    for each argument in arguments
      if argument.isNull then return values.nullValue(expression.typeInfo.kind) end if
    end for
  end if
  if name == "COALESCE" then
    for each argument in arguments
      if not argument.isNull then return values.convert(argument, expression.typeInfo) end if
    end for
    return values.nullValue(expression.typeInfo.kind)
  end if
  if name == "NULLIF" then
    left = arguments[0]
    if left.isNull then return values.nullValue(expression.typeInfo.kind) end if
    right = arguments[1]
    if not right.isNull and values.compareNonNull(left, right) == 0 then return values.nullValue(expression.typeInfo.kind) end if
    return values.convert(left, expression.typeInfo)
  end if
  if name == "LOWER" then return values.text(asciiCase(arguments[0].value, false)) end if
  if name == "UPPER" then return values.text(asciiCase(arguments[0].value, true)) end if
  if name == "LENGTH" or name == "CHAR_LENGTH" then return values.integer(utf8CharacterCount(bytes(arguments[0].value))) end if
  if name == "TRIM" then
    raw = bytes(arguments[0].value)
    start = 0
    finish = len(raw)
    while start < finish and raw[start] == 32
      start = start + 1
    end while
    while finish > start and raw[finish - 1] == 32
      finish = finish - 1
    end while
    return values.text(decode(slice(raw, start, finish - start)))
  end if
  if name == "SUBSTRING" then
    start = values.asNumber(arguments[1])
    if typeof(start) != "int" or start < 1 then return fail(INVALID_ARGUMENT, "evaluateScalarValues", "SUBSTRING start must be at least one") end if
    raw = bytes(arguments[0].value)
    startOffset = utf8ByteOffset(raw, start - 1)
    endOffset = len(raw)
    if len(arguments) == 3 then
      count = values.asNumber(arguments[2])
      if typeof(count) != "int" or count < 0 then return fail(INVALID_ARGUMENT, "evaluateScalarValues", "SUBSTRING length must be non-negative") end if
      endOffset = utf8ByteOffset(raw, start - 1 + count)
    end if
    return values.text(decode(slice(raw, startOffset, endOffset - startOffset)))
  end if
  if name == "REPLACE" then return values.text(replaceText(arguments[0].value, arguments[1].value, arguments[2].value)) end if
  if name == "CONCAT" then
    outputSize = 0
    for each argument in arguments
      outputSize = outputSize + len(bytes(argument.value))
    end for
    output = bytes(outputSize)
    outputOffset = 0
    for each argument in arguments
      raw = bytes(argument.value)
      if len(raw) > 0 then
        for byteIndex = 0 to len(raw) - 1
          output[outputOffset] = raw[byteIndex]
          outputOffset = outputOffset + 1
        end for
      end if
    end for
    return values.text(decode(output))
  end if
  if name == "ABS" then return values.convert(absoluteValue(arguments[0]), expression.typeInfo) end if
  if name == "ROUND" or name == "CEIL" or name == "FLOOR" then
    if types.isIntegralKind(arguments[0].typeKind) then return arguments[0] end if
    number = values.asNumber(arguments[0])
    rounded = math.round(number)
    if name == "CEIL" then rounded = math.ceil(number) end if
    if name == "FLOOR" then rounded = math.floor(number) end if
    return values.convert(values.doubleValue(rounded + 0.0), expression.typeInfo)
  end if
  if name == "POWER" then
    powered = math.pow(values.asNumber(arguments[0]), values.asNumber(arguments[1]))
    if powered is void then return fail(TYPE_MISMATCH, "evaluateScalarValues", "POWER domain is undefined") end if
    return values.doubleValue(powered)
  end if
  if name == "DATE_PART" then
    part = asciiCase(arguments[0].value, true)
    temporal = arguments[1]
    rawValue = values.asNumber(temporal)
    days = rawValue
    microsOfDay = 0
    if temporal.typeKind == types.SqlTypeKind.Timestamp then
      days = integerDivide(rawValue, 86400000000)
      microsOfDay = rawValue - days * 86400000000
    else if temporal.typeKind == types.SqlTypeKind.Time then
      days = 0
      microsOfDay = rawValue
    end if
    if part == "HOUR" then return values.integer(integerDivide(microsOfDay, 3600000000)) end if
    if part == "MINUTE" then return values.integer(integerDivide(microsOfDay % 3600000000, 60000000)) end if
    if part == "SECOND" then return values.integer(integerDivide(microsOfDay % 60000000, 1000000)) end if
    if temporal.typeKind == types.SqlTypeKind.Time then return fail(TYPE_MISMATCH, "evaluateScalarValues", "TIME supports HOUR, MINUTE and SECOND parts") end if
    civil = civilDateFromEpochDays(days)
    if part == "YEAR" then return values.integer(civil[0]) end if
    if part == "MONTH" then return values.integer(civil[1]) end if
    if part == "DAY" then return values.integer(civil[2]) end if
    return fail(INVALID_ARGUMENT, "evaluateScalarValues", "unsupported DATE_PART field " + part)
  end if
  return fail(BINDING_ERROR, "evaluateScalarValues", "unknown scalar function " + name)
end function

/// Evaluates scalar using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function evaluateScalar(expression, context)
  if expression.name == "COALESCE" then
    for each argument in expression.arguments
      value = evaluate(argument, context)
      if not value.isNull then return values.convert(value, expression.typeInfo) end if
    end for
    return values.nullValue(expression.typeInfo.kind)
  end if
  arguments = []
  for each argument in expression.arguments
    arguments = arguments + [evaluate(argument, context)]
  end for
  return evaluateScalarValues(expression, arguments)
end function

/// Evaluates in using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
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

/// Evaluates between using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function evaluateBetween(expression, context)
  operand = evaluate(expression.operand, context)
  lower = evaluate(expression.lower, context)
  upper = evaluate(expression.upper, context)
  result = values.logicalAnd(comparisonResult(operand, lower, ">="), comparisonResult(operand, upper, "<="))
  if expression.negated then result = values.logicalNot(result) end if
  return result
end function

/// Evaluates truth test using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function evaluateTruthTest(expression, context)
  truthValue = values.truth(evaluate(expression.operand, context))
  result = false
  if expression.expected == "TRUE" then result = truthValue == 1 end if
  if expression.expected == "FALSE" then result = truthValue == 0 end if
  if expression.expected == "UNKNOWN" then result = truthValue < 0 end if
  if expression.negated then result = not result end if
  return values.boolean(result)
end function

/// Evaluates evaluate using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function evaluate(expression, context)
  if not isBoundExpression(expression) then return fail(INVALID_ARGUMENT, "evaluate", "expression must be bound") end if
  if expression is BoundAggregate then return fail(BINDING_ERROR, "evaluate", "aggregate requires a group context") end if
  if expression is BoundSubquery then return fail(BINDING_ERROR, "evaluate", "subquery must be materialized by the executor") end if
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

/// Implements predicate passes for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function predicatePasses(expression, context)
  if expression is void then return true end if
  result = evaluate(expression, context)
  truthValue = values.truth(result)
  return truthValue == 1
end function

/// Checks passes using the supplied inputs.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param expression expression value consumed by this operation.
/// @param context Context that carries state for the operation.
function checkPasses(expression, context)
  // SQL CHECK constraints reject FALSE; TRUE and UNKNOWN both satisfy them.
  if expression is void then return true end if
  result = evaluate(expression, context)
  return values.truth(result) != 0
end function

/// Performs the componentName operation for the minisql sql expressions module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "sql.expressions"
end function

/// Performs the targetMilestone operation for the minisql sql expressions module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M13"
end function

/// Returns whether implemented satisfies the condition required by the minisql sql expressions module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
