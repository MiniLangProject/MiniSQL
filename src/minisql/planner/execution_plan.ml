//! Provides minisql planner execution plan facilities for this project.

package minisql.planner.execution_plan

// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

// Typed execution decisions shared by the cost-based optimizer and executor.
// The descriptive PhysicalPlan remains the stable EXPLAIN representation; this
// module is the executable contract that prevents the executor from choosing a
// second, potentially different, algorithm after optimization.

import minisql.sql.expressions as expressions

/// Defines the invalid argument constant used by the minisql planner execution plan module.
const INVALID_ARGUMENT = 9001

/// Defines the access sequential constant used by the minisql planner execution plan module.
const ACCESS_SEQUENTIAL = 1
/// Defines the access index constant used by the minisql planner execution plan module.
const ACCESS_INDEX = 2
/// Defines the access index only constant used by the minisql planner execution plan module.
const ACCESS_INDEX_ONLY = 3
/// Defines the access index intersection constant used by the minisql planner execution plan module.
const ACCESS_INDEX_INTERSECTION = 4
/// Defines the access index union constant used by the minisql planner execution plan module.
const ACCESS_INDEX_UNION = 5

/// Defines the join nested loop constant used by the minisql planner execution plan module.
const JOIN_NESTED_LOOP = 1
/// Defines the join hash constant used by the minisql planner execution plan module.
const JOIN_HASH = 2
/// Defines the join index nested loop constant used by the minisql planner execution plan module.
const JOIN_INDEX_NESTED_LOOP = 3

/// Defines the aggregate none constant used by the minisql planner execution plan module.
const AGGREGATE_NONE = 0
/// Defines the aggregate hash constant used by the minisql planner execution plan module.
const AGGREGATE_HASH = 1
/// Defines the aggregate count slots constant used by the minisql planner execution plan module.
const AGGREGATE_COUNT_SLOTS = 2
/// Defines the aggregate stream constant used by the minisql planner execution plan module.
const AGGREGATE_STREAM = 3
/// Defines the aggregate join count constant used by the minisql planner execution plan module.
const AGGREGATE_JOIN_COUNT = 4

/// Defines the sort none constant used by the minisql planner execution plan module.
const SORT_NONE = 0
/// Defines the sort memory constant used by the minisql planner execution plan module.
const SORT_MEMORY = 1
/// Defines the sort external constant used by the minisql planner execution plan module.
const SORT_EXTERNAL = 2
/// Defines the sort top n constant used by the minisql planner execution plan module.
const SORT_TOP_N = 3

/// Describes one persistent index without exposing catalog implementation
/// details to the optimizer. Column indexes are local to the owning table.
struct IndexInfo
  /// Owning catalog table identifier.
  tableId
  /// Stable catalog index name used by execution diagnostics.
  name
  /// Ordered table-local key columns; -1 marks an expression-key position.
  columnIndexes
  /// Position-aligned bound expression keys; ordinary column positions are void.
  keyExpressions
  /// Ordered table-local non-key columns stored in leaf payloads.
  includedColumnIndexes
  /// Optional bound predicate restricting rows physically present in the index.
  predicate
  /// Whether the complete key enforces uniqueness.
  unique
end struct

/// Immutable planning inputs loaded by the executor from one catalog snapshot.
struct PlanningContext
  /// Immutable statistics catalog snapshot.
  statistics
  /// Immutable index metadata snapshot.
  indexes
  /// Process-local DDL and maintenance generation.
  schemaGeneration
end struct

/// Selects the physical access path and safe pushed predicate for one source.
struct SourcePlan
  /// Position in BoundSelect.sources.
  sourceIndex
  /// ACCESS_* algorithm selected by the cost model.
  accessKind
  /// Selected index name or an empty string for a sequential scan.
  indexName
  /// Stable names participating in an intersection/union access path.
  indexNames
  /// Estimated rows surviving source-local predicates.
  estimatedRows
  /// Deterministic integer cost of this access path.
  estimatedCost
  /// Safe single-source predicate evaluated before joining.
  pushedPredicate
end struct

/// Selects exactly one algorithm for a join in the bound SQL join sequence.
/// Hash joins may build either side while still returning canonical left/right
/// column order. Runtime fallbacks are allowed only for transaction visibility
/// or index availability changes and never alter SQL semantics.
struct JoinPlan
  /// Position of the predicate in BoundSelect.joins.
  joinIndex
  /// Source attached by this physical join step.
  sourceIndex
  /// JOIN_* algorithm selected by the cost model.
  algorithm
  /// True when the right/new source is the hash build input.
  buildRight
  /// Estimated output cardinality after this join.
  estimatedRows
  /// Cumulative deterministic integer cost.
  estimatedCost
end struct

/// Complete executable contract for one BoundSelect.
struct ExecutionPlan
  /// Access decision indexed by bound source position.
  sources
  /// Physical join steps in execution order.
  joins
  /// Source that seeds a reordered inner-join graph.
  startSource
  /// AGGREGATE_* strategy selected for the query.
  aggregateAlgorithm
  /// SORT_* strategy selected for the query.
  sortAlgorithm
  /// True when a constant WHERE predicate proves the input empty.
  constantEmpty
  /// Simplified WHERE expression retained as the correctness filter.
  wherePredicate
  /// True when join steps differ from bound SQL order.
  reorderedJoins
end struct

/// Creates an execution-plan error carrying operation context.
/// @param code code value consumed by this operation.
/// @param operation operation value consumed by this operation.
/// @param message Human-readable message associated with the operation.
function fail(code, operation, message)
  return error(code, "planner.execution_plan." + operation + ": " + message)
end function

/// Validates and constructs catalog-independent index metadata.
/// @param tableId Identifier of table.
/// @param name Name of the affected item.
/// @param columnIndexes columnIndexes value consumed by this operation.
/// @param keyExpressions keyExpressions value consumed by this operation.
/// @param includedColumnIndexes includedColumnIndexes value consumed by this operation.
/// @param predicate predicate value consumed by this operation.
/// @param unique unique value consumed by this operation.
function indexInfo(tableId, name, columnIndexes, keyExpressions, includedColumnIndexes, predicate, unique)
  if typeof(tableId) != "int" or tableId < 0 or typeof(name) != "string" or typeof(columnIndexes) != "array" or len(columnIndexes) == 0 or typeof(keyExpressions) != "array" or len(keyExpressions) != len(columnIndexes) or typeof(includedColumnIndexes) != "array" or (predicate is not void and not expressions.isBoundExpression(predicate)) or typeof(unique) != "bool" then return fail(INVALID_ARGUMENT, "indexInfo", "invalid index metadata") end if
  for index = 0 to len(columnIndexes) - 1
    columnIndex = columnIndexes[index]
    keyExpression = keyExpressions[index]
    if typeof(columnIndex) != "int" or columnIndex < -1 or (columnIndex < 0 and not expressions.isBoundExpression(keyExpression)) or (columnIndex >= 0 and keyExpression is not void) then return fail(INVALID_ARGUMENT, "indexInfo", "invalid column/expression key position") end if
  end for
  for each columnIndex in includedColumnIndexes
    if typeof(columnIndex) != "int" or columnIndex < 0 then return fail(INVALID_ARGUMENT, "indexInfo", "included column indexes must be non-negative integers") end if
  end for
  return IndexInfo(tableId, name, columnIndexes, keyExpressions, includedColumnIndexes, predicate, unique)
end function

/// Builds an immutable optimizer input snapshot.
/// @param statistics statistics value consumed by this operation.
/// @param indexes indexes value consumed by this operation.
/// @param schemaGeneration schemaGeneration value consumed by this operation.
function context(statistics, indexes, schemaGeneration)
  if typeof(indexes) != "array" or typeof(schemaGeneration) != "int" or schemaGeneration < 0 then return fail(INVALID_ARGUMENT, "context", "invalid planning context") end if
  return PlanningContext(statistics, indexes, schemaGeneration)
end function

/// Reports whether a value is a PlanningContext.
/// @param value Value consumed or transformed by the operation.
function isPlanningContext(value)
  return value is PlanningContext
end function

/// Reports whether a value is a complete ExecutionPlan.
/// @param value Value consumed or transformed by the operation.
function isExecutionPlan(value)
  return value is ExecutionPlan
end function

/// Returns all index descriptors owned by one table.
/// @param value Value consumed or transformed by the operation.
/// @param tableId Identifier of table.
function indexesForTable(value, tableId)
  if value is not PlanningContext or typeof(tableId) != "int" or tableId < 0 then return fail(INVALID_ARGUMENT, "indexesForTable", "invalid arguments") end if
  output = []
  for each index in value.indexes
    if index is not IndexInfo then return fail(INVALID_ARGUMENT, "indexesForTable", "context contains invalid index metadata") end if
    if index.tableId == tableId then output = output + [index] end if
  end for
  return output
end function

/// Returns the stable diagnostic component name.
function componentName()
  return "planner.execution_plan"
end function

/// Returns the milestone whose executor contract this module extends.
function targetMilestone()
  return "M46"
end function

/// Reports that the component is fully implemented.
function isImplemented()
  return true
end function
