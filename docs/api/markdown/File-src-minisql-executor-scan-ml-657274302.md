# `src/minisql/executor/scan.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql executor scan facilities for this project.

Package: [`minisql.executor.scan`](Package-minisql-executor-scan-576209884.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `minisql/storage/buffer_pool.ml` as `buffer_pool` → [src/minisql/storage/buffer_pool.ml](File-src-minisql-storage-buffer-pool-ml-1867626530.md)
- `minisql/storage/heap_file.ml` as `heap_file` → [src/minisql/storage/heap_file.ml](File-src-minisql-storage-heap-file-ml-1771906446.md)
- `minisql/storage/overflow.ml` as `overflow` → [src/minisql/storage/overflow.ml](File-src-minisql-storage-overflow-ml-2096314611.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/row_codec.ml` as `row_codec` → [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)
- `minisql/storage/slotted_page.ml` as `slotted_page` → [src/minisql/storage/slotted_page.ml](File-src-minisql-storage-slotted-page-ml-1299577846.md)
- `minisql/transaction/transaction.ml` as `transaction` → [src/minisql/transaction/transaction.ml](File-src-minisql-transaction-transaction-ml-1157597470.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-scan-all-function-all-reader-src-minisql-executor-scan-ml-255471273"></a>
### all

```ml
function all(reader)
```

Materializes every live row. The range implementation is shared with LIMIT/OFFSET scans so checksum verification and transaction visibility have one implementation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L733)

<a id="function-function-minisql-executor-scan-allrange-function-allrange-reader-offset-limit-src-minisql-executor-scan-ml-1030094279"></a>
### allRange

```ml
function allRange(reader, offset, limit)
```

Scans a physical live-row range and materializes all columns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L725)

<a id="function-function-minisql-executor-scan-allrangecolumns-function-allrangecolumns-reader-offset-limit-requiredcolumns-src-minisql-executor-scan-ml-22107379"></a>
### allRangeColumns

```ml
function allRangeColumns(reader, offset, limit, requiredColumns)
```

Implements all for this module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L682)

<a id="function-function-minisql-executor-scan-appendarrayvalue-function-appendarrayvalue-source-item-operation-src-minisql-executor-scan-ml-1359553943"></a>
### appendArrayValue

```ml
function appendArrayValue(source, item, operation)
```

Appends array value using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `item` | `dynamic` | — | item value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L181)

<a id="function-function-minisql-executor-scan-close-function-close-reader-src-minisql-executor-scan-ml-954116435"></a>
### close

```ml
function close(reader)
```

Closes close owned by the minisql executor scan module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L786)

<a id="constant-constant-minisql-executor-scan-closed-handle-const-closed-handle-9008-src-minisql-executor-scan-ml-1663484046"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql executor scan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L34)

<a id="function-function-minisql-executor-scan-componentname-function-componentname-src-minisql-executor-scan-ml-819702012"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql executor scan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1050)

<a id="constant-constant-minisql-executor-scan-corrupt-data-const-corrupt-data-9004-src-minisql-executor-scan-ml-657144412"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql executor scan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L32)

<a id="function-function-minisql-executor-scan-count-function-count-reader-src-minisql-executor-scan-ml-1511357421"></a>
### count

```ml
function count(reader)
```

Counts count using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L778)

<a id="function-function-minisql-executor-scan-countliverows-function-countliverows-reader-src-minisql-executor-scan-ml-1756127831"></a>
### countLiveRows

```ml
function countLiveRows(reader)
```

Counts live slots without decoding row values. Every heap page still passes through transaction visibility, the shared cache, and page checksum checks; only row allocation, schema conversion, and overflow payload reads are skipped.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L597)

<a id="function-function-minisql-executor-scan-counttablerowscached-function-counttablerowscached-databasepath-table-pagetransaction-readcache-src-minisql-executor-scan-ml-1783841415"></a>
### countTableRowsCached

```ml
function countTableRowsCached(databasePath, table, pageTransaction, readCache)
```

Opens a short-lived cached reader and returns only its number of visible rows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L886)

<a id="function-function-minisql-executor-scan-counttablerowscachedcontrolled-function-counttablerowscachedcontrolled-database-sessionid-table-pagetransaction-src-minisql-executor-scan-ml-1449762363"></a>
### countTableRowsCachedControlled

```ml
function countTableRowsCachedControlled(database, sessionId, table, pageTransaction)
```

Counts live rows through a cancellation-aware cached reader.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L910)

<a id="function-function-minisql-executor-scan-decoderecord-function-decoderecord-reader-encoded-src-minisql-executor-scan-ml-1652294131"></a>
### decodeRecord

```ml
function decodeRecord(reader, encoded)
```

Decodes record using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L421)

<a id="function-function-minisql-executor-scan-decoderecordcolumns-function-decoderecordcolumns-reader-encoded-requiredcolumns-src-minisql-executor-scan-ml-1481976597"></a>
### decodeRecordColumns

```ml
function decodeRecordColumns(reader, encoded, requiredColumns)
```

Decodes one record while materializing only columns required by the query. Unused values retain a correctly typed SQL NULL placeholder so bound column indexes remain stable, but external TEXT/BLOB payloads are never fetched. Generated columns conservatively use the full decoder because their stored expressions may depend on columns that are not explicit in the SELECT list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L455)

<a id="function-function-minisql-executor-scan-evaluatedefault-function-evaluatedefault-rule-column-src-minisql-executor-scan-ml-79353412"></a>
### evaluateDefault

```ml
function evaluateDefault(rule, column)
```

Evaluates default using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rule` | `dynamic` | — | rule value consumed by this operation. |
| `column` | `dynamic` | — | column value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L359)

<a id="function-function-minisql-executor-scan-evaluategenerated-function-evaluategenerated-reader-generated-column-currentvalues-src-minisql-executor-scan-ml-300642721"></a>
### evaluateGenerated

```ml
function evaluateGenerated(reader, generated, column, currentValues)
```

Evaluates generated using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `generated` | `dynamic` | — | generated value consumed by this operation. |
| `column` | `dynamic` | — | column value consumed by this operation. |
| `currentValues` | `dynamic` | — | currentValues value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L386)

<a id="function-function-minisql-executor-scan-fail-function-fail-code-operation-message-src-minisql-executor-scan-ml-1355913017"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql executor scan module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L120)

<a id="function-function-minisql-executor-scan-findcolumnrule-function-findcolumnrule-reader-columnname-src-minisql-executor-scan-ml-583773510"></a>
### findColumnRule

```ml
function findColumnRule(reader, columnName)
```

Finds column rule using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `columnName` | `dynamic` | — | columnName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L346)

<a id="function-function-minisql-executor-scan-findgenerated-function-findgenerated-reader-columnname-src-minisql-executor-scan-ml-780411406"></a>
### findGenerated

```ml
function findGenerated(reader, columnName)
```

Finds generated using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `columnName` | `dynamic` | — | columnName value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L372)

<a id="function-function-minisql-executor-scan-heappagecount-function-heappagecount-reader-src-minisql-executor-scan-ml-493310815"></a>
### heapPageCount

```ml
function heapPageCount(reader)
```

Returns the number of physical heap pages advertised by the persistent page directory. Parallel operators use this metadata-only count to choose ranges.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L500)

<a id="constant-constant-minisql-executor-scan-invalid-argument-const-invalid-argument-9001-src-minisql-executor-scan-ml-430350263"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Transaction-aware sequential table scan for the first executable SQL engine.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L30)

<a id="function-function-minisql-executor-scan-isimplemented-function-isimplemented-src-minisql-executor-scan-ml-632356148"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql executor scan module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1064)

<a id="function-function-minisql-executor-scan-isrowbatch-function-isrowbatch-value-src-minisql-executor-scan-ml-1876253729"></a>
### isRowBatch

```ml
function isRowBatch(value)
```

Reports whether a value is a bounded RowBatch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L170)

<a id="function-function-minisql-executor-scan-isrowreference-function-isrowreference-value-src-minisql-executor-scan-ml-1568702825"></a>
### isRowReference

```ml
function isRowReference(value)
```

Returns whether the supplied value satisfies the row reference condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L128)

<a id="function-function-minisql-executor-scan-isscannedrow-function-isscannedrow-value-src-minisql-executor-scan-ml-1985865513"></a>
### isScannedRow

```ml
function isScannedRow(value)
```

Returns whether the supplied value satisfies the scanned row condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L136)

<a id="function-function-minisql-executor-scan-istablereader-function-istablereader-value-src-minisql-executor-scan-ml-1991443535"></a>
### isTableReader

```ml
function isTableReader(value)
```

Returns whether the supplied value satisfies the table reader condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L144)

<a id="function-function-minisql-executor-scan-istablerowcursor-function-istablerowcursor-value-src-minisql-executor-scan-ml-686045957"></a>
### isTableRowCursor

```ml
function isTableRowCursor(value)
```

Returns whether value is a forward-only table row cursor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L164)

<a id="function-function-minisql-executor-scan-materializestoredvalue-function-materializestoredvalue-reader-index-raw-src-minisql-executor-scan-ml-103340357"></a>
### materializeStoredValue

```ml
function materializeStoredValue(reader, index, raw)
```

Implements materialize stored value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |
| `raw` | `dynamic` | — | raw value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L400)

<a id="function-function-minisql-executor-scan-nextbatch-function-nextbatch-cursor-maximumrows-src-minisql-executor-scan-ml-1362770243"></a>
### nextBatch

```ml
function nextBatch(cursor, maximumRows)
```

Reads at most maximumRows from a forward-only cursor. A void result denotes end-of-input; every non-void batch contains at least one row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |
| `maximumRows` | `dynamic` | — | maximumRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L563)

<a id="function-function-minisql-executor-scan-nextrow-function-nextrow-cursor-src-minisql-executor-scan-ml-867047600"></a>
### nextRow

```ml
function nextRow(cursor)
```

Returns the next live row or void at end-of-table. Advancing before returning makes repeated calls deterministic even when the caller immediately discards a multi-megabyte decoded payload.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cursor` | `dynamic` | — | cursor value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L524)

<a id="function-function-minisql-executor-scan-open-function-open-databasepath-table-pagetransaction-src-minisql-executor-scan-ml-209158055"></a>
### open

```ml
function open(databasePath, table, pageTransaction)
```

Opens a table without a shared cache for storage tools and direct tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L257)

<a id="function-function-minisql-executor-scan-opencached-function-opencached-databasepath-table-pagetransaction-readcache-src-minisql-executor-scan-ml-577048327"></a>
### openCached

```ml
function openCached(databasePath, table, pageTransaction, readCache)
```

Opens cached for the minisql executor scan module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L215)

<a id="function-function-minisql-executor-scan-opencachedwithschema-function-opencachedwithschema-databasepath-table-pagetransaction-readcache-state-src-minisql-executor-scan-ml-1213062928"></a>
### openCachedWithSchema

```ml
function openCachedWithSchema(databasePath, table, pageTransaction, readCache, state)
```

Opens a table using a database-owned immutable schema snapshot. Managed query execution uses this variant so point lookups do not reopen and verify schema.history. The paged table itself is still opened and validated here.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L240)

<a id="function-function-minisql-executor-scan-opencursor-function-opencursor-reader-requiredcolumns-src-minisql-executor-scan-ml-1819011973"></a>
### openCursor

```ml
function openCursor(reader, requiredColumns)
```

Creates a forward-only cursor over live rows. Heap-page discovery uses the persistent sidecar index, while each selected heap page is still checksum verified before any slot or overflow pointer is trusted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L490)

<a id="function-function-minisql-executor-scan-opencursorrange-function-opencursorrange-reader-requiredcolumns-firstpageindex-endpageindex-src-minisql-executor-scan-ml-344540850"></a>
### openCursorRange

```ml
function openCursorRange(reader, requiredColumns, firstPageIndex, endPageIndex)
```

Creates a cursor over the half-open physical heap-page range [first, end). The range addresses entries in the persistent heap-page directory rather than raw file page numbers, so overflow and metadata pages are never scanned.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `firstPageIndex` | `dynamic` | — | Zero-based index of first page. |
| `endPageIndex` | `dynamic` | — | Zero-based index of end page. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L512)

<a id="function-function-minisql-executor-scan-openexisting-function-openexisting-databasepath-file-table-pagetransaction-src-minisql-executor-scan-ml-38941281"></a>
### openExisting

```ml
function openExisting(databasePath, file, table, pageTransaction)
```

Opens a caller-owned file without a shared cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L307)

<a id="function-function-minisql-executor-scan-openexistingcached-function-openexistingcached-databasepath-file-table-pagetransaction-readcache-src-minisql-executor-scan-ml-264606529"></a>
### openExistingCached

```ml
function openExistingCached(databasePath, file, table, pageTransaction, readCache)
```

Opens existing using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L270)

<a id="function-function-minisql-executor-scan-openexistingcachedwithschema-function-openexistingcachedwithschema-databasepath-file-table-pagetransaction-readcache-state-src-minisql-executor-scan-ml-340189126"></a>
### openExistingCachedWithSchema

```ml
function openExistingCachedWithSchema(databasePath, file, table, pageTransaction, readCache, state)
```

Creates a non-owning reader over a persistent database-owned table handle and an already published immutable schema snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L290)

<a id="function-function-minisql-executor-scan-readreference-function-readreference-reader-reference-src-minisql-executor-scan-ml-171632130"></a>
### readReference

```ml
function readReference(reader, reference)
```

Reads reference using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `reference` | `dynamic` | — | reference value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L743)

<a id="function-function-minisql-executor-scan-readtablereference-function-readtablereference-databasepath-table-pagetransaction-reference-src-minisql-executor-scan-ml-1677603376"></a>
### readTableReference

```ml
function readTableReference(databasePath, table, pageTransaction, reference)
```

Reads table reference using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `reference` | `dynamic` | — | reference value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L765)

- [minisql.executor.scan.RowBatch](Type-minisql-executor-scan-rowbatch-2084287350.md) — struct
- [minisql.executor.scan.RowReference](Type-minisql-executor-scan-rowreference-1672305503.md) — struct
<a id="function-function-minisql-executor-scan-samplerows-function-samplerows-reader-populationrows-maximumrows-src-minisql-executor-scan-ml-1489789820"></a>
### sampleRows

```ml
function sampleRows(reader, populationRows, maximumRows)
```

Decodes at most `maximumRows` uniformly spaced live rows while visiting each heap page once. ANALYZE obtains the exact population from slot headers first, then uses this pass to bound external-value I/O and retained memory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `maximumRows` | `dynamic` | — | maximumRows value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L622)

<a id="function-function-minisql-executor-scan-sampletablerowscached-function-sampletablerowscached-databasepath-table-populationrows-maximumrows-readcache-src-minisql-executor-scan-ml-913397277"></a>
### sampleTableRowsCached

```ml
function sampleTableRowsCached(databasePath, table, populationRows, maximumRows, readCache)
```

Opens one cached reader for the bounded ANALYZE sampling pass.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `populationRows` | `dynamic` | — | populationRows value consumed by this operation. |
| `maximumRows` | `dynamic` | — | maximumRows value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L927)

<a id="function-function-minisql-executor-scan-scanexisting-function-scanexisting-databasepath-file-table-pagetransaction-src-minisql-executor-scan-ml-2136488773"></a>
### scanExisting

```ml
function scanExisting(databasePath, file, table, pageTransaction)
```

Scans existing using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L944)

<a id="function-function-minisql-executor-scan-scanexistingrange-function-scanexistingrange-databasepath-file-table-pagetransaction-offset-limit-src-minisql-executor-scan-ml-229230199"></a>
### scanExistingRange

```ml
function scanExistingRange(databasePath, file, table, pageTransaction, offset, limit)
```

Applies a bounded range scan to a caller-owned paged file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L960)

<a id="function-function-minisql-executor-scan-scanexistingrangecolumns-function-scanexistingrangecolumns-databasepath-file-table-pagetransaction-offset-limit-requiredcolumns-src-minisql-executor-scan-ml-44459591"></a>
### scanExistingRangeColumns

```ml
function scanExistingRangeColumns(databasePath, file, table, pageTransaction, offset, limit, requiredColumns)
```

Applies both range and column pushdown to a caller-owned paged file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L977)

- [minisql.executor.scan.ScannedRow](Type-minisql-executor-scan-scannedrow-207394362.md) — struct
<a id="function-function-minisql-executor-scan-scantable-function-scantable-databasepath-table-pagetransaction-src-minisql-executor-scan-ml-1795761341"></a>
### scanTable

```ml
function scanTable(databasePath, table, pageTransaction)
```

Scans table using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L800)

<a id="function-function-minisql-executor-scan-scantablerange-function-scantablerange-databasepath-table-pagetransaction-offset-limit-src-minisql-executor-scan-ml-439919659"></a>
### scanTableRange

```ml
function scanTableRange(databasePath, table, pageTransaction, offset, limit)
```

Scans only a physical live-row range and stops as soon as the requested number of rows has been decoded. This bounds memory for simple paginated SELECT statements and avoids reading overflow values outside the page.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L817)

<a id="function-function-minisql-executor-scan-scantablerangecolumns-function-scantablerangecolumns-databasepath-table-pagetransaction-offset-limit-requiredcolumns-src-minisql-executor-scan-ml-515902911"></a>
### scanTableRangeColumns

```ml
function scanTableRangeColumns(databasePath, table, pageTransaction, offset, limit, requiredColumns)
```

Scans a range while fetching only columns referenced by the bound query.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L833)

<a id="function-function-minisql-executor-scan-scantablerangecolumnscached-function-scantablerangecolumnscached-databasepath-table-pagetransaction-offset-limit-requiredcolumns-readcache-src-minisql-executor-scan-ml-1314396771"></a>
### scanTableRangeColumnsCached

```ml
function scanTableRangeColumnsCached(databasePath, table, pageTransaction, offset, limit, requiredColumns, readCache)
```

Uses the database-owned concurrent page cache together with range and projection pushdown. The reader handle remains short-lived; cache frames are keyed only by stable path and page number.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |
| `readCache` | `dynamic` | — | readCache value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L852)

<a id="function-function-minisql-executor-scan-scantablerangecolumnscachedcontrolled-function-scantablerangecolumnscachedcontrolled-database-sessionid-table-pagetransaction-offset-limit-requiredcolumns-src-minisql-executor-scan-ml-1832411095"></a>
### scanTableRangeColumnsCachedControlled

```ml
function scanTableRangeColumnsCachedControlled(database, sessionId, table, pageTransaction, offset, limit, requiredColumns)
```

Controlled cached scan used by network sessions. The ordinary helper stays available to embedded/offline callers that do not own an operational session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L870)

<a id="function-function-minisql-executor-scan-scanusing-function-scanusing-databasepath-table-pagetransaction-existingfile-src-minisql-executor-scan-ml-973964814"></a>
### scanUsing

```ml
function scanUsing(databasePath, table, pageTransaction, existingFile)
```

Scans using using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `existingFile` | `dynamic` | — | existingFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L993)

<a id="function-function-minisql-executor-scan-scanusingcolumns-function-scanusingcolumns-databasepath-table-pagetransaction-existingfile-requiredcolumns-src-minisql-executor-scan-ml-1078569520"></a>
### scanUsingColumns

```ml
function scanUsingColumns(databasePath, table, pageTransaction, existingFile, requiredColumns)
```

Scans all rows but materializes only the supplied table-column mask.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `existingFile` | `dynamic` | — | existingFile value consumed by this operation. |
| `requiredColumns` | `dynamic` | — | requiredColumns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1041)

<a id="function-function-minisql-executor-scan-scanusingcontrolled-function-scanusingcontrolled-database-sessionid-table-pagetransaction-existingfile-src-minisql-executor-scan-ml-993140070"></a>
### scanUsingControlled

```ml
function scanUsingControlled(database, sessionId, table, pageTransaction, existingFile)
```

Controlled full scan over either a caller-owned table file or a short-lived reader. This is used by UPDATE, DELETE, and TRUNCATE before staging changes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `existingFile` | `dynamic` | — | existingFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1006)

<a id="function-function-minisql-executor-scan-scanusingrange-function-scanusingrange-databasepath-table-pagetransaction-existingfile-offset-limit-src-minisql-executor-scan-ml-292086858"></a>
### scanUsingRange

```ml
function scanUsingRange(databasePath, table, pageTransaction, existingFile, offset, limit)
```

Selects the bounded scan implementation for an optional caller-owned file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |
| `existingFile` | `dynamic` | — | existingFile value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `limit` | `dynamic` | — | limit value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1029)

<a id="function-function-minisql-executor-scan-schemafortable-function-schemafortable-table-src-minisql-executor-scan-ml-1613192384"></a>
### schemaForTable

```ml
function schemaForTable(table)
```

Implements schema for table for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | table value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L197)

<a id="function-function-minisql-executor-scan-setexecutioncontrol-function-setexecutioncontrol-reader-database-sessionid-src-minisql-executor-scan-ml-1107792349"></a>
### setExecutionControl

```ml
function setExecutionControl(reader, database, sessionId)
```

Attaches statement cancellation and deadline state to a reader. Polling is deliberately performed once per physical heap page, which bounds abort latency without adding a registry lookup for every row or expression.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L154)

- [minisql.executor.scan.TableReader](Type-minisql-executor-scan-tablereader-1730172293.md) — struct
- [minisql.executor.scan.TableRowCursor](Type-minisql-executor-scan-tablerowcursor-1183228132.md) — struct
<a id="function-function-minisql-executor-scan-targetmilestone-function-targetmilestone-src-minisql-executor-scan-ml-1070831770"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql executor scan module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L1057)

<a id="constant-constant-minisql-executor-scan-unsupported-sql-const-unsupported-sql-9025-src-minisql-executor-scan-ml-1896278037"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```

Defines the unsupported sql constant used by the minisql executor scan module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L36)

<a id="function-function-minisql-executor-scan-validateopen-function-validateopen-reader-operation-src-minisql-executor-scan-ml-605199568"></a>
### validateOpen

```ml
function validateOpen(reader, operation)
```

Validates open for the minisql executor scan workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L317)

<a id="function-function-minisql-executor-scan-verifyandcount-function-verifyandcount-reader-src-minisql-executor-scan-ml-602296475"></a>
### verifyAndCount

```ml
function verifyAndCount(reader)
```

Fully decodes and validates every live row while retaining only one row. This includes external TEXT/BLOB chains, UTF-8 conversion, schema compatibility, generated/default column handling, page checksums, and slot generations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L580)

<a id="function-function-minisql-executor-scan-verifytable-function-verifytable-databasepath-table-pagetransaction-src-minisql-executor-scan-ml-1632023669"></a>
### verifyTable

```ml
function verifyTable(databasePath, table, pageTransaction)
```

Opens, streams, and closes one table for the offline consistency checker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `table` | `dynamic` | — | table value consumed by this operation. |
| `pageTransaction` | `dynamic` | — | pageTransaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L665)

<a id="function-function-minisql-executor-scan-visiblepage-function-visiblepage-reader-pagenumber-src-minisql-executor-scan-ml-1748001171"></a>
### visiblePage

```ml
function visiblePage(reader, pageNumber)
```

Implements visible page for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reader` | `dynamic` | — | reader value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L330)
