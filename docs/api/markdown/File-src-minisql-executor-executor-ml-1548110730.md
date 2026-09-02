# `src/minisql/executor/executor.ml`

[Home](README.md) · [Files](Files.md)

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
- `minisql/transaction/transaction.ml` as `transaction` → [src/minisql/transaction/transaction.ml](File-src-minisql-transaction-transaction-ml-1157597470.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-executor-abortforconcurrency-function-abortforconcurrency-engine-src-minisql-executor-executor-ml-430320414"></a>
### abortForConcurrency

```ml
function abortForConcurrency(engine)
```

Implements abort for concurrency for this module. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4709)

<a id="function-function-minisql-executor-executor-allprivilegecodes-function-allprivilegecodes-objecttype-src-minisql-executor-executor-ml-2013702411"></a>
### allPrivilegeCodes

```ml
function allPrivilegeCodes(objectType)
```

Implements all privilege codes for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3966)

<a id="constant-constant-minisql-executor-executor-analyze-sample-rows-const-analyze-sample-rows-8192-src-minisql-executor-executor-ml-481528021"></a>
### ANALYZE_SAMPLE_ROWS

```ml
const ANALYZE_SAMPLE_ROWS = 8192
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L49)

<a id="function-function-minisql-executor-executor-analyzecolumngroups-function-analyzecolumngroups-engine-table-src-minisql-executor-executor-ml-189656278"></a>
### analyzeColumnGroups

```ml
function analyzeColumnGroups(engine, table)
```

Implements analyze table for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies. Returns distinct composite index keys eligible for joint NDV statistics. ANALYZE limits persisted groups to eight columns so the v4 catalog remains compact and deterministic even when applications define very wide indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3431)

<a id="function-function-minisql-executor-executor-analyzetable-function-analyzetable-engine-state-table-src-minisql-executor-executor-ml-945335429"></a>
### analyzeTable

```ml
function analyzeTable(engine, state, table)
```

Refreshes one table's exact population, bounded sample distributions, joint composite-key statistics, and physical page count in the supplied catalog.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3465)

<a id="function-function-minisql-executor-executor-appendauditoutcome-function-appendauditoutcome-engine-statement-success-detail-src-minisql-executor-executor-ml-1368843043"></a>
### appendAuditOutcome

```ml
function appendAuditOutcome(engine, statement, success, detail)
```

Appends audit outcome using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `success` | `dynamic` | — |  |
| `detail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4520)

<a id="function-function-minisql-executor-executor-attach-function-attach-database-src-minisql-executor-executor-ml-862535765"></a>
### attach

```ml
function attach(database)
```

Implements attach for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L413)

<a id="function-function-minisql-executor-executor-auditaction-function-auditaction-statement-src-minisql-executor-executor-ml-1320155247"></a>
### auditAction

```ml
function auditAction(statement)
```

Implements audit action for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4453)

<a id="function-function-minisql-executor-executor-auditeventtype-function-auditeventtype-statement-src-minisql-executor-executor-ml-1385440821"></a>
### auditEventType

```ml
function auditEventType(statement)
```

Implements audit event type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4509)

<a id="constant-constant-minisql-executor-executor-authentication-required-const-authentication-required-9028-src-minisql-executor-executor-ml-41784456"></a>
### AUTHENTICATION_REQUIRED

```ml
const AUTHENTICATION_REQUIRED = 9028
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L52)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3841)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3892)

<a id="function-function-minisql-executor-executor-authorizeexpressionqueriesinternal-function-authorizeexpressionqueriesinternal-engine-expression-viewstack-ctenames-src-minisql-executor-executor-ml-1488344617"></a>
### authorizeExpressionQueriesInternal

```ml
function authorizeExpressionQueriesInternal(engine, expression, viewStack, cteNames)
```

Implements authorize expression queries internal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |
| `cteNames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3694)

<a id="function-function-minisql-executor-executor-authorizenamedsource-function-authorizenamedsource-engine-state-name-viewstack-src-minisql-executor-executor-ml-622327367"></a>
### authorizeNamedSource

```ml
function authorizeNamedSource(engine, state, name, viewStack)
```

Implements authorize named source for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3758)

<a id="function-function-minisql-executor-executor-authorizeselect-function-authorizeselect-engine-statement-src-minisql-executor-executor-ml-1328749105"></a>
### authorizeSelect

```ml
function authorizeSelect(engine, statement)
```

Implements authorize select for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3818)

<a id="function-function-minisql-executor-executor-authorizeselectinternal-function-authorizeselectinternal-engine-statement-viewstack-inheritedctenames-src-minisql-executor-executor-ml-243315710"></a>
### authorizeSelectInternal

```ml
function authorizeSelectInternal(engine, statement, viewStack, inheritedCteNames)
```

Implements authorize select internal for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `viewStack` | `dynamic` | — |  |
| `inheritedCteNames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3781)

<a id="function-function-minisql-executor-executor-authorizeselectitems-function-authorizeselectitems-engine-items-src-minisql-executor-executor-ml-161153294"></a>
### authorizeSelectItems

```ml
function authorizeSelectItems(engine, items)
```

Implements authorize select items for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3825)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3926)

<a id="function-function-minisql-executor-executor-beginexplicit-function-beginexplicit-engine-statement-src-minisql-executor-executor-ml-1230393825"></a>
### beginExplicit

```ml
function beginExplicit(engine, statement)
```

Implements begin explicit for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1165)

<a id="function-function-minisql-executor-executor-beginquerycontrol-function-beginquerycontrol-engine-src-minisql-executor-executor-ml-280625674"></a>
### beginQueryControl

```ml
function beginQueryControl(engine)
```

Starts one top-level cooperative token after global memory admission.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L351)

<a id="function-function-minisql-executor-executor-bind-function-bind-statement-engine-src-minisql-executor-executor-ml-179120623"></a>
### bind

```ml
function bind(statement, engine)
```

Binds bind using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1213)

<a id="constant-constant-minisql-executor-executor-binding-error-const-binding-error-9020-src-minisql-executor-executor-ml-846252900"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L47)

<a id="function-function-minisql-executor-executor-boundcolumncount-function-boundcolumncount-bound-src-minisql-executor-executor-ml-244227792"></a>
### boundColumnCount

```ml
function boundColumnCount(bound)
```

Computes the global flattened column width of all bound sources.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2244)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2356)

- [minisql.executor.executor.CachedPlan](Type-minisql-executor-executor-cachedplan-851955911.md) — struct
<a id="function-function-minisql-executor-executor-canonicalequalitycolumns-function-canonicalequalitycolumns-condition-source-src-minisql-executor-executor-ml-997459808"></a>
### canonicalEqualityColumns

```ml
function canonicalEqualityColumns(condition, source)
```

Returns [joined-side global column, new-source local column] for a canonical equality join, or void for an unsupported condition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `condition` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2341)

<a id="function-function-minisql-executor-executor-canonicalhashjoin-function-canonicalhashjoin-engine-bound-leftrows-rightrows-sourceindex-condition-buildright-src-minisql-executor-executor-ml-1834696111"></a>
### canonicalHashJoin

```ml
function canonicalHashJoin(engine, bound, leftRows, rightRows, sourceIndex, condition, buildRight)
```

Hash-joins a reordered INNER source while preserving canonical SQL column positions. Full key equality and predicate rechecks resolve collisions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |
| `buildRight` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2378)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2526)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2460)

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2493)

<a id="function-function-minisql-executor-executor-canonicalizerows-function-canonicalizerows-bound-sourceindex-rows-src-minisql-executor-executor-ml-2021242146"></a>
### canonicalizeRows

```ml
function canonicalizeRows(bound, sourceIndex, rows)
```

Expands a compact source row set into stable global bound-column positions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2286)

<a id="function-function-minisql-executor-executor-canonicalnestedjoin-function-canonicalnestedjoin-engine-bound-leftrows-rightrows-sourceindex-condition-src-minisql-executor-executor-ml-1881530059"></a>
### canonicalNestedJoin

```ml
function canonicalNestedJoin(engine, bound, leftRows, rightRows, sourceIndex, condition)
```

Applies the semantic nested-loop fallback to one reordered INNER join edge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2322)

<a id="function-function-minisql-executor-executor-canonicalnestedjoincount-function-canonicalnestedjoincount-engine-bound-leftrows-rightrows-sourceindex-condition-src-minisql-executor-executor-ml-478190553"></a>
### canonicalNestedJoinCount

```ml
function canonicalNestedJoinCount(engine, bound, leftRows, rightRows, sourceIndex, condition)
```

Counts a final reordered nested-loop join without retaining its joined rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2435)

<a id="function-function-minisql-executor-executor-canonicalnullvalues-function-canonicalnullvalues-bound-src-minisql-executor-executor-ml-833623414"></a>
### canonicalNullValues

```ml
function canonicalNullValues(bound)
```

Creates a complete, type-correct canonical row. Typed SQL NULL placeholders keep global bound-column positions evaluable while a reordered join has not yet attached every source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2256)

<a id="function-function-minisql-executor-executor-canonicalsourcerow-function-canonicalsourcerow-bound-sourceindex-row-src-minisql-executor-executor-ml-186814829"></a>
### canonicalSourceRow

```ml
function canonicalSourceRow(bound, sourceIndex, row)
```

Expands one local source row into canonical bound-column positions. The membership/reference array lets a reordered join fill sources without inferring presence from SQL NULL values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2271)

<a id="function-function-minisql-executor-executor-close-function-close-engine-src-minisql-executor-executor-ml-1972374698"></a>
### close

```ml
function close(engine)
```

Closes close using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4731)

<a id="constant-constant-minisql-executor-executor-closed-handle-const-closed-handle-9008-src-minisql-executor-executor-ml-1236346350"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L45)

<a id="function-function-minisql-executor-executor-closeselectcursor-function-closeselectcursor-cursor-src-minisql-executor-executor-ml-2056924830"></a>
### closeSelectCursor

```ml
function closeSelectCursor(cursor)
```

Releases every resource held by a forward-only SELECT cursor. Cleanup is idempotent so protocol disconnect and normal exhaustion can share this path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3057)

<a id="function-function-minisql-executor-executor-collectrequiredcolumns-function-collectrequiredcolumns-expression-requiredcolumns-src-minisql-executor-executor-ml-1062741646"></a>
### collectRequiredColumns

```ml
function collectRequiredColumns(expression, requiredColumns)
```

Marks every base-table column referenced by an expression tree. Returning false disables projection pushdown for shapes whose dependencies cannot be proven locally (notably correlated subqueries).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2892)

<a id="function-function-minisql-executor-executor-combinecanonical-function-combinecanonical-bound-left-sourceindex-right-src-minisql-executor-executor-ml-149994786"></a>
### combineCanonical

```ml
function combineCanonical(bound, left, sourceIndex, right)
```

Adds one compact source row to an already canonical join row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `left` | `dynamic` | — |  |
| `sourceIndex` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2295)

<a id="function-function-minisql-executor-executor-commandresult-function-commandresult-command-affectedrows-message-src-minisql-executor-executor-ml-2114383351"></a>
### commandResult

```ml
function commandResult(command, affectedRows, message)
```

Implements command result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `command` | `dynamic` | — |  |
| `affectedRows` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L265)

<a id="function-function-minisql-executor-executor-commitexplicit-function-commitexplicit-engine-src-minisql-executor-executor-ml-1886859938"></a>
### commitExplicit

```ml
function commitExplicit(engine)
```

Implements commit explicit for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3562)

<a id="function-function-minisql-executor-executor-commitpagetransaction-function-commitpagetransaction-engine-pagetransaction-deltabound-deltaresult-src-minisql-executor-executor-ml-440886384"></a>
### commitPageTransaction

```ml
function commitPageTransaction(engine, pageTransaction, deltaBound, deltaResult)
```

Implements commit page transaction for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `deltaBound` | `dynamic` | — |  |
| `deltaResult` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1860)

<a id="function-function-minisql-executor-executor-componentname-function-componentname-src-minisql-executor-executor-ml-404001540"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4748)

<a id="function-function-minisql-executor-executor-constantparameterexpression-function-constantparameterexpression-expression-src-minisql-executor-executor-ml-141129440"></a>
### constantParameterExpression

```ml
function constantParameterExpression(expression)
```

Implements constant parameter expression for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L535)

<a id="constant-constant-minisql-executor-executor-constraint-violation-const-constraint-violation-9021-src-minisql-executor-executor-ml-335193633"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L48)

<a id="function-function-minisql-executor-executor-constraintkindname-function-constraintkindname-kind-src-minisql-executor-executor-ml-59503758"></a>
### constraintKindName

```ml
function constraintKindName(kind)
```

Implements constraint kind name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4175)

<a id="function-function-minisql-executor-executor-controllednestedjoin-function-controllednestedjoin-engine-leftrows-rightrows-boundjoin-src-minisql-executor-executor-ml-1211212559"></a>
### controlledNestedJoin

```ml
function controlledNestedJoin(engine, leftRows, rightRows, boundJoin)
```

Applies the semantic nested-loop join while polling inside the candidate loop. Keeping the control-aware orchestration in this module avoids coupling the reusable row-combination module to server session state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `leftRows` | `dynamic` | — |  |
| `rightRows` | `dynamic` | — |  |
| `boundJoin` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2645)

<a id="constant-constant-minisql-executor-executor-corrupt-data-const-corrupt-data-9004-src-minisql-executor-executor-ml-511771980"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L44)

<a id="function-function-minisql-executor-executor-currentplanninggeneration-function-currentplanninggeneration-engine-src-minisql-executor-executor-ml-1657511006"></a>
### currentPlanningGeneration

```ml
function currentPlanningGeneration(engine)
```

Returns the process-local planning generation shared across attached sessions. Committed DDL and statistics maintenance advance this counter while the execution gate is held, avoiding a schema-history file read per EXECUTE. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L514)

<a id="function-function-minisql-executor-executor-currentsequencevalue-function-currentsequencevalue-engine-name-src-minisql-executor-executor-ml-195081905"></a>
### currentSequenceValue

```ml
function currentSequenceValue(engine, name)
```

Implements current sequence value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L502)

<a id="constant-constant-minisql-executor-executor-cursor-source-batch-rows-const-cursor-source-batch-rows-16-src-minisql-executor-executor-ml-835040656"></a>
### CURSOR_SOURCE_BATCH_ROWS

```ml
const CURSOR_SOURCE_BATCH_ROWS = 16
```

Cursor scans retain at most the historical sixteen source rows at once, then coalesce narrow projected rows until one preferred protocol frame is full.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L65)

<a id="constant-constant-minisql-executor-executor-cursor-target-batch-bytes-const-cursor-target-batch-bytes-1048552-src-minisql-executor-executor-ml-1571366116"></a>
### CURSOR_TARGET_BATCH_BYTES

```ml
const CURSOR_TARGET_BATCH_BYTES = 1048552
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L66)

<a id="function-function-minisql-executor-executor-databasehandle-function-databasehandle-engine-src-minisql-executor-executor-ml-843164806"></a>
### databaseHandle

```ml
function databaseHandle(engine)
```

Implements database handle for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3641)

<a id="function-function-minisql-executor-executor-dcltarget-function-dcltarget-engine-objecttype-objectname-src-minisql-executor-executor-ml-115961041"></a>
### dclTarget

```ml
function dclTarget(engine, objectType, objectName)
```

Implements dcl target for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3993)

<a id="constant-constant-minisql-executor-executor-ddl-state-const-ddl-state-9023-src-minisql-executor-executor-ml-2108451247"></a>
### DDL_STATE

```ml
const DDL_STATE = 9023
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L50)

<a id="function-function-minisql-executor-executor-decodeprocedureparameternames-function-decodeprocedureparameternames-encoded-src-minisql-executor-executor-ml-1001483478"></a>
### decodeProcedureParameterNames

```ml
function decodeProcedureParameterNames(encoded)
```

Decodes ordered parameter names while accepting the pre-metadata representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1703)

<a id="function-function-minisql-executor-executor-decodeprocedureparametertype-function-decodeprocedureparametertype-encoded-parameterindex-src-minisql-executor-executor-ml-885778835"></a>
### decodeProcedureParameterType

```ml
function decodeProcedureParameterType(encoded, parameterIndex)
```

Reconstructs one declared SQL parameter type from flattened durable metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |
| `parameterIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1716)

<a id="constant-constant-minisql-executor-executor-default-query-memory-bytes-const-default-query-memory-bytes-67108864-src-minisql-executor-executor-ml-1329537879"></a>
### DEFAULT_QUERY_MEMORY_BYTES

```ml
const DEFAULT_QUERY_MEMORY_BYTES = 67108864
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L67)

<a id="function-function-minisql-executor-executor-dmlcommand-function-dmlcommand-bound-src-minisql-executor-executor-ml-254293948"></a>
### dmlCommand

```ml
function dmlCommand(bound)
```

Implements DML command for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1848)

<a id="function-function-minisql-executor-executor-encodeprocedureparameters-function-encodeprocedureparameters-parameters-src-minisql-executor-executor-ml-1980748170"></a>
### encodeProcedureParameters

```ml
function encodeProcedureParameters(parameters)
```

Flattens named procedure inputs and their exact SQL types into durable metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parameters` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1688)

- [minisql.executor.executor.Engine](Type-minisql-executor-executor-engine-929091680.md) — struct
<a id="function-function-minisql-executor-executor-ensureexplicitddl-function-ensureexplicitddl-engine-src-minisql-executor-executor-ml-696335918"></a>
### ensureExplicitDdl

```ml
function ensureExplicitDdl(engine)
```

Ensures explicit DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1198)

<a id="function-function-minisql-executor-executor-ensureexplicitdml-function-ensureexplicitdml-engine-src-minisql-executor-executor-ml-264740988"></a>
### ensureExplicitDml

```ml
function ensureExplicitDml(engine)
```

Ensures explicit DML using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1184)

<a id="function-function-minisql-executor-executor-estimatedoperatorbytes-function-estimatedoperatorbytes-engine-rows-src-minisql-executor-executor-ml-1024673711"></a>
### estimatedOperatorBytes

```ml
function estimatedOperatorBytes(engine, rows)
```

Estimates an array of scanned/projected rows and updates the peak diagnostic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L304)

<a id="function-function-minisql-executor-executor-estimatedvaluebytes-function-estimatedvaluebytes-value-src-minisql-executor-executor-ml-1784020573"></a>
### estimatedValueBytes

```ml
function estimatedValueBytes(value)
```

Estimates the retained representation of one SQL value. This is a soft accounting model, not a heap allocator contract; variable payload bytes are nevertheless measured exactly so wide-row spill decisions are meaningful.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L296)

<a id="function-function-minisql-executor-executor-evaluaterecursivequery-function-evaluaterecursivequery-engine-query-pagetransaction-src-minisql-executor-executor-ml-1113355987"></a>
### evaluateRecursiveQuery

```ml
function evaluateRecursiveQuery(engine, query, pageTransaction)
```

Evaluates anchor rows followed by semi-naive delta iterations until a fixpoint. UNION removes rows already seen; UNION ALL preserves bags and therefore relies on an empty recursive result to terminate. The depth guard diagnoses runaway SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `query` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2078)

<a id="function-function-minisql-executor-executor-executealteruser-function-executealteruser-engine-statement-src-minisql-executor-executor-ml-911086291"></a>
### executeAlterUser

```ml
function executeAlterUser(engine, statement)
```

Executes alter user using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4024)

<a id="function-function-minisql-executor-executor-executeanalyze-function-executeanalyze-engine-statement-src-minisql-executor-executor-ml-959348459"></a>
### executeAnalyze

```ml
function executeAnalyze(engine, statement)
```

Executes analyze using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3477)

<a id="function-function-minisql-executor-executor-executecall-function-executecall-engine-statement-src-minisql-executor-executor-ml-1362716837"></a>
### executeCall

```ml
function executeCall(engine, statement)
```

Evaluates CALL arguments, substitutes named inputs, and executes the persisted DML body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1748)

<a id="function-function-minisql-executor-executor-executecreateprincipal-function-executecreateprincipal-engine-statement-src-minisql-executor-executor-ml-1740915859"></a>
### executeCreatePrincipal

```ml
function executeCreatePrincipal(engine, statement)
```

Executes create principal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4011)

<a id="function-function-minisql-executor-executor-executedcl-function-executedcl-engine-statement-src-minisql-executor-executor-ml-313676291"></a>
### executeDcl

```ml
function executeDcl(engine, statement)
```

Executes dcl using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4101)

<a id="function-function-minisql-executor-executor-executeddl-function-executeddl-engine-statement-src-minisql-executor-executor-ml-1358160011"></a>
### executeDdl

```ml
function executeDdl(engine, statement)
```

Executes DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1794)

<a id="function-function-minisql-executor-executor-executedeallocate-function-executedeallocate-engine-statement-src-minisql-executor-executor-ml-1991397713"></a>
### executeDeallocate

```ml
function executeDeallocate(engine, statement)
```

Executes deallocate using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1129)

<a id="function-function-minisql-executor-executor-executedescribetable-function-executedescribetable-engine-statement-src-minisql-executor-executor-ml-219793075"></a>
### executeDescribeTable

```ml
function executeDescribeTable(engine, statement)
```

Executes describe table using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4254)

<a id="function-function-minisql-executor-executor-executedml-function-executedml-engine-statement-src-minisql-executor-executor-ml-1540650651"></a>
### executeDml

```ml
function executeDml(engine, statement)
```

Executes DML using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1940)

<a id="function-function-minisql-executor-executor-executedropprincipal-function-executedropprincipal-engine-statement-src-minisql-executor-executor-ml-1743544287"></a>
### executeDropPrincipal

```ml
function executeDropPrincipal(engine, statement)
```

Executes drop principal using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4041)

<a id="function-function-minisql-executor-executor-executeexplain-function-executeexplain-engine-statement-src-minisql-executor-executor-ml-1894687515"></a>
### executeExplain

```ml
function executeExplain(engine, statement)
```

Executes explain using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3512)

<a id="function-function-minisql-executor-executor-executegrantprivilege-function-executegrantprivilege-engine-statement-src-minisql-executor-executor-ml-993493515"></a>
### executeGrantPrivilege

```ml
function executeGrantPrivilege(engine, statement)
```

Executes grant privilege using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4075)

<a id="function-function-minisql-executor-executor-executegrantrole-function-executegrantrole-engine-statement-src-minisql-executor-executor-ml-639891795"></a>
### executeGrantRole

```ml
function executeGrantRole(engine, statement)
```

Executes grant role using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4055)

<a id="function-function-minisql-executor-executor-executemerge-function-executemerge-engine-statement-src-minisql-executor-executor-ml-248371447"></a>
### executeMerge

```ml
function executeMerge(engine, statement)
```

Runs MERGE in an existing explicit transaction or creates one atomic implicit transaction.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2026)

<a id="function-function-minisql-executor-executor-executeprepare-function-executeprepare-engine-statement-src-minisql-executor-executor-ml-416137443"></a>
### executePrepare

```ml
function executePrepare(engine, statement)
```

Executes prepare using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1098)

<a id="function-function-minisql-executor-executor-executeprepared-function-executeprepared-engine-statement-src-minisql-executor-executor-ml-1951566227"></a>
### executePrepared

```ml
function executePrepared(engine, statement)
```

Executes prepared using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1107)

<a id="function-function-minisql-executor-executor-executeprocedureddl-function-executeprocedureddl-engine-statement-src-minisql-executor-executor-ml-4246823"></a>
### executeProcedureDdl

```ml
function executeProcedureDdl(engine, statement)
```

Creates, replaces, or drops a durable single-statement stored procedure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1728)

<a id="function-function-minisql-executor-executor-executereindex-function-executereindex-engine-statement-src-minisql-executor-executor-ml-419889123"></a>
### executeReindex

```ml
function executeReindex(engine, statement)
```

Executes reindex using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4142)

<a id="function-function-minisql-executor-executor-executereleasesavepoint-function-executereleasesavepoint-engine-statement-src-minisql-executor-executor-ml-1062203289"></a>
### executeReleaseSavepoint

```ml
function executeReleaseSavepoint(engine, statement)
```

Executes release savepoint using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3621)

<a id="function-function-minisql-executor-executor-executerevokeprivilege-function-executerevokeprivilege-engine-statement-src-minisql-executor-executor-ml-1896721351"></a>
### executeRevokePrivilege

```ml
function executeRevokePrivilege(engine, statement)
```

Executes revoke privilege using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4088)

<a id="function-function-minisql-executor-executor-executerevokerole-function-executerevokerole-engine-statement-src-minisql-executor-executor-ml-1589397277"></a>
### executeRevokeRole

```ml
function executeRevokeRole(engine, statement)
```

Executes revoke role using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4065)

<a id="function-function-minisql-executor-executor-executerollbackto-function-executerollbackto-engine-statement-src-minisql-executor-executor-ml-1019368515"></a>
### executeRollbackTo

```ml
function executeRollbackTo(engine, statement)
```

Executes rollback to using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3611)

<a id="function-function-minisql-executor-executor-executesavepoint-function-executesavepoint-engine-statement-src-minisql-executor-executor-ml-1459858347"></a>
### executeSavepoint

```ml
function executeSavepoint(engine, statement)
```

Executes savepoint using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3600)

<a id="function-function-minisql-executor-executor-executeschemaddl-function-executeschemaddl-engine-statement-src-minisql-executor-executor-ml-1902403195"></a>
### executeSchemaDdl

```ml
function executeSchemaDdl(engine, statement)
```

Executes durable CREATE/DROP SCHEMA operations outside user transactions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1256)

<a id="function-function-minisql-executor-executor-executeselect-function-executeselect-engine-statement-src-minisql-executor-executor-ml-551814781"></a>
### executeSelect

```ml
function executeSelect(engine, statement)
```

Executes select using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3548)

<a id="function-function-minisql-executor-executor-executesequenceddl-function-executesequenceddl-engine-statement-src-minisql-executor-executor-ml-1664189443"></a>
### executeSequenceDdl

```ml
function executeSequenceDdl(engine, statement)
```

Executes sequence DDL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1669)

<a id="function-function-minisql-executor-executor-executeshowindexes-function-executeshowindexes-engine-statement-src-minisql-executor-executor-ml-1639478163"></a>
### executeShowIndexes

```ml
function executeShowIndexes(engine, statement)
```

Executes show indexes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4280)

<a id="function-function-minisql-executor-executor-executeshowprocesslist-function-executeshowprocesslist-engine-src-minisql-executor-executor-ml-706742654"></a>
### executeShowProcesslist

```ml
function executeShowProcesslist(engine)
```

Materializes a lock-safe snapshot of active sessions for administrators.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4229)

<a id="function-function-minisql-executor-executor-executeshowstatus-function-executeshowstatus-engine-src-minisql-executor-executor-ml-1664572118"></a>
### executeShowStatus

```ml
function executeShowStatus(engine)
```

Exposes bounded process-local counters and configured resource ceilings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4218)

<a id="function-function-minisql-executor-executor-executeshowtables-function-executeshowtables-engine-src-minisql-executor-executor-ml-1475044292"></a>
### executeShowTables

```ml
function executeShowTables(engine)
```

Executes show tables using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4209)

<a id="function-function-minisql-executor-executor-executeshutdown-function-executeshutdown-engine-src-minisql-executor-executor-ml-2009892324"></a>
### executeShutdown

```ml
function executeShutdown(engine)
```

Publishes the stop request; the listener sends this response before draining.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4245)

<a id="function-function-minisql-executor-executor-executesql-function-executesql-engine-sqltext-src-minisql-executor-executor-ml-2061122961"></a>
### executeSql

```ml
function executeSql(engine, sqlText)
```

Executes SQL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4684)

<a id="function-function-minisql-executor-executor-executestatement-function-executestatement-engine-statement-src-minisql-executor-executor-ml-1899332699"></a>
### executeStatement

```ml
function executeStatement(engine, statement)
```

Executes one AST with an implicit token for embedded callers. Network sessions start the same token before parsing so parsing, execution, cursor streaming and lock-wait retries share one absolute deadline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4669)

<a id="function-function-minisql-executor-executor-executestatementcontrolled-function-executestatementcontrolled-engine-statement-src-minisql-executor-executor-ml-2028565579"></a>
### executeStatementControlled

```ml
function executeStatementControlled(engine, statement)
```

All callers, including the embedded API, pass through the same physical execution gate. Pure reads share the database; mutations and session-state statements run exclusively. The logical transaction lock manager remains responsible for conflicts that live longer than one statement. Executes one AST under the database's physical readers/writer gate. Prepared statements are classified from their stored AST. A dirty-index marker triggers an atomic read-to-write escalation before repair, with every gate path released before returning the result or a propagated error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4604)

<a id="function-function-minisql-executor-executor-executestatementcore-function-executestatementcore-engine-statement-src-minisql-executor-executor-ml-520162987"></a>
### executeStatementCore

```ml
function executeStatementCore(engine, statement)
```

Authorizes and executes one statement while managing logical transaction locks. Statement read leases end after execution; implicit write leases are released on every outcome. Errors mark explicit transactions failed and are audited.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4536)

<a id="function-function-minisql-executor-executor-executestatementinner-function-executestatementinner-engine-statement-src-minisql-executor-executor-ml-115241195"></a>
### executeStatementInner

```ml
function executeStatementInner(engine, statement)
```

Executes statement inner using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4300)

<a id="function-function-minisql-executor-executor-executetriggerbody-function-executetriggerbody-engine-trigger-sourcetable-oldrow-newrow-pagetransaction-src-minisql-executor-executor-ml-31892013"></a>
### executeTriggerBody

```ml
function executeTriggerBody(engine, trigger, sourceTable, oldRow, newRow, pageTransaction)
```

Executes trigger body using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `trigger` | `dynamic` | — |  |
| `sourceTable` | `dynamic` | — |  |
| `oldRow` | `dynamic` | — |  |
| `newRow` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1564)

<a id="function-function-minisql-executor-executor-executetriggerddl-function-executetriggerddl-engine-statement-src-minisql-executor-executor-ml-1527619189"></a>
### executeTriggerDdl

```ml
function executeTriggerDdl(engine, statement)
```

Executes trigger DDL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1630)

<a id="function-function-minisql-executor-executor-executevacuum-function-executevacuum-engine-statement-src-minisql-executor-executor-ml-2124883343"></a>
### executeVacuum

```ml
function executeVacuum(engine, statement)
```

Executes vacuum using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4118)

<a id="function-function-minisql-executor-executor-executeviewddl-function-executeviewddl-engine-statement-src-minisql-executor-executor-ml-1822873027"></a>
### executeViewDdl

```ml
function executeViewDdl(engine, statement)
```

Executes view DDL using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1281)

<a id="constant-constant-minisql-executor-executor-execution-batch-rows-const-execution-batch-rows-128-src-minisql-executor-executor-ml-2038653322"></a>
### EXECUTION_BATCH_ROWS

```ml
const EXECUTION_BATCH_ROWS = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L62)

<a id="function-function-minisql-executor-executor-explainbound-function-explainbound-bound-src-minisql-executor-executor-ml-2105905164"></a>
### explainBound

```ml
function explainBound(bound)
```

Implements explain bound for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3502)

<a id="function-function-minisql-executor-executor-expressionhaspotentialouterreference-function-expressionhaspotentialouterreference-expression-statement-src-minisql-executor-executor-ml-1441359755"></a>
### expressionHasPotentialOuterReference

```ml
function expressionHasPotentialOuterReference(expression, statement)
```

Detects a qualified column whose source is not declared by its immediate SELECT.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L865)

<a id="function-function-minisql-executor-executor-expressionusesnextval-function-expressionusesnextval-expression-src-minisql-executor-executor-ml-2108459686"></a>
### expressionUsesNextval

```ml
function expressionUsesNextval(expression)
```

Recursively detects NEXTVAL in every expression container, including CASE, window clauses, and subqueries. NEXTVAL mutates sequence/session state and is therefore the key exception to classifying SELECT as a shared read.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4338)

<a id="function-function-minisql-executor-executor-fail-function-fail-code-operation-message-src-minisql-executor-executor-ml-2141121417"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L228)

<a id="function-function-minisql-executor-executor-filtersourcerows-function-filtersourcerows-source-rows-predicate-src-minisql-executor-executor-ml-1972927957"></a>
### filterSourceRows

```ml
function filterSourceRows(source, rows, predicate)
```

Applies a predicate assigned by the optimizer before a source participates in an inner join. Bound column indexes are global, so non-leading sources receive an offset-sized placeholder prefix during evaluation while retaining their compact local row representation for the join operator.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2229)

<a id="function-function-minisql-executor-executor-findcolumnrule-function-findcolumnrule-tableschema-columnname-src-minisql-executor-executor-ml-1670747626"></a>
### findColumnRule

```ml
function findColumnRule(tableSchema, columnName)
```

Finds column rule using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchema` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4164)

<a id="function-function-minisql-executor-executor-findpreparedindex-function-findpreparedindex-engine-name-src-minisql-executor-executor-ml-975534529"></a>
### findPreparedIndex

```ml
function findPreparedIndex(engine, name)
```

Finds prepared index using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L522)

<a id="function-function-minisql-executor-executor-finishquerycontrol-function-finishquerycontrol-engine-src-minisql-executor-executor-ml-2094669646"></a>
### finishQueryControl

```ml
function finishQueryControl(engine)
```

Releases reservations and deactivates a completed token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L365)

<a id="function-function-minisql-executor-executor-firetriggers-function-firetriggers-engine-bound-result-pagetransaction-src-minisql-executor-executor-ml-1766799936"></a>
### fireTriggers

```ml
function fireTriggers(engine, bound, result, pageTransaction)
```

Implements fire triggers for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1583)

<a id="function-function-minisql-executor-executor-hasdatabaseadmin-function-hasdatabaseadmin-engine-src-minisql-executor-executor-ml-1419369890"></a>
### hasDatabaseAdmin

```ml
function hasDatabaseAdmin(engine)
```

Returns whether the supplied value satisfies the database admin condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3648)

<a id="function-function-minisql-executor-executor-informationschemarows-function-informationschemarows-engine-relationkind-src-minisql-executor-executor-ml-1451621596"></a>
### informationSchemaRows

```ml
function informationSchemaRows(engine, relationKind)
```

Materializes a supported INFORMATION_SCHEMA relation from the live catalog snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `relationKind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2125)

<a id="constant-constant-minisql-executor-executor-invalid-argument-const-invalid-argument-9001-src-minisql-executor-executor-ml-350166239"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

SQL execution facade. M16 extends the accepted M15 scan/filter/projection pipeline with joins, grouping, aggregates, set operations and explicit logical and physical plan descriptions. Later milestones add statistics, protocol sessions and savepoints without changing this public execution contract.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L43)

<a id="function-function-minisql-executor-executor-invalidateplanningcontext-function-invalidateplanningcontext-engine-src-minisql-executor-executor-ml-2113816792"></a>
### invalidatePlanningContext

```ml
function invalidatePlanningContext(engine)
```

Invalidates only advisory state. Query correctness never depends on the cache, but local DDL/ANALYZE must expose new access paths and estimates immediately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3419)

<a id="function-function-minisql-executor-executor-isauthorizeddatastatement-function-isauthorizeddatastatement-statement-src-minisql-executor-executor-ml-1730684465"></a>
### isAuthorizedDataStatement

```ml
function isAuthorizedDataStatement(statement)
```

Returns whether a statement changes or truncates table data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | Bound SQL statement to classify. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3834)

<a id="function-function-minisql-executor-executor-isauthorizeddefinitionstatement-function-isauthorizeddefinitionstatement-statement-src-minisql-executor-executor-ml-1467498511"></a>
### isAuthorizedDefinitionStatement

```ml
function isAuthorizedDefinitionStatement(statement)
```

Returns whether a statement changes schema or optimizer metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — | Bound SQL statement to classify. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3885)

<a id="function-function-minisql-executor-executor-isengine-function-isengine-value-src-minisql-executor-executor-ml-57134237"></a>
### isEngine

```ml
function isEngine(value)
```

Returns whether the supplied value satisfies the engine condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L242)

<a id="function-function-minisql-executor-executor-isimplemented-function-isimplemented-src-minisql-executor-executor-ml-2014113356"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4762)

<a id="function-function-minisql-executor-executor-isolationvalue-function-isolationvalue-name-src-minisql-executor-executor-ml-1180263519"></a>
### isolationValue

```ml
function isolationValue(name)
```

Implements isolation value for this module. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1157)

<a id="function-function-minisql-executor-executor-ispreparedstatementstate-function-ispreparedstatementstate-value-src-minisql-executor-executor-ml-1800141301"></a>
### isPreparedStatementState

```ml
function isPreparedStatementState(value)
```

Returns whether the supplied value satisfies the prepared statement state condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L464)

<a id="function-function-minisql-executor-executor-isqueryresult-function-isqueryresult-value-src-minisql-executor-executor-ml-1266785315"></a>
### isQueryResult

```ml
function isQueryResult(value)
```

Returns whether the supplied value satisfies the query result condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L235)

<a id="function-function-minisql-executor-executor-issequencesessionvalue-function-issequencesessionvalue-value-src-minisql-executor-executor-ml-1440773105"></a>
### isSequenceSessionValue

```ml
function isSequenceSessionValue(value)
```

Returns whether the supplied value satisfies the sequence session value condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L471)

<a id="function-function-minisql-executor-executor-itemindex-function-itemindex-bound-expression-src-minisql-executor-executor-ml-444739136"></a>
### itemIndex

```ml
function itemIndex(bound, expression)
```

Implements item index for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2776)

<a id="function-function-minisql-executor-executor-joinedsource-function-joinedsource-engine-bound-pagetransaction-sourceoffset-sourcelimit-requiredcolumns-executable-src-minisql-executor-executor-ml-476399185"></a>
### joinedSource

```ml
function joinedSource(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns, executable)
```

Implements joined source for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `sourceLimit` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |
| `executable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2694)

<a id="function-function-minisql-executor-executor-joinedsourcereordered-function-joinedsourcereordered-engine-bound-pagetransaction-sourceoffset-sourcelimit-requiredcolumns-executable-src-minisql-executor-executor-ml-1305843441"></a>
### joinedSourceReordered

```ml
function joinedSourceReordered(engine, bound, pageTransaction, sourceOffset, sourceLimit, requiredColumns, executable)
```

Executes the optimizer's canonicalized order for a pure INNER equijoin graph.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `sourceLimit` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |
| `executable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2581)

<a id="function-function-minisql-executor-executor-joinedsourcereorderedcount-function-joinedsourcereorderedcount-engine-bound-pagetransaction-requiredcolumns-executable-src-minisql-executor-executor-ml-766675193"></a>
### joinedSourceReorderedCount

```ml
function joinedSourceReorderedCount(engine, bound, pageTransaction, requiredColumns, executable)
```

Executes all reordered joins except the final edge normally, then turns that edge directly into a cardinality. This bounds retained memory by the largest intermediate before the final fan-out rather than the final result size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |
| `executable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2543)

<a id="function-function-minisql-executor-executor-joinindexkeys-function-joinindexkeys-keys-src-minisql-executor-executor-ml-1423789080"></a>
### joinIndexKeys

```ml
function joinIndexKeys(keys)
```

Renders expression-index keys without their internal compatibility marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4197)

<a id="function-function-minisql-executor-executor-joinnames-function-joinnames-names-src-minisql-executor-executor-ml-2005156840"></a>
### joinNames

```ml
function joinNames(names)
```

Implements join names for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4187)

<a id="function-function-minisql-executor-executor-joinprobeguaranteespredicate-function-joinprobeguaranteespredicate-boundjoin-leftrow-predicate-src-minisql-executor-executor-ml-1750283024"></a>
### joinProbeGuaranteesPredicate

```ml
function joinProbeGuaranteesPredicate(boundJoin, leftRow, predicate)
```

Proves that one parameterized equality-index probe already guarantees a pushed right-source predicate for the current left row. This removes only simple typed column=literal predicates (and AND trees composed of them); every other source filter retains ordinary evaluation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundJoin` | `dynamic` | — |  |
| `leftRow` | `dynamic` | — |  |
| `predicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2614)

<a id="function-function-minisql-executor-executor-loadplanningcontext-function-loadplanningcontext-engine-src-minisql-executor-executor-ml-71253414"></a>
### loadPlanningContext

```ml
function loadPlanningContext(engine)
```

Builds the optimizer's catalog snapshot without giving planner modules direct access to files or mutable database handles. The snapshot is advisory; an index disappearing between planning and execution causes a semantic fallback rather than a failed or incorrect query.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3335)

<a id="function-function-minisql-executor-executor-loadstatistics-function-loadstatistics-engine-src-minisql-executor-executor-ml-641776954"></a>
### loadStatistics

```ml
function loadStatistics(engine)
```

Loads statistics using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3326)

<a id="function-function-minisql-executor-executor-markexplicitfailure-function-markexplicitfailure-engine-src-minisql-executor-executor-ml-1490166796"></a>
### markExplicitFailure

```ml
function markExplicitFailure(engine)
```

Implements mark explicit failure for this module. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4441)

<a id="function-function-minisql-executor-executor-materializeboundexpression-function-materializeboundexpression-engine-expression-bound-row-pagetransaction-src-minisql-executor-executor-ml-347857181"></a>
### materializeBoundExpression

```ml
function materializeBoundExpression(engine, expression, bound, row, pageTransaction)
```

Rebuilds a bound expression with every deferred subquery replaced by a literal. Reusing the ordinary expression evaluator keeps SQL NULL and boolean semantics centralized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2827)

<a id="function-function-minisql-executor-executor-materializeboundsubquery-function-materializeboundsubquery-engine-expression-bound-row-pagetransaction-src-minisql-executor-executor-ml-104763257"></a>
### materializeBoundSubquery

```ml
function materializeBoundSubquery(engine, expression, bound, row, pageTransaction)
```

Executes a validated scalar, EXISTS, or IN subquery for one outer source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2803)

<a id="function-function-minisql-executor-executor-materializedmlstatement-function-materializedmlstatement-engine-statement-pagetransaction-src-minisql-executor-executor-ml-183510046"></a>
### materializeDmlStatement

```ml
function materializeDmlStatement(engine, statement, pageTransaction)
```

Implements materialize DML statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1046)

<a id="function-function-minisql-executor-executor-materializeexpression-function-materializeexpression-engine-expression-pagetransaction-defersubqueries-src-minisql-executor-executor-ml-1968497743"></a>
### materializeExpression

```ml
function materializeExpression(engine, expression, pageTransaction, deferSubqueries)
```

Implements materialize expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `deferSubqueries` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L721)

<a id="function-function-minisql-executor-executor-materializeinsertselect-function-materializeinsertselect-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1231635255"></a>
### materializeInsertSelect

```ml
function materializeInsertSelect(engine, bound, pageTransaction)
```

Implements materialize insert select for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1897)

<a id="function-function-minisql-executor-executor-materializeselectstatement-function-materializeselectstatement-engine-statement-pagetransaction-src-minisql-executor-executor-ml-1930561052"></a>
### materializeSelectStatement

```ml
function materializeSelectStatement(engine, statement, pageTransaction)
```

Implements materialize select statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L814)

<a id="constant-constant-minisql-executor-executor-mode-ddl-const-mode-ddl-2-src-minisql-executor-executor-ml-1799859077"></a>
### MODE_DDL

```ml
const MODE_DDL = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L57)

<a id="constant-constant-minisql-executor-executor-mode-dml-const-mode-dml-1-src-minisql-executor-executor-ml-935666256"></a>
### MODE_DML

```ml
const MODE_DML = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L56)

<a id="constant-constant-minisql-executor-executor-mode-none-const-mode-none-0-src-minisql-executor-executor-ml-775891745"></a>
### MODE_NONE

```ml
const MODE_NONE = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L55)

<a id="function-function-minisql-executor-executor-nameinlist-function-nameinlist-names-name-src-minisql-executor-executor-ml-1485526323"></a>
### nameInList

```ml
function nameInList(names, name)
```

Implements name in list for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3684)

<a id="function-function-minisql-executor-executor-nestedselectdeclaresqualifier-function-nestedselectdeclaresqualifier-statement-qualifier-src-minisql-executor-executor-ml-161014187"></a>
### nestedSelectDeclaresQualifier

```ml
function nestedSelectDeclaresQualifier(statement, qualifier)
```

Returns true when a nested SELECT declares a qualifier that shadows an outer source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `qualifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L849)

<a id="function-function-minisql-executor-executor-nextselectbatch-function-nextselectbatch-cursor-maximumrows-src-minisql-executor-executor-ml-1002043475"></a>
### nextSelectBatch

```ml
function nextSelectBatch(cursor, maximumRows)
```

Produces at most maximumRows projected rows while retaining no earlier batch. Void denotes end-of-stream and guarantees that the read lease is released.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — |  |
| `maximumRows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3119)

<a id="function-function-minisql-executor-executor-normalizecompoundorder-function-normalizecompoundorder-rows-bound-src-minisql-executor-executor-ml-142974099"></a>
### normalizeCompoundOrder

```ml
function normalizeCompoundOrder(rows, bound)
```

Normalizes compound order using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2787)

<a id="function-function-minisql-executor-executor-notequeryspill-function-notequeryspill-engine-rows-src-minisql-executor-executor-ml-621388527"></a>
### noteQuerySpill

```ml
function noteQuerySpill(engine, rows)
```

Records a spill decision using the measured input representation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L341)

<a id="function-function-minisql-executor-executor-open-function-open-databasepath-src-minisql-executor-executor-ml-1288864166"></a>
### open

```ml
function open(databasePath)
```

Opens open using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L424)

<a id="function-function-minisql-executor-executor-openselectcursor-function-openselectcursor-engine-statement-src-minisql-executor-executor-ml-1915313715"></a>
### openSelectCursor

```ml
function openSelectCursor(engine, statement)
```

Opens the non-blocking single-table physical pipeline as a forward-only result cursor. Unsupported/blocking shapes return void so callers can use the ordinary executor without changing SQL semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3075)

<a id="function-function-minisql-executor-executor-optimizedplanfor-function-optimizedplanfor-engine-bound-src-minisql-executor-executor-ml-1694886294"></a>
### optimizedPlanFor

```ml
function optimizedPlanFor(engine, bound)
```

Returns a generation-safe cached physical plan or optimizes and records a new one. Executor-created typed literals format opaquely, so correlated and parameter-materialized SELECTs bypass caching rather than reusing a plan that embeds another invocation's literal value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3383)

<a id="constant-constant-minisql-executor-executor-permission-denied-const-permission-denied-9029-src-minisql-executor-executor-ml-1290569077"></a>
### PERMISSION_DENIED

```ml
const PERMISSION_DENIED = 9029
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L53)

<a id="function-function-minisql-executor-executor-permissionfailure-function-permissionfailure-operation-detail-src-minisql-executor-executor-ml-2072982062"></a>
### permissionFailure

```ml
function permissionFailure(operation, detail)
```

Implements permission failure for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `detail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3634)

<a id="function-function-minisql-executor-executor-persistedprogrambodysupported-function-persistedprogrambodysupported-statement-src-minisql-executor-executor-ml-1886903471"></a>
### persistedProgramBodySupported

```ml
function persistedProgramBodySupported(statement)
```

Returns whether the persisted statement formatter preserves the entire DML body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1619)

<a id="constant-constant-minisql-executor-executor-plan-cache-capacity-const-plan-cache-capacity-64-src-minisql-executor-executor-ml-1481549155"></a>
### PLAN_CACHE_CAPACITY

```ml
const PLAN_CACHE_CAPACITY = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L61)

<a id="function-function-minisql-executor-executor-plancacheentrycount-function-plancacheentrycount-engine-src-minisql-executor-executor-ml-1611185358"></a>
### planCacheEntryCount

```ml
function planCacheEntryCount(engine)
```

Exposes non-sensitive optimizer cache counters for diagnostics and tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L247)

<a id="function-function-minisql-executor-executor-plancachehitcount-function-plancachehitcount-engine-src-minisql-executor-executor-ml-670064736"></a>
### planCacheHitCount

```ml
function planCacheHitCount(engine)
```

Returns cumulative hits of entries still resident in the session cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L253)

<a id="function-function-minisql-executor-executor-pollquerycontrol-function-pollquerycontrol-engine-operation-src-minisql-executor-executor-ml-257719047"></a>
### pollQueryControl

```ml
function pollQueryControl(engine, operation)
```

Polls administrator cancellation and the monotonic execution deadline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L375)

<a id="function-function-minisql-executor-executor-preparedatabase-function-preparedatabase-database-src-minisql-executor-executor-ml-262138321"></a>
### prepareDatabase

```ml
function prepareDatabase(database)
```

Performs the index readiness pass once for an opened database. Clean marker state needs only derived-file existence checks; a dirty marker or missing file performs the expensive rebuild/verification path. A double check inside the exclusive gate lets concurrent connection accepts share either result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L395)

- [minisql.executor.executor.PreparedStatementState](Type-minisql-executor-executor-preparedstatementstate-1869459177.md) — struct
<a id="function-function-minisql-executor-executor-principal-function-principal-engine-src-minisql-executor-executor-ml-1645409502"></a>
### principal

```ml
function principal(engine)
```

Implements principal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L446)

<a id="function-function-minisql-executor-executor-privilegecode-function-privilegecode-name-objecttype-src-minisql-executor-executor-ml-227622704"></a>
### privilegeCode

```ml
function privilegeCode(name, objectType)
```

Implements privilege code for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3944)

<a id="function-function-minisql-executor-executor-privilegecodes-function-privilegecodes-names-objecttype-src-minisql-executor-executor-ml-1500901271"></a>
### privilegeCodes

```ml
function privilegeCodes(names, objectType)
```

Implements privilege codes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `names` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3975)

<a id="constant-constant-minisql-executor-executor-procedure-parameter-metadata-v1-const-procedure-parameter-metadata-v1-minisql-parameter-metadata-v1-src-minisql-executor-executor-ml-2080838468"></a>
### PROCEDURE_PARAMETER_METADATA_V1

```ml
const PROCEDURE_PARAMETER_METADATA_V1 = "__minisql_parameter_metadata_v1__"
```

Identifies the flattened, versioned parameter metadata stored with procedures.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L72)

<a id="function-function-minisql-executor-executor-projectsubqueryrows-function-projectsubqueryrows-engine-bound-source-pagetransaction-src-minisql-executor-executor-ml-373874092"></a>
### projectSubqueryRows

```ml
function projectSubqueryRows(engine, bound, source, pageTransaction)
```

Filters and projects a non-grouped row set whose expressions contain subqueries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2865)

<a id="constant-constant-minisql-executor-executor-query-cancelled-const-query-cancelled-9035-src-minisql-executor-executor-ml-1111187330"></a>
### QUERY_CANCELLED

```ml
const QUERY_CANCELLED = 9035
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L68)

<a id="constant-constant-minisql-executor-executor-query-timeout-const-query-timeout-9036-src-minisql-executor-executor-ml-974921613"></a>
### QUERY_TIMEOUT

```ml
const QUERY_TIMEOUT = 9036
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L69)

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
| `engine` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L322)

<a id="function-function-minisql-executor-executor-rebuildindexesforddl-function-rebuildindexesforddl-engine-bound-statement-src-minisql-executor-executor-ml-1225417799"></a>
### rebuildIndexesForDdl

```ml
function rebuildIndexesForDdl(engine, bound, statement)
```

Rebuilds only indexes whose table schema changed in one autocommit DDL. Unrelated tables remain byte-for-byte untouched; the durable dirty marker still triggers the conservative all-index repair after a rebuild failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1779)

- [minisql.executor.executor.RecursiveCteFrame](Type-minisql-executor-executor-recursivecteframe-1748414545.md) — struct
<a id="function-function-minisql-executor-executor-recursiverowscontain-function-recursiverowscontain-rows-candidate-src-minisql-executor-executor-ml-685192766"></a>
### recursiveRowsContain

```ml
function recursiveRowsContain(rows, candidate)
```

Returns true when a recursive result row is already present by SQL value equality.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `candidate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2058)

<a id="function-function-minisql-executor-executor-recursiveworkingrows-function-recursiveworkingrows-engine-name-src-minisql-executor-executor-ml-2002064025"></a>
### recursiveWorkingRows

```ml
function recursiveWorkingRows(engine, name)
```

Returns the innermost active delta for a recursive self-reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2066)

<a id="function-function-minisql-executor-executor-remembersequencevalue-function-remembersequencevalue-engine-name-value-src-minisql-executor-executor-ml-941748772"></a>
### rememberSequenceValue

```ml
function rememberSequenceValue(engine, name, value)
```

Implements remember sequence value for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L488)

<a id="function-function-minisql-executor-executor-replacemergecolumn-function-replacemergecolumn-expression-statement-sourcetable-sourcerow-src-minisql-executor-executor-ml-2090429325"></a>
### replaceMergeColumn

```ml
function replaceMergeColumn(expression, statement, sourceTable, sourceRow)
```

Resolves one qualified MERGE source/target column for a concrete source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `sourceTable` | `dynamic` | — |  |
| `sourceRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1419)

<a id="function-function-minisql-executor-executor-replacemergeexpression-function-replacemergeexpression-expression-statement-sourcetable-sourcerow-src-minisql-executor-executor-ml-1329509965"></a>
### replaceMergeExpression

```ml
function replaceMergeExpression(expression, statement, sourceTable, sourceRow)
```

Rewrites a MERGE expression for one source row while leaving target columns bindable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `sourceTable` | `dynamic` | — |  |
| `sourceRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1435)

<a id="function-function-minisql-executor-executor-replaceprocedureexpression-function-replaceprocedureexpression-expression-parameternames-parametervalues-src-minisql-executor-executor-ml-2146441588"></a>
### replaceProcedureExpression

```ml
function replaceProcedureExpression(expression, parameterNames, parameterValues)
```

Substitutes named procedure inputs throughout a supported DML expression.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `parameterNames` | `dynamic` | — |  |
| `parameterValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1482)

<a id="function-function-minisql-executor-executor-replaceprocedureparameter-function-replaceprocedureparameter-expression-parameternames-parametervalues-src-minisql-executor-executor-ml-1207754032"></a>
### replaceProcedureParameter

```ml
function replaceProcedureParameter(expression, parameterNames, parameterValues)
```

Replaces an unqualified procedure parameter reference with its invocation value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `parameterNames` | `dynamic` | — |  |
| `parameterValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1471)

<a id="function-function-minisql-executor-executor-replaceprocedurestatement-function-replaceprocedurestatement-statement-parameternames-parametervalues-src-minisql-executor-executor-ml-1689497001"></a>
### replaceProcedureStatement

```ml
function replaceProcedureStatement(statement, parameterNames, parameterValues)
```

Substitutes procedure parameters in one persisted INSERT, UPDATE, or DELETE body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `parameterNames` | `dynamic` | — |  |
| `parameterValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1518)

<a id="function-function-minisql-executor-executor-replacetriggerexpression-function-replacetriggerexpression-expression-table-oldrow-newrow-src-minisql-executor-executor-ml-1569511131"></a>
### replaceTriggerExpression

```ml
function replaceTriggerExpression(expression, table, oldRow, newRow)
```

Implements replace trigger expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `oldRow` | `dynamic` | — |  |
| `newRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1327)

<a id="function-function-minisql-executor-executor-replacetriggerreturning-function-replacetriggerreturning-items-table-oldrow-newrow-src-minisql-executor-executor-ml-2125935561"></a>
### replaceTriggerReturning

```ml
function replaceTriggerReturning(items, table, oldRow, newRow)
```

Implements replace trigger returning for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `oldRow` | `dynamic` | — |  |
| `newRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1370)

<a id="function-function-minisql-executor-executor-replacetriggerstatement-function-replacetriggerstatement-statement-table-oldrow-newrow-src-minisql-executor-executor-ml-146068100"></a>
### replaceTriggerStatement

```ml
function replaceTriggerStatement(statement, table, oldRow, newRow)
```

Implements replace trigger statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `oldRow` | `dynamic` | — |  |
| `newRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1382)

<a id="function-function-minisql-executor-executor-requiregrantoption-function-requiregrantoption-engine-objecttype-objectid-privilege-operation-src-minisql-executor-executor-ml-1575741859"></a>
### requireGrantOption

```ml
function requireGrantOption(engine, objectType, objectId, privilege, operation)
```

Implements require grant option for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3665)

<a id="function-function-minisql-executor-executor-requireobjectschema-function-requireobjectschema-engine-objectname-operation-src-minisql-executor-executor-ml-1537236189"></a>
### requireObjectSchema

```ml
function requireObjectSchema(engine, objectName, operation)
```

Verifies that the namespace of a qualified object exists before object DDL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `objectName` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1248)

<a id="function-function-minisql-executor-executor-requireprivilege-function-requireprivilege-engine-objecttype-objectid-privilege-operation-src-minisql-executor-executor-ml-1806371971"></a>
### requirePrivilege

```ml
function requirePrivilege(engine, objectType, objectId, privilege, operation)
```

Implements require privilege for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `objectType` | `dynamic` | — |  |
| `objectId` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3656)

<a id="function-function-minisql-executor-executor-requiresecurityadmin-function-requiresecurityadmin-engine-operation-src-minisql-executor-executor-ml-861651211"></a>
### requireSecurityAdmin

```ml
function requireSecurityAdmin(engine, operation)
```

Implements require security admin for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4003)

<a id="function-function-minisql-executor-executor-requiretableprivilegebyname-function-requiretableprivilegebyname-engine-tablename-privilege-operation-src-minisql-executor-executor-ml-1866733741"></a>
### requireTablePrivilegeByName

```ml
function requireTablePrivilegeByName(engine, tableName, privilege, operation)
```

Implements require table privilege by name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |
| `privilege` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3674)

<a id="function-function-minisql-executor-executor-resetquerymemory-function-resetquerymemory-engine-src-minisql-executor-executor-ml-1057622286"></a>
### resetQueryMemory

```ml
function resetQueryMemory(engine)
```

Clears last-statement accounting without changing the configured policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L285)

<a id="function-function-minisql-executor-executor-resettransaction-function-resettransaction-engine-src-minisql-executor-executor-ml-956724486"></a>
### resetTransaction

```ml
function resetTransaction(engine)
```

Resets transaction using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1145)

<a id="constant-constant-minisql-executor-executor-result-command-const-result-command-1-src-minisql-executor-executor-ml-1919843868"></a>
### RESULT_COMMAND

```ml
const RESULT_COMMAND = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L59)

<a id="constant-constant-minisql-executor-executor-result-rows-const-result-rows-2-src-minisql-executor-executor-ml-1453942231"></a>
### RESULT_ROWS

```ml
const RESULT_ROWS = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L60)

<a id="function-function-minisql-executor-executor-returningresult-function-returningresult-bound-result-src-minisql-executor-executor-ml-1838229607"></a>
### returningResult

```ml
function returningResult(bound, result)
```

Implements returning result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1924)

<a id="function-function-minisql-executor-executor-rollbackexplicit-function-rollbackexplicit-engine-src-minisql-executor-executor-ml-1519451594"></a>
### rollbackExplicit

```ml
function rollbackExplicit(engine)
```

Implements rollback explicit for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3588)

<a id="function-function-minisql-executor-executor-rowresult-function-rowresult-columns-rows-src-minisql-executor-executor-ml-2002219676"></a>
### rowResult

```ml
function rowResult(columns, rows)
```

Implements row result for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columns` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L272)

<a id="function-function-minisql-executor-executor-runbounddml-function-runbounddml-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1756577415"></a>
### runBoundDml

```ml
function runBoundDml(engine, bound, pageTransaction)
```

Runs bound DML using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1837)

<a id="function-function-minisql-executor-executor-runmerge-function-runmerge-engine-statement-pagetransaction-src-minisql-executor-executor-ml-1875761044"></a>
### runMerge

```ml
function runMerge(engine, statement, pageTransaction)
```

Executes every MERGE source row against the same transactional target snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1969)

<a id="function-function-minisql-executor-executor-scanboundsource-function-scanboundsource-engine-source-pagetransaction-offset-limit-requiredcolumns-src-minisql-executor-executor-ml-77683190"></a>
### scanBoundSource

```ml
function scanBoundSource(engine, source, pageTransaction, offset, limit, requiredColumns)
```

Scans a catalog table, named query, recursive fixpoint, or recursive delta source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `limit` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2189)

- [minisql.executor.executor.SelectCursor](Type-minisql-executor-executor-selectcursor-2125118112.md) — struct
<a id="function-function-minisql-executor-executor-selecthaspotentialouterreferences-function-selecthaspotentialouterreferences-statement-src-minisql-executor-executor-ml-548647991"></a>
### selectHasPotentialOuterReferences

```ml
function selectHasPotentialOuterReferences(statement)
```

Returns whether any expression in a SELECT may need a concrete outer row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L908)

<a id="function-function-minisql-executor-executor-selectprojected-function-selectprojected-engine-bound-pagetransaction-src-minisql-executor-executor-ml-488636331"></a>
### selectProjected

```ml
function selectProjected(engine, bound, pageTransaction)
```

Implements select projected for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3218)

<a id="function-function-minisql-executor-executor-selectrequiredcolumns-function-selectrequiredcolumns-bound-src-minisql-executor-executor-ml-259646204"></a>
### selectRequiredColumns

```ml
function selectRequiredColumns(bound)
```

Computes one stable local column mask per source. Global bound indexes are collected before slicing at source offsets, allowing joins to avoid fetching unrelated external values while retaining canonical flattened row positions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2951)

<a id="function-function-minisql-executor-executor-selectrows-function-selectrows-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1089900231"></a>
### selectRows

```ml
function selectRows(engine, bound, pageTransaction)
```

Implements select rows for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3311)

<a id="function-function-minisql-executor-executor-selectusesnextval-function-selectusesnextval-statement-src-minisql-executor-executor-ml-1850477497"></a>
### selectUsesNextval

```ml
function selectUsesNextval(statement)
```

Walks all SELECT clauses, CTEs, joins, and set-operation branches for NEXTVAL. Returns true as soon as any nested expression advances a sequence.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4382)

<a id="function-function-minisql-executor-executor-sequenceargumentname-function-sequenceargumentname-expression-operation-src-minisql-executor-executor-ml-1314049115"></a>
### sequenceArgumentName

```ml
function sequenceArgumentName(expression, operation)
```

Implements sequence argument name for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L479)

- [minisql.executor.executor.SequenceSessionValue](Type-minisql-executor-executor-sequencesessionvalue-1742946274.md) — struct
<a id="function-function-minisql-executor-executor-sessionidentifier-function-sessionidentifier-engine-src-minisql-executor-executor-ml-473604768"></a>
### sessionIdentifier

```ml
function sessionIdentifier(engine)
```

Implements session identifier for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4723)

<a id="function-function-minisql-executor-executor-setprincipal-function-setprincipal-engine-principalid-src-minisql-executor-executor-ml-1434755529"></a>
### setPrincipal

```ml
function setPrincipal(engine, principalId)
```

Implements set principal for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `principalId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L434)

<a id="function-function-minisql-executor-executor-setquerymemorylimit-function-setquerymemorylimit-engine-limitbytes-src-minisql-executor-executor-ml-2012910312"></a>
### setQueryMemoryLimit

```ml
function setQueryMemoryLimit(engine, limitBytes)
```

Configures the soft per-query memory budget used by blocking operators.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `limitBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L277)

<a id="function-function-minisql-executor-executor-simplebatcheligible-function-simplebatcheligible-bound-executable-src-minisql-executor-executor-ml-847775378"></a>
### simpleBatchEligible

```ml
function simpleBatchEligible(bound, executable)
```

Identifies a pipeline that can filter, project and apply LIMIT directly over bounded scan batches. Blocking relational operators retain their specialized materializing paths.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `executable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3009)

<a id="function-function-minisql-executor-executor-simplebatchprojected-function-simplebatchprojected-engine-bound-pagetransaction-requiredcolumns-wherepredicate-src-minisql-executor-executor-ml-1985148857"></a>
### simpleBatchProjected

```ml
function simpleBatchProjected(engine, bound, pageTransaction, requiredColumns, wherePredicate)
```

Executes a non-blocking single-table query with at most one source batch and the final result resident at once. This removes the former full scanned-row materialization while preserving the QueryResult API required by protocol v1.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |
| `wherePredicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3019)

<a id="function-function-minisql-executor-executor-simplecountstareligible-function-simplecountstareligible-bound-src-minisql-executor-executor-ml-1341036652"></a>
### simpleCountStarEligible

```ml
function simpleCountStarEligible(bound)
```

Recognizes the exact aggregate shape whose result depends only on live-slot visibility. More complex COUNT variants retain the general relational path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2988)

<a id="function-function-minisql-executor-executor-simplecountstarprojected-function-simplecountstarprojected-engine-bound-pagetransaction-src-minisql-executor-executor-ml-1234174103"></a>
### simpleCountStarProjected

```ml
function simpleCountStarProjected(engine, bound, pageTransaction)
```

Projects a scalar COUNT(*) directly from checksum-verified heap slot headers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3000)

<a id="function-function-minisql-executor-executor-simpletopneligible-function-simpletopneligible-bound-executable-src-minisql-executor-executor-ml-1312478808"></a>
### simpleTopNEligible

```ml
function simpleTopNEligible(bound, executable)
```

Recognizes an ordered single-table LIMIT that can maintain only the current best window while scanning. Projection and ORDER BY expressions must be row-local because subqueries require the general materializing pipeline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `executable` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3170)

<a id="function-function-minisql-executor-executor-simpletopnprojected-function-simpletopnprojected-engine-bound-pagetransaction-requiredcolumns-wherepredicate-src-minisql-executor-executor-ml-720681283"></a>
### simpleTopNProjected

```ml
function simpleTopNProjected(engine, bound, pageTransaction, requiredColumns, wherePredicate)
```

Fuses scan, filter, projection, and bounded Top-N retention. At most one scan batch plus LIMIT+OFFSET projected rows are resident, so large source tables no longer dominate memory for small ordered result windows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |
| `wherePredicate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L3181)

<a id="function-function-minisql-executor-executor-splitobjectname-function-splitobjectname-name-src-minisql-executor-executor-ml-822390495"></a>
### splitObjectName

```ml
function splitObjectName(name)
```

Splits a canonical object name into schema and local name, defaulting to public.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L2112)

<a id="function-function-minisql-executor-executor-stageddl-function-stageddl-ddltransaction-bound-src-minisql-executor-executor-ml-1110310964"></a>
### stageDdl

```ml
function stageDdl(ddlTransaction, bound)
```

Implements stage DDL for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ddlTransaction` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1220)

<a id="function-function-minisql-executor-executor-statementisolation-function-statementisolation-engine-src-minisql-executor-executor-ml-1687141350"></a>
### statementIsolation

```ml
function statementIsolation(engine)
```

Implements statement isolation for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4431)

<a id="function-function-minisql-executor-executor-statementusesreadlock-function-statementusesreadlock-statement-src-minisql-executor-executor-ml-927737241"></a>
### statementUsesReadLock

```ml
function statementUsesReadLock(statement)
```

Classifies statements that may share physical database execution. Pure SELECT, pure EXPLAIN, and metadata inspection are reads; a SELECT tree containing NEXTVAL is deliberately excluded because it changes sequence state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4408)

<a id="function-function-minisql-executor-executor-statementuseswritelock-function-statementuseswritelock-statement-src-minisql-executor-executor-ml-1933721929"></a>
### statementUsesWriteLock

```ml
function statementUsesWriteLock(statement)
```

Classifies statements that require exclusive physical database execution. This includes DML, DDL, DCL, maintenance, and SELECT statements containing NEXTVAL. Transaction-control/session-only statements are handled separately.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4418)

<a id="function-function-minisql-executor-executor-substituteexpression-function-substituteexpression-expression-parameters-src-minisql-executor-executor-ml-1566317082"></a>
### substituteExpression

```ml
function substituteExpression(expression, parameters)
```

Implements substitute expression for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `parameters` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L570)

<a id="function-function-minisql-executor-executor-substituteoutercolumn-function-substituteoutercolumn-expression-sources-rowvalues-statement-src-minisql-executor-executor-ml-2079039637"></a>
### substituteOuterColumn

```ml
function substituteOuterColumn(expression, sources, rowValues, statement)
```

Resolves a qualified outer reference against the current joined source row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `rowValues` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L933)

<a id="function-function-minisql-executor-executor-substituteouterexpression-function-substituteouterexpression-expression-sources-rowvalues-statement-src-minisql-executor-executor-ml-544362361"></a>
### substituteOuterExpression

```ml
function substituteOuterExpression(expression, sources, rowValues, statement)
```

Substitutes outer-row values throughout an expression while preserving inner shadowing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `rowValues` | `dynamic` | — |  |
| `statement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L954)

<a id="function-function-minisql-executor-executor-substituteouterselect-function-substituteouterselect-statement-sources-rowvalues-src-minisql-executor-executor-ml-1721802975"></a>
### substituteOuterSelect

```ml
function substituteOuterSelect(statement, sources, rowValues)
```

Copies a nested SELECT with every non-shadowed outer reference replaced by a row literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `sources` | `dynamic` | — |  |
| `rowValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1008)

<a id="function-function-minisql-executor-executor-substitutereturning-function-substitutereturning-items-parameters-src-minisql-executor-executor-ml-454875552"></a>
### substituteReturning

```ml
function substituteReturning(items, parameters)
```

Implements substitute returning for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `parameters` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L667)

<a id="function-function-minisql-executor-executor-substituteselect-function-substituteselect-statement-parameters-src-minisql-executor-executor-ml-959972121"></a>
### substituteSelect

```ml
function substituteSelect(statement, parameters)
```

Implements substitute select for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `parameters` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L630)

<a id="function-function-minisql-executor-executor-substitutestatement-function-substitutestatement-statement-parameters-src-minisql-executor-executor-ml-152799815"></a>
### substituteStatement

```ml
function substituteStatement(statement, parameters)
```

Implements substitute statement for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statement` | `dynamic` | — |  |
| `parameters` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L679)

<a id="function-function-minisql-executor-executor-targetmilestone-function-targetmilestone-src-minisql-executor-executor-ml-268555050"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4755)

<a id="constant-constant-minisql-executor-executor-transaction-state-const-transaction-state-9011-src-minisql-executor-executor-ml-342426264"></a>
### TRANSACTION_STATE

```ml
const TRANSACTION_STATE = 9011
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L46)

<a id="function-function-minisql-executor-executor-triggercolumnvalue-function-triggercolumnvalue-table-row-qualifier-columnname-src-minisql-executor-executor-ml-1984102729"></a>
### triggerColumnValue

```ml
function triggerColumnValue(table, row, qualifier, columnName)
```

Implements trigger column value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `qualifier` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1316)

<a id="function-function-minisql-executor-executor-triggereventcode-function-triggereventcode-bound-src-minisql-executor-executor-ml-1747003116"></a>
### triggerEventCode

```ml
function triggerEventCode(bound)
```

Implements trigger event code for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1305)

<a id="function-function-minisql-executor-executor-typedescription-function-typedescription-column-src-minisql-executor-executor-ml-348776582"></a>
### typeDescription

```ml
function typeDescription(column)
```

Implements type description for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `column` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L4153)

<a id="constant-constant-minisql-executor-executor-unsupported-sql-const-unsupported-sql-9025-src-minisql-executor-executor-ml-512500125"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L51)

<a id="function-function-minisql-executor-executor-updatetouchestriggercolumn-function-updatetouchestriggercolumn-bound-trigger-src-minisql-executor-executor-ml-225563956"></a>
### updateTouchesTriggerColumn

```ml
function updateTouchesTriggerColumn(bound, trigger)
```

Implements update touches trigger column for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bound` | `dynamic` | — |  |
| `trigger` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1550)

<a id="function-function-minisql-executor-executor-validatealtertablerows-function-validatealtertablerows-engine-bound-src-minisql-executor-executor-ml-1988709686"></a>
### validateAlterTableRows

```ml
function validateAlterTableRows(engine, bound)
```

Validates ALTER TABLE operations whose safety depends on currently stored rows. DROP COLUMN deliberately starts with empty tables so the versioned row codec never has to reinterpret a wider historical row as a shorter layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L1231)

<a id="function-function-minisql-executor-executor-validateopen-function-validateopen-engine-operation-src-minisql-executor-executor-ml-799733671"></a>
### validateOpen

```ml
function validateOpen(engine, operation)
```

Validates open using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L455)
