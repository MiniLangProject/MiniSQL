# `src/minisql/planner/execution_plan.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql planner execution plan facilities for this project.

Package: [`minisql.planner.execution_plan`](Package-minisql-planner-execution-plan-83311438.md)

Reachable from entry: **yes**

## Imports

- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)

## Declarations

<a id="constant-constant-minisql-planner-execution-plan-access-index-const-access-index-2-src-minisql-planner-execution-plan-ml-286818709"></a>
### ACCESS_INDEX

```ml
const ACCESS_INDEX = 2
```

Defines the access index constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L22)

<a id="constant-constant-minisql-planner-execution-plan-access-index-intersection-const-access-index-intersection-4-src-minisql-planner-execution-plan-ml-2006758827"></a>
### ACCESS_INDEX_INTERSECTION

```ml
const ACCESS_INDEX_INTERSECTION = 4
```

Defines the access index intersection constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L26)

<a id="constant-constant-minisql-planner-execution-plan-access-index-only-const-access-index-only-3-src-minisql-planner-execution-plan-ml-398745894"></a>
### ACCESS_INDEX_ONLY

```ml
const ACCESS_INDEX_ONLY = 3
```

Defines the access index only constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L24)

<a id="constant-constant-minisql-planner-execution-plan-access-index-union-const-access-index-union-5-src-minisql-planner-execution-plan-ml-211013056"></a>
### ACCESS_INDEX_UNION

```ml
const ACCESS_INDEX_UNION = 5
```

Defines the access index union constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L28)

<a id="constant-constant-minisql-planner-execution-plan-access-sequential-const-access-sequential-1-src-minisql-planner-execution-plan-ml-1882249308"></a>
### ACCESS_SEQUENTIAL

```ml
const ACCESS_SEQUENTIAL = 1
```

Defines the access sequential constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L20)

<a id="constant-constant-minisql-planner-execution-plan-aggregate-count-slots-const-aggregate-count-slots-2-src-minisql-planner-execution-plan-ml-1360733669"></a>
### AGGREGATE_COUNT_SLOTS

```ml
const AGGREGATE_COUNT_SLOTS = 2
```

Defines the aggregate count slots constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L42)

<a id="constant-constant-minisql-planner-execution-plan-aggregate-hash-const-aggregate-hash-1-src-minisql-planner-execution-plan-ml-1775724674"></a>
### AGGREGATE_HASH

```ml
const AGGREGATE_HASH = 1
```

Defines the aggregate hash constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L40)

<a id="constant-constant-minisql-planner-execution-plan-aggregate-join-count-const-aggregate-join-count-4-src-minisql-planner-execution-plan-ml-1892316529"></a>
### AGGREGATE_JOIN_COUNT

```ml
const AGGREGATE_JOIN_COUNT = 4
```

Defines the aggregate join count constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L46)

<a id="constant-constant-minisql-planner-execution-plan-aggregate-none-const-aggregate-none-0-src-minisql-planner-execution-plan-ml-507342021"></a>
### AGGREGATE_NONE

```ml
const AGGREGATE_NONE = 0
```

Defines the aggregate none constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L38)

<a id="constant-constant-minisql-planner-execution-plan-aggregate-stream-const-aggregate-stream-3-src-minisql-planner-execution-plan-ml-360111944"></a>
### AGGREGATE_STREAM

```ml
const AGGREGATE_STREAM = 3
```

Defines the aggregate stream constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L44)

<a id="function-function-minisql-planner-execution-plan-componentname-function-componentname-src-minisql-planner-execution-plan-ml-1500856384"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic component name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L207)

<a id="function-function-minisql-planner-execution-plan-context-function-context-statistics-indexes-schemageneration-src-minisql-planner-execution-plan-ml-1465209598"></a>
### context

```ml
function context(statistics, indexes, schemaGeneration)
```

Builds an immutable optimizer input snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statistics` | `dynamic` | — | statistics value consumed by this operation. |
| `indexes` | `dynamic` | — | indexes value consumed by this operation. |
| `schemaGeneration` | `dynamic` | — | schemaGeneration value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L176)

- [minisql.planner.execution_plan.ExecutionPlan](Type-minisql-planner-execution-plan-executionplan-1596690013.md) — struct
<a id="function-function-minisql-planner-execution-plan-fail-function-fail-code-operation-message-src-minisql-planner-execution-plan-ml-1248845663"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates an execution-plan error carrying operation context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L147)

<a id="function-function-minisql-planner-execution-plan-indexesfortable-function-indexesfortable-value-tableid-src-minisql-planner-execution-plan-ml-50932540"></a>
### indexesForTable

```ml
function indexesForTable(value, tableId)
```

Returns all index descriptors owned by one table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `tableId` | `dynamic` | — | Identifier of table. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L196)

<a id="function-function-minisql-planner-execution-plan-indexinfo-function-indexinfo-tableid-name-columnindexes-keyexpressions-includedcolumnindexes-predicate-unique-src-minisql-planner-execution-plan-ml-204855786"></a>
### indexInfo

```ml
function indexInfo(tableId, name, columnIndexes, keyExpressions, includedColumnIndexes, predicate, unique)
```

Validates and constructs catalog-independent index metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — | Identifier of table. |
| `name` | `dynamic` | — | Name of the affected item. |
| `columnIndexes` | `dynamic` | — | columnIndexes value consumed by this operation. |
| `keyExpressions` | `dynamic` | — | keyExpressions value consumed by this operation. |
| `includedColumnIndexes` | `dynamic` | — | includedColumnIndexes value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |
| `unique` | `dynamic` | — | unique value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L159)

- [minisql.planner.execution_plan.IndexInfo](Type-minisql-planner-execution-plan-indexinfo-667866752.md) — struct
<a id="constant-constant-minisql-planner-execution-plan-invalid-argument-const-invalid-argument-9001-src-minisql-planner-execution-plan-ml-1451222473"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L17)

<a id="function-function-minisql-planner-execution-plan-isexecutionplan-function-isexecutionplan-value-src-minisql-planner-execution-plan-ml-234612605"></a>
### isExecutionPlan

```ml
function isExecutionPlan(value)
```

Reports whether a value is a complete ExecutionPlan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L189)

<a id="function-function-minisql-planner-execution-plan-isimplemented-function-isimplemented-src-minisql-planner-execution-plan-ml-1321296536"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the component is fully implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L217)

<a id="function-function-minisql-planner-execution-plan-isplanningcontext-function-isplanningcontext-value-src-minisql-planner-execution-plan-ml-538934375"></a>
### isPlanningContext

```ml
function isPlanningContext(value)
```

Reports whether a value is a PlanningContext.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L183)

<a id="constant-constant-minisql-planner-execution-plan-join-hash-const-join-hash-2-src-minisql-planner-execution-plan-ml-523503381"></a>
### JOIN_HASH

```ml
const JOIN_HASH = 2
```

Defines the join hash constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L33)

<a id="constant-constant-minisql-planner-execution-plan-join-index-nested-loop-const-join-index-nested-loop-3-src-minisql-planner-execution-plan-ml-1579923772"></a>
### JOIN_INDEX_NESTED_LOOP

```ml
const JOIN_INDEX_NESTED_LOOP = 3
```

Defines the join index nested loop constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L35)

<a id="constant-constant-minisql-planner-execution-plan-join-nested-loop-const-join-nested-loop-1-src-minisql-planner-execution-plan-ml-2003472972"></a>
### JOIN_NESTED_LOOP

```ml
const JOIN_NESTED_LOOP = 1
```

Defines the join nested loop constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L31)

- [minisql.planner.execution_plan.JoinPlan](Type-minisql-planner-execution-plan-joinplan-651583843.md) — struct
- [minisql.planner.execution_plan.PlanningContext](Type-minisql-planner-execution-plan-planningcontext-482159992.md) — struct
<a id="constant-constant-minisql-planner-execution-plan-sort-external-const-sort-external-2-src-minisql-planner-execution-plan-ml-1889971461"></a>
### SORT_EXTERNAL

```ml
const SORT_EXTERNAL = 2
```

Defines the sort external constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L53)

<a id="constant-constant-minisql-planner-execution-plan-sort-memory-const-sort-memory-1-src-minisql-planner-execution-plan-ml-563121668"></a>
### SORT_MEMORY

```ml
const SORT_MEMORY = 1
```

Defines the sort memory constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L51)

<a id="constant-constant-minisql-planner-execution-plan-sort-none-const-sort-none-0-src-minisql-planner-execution-plan-ml-625089695"></a>
### SORT_NONE

```ml
const SORT_NONE = 0
```

Defines the sort none constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L49)

<a id="constant-constant-minisql-planner-execution-plan-sort-top-n-const-sort-top-n-3-src-minisql-planner-execution-plan-ml-2121836582"></a>
### SORT_TOP_N

```ml
const SORT_TOP_N = 3
```

Defines the sort top n constant used by the minisql planner execution plan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L55)

- [minisql.planner.execution_plan.SourcePlan](Type-minisql-planner-execution-plan-sourceplan-215443890.md) — struct
<a id="function-function-minisql-planner-execution-plan-targetmilestone-function-targetmilestone-src-minisql-planner-execution-plan-ml-714709122"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone whose executor contract this module extends.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L212)
