package minisql.planner.rewrites

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

import minisql.sql.expressions as expressions
import minisql.sql.values as values

// Safe, semantics-preserving planner helpers. M17 does not rewrite SQL in ways
// that could change NULL behavior; it performs conservative selectivity
// estimation and recognizes equality predicates for costing.

const INVALID_ARGUMENT = 9001

// Creates a structured error for fail using the supplied inputs.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function fail(code, operation, message)
  return error(code, "planner.rewrites." + operation + ": " + message)
end function

// Implements integer divide for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function integerDivide(numerator, denominator)
  if typeof(numerator) != "int" or typeof(denominator) != "int" or numerator < 0 or denominator <= 0 then return fail(INVALID_ARGUMENT, "integerDivide", "invalid arguments") end if
  quotient = 0
  remainder = numerator
  scale = denominator
  bit = 1
  while scale <= remainder and scale <= (endian.MAX_MINILANG_INT >> 1)
    scale = scale << 1
    bit = bit << 1
  end while
  while bit > 0
    if scale <= remainder then remainder = remainder - scale; quotient = quotient + bit end if
    scale = scale >> 1
    bit = bit >> 1
  end while
  return quotient
end function

// Implements clamp rows for this module.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function clampRows(value)
  if typeof(value) != "int" then return fail(INVALID_ARGUMENT, "clampRows", "value must be int") end if
  if value < 0 then return 0 end if
  return value
end function

// Returns whether the supplied value satisfies the column equality condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isColumnEquality(expression)
  if not expressions.isBoundExpression(expression) or expressions.isBoundAggregate(expression) then return false end if
  if expression.kind != expressions.BOUND_BINARY or expression.operator != "=" then return false end if
  if expressions.isBoundAggregate(expression.left) or expressions.isBoundAggregate(expression.right) then return false end if
  return expression.left.kind == expressions.BOUND_COLUMN and expression.right.kind == expressions.BOUND_COLUMN
end function

// Returns whether the supplied value satisfies the constant boolean condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isConstantBoolean(expression, expected)
  if not expressions.isBoundExpression(expression) or expressions.isBoundAggregate(expression) then return false end if
  if expression.kind != expressions.BOUND_LITERAL or expression.literal.isNull or typeof(expression.literal.value) != "bool" then return false end if
  return expression.literal.value == expected
end function

// Implements selectivity permille for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function selectivityPermille(expression)
  if expression is void then return 1000 end if
  if not expressions.isBoundExpression(expression) or expressions.isBoundAggregate(expression) then return 500 end if
  if isConstantBoolean(expression, true) then return 1000 end if
  if isConstantBoolean(expression, false) then return 0 end if
  if expression.kind == expressions.BOUND_IS_NULL then return 100 end if
  if expression.kind == expressions.BOUND_BINARY then
    if expression.operator == "AND" then return integerDivide(selectivityPermille(expression.left) * selectivityPermille(expression.right), 1000) end if
    if expression.operator == "OR" then
      left = selectivityPermille(expression.left)
      right = selectivityPermille(expression.right)
      combined = left + right - integerDivide(left * right, 1000)
      if combined > 1000 then combined = 1000 end if
      return combined
    end if
    if expression.operator == "=" then return 100 end if
    if expression.operator == "<>" or expression.operator == "!=" then return 900 end if
    if expression.operator == "<" or expression.operator == "<=" or expression.operator == ">" or expression.operator == ">=" then return 333 end if
    if expression.operator == "LIKE" then return 200 end if
  end if
  return 500
end function

// Estimates filtered rows using the supplied inputs.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function estimateFilteredRows(inputRows, predicate)
  inputRows = clampRows(inputRows)
  if inputRows == 0 then return 0 end if
  estimate = integerDivide(inputRows * selectivityPermille(predicate), 1000)
  if estimate == 0 and selectivityPermille(predicate) > 0 then estimate = 1 end if
  return estimate
end function

// Implements component name for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.rewrites"
end function

// Implements target milestone for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M17"
end function

// Returns whether the supplied value satisfies the implemented condition.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isImplemented()
  return true
end function
