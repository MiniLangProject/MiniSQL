package minisql.planner.rewrites

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

import minisql.sql.ast as ast
import minisql.sql.expressions as expressions
import minisql.sql.types as types
import minisql.sql.values as values

// Safe, semantics-preserving planner rewrites and selectivity helpers. Literal
// folding follows evaluator short-circuit order, while predicate pushdown is
// restricted to deterministic source-local expressions and safe join shapes.

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
  if not expressions.isBaseBoundExpression(expression) then return false end if
  if expression.kind != expressions.BOUND_BINARY or expression.operator != "=" then return false end if
  if expressions.isBoundAggregate(expression.left) or expressions.isBoundAggregate(expression.right) then return false end if
  return expression.left.kind == expressions.BOUND_COLUMN and expression.right.kind == expressions.BOUND_COLUMN
end function

// Returns whether the supplied value satisfies the constant boolean condition.
// Requires arguments that satisfy the validation performed below.
// Returns the computed value or operation status.
// Does not modify its inputs.
function isConstantBoolean(expression, expected)
  if not expressions.isBaseBoundExpression(expression) then return false end if
  if expression.kind != expressions.BOUND_LITERAL or expression.literal.isNull or typeof(expression.literal.value) != "bool" then return false end if
  return expression.literal.value == expected
end function

// Implements selectivity permille for this module.
// Returns the computed value or operation status.
// Any side effects are limited to the explicitly invoked dependencies.
function selectivityPermille(expression)
  if expression is void then return 1000 end if
  if not expressions.isBaseBoundExpression(expression) then return 500 end if
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

// Folds deterministic literal-only base expressions and left-hand boolean
// identities. Restricting identities to the evaluator's short-circuit side
// preserves the observable behavior of volatile scalar functions.
function simplify(expression)
  if expression is void or not expressions.isBaseBoundExpression(expression) then return expression end if
  if expression.kind == expressions.BOUND_LITERAL or expression.kind == expressions.BOUND_COLUMN then return expression end if
  if expression.kind == expressions.BOUND_UNARY then
    operand = simplify(expression.left)
    rewritten = expressions.unary(expression.operator, operand, expression.typeInfo)
    if operand.kind == expressions.BOUND_LITERAL then return expressions.literal(expressions.evaluate(rewritten, expressions.rowContext([])), expression.typeInfo) end if
    return rewritten
  end if
  if expression.kind == expressions.BOUND_IS_NULL then
    operand = simplify(expression.left)
    rewritten = expressions.isNull(operand, expression.operator == "IS NOT NULL")
    if operand.kind == expressions.BOUND_LITERAL then return expressions.literal(expressions.evaluate(rewritten, expressions.rowContext([])), expression.typeInfo) end if
    return rewritten
  end if
  if expression.kind == expressions.BOUND_BINARY then
    left = simplify(expression.left)
    // Honor the evaluator's left-to-right short-circuit contract before
    // touching the right operand. Besides matching SQL semantics, this avoids
    // raising a folded error from an unreachable expression such as
    // FALSE AND (1 / 0 = 1).
    if left.kind == expressions.BOUND_LITERAL then
      if expression.operator == "AND" then
        leftTruth = values.truth(left.literal)
        if leftTruth == 0 then return left end if
      else if expression.operator == "OR" then
        leftTruth = values.truth(left.literal)
        if leftTruth == 1 then return left end if
      end if
    end if
    right = simplify(expression.right)
    if left.kind == expressions.BOUND_LITERAL then
      if expression.operator == "AND" and values.truth(left.literal) == 1 then return right end if
      if expression.operator == "OR" and values.truth(left.literal) == 0 then return right end if
    end if
    rewritten = expressions.binary(expression.operator, left, right, expression.typeInfo)
    if left.kind == expressions.BOUND_LITERAL and right.kind == expressions.BOUND_LITERAL then return expressions.literal(expressions.evaluate(rewritten, expressions.rowContext([])), expression.typeInfo) end if
    return rewritten
  end if
  return expression
end function

// Collects every bound column index referenced by an expression. Returning
// false for an unknown expression shape deliberately disables pushdown rather
// than risking a semantic change when the SQL surface grows.
function collectColumnIndexes(expression, indexes)
  if expression is void then return indexes end if
  if not expressions.isBoundExpression(expression) then return false end if
  if expressions.isBoundAggregate(expression) then
    if expression.countStar then return indexes end if
    current = collectColumnIndexes(expression.argument, indexes)
    if typeof(current) == "bool" and not current then return false end if
    return collectColumnIndexes(expression.separator, current)
  end if
  if expressions.isBaseBoundExpression(expression) then
    if expression.kind == expressions.BOUND_LITERAL then return indexes end if
    if expression.kind == expressions.BOUND_COLUMN then indexes = indexes + [expression.columnIndex]; return indexes end if
    if expression.kind == expressions.BOUND_UNARY or expression.kind == expressions.BOUND_IS_NULL then return collectColumnIndexes(expression.left, indexes) end if
    if expression.kind == expressions.BOUND_BINARY then
      left = collectColumnIndexes(expression.left, indexes)
      if typeof(left) == "bool" and not left then return false end if
      return collectColumnIndexes(expression.right, left)
    end if
    return false
  end if
  if expressions.isBoundCase(expression) then
    current = indexes
    for each branch in expression.branches
      current = collectColumnIndexes(branch.condition, current)
      if typeof(current) == "bool" and not current then return false end if
      current = collectColumnIndexes(branch.result, current)
      if typeof(current) == "bool" and not current then return false end if
    end for
    return collectColumnIndexes(expression.elseExpression, current)
  end if
  if expressions.isBoundCast(expression) then return collectColumnIndexes(expression.operand, indexes) end if
  if expressions.isBoundScalar(expression) then
    current = indexes
    for each argument in expression.arguments
      current = collectColumnIndexes(argument, current)
      if typeof(current) == "bool" and not current then return false end if
    end for
    return current
  end if
  if expressions.isBoundIn(expression) then
    current = collectColumnIndexes(expression.operand, indexes)
    if typeof(current) == "bool" and not current then return false end if
    for each candidate in expression.candidates
      current = collectColumnIndexes(candidate, current)
      if typeof(current) == "bool" and not current then return false end if
    end for
    return current
  end if
  if expressions.isBoundBetween(expression) then
    current = collectColumnIndexes(expression.operand, indexes)
    if typeof(current) == "bool" and not current then return false end if
    current = collectColumnIndexes(expression.lower, current)
    if typeof(current) == "bool" and not current then return false end if
    return collectColumnIndexes(expression.upper, current)
  end if
  if expressions.isBoundTruthTest(expression) then return collectColumnIndexes(expression.operand, indexes) end if
  // Subqueries and windows own nested bindings and remain above the join.
  return false
end function

// Maps an expression to its sole source, -1 for a constant, or -2 when the
// expression spans sources or cannot be analyzed safely.
function singleSource(expression, sources)
  indexes = collectColumnIndexes(expression, [])
  if typeof(indexes) == "bool" then return -2 end if
  if len(indexes) == 0 then return -1 end if
  selected = -2
  for each columnIndex in indexes
    current = -2
    if len(sources) > 0 then
      for sourceIndex = 0 to len(sources) - 1
        source = sources[sourceIndex]
        if columnIndex >= source.offset and columnIndex < source.offset + len(source.table.columns) then current = sourceIndex; break end if
      end for
    end if
    if current < 0 then return -2 end if
    if selected == -2 then selected = current else if selected != current then return -2 end if
  end for
  return selected
end function

// Reports whether an integer array contains the requested value.
function intContains(items, value)
  for each item in items
    if item == value then return true end if
  end for
  return false
end function

// Returns the unique source indexes referenced by an expression, or void when
// a newly introduced expression shape cannot be analyzed conservatively.
function referencedSources(expression, sources)
  indexes = collectColumnIndexes(expression, [])
  if typeof(indexes) == "bool" then return void end if
  output = []
  for each columnIndex in indexes
    sourceIndex = -1
    if len(sources) > 0 then
      for index = 0 to len(sources) - 1
        source = sources[index]
        if columnIndex >= source.offset and columnIndex < source.offset + len(source.table.columns) then sourceIndex = index; break end if
      end for
    end if
    if sourceIndex < 0 then return void end if
    if not intContains(output, sourceIndex) then output = output + [sourceIndex] end if
  end for
  return output
end function

// Flattens an AND tree without changing the relative order of predicates.
function conjuncts(expression)
  if expression is void then return [] end if
  if expressions.isBaseBoundExpression(expression) and expression.kind == expressions.BOUND_BINARY and expression.operator == "AND" then return conjuncts(expression.left) + conjuncts(expression.right) end if
  return [expression]
end function

// Normalizes a column/literal comparison so the column is always on the left.
function comparisonConstraint(expression)
  if not expressions.isBaseBoundExpression(expression) or expression.kind != expressions.BOUND_BINARY then return void end if
  operator = expression.operator
  if operator != "=" and operator != "<" and operator != "<=" and operator != ">" and operator != ">=" then return void end if
  column = expression.left
  literal = expression.right
  if column.kind == expressions.BOUND_LITERAL and literal.kind == expressions.BOUND_COLUMN then
    column = expression.right
    literal = expression.left
    if operator == "<" then operator = ">" else if operator == "<=" then operator = ">=" else if operator == ">" then operator = "<" else if operator == ">=" then operator = "<=" end if
  end if
  if column.kind != expressions.BOUND_COLUMN or literal.kind != expressions.BOUND_LITERAL or literal.literal.isNull then return void end if
  return [column.columnIndex, operator, literal.literal]
end function

// Proves implication between two normalized single-column literal bounds.
function comparisonImplies(candidate, required)
  candidateBound = comparisonConstraint(candidate)
  requiredBound = comparisonConstraint(required)
  if candidateBound is void or requiredBound is void or candidateBound[0] != requiredBound[0] then return false end if
  candidateOperator = candidateBound[1]
  requiredOperator = requiredBound[1]
  // IEEE NaN does not provide the total ordering required by this proof.
  if candidateBound[2].typeKind == types.SqlTypeKind.Real or candidateBound[2].typeKind == types.SqlTypeKind.Double or requiredBound[2].typeKind == types.SqlTypeKind.Real or requiredBound[2].typeKind == types.SqlTypeKind.Double then return false end if
  comparison = values.compareNonNull(candidateBound[2], requiredBound[2])
  if typeof(comparison) != "int" then return false end if
  if candidateOperator == "=" then
    if requiredOperator == "=" then return comparison == 0 end if
    if requiredOperator == ">" then return comparison > 0 end if
    if requiredOperator == ">=" then return comparison >= 0 end if
    if requiredOperator == "<" then return comparison < 0 end if
    if requiredOperator == "<=" then return comparison <= 0 end if
  end if
  if candidateOperator == ">" or candidateOperator == ">=" then
    if requiredOperator != ">" and requiredOperator != ">=" then return false end if
    return comparison > 0 or (comparison == 0 and (candidateOperator == ">" or requiredOperator == ">="))
  end if
  if candidateOperator == "<" or candidateOperator == "<=" then
    if requiredOperator != "<" and requiredOperator != "<=" then return false end if
    return comparison < 0 or (comparison == 0 and (candidateOperator == "<" or requiredOperator == "<="))
  end if
  return false
end function

// Proves one required conjunct from one query conjunct without widening either.
function conjunctImplies(candidate, required)
  if expressions.sameBinding(candidate, required) then return true end if
  if comparisonImplies(candidate, required) then return true end if
  if expressions.isBaseBoundExpression(required) and required.kind == expressions.BOUND_IS_NULL and required.operator == "IS NOT NULL" and expressions.isBaseBoundExpression(required.left) and required.left.kind == expressions.BOUND_COLUMN then
    candidateBound = comparisonConstraint(candidate)
    return candidateBound is not void and candidateBound[0] == required.left.columnIndex
  end if
  return false
end function

// Proves the deliberately bounded partial-index implication contract. Every
// required index conjunct must occur identically or follow from a stronger
// typed single-column literal bound in the query predicate. This recognizes
// additional/reordered conjuncts without general Boolean theorem proving.
function predicateImplies(queryPredicate, requiredPredicate)
  if requiredPredicate is void then return true end if
  if queryPredicate is void then return false end if
  queryConjuncts = conjuncts(queryPredicate)
  for each required in conjuncts(requiredPredicate)
    matched = false
    for each candidate in queryConjuncts
      if conjunctImplies(candidate, required) then matched = true; break end if
    end for
    if not matched then return false end if
  end for
  return true
end function

// Reassembles predicates with SQL boolean semantics intact.
function combineConjuncts(items)
  if len(items) == 0 then return void end if
  output = items[0]
  if len(items) > 1 then
    for index = 1 to len(items) - 1
      output = expressions.binary("AND", output, items[index], output.typeInfo)
    end for
  end if
  return output
end function

// Predicate pushdown must not duplicate observable evaluation of volatile
// scalar functions or nested query expressions. The initial rewrite surface is
// therefore intentionally restricted to deterministic base predicates.
function pushdownSafe(expression)
  if expression is void or not expressions.isBaseBoundExpression(expression) then return false end if
  if expression.kind == expressions.BOUND_LITERAL or expression.kind == expressions.BOUND_COLUMN then return true end if
  if expression.kind == expressions.BOUND_UNARY or expression.kind == expressions.BOUND_IS_NULL then return pushdownSafe(expression.left) end if
  if expression.kind == expressions.BOUND_BINARY then return pushdownSafe(expression.left) and pushdownSafe(expression.right) end if
  return false
end function

// Returns one safe per-source predicate. Pushdown is initially limited to
// inner/cross join trees; outer-join NULL extension requires a dedicated
// null-rejection proof and therefore keeps the original WHERE placement.
function sourcePredicates(whereExpression, sources, joins)
  output = array(len(sources), void)
  for each joined in joins
    if joined.joinType != ast.JOIN_INNER and joined.joinType != ast.JOIN_CROSS then return output end if
  end for
  buckets = array(len(sources), void)
  for each predicate in conjuncts(whereExpression)
    sourceIndex = singleSource(predicate, sources)
    if sourceIndex >= 0 and pushdownSafe(predicate) then
      bucket = buckets[sourceIndex]
      if bucket is void then bucket = [] end if
      bucket = bucket + [predicate]
      buckets[sourceIndex] = bucket
    end if
  end for
  if len(sources) > 0 then
    for sourceIndex = 0 to len(sources) - 1
      if buckets[sourceIndex] is not void then output[sourceIndex] = combineConjuncts(buckets[sourceIndex]) end if
    end for
  end if
  return output
end function

// Returns the WHERE conjuncts that could not be assigned to a safe source
// pushdown. The executor still evaluates the complete simplified WHERE as a
// correctness guard; this residual is used for cardinality and cost only.
function residualPredicate(whereExpression, sources, joins)
  for each joined in joins
    if joined.joinType != ast.JOIN_INNER and joined.joinType != ast.JOIN_CROSS then return whereExpression end if
  end for
  residual = []
  for each predicate in conjuncts(whereExpression)
    if singleSource(predicate, sources) < 0 or not pushdownSafe(predicate) then residual = residual + [predicate] end if
  end for
  return combineConjuncts(residual)
end function

// Recognizes a literal WHERE that can never pass SQL's three-valued predicate
// test. It is safe to replace the source with an empty relation even for a
// global aggregate, whose aggregate operator will still emit its empty-group
// result.
function constantWhereEmpty(expression)
  if expression is void or not expressions.isBaseBoundExpression(expression) or expression.kind != expressions.BOUND_LITERAL then return false end if
  return values.truth(expression.literal) != 1
end function

// Finds a column/literal comparison inside a conjunction. The returned tuple
// is [found, normalized operator, literal].
function comparisonForColumn(expression, columnIndex)
  if expression is void or not expressions.isBaseBoundExpression(expression) then return [false, "", void] end if
  if expression.kind != expressions.BOUND_BINARY then return [false, "", void] end if
  if expression.operator == "AND" then
    left = comparisonForColumn(expression.left, columnIndex)
    if left[0] then return left end if
    return comparisonForColumn(expression.right, columnIndex)
  end if
  operator = expression.operator
  if expression.left.kind == expressions.BOUND_COLUMN and expression.left.columnIndex == columnIndex and expression.right.kind == expressions.BOUND_LITERAL then return [true, operator, expression.right.literal] end if
  if expression.right.kind == expressions.BOUND_COLUMN and expression.right.columnIndex == columnIndex and expression.left.kind == expressions.BOUND_LITERAL then
    if operator == "<" then operator = ">" else if operator == "<=" then operator = ">=" else if operator == ">" then operator = "<" else if operator == ">=" then operator = "<=" end if
    return [true, operator, expression.left.literal]
  end if
  return [false, "", void]
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
