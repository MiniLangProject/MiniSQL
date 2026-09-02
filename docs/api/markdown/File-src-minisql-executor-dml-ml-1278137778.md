# `src/minisql/executor/dml.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.executor.dml`](Package-minisql-executor-dml-203878558.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)
- `minisql/sql/expressions.ml` as `expressions` → [src/minisql/sql/expressions.ml](File-src-minisql-sql-expressions-ml-980820199.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `minisql/storage/btree.ml` as `btree` → [src/minisql/storage/btree.ml](File-src-minisql-storage-btree-ml-1474397187.md)
- `minisql/storage/heap_file.ml` as `heap_file` → [src/minisql/storage/heap_file.ml](File-src-minisql-storage-heap-file-ml-1771906446.md)
- `minisql/storage/overflow.ml` as `overflow` → [src/minisql/storage/overflow.ml](File-src-minisql-storage-overflow-ml-2096314611.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/row_codec.ml` as `row_codec` → [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)
- `minisql/storage/slotted_page.ml` as `slotted_page` → [src/minisql/storage/slotted_page.ml](File-src-minisql-storage-slotted-page-ml-1299577846.md)
- `minisql/transaction/checkpoint.ml` as `checkpoint` → [src/minisql/transaction/checkpoint.ml](File-src-minisql-transaction-checkpoint-ml-1306482346.md)
- `minisql/transaction/transaction.ml` as `transaction` → [src/minisql/transaction/transaction.ml](File-src-minisql-transaction-transaction-ml-1157597470.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-dml-appendkeybytes-function-appendkeybytes-left-right-src-minisql-executor-dml-ml-1118650033"></a>
### appendKeyBytes

```ml
function appendKeyBytes(left, right)
```

Appends key bytes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1139)

<a id="function-function-minisql-executor-dml-applygenerated-function-applygenerated-database-table-row-src-minisql-executor-dml-ml-887687433"></a>
### applyGenerated

```ml
function applyGenerated(database, table, row)
```

Applies generated using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L352)

<a id="function-function-minisql-executor-dml-applyinsertedindexes-function-applyinsertedindexes-database-table-result-src-minisql-executor-dml-ml-2143230300"></a>
### applyInsertedIndexes

```ml
function applyInsertedIndexes(database, table, result)
```

Applies an insert-only statement delta to every derived index without rescanning unrelated table payload pages. The caller publishes the durable indexes.dirty marker before the heap commit; a crash or failed index write is therefore repaired by the ordinary startup path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1509)

<a id="function-function-minisql-executor-dml-bindconstraintkeyexpressions-function-bindconstraintkeyexpressions-table-constraint-src-minisql-executor-dml-ml-1460149331"></a>
### bindConstraintKeyExpressions

```ml
function bindConstraintKeyExpressions(table, constraint)
```

Implements constraint key for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L446)

<a id="function-function-minisql-executor-dml-bindindexpredicate-function-bindindexpredicate-table-constraint-src-minisql-executor-dml-ml-1384344211"></a>
### bindIndexPredicate

```ml
function bindIndexPredicate(table, constraint)
```

Binds the canonical predicate stored for a partial index once per operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L514)

<a id="constant-constant-minisql-executor-dml-binding-error-const-binding-error-9020-src-minisql-executor-dml-ml-1939517166"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L44)

<a id="function-function-minisql-executor-dml-buildindexentries-function-buildindexentries-database-table-constraint-pagetransaction-src-minisql-executor-dml-ml-598833077"></a>
### buildIndexEntries

```ml
function buildIndexEntries(database, table, constraint, pageTransaction)
```

Builds index entries using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1441)

<a id="function-function-minisql-executor-dml-clearindexesdirty-function-clearindexesdirty-database-src-minisql-executor-dml-ml-2085325219"></a>
### clearIndexesDirty

```ml
function clearIndexesDirty(database)
```

Implements clear indexes dirty for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1676)

<a id="constant-constant-minisql-executor-dml-closed-handle-const-closed-handle-9008-src-minisql-executor-dml-ml-903959996"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L38)

<a id="function-function-minisql-executor-dml-closepersistenttablereader-function-closepersistenttablereader-opened-src-minisql-executor-dml-ml-2144301729"></a>
### closePersistentTableReader

```ml
function closePersistentTableReader(opened)
```

Closes a non-owning reader and then releases its persistent table lease.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `opened` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1733)

<a id="function-function-minisql-executor-dml-closepublishedfiles-function-closepublishedfiles-files-src-minisql-executor-dml-ml-1913372913"></a>
### closePublishedFiles

```ml
function closePublishedFiles(files)
```

Closes published files using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1045)

<a id="function-function-minisql-executor-dml-closereadonlyindex-function-closereadonlyindex-lease-src-minisql-executor-dml-ml-1261107268"></a>
### closeReadOnlyIndex

```ml
function closeReadOnlyIndex(lease)
```

Releases a persistent index lease without closing its database-owned tree.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1434)

<a id="function-function-minisql-executor-dml-comparisonliteralforboundkey-function-comparisonliteralforboundkey-expression-keyexpression-src-minisql-executor-dml-ml-10738667"></a>
### comparisonLiteralForBoundKey

```ml
function comparisonLiteralForBoundKey(expression, keyExpression)
```

Finds a literal comparison against one exact bound functional-index key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `keyExpression` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1933)

<a id="function-function-minisql-executor-dml-comparisonliteralforcolumn-function-comparisonliteralforcolumn-expression-columnindex-src-minisql-executor-dml-ml-1103021578"></a>
### comparisonLiteralForColumn

```ml
function comparisonLiteralForColumn(expression, columnIndex)
```

Finds and normalizes a comparison between one bound column and a literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1987)

<a id="function-function-minisql-executor-dml-componentname-function-componentname-src-minisql-executor-dml-ml-1688155174"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2438)

<a id="function-function-minisql-executor-dml-compositeequalityindexrows-function-compositeequalityindexrows-database-table-expression-pagetransaction-src-minisql-executor-dml-ml-1611870044"></a>
### compositeEqualityIndexRows

```ml
function compositeEqualityIndexRows(database, table, expression, pageTransaction)
```

Preserves the legacy composite-index API for unplanned callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1883)

- [minisql.executor.dml.ConflictMatch](Type-minisql-executor-dml-conflictmatch-1662340147.md) — struct
<a id="function-function-minisql-executor-dml-conflictupdate-function-conflictupdate-database-bound-excludedrow-match-pagetransaction-file-rowschema-src-minisql-executor-dml-ml-422734056"></a>
### conflictUpdate

```ml
function conflictUpdate(database, bound, excludedRow, match, pageTransaction, file, rowSchema)
```

Implements conflict update for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `excludedRow` | `dynamic` | — |  |
| `match` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `rowSchema` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L817)

<a id="constant-constant-minisql-executor-dml-constraint-violation-const-constraint-violation-9021-src-minisql-executor-dml-ml-1276392313"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L45)

<a id="function-function-minisql-executor-dml-constraintcolumnmask-function-constraintcolumnmask-table-constraints-src-minisql-executor-dml-ml-988944358"></a>
### constraintColumnMask

```ml
function constraintColumnMask(table, constraints)
```

Builds a table-width mask for local constraint key columns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraints` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L142)

<a id="function-function-minisql-executor-dml-constraintforindexname-function-constraintforindexname-database-table-indexname-src-minisql-executor-dml-ml-198303772"></a>
### constraintForIndexName

```ml
function constraintForIndexName(database, table, indexName)
```

Finds the exact persistent index selected by the physical plan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1925)

<a id="function-function-minisql-executor-dml-constraintforsinglecolumn-function-constraintforsinglecolumn-database-table-columnindex-src-minisql-executor-dml-ml-1334959703"></a>
### constraintForSingleColumn

```ml
function constraintForSingleColumn(database, table, columnIndex)
```

Retains the original first-match lookup used by joins and compatibility diagnostics that do not carry a typed optimizer decision.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1716)

<a id="function-function-minisql-executor-dml-constraintkey-function-constraintkey-row-table-constraint-src-minisql-executor-dml-ml-489494019"></a>
### constraintKey

```ml
function constraintKey(row, table, constraint)
```

Resolves key metadata for compatibility callers outside index hot loops.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `row` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L476)

<a id="function-function-minisql-executor-dml-constraintkeybound-function-constraintkeybound-row-table-constraint-boundkeys-src-minisql-executor-dml-ml-763744741"></a>
### constraintKeyBound

```ml
function constraintKeyBound(row, table, constraint, boundKeys)
```

Evaluates persisted expression keys and reads ordinary column keys.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `row` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `boundKeys` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L459)

<a id="constant-constant-minisql-executor-dml-corrupt-data-const-corrupt-data-9004-src-minisql-executor-dml-ml-717406690"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L37)

<a id="function-function-minisql-executor-dml-coveredrowsfromindexentries-function-coveredrowsfromindexentries-table-constraint-entries-src-minisql-executor-dml-ml-1402107087"></a>
### coveredRowsFromIndexEntries

```ml
function coveredRowsFromIndexEntries(table, constraint, entries)
```

Converts B+-tree entries into heap-shaped rows without opening the heap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `entries` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1371)

<a id="function-function-minisql-executor-dml-decodecoveredindexkey-function-decodecoveredindexkey-table-constraint-encoded-src-minisql-executor-dml-ml-2102704429"></a>
### decodeCoveredIndexKey

```ml
function decodeCoveredIndexKey(table, constraint, encoded)
```

Reconstructs table-typed SQL values from an index key. Non-key positions are typed NULL placeholders and are safe because the optimizer proves they are not referenced before selecting an index-only plan. Floating encodings retain their textual ordering representation and therefore conservatively fall back.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1316)

<a id="function-function-minisql-executor-dml-decodeescapedkeybytes-function-decodeescapedkeybytes-encoded-startoffset-src-minisql-executor-dml-ml-1128136087"></a>
### decodeEscapedKeyBytes

```ml
function decodeEscapedKeyBytes(encoded, startOffset)
```

Decodes one zero-escaped variable-width key component and returns its bytes plus the first cursor position after the 0,0 terminator.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |
| `startOffset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1259)

<a id="function-function-minisql-executor-dml-decodeincludedindexvalues-function-decodeincludedindexvalues-table-constraint-encoded-output-src-minisql-executor-dml-ml-1789853140"></a>
### decodeIncludedIndexValues

```ml
function decodeIncludedIndexValues(table, constraint, encoded, output)
```

Merges a validated MSI v1 payload into the table-width row reconstructed from the key. Missing legacy payloads return void and trigger a safe fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |
| `output` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1353)

<a id="function-function-minisql-executor-dml-decodeindexpart-function-decodeindexpart-column-encoded-cursor-operation-src-minisql-executor-dml-ml-1901313465"></a>
### decodeIndexPart

```ml
function decodeIndexPart(column, encoded, cursor, operation)
```

Decodes one self-delimiting typed value shared by ordered keys and INCLUDE payloads. Floating-point key text is not reversible and deliberately returns void, which makes execution fall back to a heap-backed index scan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `column` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |
| `cursor` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1282)

<a id="function-function-minisql-executor-dml-decoderowreference-function-decoderowreference-tableid-encoded-src-minisql-executor-dml-ml-1556452753"></a>
### decodeRowReference

```ml
function decodeRowReference(tableId, encoded)
```

Decodes row reference using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1236)

<a id="function-function-minisql-executor-dml-delete-function-delete-database-sessionid-bound-pagetransaction-src-minisql-executor-dml-ml-1485158123"></a>
### delete

```ml
function delete(database, sessionId, bound, pageTransaction)
```

Deletes delete using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L986)

<a id="function-function-minisql-executor-dml-deleteinner-function-deleteinner-database-sessionid-bound-pagetransaction-file-src-minisql-executor-dml-ml-1613313591"></a>
### deleteInner

```ml
function deleteInner(database, sessionId, bound, pageTransaction, file)
```

Deletes inner using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L964)

- [minisql.executor.dml.DmlResult](Type-minisql-executor-dml-dmlresult-1024633164.md) — struct
<a id="constant-constant-minisql-executor-dml-duplicate-key-const-duplicate-key-9022-src-minisql-executor-dml-ml-576496888"></a>
### DUPLICATE_KEY

```ml
const DUPLICATE_KEY = 9022
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L46)

<a id="function-function-minisql-executor-dml-encodeconstrainthashkey-function-encodeconstrainthashkey-keyvalues-src-minisql-executor-dml-ml-982140813"></a>
### encodeConstraintHashKey

```ml
function encodeConstraintHashKey(keyValues)
```

Encodes an exact composite constraint key without the physical B+ tree size ceiling. The statement-local hash set uses this representation to validate arbitrarily large batches in linear expected time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1207)

<a id="function-function-minisql-executor-dml-encodeindexentryvalue-function-encodeindexentryvalue-table-constraint-rowvalues-reference-src-minisql-executor-dml-ml-705597344"></a>
### encodeIndexEntryValue

```ml
function encodeIndexEntryValue(table, constraint, rowValues, reference)
```

Encodes a leaf value as a stable row-reference prefix followed, when needed, by the MSI v1 marker and self-delimiting typed INCLUDE values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `rowValues` | `dynamic` | — |  |
| `reference` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1338)

<a id="function-function-minisql-executor-dml-encodeindexkey-function-encodeindexkey-keyvalues-src-minisql-executor-dml-ml-1247495285"></a>
### encodeIndexKey

```ml
function encodeIndexKey(keyValues)
```

Encodes index key using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyValues` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1194)

<a id="function-function-minisql-executor-dml-encoderowreference-function-encoderowreference-tableid-reference-src-minisql-executor-dml-ml-1220422780"></a>
### encodeRowReference

```ml
function encodeRowReference(tableId, reference)
```

Encodes row reference using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |
| `reference` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1222)

<a id="function-function-minisql-executor-dml-ensureindexes-function-ensureindexes-database-src-minisql-executor-dml-ml-1773297009"></a>
### ensureIndexes

```ml
function ensureIndexes(database)
```

Ensures indexes using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1686)

<a id="function-function-minisql-executor-dml-equalityindexrows-function-equalityindexrows-database-table-columnindex-literalvalue-pagetransaction-src-minisql-executor-dml-ml-326846904"></a>
### equalityIndexRows

```ml
function equalityIndexRows(database, table, columnIndex, literalValue, pageTransaction)
```

Preserves the legacy equality-index API for join probes and older callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `literalValue` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1788)

<a id="function-function-minisql-executor-dml-equalityliteralforcolumn-function-equalityliteralforcolumn-expression-columnindex-src-minisql-executor-dml-ml-1902618230"></a>
### equalityLiteralForColumn

```ml
function equalityLiteralForColumn(expression, columnIndex)
```

Implements equality literal for column for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1829)

<a id="function-function-minisql-executor-dml-escapedkeybytes-function-escapedkeybytes-source-src-minisql-executor-dml-ml-1727842647"></a>
### escapedKeyBytes

```ml
function escapedKeyBytes(source)
```

Implements escaped key bytes for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1148)

<a id="function-function-minisql-executor-dml-evaluateconstantsql-function-evaluateconstantsql-sqltext-src-minisql-executor-dml-ml-252531841"></a>
### evaluateConstantSql

```ml
function evaluateConstantSql(sqlText)
```

Evaluates constant SQL using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L378)

<a id="function-function-minisql-executor-dml-evaluatereturning-function-evaluatereturning-returningitems-row-src-minisql-executor-dml-ml-1212356130"></a>
### evaluateReturning

```ml
function evaluateReturning(returningItems, row)
```

Evaluates returning using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `returningItems` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L768)

<a id="function-function-minisql-executor-dml-fail-function-fail-code-operation-message-src-minisql-executor-dml-ml-778088365"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L86)

<a id="function-function-minisql-executor-dml-fileforchange-function-fileforchange-database-fileid-src-minisql-executor-dml-ml-65550298"></a>
### fileForChange

```ml
function fileForChange(database, fileId)
```

Implements file for change for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `fileId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1034)

<a id="function-function-minisql-executor-dml-findconflict-function-findconflict-database-bound-row-pagetransaction-file-src-minisql-executor-dml-ml-29488854"></a>
### findConflict

```ml
function findConflict(database, bound, row, pageTransaction, file)
```

Finds conflict using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L795)

<a id="function-function-minisql-executor-dml-findgenerated-function-findgenerated-database-table-columnname-src-minisql-executor-dml-ml-949430744"></a>
### findGenerated

```ml
function findGenerated(database, table, columnName)
```

Finds generated using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L342)

<a id="function-function-minisql-executor-dml-findrule-function-findrule-tableschemavalue-columnname-src-minisql-executor-dml-ml-312643881"></a>
### findRule

```ml
function findRule(tableSchemaValue, columnName)
```

Finds rule using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchemaValue` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L367)

<a id="function-function-minisql-executor-dml-generatedcolumns-function-generatedcolumns-database-table-src-minisql-executor-dml-ml-1875473215"></a>
### generatedColumns

```ml
function generatedColumns(database, table)
```

Implements generated columns for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L335)

<a id="function-function-minisql-executor-dml-hasidentitycolumn-function-hasidentitycolumn-database-table-src-minisql-executor-dml-ml-29494139"></a>
### hasIdentityColumn

```ml
function hasIdentityColumn(database, table)
```

Returns whether identity allocation requires sequential visibility of rows inserted earlier in the same statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L623)

<a id="function-function-minisql-executor-dml-indexaccessdescription-function-indexaccessdescription-database-bound-src-minisql-executor-dml-ml-1112743319"></a>
### indexAccessDescription

```ml
function indexAccessDescription(database, bound)
```

Implements index access description for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2190)

<a id="function-function-minisql-executor-dml-indexcolumnmask-function-indexcolumnmask-table-constraint-src-minisql-executor-dml-ml-574050315"></a>
### indexColumnMask

```ml
function indexColumnMask(table, constraint)
```

Extends a key mask with non-key values persisted in covering-index leaves.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L172)

<a id="function-function-minisql-executor-dml-indexdirtypath-function-indexdirtypath-database-src-minisql-executor-dml-ml-1438789533"></a>
### indexDirtyPath

```ml
function indexDirtyPath(database)
```

Implements index dirty path for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1636)

<a id="function-function-minisql-executor-dml-indexedconstraints-function-indexedconstraints-database-table-src-minisql-executor-dml-ml-1042846335"></a>
### indexedConstraints

```ml
function indexedConstraints(database, table)
```

Implements indexed constraints for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1386)

<a id="function-function-minisql-executor-dml-indexesneedrepair-function-indexesneedrepair-database-src-minisql-executor-dml-ml-1746326027"></a>
### indexesNeedRepair

```ml
function indexesNeedRepair(database)
```

Implements indexes need repair for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1643)

<a id="function-function-minisql-executor-dml-indexfilesmissing-function-indexfilesmissing-database-src-minisql-executor-dml-ml-1701460627"></a>
### indexFilesMissing

```ml
function indexFilesMissing(database)
```

Detects missing derived index files without scanning any table heap. A clean dirty-marker state proves that committed index updates completed, but older databases or manual file loss may still leave an expected file absent.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1650)

<a id="function-function-minisql-executor-dml-indexkeypart-function-indexkeypart-value-src-minisql-executor-dml-ml-774872045"></a>
### indexKeyPart

```ml
function indexKeyPart(value)
```

Implements index key part for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1166)

<a id="function-function-minisql-executor-dml-indexpath-function-indexpath-database-constraint-src-minisql-executor-dml-ml-268600574"></a>
### indexPath

```ml
function indexPath(database, constraint)
```

Implements index path for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1406)

<a id="function-function-minisql-executor-dml-indexpredicatepasses-function-indexpredicatepasses-boundpredicate-row-src-minisql-executor-dml-ml-146017255"></a>
### indexPredicatePasses

```ml
function indexPredicatePasses(boundPredicate, row)
```

SQL WHERE semantics admit only TRUE; FALSE and UNKNOWN omit the row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `boundPredicate` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L520)

<a id="function-function-minisql-executor-dml-indexrowsforbound-function-indexrowsforbound-database-bound-pagetransaction-src-minisql-executor-dml-ml-1459630994"></a>
### indexRowsForBound

```ml
function indexRowsForBound(database, bound, pageTransaction)
```

Returns index candidates for one bound, single-table SELECT or void when the query shape or transaction visibility requires a sequential fallback.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2177)

<a id="function-function-minisql-executor-dml-initialrow-function-initialrow-database-bound-boundrow-pagetransaction-file-src-minisql-executor-dml-ml-658145592"></a>
### initialRow

```ml
function initialRow(database, bound, boundRow, pageTransaction, file)
```

Implements initial row for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `boundRow` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L407)

<a id="function-function-minisql-executor-dml-insert-function-insert-database-sessionid-bound-pagetransaction-src-minisql-executor-dml-ml-128613687"></a>
### insert

```ml
function insert(database, sessionId, bound, pageTransaction)
```

Inserts insert using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L893)

<a id="function-function-minisql-executor-dml-insertbatchwithoutconflict-function-insertbatchwithoutconflict-database-sessionid-bound-pagetransaction-file-src-minisql-executor-dml-ml-840144085"></a>
### insertBatchWithoutConflict

```ml
function insertBatchWithoutConflict(database, sessionId, bound, pageTransaction, file)
```

Inserts a conflict-free batch using fixed-size result buffers and one unique snapshot. Other constraints are checked again in insertion order so foreign keys may still reference a preceding row from the same SQL statement.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L635)

- [minisql.executor.dml.InsertCursor](Type-minisql-executor-dml-insertcursor-522103103.md) — struct
<a id="function-function-minisql-executor-dml-insertinner-function-insertinner-database-sessionid-bound-pagetransaction-file-src-minisql-executor-dml-ml-792131871"></a>
### insertInner

```ml
function insertInner(database, sessionId, bound, pageTransaction, file)
```

Inserts inner using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L853)

<a id="constant-constant-minisql-executor-dml-invalid-argument-const-invalid-argument-9001-src-minisql-executor-dml-ml-875183267"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Basic transactional DML. Every changed heap page is private until the WAL commit succeeds. Publishing pages after commit is redo-safe: a publication failure is repaired by the already accepted M7 recovery path on next open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L36)

<a id="function-function-minisql-executor-dml-isconflictmatch-function-isconflictmatch-value-src-minisql-executor-dml-ml-259305499"></a>
### isConflictMatch

```ml
function isConflictMatch(value)
```

Returns whether the supplied value satisfies the conflict match condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L100)

<a id="function-function-minisql-executor-dml-isdmlresult-function-isdmlresult-value-src-minisql-executor-dml-ml-470707937"></a>
### isDmlResult

```ml
function isDmlResult(value)
```

Returns whether the supplied value satisfies the DML result condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L93)

<a id="function-function-minisql-executor-dml-isimplemented-function-isimplemented-src-minisql-executor-dml-ml-1038395294"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2452)

<a id="function-function-minisql-executor-dml-isuniqueindexconstraint-function-isuniqueindexconstraint-value-src-minisql-executor-dml-ml-1761488093"></a>
### isUniqueIndexConstraint

```ml
function isUniqueIndexConstraint(value)
```

Returns whether the supplied value satisfies the unique index constraint condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1399)

<a id="function-function-minisql-executor-dml-joinindexrows-function-joinindexrows-database-source-condition-leftrow-pagetransaction-src-minisql-executor-dml-ml-515356791"></a>
### joinIndexRows

```ml
function joinIndexRows(database, source, condition, leftRow, pageTransaction)
```

Implements join index rows for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `condition` | `dynamic` | — |  |
| `leftRow` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2200)

<a id="function-function-minisql-executor-dml-keyhasnull-function-keyhasnull-key-src-minisql-executor-dml-ml-1796555603"></a>
### keyHasNull

```ml
function keyHasNull(key)
```

Implements key has null for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L483)

<a id="function-function-minisql-executor-dml-keysequal-function-keysequal-left-right-src-minisql-executor-dml-ml-1657984465"></a>
### keysEqual

```ml
function keysEqual(left, right)
```

Implements keys equal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L493)

<a id="function-function-minisql-executor-dml-markindexesdirty-function-markindexesdirty-database-src-minisql-executor-dml-ml-1402963441"></a>
### markIndexesDirty

```ml
function markIndexesDirty(database)
```

Implements mark indexes dirty for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1662)

<a id="function-function-minisql-executor-dml-namedcompositeequalityindexrows-function-namedcompositeequalityindexrows-database-table-expression-pagetransaction-indexname-src-minisql-executor-dml-ml-729593695"></a>
### namedCompositeEqualityIndexRows

```ml
function namedCompositeEqualityIndexRows(database, table, expression, pageTransaction, indexName)
```

Executes a complete equality probe against a named composite index, or the first usable composite index when indexName is empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1845)

<a id="function-function-minisql-executor-dml-namedconstraintforsinglecolumn-function-namedconstraintforsinglecolumn-database-table-columnindex-indexname-src-minisql-executor-dml-ml-597243968"></a>
### namedConstraintForSingleColumn

```ml
function namedConstraintForSingleColumn(database, table, columnIndex, indexName)
```

Finds a single-column index, optionally requiring the optimizer's stable catalog index name. An empty name retains the legacy first-match behavior.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1703)

<a id="function-function-minisql-executor-dml-namedequalityindexrows-function-namedequalityindexrows-database-table-columnindex-literalvalue-pagetransaction-indexname-src-minisql-executor-dml-ml-496592575"></a>
### namedEqualityIndexRows

```ml
function namedEqualityIndexRows(database, table, columnIndex, literalValue, pageTransaction, indexName)
```

Executes an equality lookup through one explicitly named single-column index, or through the first matching index when indexName is empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `literalValue` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1769)

<a id="function-function-minisql-executor-dml-namedexpressionindexrows-function-namedexpressionindexrows-database-table-expression-pagetransaction-indexname-src-minisql-executor-dml-ml-360173989"></a>
### namedExpressionIndexRows

```ml
function namedExpressionIndexRows(database, table, expression, pageTransaction, indexName)
```

Executes an equality/range probe against one named expression index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1951)

<a id="function-function-minisql-executor-dml-namedrangeindexrows-function-namedrangeindexrows-database-table-columnindex-literalvalue-operator-pagetransaction-indexname-src-minisql-executor-dml-ml-619370781"></a>
### namedRangeIndexRows

```ml
function namedRangeIndexRows(database, table, columnIndex, literalValue, operator, pageTransaction, indexName)
```

Executes a range lookup through one explicitly named single-column index, or through the first matching index when indexName is empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `literalValue` | `dynamic` | — |  |
| `operator` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1794)

<a id="function-function-minisql-executor-dml-namedsingleindexrows-function-namedsingleindexrows-database-table-expression-pagetransaction-indexname-src-minisql-executor-dml-ml-82418613"></a>
### namedSingleIndexRows

```ml
function namedSingleIndexRows(database, table, expression, pageTransaction, indexName)
```

Implements index rows for bound for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies. Finds one executable single-column index predicate inside an AND tree. The caller retains the complete WHERE predicate as a post-filter, so using one conjunct here is semantically equivalent to a database index candidate scan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1894)

<a id="function-function-minisql-executor-dml-nextidentity-function-nextidentity-database-table-columnindex-pagetransaction-file-src-minisql-executor-dml-ml-328549124"></a>
### nextIdentity

```ml
function nextIdentity(database, table, columnIndex, pageTransaction, file)
```

Implements next identity for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L387)

<a id="constant-constant-minisql-executor-dml-object-not-found-const-object-not-found-9014-src-minisql-executor-dml-ml-332094735"></a>
### OBJECT_NOT_FOUND

```ml
const OBJECT_NOT_FOUND = 9014
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L41)

<a id="function-function-minisql-executor-dml-openpersistenttablereader-function-openpersistenttablereader-database-table-pagetransaction-src-minisql-executor-dml-ml-1585215262"></a>
### openPersistentTableReader

```ml
function openPersistentTableReader(database, table, pageTransaction)
```

Acquires a persistent table handle and creates a non-owning reader over it. The returned lease keeps the handle generation alive while positioned reads materialize every heap reference.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1723)

<a id="function-function-minisql-executor-dml-openreadonlyindex-function-openreadonlyindex-database-constraint-operation-src-minisql-executor-dml-ml-2102244551"></a>
### openReadOnlyIndex

```ml
function openReadOnlyIndex(database, constraint, operation)
```

Opens an index for a read plan while retaining the concrete path in errors. This makes a missing or inaccessible derived file diagnosable without hiding corruption behind a generic native CreateFile failure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1413)

<a id="constant-constant-minisql-executor-dml-page-full-const-page-full-9015-src-minisql-executor-dml-ml-1841809338"></a>
### PAGE_FULL

```ml
const PAGE_FULL = 9015
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L42)

<a id="function-function-minisql-executor-dml-plannedcombinedindexrowsforbound-function-plannedcombinedindexrowsforbound-database-bound-pagetransaction-indexnames-unionmode-src-minisql-executor-dml-ml-1208720618"></a>
### plannedCombinedIndexRowsForBound

```ml
function plannedCombinedIndexRowsForBound(database, bound, pageTransaction, indexNames, unionMode)
```

Executes a planned intersection or union of independently safe index probes. Combining durable row identities preserves one heap row per result even when duplicate OR branches or overlapping indexes return the same entry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexNames` | `dynamic` | — |  |
| `unionMode` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2150)

<a id="function-function-minisql-executor-dml-plannedcoveredindexentries-function-plannedcoveredindexentries-database-table-expression-constraint-src-minisql-executor-dml-ml-153807040"></a>
### plannedCoveredIndexEntries

```ml
function plannedCoveredIndexEntries(database, table, expression, constraint)
```

Reads B+-tree entries for the exact equality/range shape accepted by the optimizer. Unlike ordinary index access this helper deliberately stops before heap dereference so a covering plan can reconstruct rows from key bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2007)

<a id="function-function-minisql-executor-dml-plannedindexonlyrowsforbound-function-plannedindexonlyrowsforbound-database-bound-pagetransaction-indexname-src-minisql-executor-dml-ml-1128358803"></a>
### plannedIndexOnlyRowsForBound

```ml
function plannedIndexOnlyRowsForBound(database, bound, pageTransaction, indexName)
```

Executes a planned covering scan without touching table or overflow pages.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2069)

<a id="function-function-minisql-executor-dml-plannedindexreferencesforbound-function-plannedindexreferencesforbound-database-bound-indexname-src-minisql-executor-dml-ml-593883132"></a>
### plannedIndexReferencesForBound

```ml
function plannedIndexReferencesForBound(database, bound, indexName)
```

Reads encoded row identities from one optimizer-selected ordinary index. Functional keys retain their safe single-index fallback until their entry codec exposes the same generic reference-only interface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2115)

<a id="function-function-minisql-executor-dml-plannedindexrowsforbound-function-plannedindexrowsforbound-database-bound-pagetransaction-indexname-src-minisql-executor-dml-ml-598165795"></a>
### plannedIndexRowsForBound

```ml
function plannedIndexRowsForBound(database, bound, pageTransaction, indexName)
```

Executes exactly the optimizer-selected access path for a single-table SELECT. Returning void lets the executor fall back safely if catalog or transaction visibility changed after planning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2086)

<a id="function-function-minisql-executor-dml-publishcommitted-function-publishcommitted-database-pagetransaction-commitlsn-src-minisql-executor-dml-ml-1170066974"></a>
### publishCommitted

```ml
function publishCommitted(database, pageTransaction, commitLsn)
```

Implements publish committed for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `commitLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1068)

<a id="function-function-minisql-executor-dml-rangeindexrows-function-rangeindexrows-database-table-columnindex-literalvalue-operator-pagetransaction-src-minisql-executor-dml-ml-567612606"></a>
### rangeIndexRows

```ml
function rangeIndexRows(database, table, columnIndex, literalValue, operator, pageTransaction)
```

Preserves the legacy range-index API for callers without a physical plan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `columnIndex` | `dynamic` | — |  |
| `literalValue` | `dynamic` | — |  |
| `operator` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1822)

<a id="constant-constant-minisql-executor-dml-read-only-violation-const-read-only-violation-9012-src-minisql-executor-dml-ml-2101287639"></a>
### READ_ONLY_VIOLATION

```ml
const READ_ONLY_VIOLATION = 9012
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L40)

<a id="function-function-minisql-executor-dml-readonlyindexcontext-function-readonlyindexcontext-lease-src-minisql-executor-dml-ml-458194440"></a>
### readOnlyIndexContext

```ml
function readOnlyIndexContext(lease)
```

Returns the event context amortized across this index probe's page reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1429)

<a id="function-function-minisql-executor-dml-readonlyindextree-function-readonlyindextree-lease-src-minisql-executor-dml-ml-1726122316"></a>
### readOnlyIndexTree

```ml
function readOnlyIndexTree(lease)
```

Returns the immutable BTree owned by one active database handle lease.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1424)

<a id="function-function-minisql-executor-dml-rebuildallindexes-function-rebuildallindexes-database-src-minisql-executor-dml-ml-733084177"></a>
### rebuildAllIndexes

```ml
function rebuildAllIndexes(database)
```

Implements rebuild all indexes for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1556)

<a id="function-function-minisql-executor-dml-rebuildindex-function-rebuildindex-database-table-constraint-src-minisql-executor-dml-ml-1266760974"></a>
### rebuildIndex

```ml
function rebuildIndex(database, table, constraint)
```

Implements rebuild index for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1471)

<a id="function-function-minisql-executor-dml-rebuildindexesfortable-function-rebuildindexesfortable-database-table-src-minisql-executor-dml-ml-1976300691"></a>
### rebuildIndexesForTable

```ml
function rebuildIndexesForTable(database, table)
```

Implements rebuild indexes for table for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1496)

<a id="function-function-minisql-executor-dml-reindex-function-reindex-database-name-src-minisql-executor-dml-ml-1832943030"></a>
### reindex

```ml
function reindex(database, name)
```

Implements reindex for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2408)

<a id="function-function-minisql-executor-dml-resetwalaftervacuum-function-resetwalaftervacuum-database-src-minisql-executor-dml-ml-2082802417"></a>
### resetWalAfterVacuum

```ml
function resetWalAfterVacuum(database)
```

Resets WAL after vacuum using the supplied inputs. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2345)

<a id="function-function-minisql-executor-dml-rewritetablestreaming-function-rewritetablestreaming-databasepath-path-pagesize-databaseid-table-src-minisql-executor-dml-ml-1900477993"></a>
### rewriteTableStreaming

```ml
function rewriteTableStreaming(databasePath, path, pageSize, databaseId, table)
```

Rewrites one table with memory bounded to one source page, one decoded row, and one target page. This is the VACUUM path for multi-gigabyte relations; retaining the complete live row set would otherwise scale heap usage with database size and fail long before the storage format reaches its limits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2277)

<a id="function-function-minisql-executor-dml-rowreferencecontains-function-rowreferencecontains-references-candidate-src-minisql-executor-dml-ml-1216313671"></a>
### rowReferenceContains

```ml
function rowReferenceContains(references, candidate)
```

Reports whether a reference collection already contains one row identity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `references` | `dynamic` | — |  |
| `candidate` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2105)

<a id="function-function-minisql-executor-dml-rowsfromindexentries-function-rowsfromindexentries-database-table-constraint-pagetransaction-entries-src-minisql-executor-dml-ml-629175779"></a>
### rowsFromIndexEntries

```ml
function rowsFromIndexEntries(database, table, constraint, pageTransaction, entries)
```

Implements rows from index entries for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `entries` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1745)

<a id="function-function-minisql-executor-dml-rowsfromreferences-function-rowsfromreferences-database-table-pagetransaction-references-src-minisql-executor-dml-ml-1497789068"></a>
### rowsFromReferences

```ml
function rowsFromReferences(database, table, pageTransaction, references)
```

Materializes one combined identity set through one shared table reader.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `references` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2130)

<a id="function-function-minisql-executor-dml-samereference-function-samereference-left-right-src-minisql-executor-dml-ml-644096527"></a>
### sameReference

```ml
function sameReference(left, right)
```

Implements same reference for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L107)

<a id="function-function-minisql-executor-dml-samerowreference-function-samerowreference-left-right-src-minisql-executor-dml-ml-1051269909"></a>
### sameRowReference

```ml
function sameRowReference(left, right)
```

Reports whether two durable heap references identify the same row version.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2100)

<a id="function-function-minisql-executor-dml-scanrows-function-scanrows-database-table-pagetransaction-existingfile-src-minisql-executor-dml-ml-1638434303"></a>
### scanRows

```ml
function scanRows(database, table, pageTransaction, existingFile)
```

Scans rows using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `existingFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L129)

<a id="function-function-minisql-executor-dml-scanrowscolumns-function-scanrowscolumns-database-table-pagetransaction-existingfile-requiredcolumns-src-minisql-executor-dml-ml-1325847411"></a>
### scanRowsColumns

```ml
function scanRowsColumns(database, table, pageTransaction, existingFile, requiredColumns)
```

Scans rows while retaining only columns needed by a constraint check.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `existingFile` | `dynamic` | — |  |
| `requiredColumns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L137)

<a id="function-function-minisql-executor-dml-schemastate-function-schemastate-database-src-minisql-executor-dml-ml-908090397"></a>
### schemaState

```ml
function schemaState(database)
```

Implements schema state for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L328)

<a id="function-function-minisql-executor-dml-singleindexrows-function-singleindexrows-database-table-expression-pagetransaction-src-minisql-executor-dml-ml-104732678"></a>
### singleIndexRows

```ml
function singleIndexRows(database, table, expression, pageTransaction)
```

Finds the first executable single-column predicate for legacy callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `expression` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1920)

<a id="function-function-minisql-executor-dml-stagedelete-function-stagedelete-pagetransaction-file-table-reference-src-minisql-executor-dml-ml-2073075574"></a>
### stageDelete

```ml
function stageDelete(pageTransaction, file, table, reference)
```

Implements stage delete for this module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `reference` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L288)

<a id="function-function-minisql-executor-dml-stageinsert-function-stageinsert-pagetransaction-file-table-encodedrow-src-minisql-executor-dml-ml-58867153"></a>
### stageInsert

```ml
function stageInsert(pageTransaction, file, table, encodedRow)
```

Implements stage insert for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `encodedRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L207)

<a id="function-function-minisql-executor-dml-stageinsertwithcursor-function-stageinsertwithcursor-pagetransaction-file-table-encodedrow-cursor-src-minisql-executor-dml-ml-162834203"></a>
### stageInsertWithCursor

```ml
function stageInsertWithCursor(pageTransaction, file, table, encodedRow, cursor)
```

Stages one row while advancing a statement-local heap cursor. Pages before the cursor were already proven full and cannot gain space during an insert-only batch, so each heap page is visited only a bounded number of times.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `encodedRow` | `dynamic` | — |  |
| `cursor` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L234)

<a id="function-function-minisql-executor-dml-stageupdate-function-stageupdate-pagetransaction-file-table-reference-encodedrow-src-minisql-executor-dml-ml-1779609644"></a>
### stageUpdate

```ml
function stageUpdate(pageTransaction, file, table, reference, encodedRow)
```

Implements stage update for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `reference` | `dynamic` | — |  |
| `encodedRow` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L302)

<a id="function-function-minisql-executor-dml-storagerow-function-storagerow-rowschema-table-sqlvalues-file-ownerid-src-minisql-executor-dml-ml-1691746571"></a>
### storageRow

```ml
function storageRow(rowSchema, table, sqlValues, file, ownerId)
```

Implements storage row for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `sqlValues` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L185)

<a id="function-function-minisql-executor-dml-tableschemastate-function-tableschemastate-database-table-src-minisql-executor-dml-ml-716044179"></a>
### tableSchemaState

```ml
function tableSchemaState(database, table)
```

Implements table schema state for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L321)

<a id="function-function-minisql-executor-dml-targetmilestone-function-targetmilestone-src-minisql-executor-dml-ml-2010450604"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2445)

<a id="constant-constant-minisql-executor-dml-transaction-state-const-transaction-state-9011-src-minisql-executor-dml-ml-860463038"></a>
### TRANSACTION_STATE

```ml
const TRANSACTION_STATE = 9011
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L39)

<a id="function-function-minisql-executor-dml-truncate-function-truncate-database-sessionid-bound-pagetransaction-src-minisql-executor-dml-ml-1652057047"></a>
### truncate

```ml
function truncate(database, sessionId, bound, pageTransaction)
```

Implements truncate for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1002)

<a id="constant-constant-minisql-executor-dml-type-mismatch-const-type-mismatch-9017-src-minisql-executor-dml-ml-1967723360"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L43)

<a id="function-function-minisql-executor-dml-uniqueconstraints-function-uniqueconstraints-database-table-src-minisql-executor-dml-ml-309730813"></a>
### uniqueConstraints

```ml
function uniqueConstraints(database, table)
```

Implements unique constraints for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L781)

<a id="constant-constant-minisql-executor-dml-unsupported-sql-const-unsupported-sql-9025-src-minisql-executor-dml-ml-1214782421"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L47)

<a id="function-function-minisql-executor-dml-update-function-update-database-sessionid-bound-pagetransaction-src-minisql-executor-dml-ml-629996283"></a>
### update

```ml
function update(database, sessionId, bound, pageTransaction)
```

Implements update for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L949)

<a id="function-function-minisql-executor-dml-updateinner-function-updateinner-database-sessionid-bound-pagetransaction-file-src-minisql-executor-dml-ml-900909655"></a>
### updateInner

```ml
function updateInner(database, sessionId, bound, pageTransaction, file)
```

Implements update inner for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `sessionId` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L909)

<a id="function-function-minisql-executor-dml-vacuum-function-vacuum-database-tablename-src-minisql-executor-dml-ml-326428534"></a>
### vacuum

```ml
function vacuum(database, tableName)
```

Implements vacuum for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2385)

<a id="function-function-minisql-executor-dml-vacuumstoragevalues-function-vacuumstoragevalues-heap-table-sqlvalues-ownerid-src-minisql-executor-dml-ml-969837900"></a>
### vacuumStorageValues

```ml
function vacuumStorageValues(heap, table, sqlValues, ownerId)
```

Implements vacuum storage values for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `sqlValues` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2223)

<a id="function-function-minisql-executor-dml-vacuumtable-function-vacuumtable-database-table-src-minisql-executor-dml-ml-1377199453"></a>
### vacuumTable

```ml
function vacuumTable(database, table)
```

Implements vacuum table for this module. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2361)

<a id="function-function-minisql-executor-dml-validatecheck-function-validatecheck-table-constraint-row-src-minisql-executor-dml-ml-802313877"></a>
### validateCheck

```ml
function validateCheck(table, constraint, row)
```

Validates check using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L506)

<a id="function-function-minisql-executor-dml-validatedeletereferences-function-validatedeletereferences-database-table-row-pagetransaction-file-src-minisql-executor-dml-ml-1466109574"></a>
### validateDeleteReferences

```ml
function validateDeleteReferences(database, table, row, pageTransaction, file)
```

Validates delete references using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L733)

<a id="function-function-minisql-executor-dml-validateexistingconstraint-function-validateexistingconstraint-database-bound-src-minisql-executor-dml-ml-781926743"></a>
### validateExistingConstraint

```ml
function validateExistingConstraint(database, bound)
```

Validates existing constraint using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L692)

<a id="function-function-minisql-executor-dml-validateforeignkey-function-validateforeignkey-database-table-constraint-row-pagetransaction-file-src-minisql-executor-dml-ml-423621895"></a>
### validateForeignKey

```ml
function validateForeignKey(database, table, constraint, row, pageTransaction, file)
```

Validates foreign key using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L547)

<a id="function-function-minisql-executor-dml-validateindexentryvalueshape-function-validateindexentryvalueshape-constraint-encoded-src-minisql-executor-dml-ml-592518047"></a>
### validateIndexEntryValueShape

```ml
function validateIndexEntryValueShape(constraint, encoded)
```

Validates the leaf-value shape before a heap-backed scan consumes only its row-reference prefix. Full payload decoding remains exclusive to index-only scans, while ordinary legacy values still require an exact 12-byte length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `constraint` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1247)

<a id="function-function-minisql-executor-dml-validaterow-function-validaterow-database-table-row-pagetransaction-excludedreference-file-src-minisql-executor-dml-ml-1099341395"></a>
### validateRow

```ml
function validateRow(database, table, row, pageTransaction, excludedReference, file)
```

Validates row using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `excludedReference` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L569)

<a id="function-function-minisql-executor-dml-validateunique-function-validateunique-database-table-constraint-row-pagetransaction-excludedreference-file-src-minisql-executor-dml-ml-2067003224"></a>
### validateUnique

```ml
function validateUnique(database, table, constraint, row, pageTransaction, excludedReference, file)
```

Validates unique using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `row` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `excludedReference` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L528)

<a id="function-function-minisql-executor-dml-validateuniquebatch-function-validateuniquebatch-database-table-rows-pagetransaction-file-src-minisql-executor-dml-ml-251254079"></a>
### validateUniqueBatch

```ml
function validateUniqueBatch(database, table, rows, pageTransaction, file)
```

Validates all unique keys for a statement from one stable table snapshot. Precomputed keys remove the repeated full heap scan previously performed for every inserted row while retaining SQL NULL and primary-key semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L592)

<a id="function-function-minisql-executor-dml-verifyallindexes-function-verifyallindexes-database-src-minisql-executor-dml-ml-1339064481"></a>
### verifyAllIndexes

```ml
function verifyAllIndexes(database)
```

Verifies all indexes using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1622)

<a id="function-function-minisql-executor-dml-verifyindex-function-verifyindex-database-table-constraint-src-minisql-executor-dml-ml-687328344"></a>
### verifyIndex

```ml
function verifyIndex(database, table, constraint)
```

Verifies one index while guaranteeing that both read-only handles are closed on comparison failures. B+ tree open already performs the streaming structural audit, and the explicit call documents that integrity is part of this API.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1604)

<a id="function-function-minisql-executor-dml-verifyindexstreaming-function-verifyindexstreaming-database-table-constraint-tree-reader-src-minisql-executor-dml-ml-125543123"></a>
### verifyIndexStreaming

```ml
function verifyIndexStreaming(database, table, constraint, tree, reader)
```

Compares one derived index with the heap through forward-only row reads and logarithmic B+ tree membership probes. Count equality plus the presence of every unique row-reference entry proves that the tree has neither missing nor additional entries, without retaining either complete collection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `constraint` | `dynamic` | — |  |
| `tree` | `dynamic` | — |  |
| `reader` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1568)

<a id="function-function-minisql-executor-dml-visiblepage-function-visiblepage-pagetransaction-file-tableid-pagenumber-src-minisql-executor-dml-ml-1079008686"></a>
### visiblePage

```ml
function visiblePage(pageTransaction, file, tableId, pageNumber)
```

Implements visible page for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageTransaction` | `dynamic` | — |  |
| `file` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L117)

<a id="function-function-minisql-executor-dml-writepublicationbatch-function-writepublicationbatch-file-firstpagenumber-images-src-minisql-executor-dml-ml-723910868"></a>
### writePublicationBatch

```ml
function writePublicationBatch(file, firstPageNumber, images)
```

Writes one consecutive publication batch. Keeping batches below 512 KiB amortizes Win32 seek/write calls without allowing a large transaction to duplicate an unbounded number of committed page images.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `firstPageNumber` | `dynamic` | — |  |
| `images` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L1057)

<a id="function-function-minisql-executor-dml-writerowstoheap-function-writerowstoheap-path-pagesize-databaseid-table-rows-src-minisql-executor-dml-ml-1437275314"></a>
### writeRowsToHeap

```ml
function writeRowsToHeap(path, pageSize, databaseId, table, rows)
```

Writes rows to heap using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/dml.ml#L2246)
