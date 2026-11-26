# `src/minisql/executor/executor.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql executor executor facilities for this project.

Package: [`minisql.executor.executor`](Package-minisql-executor-executor-575459312.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/catalog/statistics.ml` as `statistics` → [src/minisql/catalog/statistics.ml](File-src-minisql-catalog-statistics-ml-1707584758.md)
- `minisql/common/diagnostics.ml` as `diagnostics` → [src/minisql/common/diagnostics.ml](File-src-minisql-common-diagnostics-ml-1805539733.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/executor/aggregate.ml` as `aggregate` → [src/minisql/executor/aggregate.ml](File-src-minisql-executor-aggregate-ml-1058141144.md)
- `minisql/executor/dml.ml` as `dml` → [src/minisql/executor/dml.ml](File-src-minisql-executor-dml-ml-1278137778.md)
- `minisql/executor/filter.ml` as `filter` → [src/minisql/executor/filter.ml](File-src-minisql-executor-filter-ml-1336995315.md)
- `minisql/executor/join.ml` as `join` → [src/minisql/executor/join.ml](File-src-minisql-executor-join-ml-2069389245.md)
- `minisql/executor/projection.ml` as `projection` → [src/minisql/executor/projection.ml](File-src-minisql-executor-projection-ml-1842888238.md)
- `minisql/executor/routine_state.ml` as `routine_state` → [src/minisql/executor/routine_state.ml](File-src-minisql-executor-routine-state-ml-1687727431.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/executor/sort.ml` as `sort` → [src/minisql/executor/sort.ml](File-src-minisql-executor-sort-ml-267147473.md)
- `minisql/planner/execution_plan.ml` as `execution_plan` → [src/minisql/planner/execution_plan.ml](File-src-minisql-planner-execution-plan-ml-1727378828.md)
- `minisql/planner/logical_plan.ml` as `logical_plan` → [src/minisql/planner/logical_plan.ml](File-src-minisql-planner-logical-plan-ml-661531493.md)
- `minisql/planner/optimizer.ml` as `optimizer` → [src/minisql/planner/optimizer.ml](File-src-minisql-planner-optimizer-ml-1479207859.md)
- `minisql/planner/physical_plan.ml` as `physical_plan` → [src/minisql/planner/physical_plan.ml](File-src-minisql-planner-physical-plan-ml-736569249.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `minisql/storage/buffer_pool.ml` as `buffer_pool` → [src/minisql/storage/buffer_pool.ml](File-src-minisql-storage-buffer-pool-ml-1867626530.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/table_header.ml` as `table_header` → [src/minisql/storage/table_header.ml](File-src-minisql-storage-table-header-ml-163902973.md)
- `minisql/transaction/transaction.ml` as `transaction` → [src/minisql/transaction/transaction.ml](File-src-minisql-transaction-transaction-ml-1157597470.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency
- `std/string.ml` as `string_api` → `../MiniLangCompilerML/std/string.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-executor-abortforconcurrency-function-abortforconcurrency-engine-src-minisql-executor-executor-ml-430320414"></a>
### abortForConcurrency

```ml
function abortForConcurrency(engine)
```

Implements abort for concurrency for this module. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5387)

<a id="function-function-minisql-executor-executor-allprivilegecodes-function-allprivilegecodes-objecttype-src-minisql-executor-executor-ml-2013702411"></a>
### allPrivilegeCodes

```ml
function allPrivilegeCodes(objectType)
```

Implements all privilege codes for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4476)

<a id="constant-constant-minisql-executor-executor-analyze-sample-rows-const-analyze-sample-rows-8192-src-minisql-executor-executor-ml-481528021"></a>
### ANALYZE_SAMPLE_ROWS

```ml
const ANALYZE_SAMPLE_ROWS = 8192
```

Defines the analyze sample rows constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L57)

<a id="function-function-minisql-executor-executor-analyzecolumngroups-function-analyzecolumngroups-engine-table-src-minisql-executor-executor-ml-189656278"></a>
### analyzeColumnGroups

```ml
function analyzeColumnGroups(engine, table)
```

Implements analyze table for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies. Returns distinct composite index keys eligible for joint NDV statistics. ANALYZE limits persisted groups to eight columns so the v4 catalog remains compact and deterministic even when applications define very wide indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3872)

<a id="function-function-minisql-executor-executor-analyzetable-function-analyzetable-engine-state-table-src-minisql-executor-executor-ml-945335429"></a>
### analyzeTable

```ml
function analyzeTable(engine, state, table)
```

Refreshes one table's exact population, bounded sample distributions, joint composite-key statistics, and physical page count in the supplied catalog.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3909)

<a id="function-function-minisql-executor-executor-appendauditoutcome-function-appendauditoutcome-engine-statement-success-detail-src-minisql-executor-executor-ml-1368843043"></a>
### appendAuditOutcome

```ml
function appendAuditOutcome(engine, statement, success, detail)
```

Appends audit outcome using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `success` | `dynamic` | — | success value consumed by this operation. |
| `detail` | `dynamic` | — | detail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5111)

<a id="function-function-minisql-executor-executor-attach-function-attach-database-src-minisql-executor-executor-ml-862535765"></a>
### attach

```ml
function attach(database)
```

Implements attach for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L476)

<a id="function-function-minisql-executor-executor-auditaction-function-auditaction-statement-src-minisql-executor-executor-ml-1320155247"></a>
### auditAction

```ml
function auditAction(statement)
```

Implements audit action for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5039)

<a id="function-function-minisql-executor-executor-auditeventtype-function-auditeventtype-statement-src-minisql-executor-executor-ml-1385440821"></a>
### auditEventType

```ml
function auditEventType(statement)
```

Implements audit event type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5096)

<a id="constant-constant-minisql-executor-executor-authentication-required-const-authentication-required-9028-src-minisql-executor-executor-ml-41784456"></a>
### AUTHENTICATION_REQUIRED

```ml
const AUTHENTICATION_REQUIRED = 9028
```

Defines the authentication required constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L63)

<a id="function-function-minisql-executor-executor-authorizedatastatement-function-authorizedatastatement-engine-statement-src-minisql-executor-executor-ml-1255786131"></a>
### authorizeDataStatement

```ml
function authorizeDataStatement(engine, statement)
```

Authorizes INSERT, UPDATE, DELETE, MERGE, and TRUNCATE expression trees.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine and authenticated principal. |
| `statement` | `dynamic` | — | Bound data-changing statement to authorize. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4336)

<a id="function-function-minisql-executor-executor-authorizedefinitionstatement-function-authorizedefinitionstatement-engine-statement-src-minisql-executor-executor-ml-1660165123"></a>
### authorizeDefinitionStatement

```ml
function authorizeDefinitionStatement(engine, statement)
```

Authorizes schema and maintenance statements in one isolated dispatcher.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine and authenticated principal. |
| `statement` | `dynamic` | — | Bound definition or maintenance statement to authorize. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4387)

<a id="function-function-minisql-executor-executor-authorizeexpressionqueriesinternal-function-authorizeexpressionqueriesinternal-engine-expression-viewstack-ctenames-src-minisql-executor-executor-ml-1488344617"></a>
### authorizeExpressionQueriesInternal

```ml
function authorizeExpressionQueriesInternal(engine, expression, viewStack, cteNames)
```

Implements authorize expression queries internal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `viewStack` | `dynamic` | — | viewStack value consumed by this operation. |
| `cteNames` | `dynamic` | — | cteNames value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4177)

<a id="function-function-minisql-executor-executor-authorizenamedsource-function-authorizenamedsource-engine-state-name-viewstack-src-minisql-executor-executor-ml-622327367"></a>
### authorizeNamedSource

```ml
function authorizeNamedSource(engine, state, name, viewStack)
```

Implements authorize named source for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `name` | `dynamic` | — | Name of the affected item. |
| `viewStack` | `dynamic` | — | viewStack value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4245)

<a id="function-function-minisql-executor-executor-authorizeselect-function-authorizeselect-engine-statement-src-minisql-executor-executor-ml-1328749105"></a>
### authorizeSelect

```ml
function authorizeSelect(engine, statement)
```

Implements authorize select for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4311)

<a id="function-function-minisql-executor-executor-authorizeselectinternal-function-authorizeselectinternal-engine-statement-viewstack-inheritedctenames-src-minisql-executor-executor-ml-243315710"></a>
### authorizeSelectInternal

```ml
function authorizeSelectInternal(engine, statement, viewStack, inheritedCteNames)
```

Implements authorize select internal for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `viewStack` | `dynamic` | — | viewStack value consumed by this operation. |
| `inheritedCteNames` | `dynamic` | — | inheritedCteNames value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4272)

<a id="function-function-minisql-executor-executor-authorizeselectitems-function-authorizeselectitems-engine-items-src-minisql-executor-executor-ml-161153294"></a>
### authorizeSelectItems

```ml
function authorizeSelectItems(engine, items)
```

Implements authorize select items for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4320)

<a id="function-function-minisql-executor-executor-authorizestatement-function-authorizestatement-engine-statement-src-minisql-executor-executor-ml-412202411"></a>
### authorizeStatement

```ml
function authorizeStatement(engine, statement)
```

Authorizes a statement against the active engine security context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine and authenticated principal. |
| `statement` | `dynamic` | — | Bound SQL statement to authorize or classify as public. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4421)

<a id="function-function-minisql-executor-executor-beginexplicit-function-beginexplicit-engine-statement-src-minisql-executor-executor-ml-1230393825"></a>
### beginExplicit

```ml
function beginExplicit(engine, statement)
```

Implements begin explicit for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1326)

<a id="function-function-minisql-executor-executor-beginquerycontrol-function-beginquerycontrol-engine-src-minisql-executor-executor-ml-280625674"></a>
### beginQueryControl

```ml
function beginQueryControl(engine)
```

Starts one top-level cooperative token after global memory admission.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L403)

<a id="function-function-minisql-executor-executor-bind-function-bind-statement-engine-src-minisql-executor-executor-ml-179120623"></a>
### bind

```ml
function bind(statement, engine)
```

Binds bind using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1378)

<a id="constant-constant-minisql-executor-executor-binding-error-const-binding-error-9020-src-minisql-executor-executor-ml-846252900"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```

Defines the binding error constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L53)

<a id="function-function-minisql-executor-executor-boundcolumncount-function-boundcolumncount-bound-src-minisql-executor-executor-ml-244227792"></a>
### boundColumnCount

```ml
function boundColumnCount(bound)
```

Computes the global flattened column width of all bound sources.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2554)

<a id="function-function-minisql-executor-executor-buildcanonicalhashbuckets-function-buildcanonicalhashbuckets-engine-rows-keycolumn-operation-src-minisql-executor-executor-ml-1172462147"></a>
### buildCanonicalHashBuckets

```ml
function buildCanonicalHashBuckets(engine, rows, keyColumn, operation)
```

Builds the fixed hash-bucket array shared by materializing and COUNT joins.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine used for expression evaluation. |
| `rows` | `dynamic` | — | Build-side rows to partition into hash buckets. |
| `keyColumn` | `dynamic` | — | Bound join-key expression evaluated for each row. |
| `operation` | `dynamic` | — | Diagnostic operation name used by validation errors. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2685)

- [minisql.executor.executor.CachedPlan](Type-minisql-executor-executor-cachedplan-851955911.md) — struct
<a id="function-function-minisql-executor-executor-canonicalequalitycolumns-function-canonicalequalitycolumns-condition-source-src-minisql-executor-executor-ml-997459808"></a>
### canonicalEqualityColumns

```ml
function canonicalEqualityColumns(condition, source)
```

Returns [joined-side global column, new-source local column] for a canonical equality join, or void for an unsupported condition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — | condition value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2670)

<a id="function-function-minisql-executor-executor-canonicalhashjoin-function-canonicalhashjoin-engine-bound-leftrows-rightrows-sourceindex-condition-buildright-src-minisql-executor-executor-ml-1834696111"></a>
### canonicalHashJoin

```ml
function canonicalHashJoin(engine, bound, leftRows, rightRows, sourceIndex, condition, buildRight)
```

Hash-joins a reordered INNER source while preserving canonical SQL column positions. Full key equality and predicate rechecks resolve collisions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `leftRows` | `dynamic` | — | leftRows value consumed by this operation. |
| `rightRows` | `dynamic` | — | rightRows value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `condition` | `dynamic` | — | condition value consumed by this operation. |
| `buildRight` | `dynamic` | — | buildRight value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2714)

<a id="function-function-minisql-executor-executor-canonicalhashjoincount-function-canonicalhashjoincount-engine-bound-leftrows-rightrows-sourceindex-condition-buildright-src-minisql-executor-executor-ml-180714507"></a>
### canonicalHashJoinCount

```ml
function canonicalHashJoinCount(engine, bound, leftRows, rightRows, sourceIndex, condition, buildRight)
```

Counts a final reordered hash join without materializing result rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine used for expression evaluation. |
| `bound` | `dynamic` | — | Bound SELECT statement and source layout. |
| `leftRows` | `dynamic` | — | Canonical rows from the left join input. |
| `rightRows` | `dynamic` | — | Compact rows from the right join input. |
| `sourceIndex` | `dynamic` | — | Position at which right rows join the canonical layout. |
| `condition` | `dynamic` | — | Optional residual join predicate. |
| `buildRight` | `dynamic` | — | Selects which input is used as the hash build side. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2868)

<a id="function-function-minisql-executor-executor-canonicalhashjoincountprobeleft-function-canonicalhashjoincountprobeleft-engine-bound-leftrows-buckets-sourceindex-condition-joinedcolumn-src-minisql-executor-executor-ml-404477378"></a>
### canonicalHashJoinCountProbeLeft

```ml
function canonicalHashJoinCountProbeLeft(engine, bound, leftRows, buckets, sourceIndex, condition, joinedColumn)
```

Probes right-side buckets with canonical left rows and counts valid matches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine used for residual evaluation. |
| `bound` | `dynamic` | — | Bound SELECT statement and source layout. |
| `leftRows` | `dynamic` | — | Canonical rows from the left join input. |
| `buckets` | `dynamic` | — | Hash buckets built from right-side rows. |
| `sourceIndex` | `dynamic` | — | Position at which the compact row is joined. |
| `condition` | `dynamic` | — | Optional residual join predicate. |
| `joinedColumn` | `dynamic` | — | Bound key expression for the probing row. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2802)

<a id="function-function-minisql-executor-executor-canonicalhashjoincountproberight-function-canonicalhashjoincountproberight-engine-bound-rightrows-buckets-sourceindex-condition-localcolumn-src-minisql-executor-executor-ml-1377943377"></a>
### canonicalHashJoinCountProbeRight

```ml
function canonicalHashJoinCountProbeRight(engine, bound, rightRows, buckets, sourceIndex, condition, localColumn)
```

Probes left-side buckets with compact right rows and counts valid matches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution engine used for residual evaluation. |
| `bound` | `dynamic` | — | Bound SELECT statement and source layout. |
| `rightRows` | `dynamic` | — | Compact rows from the right join input. |
| `buckets` | `dynamic` | — | Hash buckets built from left-side rows. |
| `sourceIndex` | `dynamic` | — | Position at which the compact row is joined. |
| `condition` | `dynamic` | — | Optional residual join predicate. |
| `localColumn` | `dynamic` | — | Bound key expression for the probing row. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2835)

<a id="function-function-minisql-executor-executor-canonicalizerows-function-canonicalizerows-bound-sourceindex-rows-src-minisql-executor-executor-ml-2021242146"></a>
### canonicalizeRows

```ml
function canonicalizeRows(bound, sourceIndex, rows)
```

Expands a compact source row set into stable global bound-column positions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2603)

<a id="function-function-minisql-executor-executor-canonicalnestedjoin-function-canonicalnestedjoin-engine-bound-leftrows-rightrows-sourceindex-condition-src-minisql-executor-executor-ml-1881530059"></a>
### canonicalNestedJoin

```ml
function canonicalNestedJoin(engine, bound, leftRows, rightRows, sourceIndex, condition)
```

Applies the semantic nested-loop fallback to one reordered INNER join edge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `leftRows` | `dynamic` | — | leftRows value consumed by this operation. |
| `rightRows` | `dynamic` | — | rightRows value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `condition` | `dynamic` | — | condition value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2649)

<a id="function-function-minisql-executor-executor-canonicalnestedjoincount-function-canonicalnestedjoincount-engine-bound-leftrows-rightrows-sourceindex-condition-src-minisql-executor-executor-ml-478190553"></a>
### canonicalNestedJoinCount

```ml
function canonicalNestedJoinCount(engine, bound, leftRows, rightRows, sourceIndex, condition)
```

Counts a final reordered nested-loop join without retaining its joined rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `leftRows` | `dynamic` | — | leftRows value consumed by this operation. |
| `rightRows` | `dynamic` | — | rightRows value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `condition` | `dynamic` | — | condition value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2777)

<a id="function-function-minisql-executor-executor-canonicalnullvalues-function-canonicalnullvalues-bound-src-minisql-executor-executor-ml-833623414"></a>
### canonicalNullValues

```ml
function canonicalNullValues(bound)
```

Creates a complete, type-correct canonical row. Typed SQL NULL placeholders keep global bound-column positions evaluable while a reordered join has not yet attached every source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2567)

<a id="function-function-minisql-executor-executor-canonicalsourcerow-function-canonicalsourcerow-bound-sourceindex-row-src-minisql-executor-executor-ml-186814829"></a>
### canonicalSourceRow

```ml
function canonicalSourceRow(bound, sourceIndex, row)
```

Expands one local source row into canonical bound-column positions. The membership/reference array lets a reordered join fill sources without inferring presence from SQL NULL values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2585)

<a id="function-function-minisql-executor-executor-clearstatementwarnings-function-clearstatementwarnings-engine-src-minisql-executor-executor-ml-2068796154"></a>
### clearStatementWarnings

```ml
function clearStatementWarnings(engine)
```

Replaces the public warning list after a nondiagnostic query has captured variables.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7107)

<a id="function-function-minisql-executor-executor-close-function-close-engine-src-minisql-executor-executor-ml-1972374698"></a>
### close

```ml
function close(engine)
```

Closes close owned by the minisql executor executor module. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5411)

<a id="constant-constant-minisql-executor-executor-closed-handle-const-closed-handle-9008-src-minisql-executor-executor-ml-1236346350"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L49)

<a id="function-function-minisql-executor-executor-closeselectcursor-function-closeselectcursor-cursor-src-minisql-executor-executor-ml-2056924830"></a>
### closeSelectCursor

```ml
function closeSelectCursor(cursor)
```

Releases every resource held by a forward-only SELECT cursor. Cleanup is idempotent so protocol disconnect and normal exhaustion can share this path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3458)

<a id="function-function-minisql-executor-executor-collectrequiredcolumns-function-collectrequiredcolumns-expression-requiredcolumns-src-minisql-executor-executor-ml-1062741646"></a>
### collectRequiredColumns

```ml
function collectRequiredColumns(expression, requiredColumns)
```

Marks every base-table column referenced by an expression tree. Returning false disables projection pushdown for shapes whose dependencies cannot be proven locally (notably correlated subqueries).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3280)

<a id="function-function-minisql-executor-executor-combinecanonical-function-combinecanonical-bound-left-sourceindex-right-src-minisql-executor-executor-ml-149994786"></a>
### combineCanonical

```ml
function combineCanonical(bound, left, sourceIndex, right)
```

Adds one compact source row to an already canonical join row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `sourceIndex` | `dynamic` | — | Zero-based index of source. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2616)

<a id="function-function-minisql-executor-executor-commandresult-function-commandresult-command-affectedrows-message-src-minisql-executor-executor-ml-2114383351"></a>
### commandResult

```ml
function commandResult(command, affectedRows, message)
```

Implements command result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — | command value consumed by this operation. |
| `affectedRows` | `dynamic` | — | affectedRows value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L304)

<a id="function-function-minisql-executor-executor-commitexplicit-function-commitexplicit-engine-src-minisql-executor-executor-ml-1886859938"></a>
### commitExplicit

```ml
function commitExplicit(engine)
```

Implements commit explicit for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4014)

<a id="function-function-minisql-executor-executor-commitpagetransaction-function-commitpagetransaction-engine-pagetransaction-deltabound-deltaresult-src-minisql-executor-executor-ml-440886384"></a>
### commitPageTransaction

```ml
function commitPageTransaction(engine, pageTransaction, deltaBound, deltaResult)
```

Implements commit page transaction for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `deltaBound` | `dynamic` | — | deltaBound value consumed by this operation. |
| `deltaResult` | `dynamic` | — | deltaResult value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2127)

<a id="function-function-minisql-executor-executor-componentname-function-componentname-src-minisql-executor-executor-ml-404001540"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql executor executor module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5428)

<a id="function-function-minisql-executor-executor-constantparameterexpression-function-constantparameterexpression-expression-src-minisql-executor-executor-ml-141129440"></a>
### constantParameterExpression

```ml
function constantParameterExpression(expression)
```

Implements constant parameter expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L617)

<a id="constant-constant-minisql-executor-executor-constraint-violation-const-constraint-violation-9021-src-minisql-executor-executor-ml-335193633"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```

Defines the constraint violation constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L55)

<a id="function-function-minisql-executor-executor-constraintkindname-function-constraintkindname-kind-src-minisql-executor-executor-ml-59503758"></a>
### constraintKindName

```ml
function constraintKindName(kind)
```

Implements constraint kind name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4722)

<a id="function-function-minisql-executor-executor-controllednestedjoin-function-controllednestedjoin-engine-leftrows-rightrows-boundjoin-src-minisql-executor-executor-ml-1211212559"></a>
### controlledNestedJoin

```ml
function controlledNestedJoin(engine, leftRows, rightRows, boundJoin)
```

Applies the semantic nested-loop join while polling inside the candidate loop. Keeping the control-aware orchestration in this module avoids coupling the reusable row-combination module to server session state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `leftRows` | `dynamic` | — | leftRows value consumed by this operation. |
| `rightRows` | `dynamic` | — | rightRows value consumed by this operation. |
| `boundJoin` | `dynamic` | — | boundJoin value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3006)

<a id="constant-constant-minisql-executor-executor-corrupt-data-const-corrupt-data-9004-src-minisql-executor-executor-ml-511771980"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L47)

<a id="function-function-minisql-executor-executor-currentplanninggeneration-function-currentplanninggeneration-engine-src-minisql-executor-executor-ml-1657511006"></a>
### currentPlanningGeneration

```ml
function currentPlanningGeneration(engine)
```

Returns the process-local planning generation shared across attached sessions. Committed DDL and statistics maintenance advance this counter while the execution gate is held, avoiding a schema-history file read per EXECUTE. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L593)

<a id="function-function-minisql-executor-executor-currentsequencevalue-function-currentsequencevalue-engine-name-src-minisql-executor-executor-ml-195081905"></a>
### currentSequenceValue

```ml
function currentSequenceValue(engine, name)
```

Implements current sequence value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L580)

<a id="constant-constant-minisql-executor-executor-cursor-source-batch-rows-const-cursor-source-batch-rows-16-src-minisql-executor-executor-ml-835040656"></a>
### CURSOR_SOURCE_BATCH_ROWS

```ml
const CURSOR_SOURCE_BATCH_ROWS = 16
```

Cursor scans retain at most the historical sixteen source rows at once, then


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L85)

<a id="constant-constant-minisql-executor-executor-cursor-target-batch-bytes-const-cursor-target-batch-bytes-1048552-src-minisql-executor-executor-ml-1571366116"></a>
### CURSOR_TARGET_BATCH_BYTES

```ml
const CURSOR_TARGET_BATCH_BYTES = 1048552
```

Defines the cursor target batch bytes constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L87)

<a id="function-function-minisql-executor-executor-databasehandle-function-databasehandle-engine-src-minisql-executor-executor-ml-843164806"></a>
### databaseHandle

```ml
function databaseHandle(engine)
```

Implements database handle for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4103)

<a id="function-function-minisql-executor-executor-dcltarget-function-dcltarget-engine-objecttype-objectname-src-minisql-executor-executor-ml-115961041"></a>
### dclTarget

```ml
function dclTarget(engine, objectType, objectName)
```

Implements dcl target for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |
| `objectName` | `dynamic` | — | objectName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4509)

<a id="constant-constant-minisql-executor-executor-ddl-state-const-ddl-state-9023-src-minisql-executor-executor-ml-2108451247"></a>
### DDL_STATE

```ml
const DDL_STATE = 9023
```

Defines the ddl state constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L59)

<a id="function-function-minisql-executor-executor-decodeprocedureparameternames-function-decodeprocedureparameternames-encoded-src-minisql-executor-executor-ml-1001483478"></a>
### decodeProcedureParameterNames

```ml
function decodeProcedureParameterNames(encoded)
```

Decodes ordered parameter names while accepting the pre-metadata representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1990)

<a id="function-function-minisql-executor-executor-decodeprocedureparametertype-function-decodeprocedureparametertype-encoded-parameterindex-src-minisql-executor-executor-ml-885778835"></a>
### decodeProcedureParameterType

```ml
function decodeProcedureParameterType(encoded, parameterIndex)
```

Reconstructs one declared SQL parameter type from flattened durable metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |
| `parameterIndex` | `dynamic` | — | Zero-based index of parameter. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2005)

<a id="constant-constant-minisql-executor-executor-default-query-memory-bytes-const-default-query-memory-bytes-67108864-src-minisql-executor-executor-ml-1329537879"></a>
### DEFAULT_QUERY_MEMORY_BYTES

```ml
const DEFAULT_QUERY_MEMORY_BYTES = 67108864
```

Defines the default query memory bytes constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L89)

<a id="function-function-minisql-executor-executor-dmlcommand-function-dmlcommand-bound-src-minisql-executor-executor-ml-254293948"></a>
### dmlCommand

```ml
function dmlCommand(bound)
```

Implements DML command for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2111)

<a id="function-function-minisql-executor-executor-encodeprocedureparameters-function-encodeprocedureparameters-parameters-src-minisql-executor-executor-ml-1980748170"></a>
### encodeProcedureParameters

```ml
function encodeProcedureParameters(parameters)
```

Flattens named procedure inputs and their exact SQL types into durable metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parameters` | `dynamic` | — | parameters value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1974)

- [minisql.executor.executor.Engine](Type-minisql-executor-executor-engine-929091680.md) — struct
<a id="function-function-minisql-executor-executor-ensureexplicitddl-function-ensureexplicitddl-engine-src-minisql-executor-executor-ml-696335918"></a>
### ensureExplicitDdl

```ml
function ensureExplicitDdl(engine)
```

Ensures explicit DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1361)

<a id="function-function-minisql-executor-executor-ensureexplicitdml-function-ensureexplicitdml-engine-src-minisql-executor-executor-ml-264740988"></a>
### ensureExplicitDml

```ml
function ensureExplicitDml(engine)
```

Ensures explicit DML using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1346)

<a id="function-function-minisql-executor-executor-estimatedoperatorbytes-function-estimatedoperatorbytes-engine-rows-src-minisql-executor-executor-ml-1024673711"></a>
### estimatedOperatorBytes

```ml
function estimatedOperatorBytes(engine, rows)
```

Estimates an array of scanned/projected rows and updates the peak diagnostic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L351)

<a id="function-function-minisql-executor-executor-estimatedvaluebytes-function-estimatedvaluebytes-value-src-minisql-executor-executor-ml-1784020573"></a>
### estimatedValueBytes

```ml
function estimatedValueBytes(value)
```

Estimates the retained representation of one SQL value. This is a soft accounting model, not a heap allocator contract; variable payload bytes are nevertheless measured exactly so wide-row spill decisions are meaningful.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L341)

<a id="function-function-minisql-executor-executor-evaluaterecursivequery-function-evaluaterecursivequery-engine-query-pagetransaction-src-minisql-executor-executor-ml-1113355987"></a>
### evaluateRecursiveQuery

```ml
function evaluateRecursiveQuery(engine, query, pageTransaction)
```

Evaluates anchor rows followed by semi-naive delta iterations until a fixpoint. UNION removes rows already seen; UNION ALL preserves bags and therefore relies on an empty recursive result to terminate. The depth guard diagnoses runaway SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `query` | `dynamic` | — | query value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2365)

<a id="function-function-minisql-executor-executor-executealteruser-function-executealteruser-engine-statement-src-minisql-executor-executor-ml-911086291"></a>
### executeAlterUser

```ml
function executeAlterUser(engine, statement)
```

Executes alter user using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4551)

<a id="function-function-minisql-executor-executor-executeanalyze-function-executeanalyze-engine-statement-src-minisql-executor-executor-ml-959348459"></a>
### executeAnalyze

```ml
function executeAnalyze(engine, statement)
```

Executes analyze using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3923)

<a id="function-function-minisql-executor-executor-executecall-function-executecall-engine-statement-src-minisql-executor-executor-ml-1362716837"></a>
### executeCall

```ml
function executeCall(engine, statement)
```

Evaluates CALL arguments, substitutes named inputs, and executes the persisted DML body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2026)

<a id="function-function-minisql-executor-executor-executecreateprincipal-function-executecreateprincipal-engine-statement-src-minisql-executor-executor-ml-1740915859"></a>
### executeCreatePrincipal

```ml
function executeCreatePrincipal(engine, statement)
```

Executes create principal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4536)

<a id="function-function-minisql-executor-executor-executedcl-function-executedcl-engine-statement-src-minisql-executor-executor-ml-313676291"></a>
### executeDcl

```ml
function executeDcl(engine, statement)
```

Executes dcl using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4640)

<a id="function-function-minisql-executor-executor-executeddl-function-executeddl-engine-statement-src-minisql-executor-executor-ml-1358160011"></a>
### executeDdl

```ml
function executeDdl(engine, statement)
```

Executes DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2053)

<a id="function-function-minisql-executor-executor-executedeallocate-function-executedeallocate-engine-statement-src-minisql-executor-executor-ml-1991397713"></a>
### executeDeallocate

```ml
function executeDeallocate(engine, statement)
```

Executes deallocate using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1286)

<a id="function-function-minisql-executor-executor-executedescribetable-function-executedescribetable-engine-statement-src-minisql-executor-executor-ml-219793075"></a>
### executeDescribeTable

```ml
function executeDescribeTable(engine, statement)
```

Executes describe table using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4809)

<a id="function-function-minisql-executor-executor-executedml-function-executedml-engine-statement-src-minisql-executor-executor-ml-1540650651"></a>
### executeDml

```ml
function executeDml(engine, statement)
```

Executes DML using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2214)

<a id="function-function-minisql-executor-executor-executedropprincipal-function-executedropprincipal-engine-statement-src-minisql-executor-executor-ml-1743544287"></a>
### executeDropPrincipal

```ml
function executeDropPrincipal(engine, statement)
```

Executes drop principal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4570)

<a id="function-function-minisql-executor-executor-executeexplain-function-executeexplain-engine-statement-src-minisql-executor-executor-ml-1894687515"></a>
### executeExplain

```ml
function executeExplain(engine, statement)
```

Executes explain using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3961)

<a id="function-function-minisql-executor-executor-executegrantprivilege-function-executegrantprivilege-engine-statement-src-minisql-executor-executor-ml-993493515"></a>
### executeGrantPrivilege

```ml
function executeGrantPrivilege(engine, statement)
```

Executes grant privilege using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4610)

<a id="function-function-minisql-executor-executor-executegrantrole-function-executegrantrole-engine-statement-src-minisql-executor-executor-ml-639891795"></a>
### executeGrantRole

```ml
function executeGrantRole(engine, statement)
```

Executes grant role using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4586)

<a id="function-function-minisql-executor-executor-executemerge-function-executemerge-engine-statement-src-minisql-executor-executor-ml-248371447"></a>
### executeMerge

```ml
function executeMerge(engine, statement)
```

Runs MERGE in an existing explicit transaction or creates one atomic implicit transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2306)

<a id="function-function-minisql-executor-executor-executeprepare-function-executeprepare-engine-statement-src-minisql-executor-executor-ml-416137443"></a>
### executePrepare

```ml
function executePrepare(engine, statement)
```

Executes prepare using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1237)

<a id="function-function-minisql-executor-executor-executeprepared-function-executeprepared-engine-statement-src-minisql-executor-executor-ml-1951566227"></a>
### executePrepared

```ml
function executePrepared(engine, statement)
```

Executes prepared using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1251)

<a id="function-function-minisql-executor-executor-executeprocedureddl-function-executeprocedureddl-engine-statement-src-minisql-executor-executor-ml-4246823"></a>
### executeProcedureDdl

```ml
function executeProcedureDdl(engine, statement)
```

Creates, replaces, or drops a durable single-statement stored procedure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2019)

<a id="function-function-minisql-executor-executor-executereindex-function-executereindex-engine-statement-src-minisql-executor-executor-ml-419889123"></a>
### executeReindex

```ml
function executeReindex(engine, statement)
```

Executes reindex using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4685)

<a id="function-function-minisql-executor-executor-executereleasesavepoint-function-executereleasesavepoint-engine-statement-src-minisql-executor-executor-ml-1062203289"></a>
### executeReleaseSavepoint

```ml
function executeReleaseSavepoint(engine, statement)
```

Executes release savepoint using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4080)

<a id="function-function-minisql-executor-executor-executerevokeprivilege-function-executerevokeprivilege-engine-statement-src-minisql-executor-executor-ml-1896721351"></a>
### executeRevokePrivilege

```ml
function executeRevokePrivilege(engine, statement)
```

Executes revoke privilege using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4625)

<a id="function-function-minisql-executor-executor-executerevokerole-function-executerevokerole-engine-statement-src-minisql-executor-executor-ml-1589397277"></a>
### executeRevokeRole

```ml
function executeRevokeRole(engine, statement)
```

Executes revoke role using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4598)

<a id="function-function-minisql-executor-executor-executerollbackto-function-executerollbackto-engine-statement-src-minisql-executor-executor-ml-1019368515"></a>
### executeRollbackTo

```ml
function executeRollbackTo(engine, statement)
```

Executes rollback to using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4068)

<a id="function-function-minisql-executor-executor-executeroutinecall-function-executeroutinecall-engine-statement-src-minisql-executor-executor-ml-775747399"></a>
### executeRoutineCall

```ml
function executeRoutineCall(engine, statement)
```

Evaluates input copies, enters an independent frame, and copies OUT values only after success.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6749)

<a id="function-function-minisql-executor-executor-executeroutineddl-function-executeroutineddl-engine-statement-src-minisql-executor-executor-ml-1609030293"></a>
### executeRoutineDdl

```ml
function executeRoutineDdl(engine, statement)
```

Persists canonical SQL, immutable identity, timestamps and supported execution context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Open database engine; authorized routine DDL commits an active transaction. |
| `statement` | `dynamic` | — | Parsed CREATE, ALTER, or DROP PROCEDURE statement. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6689)

<a id="function-function-minisql-executor-executor-executeroutinestatement-function-executeroutinestatement-engine-statement-src-minisql-executor-executor-ml-328116931"></a>
### executeRoutineStatement

```ml
function executeRoutineStatement(engine, statement)
```

Executes the permitted session-level procedural statements and metadata commands.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7054)

<a id="function-function-minisql-executor-executor-executesavepoint-function-executesavepoint-engine-statement-src-minisql-executor-executor-ml-1459858347"></a>
### executeSavepoint

```ml
function executeSavepoint(engine, statement)
```

Executes savepoint using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4055)

<a id="function-function-minisql-executor-executor-executeschemaddl-function-executeschemaddl-engine-statement-src-minisql-executor-executor-ml-1902403195"></a>
### executeSchemaDdl

```ml
function executeSchemaDdl(engine, statement)
```

Executes durable CREATE/DROP SCHEMA operations outside user transactions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1430)

<a id="function-function-minisql-executor-executor-executeselect-function-executeselect-engine-statement-src-minisql-executor-executor-ml-551814781"></a>
### executeSelect

```ml
function executeSelect(engine, statement)
```

Executes select using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3999)

<a id="function-function-minisql-executor-executor-executesequenceddl-function-executesequenceddl-engine-statement-src-minisql-executor-executor-ml-1664189443"></a>
### executeSequenceDdl

```ml
function executeSequenceDdl(engine, statement)
```

Executes sequence DDL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1954)

<a id="function-function-minisql-executor-executor-executeshowindexes-function-executeshowindexes-engine-statement-src-minisql-executor-executor-ml-1639478163"></a>
### executeShowIndexes

```ml
function executeShowIndexes(engine, statement)
```

Executes show indexes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4837)

<a id="function-function-minisql-executor-executor-executeshowprocesslist-function-executeshowprocesslist-engine-src-minisql-executor-executor-ml-706742654"></a>
### executeShowProcesslist

```ml
function executeShowProcesslist(engine)
```

Materializes a lock-safe snapshot of active sessions for administrators.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4781)

<a id="function-function-minisql-executor-executor-executeshowstatus-function-executeshowstatus-engine-src-minisql-executor-executor-ml-1664572118"></a>
### executeShowStatus

```ml
function executeShowStatus(engine)
```

Exposes bounded process-local counters and configured resource ceilings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4769)

<a id="function-function-minisql-executor-executor-executeshowtables-function-executeshowtables-engine-src-minisql-executor-executor-ml-1475044292"></a>
### executeShowTables

```ml
function executeShowTables(engine)
```

Executes show tables using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4759)

<a id="function-function-minisql-executor-executor-executeshutdown-function-executeshutdown-engine-src-minisql-executor-executor-ml-2009892324"></a>
### executeShutdown

```ml
function executeShutdown(engine)
```

Publishes the stop request; the listener sends this response before draining.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4798)

<a id="function-function-minisql-executor-executor-executesql-function-executesql-engine-sqltext-src-minisql-executor-executor-ml-2061122961"></a>
### executeSql

```ml
function executeSql(engine, sqlText)
```

Executes SQL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5357)

<a id="function-function-minisql-executor-executor-executestatement-function-executestatement-engine-statement-src-minisql-executor-executor-ml-1899332699"></a>
### executeStatement

```ml
function executeStatement(engine, statement)
```

Executes one AST with an implicit token for embedded callers. Network sessions start the same token before parsing so parsing, execution, cursor streaming and lock-wait retries share one absolute deadline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5313)

<a id="function-function-minisql-executor-executor-executestatementcontrolled-function-executestatementcontrolled-engine-statement-src-minisql-executor-executor-ml-2028565579"></a>
### executeStatementControlled

```ml
function executeStatementControlled(engine, statement)
```

All callers, including the embedded API, pass through the same physical execution gate. Pure reads share the database; mutations and session-state statements run exclusively. The logical transaction lock manager remains responsible for conflicts that live longer than one statement. Executes one AST under the database's physical readers/writer gate. Prepared statements are classified from their stored AST. A dirty-index marker triggers an atomic read-to-write escalation before repair, with every gate path released before returning the result or a propagated error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5211)

<a id="function-function-minisql-executor-executor-executestatementcore-function-executestatementcore-engine-statement-src-minisql-executor-executor-ml-520162987"></a>
### executeStatementCore

```ml
function executeStatementCore(engine, statement)
```

Authorizes and executes one statement while managing logical transaction locks. Statement read leases end after execution; implicit write leases are released on every outcome. Errors mark explicit transactions failed and are audited.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5129)

<a id="function-function-minisql-executor-executor-executestatementinner-function-executestatementinner-engine-statement-src-minisql-executor-executor-ml-115241195"></a>
### executeStatementInner

```ml
function executeStatementInner(engine, statement)
```

Executes statement inner using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4859)

<a id="function-function-minisql-executor-executor-executestatementstreaming-function-executestatementstreaming-engine-statement-sink-context-src-minisql-executor-executor-ml-544186883"></a>
### executeStatementStreaming

```ml
function executeStatementStreaming(engine, statement, sink, context)
```

Installs one synchronous result consumer; every exit restores the prior owner. The returned value is the final CALL status. Row batches are sent only once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `sink` | `dynamic` | — |  |
| `context` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5340)

<a id="function-function-minisql-executor-executor-executetriggerbody-function-executetriggerbody-engine-trigger-sourcetable-oldrow-newrow-pagetransaction-src-minisql-executor-executor-ml-31892013"></a>
### executeTriggerBody

```ml
function executeTriggerBody(engine, trigger, sourceTable, oldRow, newRow, pageTransaction)
```

Executes trigger body using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `trigger` | `dynamic` | — | trigger value consumed by this operation. |
| `sourceTable` | `dynamic` | — | sourceTable value consumed by this operation. |
| `oldRow` | `dynamic` | — | oldRow value consumed by this operation. |
| `newRow` | `dynamic` | — | newRow value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1782)

<a id="function-function-minisql-executor-executor-executetriggerddl-function-executetriggerddl-engine-statement-src-minisql-executor-executor-ml-1527619189"></a>
### executeTriggerDdl

```ml
function executeTriggerDdl(engine, statement)
```

Executes trigger DDL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1911)

<a id="function-function-minisql-executor-executor-executevacuum-function-executevacuum-engine-statement-src-minisql-executor-executor-ml-2124883343"></a>
### executeVacuum

```ml
function executeVacuum(engine, statement)
```

Executes vacuum using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4659)

<a id="function-function-minisql-executor-executor-executeviewddl-function-executeviewddl-engine-statement-src-minisql-executor-executor-ml-1822873027"></a>
### executeViewDdl

```ml
function executeViewDdl(engine, statement)
```

Executes view DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1457)

<a id="constant-constant-minisql-executor-executor-execution-batch-rows-const-execution-batch-rows-128-src-minisql-executor-executor-ml-2038653322"></a>
### EXECUTION_BATCH_ROWS

```ml
const EXECUTION_BATCH_ROWS = 128
```

Defines the execution batch rows constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L83)

<a id="function-function-minisql-executor-executor-explainbound-function-explainbound-bound-src-minisql-executor-executor-ml-2105905164"></a>
### explainBound

```ml
function explainBound(bound)
```

Implements explain bound for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3949)

<a id="function-function-minisql-executor-executor-expressionhaspotentialouterreference-function-expressionhaspotentialouterreference-expression-statement-src-minisql-executor-executor-ml-1441359755"></a>
### expressionHasPotentialOuterReference

```ml
function expressionHasPotentialOuterReference(expression, statement)
```

Detects a qualified column whose source is not declared by its immediate SELECT.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L987)

<a id="function-function-minisql-executor-executor-expressionusesnextval-function-expressionusesnextval-expression-src-minisql-executor-executor-ml-2108459686"></a>
### expressionUsesNextval

```ml
function expressionUsesNextval(expression)
```

Recursively detects NEXTVAL in every expression container, including CASE, window clauses, and subqueries. NEXTVAL mutates sequence/session state and is therefore the key exception to classifying SELECT as a shared read.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4899)

<a id="function-function-minisql-executor-executor-fail-function-fail-code-operation-message-src-minisql-executor-executor-ml-2141121417"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql executor executor module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L260)

<a id="function-function-minisql-executor-executor-failedroutineresults-function-failedroutineresults-engine-src-minisql-executor-executor-ml-2014920122"></a>
### failedRoutineResults

```ml
function failedRoutineResults(engine)
```

Returns results completed before an unhandled routine error, without changing embedded errors. The protocol sends these in order followed by the original error response.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7078)

<a id="function-function-minisql-executor-executor-filtersourcerows-function-filtersourcerows-source-rows-predicate-src-minisql-executor-executor-ml-1972927957"></a>
### filterSourceRows

```ml
function filterSourceRows(source, rows, predicate)
```

Applies a predicate assigned by the optimizer before a source participates in an inner join. Bound column indexes are global, so non-leading sources receive an offset-sized placeholder prefix during evaluation while retaining their compact local row representation for the join operator.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2538)

<a id="function-function-minisql-executor-executor-findcolumnrule-function-findcolumnrule-tableschema-columnname-src-minisql-executor-executor-ml-1670747626"></a>
### findColumnRule

```ml
function findColumnRule(tableSchema, columnName)
```

Finds column rule using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchema` | `dynamic` | — | tableSchema value consumed by this operation. |
| `columnName` | `dynamic` | — | columnName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4710)

<a id="function-function-minisql-executor-executor-findpreparedindex-function-findpreparedindex-engine-name-src-minisql-executor-executor-ml-975534529"></a>
### findPreparedIndex

```ml
function findPreparedIndex(engine, name)
```

Finds prepared index using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L603)

<a id="function-function-minisql-executor-executor-finishquerycontrol-function-finishquerycontrol-engine-src-minisql-executor-executor-ml-2094669646"></a>
### finishQueryControl

```ml
function finishQueryControl(engine)
```

Releases reservations and deactivates a completed token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L424)

<a id="function-function-minisql-executor-executor-firetriggers-function-firetriggers-engine-bound-result-pagetransaction-src-minisql-executor-executor-ml-1766799936"></a>
### fireTriggers

```ml
function fireTriggers(engine, bound, result, pageTransaction)
```

Implements fire triggers for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1848)

<a id="function-function-minisql-executor-executor-hasdatabaseadmin-function-hasdatabaseadmin-engine-src-minisql-executor-executor-ml-1419369890"></a>
### hasDatabaseAdmin

```ml
function hasDatabaseAdmin(engine)
```

Returns whether the supplied value satisfies the database admin condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4111)

<a id="function-function-minisql-executor-executor-informationschemarows-function-informationschemarows-engine-relationkind-src-minisql-executor-executor-ml-1451621596"></a>
### informationSchemaRows

```ml
function informationSchemaRows(engine, relationKind)
```

Materializes a supported INFORMATION_SCHEMA relation from the live catalog snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `relationKind` | `dynamic` | — | relationKind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2415)

<a id="constant-constant-minisql-executor-executor-invalid-argument-const-invalid-argument-9001-src-minisql-executor-executor-ml-350166239"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

SQL execution facade. M16 extends the accepted M15 scan/filter/projection


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L45)

<a id="function-function-minisql-executor-executor-invalidateplanningcontext-function-invalidateplanningcontext-engine-src-minisql-executor-executor-ml-2113816792"></a>
### invalidatePlanningContext

```ml
function invalidatePlanningContext(engine)
```

Invalidates only advisory state. Query correctness never depends on the cache, but local DDL/ANALYZE must expose new access paths and estimates immediately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3858)

<a id="function-function-minisql-executor-executor-isapplicationerror-function-isapplicationerror-engine-errorcode-src-minisql-executor-executor-ml-1664485325"></a>
### isApplicationError

```ml
function isApplicationError(engine, errorCode)
```

Distinguishes application MYSQL_ERRNO values from internal lock/cancellation control codes. Listener retry policy must never replay committed procedure side effects for a SIGNAL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `errorCode` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7072)

<a id="function-function-minisql-executor-executor-isauthorizeddatastatement-function-isauthorizeddatastatement-statement-src-minisql-executor-executor-ml-1730684465"></a>
### isAuthorizedDataStatement

```ml
function isAuthorizedDataStatement(statement)
```

Returns whether a statement changes or truncates table data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | Bound SQL statement to classify. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4329)

<a id="function-function-minisql-executor-executor-isauthorizeddefinitionstatement-function-isauthorizeddefinitionstatement-statement-src-minisql-executor-executor-ml-1467498511"></a>
### isAuthorizedDefinitionStatement

```ml
function isAuthorizedDefinitionStatement(statement)
```

Returns whether a statement changes schema or optimizer metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | Bound SQL statement to classify. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4380)

<a id="function-function-minisql-executor-executor-isengine-function-isengine-value-src-minisql-executor-executor-ml-57134237"></a>
### isEngine

```ml
function isEngine(value)
```

Returns whether the supplied value satisfies the engine condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L276)

<a id="function-function-minisql-executor-executor-isimplemented-function-isimplemented-src-minisql-executor-executor-ml-2014113356"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql executor executor module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5442)

<a id="function-function-minisql-executor-executor-isolationvalue-function-isolationvalue-name-src-minisql-executor-executor-ml-1180263519"></a>
### isolationValue

```ml
function isolationValue(name)
```

Implements isolation value for this module. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1316)

<a id="function-function-minisql-executor-executor-ispreparedstatementstate-function-ispreparedstatementstate-value-src-minisql-executor-executor-ml-1800141301"></a>
### isPreparedStatementState

```ml
function isPreparedStatementState(value)
```

Returns whether the supplied value satisfies the prepared statement state condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L534)

<a id="function-function-minisql-executor-executor-isqueryresult-function-isqueryresult-value-src-minisql-executor-executor-ml-1266785315"></a>
### isQueryResult

```ml
function isQueryResult(value)
```

Returns whether the supplied value satisfies the query result condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L268)

<a id="function-function-minisql-executor-executor-issequencesessionvalue-function-issequencesessionvalue-value-src-minisql-executor-executor-ml-1440773105"></a>
### isSequenceSessionValue

```ml
function isSequenceSessionValue(value)
```

Returns whether the supplied value satisfies the sequence session value condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L542)

<a id="function-function-minisql-executor-executor-itemindex-function-itemindex-bound-expression-src-minisql-executor-executor-ml-444739136"></a>
### itemIndex

```ml
function itemIndex(bound, expression)
```

Implements item index for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3146)

<a id="function-function-minisql-executor-executor-joinedsource-function-joinedsource-engine-bound-pagetransaction-sourceoffset-sourcelimit-requiredcolumns-executable-src-minisql-executor-executor-ml-476399185"></a>
### joinedSource

```ml
function joinedSource(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns, executable)
```

Implements joined source for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `sourceLimit` | `dynamic` | — | sourceLimit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `executable` | `dynamic` | — | executable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3062)

<a id="function-function-minisql-executor-executor-joinedsourcereordered-function-joinedsourcereordered-engine-bound-pagetransaction-sourceoffset-sourcelimit-requiredcolumns-executable-src-minisql-executor-executor-ml-1305843441"></a>
### joinedSourceReordered

```ml
function joinedSourceReordered(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns, executable)
```

Executes the optimizer's canonicalized order for a pure INNER equijoin graph.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `sourceLimit` | `dynamic` | — | sourceLimit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `executable` | `dynamic` | — | executable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2935)

<a id="function-function-minisql-executor-executor-joinedsourcereorderedcount-function-joinedsourcereorderedcount-engine-bound-pagetransaction-requiredcolumns-executable-src-minisql-executor-executor-ml-766675193"></a>
### joinedSourceReorderedCount

```ml
function joinedSourceReorderedCount(engine, bound, pageTransaction, requiredColumns, executable)
```

Executes all reordered joins except the final edge normally, then turns that edge directly into a cardinality. This bounds retained memory by the largest intermediate before the final fan-out rather than the final result size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `executable` | `dynamic` | — | executable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2890)

<a id="function-function-minisql-executor-executor-joinindexkeys-function-joinindexkeys-keys-src-minisql-executor-executor-ml-1423789080"></a>
### joinIndexKeys

```ml
function joinIndexKeys(keys)
```

Renders expression-index keys without their internal compatibility marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `dynamic` | — | keys value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4746)

<a id="function-function-minisql-executor-executor-joinnames-function-joinnames-names-src-minisql-executor-executor-ml-2005156840"></a>
### joinNames

```ml
function joinNames(names)
```

Implements join names for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — | names value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4735)

<a id="function-function-minisql-executor-executor-joinprobeguaranteespredicate-function-joinprobeguaranteespredicate-boundjoin-leftrow-predicate-src-minisql-executor-executor-ml-1750283024"></a>
### joinProbeGuaranteesPredicate

```ml
function joinProbeGuaranteesPredicate(boundJoin, leftRow, predicate)
```

Proves that one parameterized equality-index probe already guarantees a pushed right-source predicate for the current left row. This removes only simple typed column=literal predicates (and AND trees composed of them); every other source filter retains ordinary evaluation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundJoin` | `dynamic` | — | boundJoin value consumed by this operation. |
| `leftRow` | `dynamic` | — | leftRow value consumed by this operation. |
| `predicate` | `dynamic` | — | predicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2971)

<a id="function-function-minisql-executor-executor-leaveselectadmission-function-leaveselectadmission-engine-ownsgate-src-minisql-executor-executor-ml-468584844"></a>
### leaveSelectAdmission

```ml
function leaveSelectAdmission(engine, ownsGate)
```

Releases only a gate acquired by the cursor, never its enclosing CALL gate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `ownsGate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3475)

<a id="function-function-minisql-executor-executor-loadplanningcontext-function-loadplanningcontext-engine-src-minisql-executor-executor-ml-71253414"></a>
### loadPlanningContext

```ml
function loadPlanningContext(engine)
```

Builds the optimizer's catalog snapshot without giving planner modules direct access to files or mutable database handles. The snapshot is advisory; an index disappearing between planning and execution causes a semantic fallback rather than a failed or incorrect query.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3771)

<a id="function-function-minisql-executor-executor-loadstatistics-function-loadstatistics-engine-src-minisql-executor-executor-ml-641776954"></a>
### loadStatistics

```ml
function loadStatistics(engine)
```

Loads statistics using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3761)

<a id="function-function-minisql-executor-executor-markexplicitfailure-function-markexplicitfailure-engine-src-minisql-executor-executor-ml-1490166796"></a>
### markExplicitFailure

```ml
function markExplicitFailure(engine)
```

Implements mark explicit failure for this module. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5026)

<a id="function-function-minisql-executor-executor-materializeboundexpression-function-materializeboundexpression-engine-expression-bound-row-pagetransaction-src-minisql-executor-executor-ml-347857181"></a>
### materializeBoundExpression

```ml
function materializeBoundExpression(engine, expression, bound, row, pageTransaction)
```

Rebuilds a bound expression with every deferred subquery replaced by a literal. Reusing the ordinary expression evaluator keeps SQL NULL and boolean semantics centralized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3209)

<a id="function-function-minisql-executor-executor-materializeboundsubquery-function-materializeboundsubquery-engine-expression-bound-row-pagetransaction-src-minisql-executor-executor-ml-104763257"></a>
### materializeBoundSubquery

```ml
function materializeBoundSubquery(engine, expression, bound, row, pageTransaction)
```

Executes a validated scalar, EXISTS, or IN subquery for one outer source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3180)

<a id="function-function-minisql-executor-executor-materializedmlstatement-function-materializedmlstatement-engine-statement-pagetransaction-src-minisql-executor-executor-ml-183510046"></a>
### materializeDmlStatement

```ml
function materializeDmlStatement(engine, statement, pageTransaction)
```

Implements materialize DML statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1183)

<a id="function-function-minisql-executor-executor-materializeexpression-function-materializeexpression-engine-expression-pagetransaction-defersubqueries-src-minisql-executor-executor-ml-1968497743"></a>
### materializeExpression

```ml
function materializeExpression(engine, expression, pageTransaction, deferSubqueries)
```

Implements materialize expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `deferSubqueries` | `dynamic` | — | deferSubqueries value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L836)

<a id="function-function-minisql-executor-executor-materializeinsertselect-function-materializeinsertselect-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1231635255"></a>
### materializeInsertSelect

```ml
function materializeInsertSelect(engine, bound, pageTransaction)
```

Implements materialize insert select for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2167)

<a id="function-function-minisql-executor-executor-materializeselectstatement-function-materializeselectstatement-engine-statement-pagetransaction-src-minisql-executor-executor-ml-1930561052"></a>
### materializeSelectStatement

```ml
function materializeSelectStatement(engine, statement, pageTransaction)
```

Implements materialize select statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L932)

<a id="constant-constant-minisql-executor-executor-mode-ddl-const-mode-ddl-2-src-minisql-executor-executor-ml-1799859077"></a>
### MODE_DDL

```ml
const MODE_DDL = 2
```

Defines the mode ddl constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L72)

<a id="constant-constant-minisql-executor-executor-mode-dml-const-mode-dml-1-src-minisql-executor-executor-ml-935666256"></a>
### MODE_DML

```ml
const MODE_DML = 1
```

Defines the mode dml constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L70)

<a id="constant-constant-minisql-executor-executor-mode-none-const-mode-none-0-src-minisql-executor-executor-ml-775891745"></a>
### MODE_NONE

```ml
const MODE_NONE = 0
```

Defines the mode none constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L68)

<a id="function-function-minisql-executor-executor-nameinlist-function-nameinlist-names-name-src-minisql-executor-executor-ml-1485526323"></a>
### nameInList

```ml
function nameInList(names, name)
```

Implements name in list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — | names value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4163)

<a id="function-function-minisql-executor-executor-nestedselectdeclaresqualifier-function-nestedselectdeclaresqualifier-statement-qualifier-src-minisql-executor-executor-ml-161014187"></a>
### nestedSelectDeclaresQualifier

```ml
function nestedSelectDeclaresQualifier(statement, qualifier)
```

Returns true when a nested SELECT declares a qualifier that shadows an outer source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `qualifier` | `dynamic` | — | qualifier value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L969)

<a id="function-function-minisql-executor-executor-nextselectbatch-function-nextselectbatch-cursor-maximumrows-src-minisql-executor-executor-ml-1002043475"></a>
### nextSelectBatch

```ml
function nextSelectBatch(cursor, maximumRows)
```

Produces at most maximumRows projected rows while retaining no earlier batch. Void denotes end-of-stream and guarantees that the read lease is released.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |
| `maximumRows` | `dynamic` | — | maximumRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3540)

<a id="function-function-minisql-executor-executor-normalizecompoundorder-function-normalizecompoundorder-rows-bound-src-minisql-executor-executor-ml-142974099"></a>
### normalizeCompoundOrder

```ml
function normalizeCompoundOrder(rows, bound)
```

Normalizes compound order using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3159)

<a id="function-function-minisql-executor-executor-notequeryspill-function-notequeryspill-engine-rows-src-minisql-executor-executor-ml-621388527"></a>
### noteQuerySpill

```ml
function noteQuerySpill(engine, rows)
```

Records a spill decision using the measured input representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L392)

<a id="function-function-minisql-executor-executor-open-function-open-databasepath-src-minisql-executor-executor-ml-1288864166"></a>
### open

```ml
function open(databasePath)
```

Opens open for the minisql executor executor module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L488)

<a id="function-function-minisql-executor-executor-openselectcursor-function-openselectcursor-engine-statement-ownsgate-true-src-minisql-executor-executor-ml-759917882"></a>
### openSelectCursor

```ml
function openSelectCursor(engine, statement, ownsGate = true)
```

Opens the non-blocking single-table physical pipeline as a forward-only result cursor. Unsupported/blocking shapes return void so callers can use the ordinary executor without changing SQL semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `ownsGate` | `dynamic` | <code>true</code> |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3485)

<a id="function-function-minisql-executor-executor-optimizedplanfor-function-optimizedplanfor-engine-bound-src-minisql-executor-executor-ml-1694886294"></a>
### optimizedPlanFor

```ml
function optimizedPlanFor(engine, bound)
```

Returns a generation-safe cached physical plan or optimizes and records a new one. Executor-created typed literals format opaquely, so correlated and parameter-materialized SELECTs bypass caching rather than reusing a plan that embeds another invocation's literal value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3821)

<a id="constant-constant-minisql-executor-executor-permission-denied-const-permission-denied-9029-src-minisql-executor-executor-ml-1290569077"></a>
### PERMISSION_DENIED

```ml
const PERMISSION_DENIED = 9029
```

Defines the permission denied constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L65)

<a id="function-function-minisql-executor-executor-permissionfailure-function-permissionfailure-operation-detail-src-minisql-executor-executor-ml-2072982062"></a>
### permissionFailure

```ml
function permissionFailure(operation, detail)
```

Implements permission failure for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `detail` | `dynamic` | — | detail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4095)

<a id="function-function-minisql-executor-executor-persistedprogrambodysupported-function-persistedprogrambodysupported-statement-src-minisql-executor-executor-ml-1886903471"></a>
### persistedProgramBodySupported

```ml
function persistedProgramBodySupported(statement)
```

Returns whether the persisted statement formatter preserves the entire DML body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1885)

<a id="constant-constant-minisql-executor-executor-plan-cache-capacity-const-plan-cache-capacity-64-src-minisql-executor-executor-ml-1481549155"></a>
### PLAN_CACHE_CAPACITY

```ml
const PLAN_CACHE_CAPACITY = 64
```

Defines the plan cache capacity constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L81)

<a id="function-function-minisql-executor-executor-plancacheentrycount-function-plancacheentrycount-engine-src-minisql-executor-executor-ml-1611185358"></a>
### planCacheEntryCount

```ml
function planCacheEntryCount(engine)
```

Exposes non-sensitive optimizer cache counters for diagnostics and tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L282)

<a id="function-function-minisql-executor-executor-plancachehitcount-function-plancachehitcount-engine-src-minisql-executor-executor-ml-670064736"></a>
### planCacheHitCount

```ml
function planCacheHitCount(engine)
```

Returns cumulative hits of entries still resident in the session cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L289)

<a id="function-function-minisql-executor-executor-pollquerycontrol-function-pollquerycontrol-engine-operation-src-minisql-executor-executor-ml-257719047"></a>
### pollQueryControl

```ml
function pollQueryControl(engine, operation)
```

Polls administrator cancellation and the monotonic execution deadline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L436)

<a id="function-function-minisql-executor-executor-preparedatabase-function-preparedatabase-database-src-minisql-executor-executor-ml-262138321"></a>
### prepareDatabase

```ml
function prepareDatabase(database)
```

Performs the index readiness pass once for an opened database. Clean marker state needs only derived-file existence checks; a dirty marker or missing file performs the expensive rebuild/verification path. A double check inside the exclusive gate lets concurrent connection accepts share either result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L457)

- [minisql.executor.executor.PreparedStatementState](Type-minisql-executor-executor-preparedstatementstate-1869459177.md) — struct
<a id="function-function-minisql-executor-executor-principal-function-principal-engine-src-minisql-executor-executor-ml-1645409502"></a>
### principal

```ml
function principal(engine)
```

Implements principal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L513)

<a id="function-function-minisql-executor-executor-privilegecode-function-privilegecode-name-objecttype-src-minisql-executor-executor-ml-227622704"></a>
### privilegeCode

```ml
function privilegeCode(name, objectType)
```

Implements privilege code for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4445)

<a id="function-function-minisql-executor-executor-privilegecodes-function-privilegecodes-names-objecttype-src-minisql-executor-executor-ml-1500901271"></a>
### privilegeCodes

```ml
function privilegeCodes(names, objectType)
```

Implements privilege codes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — | names value consumed by this operation. |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4488)

<a id="constant-constant-minisql-executor-executor-procedure-metadata-v2-const-procedure-metadata-v2-minisql-routine-metadata-v2-src-minisql-executor-executor-ml-945737886"></a>
### PROCEDURE_METADATA_V2

```ml
const PROCEDURE_METADATA_V2 = "__minisql_routine_metadata_v2__"
```

Full routine definitions use the existing durable extension envelope, versioned independently.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5653)

<a id="constant-constant-minisql-executor-executor-procedure-parameter-metadata-v1-const-procedure-parameter-metadata-v1-minisql-parameter-metadata-v1-src-minisql-executor-executor-ml-2080838468"></a>
### PROCEDURE_PARAMETER_METADATA_V1

```ml
const PROCEDURE_PARAMETER_METADATA_V1 = "__minisql_parameter_metadata_v1__"
```

Identifies the flattened, versioned parameter metadata stored with procedures.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L96)

<a id="function-function-minisql-executor-executor-projectsubqueryrows-function-projectsubqueryrows-engine-bound-source-pagetransaction-src-minisql-executor-executor-ml-373874092"></a>
### projectSubqueryRows

```ml
function projectSubqueryRows(engine, bound, source, pageTransaction)
```

Filters and projects a non-grouped row set whose expressions contain subqueries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3251)

<a id="constant-constant-minisql-executor-executor-query-cancelled-const-query-cancelled-9035-src-minisql-executor-executor-ml-1111187330"></a>
### QUERY_CANCELLED

```ml
const QUERY_CANCELLED = 9035
```

Defines the query cancelled constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L91)

<a id="constant-constant-minisql-executor-executor-query-timeout-const-query-timeout-9036-src-minisql-executor-executor-ml-974921613"></a>
### QUERY_TIMEOUT

```ml
const QUERY_TIMEOUT = 9036
```

Defines the query timeout constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L93)

- [minisql.executor.executor.QueryControl](Type-minisql-executor-executor-querycontrol-502790795.md) — struct
- [minisql.executor.executor.QueryMemoryManager](Type-minisql-executor-executor-querymemorymanager-1878359024.md) — struct
- [minisql.executor.executor.QueryResult](Type-minisql-executor-executor-queryresult-1157654927.md) — struct
<a id="function-function-minisql-executor-executor-queryrowthreshold-function-queryrowthreshold-engine-rows-src-minisql-executor-executor-ml-526154789"></a>
### queryRowThreshold

```ml
function queryRowThreshold(engine, rows)
```

Derives a spill row threshold from sampled row width and the byte budget.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L371)

<a id="function-function-minisql-executor-executor-rebuildindexesforddl-function-rebuildindexesforddl-engine-bound-statement-src-minisql-executor-executor-ml-1225417799"></a>
### rebuildIndexesForDdl

```ml
function rebuildIndexesForDdl(engine, bound, statement)
```

Rebuilds only indexes whose table schema changed in one autocommit DDL. Unrelated tables remain byte-for-byte untouched; the durable dirty marker still triggers the conservative all-index repair after a rebuild failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2036)

<a id="function-function-minisql-executor-executor-recordstatementerror-function-recordstatementerror-engine-nativeerror-replacearea-false-src-minisql-executor-executor-ml-337169722"></a>
### recordStatementError

```ml
function recordStatementError(engine, nativeError, replaceArea = false)
```

Shares terminal error accounting across parsing, cursor and normal execution paths. replaceArea is used for errors raised before a public statement can be executed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `nativeError` | `dynamic` | — |  |
| `replaceArea` | `dynamic` | <code>false</code> |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7117)

- [minisql.executor.executor.RecursiveCteFrame](Type-minisql-executor-executor-recursivecteframe-1748414545.md) — struct
<a id="function-function-minisql-executor-executor-recursiverowscontain-function-recursiverowscontain-rows-candidate-src-minisql-executor-executor-ml-685192766"></a>
### recursiveRowsContain

```ml
function recursiveRowsContain(rows, candidate)
```

Returns true when a recursive result row is already present by SQL value equality.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `candidate` | `dynamic` | — | candidate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2340)

<a id="function-function-minisql-executor-executor-recursiveworkingrows-function-recursiveworkingrows-engine-name-src-minisql-executor-executor-ml-2002064025"></a>
### recursiveWorkingRows

```ml
function recursiveWorkingRows(engine, name)
```

Returns the innermost active delta for a recursive self-reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2350)

<a id="function-function-minisql-executor-executor-remembersequencevalue-function-remembersequencevalue-engine-name-value-src-minisql-executor-executor-ml-941748772"></a>
### rememberSequenceValue

```ml
function rememberSequenceValue(engine, name, value)
```

Implements remember sequence value for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L564)

<a id="function-function-minisql-executor-executor-replacemergecolumn-function-replacemergecolumn-expression-statement-sourcetable-sourcerow-src-minisql-executor-executor-ml-2090429325"></a>
### replaceMergeColumn

```ml
function replaceMergeColumn(expression, statement, sourceTable, sourceRow)
```

Resolves one qualified MERGE source/target column for a concrete source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `sourceTable` | `dynamic` | — | sourceTable value consumed by this operation. |
| `sourceRow` | `dynamic` | — | sourceRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1616)

<a id="function-function-minisql-executor-executor-replacemergeexpression-function-replacemergeexpression-expression-statement-sourcetable-sourcerow-src-minisql-executor-executor-ml-1329509965"></a>
### replaceMergeExpression

```ml
function replaceMergeExpression(expression, statement, sourceTable, sourceRow)
```

Rewrites a MERGE expression for one source row while leaving target columns bindable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `sourceTable` | `dynamic` | — | sourceTable value consumed by this operation. |
| `sourceRow` | `dynamic` | — | sourceRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1636)

<a id="function-function-minisql-executor-executor-replaceprocedureexpression-function-replaceprocedureexpression-expression-parameternames-parametervalues-src-minisql-executor-executor-ml-2146441588"></a>
### replaceProcedureExpression

```ml
function replaceProcedureExpression(expression, parameterNames, parameterValues)
```

Substitutes named procedure inputs throughout a supported DML expression.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `parameterNames` | `dynamic` | — | parameterNames value consumed by this operation. |
| `parameterValues` | `dynamic` | — | parameterValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1689)

<a id="function-function-minisql-executor-executor-replaceprocedureparameter-function-replaceprocedureparameter-expression-parameternames-parametervalues-src-minisql-executor-executor-ml-1207754032"></a>
### replaceProcedureParameter

```ml
function replaceProcedureParameter(expression, parameterNames, parameterValues)
```

Replaces an unqualified procedure parameter reference with its invocation value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `parameterNames` | `dynamic` | — | parameterNames value consumed by this operation. |
| `parameterValues` | `dynamic` | — | parameterValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1675)

<a id="function-function-minisql-executor-executor-replaceprocedurestatement-function-replaceprocedurestatement-statement-parameternames-parametervalues-src-minisql-executor-executor-ml-1689497001"></a>
### replaceProcedureStatement

```ml
function replaceProcedureStatement(statement, parameterNames, parameterValues)
```

Substitutes procedure parameters in one persisted INSERT, UPDATE, or DELETE body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `parameterNames` | `dynamic` | — | parameterNames value consumed by this operation. |
| `parameterValues` | `dynamic` | — | parameterValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1728)

<a id="function-function-minisql-executor-executor-replacetriggerexpression-function-replacetriggerexpression-expression-table-oldrow-newrow-src-minisql-executor-executor-ml-1569511131"></a>
### replaceTriggerExpression

```ml
function replaceTriggerExpression(expression, table, oldRow, newRow)
```

Implements replace trigger expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `oldRow` | `dynamic` | — | oldRow value consumed by this operation. |
| `newRow` | `dynamic` | — | newRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1512)

<a id="function-function-minisql-executor-executor-replacetriggerreturning-function-replacetriggerreturning-items-table-oldrow-newrow-src-minisql-executor-executor-ml-2125935561"></a>
### replaceTriggerReturning

```ml
function replaceTriggerReturning(items, table, oldRow, newRow)
```

Implements replace trigger returning for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `oldRow` | `dynamic` | — | oldRow value consumed by this operation. |
| `newRow` | `dynamic` | — | newRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1559)

<a id="function-function-minisql-executor-executor-replacetriggerstatement-function-replacetriggerstatement-statement-table-oldrow-newrow-src-minisql-executor-executor-ml-146068100"></a>
### replaceTriggerStatement

```ml
function replaceTriggerStatement(statement, table, oldRow, newRow)
```

Implements replace trigger statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `oldRow` | `dynamic` | — | oldRow value consumed by this operation. |
| `newRow` | `dynamic` | — | newRow value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1575)

<a id="function-function-minisql-executor-executor-requiregrantoption-function-requiregrantoption-engine-objecttype-objectid-privilege-operation-src-minisql-executor-executor-ml-1575741859"></a>
### requireGrantOption

```ml
function requireGrantOption(engine, objectType, objectId, privilege, operation)
```

Implements require grant option for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |
| `objectId` | `dynamic` | — | Identifier of object. |
| `privilege` | `dynamic` | — | privilege value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4138)

<a id="function-function-minisql-executor-executor-requireobjectschema-function-requireobjectschema-engine-objectname-operation-src-minisql-executor-executor-ml-1537236189"></a>
### requireObjectSchema

```ml
function requireObjectSchema(engine, objectName, operation)
```

Verifies that the namespace of a qualified object exists before object DDL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `objectName` | `dynamic` | — | objectName value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1420)

<a id="function-function-minisql-executor-executor-requireprivilege-function-requireprivilege-engine-objecttype-objectid-privilege-operation-src-minisql-executor-executor-ml-1806371971"></a>
### requirePrivilege

```ml
function requirePrivilege(engine, objectType, objectId, privilege, operation)
```

Implements require privilege for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `objectType` | `dynamic` | — | objectType value consumed by this operation. |
| `objectId` | `dynamic` | — | Identifier of object. |
| `privilege` | `dynamic` | — | privilege value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4124)

<a id="function-function-minisql-executor-executor-requiresecurityadmin-function-requiresecurityadmin-engine-operation-src-minisql-executor-executor-ml-861651211"></a>
### requireSecurityAdmin

```ml
function requireSecurityAdmin(engine, operation)
```

Implements require security admin for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4526)

<a id="function-function-minisql-executor-executor-requiretableprivilegebyname-function-requiretableprivilegebyname-engine-tablename-privilege-operation-src-minisql-executor-executor-ml-1866733741"></a>
### requireTablePrivilegeByName

```ml
function requireTablePrivilegeByName(engine, tableName, privilege, operation)
```

Implements require table privilege by name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `tableName` | `dynamic` | — | tableName value consumed by this operation. |
| `privilege` | `dynamic` | — | privilege value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4151)

<a id="function-function-minisql-executor-executor-resetquerymemory-function-resetquerymemory-engine-src-minisql-executor-executor-ml-1057622286"></a>
### resetQueryMemory

```ml
function resetQueryMemory(engine)
```

Clears last-statement accounting without changing the configured policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L329)

<a id="function-function-minisql-executor-executor-resettransaction-function-resettransaction-engine-src-minisql-executor-executor-ml-956724486"></a>
### resetTransaction

```ml
function resetTransaction(engine)
```

Resets transaction using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1303)

<a id="constant-constant-minisql-executor-executor-result-command-const-result-command-1-src-minisql-executor-executor-ml-1919843868"></a>
### RESULT_COMMAND

```ml
const RESULT_COMMAND = 1
```

Defines the result command constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L75)

<a id="constant-constant-minisql-executor-executor-result-multiple-const-result-multiple-3-src-minisql-executor-executor-ml-891462430"></a>
### RESULT_MULTIPLE

```ml
const RESULT_MULTIPLE = 3
```

Contains ordered child QueryResult values in rows, followed by CALL status.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L79)

<a id="constant-constant-minisql-executor-executor-result-rows-const-result-rows-2-src-minisql-executor-executor-ml-1453942231"></a>
### RESULT_ROWS

```ml
const RESULT_ROWS = 2
```

Defines the result rows constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L77)

<a id="function-function-minisql-executor-executor-returningresult-function-returningresult-bound-result-src-minisql-executor-executor-ml-1838229607"></a>
### returningResult

```ml
function returningResult(bound, result)
```

Implements returning result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `result` | `dynamic` | — | Result object populated or inspected by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2196)

<a id="function-function-minisql-executor-executor-rollbackexplicit-function-rollbackexplicit-engine-src-minisql-executor-executor-ml-1519451594"></a>
### rollbackExplicit

```ml
function rollbackExplicit(engine)
```

Implements rollback explicit for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4041)

<a id="function-function-minisql-executor-executor-routineassign-function-routineassign-engine-frame-name-value-src-minisql-executor-executor-ml-2107802491"></a>
### routineAssign

```ml
function routineAssign(engine, frame, name, value)
```

Assigns through an existing lexical variable or creates a connection-local user variable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6001)

<a id="function-function-minisql-executor-executor-routineassignmentwarning-function-routineassignmentwarning-engine-state-number-message-src-minisql-executor-executor-ml-1617779445"></a>
### routineAssignmentWarning

```ml
function routineAssignmentWarning(engine, state, number, message)
```

Records successful lossy assignment as a catchable warning after assignment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `number` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5963)

<a id="function-function-minisql-executor-executor-routineassignrow-function-routineassignrow-engine-frame-names-row-src-minisql-executor-executor-ml-2008914011"></a>
### routineAssignRow

```ml
function routineAssignRow(engine, frame, names, row)
```

Assigns one SELECT/FETCH row only after target count and conversions all succeed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `names` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6378)

<a id="function-function-minisql-executor-executor-routineauthorizeddl-function-routineauthorizeddl-engine-statement-src-minisql-executor-executor-ml-2089634333"></a>
### routineAuthorizeDdl

```ml
function routineAuthorizeDdl(engine, statement)
```

Requires the dedicated routine privilege; generic CREATE does not authorize programs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Authenticated security context for the DDL statement. |
| `statement` | `dynamic` | — | CREATE, ALTER, or DROP PROCEDURE syntax tree. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6661)

<a id="function-function-minisql-executor-executor-routineblock-function-routineblock-engine-frame-statement-src-minisql-executor-executor-ml-999555204"></a>
### routineBlock

```ml
function routineBlock(engine, frame, statement)
```

Executes a scope and closes its cursors on normal, LEAVE, EXIT, and error paths.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6202)

<a id="function-function-minisql-executor-executor-routinecanonicalname-function-routinecanonicalname-name-src-minisql-executor-executor-ml-1599224739"></a>
### routineCanonicalName

```ml
function routineCanonicalName(name)
```

Canonicalizes the default schema without changing non-default namespaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5677)

<a id="function-function-minisql-executor-executor-routinechecktriggerstatement-function-routinechecktriggerstatement-engine-statement-src-minisql-executor-executor-ml-1671207251"></a>
### routineCheckTriggerStatement

```ml
function routineCheckTriggerStatement(engine, statement)
```

Enforces inherited trigger restrictions before any prohibited statement executes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6302)

<a id="function-function-minisql-executor-executor-routinechecktriggertarget-function-routinechecktriggertarget-engine-name-src-minisql-executor-executor-ml-209823323"></a>
### routineCheckTriggerTarget

```ml
function routineCheckTriggerTarget(engine, name)
```

Rejects changes to every table whose active row trigger led to this statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6318)

<a id="function-function-minisql-executor-executor-routineconvert-function-routineconvert-engine-value-typeinfo-src-minisql-executor-executor-ml-892997367"></a>
### routineConvert

```ml
function routineConvert(engine, value, typeInfo)
```

Coerces routine assignments using the declared SQL type, including MySQL boolean integers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |
| `typeInfo` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5894)

<a id="function-function-minisql-executor-executor-routinecursorprobesafe-function-routinecursorprobesafe-statement-src-minisql-executor-executor-ml-1953823877"></a>
### routineCursorProbeSafe

```ml
function routineCursorProbeSafe(statement)
```

Rejects effectful/unsupported cursor probes before any expression is evaluated. Falling back must never execute a sequence expression a second time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5812)

<a id="function-function-minisql-executor-executor-routinedeclare-function-routinedeclare-engine-frame-statement-src-minisql-executor-executor-ml-1941502620"></a>
### routineDeclare

```ml
function routineDeclare(engine, frame, statement)
```

Adds a typed declaration after checking duplicate names in the current block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6179)

<a id="function-function-minisql-executor-executor-routinedefinerid-function-routinedefinerid-procedure-src-minisql-executor-executor-ml-2034922905"></a>
### routineDefinerId

```ml
function routineDefinerId(procedure)
```

Returns a durable definer identity rather than resolving a potentially reused user name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5861)

<a id="function-function-minisql-executor-executor-routinedefinition-function-routinedefinition-procedure-src-minisql-executor-executor-ml-1315056799"></a>
### routineDefinition

```ml
function routineDefinition(procedure)
```

Decodes both legacy single-DML procedures and full version-two definitions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5692)

<a id="function-function-minisql-executor-executor-routinedefinitioncached-function-routinedefinitioncached-engine-procedure-src-minisql-executor-executor-ml-184767573"></a>
### routineDefinitionCached

```ml
function routineDefinitionCached(engine, procedure)
```

Reuses immutable parsed programs while identity, source and persisted context match. No authorization decision or mutable frame is cached, so REVOKE remains immediate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `procedure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5716)

<a id="function-function-minisql-executor-executor-routinedefinitionvisible-function-routinedefinitionvisible-engine-procedure-src-minisql-executor-executor-ml-486329367"></a>
### routineDefinitionVisible

```ml
function routineDefinitionVisible(engine, procedure)
```

Separates definition-reading privileges from the ability to invoke or alter a routine.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Effective authenticated principal used for this metadata query. |
| `procedure` | `dynamic` | — | Persisted procedure identified by durable object and definer IDs. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6900)

<a id="function-function-minisql-executor-executor-routinediagnostics-function-routinediagnostics-engine-frame-statement-src-minisql-executor-executor-ml-22052500"></a>
### routineDiagnostics

```ml
function routineDiagnostics(engine, frame, statement)
```

Returns current/stacked statement or condition diagnostics without clearing them.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6466)

<a id="function-function-minisql-executor-executor-routineemitresult-function-routineemitresult-engine-frame-result-src-minisql-executor-executor-ml-369694558"></a>
### routineEmitResult

```ml
function routineEmitResult(engine, frame, result)
```

Emits a complete materialized result only when its blocking operator has finished.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6342)

<a id="function-function-minisql-executor-executor-routineerrorpreservestransaction-function-routineerrorpreservestransaction-engine-nativeerror-src-minisql-executor-executor-ml-1841655333"></a>
### routineErrorPreservesTransaction

```ml
function routineErrorPreservesTransaction(engine, nativeError)
```

Ordinary routine SQL conditions leave prior successful transaction statements usable. Storage/transport failures retain the conservative failed-transaction contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `nativeError` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7169)

<a id="function-function-minisql-executor-executor-routineexecutenode-function-routineexecutenode-engine-frame-statement-src-minisql-executor-executor-ml-1101660716"></a>
### routineExecuteNode

```ml
function routineExecuteNode(engine, frame, statement)
```

Dispatches procedural statements; ordinary SQL uses the existing executor and permissions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6503)

<a id="function-function-minisql-executor-executor-routinefind-function-routinefind-engine-name-src-minisql-executor-executor-ml-82711079"></a>
### routineFind

```ml
function routineFind(engine, name)
```

Finds one routine in the caller's default schema.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5684)

<a id="function-function-minisql-executor-executor-routineflushassignmentwarnings-function-routineflushassignmentwarnings-engine-src-minisql-executor-executor-ml-633670174"></a>
### routineFlushAssignmentWarnings

```ml
function routineFlushAssignmentWarnings(engine)
```

Retains all conditions raised by successful parameter conversion outside a body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5973)

<a id="function-function-minisql-executor-executor-routinehandle-function-routinehandle-engine-frame-diagnostic-src-minisql-executor-executor-ml-51705236"></a>
### routineHandle

```ml
function routineHandle(engine, frame, diagnostic)
```

Selects the closest handler scope, with errno > SQLSTATE > class within that scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `diagnostic` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6134)

<a id="function-function-minisql-executor-executor-routineinformationrow-function-routineinformationrow-engine-procedure-src-minisql-executor-executor-ml-1454902107"></a>
### routineInformationRow

```ml
function routineInformationRow(engine, procedure)
```

Exposes all ROUTINES columns in MySQL order; function-only attributes remain NULL/empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Effective authenticated principal for definition visibility. |
| `procedure` | `dynamic` | — | Persisted routine record with optional historical execution context. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6919)

<a id="function-function-minisql-executor-executor-routineloop-function-routineloop-engine-frame-statement-src-minisql-executor-executor-ml-52145372"></a>
### routineLoop

```ml
function routineLoop(engine, frame, statement)
```

Runs one loop with structured LEAVE/ITERATE propagation and cooperative deadline checks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6219)

<a id="function-function-minisql-executor-executor-routinemetadatacharacterset-function-routinemetadatacharacterset-collation-src-minisql-executor-executor-ml-1761240671"></a>
### routineMetadataCharacterSet

```ml
function routineMetadataCharacterSet(collation)
```

Derives the supported character set from a binary collation, preserving unknown history.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `collation` | `dynamic` | — | Explicit or creation-time database collation, or void for legacy records. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6938)

<a id="function-function-minisql-executor-executor-routinemetadatatext-function-routinemetadatatext-value-src-minisql-executor-executor-ml-1106783685"></a>
### routineMetadataText

```ml
function routineMetadataText(value)
```

Converts an optional persisted string to SQL NULL without inventing legacy context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Native string or void from the durable routine metadata reader. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6883)

<a id="function-function-minisql-executor-executor-routinemetadatatimestamp-function-routinemetadatatimestamp-procedure-key-src-minisql-executor-executor-ml-1917153124"></a>
### routineMetadataTimestamp

```ml
function routineMetadataTimestamp(procedure, key)
```

Exposes an actual UTC timestamp using MiniSQL's epoch-microsecond SQL representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedure` | `dynamic` | — | Persisted routine record. |
| `key` | `dynamic` | — | The created or last_altered attribute name. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6891)

<a id="function-function-minisql-executor-executor-routinenormal-function-routinenormal-src-minisql-executor-executor-ml-184445182"></a>
### routineNormal

```ml
function routineNormal()
```

Builds a normal flow result without conflating it with SQL NULL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6094)

<a id="function-function-minisql-executor-executor-routineobjectname-function-routineobjectname-name-frame-src-minisql-executor-executor-ml-1429458976"></a>
### routineObjectName

```ml
function routineObjectName(name, frame)
```

Resolves an unqualified object against a routine's schema; public keeps historical spelling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5656)

<a id="function-function-minisql-executor-executor-routineoutputparameters-function-routineoutputparameters-engine-src-minisql-executor-executor-ml-1513810516"></a>
### routineOutputParameters

```ml
function routineOutputParameters(engine)
```

Captured output values are detached from lexical frames and retain SQL NULL/type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7129)

<a id="function-function-minisql-executor-executor-routineparameterinformationrow-function-routineparameterinformationrow-procedure-definition-parameter-ordinal-src-minisql-executor-executor-ml-220753772"></a>
### routineParameterInformationRow

```ml
function routineParameterInformationRow(procedure, definition, parameter, ordinal)
```

Returns a parameter's complete type metadata, using its type family rather than syntax slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedure` | `dynamic` | — | Persisted routine supplying creation-time default collation. |
| `definition` | `dynamic` | — | Parsed CREATE PROCEDURE syntax tree. |
| `parameter` | `dynamic` | — | One typed parameter declaration, including direction and text attributes. |
| `ordinal` | `dynamic` | — | One-based parameter position; procedures have no return-value row. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6950)

<a id="function-function-minisql-executor-executor-routinepersistedmetadata-function-routinepersistedmetadata-engine-definerid-existing-altering-src-minisql-executor-executor-ml-1385684881"></a>
### routinePersistedMetadata

```ml
function routinePersistedMetadata(engine, definerId, existing, altering)
```

Captures DDL timestamps and execution context without reconstructing unknown history. ALTER preserves creation-time character settings, but records its current SQL mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Active execution context used by the definition statement. |
| `definerId` | `dynamic` | — | Durable identity retained through ALTER/OR REPLACE. |
| `existing` | `dynamic` | — | Prior definition, or void for a first creation. |
| `altering` | `dynamic` | — | True for ALTER characteristics; false for CREATE/OR REPLACE. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6640)

<a id="function-function-minisql-executor-executor-routineprepare-function-routineprepare-engine-frame-statement-src-minisql-executor-executor-ml-626351044"></a>
### routinePrepare

```ml
function routinePrepare(engine, frame, statement)
```

SQL PREPARE has session lifetime and never captures a routine's local frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6487)

<a id="function-function-minisql-executor-executor-routinereadonlyexpression-function-routinereadonlyexpression-expression-src-minisql-executor-executor-ml-1978089466"></a>
### routineReadOnlyExpression

```ml
function routineReadOnlyExpression(expression)
```

Subqueries are conservatively excluded until their expanded view dependencies can be proven under the same gate; ordinary scalar trees remain eligible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5825)

<a id="function-function-minisql-executor-executor-routinereadonlynode-function-routinereadonlynode-engine-statement-schema-visited-src-minisql-executor-executor-ml-557000142"></a>
### routineReadOnlyNode

```ml
function routineReadOnlyNode(engine, statement, schema, visited)
```

Proves a procedure tree cannot write database state; characteristics are advisory. Unknown/dynamic SQL and sequence mutation fall back to exclusive execution.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `schema` | `dynamic` | — |  |
| `visited` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5740)

<a id="function-function-minisql-executor-executor-routinereadvariable-function-routinereadvariable-engine-frame-name-src-minisql-executor-executor-ml-607776520"></a>
### routineReadVariable

```ml
function routineReadVariable(engine, frame, name)
```

Reads local/session/system variables; uninitialized user variables are SQL NULL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5867)

<a id="function-function-minisql-executor-executor-routinerequiretarget-function-routinerequiretarget-engine-frame-name-src-minisql-executor-executor-ml-1286483460"></a>
### routineRequireTarget

```ml
function routineRequireTarget(engine, frame, name)
```

Validates assignment targets before executing a CALL with output parameters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5987)

<a id="function-function-minisql-executor-executor-routineresolvecondition-function-routineresolvecondition-engine-frame-condition-src-minisql-executor-executor-ml-11037182"></a>
### routineResolveCondition

```ml
function routineResolveCondition(engine, frame, condition)
```

Resolves named handler/signal conditions at their lexical declaration site.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6194)

<a id="function-function-minisql-executor-executor-routinerewriteexpression-function-routinerewriteexpression-expression-engine-frame-src-minisql-executor-executor-ml-584128721"></a>
### routineRewriteExpression

```ml
function routineRewriteExpression(expression, engine, frame)
```

Rewrites lexical variables to typed literals without altering the stored syntax tree.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5448)

<a id="function-function-minisql-executor-executor-routinerewritereturning-function-routinerewritereturning-items-engine-frame-src-minisql-executor-executor-ml-2041392243"></a>
### routineRewriteReturning

```ml
function routineRewriteReturning(items, engine, frame)
```

Implements substitute returning for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5567)

<a id="function-function-minisql-executor-executor-routinerewriteselect-function-routinerewriteselect-statement-engine-frame-src-minisql-executor-executor-ml-443349544"></a>
### routineRewriteSelect

```ml
function routineRewriteSelect(statement, engine, frame)
```

Implements substitute select for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5518)

<a id="function-function-minisql-executor-executor-routinerewritestatement-function-routinerewritestatement-statement-engine-frame-src-minisql-executor-executor-ml-2048615994"></a>
### routineRewriteStatement

```ml
function routineRewriteStatement(statement, engine, frame)
```

Implements substitute statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5581)

<a id="function-function-minisql-executor-executor-routinerun-function-routinerun-engine-frame-statement-src-minisql-executor-executor-ml-1350212600"></a>
### routineRun

```ml
function routineRun(engine, frame, statement)
```

Intercepts one native error once, then carries unhandled conditions as explicit flow.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6099)

<a id="function-function-minisql-executor-executor-routinerunlist-function-routinerunlist-engine-frame-statements-src-minisql-executor-executor-ml-303264249"></a>
### routineRunList

```ml
function routineRunList(engine, frame, statements)
```

Runs statements in source order, stopping immediately on control transfer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statements` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6125)

<a id="function-function-minisql-executor-executor-routineselect-function-routineselect-engine-frame-query-src-minisql-executor-executor-ml-1442092401"></a>
### routineSelect

```ml
function routineSelect(engine, frame, query)
```

Executes a query for a cursor or INTO without exposing its rows to the client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `query` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6402)

<a id="function-function-minisql-executor-executor-routinesendbatch-function-routinesendbatch-engine-result-resultstart-src-minisql-executor-executor-ml-1435900206"></a>
### routineSendBatch

```ml
function routineSendBatch(engine, result, resultStart)
```

A transport error terminates evaluation and cannot be swallowed by SQL handlers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |
| `resultStart` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6329)

<a id="function-function-minisql-executor-executor-routineshow-function-routineshow-engine-statement-src-minisql-executor-executor-ml-1548417497"></a>
### routineShow

```ml
function routineShow(engine, statement)
```

Implements complete SHOW CREATE/STATUS layouts with independent source access checks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Effective authenticated context for metadata and source visibility. |
| `statement` | `dynamic` | — | SHOW CREATE PROCEDURE or SHOW PROCEDURE STATUS syntax tree. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7011)

<a id="function-function-minisql-executor-executor-routineshowwarnings-function-routineshowwarnings-engine-statement-src-minisql-executor-executor-ml-1316811419"></a>
### routineShowWarnings

```ml
function routineShowWarnings(engine, statement)
```

SHOW diagnostics is observational: LIMIT/count do not clear the retained area.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7139)

<a id="function-function-minisql-executor-executor-routinesignal-function-routinesignal-engine-frame-statement-src-minisql-executor-executor-ml-152596028"></a>
### routineSignal

```ml
function routineSignal(engine, frame, statement)
```

Raises SIGNAL/RESIGNAL while preserving the stacked condition and optional information fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6414)

<a id="function-function-minisql-executor-executor-routinesourcename-function-routinesourcename-name-frame-ctes-src-minisql-executor-executor-ml-1813209819"></a>
### routineSourceName

```ml
function routineSourceName(name, frame, ctes)
```

CTE names remain lexical names even when a routine belongs to a named schema.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `ctes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5664)

<a id="function-function-minisql-executor-executor-routinesql-function-routinesql-engine-frame-statement-src-minisql-executor-executor-ml-445966792"></a>
### routineSql

```ml
function routineSql(engine, frame, statement)
```

Executes SQL under the CALL's physical gate, with statement rollback for handled DML errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6233)

<a id="function-function-minisql-executor-executor-routinestarted-function-routinestarted-engine-src-minisql-executor-executor-ml-1438717598"></a>
### routineStarted

```ml
function routineStarted(engine)
```

Whole CALL retries are permitted only before argument/body evaluation starts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7134)

<a id="function-function-minisql-executor-executor-routinestoredcontext-function-routinestoredcontext-procedure-key-fallback-src-minisql-executor-executor-ml-2070756398"></a>
### routineStoredContext

```ml
function routineStoredContext(procedure, key, fallback)
```

Retrieves persisted execution context while leaving legacy fallback policy explicit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `procedure` | `dynamic` | — | Persisted routine record. |
| `key` | `dynamic` | — | One of the documented lower-case context attribute names. |
| `fallback` | `dynamic` | — | Value used only when the old record has no such attribute. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6628)

<a id="function-function-minisql-executor-executor-routinestreamselect-function-routinestreamselect-engine-statement-src-minisql-executor-executor-ml-1831977703"></a>
### routineStreamSelect

```ml
function routineStreamSelect(engine, statement)
```

Streams an eligible SELECT with bounded resident rows while the CALL owns its gate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6350)

<a id="function-function-minisql-executor-executor-routinestrictmode-function-routinestrictmode-mode-src-minisql-executor-executor-ml-185563079"></a>
### routineStrictMode

```ml
function routineStrictMode(mode)
```

Applies the subset of SQL modes for which the engine implements semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mode` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5958)

<a id="function-function-minisql-executor-executor-routinetruth-function-routinetruth-value-src-minisql-executor-executor-ml-577394897"></a>
### routineTruth

```ml
function routineTruth(value)
```

MySQL conditionals treat NULL and numeric zero as false.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6087)

<a id="function-function-minisql-executor-executor-routinevalue-function-routinevalue-engine-frame-expression-src-minisql-executor-executor-ml-1770264489"></a>
### routineValue

```ml
function routineValue(engine, frame, expression)
```

Evaluates a scalar with lexical substitution and the normal query expression engine.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `frame` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6076)

<a id="function-function-minisql-executor-executor-routinevisible-function-routinevisible-engine-procedure-src-minisql-executor-executor-ml-749893579"></a>
### routineVisible

```ml
function routineVisible(engine, procedure)
```

Allows scoped routine metadata without implicitly revealing the routine body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | Effective authenticated principal used for this metadata query. |
| `procedure` | `dynamic` | — | Persisted procedure to inspect. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L6910)

<a id="function-function-minisql-executor-executor-rowresult-function-rowresult-columns-rows-src-minisql-executor-executor-ml-2002219676"></a>
### rowResult

```ml
function rowResult(columns, rows)
```

Implements row result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columns` | `dynamic` | — | columns value consumed by this operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L313)

<a id="function-function-minisql-executor-executor-runbounddml-function-runbounddml-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1756577415"></a>
### runBoundDml

```ml
function runBoundDml(engine, bound, pageTransaction)
```

Runs bound DML using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2099)

<a id="function-function-minisql-executor-executor-runmerge-function-runmerge-engine-statement-pagetransaction-src-minisql-executor-executor-ml-1875761044"></a>
### runMerge

```ml
function runMerge(engine, statement, pageTransaction)
```

Executes every MERGE source row against the same transactional target snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2247)

<a id="function-function-minisql-executor-executor-scanboundsource-function-scanboundsource-engine-source-pagetransaction-offset-limit-requiredcolumns-src-minisql-executor-executor-ml-77683190"></a>
### scanBoundSource

```ml
function scanBoundSource(engine, source, pageTransaction, offset, limit, requiredColumns)
```

Scans a catalog table, named query, recursive fixpoint, or recursive delta source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2495)

- [minisql.executor.executor.SelectCursor](Type-minisql-executor-executor-selectcursor-2125118112.md) — struct
<a id="function-function-minisql-executor-executor-selecthaspotentialouterreferences-function-selecthaspotentialouterreferences-statement-src-minisql-executor-executor-ml-548647991"></a>
### selectHasPotentialOuterReferences

```ml
function selectHasPotentialOuterReferences(statement)
```

Returns whether any expression in a SELECT may need a concrete outer row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1031)

<a id="function-function-minisql-executor-executor-selectprojected-function-selectprojected-engine-bound-pagetransaction-src-minisql-executor-executor-ml-488636331"></a>
### selectProjected

```ml
function selectProjected(engine, bound, pageTransaction)
```

Implements select projected for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3649)

<a id="function-function-minisql-executor-executor-selectrequiredcolumns-function-selectrequiredcolumns-bound-src-minisql-executor-executor-ml-259646204"></a>
### selectRequiredColumns

```ml
function selectRequiredColumns(bound)
```

Computes one stable local column mask per source. Global bound indexes are collected before slicing at source offsets, allowing joins to avoid fetching unrelated external values while retaining canonical flattened row positions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3340)

<a id="function-function-minisql-executor-executor-selectrows-function-selectrows-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1089900231"></a>
### selectRows

```ml
function selectRows(engine, bound, pageTransaction)
```

Implements select rows for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3745)

<a id="function-function-minisql-executor-executor-selectusesnextval-function-selectusesnextval-statement-src-minisql-executor-executor-ml-1850477497"></a>
### selectUsesNextval

```ml
function selectUsesNextval(statement)
```

Walks all SELECT clauses, CTEs, joins, and set-operation branches for NEXTVAL. Returns true as soon as any nested expression advances a sequence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4944)

<a id="function-function-minisql-executor-executor-sequenceargumentname-function-sequenceargumentname-expression-operation-src-minisql-executor-executor-ml-1314049115"></a>
### sequenceArgumentName

```ml
function sequenceArgumentName(expression, operation)
```

Implements sequence argument name for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L552)

- [minisql.executor.executor.SequenceSessionValue](Type-minisql-executor-executor-sequencesessionvalue-1742946274.md) — struct
<a id="function-function-minisql-executor-executor-sessionidentifier-function-sessionidentifier-engine-src-minisql-executor-executor-ml-473604768"></a>
### sessionIdentifier

```ml
function sessionIdentifier(engine)
```

Implements session identifier for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5402)

<a id="function-function-minisql-executor-executor-setprincipal-function-setprincipal-engine-principalid-src-minisql-executor-executor-ml-1434755529"></a>
### setPrincipal

```ml
function setPrincipal(engine, principalId)
```

Implements set principal for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `principalId` | `dynamic` | — | Identifier of principal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L500)

<a id="function-function-minisql-executor-executor-setquerymemorylimit-function-setquerymemorylimit-engine-limitbytes-src-minisql-executor-executor-ml-2012910312"></a>
### setQueryMemoryLimit

```ml
function setQueryMemoryLimit(engine, limitBytes)
```

Configures the soft per-query memory budget used by blocking operators.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `limitBytes` | `dynamic` | — | limitBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L320)

<a id="function-function-minisql-executor-executor-simplebatcheligible-function-simplebatcheligible-bound-executable-src-minisql-executor-executor-ml-847775378"></a>
### simpleBatchEligible

```ml
function simpleBatchEligible(bound, executable)
```

Identifies a pipeline that can filter, project and apply LIMIT directly over bounded scan batches. Blocking relational operators retain their specialized materializing paths.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `executable` | `dynamic` | — | executable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3404)

<a id="function-function-minisql-executor-executor-simplebatchprojected-function-simplebatchprojected-engine-bound-pagetransaction-requiredcolumns-wherepredicate-src-minisql-executor-executor-ml-1985148857"></a>
### simpleBatchProjected

```ml
function simpleBatchProjected(engine, bound, pageTransaction, requiredColumns, wherePredicate)
```

Executes a non-blocking single-table query with at most one source batch and the final result resident at once. This removes the former full scanned-row materialization while preserving the QueryResult API required by protocol v1.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `wherePredicate` | `dynamic` | — | wherePredicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3419)

<a id="function-function-minisql-executor-executor-simplecountstareligible-function-simplecountstareligible-bound-src-minisql-executor-executor-ml-1341036652"></a>
### simpleCountStarEligible

```ml
function simpleCountStarEligible(bound)
```

Recognizes the exact aggregate shape whose result depends only on live-slot visibility. More complex COUNT variants retain the general relational path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3378)

<a id="function-function-minisql-executor-executor-simplecountstarprojected-function-simplecountstarprojected-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1234174103"></a>
### simpleCountStarProjected

```ml
function simpleCountStarProjected(engine, bound, pageTransaction)
```

Projects a scalar COUNT(*) directly from checksum-verified heap slot headers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3393)

<a id="function-function-minisql-executor-executor-simpletopneligible-function-simpletopneligible-bound-executable-src-minisql-executor-executor-ml-1312478808"></a>
### simpleTopNEligible

```ml
function simpleTopNEligible(bound, executable)
```

Recognizes an ordered single-table LIMIT that can maintain only the current best window while scanning. Projection and ORDER BY expressions must be row-local because subqueries require the general materializing pipeline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `executable` | `dynamic` | — | executable value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3593)

<a id="function-function-minisql-executor-executor-simpletopnprojected-function-simpletopnprojected-engine-bound-pagetransaction-requiredcolumns-wherepredicate-src-minisql-executor-executor-ml-720681283"></a>
### simpleTopNProjected

```ml
function simpleTopNProjected(engine, bound, pageTransaction, requiredColumns, wherePredicate)
```

Fuses scan, filter, projection, and bounded Top-N retention. At most one scan batch plus LIMIT+OFFSET projected rows are resident, so large source tables no longer dominate memory for small ordered result windows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `wherePredicate` | `dynamic` | — | wherePredicate value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3609)

<a id="function-function-minisql-executor-executor-splitobjectname-function-splitobjectname-name-src-minisql-executor-executor-ml-822390495"></a>
### splitObjectName

```ml
function splitObjectName(name)
```

Splits a canonical object name into schema and local name, defaulting to public.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2400)

<a id="function-function-minisql-executor-executor-stageddl-function-stageddl-ddltransaction-bound-src-minisql-executor-executor-ml-1110310964"></a>
### stageDdl

```ml
function stageDdl(ddlTransaction, bound)
```

Implements stage DDL for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ddlTransaction` | `dynamic` | — | ddlTransaction value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1387)

<a id="function-function-minisql-executor-executor-statementcallsroutine-function-statementcallsroutine-engine-statement-src-minisql-executor-executor-ml-1647226515"></a>
### statementCallsRoutine

```ml
function statementCallsRoutine(engine, statement)
```

Recognizes a public CALL even when the client used a prepared wrapper.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5001)

<a id="function-function-minisql-executor-executor-statementdiagnostic-function-statementdiagnostic-engine-nativeerror-src-minisql-executor-executor-ml-328684097"></a>
### statementDiagnostic

```ml
function statementDiagnostic(engine, nativeError)
```

Exposes a structured condition while keeping legacy native error codes intact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `nativeError` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7083)

<a id="function-function-minisql-executor-executor-statementisolation-function-statementisolation-engine-src-minisql-executor-executor-ml-1687141350"></a>
### statementIsolation

```ml
function statementIsolation(engine)
```

Implements statement isolation for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5015)

<a id="function-function-minisql-executor-executor-statementrequireswrite-function-statementrequireswrite-engine-statement-src-minisql-executor-executor-ml-974547963"></a>
### statementRequiresWrite

```ml
function statementRequiresWrite(engine, statement)
```

An analyzed read-only CALL needs no logical writer lease or write fence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4995)

<a id="function-function-minisql-executor-executor-statementusesreadlock-function-statementusesreadlock-statement-src-minisql-executor-executor-ml-927737241"></a>
### statementUsesReadLock

```ml
function statementUsesReadLock(statement)
```

Classifies statements that may share physical database execution. Pure SELECT, pure EXPLAIN, and metadata inspection are reads; a SELECT tree containing NEXTVAL is deliberately excluded because it changes sequence state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4973)

<a id="function-function-minisql-executor-executor-statementuseswritelock-function-statementuseswritelock-statement-src-minisql-executor-executor-ml-1933721929"></a>
### statementUsesWriteLock

```ml
function statementUsesWriteLock(statement)
```

Classifies statements that require exclusive physical database execution. This includes DML, DDL, DCL, maintenance, and SELECT statements containing NEXTVAL. Transaction-control/session-only statements are handled separately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4984)

<a id="function-function-minisql-executor-executor-statementwarnings-function-statementwarnings-engine-src-minisql-executor-executor-ml-219144310"></a>
### statementWarnings

```ml
function statementWarnings(engine)
```

Returns only nonfatal warning/not-found records for connector warning chains.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L7097)

<a id="function-function-minisql-executor-executor-substituteexpression-function-substituteexpression-expression-parameters-src-minisql-executor-executor-ml-1566317082"></a>
### substituteExpression

```ml
function substituteExpression(expression, parameters)
```

Implements substitute expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `parameters` | `dynamic` | — | parameters value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L654)

<a id="function-function-minisql-executor-executor-substituteoutercolumn-function-substituteoutercolumn-expression-sources-rowvalues-statement-src-minisql-executor-executor-ml-2079039637"></a>
### substituteOuterColumn

```ml
function substituteOuterColumn(expression, sources, rowValues, statement)
```

Resolves a qualified outer reference against the current joined source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `rowValues` | `dynamic` | — | rowValues value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1060)

<a id="function-function-minisql-executor-executor-substituteouterexpression-function-substituteouterexpression-expression-sources-rowvalues-statement-src-minisql-executor-executor-ml-544362361"></a>
### substituteOuterExpression

```ml
function substituteOuterExpression(expression, sources, rowValues, statement)
```

Substitutes outer-row values throughout an expression while preserving inner shadowing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `rowValues` | `dynamic` | — | rowValues value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1085)

<a id="function-function-minisql-executor-executor-substituteouterselect-function-substituteouterselect-statement-sources-rowvalues-src-minisql-executor-executor-ml-1721802975"></a>
### substituteOuterSelect

```ml
function substituteOuterSelect(statement, sources, rowValues)
```

Copies a nested SELECT with every non-shadowed outer reference replaced by a row literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `sources` | `dynamic` | — | sources value consumed by this operation. |
| `rowValues` | `dynamic` | — | rowValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1142)

<a id="function-function-minisql-executor-executor-substitutereturning-function-substitutereturning-items-parameters-src-minisql-executor-executor-ml-454875552"></a>
### substituteReturning

```ml
function substituteReturning(items, parameters)
```

Implements substitute returning for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Items consumed or updated by the operation. |
| `parameters` | `dynamic` | — | parameters value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L759)

<a id="function-function-minisql-executor-executor-substituteselect-function-substituteselect-statement-parameters-src-minisql-executor-executor-ml-959972121"></a>
### substituteSelect

```ml
function substituteSelect(statement, parameters)
```

Implements substitute select for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `parameters` | `dynamic` | — | parameters value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L716)

<a id="function-function-minisql-executor-executor-substitutestatement-function-substitutestatement-statement-parameters-src-minisql-executor-executor-ml-152799815"></a>
### substituteStatement

```ml
function substituteStatement(statement, parameters)
```

Implements substitute statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | statement value consumed by this operation. |
| `parameters` | `dynamic` | — | parameters value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L773)

<a id="function-function-minisql-executor-executor-targetmilestone-function-targetmilestone-src-minisql-executor-executor-ml-268555050"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql executor executor module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L5435)

<a id="constant-constant-minisql-executor-executor-transaction-state-const-transaction-state-9011-src-minisql-executor-executor-ml-342426264"></a>
### TRANSACTION_STATE

```ml
const TRANSACTION_STATE = 9011
```

Defines the transaction state constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L51)

<a id="function-function-minisql-executor-executor-triggercolumnvalue-function-triggercolumnvalue-table-row-qualifier-columnname-src-minisql-executor-executor-ml-1984102729"></a>
### triggerColumnValue

```ml
function triggerColumnValue(table, row, qualifier, columnName)
```

Implements trigger column value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `row` | `dynamic` | — | row value consumed by this operation. |
| `qualifier` | `dynamic` | — | qualifier value consumed by this operation. |
| `columnName` | `dynamic` | — | columnName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1497)

<a id="function-function-minisql-executor-executor-triggereventcode-function-triggereventcode-bound-src-minisql-executor-executor-ml-1747003116"></a>
### triggerEventCode

```ml
function triggerEventCode(bound)
```

Implements trigger event code for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1482)

<a id="function-function-minisql-executor-executor-typedescription-function-typedescription-column-src-minisql-executor-executor-ml-348776582"></a>
### typeDescription

```ml
function typeDescription(column)
```

Implements type description for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `column` | `dynamic` | — | column value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4697)

<a id="constant-constant-minisql-executor-executor-unsupported-sql-const-unsupported-sql-9025-src-minisql-executor-executor-ml-512500125"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```

Defines the unsupported sql constant used by the minisql executor executor module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L61)

<a id="function-function-minisql-executor-executor-updatetouchestriggercolumn-function-updatetouchestriggercolumn-bound-trigger-src-minisql-executor-executor-ml-225563956"></a>
### updateTouchesTriggerColumn

```ml
function updateTouchesTriggerColumn(bound, trigger)
```

Implements update touches trigger column for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — | bound value consumed by this operation. |
| `trigger` | `dynamic` | — | trigger value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1762)

<a id="function-function-minisql-executor-executor-validatealtertablerows-function-validatealtertablerows-engine-bound-src-minisql-executor-executor-ml-1988709686"></a>
### validateAlterTableRows

```ml
function validateAlterTableRows(engine, bound)
```

Validates ALTER TABLE operations whose safety depends on currently stored rows. DROP COLUMN deliberately starts with empty tables so the versioned row codec never has to reinterpret a wider historical row as a shorter layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `bound` | `dynamic` | — | bound value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1400)

<a id="function-function-minisql-executor-executor-validateopen-function-validateopen-engine-operation-src-minisql-executor-executor-ml-799733671"></a>
### validateOpen

```ml
function validateOpen(engine, operation)
```

Validates open for the minisql executor executor workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L524)
