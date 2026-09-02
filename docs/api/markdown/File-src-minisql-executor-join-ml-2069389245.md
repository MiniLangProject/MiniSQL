# `src/minisql/executor/join.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.executor.join`](Package-minisql-executor-join-4666933.md)

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

<a id="function-function-minisql-executor-join-apply-function-apply-leftrows-rightrows-boundjoin-src-minisql-executor-join-ml-582504799"></a>
### apply

```ml
function apply(leftRows, rightRows, boundJoin)
```

Executes the semantic nested-loop fallback for every supported join type. Tracks matched right rows for RIGHT/FULL padding and emits typed NULL padding for unmatched outer rows. Returns rows in deterministic left-major order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L508)

<a id="function-function-minisql-executor-join-applyhash-function-applyhash-leftrows-rightrows-boundjoin-src-minisql-executor-join-ml-1039039119"></a>
### applyHash

```ml
function applyHash(leftRows, rightRows, boundJoin)
```

Backward-compatible entry point used by direct executor tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L501)

<a id="function-function-minisql-executor-join-applyhashbuild-function-applyhashbuild-leftrows-rightrows-boundjoin-buildright-src-minisql-executor-join-ml-90075153"></a>
### applyHashBuild

```ml
function applyHashBuild(leftRows, rightRows, boundJoin, buildRight)
```

Selects a direct hash-build orientation without a server query token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L335)

<a id="function-function-minisql-executor-join-applyhashbuildcore-function-applyhashbuildcore-leftrows-rightrows-boundjoin-buildright-database-sessionid-src-minisql-executor-join-ml-61323851"></a>
### applyHashBuildCore

```ml
function applyHashBuildCore(leftRows, rightRows, boundJoin, buildRight, database, sessionId)
```

Executes the optimizer-selected hash build orientation. LEFT joins keep the right build side because unmatched-left tracking is part of that algorithm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L318)

<a id="function-function-minisql-executor-join-applyhashbuildwithspill-function-applyhashbuildwithspill-leftrows-rightrows-boundjoin-buildright-temporaryroot-threshold-src-minisql-executor-join-ml-2143391679"></a>
### applyHashBuildWithSpill

```ml
function applyHashBuildWithSpill(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold)
```

Historical direct API retains behavior without a cooperative server token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |
| `temporaryRoot` | `dynamic` | — |  |
| `threshold` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L491)

<a id="function-function-minisql-executor-join-applyhashbuildwithspillcontrolled-function-applyhashbuildwithspillcontrolled-leftrows-rightrows-boundjoin-buildright-temporaryroot-threshold-database-sessionid-src-minisql-executor-join-ml-583842025"></a>
### applyHashBuildWithSpillControlled

```ml
function applyHashBuildWithSpillControlled(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, database, sessionId)
```

Server execution path propagates cancellation/deadline state into spill workers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |
| `temporaryRoot` | `dynamic` | — |  |
| `threshold` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L496)

<a id="function-function-minisql-executor-join-applyhashbuildwithspillcore-function-applyhashbuildwithspillcore-leftrows-rightrows-boundjoin-buildright-temporaryroot-threshold-database-sessionid-src-minisql-executor-join-ml-1207558427"></a>
### applyHashBuildWithSpillCore

```ml
function applyHashBuildWithSpillCore(leftRows, rightRows, boundJoin, buildRight, temporaryRoot, threshold, database, sessionId)
```

Executes a grace-style partitioned hash join when the selected build input exceeds the row threshold. Each partition is CRC/shape validated by the shared spill codec and removed on both success and failure paths.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |
| `temporaryRoot` | `dynamic` | — |  |
| `threshold` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L397)

<a id="function-function-minisql-executor-join-applyhashleft-function-applyhashleft-leftrows-rightrows-boundjoin-src-minisql-executor-join-ml-294180477"></a>
### applyHashLeft

```ml
function applyHashLeft(leftRows, rightRows, boundJoin)
```

Preserves left-build hash joins for callers without a server query token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L330)

<a id="function-function-minisql-executor-join-applyhashleftcore-function-applyhashleftcore-leftrows-rightrows-boundjoin-database-sessionid-src-minisql-executor-join-ml-2082804693"></a>
### applyHashLeftCore

```ml
function applyHashLeftCore(leftRows, rightRows, boundJoin, database, sessionId)
```

Executes an INNER equi-join with the left input as the hash-build side. The emitted row remains `left.values + right.values`, so choosing the smaller build side never changes bound column indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L265)

<a id="function-function-minisql-executor-join-applyhashright-function-applyhashright-leftrows-rightrows-boundjoin-src-minisql-executor-join-ml-1106965383"></a>
### applyHashRight

```ml
function applyHashRight(leftRows, rightRows, boundJoin)
```

Preserves right-build hash joins for callers without a server query token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L325)

<a id="function-function-minisql-executor-join-applyhashrightcore-function-applyhashrightcore-leftrows-rightrows-boundjoin-database-sessionid-src-minisql-executor-join-ml-848546437"></a>
### applyHashRightCore

```ml
function applyHashRightCore(leftRows, rightRows, boundJoin, database, sessionId)
```

Executes an INNER or LEFT equi-join with a right-side hash table. NULL keys never match, full value comparison resolves collisions, and the original predicate is rechecked before emission. Unsupported shapes fall back.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L201)

<a id="function-function-minisql-executor-join-applyspilledpartition-function-applyspilledpartition-task-src-minisql-executor-join-ml-257639769"></a>
### applySpilledPartition

```ml
function applySpilledPartition(task)
```

Reads and joins one pair of hash partitions on a native worker. Runs are deleted by their owning task on both successful and failed reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L371)

<a id="function-function-minisql-executor-join-canhash-function-canhash-boundjoin-src-minisql-executor-join-ml-717831136"></a>
### canHash

```ml
function canHash(boundJoin)
```

Returns whether the supplied value satisfies the hash condition. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L187)

<a id="function-function-minisql-executor-join-cleanuppartitiontasks-function-cleanuppartitiontasks-tasks-src-minisql-executor-join-ml-1028962006"></a>
### cleanupPartitionTasks

```ml
function cleanupPartitionTasks(tasks)
```

Removes every spill run already owned by not-yet-submitted partition tasks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tasks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L359)

<a id="function-function-minisql-executor-join-combine-function-combine-left-right-src-minisql-executor-join-ml-875615771"></a>
### combine

```ml
function combine(left, right)
```

Implements combine for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L75)

<a id="function-function-minisql-executor-join-componentname-function-componentname-src-minisql-executor-join-ml-182550798"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L549)

<a id="function-function-minisql-executor-join-conditionpasses-function-conditionpasses-condition-row-src-minisql-executor-join-ml-1218160165"></a>
### conditionPasses

```ml
function conditionPasses(condition, row)
```

Implements condition passes for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L108)

<a id="function-function-minisql-executor-join-equalitycolumns-function-equalitycolumns-boundjoin-src-minisql-executor-join-ml-1971825006"></a>
### equalityColumns

```ml
function equalityColumns(boundJoin)
```

Implements equality columns for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L169)

<a id="function-function-minisql-executor-join-fail-function-fail-code-operation-message-src-minisql-executor-join-ml-1186142595"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L62)

<a id="constant-constant-minisql-executor-join-hash-bucket-count-const-hash-bucket-count-257-src-minisql-executor-join-ml-687203375"></a>
### HASH_BUCKET_COUNT

```ml
const HASH_BUCKET_COUNT = 257
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L24)

<a id="constant-constant-minisql-executor-join-hash-mask-const-hash-mask-2147483647-src-minisql-executor-join-ml-1849200055"></a>
### HASH_MASK

```ml
const HASH_MASK = 2147483647
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L25)

<a id="function-function-minisql-executor-join-hashbytes-function-hashbytes-input-seed-src-minisql-executor-join-ml-1202831771"></a>
### hashBytes

```ml
function hashBytes(input, seed)
```

Implements hash bytes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |
| `seed` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L117)

- [minisql.executor.join.HashJoinEntry](Type-minisql-executor-join-hashjoinentry-1527281743.md) — struct
<a id="function-function-minisql-executor-join-hashvalue-function-hashvalue-value-src-minisql-executor-join-ml-1134870723"></a>
### hashValue

```ml
function hashValue(value)
```

Implements hash value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L132)

<a id="function-function-minisql-executor-join-integerdivide-function-integerdivide-numerator-denominator-src-minisql-executor-join-ml-2085825425"></a>
### integerDivide

```ml
function integerDivide(numerator, denominator)
```

Computes non-negative truncating integer division without losing precision.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `numerator` | `dynamic` | — |  |
| `denominator` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L67)

<a id="constant-constant-minisql-executor-join-intra-query-workers-const-intra-query-workers-4-src-minisql-executor-join-ml-1610784937"></a>
### INTRA_QUERY_WORKERS

```ml
const INTRA_QUERY_WORKERS = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L26)

<a id="constant-constant-minisql-executor-join-invalid-argument-const-invalid-argument-9001-src-minisql-executor-join-ml-2026853893"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Join executor. M16 provides the correctness-first nested-loop implementation. M46 adds a deterministic hash path for INNER/LEFT equality joins while keeping nested loops as the semantic fallback for all other predicates and outer joins.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L23)

<a id="function-function-minisql-executor-join-isimplemented-function-isimplemented-src-minisql-executor-join-ml-1916872414"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L563)

- [minisql.executor.join.JoinPartitionTask](Type-minisql-executor-join-joinpartitiontask-547162216.md) — struct
<a id="function-function-minisql-executor-join-nullvalues-function-nullvalues-table-src-minisql-executor-join-ml-995927156"></a>
### nullValues

```ml
function nullValues(table)
```

Implements null values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L83)

<a id="function-function-minisql-executor-join-nullvaluesfortypes-function-nullvaluesfortypes-typeinfos-src-minisql-executor-join-ml-294311717"></a>
### nullValuesForTypes

```ml
function nullValuesForTypes(typeInfos)
```

Implements null values for types for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeInfos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L95)

<a id="function-function-minisql-executor-join-polljoincontrol-function-polljoincontrol-database-sessionid-counter-operation-src-minisql-executor-join-ml-588140083"></a>
### pollJoinControl

```ml
function pollJoinControl(database, sessionId, counter, operation)
```

Polls a server-owned query at bounded hash-operator intervals. Direct module tests pass a void database and retain the dependency-free historical API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `counter` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L54)

<a id="function-function-minisql-executor-join-projectedspillrows-function-projectedspillrows-rows-src-minisql-executor-join-ml-1439279559"></a>
### projectedSpillRows

```ml
function projectedSpillRows(rows)
```

Converts scanned rows to the generic validated spill-run representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L340)

<a id="function-function-minisql-executor-join-scannedspillrows-function-scannedspillrows-rows-src-minisql-executor-join-ml-1413995643"></a>
### scannedSpillRows

```ml
function scannedSpillRows(rows)
```

Restores value-only scanned rows after a validated spill-run read.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L350)

<a id="function-function-minisql-executor-join-targetmilestone-function-targetmilestone-src-minisql-executor-join-ml-1165845932"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L556)
