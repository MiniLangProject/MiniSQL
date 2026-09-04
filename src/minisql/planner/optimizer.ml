//! Provides minisql planner optimizer facilities for this project.

package minisql.planner.optimizer

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.common.endian as endian

import minisql.catalog.statistics as statistics
import minisql.planner.cost as cost
import minisql.planner.execution_plan as execution_plan
import minisql.planner.physical_plan as physical_plan
import minisql.planner.rewrites as rewrites
import minisql.sql.ast as ast
import minisql.sql.binder as binder
import minisql.sql.expressions as expressions
import minisql.sql.types as types

/// Costed physical-plan builder. It produces both the stable descriptive

const INVALID_ARGUMENT = 9001

/// Reports whether a stable index-name list contains one name.
/// @param items Items consumed or updated by the operation.
/// @param name Name of the affected item.
function indexNameContains(items, name)
  for each item in items
    if item == name then return true end if
  end for
  return false
end function

/// Renders a deterministic comma-separated index-name list for EXPLAIN.
/// @param items Items consumed or updated by the operation.
function indexNameListText(items)
  output = ""
  for each item in items
    if len(output) > 0 then output = output + "," end if
    output = output + item
  end for
  return output
end function

/// Groups the optimized plan state and preserves the field relationships documented below.
struct OptimizedPlan
  /// Stores the root associated with this value.
  root
  /// Stores the used statistics associated with this value.
  usedStatistics
  /// Stores the typed physical decisions consumed by the executor.
  execution
end struct

/// Best known left-deep join prefix for one source subset. The bounded dynamic
/// program stores one state per bit mask and therefore avoids factorial search.
struct JoinOrderState
  /// Bit set for every source already present in the prefix.
  sourceMask
  /// Source that seeds the executable left-deep plan.
  startSource
  /// Bound join predicates in physical attachment order.
  joinIndexes
  /// Source attached by each corresponding join predicate.
  sourceIndexes
  /// Cumulative cost and cardinality of this prefix.
  estimate
end struct

/// Performs the fail operation for the minisql planner optimizer module.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "planner.optimizer." + operation + ": " + message)
end function

/// Implements integer divide for this module.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param numerator numerator value consumed by this operation.
/// @param denominator denominator value consumed by this operation.
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

/// Returns whether the supplied value satisfies the optimized plan condition.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
/// @param value Value consumed or transformed by the operation.
function isOptimizedPlan(value)
  return value is OptimizedPlan
end function

/// Implements table stats for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param state Mutable state inspected or updated by the operation.
/// @param tableId Identifier of table.
function tableStats(state, tableId)
  if state is void then return void end if
  if execution_plan.isPlanningContext(state) then state = state.statistics end if
  if state is void then return void end if
  if not statistics.isStatisticsCatalog(state) then return fail(INVALID_ARGUMENT, "tableStats", "statistics must be catalog or void") end if
  return statistics.findTable(state, tableId)
end function

/// Returns index metadata from a rich planning context. Legacy callers that pass
/// only StatisticsCatalog retain sequential scans and remain source-compatible.
/// @param state Mutable state inspected or updated by the operation.
/// @param tableId Identifier of table.
function tableIndexes(state, tableId)
  if not execution_plan.isPlanningContext(state) then return [] end if
  return execution_plan.indexesForTable(state, tableId)
end function

/// Finds persisted column statistics by local table-column index.
/// @param found found value consumed by this operation.
/// @param columnIndex Zero-based index of column.
function columnStats(found, columnIndex)
  if found is void then return void end if
  for each column in found.columns
    if column.columnIndex == columnIndex then return column end if
  end for
  return void
end function

/// Finds exact ordered joint-column statistics, normally produced for a
/// composite index key by ANALYZE.
/// @param found found value consumed by this operation.
/// @param columnIndexes columnIndexes value consumed by this operation.
function columnGroupStats(found, columnIndexes)
  if found is void or typeof(found.columnGroups) != "array" then return void end if
  for each group in found.columnGroups
    same = len(group.columnIndexes) == len(columnIndexes)
    if same and len(columnIndexes) > 0 then
      for index = 0 to len(columnIndexes) - 1
        if group.columnIndexes[index] != columnIndexes[index] then same = false; break end if
      end for
    end if
    if same then return group end if
  end for
  return void
end function

/// Multiplies a cardinality by a bounded fraction without overflowing the
/// native integer. Dividing the remainder and denominator together only occurs
/// in the exceptional near-limit case and preserves a close conservative ratio.
/// @param value Value consumed or transformed by the operation.
/// @param numerator numerator value consumed by this operation.
/// @param denominator denominator value consumed by this operation.
function scaleFraction(value, numerator, denominator)
  if value == 0 or numerator == 0 then return 0 end if
  if numerator >= denominator then return value end if
  quotient = integerDivide(value, denominator)
  remainder = value - quotient * denominator
  result = quotient * numerator
  scaledDenominator = denominator
  while remainder > integerDivide(endian.MAX_MINILANG_INT, numerator)
    remainder = remainder >> 1
    scaledDenominator = scaledDenominator >> 1
  end while
  if scaledDenominator > 0 then result = result + integerDivide(remainder * numerator, scaledDenominator) end if
  return result
end function

/// Interpolates an inclusive integral boundary within the persisted cumulative
/// histogram and returns a whole-table population estimate.
/// @param current current value consumed by this operation.
/// @param candidate candidate value consumed by this operation.
function histogramLessOrEqual(current, candidate)
  if typeof(current.histogramBounds) != "array" or len(current.histogramBounds) == 0 then return void end if
  if candidate < current.minimumIntegral then return 0 end if
  if candidate >= current.maximumIntegral then return current.histogramCounts[len(current.histogramCounts) - 1] end if
  previousBound = current.minimumIntegral - 1
  previousCount = 0
  for index = 0 to len(current.histogramBounds) - 1
    upperBound = current.histogramBounds[index]
    upperCount = current.histogramCounts[index]
    if candidate <= upperBound then
      width = upperBound - previousBound
      position = candidate - previousBound
      bucketRows = upperCount - previousCount
      return previousCount + scaleFraction(bucketRows, position, width)
    end if
    previousBound = upperBound
    previousCount = upperCount
  end for
  return previousCount
end function

/// Estimates equality from the MCV list and distributes the remaining
/// population uniformly across non-MCV distinct values.
/// @param inputRows inputRows value consumed by this operation.
/// @param tableRows tableRows value consumed by this operation.
/// @param current current value consumed by this operation.
/// @param literal literal value consumed by this operation.
function equalityRows(inputRows, tableRows, current, literal)
  if current is void or literal is void or literal.isNull or tableRows <= 0 then return void end if
  lookupValue = literal.value
  if current.mostCommonHashed then lookupValue = statistics.hashValue(literal) end if
  if typeof(lookupValue) == "int" and typeof(current.mostCommonValues) == "array" then
    for index = 0 to len(current.mostCommonValues) - 1
      if current.mostCommonValues[index] == lookupValue then return scaleFraction(current.mostCommonCounts[index], inputRows, tableRows) end if
    end for
  end if
  if current.distinctCount <= 0 then return void end if
  nonNullRows = tableRows - current.nullCount
  commonRows = 0
  commonDistinct = 0
  if typeof(current.mostCommonCounts) == "array" then
    commonDistinct = len(current.mostCommonCounts)
    for each count in current.mostCommonCounts
      commonRows = commonRows + count
    end for
  end if
  remainingDistinct = current.distinctCount - commonDistinct
  if remainingDistinct <= 0 then return 0 end if
  remainingRows = nonNullRows - commonRows
  if remainingRows < 0 then remainingRows = 0 end if
  estimate = integerDivide(remainingRows, remainingDistinct)
  estimate = scaleFraction(estimate, inputRows, tableRows)
  if estimate == 0 and inputRows > 0 and remainingRows > 0 then estimate = 1 end if
  return estimate
end function

/// Computes the persisted tuple hash used by multi-column MCV statistics.
/// @param literals literals value consumed by this operation.
function tupleHashForLiterals(literals)
  result = 2166136261 & 2147483647
  for each literal in literals
    if literal.isNull then return void end if
    result = ((result ^ statistics.hashValue(literal)) * 16777619) & 2147483647
  end for
  return result
end function

/// Estimates an integral inequality from a cumulative histogram, with a uniform
/// interpolation inside each bucket and a bounds-only fallback for v1-v3 data.
/// @param inputRows inputRows value consumed by this operation.
/// @param tableRows tableRows value consumed by this operation.
/// @param current current value consumed by this operation.
/// @param operator operator value consumed by this operation.
/// @param literal literal value consumed by this operation.
function integralRangeRows(inputRows, tableRows, current, operator, literal)
  if current is void or not current.hasIntegralBounds or literal is void or literal.isNull or typeof(literal.value) != "int" then return void end if
  if tableRows <= 0 then return 0 end if
  nonNullRows = scaleFraction(inputRows, tableRows - current.nullCount, tableRows)
  minimum = current.minimumIntegral
  maximum = current.maximumIntegral
  candidate = literal.value
  histogramEstimate = void
  if operator == "<=" then histogramEstimate = histogramLessOrEqual(current, candidate) end if
  if operator == "<" then histogramEstimate = histogramLessOrEqual(current, candidate - 1) end if
  if operator == ">" then
    lessOrEqual = histogramLessOrEqual(current, candidate)
    if lessOrEqual is not void then histogramEstimate = tableRows - current.nullCount - lessOrEqual end if
  end if
  if operator == ">=" then
    less = histogramLessOrEqual(current, candidate - 1)
    if less is not void then histogramEstimate = tableRows - current.nullCount - less end if
  end if
  if histogramEstimate is not void then
    if histogramEstimate < 0 then histogramEstimate = 0 end if
    return scaleFraction(histogramEstimate, inputRows, tableRows)
  end if
  span = maximum - minimum + 1
  numerator = 0
  if operator == ">=" then
    if candidate <= minimum then return nonNullRows end if
    if candidate > maximum then return 0 end if
    numerator = maximum - candidate + 1
  else if operator == ">" then
    if candidate < minimum then return nonNullRows end if
    if candidate >= maximum then return 0 end if
    numerator = maximum - candidate
  else if operator == "<=" then
    if candidate >= maximum then return nonNullRows end if
    if candidate < minimum then return 0 end if
    numerator = candidate - minimum + 1
  else if operator == "<" then
    if candidate > maximum then return nonNullRows end if
    if candidate <= minimum then return 0 end if
    numerator = candidate - minimum
  else
    return void
  end if
  estimated = scaleFraction(nonNullRows, numerator, span)
  if estimated == 0 and numerator > 0 and nonNullRows > 0 then estimated = 1 end if
  return estimated
end function

/// Selects the widest complete equality group available for a predicate.
/// @param source source value consumed by this operation.
/// @param found found value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
function equalityColumnGroup(source, found, predicate)
  if found is void or typeof(found.columnGroups) != "array" then return void end if
  selected = void
  for each group in found.columnGroups
    complete = true
    for each localIndex in group.columnIndexes
      comparison = rewrites.comparisonForColumn(predicate, source.offset + localIndex)
      if not comparison[0] or comparison[1] != "=" or comparison[2] is void or comparison[2].isNull then complete = false; break end if
    end for
    if complete and group.distinctCount > 0 and (selected is void or len(group.columnIndexes) > len(selected.columnIndexes)) then selected = group end if
  end for
  return selected
end function

/// Estimates a pushed predicate with available NDV statistics, retaining the
/// conservative M17 heuristic for unsupported expression shapes.
/// @param source source value consumed by this operation.
/// @param found found value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
/// @param fallbackRows fallbackRows value consumed by this operation.
function predicateRows(source, found, predicate, fallbackRows)
  if predicate is void then return fallbackRows end if
  if found is void then return rewrites.estimateFilteredRows(fallbackRows, predicate) end if
  output = fallbackRows
  matchedGroup = equalityColumnGroup(source, found, predicate)
  if matchedGroup is not void then
    output = integerDivide(fallbackRows, matchedGroup.distinctCount)
    if output == 0 and fallbackRows > 0 then output = 1 end if
  end if
  for each conjunct in rewrites.conjuncts(predicate)
    estimated = false
    for localIndex = 0 to len(source.table.columns) - 1
      comparison = rewrites.comparisonForColumn(conjunct, source.offset + localIndex)
      if comparison[0] then
        coveredByGroup = false
        if matchedGroup is not void and comparison[1] == "=" then
          for each groupIndex in matchedGroup.columnIndexes
            if groupIndex == localIndex then coveredByGroup = true; break end if
          end for
        end if
        if coveredByGroup then estimated = true; break end if
        if comparison[2] is not void and comparison[2].isNull then return 0 end if
        current = columnStats(found, localIndex)
        if current is not void and comparison[1] == "=" and current.distinctCount > 0 then
          equalityEstimate = equalityRows(output, found.rowCount, current, comparison[2])
          if equalityEstimate is void then equalityEstimate = integerDivide(output, current.distinctCount) end if
          output = equalityEstimate
          if output == 0 and fallbackRows > 0 and comparison[2] is not void and not comparison[2].isNull then output = 1 end if
        else if current is not void then
          ranged = integralRangeRows(output, found.rowCount, current, comparison[1], comparison[2])
          if ranged is void then output = rewrites.estimateFilteredRows(output, conjunct) else output = ranged end if
        else
          output = rewrites.estimateFilteredRows(output, conjunct)
        end if
        estimated = true
        break
      end if
    end for
    if not estimated then output = rewrites.estimateFilteredRows(output, conjunct) end if
  end for
  return output
end function

/// Returns whether every column referenced by one expression belongs to an
/// index key. Global bound indexes are translated into the source-local domain.
/// @param expression expression value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param index Zero-based index of the affected item.
function expressionCoveredByIndex(expression, source, index)
  if expression is void then return true end if
  referenced = rewrites.collectColumnIndexes(expression, [])
  if typeof(referenced) == "bool" then return false end if
  for each boundIndex in referenced
    localIndex = boundIndex - source.offset
    if localIndex < 0 or localIndex >= len(source.table.columns) then return false end if
    covered = false
    for each keyIndex in index.columnIndexes + index.includedColumnIndexes
      if keyIndex == localIndex then covered = true; break end if
    end for
    if not covered then return false end if
  end for
  return true
end function

/// Recognizes a query fully answerable from B+-tree key and INCLUDE payloads.
/// @param bound bound value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param index Zero-based index of the affected item.
/// @param predicate predicate value consumed by this operation.
function indexCoversBound(bound, source, index, predicate)
  if len(bound.sources) != 1 or len(bound.joins) != 0 or source.query is not void or len(bound.setOperations) != 0 or bound.windowQuery then return false end if
  for each columnIndex in index.columnIndexes + index.includedColumnIndexes
    if columnIndex < 0 or columnIndex >= len(source.table.columns) then return false end if
    typeCode = source.table.columns[columnIndex].typeCode
    decodable = typeCode == types.SqlTypeKind.Boolean or types.isIntegralKind(typeCode) or typeCode == types.SqlTypeKind.Decimal or typeCode == types.SqlTypeKind.Date or typeCode == types.SqlTypeKind.Time or typeCode == types.SqlTypeKind.Timestamp or types.isTextKind(typeCode) or types.isBinaryKind(typeCode)
    if not decodable then return false end if
  end for
  if not expressionCoveredByIndex(predicate, source, index) or not expressionCoveredByIndex(bound.havingExpression, source, index) then return false end if
  for each item in bound.items
    if not expressionCoveredByIndex(item, source, index) then return false end if
  end for
  for each item in bound.groupExpressions
    if not expressionCoveredByIndex(item, source, index) then return false end if
  end for
  for each item in bound.orderExpressions
    if not expressionCoveredByIndex(item, source, index) then return false end if
  end for
  return true
end function

/// Chooses the longest usable B+-tree prefix for a source predicate. Equality
/// may consume every index column; a range may consume only the leading column
/// because the current storage integration does not yet expose prefix ranges.
/// @param bound bound value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param found found value consumed by this operation.
/// @param rows rows value consumed by this operation.
/// @param outputRows outputRows value consumed by this operation.
function indexCandidate(bound, source, predicate, state, found, rows, outputRows)
  selected = void
  selectedPrefix = 0
  selectedUniqueLookup = false
  selectedRows = rows
  selectedCost = endian.MAX_MINILANG_INT
  selectedCovering = false
  for each index in tableIndexes(state, source.table.tableId)
    prefix = 0
    allEquality = true
    keyLiterals = []
    candidateRows = rows
    for keyPosition = 0 to len(index.columnIndexes) - 1
      localIndex = index.columnIndexes[keyPosition]
      comparison = void
      if localIndex >= 0 then comparison = rewrites.comparisonForColumn(predicate, source.offset + localIndex) else comparison = rewrites.comparisonForExpression(predicate, index.keyExpressions[keyPosition]) end if
      if not comparison[0] then break end if
      operator = comparison[1]
      if operator == "=" then
        prefix = prefix + 1
        keyLiterals = keyLiterals + [comparison[2]]
        current = void
        if localIndex >= 0 then current = columnStats(found, localIndex) end if
        if current is not void and current.distinctCount > 0 then
          estimatedEquality = equalityRows(candidateRows, rows, current, comparison[2])
          if estimatedEquality is void then estimatedEquality = integerDivide(candidateRows, current.distinctCount) end if
          candidateRows = estimatedEquality
          if candidateRows == 0 and rows > 0 then candidateRows = 1 end if
        else
          candidateRows = rewrites.estimateFilteredRows(candidateRows, predicate)
        end if
      else if prefix == 0 and (operator == "<" or operator == "<=" or operator == ">" or operator == ">=") then
        prefix = 1
        allEquality = false
        current = void
        if localIndex >= 0 then current = columnStats(found, localIndex) end if
        candidateRows = integralRangeRows(candidateRows, rows, current, operator, comparison[2])
        if candidateRows is void then candidateRows = integerDivide(rows, 3) end if
        if candidateRows == 0 and rows > 0 then candidateRows = 1 end if
        break
      else
        break
      end if
    end for
    usable = prefix > 0
    if index.predicate is not void and (len(bound.sources) != 1 or not rewrites.predicateImplies(predicate, index.predicate)) then usable = false end if
    if len(index.columnIndexes) > 1 and (prefix != len(index.columnIndexes) or not allEquality) then usable = false end if
    if usable and allEquality and prefix == len(index.columnIndexes) and len(index.columnIndexes) > 1 then
      group = columnGroupStats(found, index.columnIndexes)
      if group is not void and group.distinctCount > 0 then
        candidateRows = integerDivide(rows, group.distinctCount)
        tupleHash = tupleHashForLiterals(keyLiterals)
        if tupleHash is not void and typeof(group.mostCommonHashes) == "array" and len(group.mostCommonHashes) > 0 then
          for groupIndex = 0 to len(group.mostCommonHashes) - 1
            if group.mostCommonHashes[groupIndex] == tupleHash then candidateRows = group.mostCommonCounts[groupIndex]; break end if
          end for
        end if
        if candidateRows == 0 and rows > 0 then candidateRows = 1 end if
      end if
    end if
    uniqueLookup = index.unique and allEquality and prefix == len(index.columnIndexes)
    if uniqueLookup then candidateRows = 1 end if
    if usable then
      covering = indexCoversBound(bound, source, index, predicate)
      candidateCost = cost.indexScan(3, candidateRows, outputRows, uniqueLookup).total
      if covering then candidateCost = cost.indexOnlyScan(3, candidateRows, outputRows, uniqueLookup).total end if
      if selected is void or candidateCost < selectedCost or (candidateCost == selectedCost and prefix > selectedPrefix) then
        selected = index
        selectedPrefix = prefix
        selectedUniqueLookup = uniqueLookup
        selectedRows = candidateRows
        selectedCost = candidateCost
        selectedCovering = covering
      end if
    end if
  end for
  return [selected, selectedPrefix, selectedUniqueLookup, selectedRows, selectedCovering]
end function

/// Chooses a bounded multi-index path for a single base table. AND may use every
/// independently indexable conjunct and intersect row identities; OR is eligible
/// only when every disjunct has an index so no qualifying branch can be lost.
/// @param bound bound value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param found found value consumed by this operation.
/// @param rows rows value consumed by this operation.
function combinedIndexCandidate(bound, source, predicate, state, found, rows)
  if len(bound.sources) != 1 or len(bound.joins) != 0 or predicate is void or not expressions.isBaseBoundExpression(predicate) or predicate.kind != expressions.BOUND_BINARY then return [execution_plan.ACCESS_SEQUENTIAL, [], rows, endian.MAX_MINILANG_INT] end if
  accessKind = execution_plan.ACCESS_SEQUENTIAL
  parts = []
  if predicate.operator == "AND" then accessKind = execution_plan.ACCESS_INDEX_INTERSECTION; parts = rewrites.conjuncts(predicate) end if
  if predicate.operator == "OR" then accessKind = execution_plan.ACCESS_INDEX_UNION; parts = rewrites.disjuncts(predicate) end if
  if accessKind == execution_plan.ACCESS_SEQUENTIAL or len(parts) < 2 then return [execution_plan.ACCESS_SEQUENTIAL, [], rows, endian.MAX_MINILANG_INT] end if
  names = []
  estimates = []
  totalCost = 0
  for each part in parts
    partRows = rewrites.estimateFilteredRows(rows, part)
    candidate = indexCandidate(bound, source, part, state, found, rows, partRows)
    if candidate[0] is void then
      if accessKind == execution_plan.ACCESS_INDEX_UNION then return [execution_plan.ACCESS_SEQUENTIAL, [], rows, endian.MAX_MINILANG_INT] end if
      continue
    end if
    if not indexNameContains(names, candidate[0].name) then
      names = names + [candidate[0].name]
      estimates = estimates + [candidate[3]]
      // Multi-index execution intersects/unions encoded row references before
      // opening the heap, so each component pays index-entry rather than heap-row cost.
      totalCost = totalCost + cost.indexOnlyScan(3, candidate[3], 0, candidate[2]).total
    end if
  end for
  if len(names) < 2 then return [execution_plan.ACCESS_SEQUENTIAL, [], rows, endian.MAX_MINILANG_INT] end if
  estimatedRows = 0
  if accessKind == execution_plan.ACCESS_INDEX_INTERSECTION then
    estimatedRows = rows
    for each currentRows in estimates
      estimatedRows = scaleFraction(estimatedRows, currentRows, rows)
    end for
  else
    for each currentRows in estimates
      estimatedRows = estimatedRows + currentRows
      if estimatedRows > rows then estimatedRows = rows end if
    end for
  end if
  if estimatedRows == 0 and rows > 0 then estimatedRows = 1 end if
  return [accessKind, names, estimatedRows, totalCost + estimatedRows * 5]
end function

/// Scans plan using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param bound bound value consumed by this operation.
/// @param source source value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param predicate predicate value consumed by this operation.
/// @param sourceIndex Zero-based index of source.
function scanPlan(bound, source, state, predicate, sourceIndex)
  found = tableStats(state, source.table.tableId)
  rows = 1000
  pages = 100
  detail = source.table.name + " (default estimates)"
  used = false
  if found is not void then
    rows = found.rowCount
    pages = found.pageCount
    detail = source.table.name + " pages=" + pages
    used = true
  end if
  sequential = cost.sequentialScan(pages, rows)
  outputRows = predicateRows(source, found, predicate, rows)
  selected = sequential
  accessKind = execution_plan.ACCESS_SEQUENTIAL
  indexName = ""
  candidate = indexCandidate(bound, source, predicate, state, found, rows, outputRows)
  if candidate[0] is not void then
    // A complete equality probe of a unique index returns at most one row even
    // when ANALYZE statistics are absent. This semantic bound is stronger than
    // the generic predicate selectivity heuristic.
    if candidate[2] then outputRows = 1 end if
    indexed = cost.indexScan(3, candidate[3], outputRows, candidate[2])
    if candidate[4] then indexed = cost.indexOnlyScan(3, candidate[3], outputRows, candidate[2]) end if
    if indexed.total < sequential.total then
      selected = indexed
      accessKind = execution_plan.ACCESS_INDEX
      if candidate[4] then accessKind = execution_plan.ACCESS_INDEX_ONLY end if
      indexName = candidate[0].name
      detail = source.table.name + " index=" + indexName
    end if
  end if
  combined = combinedIndexCandidate(bound, source, predicate, state, found, rows)
  if combined[0] != execution_plan.ACCESS_SEQUENTIAL and combined[3] < selected.total then
    accessKind = combined[0]
    indexName = ""
    outputRows = combined[2]
    algorithm = "Index Intersection"
    if accessKind == execution_plan.ACCESS_INDEX_UNION then algorithm = "Index Union" end if
    selected = cost.estimate(1, combined[3], outputRows, algorithm)
    detail = source.table.name + " indexes=" + indexNameListText(combined[1])
  end if
  if accessKind == execution_plan.ACCESS_SEQUENTIAL and predicate is not void then selected = cost.filter(sequential, outputRows) end if
  indexNames = []
  if combined[0] == accessKind then indexNames = combined[1] end if
  sourcePlan = execution_plan.SourcePlan(sourceIndex, accessKind, indexName, indexNames, outputRows, selected.total, predicate)
  return [physical_plan.PhysicalPlan(selected.algorithm, detail, outputRows, selected.total, []), selected, used, sourcePlan]
end function

/// Implements join rows for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param columnIndex Zero-based index of column.
function distinctForBoundColumn(bound, state, columnIndex)
  for each source in bound.sources
    if columnIndex >= source.offset and columnIndex < source.offset + len(source.table.columns) then
      found = tableStats(state, source.table.tableId)
      current = columnStats(found, columnIndex - source.offset)
      if current is not void then return current.distinctCount end if
      return 0
    end if
  end for
  return 0
end function

/// Estimates output cardinality for one join using NDV statistics when the
/// predicate is a supported equality.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param leftRows leftRows value consumed by this operation.
/// @param rightRows rightRows value consumed by this operation.
/// @param joinType joinType value consumed by this operation.
/// @param condition condition value consumed by this operation.
function joinRows(bound, state, leftRows, rightRows, joinType, condition)
  if joinType == ast.JOIN_CROSS then return leftRows * rightRows end if
  estimate = integerDivide(leftRows * rightRows, 10)
  if rewrites.isColumnEquality(condition) then
    leftDistinct = distinctForBoundColumn(bound, state, condition.left.columnIndex)
    rightDistinct = distinctForBoundColumn(bound, state, condition.right.columnIndex)
    divisor = leftDistinct
    if rightDistinct > divisor then divisor = rightDistinct end if
    if divisor > 0 then estimate = integerDivide(leftRows * rightRows, divisor) end if
  end if
  if estimate == 0 and leftRows > 0 and rightRows > 0 then estimate = 1 end if
  if (joinType == ast.JOIN_LEFT or joinType == ast.JOIN_FULL) and estimate < leftRows then estimate = leftRows end if
  if (joinType == ast.JOIN_RIGHT or joinType == ast.JOIN_FULL) and estimate < rightRows then estimate = rightRows end if
  return estimate
end function

/// Implements join operator for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param joinType joinType value consumed by this operation.
function joinOperator(joinType)
  if joinType == ast.JOIN_LEFT then return "Left Outer Join" end if
  if joinType == ast.JOIN_RIGHT then return "Right Outer Join" end if
  if joinType == ast.JOIN_FULL then return "Full Outer Join" end if
  if joinType == ast.JOIN_CROSS then return "Cross Join" end if
  return "Inner Join"
end function

/// Recognizes the exact COUNT(*) form implemented by the checksum-verified heap
/// slot counter. Keeping this choice in the optimizer makes EXPLAIN and normal
/// execution agree about the fast path.
/// @param bound bound value consumed by this operation.
/// @param wherePredicate wherePredicate value consumed by this operation.
function countSlotsEligible(bound, wherePredicate)
  if len(bound.sources) != 1 or len(bound.joins) != 0 or bound.sources[0].query is not void then return false end if
  if len(bound.items) != 1 or not expressions.isBoundAggregate(bound.items[0]) then return false end if
  item = bound.items[0]
  if item.name != "COUNT" or not item.countStar or item.distinct then return false end if
  if wherePredicate is not void or len(bound.groupExpressions) != 0 or bound.havingExpression is not void then return false end if
  if len(bound.orderExpressions) != 0 or len(bound.setOperations) != 0 or bound.windowQuery then return false end if
  if bound.statement.distinct or bound.statement.offset != 0 or bound.statement.limit == 0 then return false end if
  return true
end function

/// Recognizes direct, non-DISTINCT scalar aggregates that can update fixed-size
/// accumulators while scanning instead of retaining every input row.
/// @param bound bound value consumed by this operation.
/// @param wherePredicate wherePredicate value consumed by this operation.
function streamAggregateEligible(bound, wherePredicate)
  if len(bound.sources) != 1 or len(bound.joins) != 0 or bound.sources[0].query is not void then return false end if
  if not bound.aggregateQuery or len(bound.groupExpressions) != 0 or bound.havingExpression is not void then return false end if
  if bound.statement.distinct or len(bound.setOperations) != 0 or bound.windowQuery or len(bound.orderExpressions) != 0 then return false end if
  if expressions.containsSubquery(wherePredicate) then return false end if
  if bound.statement.offset != 0 or bound.statement.limit == 0 then return false end if
  for each item in bound.items
    if not expressions.isBoundAggregate(item) or item.distinct or item.name == "STRING_AGG" then return false end if
  end for
  return len(bound.items) > 0
end function

/// Recognizes a reordered INNER-equijoin COUNT(*) whose final join can count
/// matches instead of materializing the potentially much larger joined rowset.
/// @param bound bound value consumed by this operation.
/// @param wherePredicate wherePredicate value consumed by this operation.
/// @param reordered reordered value consumed by this operation.
function streamingJoinCountEligible(bound, wherePredicate, reordered)
  if not reordered or len(bound.sources) < 2 or len(bound.joins) != len(bound.sources) - 1 then return false end if
  if len(bound.items) != 1 or not expressions.isBoundAggregate(bound.items[0]) then return false end if
  item = bound.items[0]
  if item.name != "COUNT" or not item.countStar or item.distinct then return false end if
  if wherePredicate is not void or len(bound.groupExpressions) != 0 or bound.havingExpression is not void then return false end if
  if bound.statement.distinct or len(bound.setOperations) != 0 or bound.windowQuery or len(bound.orderExpressions) != 0 then return false end if
  if bound.statement.offset != 0 or bound.statement.limit == 0 then return false end if
  for each joined in bound.joins
    if joined.joinType != ast.JOIN_INNER or not rewrites.isColumnEquality(joined.condition) then return false end if
  end for
  return true
end function

/// Finds the single-column right-side index usable by a parameterized equality
/// join. Composite join probes are deferred until the executor accepts multiple
/// lookup keys.
/// @param joined joined value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
function joinIndexCandidate(joined, state)
  if joined.condition is void or not rewrites.isColumnEquality(joined.condition) then return void end if
  rightColumn = -1
  if joined.condition.left.columnIndex >= joined.source.offset then rightColumn = joined.condition.left.columnIndex - joined.source.offset end if
  if joined.condition.right.columnIndex >= joined.source.offset then rightColumn = joined.condition.right.columnIndex - joined.source.offset end if
  if rightColumn < 0 or rightColumn >= len(joined.source.table.columns) then return void end if
  for each index in tableIndexes(state, joined.source.table.tableId)
    if index.predicate is void and len(index.columnIndexes) == 1 and index.columnIndexes[0] == rightColumn then return index end if
  end for
  return void
end function

/// Returns join indexes in their bound SQL order.
/// @param bound bound value consumed by this operation.
function originalJoinSequence(bound)
  output = []
  if len(bound.joins) > 0 then
    for index = 0 to len(bound.joins) - 1
      output = output + [index]
    end for
  end if
  return output
end function

/// Returns the syntactic source introduced by each original join.
/// @param bound bound value consumed by this operation.
function originalJoinSources(bound)
  output = []
  if len(bound.sources) > 1 then
    for sourceIndex = 1 to len(bound.sources) - 1
      output = output + [sourceIndex]
    end for
  end if
  return output
end function

/// Copies an integer array while omitting one position.
/// @param items Items consumed or updated by the operation.
/// @param removedIndex Zero-based index of removed.
function removeIntegerAt(items, removedIndex)
  output = []
  if len(items) > 0 then
    for index = 0 to len(items) - 1
      if index != removedIndex then output = output + [items[index]] end if
    end for
  end if
  return output
end function

/// Reorders a pure INNER equijoin graph with a deterministic cost-guided greedy
/// search. The smallest estimated source seeds the tree; each step attaches the
/// smallest unjoined source connected by one eligible equality edge. Outer,
/// cross, cyclic and non-binary predicates retain SQL order.
/// @param bound bound value consumed by this operation.
/// @param sourceScans sourceScans value consumed by this operation.
function chooseJoinSequenceGreedy(bound, sourceScans)
  original = originalJoinSequence(bound)
  originalSources = originalJoinSources(bound)
  for each joined in bound.joins
    if joined.joinType != ast.JOIN_INNER or not rewrites.isColumnEquality(joined.condition) then return [original, originalSources, 0, false] end if
  end for
  if len(bound.sources) == 0 then return [original, originalSources, 0, false] end if
  startSource = 0
  startRows = sourceScans[0][1].rows
  if len(bound.sources) > 1 then
    for sourceIndex = 1 to len(bound.sources) - 1
      candidateRows = sourceScans[sourceIndex][1].rows
      if candidateRows < startRows then startSource = sourceIndex; startRows = candidateRows end if
    end for
  end if
  joinedSources = array(len(bound.sources), false)
  joinedSources[startSource] = true
  remaining = original
  output = []
  outputSources = []
  while len(remaining) > 0
    selectedPosition = -1
    selectedSource = -1
    selectedRows = endian.MAX_MINILANG_INT
    for position = 0 to len(remaining) - 1
      joinIndex = remaining[position]
      references = rewrites.referencedSources(bound.joins[joinIndex].condition, bound.sources)
      candidateSource = -1
      eligible = references is not void and len(references) == 2
      if eligible and joinedSources[references[0]] and not joinedSources[references[1]] then candidateSource = references[1] end if
      if eligible and joinedSources[references[1]] and not joinedSources[references[0]] then candidateSource = references[0] end if
      if candidateSource < 0 then eligible = false end if
      if eligible then
        candidateRows = sourceScans[candidateSource][1].rows
        if selectedPosition < 0 or candidateRows < selectedRows then
          selectedPosition = position
          selectedSource = candidateSource
          selectedRows = candidateRows
        end if
      end if
    end for
    if selectedPosition < 0 then return [original, originalSources, 0, false] end if
    selectedJoin = remaining[selectedPosition]
    output = output + [selectedJoin]
    outputSources = outputSources + [selectedSource]
    joinedSources[selectedSource] = true
    remaining = removeIntegerAt(remaining, selectedPosition)
  end while
  reordered = startSource != 0
  if len(output) > 0 then
    for index = 0 to len(output) - 1
      if output[index] != original[index] or outputSources[index] != originalSources[index] then reordered = true end if
    end for
  end if
  return [output, outputSources, startSource, reordered]
end function

/// Counts set source bits in a small join-enumeration mask.
/// @param mask mask value consumed by this operation.
function sourceMaskCount(mask)
  count = 0
  remaining = mask
  while remaining > 0
    if (remaining & 1) != 0 then count = count + 1 end if
    remaining = remaining >> 1
  end while
  return count
end function

/// Finds a join edge that connects one candidate source to the current subset.
/// Pure tree-shaped INNER equijoin graphs have one such edge; when more than one
/// exists the lowest estimated output cardinality wins deterministically.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param sourceIndex Zero-based index of source.
function connectingJoin(bound, state, sourceIndex)
  selected = -1
  selectedRows = endian.MAX_MINILANG_INT
  for joinIndex = 0 to len(bound.joins) - 1
    references = rewrites.referencedSources(bound.joins[joinIndex].condition, bound.sources)
    if references is not void and len(references) == 2 then
      other = -1
      if references[0] == sourceIndex and (state.sourceMask & (1 << references[1])) != 0 then other = references[1] end if
      if references[1] == sourceIndex and (state.sourceMask & (1 << references[0])) != 0 then other = references[0] end if
      if other >= 0 then
        candidateRows = joinRows(bound, void, state.estimate.rows, 1, ast.JOIN_INNER, bound.joins[joinIndex].condition)
        if selected < 0 or candidateRows < selectedRows then selected = joinIndex; selectedRows = candidateRows end if
      end if
    end if
  end for
  return selected
end function

/// Enumerates the cheapest connected left-deep order for up to eight sources.
/// This is the classic Selinger subset dynamic program adapted to MiniSQL's
/// executor contract, which attaches one source per JoinPlan. Unsupported or
/// larger graphs retain the deterministic greedy implementation above.
/// @param bound bound value consumed by this operation.
/// @param sourceScans sourceScans value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
function chooseJoinSequence(bound, sourceScans, state)
  original = originalJoinSequence(bound)
  originalSources = originalJoinSources(bound)
  sourceCount = len(bound.sources)
  if sourceCount == 0 then return [original, originalSources, 0, false] end if
  if sourceCount > 8 or len(bound.joins) != sourceCount - 1 then return chooseJoinSequenceGreedy(bound, sourceScans) end if
  for each joined in bound.joins
    if joined.joinType != ast.JOIN_INNER or not rewrites.isColumnEquality(joined.condition) then return [original, originalSources, 0, false] end if
  end for
  stateCount = 1 << sourceCount
  best = array(stateCount, void)
  for sourceIndex = 0 to sourceCount - 1
    sourceEstimate = sourceScans[sourceIndex][1]
    best[1 << sourceIndex] = JoinOrderState(1 << sourceIndex, sourceIndex, [], [], sourceEstimate)
  end for
  if sourceCount > 1 then
    for prefixSize = 1 to sourceCount - 1
      for mask = 1 to stateCount - 1
      current = best[mask]
      if current is not void and sourceMaskCount(mask) == prefixSize then
        for sourceIndex = 0 to sourceCount - 1
          sourceBit = 1 << sourceIndex
          if (mask & sourceBit) == 0 then
            joinIndex = connectingJoin(bound, current, sourceIndex)
            if joinIndex >= 0 then
              right = sourceScans[sourceIndex][1]
              joined = bound.joins[joinIndex]
              outputRows = joinRows(bound, state, current.estimate.rows, right.rows, joined.joinType, joined.condition)
              nested = cost.nestedLoop(current.estimate, right, outputRows)
              candidate = nested
              if types.sameBase(joined.condition.left.typeInfo, joined.condition.right.typeInfo) then
                hashed = cost.hashJoin(current.estimate, right, outputRows)
                if hashed.total <= candidate.total then candidate = hashed end if
              end if
              nextMask = mask | sourceBit
              existing = best[nextMask]
              if existing is void or candidate.total < existing.estimate.total then
                best[nextMask] = JoinOrderState(nextMask, current.startSource, current.joinIndexes + [joinIndex], current.sourceIndexes + [sourceIndex], candidate)
              end if
            end if
          end if
        end for
      end if
      end for
    end for
  end if
  selected = best[stateCount - 1]
  if selected is void then return chooseJoinSequenceGreedy(bound, sourceScans) end if
  reordered = selected.startSource != 0
  if len(selected.joinIndexes) > 0 then
    for index = 0 to len(selected.joinIndexes) - 1
      if selected.joinIndexes[index] != original[index] or selected.sourceIndexes[index] != originalSources[index] then reordered = true end if
    end for
  end if
  return [selected.joinIndexes, selected.sourceIndexes, selected.startSource, reordered, true]
end function

/// Builds the scan/join spine and its cumulative deterministic cost estimate.
/// Equality INNER/LEFT joins compare hash and nested-loop costs; unsupported join
/// shapes retain the semantic nested-loop fallback. Returns plan, cost, and stats-use flag.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
/// @param sourcePredicates sourcePredicates value consumed by this operation.
function buildBase(bound, state, sourcePredicates)
  if len(bound.sources) == 0 then
    estimate = cost.estimate(0, 1, 1, "Values")
    return [physical_plan.PhysicalPlan("Values", "one row", 1, 1, []), estimate, false, [], [], false, 0]
  end if
  sourceScans = []
  for sourceIndex = 0 to len(bound.sources) - 1
    sourceScans = sourceScans + [scanPlan(bound, bound.sources[sourceIndex], state, sourcePredicates[sourceIndex], sourceIndex)]
  end for
  sequence = chooseJoinSequence(bound, sourceScans, state)
  first = sourceScans[sequence[2]]
  root = first[0]
  currentCost = first[1]
  used = first[2]
  sourcePlans = array(len(bound.sources), void)
  for sourceIndex = 0 to len(bound.sources) - 1
    sourcePlans[sourceIndex] = sourceScans[sourceIndex][3]
  end for
  joinPlans = []
  stepIndex = 0
  for each joinIndex in sequence[0]
    joined = bound.joins[joinIndex]
    sourceIndex = sequence[1][stepIndex]
    right = sourceScans[sourceIndex]
    outputRows = joinRows(bound, state, currentCost.rows, right[1].rows, joined.joinType, joined.condition)
    nested = cost.nestedLoop(currentCost, right[1], outputRows)
    selected = nested
    selectedAlgorithm = execution_plan.JOIN_NESTED_LOOP
    buildRight = true
    operatorName = joinOperator(joined.joinType)
    detail = joined.source.table.name
    hashSupported = rewrites.isColumnEquality(joined.condition) and types.sameBase(joined.condition.left.typeInfo, joined.condition.right.typeInfo) and (joined.joinType == ast.JOIN_INNER or joined.joinType == ast.JOIN_LEFT)
    if hashSupported then
      hashed = cost.hashJoin(currentCost, right[1], outputRows)
      if hashed.total <= nested.total then
        selected = hashed
        selectedAlgorithm = execution_plan.JOIN_HASH
        operatorName = "Hash Join"
        if joined.joinType == ast.JOIN_INNER and currentCost.rows < right[1].rows then buildRight = false end if
        buildName = "right"
        if not buildRight then buildName = "left" end if
        detail = detail + " type=" + joinOperator(joined.joinType) + "; build=" + buildName
      else
        detail = detail + " equality; hash-cost=" + hashed.total
      end if
    end if
    indexed = joinIndexCandidate(joined, state)
    if sequence[3] then indexed = void end if
    if indexed is not void and (joined.joinType == ast.JOIN_INNER or joined.joinType == ast.JOIN_LEFT) then
      matches = 1
      rightStats = tableStats(state, joined.source.table.tableId)
      if rightStats is not void and not indexed.unique and rightStats.rowCount > 0 then
        localColumn = indexed.columnIndexes[0]
        currentColumn = columnStats(rightStats, localColumn)
        if currentColumn is not void and currentColumn.distinctCount > 0 then
          matches = integerDivide(rightStats.rowCount, currentColumn.distinctCount)
          if matches == 0 then matches = 1 end if
        end if
      end if
      indexJoin = cost.indexNestedLoop(currentCost, 3, matches, outputRows)
      if indexJoin.total < selected.total then
        selected = indexJoin
        selectedAlgorithm = execution_plan.JOIN_INDEX_NESTED_LOOP
        operatorName = "Index Nested Loop Join"
        detail = joined.source.table.name + " index=" + indexed.name
      end if
    end if
    root = physical_plan.PhysicalPlan(operatorName, detail, outputRows, selected.total, [root, right[0]])
    joinPlans = joinPlans + [execution_plan.JoinPlan(joinIndex, sourceIndex, selectedAlgorithm, buildRight, outputRows, selected.total)]
    currentCost = selected
    used = used or right[2]
    stepIndex = stepIndex + 1
  end for
  if len(sequence) > 4 and sequence[4] and len(bound.joins) > 0 then
    root = physical_plan.PhysicalPlan("Dynamic Join Order", "sources=" + len(bound.sources), currentCost.rows, currentCost.total, [root])
  end if
  return [root, currentCost, used, sourcePlans, joinPlans, sequence[3], sequence[2]]
end function

/// Lowers a bound SELECT into a costed physical operator tree.
/// Operators are added in relational order; analyzed statistics replace defaults,
/// large sorts select external merge sort, and set-operation branches recurse.
/// Returns OptimizedPlan or a structured validation/dependency error.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
function optimize(bound, state)
  if not binder.isBoundSelect(bound) then return fail(INVALID_ARGUMENT, "optimize", "bound must be BoundSelect") end if
  normalizedWhere = rewrites.simplify(bound.whereExpression)
  if rewrites.isConstantBoolean(normalizedWhere, true) then normalizedWhere = void end if
  pushed = rewrites.sourcePredicates(normalizedWhere, bound.sources, bound.joins)
  built = buildBase(bound, state, pushed)
  root = built[0]
  currentCost = built[1]
  used = built[2]
  constantEmpty = rewrites.constantWhereEmpty(normalizedWhere)
  if constantEmpty then
    currentCost = cost.estimate(0, 0, 0, "Empty Result")
    root = physical_plan.PhysicalPlan("Empty Result", "constant WHERE predicate", 0, 0, [])
  end if
  residual = rewrites.residualPredicate(normalizedWhere, bound.sources, bound.joins)
  if residual is not void then
    rows = rewrites.estimateFilteredRows(currentCost.rows, residual)
    currentCost = cost.filter(currentCost, rows)
    root = physical_plan.PhysicalPlan("Filter", "selectivity=" + rewrites.selectivityPermille(residual) + "/1000", rows, currentCost.total, [root])
  end if
  aggregateAlgorithm = execution_plan.AGGREGATE_NONE
  if bound.aggregateQuery then
    groups = currentCost.rows
    if len(bound.groupExpressions) == 0 then groups = 1 else if groups > 100 then groups = 100 end if
    currentCost = cost.aggregate(currentCost, groups)
    aggregateName = currentCost.algorithm
    aggregateDetail = "groups=" + len(bound.groupExpressions)
    aggregateAlgorithm = execution_plan.AGGREGATE_HASH
    if countSlotsEligible(bound, normalizedWhere) then
      aggregateName = "Count Slots"
      aggregateDetail = bound.sources[0].table.name + " checksum-verified live slots"
      aggregateAlgorithm = execution_plan.AGGREGATE_COUNT_SLOTS
    else if streamAggregateEligible(bound, normalizedWhere) then
      aggregateName = "Streaming Aggregate"
      aggregateDetail = "fixed-size accumulators=" + len(bound.items)
      aggregateAlgorithm = execution_plan.AGGREGATE_STREAM
    else if streamingJoinCountEligible(bound, normalizedWhere, built[5]) then
      aggregateName = "Streaming Join Count"
      aggregateDetail = "final join emits cardinality only"
      aggregateAlgorithm = execution_plan.AGGREGATE_JOIN_COUNT
    end if
    root = physical_plan.PhysicalPlan(aggregateName, aggregateDetail, groups, currentCost.total, [root])
  end if
  currentCost = cost.project(currentCost, currentCost.rows)
  root = physical_plan.PhysicalPlan("Projection", "columns=" + len(bound.items), currentCost.rows, currentCost.total, [root])
  if bound.statement.distinct then
    currentCost = cost.aggregate(currentCost, currentCost.rows)
    root = physical_plan.PhysicalPlan("Distinct", "", currentCost.rows, currentCost.total, [root])
  end if
  for each operation in bound.setOperations
    rightPlan = optimize(operation.query, state)
    rows = currentCost.rows + rightPlan.root.estimatedRows
    if not operation.all then rows = integerDivide(rows, 2) end if
    name = "Union"
    if operation.operator == ast.SET_INTERSECT then name = "Intersect" end if
    if operation.operator == ast.SET_EXCEPT then name = "Except" end if
    if operation.all then name = name + " All" end if
    total = currentCost.total + rightPlan.root.estimatedCost + rows
    root = physical_plan.PhysicalPlan(name, "", rows, total, [root, rightPlan.root])
    currentCost = cost.estimate(currentCost.startup, total, rows, name)
    used = used or rightPlan.usedStatistics
  end for
  sortAlgorithm = execution_plan.SORT_NONE
  if len(bound.statement.orderBy) > 0 then
    if bound.statement.limit >= 0 and bound.statement.limit + bound.statement.offset <= 128 then
      sortAlgorithm = execution_plan.SORT_TOP_N
      currentCost = cost.topN(currentCost, bound.statement.limit + bound.statement.offset)
    else if currentCost.rows > 128 then
      sortAlgorithm = execution_plan.SORT_EXTERNAL
      currentCost = cost.externalSort(currentCost)
    else
      sortAlgorithm = execution_plan.SORT_MEMORY
      currentCost = cost.sort(currentCost)
    end if
    root = physical_plan.PhysicalPlan(currentCost.algorithm, "keys=" + len(bound.statement.orderBy), currentCost.rows, currentCost.total, [root])
  end if
  if bound.statement.limit >= 0 or bound.statement.offset > 0 then
    rows = currentCost.rows
    if bound.statement.offset >= rows then rows = 0 else rows = rows - bound.statement.offset end if
    if bound.statement.limit >= 0 and bound.statement.limit < rows then rows = bound.statement.limit end if
    root = physical_plan.PhysicalPlan("Limit", "offset=" + bound.statement.offset + ", limit=" + bound.statement.limit, rows, currentCost.total, [root])
  end if
  executable = execution_plan.ExecutionPlan(built[3], built[4], built[6], aggregateAlgorithm, sortAlgorithm, constantEmpty, normalizedWhere, built[5])
  return OptimizedPlan(root, used, executable)
end function

/// Implements explain for this module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param bound bound value consumed by this operation.
/// @param state Mutable state inspected or updated by the operation.
function explain(bound, state)
  optimized = optimize(bound, state)
  lines = physical_plan.render(optimized.root)
  prefix = "statistics=defaults"
  if optimized.usedStatistics then prefix = "statistics=analyzed" end if
  return [prefix] + lines
end function

/// Performs the componentName operation for the minisql planner optimizer module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function componentName()
  return "planner.optimizer"
end function

/// Performs the targetMilestone operation for the minisql planner optimizer module.
/// Returns the computed value or operation status.
/// Any side effects are limited to the explicitly invoked dependencies.
function targetMilestone()
  return "M17"
end function

/// Returns whether implemented satisfies the condition required by the minisql planner optimizer module.
/// Returns the computed value or operation status.
/// Does not modify its inputs.
function isImplemented()
  return true
end function
