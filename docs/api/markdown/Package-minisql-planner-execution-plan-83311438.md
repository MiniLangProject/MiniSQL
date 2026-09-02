# Package `minisql.planner.execution_plan`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/planner/execution_plan.ml](File-src-minisql-planner-execution-plan-ml-1727378828.md)

## Symbols

- [`minisql.planner.execution_plan.ACCESS_INDEX`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-access-index-const-access-index-2-src-minisql-planner-execution-plan-ml-286818709) — constant
- [`minisql.planner.execution_plan.ACCESS_INDEX_INTERSECTION`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-access-index-intersection-const-access-index-intersection-4-src-minisql-planner-execution-plan-ml-2006758827) — constant
- [`minisql.planner.execution_plan.ACCESS_INDEX_ONLY`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-access-index-only-const-access-index-only-3-src-minisql-planner-execution-plan-ml-398745894) — constant
- [`minisql.planner.execution_plan.ACCESS_INDEX_UNION`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-access-index-union-const-access-index-union-5-src-minisql-planner-execution-plan-ml-211013056) — constant
- [`minisql.planner.execution_plan.ACCESS_SEQUENTIAL`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-access-sequential-const-access-sequential-1-src-minisql-planner-execution-plan-ml-1882249308) — constant
- [`minisql.planner.execution_plan.AGGREGATE_COUNT_SLOTS`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-aggregate-count-slots-const-aggregate-count-slots-2-src-minisql-planner-execution-plan-ml-1360733669) — constant
- [`minisql.planner.execution_plan.AGGREGATE_HASH`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-aggregate-hash-const-aggregate-hash-1-src-minisql-planner-execution-plan-ml-1775724674) — constant
- [`minisql.planner.execution_plan.AGGREGATE_JOIN_COUNT`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-aggregate-join-count-const-aggregate-join-count-4-src-minisql-planner-execution-plan-ml-1892316529) — constant
- [`minisql.planner.execution_plan.AGGREGATE_NONE`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-aggregate-none-const-aggregate-none-0-src-minisql-planner-execution-plan-ml-507342021) — constant
- [`minisql.planner.execution_plan.AGGREGATE_STREAM`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-aggregate-stream-const-aggregate-stream-3-src-minisql-planner-execution-plan-ml-360111944) — constant
- [`minisql.planner.execution_plan.componentName`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-componentname-function-componentname-src-minisql-planner-execution-plan-ml-1500856384) — function
- [`minisql.planner.execution_plan.context`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-context-function-context-statistics-indexes-schemageneration-src-minisql-planner-execution-plan-ml-1465209598) — function
- [`minisql.planner.execution_plan.ExecutionPlan`](Type-minisql-planner-execution-plan-executionplan-1596690013.md) — struct
- [`minisql.planner.execution_plan.fail`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-fail-function-fail-code-operation-message-src-minisql-planner-execution-plan-ml-1248845663) — function
- [`minisql.planner.execution_plan.indexesForTable`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-indexesfortable-function-indexesfortable-value-tableid-src-minisql-planner-execution-plan-ml-50932540) — function
- [`minisql.planner.execution_plan.indexInfo`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-indexinfo-function-indexinfo-tableid-name-columnindexes-keyexpressions-includedcolumnindexes-predicate-unique-src-minisql-planner-execution-plan-ml-204855786) — function
- [`minisql.planner.execution_plan.IndexInfo`](Type-minisql-planner-execution-plan-indexinfo-667866752.md) — struct
- [`minisql.planner.execution_plan.INVALID_ARGUMENT`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-execution-plan-ml-1451222473) — constant
- [`minisql.planner.execution_plan.isExecutionPlan`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-isexecutionplan-function-isexecutionplan-value-src-minisql-planner-execution-plan-ml-234612605) — function
- [`minisql.planner.execution_plan.isImplemented`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-isimplemented-function-isimplemented-src-minisql-planner-execution-plan-ml-1321296536) — function
- [`minisql.planner.execution_plan.isPlanningContext`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-isplanningcontext-function-isplanningcontext-value-src-minisql-planner-execution-plan-ml-538934375) — function
- [`minisql.planner.execution_plan.JOIN_HASH`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-join-hash-const-join-hash-2-src-minisql-planner-execution-plan-ml-523503381) — constant
- [`minisql.planner.execution_plan.JOIN_INDEX_NESTED_LOOP`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-join-index-nested-loop-const-join-index-nested-loop-3-src-minisql-planner-execution-plan-ml-1579923772) — constant
- [`minisql.planner.execution_plan.JOIN_NESTED_LOOP`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-join-nested-loop-const-join-nested-loop-1-src-minisql-planner-execution-plan-ml-2003472972) — constant
- [`minisql.planner.execution_plan.JoinPlan`](Type-minisql-planner-execution-plan-joinplan-651583843.md) — struct
- [`minisql.planner.execution_plan.PlanningContext`](Type-minisql-planner-execution-plan-planningcontext-482159992.md) — struct
- [`minisql.planner.execution_plan.SORT_EXTERNAL`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-sort-external-const-sort-external-2-src-minisql-planner-execution-plan-ml-1889971461) — constant
- [`minisql.planner.execution_plan.SORT_MEMORY`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-sort-memory-const-sort-memory-1-src-minisql-planner-execution-plan-ml-563121668) — constant
- [`minisql.planner.execution_plan.SORT_NONE`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-sort-none-const-sort-none-0-src-minisql-planner-execution-plan-ml-625089695) — constant
- [`minisql.planner.execution_plan.SORT_TOP_N`](File-src-minisql-planner-execution-plan-ml-1727378828.md#constant-constant-minisql-planner-execution-plan-sort-top-n-const-sort-top-n-3-src-minisql-planner-execution-plan-ml-2121836582) — constant
- [`minisql.planner.execution_plan.SourcePlan`](Type-minisql-planner-execution-plan-sourceplan-215443890.md) — struct
- [`minisql.planner.execution_plan.targetMilestone`](File-src-minisql-planner-execution-plan-ml-1727378828.md#function-function-minisql-planner-execution-plan-targetmilestone-function-targetmilestone-src-minisql-planner-execution-plan-ml-714709122) — function
