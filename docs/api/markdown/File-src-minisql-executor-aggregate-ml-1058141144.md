# `src/minisql/executor/aggregate.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql executor aggregate facilities for this project.

Package: [`minisql.executor.aggregate`](Package-minisql-executor-aggregate-608808892.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/executor/projection.ml` as `projection` → [src/minisql/executor/projection.ml](File-src-minisql-executor-projection-ml-1842888238.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/executor/sort.ml` as `sort` → [src/minisql/executor/sort.ml](File-src-minisql-executor-sort-ml-267147473.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `std/concurrent/thread_pool.ml` as `thread_pool` → `../MiniLangCompilerML/std/concurrent/thread_pool.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-aggregate-accumulate-function-accumulate-state-row-src-minisql-executor-aggregate-ml-554184651"></a>
### accumulate

```ml
function accumulate(state, row)
```

Updates one accumulator from one row without retaining the row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L342)

<a id="function-function-minisql-executor-aggregate-accumulatebatch-function-accumulatebatch-states-rows-src-minisql-executor-aggregate-ml-1452920695"></a>
### accumulateBatch

```ml
function accumulateBatch(states, rows)
```

Updates all aggregate lanes from one bounded row batch. Keeping accumulator dispatch outside the storage cursor makes the operator batch-at-a-time and gives the native compiler a compact, allocation-free numeric inner loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `states` | `dynamic` | — | states value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L379)

- [minisql.executor.aggregate.AggregateAccumulator](Type-minisql-executor-aggregate-aggregateaccumulator-1137240641.md) — struct
- [minisql.executor.aggregate.AggregateGroup](Type-minisql-executor-aggregate-aggregategroup-461824564.md) — struct
<a id="function-function-minisql-executor-aggregate-aggregatepagerange-function-aggregatepagerange-task-src-minisql-executor-aggregate-ml-173467701"></a>
### aggregatePageRange

```ml
function aggregatePageRange(task)
```

Scans one disjoint heap-page range and returns mergeable partial states.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — | task value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L417)

- [minisql.executor.aggregate.AggregatePartitionTask](Type-minisql-executor-aggregate-aggregatepartitiontask-2048101232.md) — struct
<a id="function-function-minisql-executor-aggregate-aggregatevalue-function-aggregatevalue-expression-rows-src-minisql-executor-aggregate-ml-1815246775"></a>
### aggregateValue

```ml
function aggregateValue(expression, rows)
```

Implements aggregate value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L246)

<a id="constant-constant-minisql-executor-aggregate-binding-error-const-binding-error-9020-src-minisql-executor-aggregate-ml-1200471654"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```

Defines the binding error constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L27)

<a id="function-function-minisql-executor-aggregate-componentname-function-componentname-src-minisql-executor-aggregate-ml-1565929558"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql executor aggregate module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L1115)

<a id="function-function-minisql-executor-aggregate-createaccumulator-function-createaccumulator-expression-src-minisql-executor-aggregate-ml-136780032"></a>
### createAccumulator

```ml
function createAccumulator(expression)
```

Creates an accumulator whose neutral state matches SQL empty-input rules.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L333)

<a id="function-function-minisql-executor-aggregate-distinctvalues-function-distinctvalues-input-src-minisql-executor-aggregate-ml-777826826"></a>
### distinctValues

```ml
function distinctValues(input)
```

Implements distinct values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | input value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L219)

<a id="function-function-minisql-executor-aggregate-evaluateargument-function-evaluateargument-expression-row-src-minisql-executor-aggregate-ml-1558258396"></a>
### evaluateArgument

```ml
function evaluateArgument(expression, row)
```

Evaluates argument using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L236)

<a id="function-function-minisql-executor-aggregate-evaluategroup-function-evaluategroup-expression-rows-representative-src-minisql-executor-aggregate-ml-2049059416"></a>
### evaluateGroup

```ml
function evaluateGroup(expression, rows, representative)
```

Evaluates group using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `representative` | `dynamic` | — | representative value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L750)

<a id="function-function-minisql-executor-aggregate-evaluatelist-function-evaluatelist-boundexpressions-rows-representative-src-minisql-executor-aggregate-ml-1168022623"></a>
### evaluateList

```ml
function evaluateList(boundExpressions, rows, representative)
```

Evaluates list using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundExpressions` | `dynamic` | — | boundExpressions value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `representative` | `dynamic` | — | representative value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L868)

<a id="function-function-minisql-executor-aggregate-fail-function-fail-code-operation-message-src-minisql-executor-aggregate-ml-1897074913"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql executor aggregate module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L122)

<a id="function-function-minisql-executor-aggregate-findmatching-function-findmatching-rows-candidate-used-src-minisql-executor-aggregate-ml-45937607"></a>
### findMatching

```ml
function findMatching(rows, candidate, used)
```

Finds matching using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `candidate` | `dynamic` | — | candidate value consumed by this operation. |
| `used` | `dynamic` | — | used value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L1061)

<a id="function-function-minisql-executor-aggregate-finishaccumulator-function-finishaccumulator-state-src-minisql-executor-aggregate-ml-574208863"></a>
### finishAccumulator

```ml
function finishAccumulator(state)
```

Converts an accumulator into the same SqlValue produced by aggregateValue.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L443)

<a id="function-function-minisql-executor-aggregate-finishstreaming-function-finishstreaming-states-src-minisql-executor-aggregate-ml-1737727722"></a>
### finishStreaming

```ml
function finishStreaming(states)
```

Finalizes fixed-size accumulators into the ordinary one-row projection shape.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `states` | `dynamic` | — | states value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L490)

<a id="function-function-minisql-executor-aggregate-grouprows-function-grouprows-rows-groupexpressions-aggregatequery-src-minisql-executor-aggregate-ml-167787480"></a>
### groupRows

```ml
function groupRows(rows, groupExpressions, aggregateQuery)
```

Partitions rows with a fixed-bucket hash table and explicit collision chains. Full-key comparison preserves SQL NULL/equality semantics; the separate groups array preserves first-key encounter order. Empty global aggregation yields one group.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `groupExpressions` | `dynamic` | — | groupExpressions value consumed by this operation. |
| `aggregateQuery` | `dynamic` | — | aggregateQuery value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L882)

<a id="constant-constant-minisql-executor-aggregate-hash-bucket-count-const-hash-bucket-count-257-src-minisql-executor-aggregate-ml-470152643"></a>
### HASH_BUCKET_COUNT

```ml
const HASH_BUCKET_COUNT = 257
```

Defines the hash bucket count constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L29)

<a id="constant-constant-minisql-executor-aggregate-hash-mask-const-hash-mask-2147483647-src-minisql-executor-aggregate-ml-1770557061"></a>
### HASH_MASK

```ml
const HASH_MASK = 2147483647
```

Defines the hash mask constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L31)

<a id="function-function-minisql-executor-aggregate-hashbytes-function-hashbytes-input-seed-src-minisql-executor-aggregate-ml-350454739"></a>
### hashBytes

```ml
function hashBytes(input, seed)
```

Implements hash bytes for this module. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | input value consumed by this operation. |
| `seed` | `dynamic` | — | seed value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L131)

- [minisql.executor.aggregate.HashGroupEntry](Type-minisql-executor-aggregate-hashgroupentry-1937125899.md) — struct
<a id="function-function-minisql-executor-aggregate-hashvalue-function-hashvalue-value-src-minisql-executor-aggregate-ml-1006498035"></a>
### hashValue

```ml
function hashValue(value)
```

Implements hash value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L146)

<a id="function-function-minisql-executor-aggregate-hashvalues-function-hashvalues-input-src-minisql-executor-aggregate-ml-621631530"></a>
### hashValues

```ml
function hashValues(input)
```

Implements hash values for this module. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | input value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L182)

<a id="function-function-minisql-executor-aggregate-integerdivide-function-integerdivide-numerator-denominator-src-minisql-executor-aggregate-ml-155382195"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Computes non-negative truncating integer division for spill partition sizing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — | numerator value consumed by this operation. |
| `denominator` | `dynamic` | — | denominator value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L42)

<a id="constant-constant-minisql-executor-aggregate-intra-query-workers-const-intra-query-workers-4-src-minisql-executor-aggregate-ml-1946482825"></a>
### INTRA_QUERY_WORKERS

```ml
const INTRA_QUERY_WORKERS = 4
```

Defines the intra query workers constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L33)

<a id="constant-constant-minisql-executor-aggregate-invalid-argument-const-invalid-argument-9001-src-minisql-executor-aggregate-ml-2003255351"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Grouping, SQL aggregates and set operations. The first implementation uses


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L23)

<a id="function-function-minisql-executor-aggregate-isimplemented-function-isimplemented-src-minisql-executor-aggregate-ml-902752878"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql executor aggregate module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L1129)

<a id="function-function-minisql-executor-aggregate-mergeaccumulator-function-mergeaccumulator-target-partial-src-minisql-executor-aggregate-ml-260712376"></a>
### mergeAccumulator

```ml
function mergeAccumulator(target, partial)
```

Merges one worker's fixed-size partial aggregate into the coordinator state. AVG is represented by SUM+COUNT, while extrema and boolean folds preserve SQL NULL behavior through the explicit hasValue bit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `partial` | `dynamic` | — | partial value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L394)

<a id="constant-constant-minisql-executor-aggregate-parallel-scan-minimum-pages-const-parallel-scan-minimum-pages-128-src-minisql-executor-aggregate-ml-1190551092"></a>
### PARALLEL_SCAN_MINIMUM_PAGES

```ml
const PARALLEL_SCAN_MINIMUM_PAGES = 128
```

Defines the parallel scan minimum pages constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L37)

- [minisql.executor.aggregate.ParallelAggregateTask](Type-minisql-executor-aggregate-parallelaggregatetask-847195465.md) — struct
<a id="function-function-minisql-executor-aggregate-project-function-project-rows-selectexpressions-groupexpressions-havingexpression-orderexpressions-src-minisql-executor-aggregate-ml-1675282638"></a>
### project

```ml
function project(rows, selectExpressions, groupExpressions, havingExpression, orderExpressions)
```

Implements project for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `groupExpressions` | `dynamic` | — | groupExpressions value consumed by this operation. |
| `havingExpression` | `dynamic` | — | havingExpression value consumed by this operation. |
| `orderExpressions` | `dynamic` | — | orderExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L922)

<a id="function-function-minisql-executor-aggregate-projectedspillrows-function-projectedspillrows-rows-src-minisql-executor-aggregate-ml-1026336065"></a>
### projectedSpillRows

```ml
function projectedSpillRows(rows)
```

Converts scanned rows to the shared validated spill representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L944)

<a id="function-function-minisql-executor-aggregate-projectspilledpartition-function-projectspilledpartition-task-src-minisql-executor-aggregate-ml-1701208801"></a>
### projectSpilledPartition

```ml
function projectSpilledPartition(task)
```

Reads, aggregates, and removes one partition. Different tasks own disjoint files and disjoint hash tables, so native workers require no shared lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — | task value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L965)

<a id="function-function-minisql-executor-aggregate-projectstreamingrows-function-projectstreamingrows-rows-selectexpressions-predicate-src-minisql-executor-aggregate-ml-446170085"></a>
### projectStreamingRows

```ml
function projectStreamingRows(rows, selectExpressions, predicate)
```

Preserves the direct aggregate API for callers without server session state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L531)

<a id="function-function-minisql-executor-aggregate-projectstreamingrowscontrolled-function-projectstreamingrowscontrolled-rows-selectexpressions-predicate-database-sessionid-src-minisql-executor-aggregate-ml-107233609"></a>
### projectStreamingRowsControlled

```ml
function projectStreamingRowsControlled(rows, selectExpressions, predicate, database, sessionId)
```

Streams selected rows while honoring one server query control token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L541)

<a id="function-function-minisql-executor-aggregate-projectstreamingrowscore-function-projectstreamingrowscore-rows-selectexpressions-predicate-database-sessionid-src-minisql-executor-aggregate-ml-1185759817"></a>
### projectStreamingRowsCore

```ml
function projectStreamingRowsCore(rows, selectExpressions, predicate, database, sessionId)
```

Streams already selected rows through a predicate and fixed-size scalar aggregate state. This is used by planned index scans without rebuilding the general grouping structures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L506)

<a id="function-function-minisql-executor-aggregate-projectstreamingtable-function-projectstreamingtable-databasepath-table-pagetransaction-readcache-selectexpressions-src-minisql-executor-aggregate-ml-1700060926"></a>
### projectStreamingTable

```ml
function projectStreamingTable(databasePath, table, pageTransaction, readCache, selectExpressions)
```

Preserves unfiltered streaming aggregation for non-server callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L653)

<a id="function-function-minisql-executor-aggregate-projectstreamingtablecontrolled-function-projectstreamingtablecontrolled-databasepath-table-pagetransaction-readcache-selectexpressions-database-sessionid-src-minisql-executor-aggregate-ml-459496904"></a>
### projectStreamingTableControlled

```ml
function projectStreamingTableControlled(databasePath, table, pageTransaction, readCache, selectExpressions, database, sessionId)
```

Aggregates an unfiltered table under cooperative server control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L665)

<a id="function-function-minisql-executor-aggregate-projectstreamingtablecore-function-projectstreamingtablecore-databasepath-table-pagetransaction-readcache-selectexpressions-database-sessionid-src-minisql-executor-aggregate-ml-1145734150"></a>
### projectStreamingTableCore

```ml
function projectStreamingTableCore(databasePath, table, pageTransaction, readCache, selectExpressions, database, sessionId)
```

Keeps the unfiltered hot path branch-free inside the row loop. This function is intentionally separate from projectStreamingTableFiltered because scalar whole-table aggregates are common and execute the loop once per stored row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L623)

<a id="function-function-minisql-executor-aggregate-projectstreamingtablefiltered-function-projectstreamingtablefiltered-databasepath-table-pagetransaction-readcache-selectexpressions-predicate-requiredcolumns-src-minisql-executor-aggregate-ml-2111044177"></a>
### projectStreamingTableFiltered

```ml
function projectStreamingTableFiltered(databasePath, table, pageTransaction, readCache, selectExpressions, predicate, requiredColumns)
```

Preserves filtered streaming aggregation for non-server callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L595)

<a id="function-function-minisql-executor-aggregate-projectstreamingtablefilteredcontrolled-function-projectstreamingtablefilteredcontrolled-databasepath-table-pagetransaction-readcache-selectexpressions-predicate-requiredcolumns-database-sessionid-src-minisql-executor-aggregate-ml-519674565"></a>
### projectStreamingTableFilteredControlled

```ml
function projectStreamingTableFilteredControlled(databasePath, table, pageTransaction, readCache, selectExpressions, predicate, requiredColumns, database, sessionId)
```

Filters and aggregates a table under cooperative server control.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L609)

<a id="function-function-minisql-executor-aggregate-projectstreamingtablefilteredcore-function-projectstreamingtablefilteredcore-databasepath-table-pagetransaction-readcache-selectexpressions-predicate-requiredcolumns-database-sessionid-src-minisql-executor-aggregate-ml-2007529947"></a>
### projectStreamingTableFilteredCore

```ml
function projectStreamingTableFilteredCore(databasePath, table, pageTransaction, readCache, selectExpressions, predicate, requiredColumns, database, sessionId)
```

Streams one filtered base table through fixed-size scalar aggregate accumulators. The caller-supplied mask includes both aggregate and predicate columns, and the reader closes on every reported failure path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L557)

<a id="function-function-minisql-executor-aggregate-projectstreamingtableparallel-function-projectstreamingtableparallel-databasepath-table-readcache-selectexpressions-src-minisql-executor-aggregate-ml-959428731"></a>
### projectStreamingTableParallel

```ml
function projectStreamingTableParallel(databasePath, table, readCache, selectExpressions)
```

Preserves parallel aggregate execution for callers without a query token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L729)

<a id="function-function-minisql-executor-aggregate-projectstreamingtableparallelcontrolled-function-projectstreamingtableparallelcontrolled-databasepath-table-readcache-selectexpressions-database-sessionid-src-minisql-executor-aggregate-ml-442185683"></a>
### projectStreamingTableParallelControlled

```ml
function projectStreamingTableParallelControlled(databasePath, table, readCache, selectExpressions, database, sessionId)
```

Propagates server cancellation and deadlines into parallel aggregate workers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L740)

<a id="function-function-minisql-executor-aggregate-projectstreamingtableparallelcore-function-projectstreamingtableparallelcore-databasepath-table-readcache-selectexpressions-database-sessionid-src-minisql-executor-aggregate-ml-633892341"></a>
### projectStreamingTableParallelCore

```ml
function projectStreamingTableParallelCore(databasePath, table, readCache, selectExpressions, database, sessionId)
```

Executes an unfiltered scalar aggregate with page-partitioned native workers. Small tables and transactional readers stay on the lower-overhead serial path; every worker sees committed pages only and returns constant-size state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L678)

<a id="function-function-minisql-executor-aggregate-projectwithspill-function-projectwithspill-rows-selectexpressions-groupexpressions-havingexpression-orderexpressions-temporaryroot-threshold-src-minisql-executor-aggregate-ml-1182730562"></a>
### projectWithSpill

```ml
function projectWithSpill(rows, selectExpressions, groupExpressions, havingExpression, orderExpressions, temporaryRoot, threshold)
```

Executes grouped aggregation one hash partition at a time when the input exceeds the configured threshold. Equal group keys always select the same partition; final ORDER BY, when present, restores requested output ordering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `groupExpressions` | `dynamic` | — | groupExpressions value consumed by this operation. |
| `havingExpression` | `dynamic` | — | havingExpression value consumed by this operation. |
| `orderExpressions` | `dynamic` | — | orderExpressions value consumed by this operation. |
| `temporaryRoot` | `dynamic` | — | temporaryRoot value consumed by this operation. |
| `threshold` | `dynamic` | — | threshold value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L985)

<a id="function-function-minisql-executor-aggregate-samevalue-function-samevalue-left-right-src-minisql-executor-aggregate-ml-234742147"></a>
### sameValue

```ml
function sameValue(left, right)
```

Implements same value for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L195)

<a id="function-function-minisql-executor-aggregate-samevalues-function-samevalues-left-right-src-minisql-executor-aggregate-ml-1674414761"></a>
### sameValues

```ml
function sameValues(left, right)
```

Implements same values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L205)

<a id="function-function-minisql-executor-aggregate-scannedspillrows-function-scannedspillrows-rows-src-minisql-executor-aggregate-ml-226947013"></a>
### scannedSpillRows

```ml
function scannedSpillRows(rows)
```

Restores value-only scanned rows from a validated spill partition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L954)

<a id="function-function-minisql-executor-aggregate-setoperation-function-setoperation-leftrows-rightrows-operator-all-src-minisql-executor-aggregate-ml-1388778196"></a>
### setOperation

```ml
function setOperation(leftRows, rightRows, operator, all)
```

Implements set operation for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — | leftRows value consumed by this operation. |
| `rightRows` | `dynamic` | — | rightRows value consumed by this operation. |
| `operator` | `dynamic` | — | operator value consumed by this operation. |
| `all` | `dynamic` | — | all value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L1077)

<a id="function-function-minisql-executor-aggregate-streamingaccumulators-function-streamingaccumulators-selectexpressions-operation-src-minisql-executor-aggregate-ml-642545548"></a>
### streamingAccumulators

```ml
function streamingAccumulators(selectExpressions, operation)
```

Creates accumulator state for a validated streaming scalar aggregate list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L479)

<a id="function-function-minisql-executor-aggregate-streamingrequiredcolumns-function-streamingrequiredcolumns-table-selectexpressions-src-minisql-executor-aggregate-ml-1995208803"></a>
### streamingRequiredColumns

```ml
function streamingRequiredColumns(table, selectExpressions)
```

Builds the narrowest safe source-column mask for direct aggregate arguments. Complex scalar arguments retain full decoding while still avoiding row materialization; direct column aggregates skip unrelated external values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `selectExpressions` | `dynamic` | — | selectExpressions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L460)

<a id="function-function-minisql-executor-aggregate-targetmilestone-function-targetmilestone-src-minisql-executor-aggregate-ml-1507961956"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql executor aggregate module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L1122)

<a id="constant-constant-minisql-executor-aggregate-type-mismatch-const-type-mismatch-9017-src-minisql-executor-aggregate-ml-1339377856"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```

Defines the type mismatch constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L25)

<a id="constant-constant-minisql-executor-aggregate-vector-batch-rows-const-vector-batch-rows-256-src-minisql-executor-aggregate-ml-1760719404"></a>
### VECTOR_BATCH_ROWS

```ml
const VECTOR_BATCH_ROWS = 256
```

Defines the vector batch rows constant used by the minisql executor aggregate module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L35)
