# `src/minisql/catalog/schema_history.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.catalog.schema_history`](Package-minisql-catalog-schema-history-840777387.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/binder.ml` as `binder` → [src/minisql/sql/binder.ml](File-src-minisql-sql-binder-ml-1729118960.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)
- `minisql/storage/btree.ml` as `btree` → [src/minisql/storage/btree.ml](File-src-minisql-storage-btree-ml-1474397187.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)
- `minisql/storage/heap_file.ml` as `heap_file` → [src/minisql/storage/heap_file.ml](File-src-minisql-storage-heap-file-ml-1771906446.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)

## Declarations

<a id="constant-constant-minisql-catalog-schema-history-action-alter-table-const-action-alter-table-4-src-minisql-catalog-schema-history-ml-696280563"></a>
### ACTION_ALTER_TABLE

```ml
const ACTION_ALTER_TABLE = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L59)

<a id="constant-constant-minisql-catalog-schema-history-action-create-index-const-action-create-index-2-src-minisql-catalog-schema-history-ml-1907281383"></a>
### ACTION_CREATE_INDEX

```ml
const ACTION_CREATE_INDEX = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L57)

<a id="constant-constant-minisql-catalog-schema-history-action-create-sequence-const-action-create-sequence-7-src-minisql-catalog-schema-history-ml-369253736"></a>
### ACTION_CREATE_SEQUENCE

```ml
const ACTION_CREATE_SEQUENCE = 7
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L62)

<a id="constant-constant-minisql-catalog-schema-history-action-create-table-const-action-create-table-1-src-minisql-catalog-schema-history-ml-1827847154"></a>
### ACTION_CREATE_TABLE

```ml
const ACTION_CREATE_TABLE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L56)

<a id="constant-constant-minisql-catalog-schema-history-action-create-trigger-const-action-create-trigger-9-src-minisql-catalog-schema-history-ml-363802594"></a>
### ACTION_CREATE_TRIGGER

```ml
const ACTION_CREATE_TRIGGER = 9
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L64)

<a id="constant-constant-minisql-catalog-schema-history-action-create-view-const-action-create-view-5-src-minisql-catalog-schema-history-ml-1569238698"></a>
### ACTION_CREATE_VIEW

```ml
const ACTION_CREATE_VIEW = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L60)

<a id="constant-constant-minisql-catalog-schema-history-action-drop-sequence-const-action-drop-sequence-8-src-minisql-catalog-schema-history-ml-1949615451"></a>
### ACTION_DROP_SEQUENCE

```ml
const ACTION_DROP_SEQUENCE = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L63)

<a id="constant-constant-minisql-catalog-schema-history-action-drop-table-const-action-drop-table-3-src-minisql-catalog-schema-history-ml-1405572232"></a>
### ACTION_DROP_TABLE

```ml
const ACTION_DROP_TABLE = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L58)

<a id="constant-constant-minisql-catalog-schema-history-action-drop-trigger-const-action-drop-trigger-10-src-minisql-catalog-schema-history-ml-171001846"></a>
### ACTION_DROP_TRIGGER

```ml
const ACTION_DROP_TRIGGER = 10
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L65)

<a id="constant-constant-minisql-catalog-schema-history-action-drop-view-const-action-drop-view-6-src-minisql-catalog-schema-history-ml-1187514445"></a>
### ACTION_DROP_VIEW

```ml
const ACTION_DROP_VIEW = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L61)

<a id="function-function-minisql-catalog-schema-history-advanceschemaversion-function-advanceschemaversion-table-tableschemavalue-src-minisql-catalog-schema-history-ml-240066914"></a>
### advanceSchemaVersion

```ml
function advanceSchemaVersion(table, tableSchemaValue)
```

Advances the schema generation shared by catalog metadata and schema rules.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | Mutable catalog table whose schema version advances. |
| `tableSchemaValue` | `dynamic` | — | Mutable persisted schema rules for the same table. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1117)

<a id="function-function-minisql-catalog-schema-history-allocateid-function-allocateid-preparedmetadata-src-minisql-catalog-schema-history-ml-635539272"></a>
### allocateId

```ml
function allocateId(preparedMetadata)
```

Allocates the id. Inputs: `preparedMetadata`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `preparedMetadata` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L889)

<a id="function-function-minisql-catalog-schema-history-appendconstraint-function-appendconstraint-preparedmetadata-tablename-tableschemavalue-value-src-minisql-catalog-schema-history-ml-589798664"></a>
### appendConstraint

```ml
function appendConstraint(preparedMetadata, tableName, tableSchemaValue, value)
```

Appends the constraint. Inputs: `preparedMetadata`, `tableName`, `tableSchemaValue`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `preparedMetadata` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |
| `tableSchemaValue` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L935)

<a id="function-function-minisql-catalog-schema-history-appendextensionvalue-function-appendextensionvalue-values-value-src-minisql-catalog-schema-history-ml-1830544303"></a>
### appendExtensionValue

```ml
function appendExtensionValue(values, value)
```

Appends the extension value. Inputs: `values`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2130)

<a id="function-function-minisql-catalog-schema-history-applyalteraddcolumn-function-applyalteraddcolumn-prepared-table-tableschemavalue-statement-bound-src-minisql-catalog-schema-history-ml-622536432"></a>
### applyAlterAddColumn

```ml
function applyAlterAddColumn(prepared, table, tableSchemaValue, statement, bound)
```

Applies ALTER TABLE ADD COLUMN without mixing its invariants with other DDL actions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `table` | `dynamic` | — | Mutable catalog table receiving the new column. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed ALTER TABLE statement. |
| `bound` | `dynamic` | — | Bound type and expression information for the statement. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1129)

<a id="function-function-minisql-catalog-schema-history-applyalteraddconstraint-function-applyalteraddconstraint-prepared-databasepath-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-1313811038"></a>
### applyAlterAddConstraint

```ml
function applyAlterAddConstraint(prepared, databasePath, table, tableSchemaValue, statement)
```

Adds one table constraint and schedules any physical index it owns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `databasePath` | `dynamic` | — | Database directory used for new backing files. |
| `table` | `dynamic` | — | Mutable catalog table receiving the constraint. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed ADD CONSTRAINT action. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1233)

<a id="function-function-minisql-catalog-schema-history-applyalterdefault-function-applyalterdefault-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-1761557673"></a>
### applyAlterDefault

```ml
function applyAlterDefault(table, tableSchemaValue, statement)
```

Applies SET/DROP DEFAULT while preserving identity-column ownership.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | Catalog table used to validate the target column. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed default-changing action. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1357)

<a id="function-function-minisql-catalog-schema-history-applyalterdropcolumn-function-applyalterdropcolumn-prepared-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-1224104796"></a>
### applyAlterDropColumn

```ml
function applyAlterDropColumn(prepared, table, tableSchemaValue, statement)
```

Applies a metadata-only column drop after dependency and ownership validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `table` | `dynamic` | — | Mutable catalog table losing the column. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed DROP COLUMN action. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1319)

<a id="function-function-minisql-catalog-schema-history-applyalterdropconstraint-function-applyalterdropconstraint-prepared-databasepath-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-427513902"></a>
### applyAlterDropConstraint

```ml
function applyAlterDropConstraint(prepared, databasePath, table, tableSchemaValue, statement)
```

Removes a constraint only after proving that no foreign key depends on it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `databasePath` | `dynamic` | — | Database directory containing backing files. |
| `table` | `dynamic` | — | Mutable catalog table losing the constraint. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed DROP CONSTRAINT action. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1261)

<a id="function-function-minisql-catalog-schema-history-applyalternullability-function-applyalternullability-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-1326797977"></a>
### applyAlterNullability

```ml
function applyAlterNullability(table, tableSchemaValue, statement)
```

Applies SET/DROP NOT NULL to one existing column.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — | Mutable catalog table containing the target column. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed nullability-changing action. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1379)

<a id="function-function-minisql-catalog-schema-history-applyalterrenamecolumn-function-applyalterrenamecolumn-prepared-table-tableschemavalue-statement-src-minisql-catalog-schema-history-ml-100829268"></a>
### applyAlterRenameColumn

```ml
function applyAlterRenameColumn(prepared, table, tableSchemaValue, statement)
```

Rewrites every catalog dependency affected by an ALTER TABLE RENAME COLUMN.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `table` | `dynamic` | — | Mutable catalog table containing the renamed column. |
| `tableSchemaValue` | `dynamic` | — | Mutable schema rules associated with the table. |
| `statement` | `dynamic` | — | Parsed rename-column action and names. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1150)

<a id="function-function-minisql-catalog-schema-history-applyalterrenametable-function-applyalterrenametable-prepared-table-statement-src-minisql-catalog-schema-history-ml-1092372472"></a>
### applyAlterRenameTable

```ml
function applyAlterRenameTable(prepared, table, statement)
```

Applies a table rename and updates incoming foreign-key references.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `table` | `dynamic` | — | Mutable catalog table being renamed. |
| `statement` | `dynamic` | — | Parsed rename-table action and destination name. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1195)

- [minisql.catalog.schema_history.BackupPlan](Type-minisql-catalog-schema-history-backupplan-347317938.md) — struct
<a id="function-function-minisql-catalog-schema-history-begin-function-begin-database-src-minisql-catalog-schema-history-ml-1827025393"></a>
### begin

```ml
function begin(database)
```

Begins the requested value. Inputs: `database`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1582)

<a id="function-function-minisql-catalog-schema-history-beginmaintenance-function-beginmaintenance-databasepath-originalpath-temporarypath-backuppath-src-minisql-catalog-schema-history-ml-1608442015"></a>
### beginMaintenance

```ml
function beginMaintenance(databasePath, originalPath, temporaryPath, backupPath)
```

Begins the maintenance. Inputs: `databasePath`, `originalPath`, `temporaryPath`, `backupPath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `originalPath` | `dynamic` | — |  |
| `temporaryPath` | `dynamic` | — |  |
| `backupPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1775)

<a id="constant-constant-minisql-catalog-schema-history-binding-error-const-binding-error-9020-src-minisql-catalog-schema-history-ml-1096633624"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L35)

<a id="function-function-minisql-catalog-schema-history-buildaltertable-function-buildaltertable-prepared-databasepath-bound-src-minisql-catalog-schema-history-ml-532175697"></a>
### buildAlterTable

```ml
function buildAlterTable(prepared, databasePath, bound)
```

Dispatches ALTER TABLE to one action-specific handler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state being updated. |
| `databasePath` | `dynamic` | — | Database directory used for physical schema changes. |
| `bound` | `dynamic` | — | Bound ALTER TABLE statement and resolved table metadata. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1390)

<a id="function-function-minisql-catalog-schema-history-buildcreateindex-function-buildcreateindex-prepared-databasepath-bound-src-minisql-catalog-schema-history-ml-1036460549"></a>
### buildCreateIndex

```ml
function buildCreateIndex(prepared, databasePath, bound)
```

Builds the create index. Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1516)

<a id="function-function-minisql-catalog-schema-history-buildcreatetable-function-buildcreatetable-prepared-databasepath-bound-src-minisql-catalog-schema-history-ml-273960813"></a>
### buildCreateTable

```ml
function buildCreateTable(prepared, databasePath, bound)
```

Builds the create table. Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1408)

<a id="function-function-minisql-catalog-schema-history-builddroptable-function-builddroptable-prepared-databasepath-bound-src-minisql-catalog-schema-history-ml-1771371165"></a>
### buildDropTable

```ml
function buildDropTable(prepared, databasePath, bound)
```

Builds the drop table. Inputs: `prepared`, `databasePath`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1549)

<a id="function-function-minisql-catalog-schema-history-bytesequal-function-bytesequal-left-right-src-minisql-catalog-schema-history-ml-445735181"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L431)

<a id="function-function-minisql-catalog-schema-history-catalogtablebyid-function-catalogtablebyid-catalogstate-tableid-src-minisql-catalog-schema-history-ml-2058262789"></a>
### catalogTableById

```ml
function catalogTableById(catalogState, tableId)
```

Performs the catalog table by id operation for this module. Inputs: `catalogState`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `catalogState` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L946)

<a id="function-function-minisql-catalog-schema-history-cleanupcommitted-function-cleanupcommitted-prepared-databasepath-src-minisql-catalog-schema-history-ml-2121321125"></a>
### cleanupCommitted

```ml
function cleanupCommitted(prepared, databasePath)
```

Performs the cleanup committed operation for this module. Inputs: `prepared`, `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1917)

<a id="function-function-minisql-catalog-schema-history-clonecatalog-function-clonecatalog-value-src-minisql-catalog-schema-history-ml-516561281"></a>
### cloneCatalog

```ml
function cloneCatalog(value)
```

Clones the catalog. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L837)

<a id="function-function-minisql-catalog-schema-history-clonemetadata-function-clonemetadata-value-src-minisql-catalog-schema-history-ml-814097517"></a>
### cloneMetadata

```ml
function cloneMetadata(value)
```

Clones the metadata. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L831)

<a id="function-function-minisql-catalog-schema-history-clonestate-function-clonestate-value-src-minisql-catalog-schema-history-ml-195874509"></a>
### cloneState

```ml
function cloneState(value)
```

Clones the state. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L843)

<a id="constant-constant-minisql-catalog-schema-history-closed-handle-const-closed-handle-9008-src-minisql-catalog-schema-history-ml-871512706"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L32)

<a id="function-function-minisql-catalog-schema-history-columnexists-function-columnexists-table-name-src-minisql-catalog-schema-history-ml-1894755735"></a>
### columnExists

```ml
function columnExists(table, name)
```

Performs the column exists operation for this module. Inputs: `table`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L904)

<a id="function-function-minisql-catalog-schema-history-columnindexbyname-function-columnindexbyname-table-name-src-minisql-catalog-schema-history-ml-928178735"></a>
### columnIndexByName

```ml
function columnIndexByName(table, name)
```

Performs the column index by name operation for this module. Inputs: `table`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L955)

<a id="function-function-minisql-catalog-schema-history-columnrule-function-columnrule-columnname-defaultsql-identity-src-minisql-catalog-schema-history-ml-1788262704"></a>
### columnRule

```ml
function columnRule(columnName, defaultSql, identity)
```

Performs the column rule operation for this module. Inputs: `columnName`, `defaultSql`, `identity`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnName` | `dynamic` | — |  |
| `defaultSql` | `dynamic` | — |  |
| `identity` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L606)

- [minisql.catalog.schema_history.ColumnRule](Type-minisql-catalog-schema-history-columnrule-1709278571.md) — struct
<a id="function-function-minisql-catalog-schema-history-commit-function-commit-transaction-src-minisql-catalog-schema-history-ml-763934810"></a>
### commit

```ml
function commit(transaction)
```

Commits the requested value. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1996)

<a id="function-function-minisql-catalog-schema-history-commitinternal-function-commitinternal-transaction-stopphase-src-minisql-catalog-schema-history-ml-414010057"></a>
### commitInternal

```ml
function commitInternal(transaction, stopPhase)
```

Commits the internal. Inputs: `transaction`, `stopPhase`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `stopPhase` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1931)

<a id="function-function-minisql-catalog-schema-history-commitstoppingafter-function-commitstoppingafter-transaction-phase-src-minisql-catalog-schema-history-ml-2096578427"></a>
### commitStoppingAfter

```ml
function commitStoppingAfter(transaction, phase)
```

Commits the stopping after. Inputs: `transaction`, `phase`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `phase` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2002)

<a id="function-function-minisql-catalog-schema-history-componentname-function-componentname-src-minisql-catalog-schema-history-ml-664736376"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2633)

<a id="function-function-minisql-catalog-schema-history-constraint-function-constraint-name-kind-columns-expressionsql-referencetable-referencecolumns-ondelete-onupdate-indexid-indexname-src-minisql-catalog-schema-history-ml-49631237"></a>
### constraint

```ml
function constraint(name, kind, columns, expressionSql, referenceTable, referenceColumns, onDelete, onUpdate, indexId, indexName)
```

Performs the constraint operation for this module. Inputs: `name`, `kind`, `columns`, `expressionSql`, `referenceTable`, `referenceColumns`, `onDelete`, `onUpdate`, `indexId`, `indexName`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `columns` | `dynamic` | — |  |
| `expressionSql` | `dynamic` | — |  |
| `referenceTable` | `dynamic` | — |  |
| `referenceColumns` | `dynamic` | — |  |
| `onDelete` | `dynamic` | — |  |
| `onUpdate` | `dynamic` | — |  |
| `indexId` | `dynamic` | — |  |
| `indexName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L613)

<a id="constant-constant-minisql-catalog-schema-history-constraint-check-const-constraint-check-3-src-minisql-catalog-schema-history-ml-1977665818"></a>
### CONSTRAINT_CHECK

```ml
const CONSTRAINT_CHECK = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L52)

<a id="constant-constant-minisql-catalog-schema-history-constraint-foreign-key-const-constraint-foreign-key-4-src-minisql-catalog-schema-history-ml-1312147815"></a>
### CONSTRAINT_FOREIGN_KEY

```ml
const CONSTRAINT_FOREIGN_KEY = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L53)

<a id="constant-constant-minisql-catalog-schema-history-constraint-index-const-constraint-index-5-src-minisql-catalog-schema-history-ml-682014112"></a>
### CONSTRAINT_INDEX

```ml
const CONSTRAINT_INDEX = 5
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L54)

<a id="constant-constant-minisql-catalog-schema-history-constraint-primary-key-const-constraint-primary-key-1-src-minisql-catalog-schema-history-ml-808067456"></a>
### CONSTRAINT_PRIMARY_KEY

```ml
const CONSTRAINT_PRIMARY_KEY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L50)

<a id="constant-constant-minisql-catalog-schema-history-constraint-unique-const-constraint-unique-2-src-minisql-catalog-schema-history-ml-879364815"></a>
### CONSTRAINT_UNIQUE

```ml
const CONSTRAINT_UNIQUE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L51)

<a id="constant-constant-minisql-catalog-schema-history-constraint-violation-const-constraint-violation-9021-src-minisql-catalog-schema-history-ml-1173263779"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L36)

- [minisql.catalog.schema_history.ConstraintDefinition](Type-minisql-catalog-schema-history-constraintdefinition-1280359101.md) — struct
<a id="function-function-minisql-catalog-schema-history-constraintfromast-function-constraintfromast-prepared-table-tableschemavalue-source-src-minisql-catalog-schema-history-ml-834402698"></a>
### constraintFromAst

```ml
function constraintFromAst(prepared, table, tableSchemaValue, source)
```

Performs the constraint from ast operation for this module. Inputs: `prepared`, `table`, `tableSchemaValue`, `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |
| `tableSchemaValue` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1103)

<a id="function-function-minisql-catalog-schema-history-constraintnameexists-function-constraintnameexists-tableschemavalue-name-src-minisql-catalog-schema-history-ml-765994709"></a>
### constraintNameExists

```ml
function constraintNameExists(tableSchemaValue, name)
```

Performs the constraint name exists operation for this module. Inputs: `tableSchemaValue`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchemaValue` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1079)

<a id="function-function-minisql-catalog-schema-history-constraintsfor-function-constraintsfor-databasepath-databaseid-tableid-src-minisql-catalog-schema-history-ml-2077175127"></a>
### constraintsFor

```ml
function constraintsFor(databasePath, databaseId, tableId)
```

Performs the constraints for operation for this module. Inputs: `databasePath`, `databaseId`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2019)

<a id="function-function-minisql-catalog-schema-history-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-catalog-schema-history-ml-181565095"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Copies the exact. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L442)

<a id="constant-constant-minisql-catalog-schema-history-corrupt-data-const-corrupt-data-9004-src-minisql-catalog-schema-history-ml-1770692676"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L30)

- [minisql.catalog.schema_history.CreateFilePlan](Type-minisql-catalog-schema-history-createfileplan-647574662.md) — struct
<a id="function-function-minisql-catalog-schema-history-createplannedfiles-function-createplannedfiles-transaction-prepared-src-minisql-catalog-schema-history-ml-991839909"></a>
### createPlannedFiles

```ml
function createPlannedFiles(transaction, prepared)
```

Creates the planned files. Inputs: `transaction`, `prepared`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `prepared` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1887)

<a id="function-function-minisql-catalog-schema-history-createstate-function-createstate-databaseid-src-minisql-catalog-schema-history-ml-1742306546"></a>
### createState

```ml
function createState(databaseId)
```

Creates the state. Inputs: `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L553)

<a id="constant-constant-minisql-catalog-schema-history-ddl-state-const-ddl-state-9023-src-minisql-catalog-schema-history-ml-1800582437"></a>
### DDL_STATE

```ml
const DDL_STATE = 9023
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L37)

- [minisql.catalog.schema_history.DdlAction](Type-minisql-catalog-schema-history-ddlaction-125467819.md) — struct
- [minisql.catalog.schema_history.DdlJournal](Type-minisql-catalog-schema-history-ddljournal-1881557492.md) — struct
- [minisql.catalog.schema_history.DdlTransaction](Type-minisql-catalog-schema-history-ddltransaction-1711998007.md) — struct
<a id="function-function-minisql-catalog-schema-history-decode-function-decode-encoded-src-minisql-catalog-schema-history-ml-1411800884"></a>
### decode

```ml
function decode(encoded)
```

Keep the qualified public API schema_history.decode(...), while all internal calls use an unambiguous helper. MiniLang also has a builtin decode(bytes). Decodes the requested value. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L782)

- [minisql.catalog.schema_history.DecodedExtensionEntry](Type-minisql-catalog-schema-history-decodedextensionentry-1880168724.md) — struct
- [minisql.catalog.schema_history.DecodedString](Type-minisql-catalog-schema-history-decodedstring-1998070114.md) — struct
<a id="function-function-minisql-catalog-schema-history-decodeextensions-function-decodeextensions-encoded-databaseid-src-minisql-catalog-schema-history-ml-1020164368"></a>
### decodeExtensions

```ml
function decodeExtensions(encoded, databaseId)
```

Decodes the extensions. Inputs: `encoded`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2208)

<a id="function-function-minisql-catalog-schema-history-decodegeneratedextensionentry-function-decodegeneratedextensionentry-payload-offset-payloadlength-src-minisql-catalog-schema-history-ml-2042518695"></a>
### decodeGeneratedExtensionEntry

```ml
function decodeGeneratedExtensionEntry(payload, offset, payloadLength)
```

Decodes the generated extension entry. Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `payloadLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2178)

<a id="function-function-minisql-catalog-schema-history-decodejournal-function-decodejournal-encoded-src-minisql-catalog-schema-history-ml-734385418"></a>
### decodeJournal

```ml
function decodeJournal(encoded)
```

Decodes the journal. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1695)

<a id="function-function-minisql-catalog-schema-history-decodemaintenance-function-decodemaintenance-encoded-src-minisql-catalog-schema-history-ml-338720562"></a>
### decodeMaintenance

```ml
function decodeMaintenance(encoded)
```

Decodes the maintenance. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1753)

<a id="function-function-minisql-catalog-schema-history-decodenative-function-decodenative-words-operation-name-src-minisql-catalog-schema-history-ml-2054156915"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes the native. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L709)

<a id="function-function-minisql-catalog-schema-history-decodesequenceextensionentry-function-decodesequenceextensionentry-payload-offset-payloadlength-src-minisql-catalog-schema-history-ml-1944150447"></a>
### decodeSequenceExtensionEntry

```ml
function decodeSequenceExtensionEntry(payload, offset, payloadLength)
```

Decodes the sequence extension entry. Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `payloadLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2159)

<a id="function-function-minisql-catalog-schema-history-decodestate-function-decodestate-encoded-src-minisql-catalog-schema-history-ml-676852886"></a>
### decodeState

```ml
function decodeState(encoded)
```

Decodes the state. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L717)

<a id="function-function-minisql-catalog-schema-history-decodetriggerextensionentry-function-decodetriggerextensionentry-payload-offset-payloadlength-src-minisql-catalog-schema-history-ml-508686413"></a>
### decodeTriggerExtensionEntry

```ml
function decodeTriggerExtensionEntry(payload, offset, payloadLength)
```

Decodes the trigger extension entry. Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `payloadLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2191)

<a id="function-function-minisql-catalog-schema-history-decodeviewextensionentry-function-decodeviewextensionentry-payload-offset-payloadlength-src-minisql-catalog-schema-history-ml-2051589179"></a>
### decodeViewExtensionEntry

```ml
function decodeViewExtensionEntry(payload, offset, payloadLength)
```

Decodes the view extension entry. Inputs: `payload`, `offset`, `payloadLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `payloadLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2145)

<a id="function-function-minisql-catalog-schema-history-deleteifexists-function-deleteifexists-path-src-minisql-catalog-schema-history-ml-975983113"></a>
### deleteIfExists

```ml
function deleteIfExists(path)
```

Deletes the if exists. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1835)

<a id="function-function-minisql-catalog-schema-history-dropprocedure-function-dropprocedure-databasepath-databaseid-name-ifexists-src-minisql-catalog-schema-history-ml-1721012554"></a>
### dropProcedure

```ml
function dropProcedure(databasePath, databaseId, name, ifExists)
```

Drops a stored procedure without exposing its internal extension marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2490)

<a id="function-function-minisql-catalog-schema-history-dropschema-function-dropschema-databasepath-databaseid-name-ifexists-src-minisql-catalog-schema-history-ml-1904935178"></a>
### dropSchema

```ml
function dropSchema(databasePath, databaseId, name, ifExists)
```

Drops an empty user schema and rejects built-in or populated namespaces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2414)

<a id="function-function-minisql-catalog-schema-history-dropsequence-function-dropsequence-databasepath-databaseid-name-ifexists-src-minisql-catalog-schema-history-ml-447282826"></a>
### dropSequence

```ml
function dropSequence(databasePath, databaseId, name, ifExists)
```

Drops the sequence. Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2521)

<a id="function-function-minisql-catalog-schema-history-droptrigger-function-droptrigger-databasepath-databaseid-name-ifexists-src-minisql-catalog-schema-history-ml-156717852"></a>
### dropTrigger

```ml
function dropTrigger(databasePath, databaseId, name, ifExists)
```

Drops the trigger. Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2599)

<a id="function-function-minisql-catalog-schema-history-dropview-function-dropview-databasepath-databaseid-name-ifexists-src-minisql-catalog-schema-history-ml-667399654"></a>
### dropView

```ml
function dropView(databasePath, databaseId, name, ifExists)
```

Drops the view. Inputs: `databasePath`, `databaseId`, `name`, `ifExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2461)

<a id="function-function-minisql-catalog-schema-history-encode-function-encode-state-src-minisql-catalog-schema-history-ml-565610641"></a>
### encode

```ml
function encode(state)
```

Encodes the requested value. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L658)

<a id="function-function-minisql-catalog-schema-history-encodedconstraintsize-function-encodedconstraintsize-value-src-minisql-catalog-schema-history-ml-1166884589"></a>
### encodedConstraintSize

```ml
function encodedConstraintSize(value)
```

Encodes the d constraint size. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L639)

<a id="function-function-minisql-catalog-schema-history-encodedrulesize-function-encodedrulesize-rule-src-minisql-catalog-schema-history-ml-338488940"></a>
### encodedRuleSize

```ml
function encodedRuleSize(rule)
```

Encodes the d rule size. Inputs: `rule`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rule` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L633)

<a id="function-function-minisql-catalog-schema-history-encodedtablesize-function-encodedtablesize-table-src-minisql-catalog-schema-history-ml-1429407058"></a>
### encodedTableSize

```ml
function encodedTableSize(table)
```

Encodes the d table size. Inputs: `table`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L645)

<a id="function-function-minisql-catalog-schema-history-encodeextensions-function-encodeextensions-state-src-minisql-catalog-schema-history-ml-751778581"></a>
### encodeExtensions

```ml
function encodeExtensions(state)
```

Encodes the extensions. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2051)

<a id="function-function-minisql-catalog-schema-history-encodejournal-function-encodejournal-value-src-minisql-catalog-schema-history-ml-1359877259"></a>
### encodeJournal

```ml
function encodeJournal(value)
```

Encodes the journal. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1667)

<a id="function-function-minisql-catalog-schema-history-encodemaintenance-function-encodemaintenance-value-src-minisql-catalog-schema-history-ml-17575403"></a>
### encodeMaintenance

```ml
function encodeMaintenance(value)
```

Encodes the maintenance. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1737)

<a id="function-function-minisql-catalog-schema-history-ensurepreparedtableschema-function-ensurepreparedtableschema-prepared-table-src-minisql-catalog-schema-history-ml-1718250003"></a>
### ensurePreparedTableSchema

```ml
function ensurePreparedTableSchema(prepared, table)
```

Ensures the prepared table schema. Inputs: `prepared`, `table`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |
| `table` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1088)

<a id="function-function-minisql-catalog-schema-history-expressionreferencescolumn-function-expressionreferencescolumn-expression-columnname-src-minisql-catalog-schema-history-ml-530100237"></a>
### expressionReferencesColumn

```ml
function expressionReferencesColumn(expression, columnName)
```

Reports whether a persisted row expression refers to one unqualified column.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1037)

<a id="function-function-minisql-catalog-schema-history-expressionsqlreferencescolumn-function-expressionsqlreferencescolumn-sqltext-columnname-src-minisql-catalog-schema-history-ml-1069560452"></a>
### expressionSqlReferencesColumn

```ml
function expressionSqlReferencesColumn(sqlText, columnName)
```

Parses canonical SQL before checking a partial-index column dependency.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1052)

<a id="constant-constant-minisql-catalog-schema-history-extension-kind-const-extension-kind-43-src-minisql-catalog-schema-history-ml-1328457636"></a>
### EXTENSION_KIND

```ml
const EXTENSION_KIND = 43
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L44)

<a id="function-function-minisql-catalog-schema-history-extensionmagic-function-extensionmagic-src-minisql-catalog-schema-history-ml-1969914444"></a>
### extensionMagic

```ml
function extensionMagic()
```

Performs the extension magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L347)

<a id="function-function-minisql-catalog-schema-history-extensionpath-function-extensionpath-databasepath-src-minisql-catalog-schema-history-ml-1738073634"></a>
### extensionPath

```ml
function extensionPath(databasePath)
```

Performs the extension path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L371)

<a id="function-function-minisql-catalog-schema-history-extensionrecordsize-function-extensionrecordsize-state-src-minisql-catalog-schema-history-ml-1549843543"></a>
### extensionRecordSize

```ml
function extensionRecordSize(state)
```

Performs the extension record size operation for this module. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2032)

<a id="function-function-minisql-catalog-schema-history-fail-function-fail-code-operation-message-src-minisql-catalog-schema-history-ml-1927139827"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates the module's structured error with operation context. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L323)

<a id="function-function-minisql-catalog-schema-history-findconstraint-function-findconstraint-tableschemavalue-name-src-minisql-catalog-schema-history-ml-1481441665"></a>
### findConstraint

```ml
function findConstraint(tableSchemaValue, name)
```

Finds the constraint. Inputs: `tableSchemaValue`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchemaValue` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L821)

<a id="function-function-minisql-catalog-schema-history-findprocedure-function-findprocedure-state-name-src-minisql-catalog-schema-history-ml-116056544"></a>
### findProcedure

```ml
function findProcedure(state, name)
```

Finds a persisted stored procedure by its SQL-visible name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2480)

<a id="function-function-minisql-catalog-schema-history-findsequence-function-findsequence-state-name-src-minisql-catalog-schema-history-ml-132602032"></a>
### findSequence

```ml
function findSequence(state, name)
```

Finds the sequence. Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2496)

<a id="function-function-minisql-catalog-schema-history-findtableschema-function-findtableschema-state-tableid-src-minisql-catalog-schema-history-ml-2038658554"></a>
### findTableSchema

```ml
function findTableSchema(state, tableId)
```

Finds the table schema. Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L811)

<a id="function-function-minisql-catalog-schema-history-findview-function-findview-state-name-src-minisql-catalog-schema-history-ml-705498328"></a>
### findView

```ml
function findView(state, name)
```

Finds the view. Inputs: `state`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2311)

<a id="function-function-minisql-catalog-schema-history-finishmaintenance-function-finishmaintenance-databasepath-value-src-minisql-catalog-schema-history-ml-926727479"></a>
### finishMaintenance

```ml
function finishMaintenance(databasePath, value)
```

Performs the finish maintenance operation for this module. Inputs: `databasePath`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1793)

<a id="constant-constant-minisql-catalog-schema-history-format-version-const-format-version-1-src-minisql-catalog-schema-history-ml-912566412"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L40)

<a id="function-function-minisql-catalog-schema-history-generatedcolumndefinition-function-generatedcolumndefinition-tableid-columnname-expressionsql-stored-src-minisql-catalog-schema-history-ml-38611347"></a>
### generatedColumnDefinition

```ml
function generatedColumnDefinition(tableId, columnName, expressionSql, stored)
```

Performs the generated column definition operation for this module. Inputs: `tableId`, `columnName`, `expressionSql`, `stored`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |
| `columnName` | `dynamic` | — |  |
| `expressionSql` | `dynamic` | — |  |
| `stored` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L592)

- [minisql.catalog.schema_history.GeneratedColumnDefinition](Type-minisql-catalog-schema-history-generatedcolumndefinition-318283151.md) — struct
<a id="function-function-minisql-catalog-schema-history-generatedconstraintname-function-generatedconstraintname-prefix-tablename-suffix-src-minisql-catalog-schema-history-ml-1293576214"></a>
### generatedConstraintName

```ml
function generatedConstraintName(prefix, tableName, suffix)
```

Performs the generated constraint name operation for this module. Inputs: `prefix`, `tableName`, `suffix`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — |  |
| `tableName` | `dynamic` | — |  |
| `suffix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L898)

<a id="function-function-minisql-catalog-schema-history-generatedfortable-function-generatedfortable-state-tableid-src-minisql-catalog-schema-history-ml-3719838"></a>
### generatedForTable

```ml
function generatedForTable(state, tableId)
```

Performs the generated for table operation for this module. Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2562)

<a id="function-function-minisql-catalog-schema-history-indexexpressionkey-function-indexexpressionkey-sqltext-src-minisql-catalog-schema-history-ml-1101182671"></a>
### indexExpressionKey

```ml
function indexExpressionKey(sqlText)
```

Encodes a canonical expression in the backwards-compatible index key array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L982)

<a id="function-function-minisql-catalog-schema-history-indexexpressionprefix-function-indexexpressionprefix-src-minisql-catalog-schema-history-ml-1241826704"></a>
### indexExpressionPrefix

```ml
function indexExpressionPrefix()
```

Returns a binary catalog marker that cannot collide with a SQL identifier accepted from normal text input. Keeping the marker out of the schema format itself preserves v1 compatibility for older column-only index histories.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L977)

<a id="function-function-minisql-catalog-schema-history-indexexpressionsql-function-indexexpressionsql-value-src-minisql-catalog-schema-history-ml-1094178581"></a>
### indexExpressionSql

```ml
function indexExpressionSql(value)
```

Returns canonical SQL from an expression key or an empty string otherwise.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L995)

<a id="function-function-minisql-catalog-schema-history-indexfilepath-function-indexfilepath-databasepath-indexid-src-minisql-catalog-schema-history-ml-628284249"></a>
### indexFilePath

```ml
function indexFilePath(databasePath, indexId)
```

Performs the index file path operation for this module. Inputs: `databasePath`, `indexId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `indexId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L377)

<a id="function-function-minisql-catalog-schema-history-indexkeydisplay-function-indexkeydisplay-value-src-minisql-catalog-schema-history-ml-881995883"></a>
### indexKeyDisplay

```ml
function indexKeyDisplay(value)
```

Returns the user-facing key text without the internal compatibility marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1002)

<a id="constant-constant-minisql-catalog-schema-history-invalid-argument-const-invalid-argument-9001-src-minisql-catalog-schema-history-ml-142196997"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Durable schema/constraint sidecar and transactional DDL journal.

The M8 bootstrap catalog intentionally remains format v1. M14 adds richer
schema information in catalog/schema.history, protected by a CRC envelope.
DDL uses a before-image journal. Recovery before catalog.openDatabase either
restores the old metadata (PREPARED) or keeps the published generation
(COMMITTED). This allows CREATE TABLE/INDEX and DROP TABLE to be atomic across
catalog metadata and physical files without changing accepted M8 formats.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L28)

<a id="constant-constant-minisql-catalog-schema-history-io-failure-const-io-failure-9005-src-minisql-catalog-schema-history-ml-769628925"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L31)

<a id="function-function-minisql-catalog-schema-history-isconstraintdefinition-function-isconstraintdefinition-value-src-minisql-catalog-schema-history-ml-1245699325"></a>
### isConstraintDefinition

```ml
function isConstraintDefinition(value)
```

Evaluates whether the supplied input satisfies the constraint definition predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L389)

<a id="function-function-minisql-catalog-schema-history-isddltransaction-function-isddltransaction-value-src-minisql-catalog-schema-history-ml-1315201869"></a>
### isDdlTransaction

```ml
function isDdlTransaction(value)
```

Evaluates whether the supplied input satisfies the ddl transaction predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L401)

<a id="function-function-minisql-catalog-schema-history-isgeneratedcolumndefinition-function-isgeneratedcolumndefinition-value-src-minisql-catalog-schema-history-ml-1967682737"></a>
### isGeneratedColumnDefinition

```ml
function isGeneratedColumnDefinition(value)
```

Evaluates whether the supplied input satisfies the generated column definition predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L419)

<a id="function-function-minisql-catalog-schema-history-isimplemented-function-isimplemented-src-minisql-catalog-schema-history-ml-689189792"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2645)

<a id="function-function-minisql-catalog-schema-history-isindexexpressionkey-function-isindexexpressionkey-value-src-minisql-catalog-schema-history-ml-269773501"></a>
### isIndexExpressionKey

```ml
function isIndexExpressionKey(value)
```

Reports whether one persisted index key is a canonical expression marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L988)

<a id="function-function-minisql-catalog-schema-history-isinternalextensionviewname-function-isinternalextensionviewname-name-src-minisql-catalog-schema-history-ml-1984832653"></a>
### isInternalExtensionViewName

```ml
function isInternalExtensionViewName(name)
```

Returns whether a view extension entry is internal rather than SQL-visible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2359)

<a id="function-function-minisql-catalog-schema-history-ismaintenancejournal-function-ismaintenancejournal-value-src-minisql-catalog-schema-history-ml-1031052765"></a>
### isMaintenanceJournal

```ml
function isMaintenanceJournal(value)
```

Evaluates whether the supplied input satisfies the maintenance journal predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1731)

<a id="function-function-minisql-catalog-schema-history-isproceduremarkername-function-isproceduremarkername-name-src-minisql-catalog-schema-history-ml-1918470261"></a>
### isProcedureMarkerName

```ml
function isProcedureMarkerName(name)
```

Returns whether a view extension entry stores procedure metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2340)

<a id="function-function-minisql-catalog-schema-history-isschemamarkername-function-isschemamarkername-name-src-minisql-catalog-schema-history-ml-2111421029"></a>
### isSchemaMarkerName

```ml
function isSchemaMarkerName(name)
```

Returns whether a persisted view entry is an internal schema marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2324)

<a id="function-function-minisql-catalog-schema-history-isschemastate-function-isschemastate-value-src-minisql-catalog-schema-history-ml-379350653"></a>
### isSchemaState

```ml
function isSchemaState(value)
```

Evaluates whether the supplied input satisfies the schema state predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L383)

<a id="function-function-minisql-catalog-schema-history-issequencedefinition-function-issequencedefinition-value-src-minisql-catalog-schema-history-ml-2068515321"></a>
### isSequenceDefinition

```ml
function isSequenceDefinition(value)
```

Evaluates whether the supplied input satisfies the sequence definition predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L413)

<a id="function-function-minisql-catalog-schema-history-istableschema-function-istableschema-value-src-minisql-catalog-schema-history-ml-1706714715"></a>
### isTableSchema

```ml
function isTableSchema(value)
```

Evaluates whether the supplied input satisfies the table schema predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L395)

<a id="function-function-minisql-catalog-schema-history-istriggerdefinition-function-istriggerdefinition-value-src-minisql-catalog-schema-history-ml-2128594211"></a>
### isTriggerDefinition

```ml
function isTriggerDefinition(value)
```

Evaluates whether the supplied input satisfies the trigger definition predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L425)

<a id="function-function-minisql-catalog-schema-history-isviewdefinition-function-isviewdefinition-value-src-minisql-catalog-schema-history-ml-345997677"></a>
### isViewDefinition

```ml
function isViewDefinition(value)
```

Evaluates whether the supplied input satisfies the view definition predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L407)

<a id="constant-constant-minisql-catalog-schema-history-journal-committed-const-journal-committed-2-src-minisql-catalog-schema-history-ml-675296683"></a>
### JOURNAL_COMMITTED

```ml
const JOURNAL_COMMITTED = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L46)

<a id="constant-constant-minisql-catalog-schema-history-journal-kind-const-journal-kind-41-src-minisql-catalog-schema-history-ml-1156185174"></a>
### JOURNAL_KIND

```ml
const JOURNAL_KIND = 41
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L42)

<a id="constant-constant-minisql-catalog-schema-history-journal-prepared-const-journal-prepared-1-src-minisql-catalog-schema-history-ml-1872826398"></a>
### JOURNAL_PREPARED

```ml
const JOURNAL_PREPARED = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L45)

<a id="function-function-minisql-catalog-schema-history-journalarraysize-function-journalarraysize-values-src-minisql-catalog-schema-history-ml-1785157758"></a>
### journalArraySize

```ml
function journalArraySize(values)
```

Performs the journal array size operation for this module. Inputs: `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1657)

<a id="function-function-minisql-catalog-schema-history-journalmagic-function-journalmagic-src-minisql-catalog-schema-history-ml-1754591632"></a>
### journalMagic

```ml
function journalMagic()
```

Returns a fresh copy of the DDL-journal magic bytes. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L335)

<a id="function-function-minisql-catalog-schema-history-journalpath-function-journalpath-databasepath-src-minisql-catalog-schema-history-ml-1605021578"></a>
### journalPath

```ml
function journalPath(databasePath)
```

Performs the journal path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L359)

<a id="function-function-minisql-catalog-schema-history-loadextensionsinto-function-loadextensionsinto-databasepath-state-src-minisql-catalog-schema-history-ml-136851931"></a>
### loadExtensionsInto

```ml
function loadExtensionsInto(databasePath, state)
```

Loads the extensions into. Inputs: `databasePath`, `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2281)

<a id="function-function-minisql-catalog-schema-history-loadorcreate-function-loadorcreate-databasepath-databaseid-src-minisql-catalog-schema-history-ml-21699014"></a>
### loadOrCreate

```ml
function loadOrCreate(databasePath, databaseId)
```

Loads the or create. Inputs: `databasePath`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L796)

<a id="constant-constant-minisql-catalog-schema-history-maintenance-committed-const-maintenance-committed-2-src-minisql-catalog-schema-history-ml-1096663643"></a>
### MAINTENANCE_COMMITTED

```ml
const MAINTENANCE_COMMITTED = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L48)

<a id="constant-constant-minisql-catalog-schema-history-maintenance-kind-const-maintenance-kind-42-src-minisql-catalog-schema-history-ml-1624590903"></a>
### MAINTENANCE_KIND

```ml
const MAINTENANCE_KIND = 42
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L43)

<a id="constant-constant-minisql-catalog-schema-history-maintenance-prepared-const-maintenance-prepared-1-src-minisql-catalog-schema-history-ml-164984646"></a>
### MAINTENANCE_PREPARED

```ml
const MAINTENANCE_PREPARED = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L47)

- [minisql.catalog.schema_history.MaintenanceJournal](Type-minisql-catalog-schema-history-maintenancejournal-1976737073.md) — struct
<a id="function-function-minisql-catalog-schema-history-maintenancemagic-function-maintenancemagic-src-minisql-catalog-schema-history-ml-1839027448"></a>
### maintenanceMagic

```ml
function maintenanceMagic()
```

Returns a fresh copy of the maintenance-journal magic bytes. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L341)

<a id="function-function-minisql-catalog-schema-history-maintenancepath-function-maintenancepath-databasepath-src-minisql-catalog-schema-history-ml-289429938"></a>
### maintenancePath

```ml
function maintenancePath(databasePath)
```

Performs the maintenance path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L365)

<a id="function-function-minisql-catalog-schema-history-markmaintenancecommitted-function-markmaintenancecommitted-databasepath-value-src-minisql-catalog-schema-history-ml-1494544011"></a>
### markMaintenanceCommitted

```ml
function markMaintenanceCommitted(databasePath, value)
```

Marks the maintenance committed. Inputs: `databasePath`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1784)

<a id="function-function-minisql-catalog-schema-history-nextextensionid-function-nextextensionid-state-src-minisql-catalog-schema-history-ml-71319231"></a>
### nextExtensionId

```ml
function nextExtensionId(state)
```

Performs the next extension id operation for this module. Inputs: `state`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2295)

<a id="function-function-minisql-catalog-schema-history-nextsequence-function-nextsequence-databasepath-databaseid-name-src-minisql-catalog-schema-history-ml-1473937519"></a>
### nextSequence

```ml
function nextSequence(databasePath, databaseId, name)
```

Performs the next sequence operation for this module. Inputs: `databasePath`, `databaseId`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2541)

<a id="constant-constant-minisql-catalog-schema-history-object-exists-const-object-exists-9013-src-minisql-catalog-schema-history-ml-1250456358"></a>
### OBJECT_EXISTS

```ml
const OBJECT_EXISTS = 9013
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L33)

<a id="constant-constant-minisql-catalog-schema-history-object-not-found-const-object-not-found-9014-src-minisql-catalog-schema-history-ml-1052094797"></a>
### OBJECT_NOT_FOUND

```ml
const OBJECT_NOT_FOUND = 9014
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L34)

<a id="function-function-minisql-catalog-schema-history-objectinschema-function-objectinschema-objectname-schemaname-src-minisql-catalog-schema-history-ml-1130142132"></a>
### objectInSchema

```ml
function objectInSchema(objectName, schemaName)
```

Returns true when an object name starts with the exact `schema.` prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `objectName` | `dynamic` | — |  |
| `schemaName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2364)

<a id="function-function-minisql-catalog-schema-history-prepare-function-prepare-transaction-src-minisql-catalog-schema-history-ml-795164268"></a>
### prepare

```ml
function prepare(transaction)
```

Performs the prepare operation for this module. Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1634)

- [minisql.catalog.schema_history.PreparedDdl](Type-minisql-catalog-schema-history-preparedddl-1982290018.md) — struct
<a id="constant-constant-minisql-catalog-schema-history-procedure-marker-prefix-const-procedure-marker-prefix-minisql-procedure-src-minisql-catalog-schema-history-ml-1810854528"></a>
### PROCEDURE_MARKER_PREFIX

```ml
const PROCEDURE_MARKER_PREFIX = "__minisql_procedure__"
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L75)

<a id="function-function-minisql-catalog-schema-history-proceduremarkername-function-proceduremarkername-name-src-minisql-catalog-schema-history-ml-781738053"></a>
### procedureMarkerName

```ml
function procedureMarkerName(name)
```

Encodes a stored procedure in the durable extension namespace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2335)

<a id="function-function-minisql-catalog-schema-history-procedureobjectname-function-procedureobjectname-markername-src-minisql-catalog-schema-history-ml-1296164969"></a>
### procedureObjectName

```ml
function procedureObjectName(markerName)
```

Decodes the SQL-visible procedure name from an internal marker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `markerName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2351)

<a id="function-function-minisql-catalog-schema-history-publishfilemoves-function-publishfilemoves-prepared-src-minisql-catalog-schema-history-ml-1652662439"></a>
### publishFileMoves

```ml
function publishFileMoves(prepared)
```

Performs the publish file moves operation for this module. Inputs: `prepared`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1903)

<a id="function-function-minisql-catalog-schema-history-putprocedure-function-putprocedure-databasepath-databaseid-name-bodysql-parameternames-replace-src-minisql-catalog-schema-history-ml-663289078"></a>
### putProcedure

```ml
function putProcedure(databasePath, databaseId, name, bodySql, parameterNames, replace)
```

Creates or replaces a stored procedure body and ordered parameter names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `bodySql` | `dynamic` | — |  |
| `parameterNames` | `dynamic` | — |  |
| `replace` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2485)

<a id="function-function-minisql-catalog-schema-history-putschema-function-putschema-databasepath-databaseid-name-ifnotexists-src-minisql-catalog-schema-history-ml-807590599"></a>
### putSchema

```ml
function putSchema(databasePath, databaseId, name, ifNotExists)
```

Creates a durable empty schema namespace using the extension sidecar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `ifNotExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2399)

<a id="function-function-minisql-catalog-schema-history-putsequence-function-putsequence-databasepath-databaseid-name-startvalue-incrementvalue-minimumvalue-maximumvalue-cycle-ifnotexists-src-minisql-catalog-schema-history-ml-1507368614"></a>
### putSequence

```ml
function putSequence(databasePath, databaseId, name, startValue, incrementValue, minimumValue, maximumValue, cycle, ifNotExists)
```

Performs the put sequence operation for this module. Inputs: `databasePath`, `databaseId`, `name`, `startValue`, `incrementValue`, `minimumValue`, `maximumValue`, `cycle`, `ifNotExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `startValue` | `dynamic` | — |  |
| `incrementValue` | `dynamic` | — |  |
| `minimumValue` | `dynamic` | — |  |
| `maximumValue` | `dynamic` | — |  |
| `cycle` | `dynamic` | — |  |
| `ifNotExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2505)

<a id="function-function-minisql-catalog-schema-history-puttrigger-function-puttrigger-databasepath-databaseid-name-tableid-timing-eventtype-targetcolumn-expressionsql-ifnotexists-src-minisql-catalog-schema-history-ml-290308971"></a>
### putTrigger

```ml
function putTrigger(databasePath, databaseId, name, tableId, timing, eventType, targetColumn, expressionSql, ifNotExists)
```

Performs the put trigger operation for this module. Inputs: `databasePath`, `databaseId`, `name`, `tableId`, `timing`, `eventType`, `targetColumn`, `expressionSql`, `ifNotExists`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |
| `timing` | `dynamic` | — |  |
| `eventType` | `dynamic` | — |  |
| `targetColumn` | `dynamic` | — |  |
| `expressionSql` | `dynamic` | — |  |
| `ifNotExists` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2582)

<a id="function-function-minisql-catalog-schema-history-putview-function-putview-databasepath-databaseid-name-sqltext-columnnames-replace-src-minisql-catalog-schema-history-ml-2093970288"></a>
### putView

```ml
function putView(databasePath, databaseId, name, sqlText, columnNames, replace)
```

Performs the put view operation for this module. Inputs: `databasePath`, `databaseId`, `name`, `sqlText`, `columnNames`, `replace`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |
| `columnNames` | `dynamic` | — |  |
| `replace` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2443)

<a id="function-function-minisql-catalog-schema-history-readstring-function-readstring-source-offset-operation-src-minisql-catalog-schema-history-ml-1354809399"></a>
### readString

```ml
function readString(source, offset, operation)
```

Reads the string. Inputs: `source`, `offset`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L503)

<a id="function-function-minisql-catalog-schema-history-readstringarray-function-readstringarray-source-offset-operation-src-minisql-catalog-schema-history-ml-2027827683"></a>
### readStringArray

```ml
function readStringArray(source, offset, operation)
```

Reads the string array. Inputs: `source`, `offset`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L536)

<a id="function-function-minisql-catalog-schema-history-readwhole-function-readwhole-path-src-minisql-catalog-schema-history-ml-23506959"></a>
### readWhole

```ml
function readWhole(path)
```

Reads the whole. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L452)

<a id="function-function-minisql-catalog-schema-history-recovermaintenance-function-recovermaintenance-databasepath-src-minisql-catalog-schema-history-ml-1834837990"></a>
### recoverMaintenance

```ml
function recoverMaintenance(databasePath)
```

Recovers the maintenance. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1803)

<a id="function-function-minisql-catalog-schema-history-recoverpending-function-recoverpending-databasepath-src-minisql-catalog-schema-history-ml-1515618586"></a>
### recoverPending

```ml
function recoverPending(databasePath)
```

Recovers the pending. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1842)

<a id="function-function-minisql-catalog-schema-history-removeat-function-removeat-values-index-src-minisql-catalog-schema-history-ml-2096332720"></a>
### removeAt

```ml
function removeAt(values, index)
```

Removes the at. Inputs: `values`, `index`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L855)

<a id="function-function-minisql-catalog-schema-history-renameexpression-function-renameexpression-expression-oldname-newname-src-minisql-catalog-schema-history-ml-1259643271"></a>
### renameExpression

```ml
function renameExpression(expression, oldName, newName)
```

Performs the rename expression operation for this module. Inputs: `expression`, `oldName`, `newName`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — |  |
| `oldName` | `dynamic` | — |  |
| `newName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1009)

<a id="function-function-minisql-catalog-schema-history-renameexpressionsql-function-renameexpressionsql-sqltext-oldname-newname-src-minisql-catalog-schema-history-ml-87506314"></a>
### renameExpressionSql

```ml
function renameExpressionSql(sqlText, oldName, newName)
```

Performs the rename expression sql operation for this module. Inputs: `sqlText`, `oldName`, `newName`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sqlText` | `dynamic` | — |  |
| `oldName` | `dynamic` | — |  |
| `newName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1031)

<a id="function-function-minisql-catalog-schema-history-rollback-function-rollback-transaction-src-minisql-catalog-schema-history-ml-1116760466"></a>
### rollback

```ml
function rollback(transaction)
```

Rolls back the requested value. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2010)

<a id="function-function-minisql-catalog-schema-history-samestringarray-function-samestringarray-left-right-src-minisql-catalog-schema-history-ml-1268397001"></a>
### sameStringArray

```ml
function sameStringArray(left, right)
```

Compares the string array. Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1059)

<a id="function-function-minisql-catalog-schema-history-save-function-save-databasepath-state-src-minisql-catalog-schema-history-ml-966313371"></a>
### save

```ml
function save(databasePath, state)
```

Persists the requested value. Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L788)

<a id="function-function-minisql-catalog-schema-history-saveextensions-function-saveextensions-databasepath-state-src-minisql-catalog-schema-history-ml-455435523"></a>
### saveExtensions

```ml
function saveExtensions(databasePath, state)
```

Persists the extensions. Inputs: `databasePath`, `state`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2275)

<a id="constant-constant-minisql-catalog-schema-history-schema-extension-version-const-schema-extension-version-1-src-minisql-catalog-schema-history-ml-75287456"></a>
### SCHEMA_EXTENSION_VERSION

```ml
const SCHEMA_EXTENSION_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L67)

<a id="constant-constant-minisql-catalog-schema-history-schema-kind-const-schema-kind-40-src-minisql-catalog-schema-history-ml-798957299"></a>
### SCHEMA_KIND

```ml
const SCHEMA_KIND = 40
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L41)

<a id="constant-constant-minisql-catalog-schema-history-schema-marker-prefix-const-schema-marker-prefix-minisql-schema-src-minisql-catalog-schema-history-ml-616612560"></a>
### SCHEMA_MARKER_PREFIX

```ml
const SCHEMA_MARKER_PREFIX = "__minisql_schema__"
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L74)

<a id="function-function-minisql-catalog-schema-history-schemaexists-function-schemaexists-state-name-src-minisql-catalog-schema-history-ml-1532157176"></a>
### schemaExists

```ml
function schemaExists(state, name)
```

Returns whether a schema is built in or durably registered.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2376)

<a id="function-function-minisql-catalog-schema-history-schemamagic-function-schemamagic-src-minisql-catalog-schema-history-ml-181071584"></a>
### schemaMagic

```ml
function schemaMagic()
```

Returns a fresh copy of the schema-history magic bytes. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L329)

<a id="function-function-minisql-catalog-schema-history-schemamarkername-function-schemamarkername-name-src-minisql-catalog-schema-history-ml-1982527125"></a>
### schemaMarkerName

```ml
function schemaMarkerName(name)
```

Encodes a durable schema namespace as an internal extension entry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2319)

<a id="function-function-minisql-catalog-schema-history-schemanames-function-schemanames-state-src-minisql-catalog-schema-history-ml-129074303"></a>
### schemaNames

```ml
function schemaNames(state)
```

Returns all SQL-visible schemas while hiding internal persistence markers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2382)

<a id="function-function-minisql-catalog-schema-history-schemapath-function-schemapath-databasepath-src-minisql-catalog-schema-history-ml-1562993022"></a>
### schemaPath

```ml
function schemaPath(databasePath)
```

Performs the schema path operation for this module. Inputs: `databasePath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L353)

- [minisql.catalog.schema_history.SchemaState](Type-minisql-catalog-schema-history-schemastate-2077837205.md) — struct
<a id="function-function-minisql-catalog-schema-history-sequencedefinition-function-sequencedefinition-sequenceid-name-startvalue-incrementvalue-minimumvalue-maximumvalue-lastvalue-hasvalue-cycle-ownedtableid-ownedcolumnname-src-minisql-catalog-schema-history-ml-763756256"></a>
### sequenceDefinition

```ml
function sequenceDefinition(sequenceId, name, startValue, incrementValue, minimumValue, maximumValue, lastValue, hasValue, cycle, ownedTableId, ownedColumnName)
```

Performs the sequence definition operation for this module. Inputs: `sequenceId`, `name`, `startValue`, `incrementValue`, `minimumValue`, `maximumValue`, `lastValue`, `hasValue`, `cycle`, `ownedTableId`, `ownedColumnName`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sequenceId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `startValue` | `dynamic` | — |  |
| `incrementValue` | `dynamic` | — |  |
| `minimumValue` | `dynamic` | — |  |
| `maximumValue` | `dynamic` | — |  |
| `lastValue` | `dynamic` | — |  |
| `hasValue` | `dynamic` | — |  |
| `cycle` | `dynamic` | — |  |
| `ownedTableId` | `dynamic` | — |  |
| `ownedColumnName` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L578)

- [minisql.catalog.schema_history.SequenceDefinition](Type-minisql-catalog-schema-history-sequencedefinition-289005439.md) — struct
<a id="function-function-minisql-catalog-schema-history-settriggerenabled-function-settriggerenabled-databasepath-databaseid-name-enabled-src-minisql-catalog-schema-history-ml-1992888298"></a>
### setTriggerEnabled

```ml
function setTriggerEnabled(databasePath, databaseId, name, enabled)
```

Persists the enabled state of an existing trigger definition.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2618)

<a id="function-function-minisql-catalog-schema-history-stagealtertable-function-stagealtertable-transaction-bound-src-minisql-catalog-schema-history-ml-651373284"></a>
### stageAlterTable

```ml
function stageAlterTable(transaction, bound)
```

Performs the stage alter table operation for this module. Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1625)

<a id="function-function-minisql-catalog-schema-history-stagecreateindex-function-stagecreateindex-transaction-bound-src-minisql-catalog-schema-history-ml-851636556"></a>
### stageCreateIndex

```ml
function stageCreateIndex(transaction, bound)
```

Performs the stage create index operation for this module. Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1607)

<a id="function-function-minisql-catalog-schema-history-stagecreatetable-function-stagecreatetable-transaction-bound-src-minisql-catalog-schema-history-ml-1218282108"></a>
### stageCreateTable

```ml
function stageCreateTable(transaction, bound)
```

Performs the stage create table operation for this module. Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1598)

<a id="function-function-minisql-catalog-schema-history-stagedroptable-function-stagedroptable-transaction-bound-src-minisql-catalog-schema-history-ml-1399106308"></a>
### stageDropTable

```ml
function stageDropTable(transaction, bound)
```

Performs the stage drop table operation for this module. Inputs: `transaction`, `bound`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `bound` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1616)

<a id="function-function-minisql-catalog-schema-history-stringarraycontains-function-stringarraycontains-values-name-src-minisql-catalog-schema-history-ml-1383850081"></a>
### stringArrayContains

```ml
function stringArrayContains(values, name)
```

Returns whether the supplied string array contains an exact identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1070)

<a id="function-function-minisql-catalog-schema-history-stringarrayreplace-function-stringarrayreplace-values-oldvalue-newvalue-src-minisql-catalog-schema-history-ml-534027893"></a>
### stringArrayReplace

```ml
function stringArrayReplace(values, oldValue, newValue)
```

Performs the string array replace operation for this module. Inputs: `values`, `oldValue`, `newValue`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `oldValue` | `dynamic` | — |  |
| `newValue` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L966)

<a id="function-function-minisql-catalog-schema-history-stringarraysize-function-stringarraysize-values-src-minisql-catalog-schema-history-ml-2066238572"></a>
### stringArraySize

```ml
function stringArraySize(values)
```

Performs the string array size operation for this module. Inputs: `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L514)

<a id="function-function-minisql-catalog-schema-history-stringsize-function-stringsize-value-src-minisql-catalog-schema-history-ml-1161967177"></a>
### stringSize

```ml
function stringSize(value)
```

Performs the string size operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L485)

<a id="function-function-minisql-catalog-schema-history-tableindexbyname-function-tableindexbyname-catalogstate-name-src-minisql-catalog-schema-history-ml-1894979721"></a>
### tableIndexByName

```ml
function tableIndexByName(catalogState, name)
```

Performs the table index by name operation for this module. Inputs: `catalogState`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `catalogState` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L867)

<a id="function-function-minisql-catalog-schema-history-tableschema-function-tableschema-tableid-schemaversion-columnrules-constraints-src-minisql-catalog-schema-history-ml-845118965"></a>
### tableSchema

```ml
function tableSchema(tableId, schemaVersion, columnRules, constraints)
```

Performs the table schema operation for this module. Inputs: `tableId`, `schemaVersion`, `columnRules`, `constraints`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableId` | `dynamic` | — |  |
| `schemaVersion` | `dynamic` | — |  |
| `columnRules` | `dynamic` | — |  |
| `constraints` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L626)

- [minisql.catalog.schema_history.TableSchema](Type-minisql-catalog-schema-history-tableschema-1050598738.md) — struct
<a id="function-function-minisql-catalog-schema-history-tableschemaindex-function-tableschemaindex-state-tableid-src-minisql-catalog-schema-history-ml-1672876886"></a>
### tableSchemaIndex

```ml
function tableSchemaIndex(state, tableId)
```

Performs the table schema index operation for this module. Inputs: `state`, `tableId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L878)

<a id="function-function-minisql-catalog-schema-history-targetmilestone-function-targetmilestone-src-minisql-catalog-schema-history-ml-443838158"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2639)

<a id="constant-constant-minisql-catalog-schema-history-trigger-after-const-trigger-after-2-src-minisql-catalog-schema-history-ml-556739647"></a>
### TRIGGER_AFTER

```ml
const TRIGGER_AFTER = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L69)

<a id="constant-constant-minisql-catalog-schema-history-trigger-before-const-trigger-before-1-src-minisql-catalog-schema-history-ml-279513344"></a>
### TRIGGER_BEFORE

```ml
const TRIGGER_BEFORE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L68)

<a id="constant-constant-minisql-catalog-schema-history-trigger-delete-const-trigger-delete-3-src-minisql-catalog-schema-history-ml-1892343402"></a>
### TRIGGER_DELETE

```ml
const TRIGGER_DELETE = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L72)

<a id="constant-constant-minisql-catalog-schema-history-trigger-insert-const-trigger-insert-1-src-minisql-catalog-schema-history-ml-1621379136"></a>
### TRIGGER_INSERT

```ml
const TRIGGER_INSERT = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L70)

<a id="constant-constant-minisql-catalog-schema-history-trigger-update-const-trigger-update-2-src-minisql-catalog-schema-history-ml-1310310741"></a>
### TRIGGER_UPDATE

```ml
const TRIGGER_UPDATE = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L71)

<a id="function-function-minisql-catalog-schema-history-triggerdefinition-function-triggerdefinition-triggerid-name-tableid-timing-eventtype-targetcolumn-expressionsql-enabled-src-minisql-catalog-schema-history-ml-761749909"></a>
### triggerDefinition

```ml
function triggerDefinition(triggerId, name, tableId, timing, eventType, targetColumn, expressionSql, enabled)
```

Performs the trigger definition operation for this module. Inputs: `triggerId`, `name`, `tableId`, `timing`, `eventType`, `targetColumn`, `expressionSql`, `enabled`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `triggerId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |
| `timing` | `dynamic` | — |  |
| `eventType` | `dynamic` | — |  |
| `targetColumn` | `dynamic` | — |  |
| `expressionSql` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L599)

- [minisql.catalog.schema_history.TriggerDefinition](Type-minisql-catalog-schema-history-triggerdefinition-702458084.md) — struct
<a id="function-function-minisql-catalog-schema-history-triggersfortable-function-triggersfortable-state-tableid-eventtype-src-minisql-catalog-schema-history-ml-1492755244"></a>
### triggersForTable

```ml
function triggersForTable(state, tableId, eventType)
```

Performs the triggers for table operation for this module. Inputs: `state`, `tableId`, `eventType`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tableId` | `dynamic` | — |  |
| `eventType` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L2572)

<a id="function-function-minisql-catalog-schema-history-uniqueconstraintforcolumns-function-uniqueconstraintforcolumns-tableschemavalue-columns-src-minisql-catalog-schema-history-ml-59753531"></a>
### uniqueConstraintForColumns

```ml
function uniqueConstraintForColumns(tableSchemaValue, columns)
```

Performs the unique constraint for columns operation for this module. Inputs: `tableSchemaValue`, `columns`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tableSchemaValue` | `dynamic` | — |  |
| `columns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L913)

<a id="constant-constant-minisql-catalog-schema-history-unsupported-format-const-unsupported-format-9003-src-minisql-catalog-schema-history-ml-1330699959"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L29)

<a id="constant-constant-minisql-catalog-schema-history-unsupported-sql-const-unsupported-sql-9025-src-minisql-catalog-schema-history-ml-1035658615"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L38)

<a id="function-function-minisql-catalog-schema-history-validatealterdropcolumndependencies-function-validatealterdropcolumndependencies-prepared-table-columnname-src-minisql-catalog-schema-history-ml-1055870048"></a>
### validateAlterDropColumnDependencies

```ml
function validateAlterDropColumnDependencies(prepared, table, columnName)
```

Rejects a column drop while any schema object still depends on that column.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state used for dependency lookup. |
| `table` | `dynamic` | — | Table from which the column would be removed. |
| `columnName` | `dynamic` | — | Exact column name being checked. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1292)

<a id="function-function-minisql-catalog-schema-history-validatealterforeignkey-function-validatealterforeignkey-prepared-table-source-src-minisql-catalog-schema-history-ml-548672482"></a>
### validateAlterForeignKey

```ml
function validateAlterForeignKey(prepared, table, source)
```

Validates the relational side of a new foreign-key constraint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prepared` | `dynamic` | — | Transactional schema-change state used for catalog lookup. |
| `table` | `dynamic` | — | Source table that owns the foreign key. |
| `source` | `dynamic` | — | Parsed foreign-key constraint definition. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1211)

<a id="function-function-minisql-catalog-schema-history-validatetransaction-function-validatetransaction-transaction-operation-src-minisql-catalog-schema-history-ml-2056680627"></a>
### validateTransaction

```ml
function validateTransaction(transaction, operation)
```

Validates the transaction. Inputs: `transaction`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1590)

<a id="function-function-minisql-catalog-schema-history-viewdefinition-function-viewdefinition-viewid-name-sqltext-columnnames-src-minisql-catalog-schema-history-ml-627527808"></a>
### viewDefinition

```ml
function viewDefinition(viewId, name, sqlText, columnNames)
```

Performs the view definition operation for this module. Inputs: `viewId`, `name`, `sqlText`, `columnNames`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `viewId` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |
| `columnNames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L571)

- [minisql.catalog.schema_history.ViewDefinition](Type-minisql-catalog-schema-history-viewdefinition-1769625371.md) — struct
<a id="function-function-minisql-catalog-schema-history-writeatomic-function-writeatomic-path-data-src-minisql-catalog-schema-history-ml-140307765"></a>
### writeAtomic

```ml
function writeAtomic(path, data)
```

Writes the atomic. Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L475)

<a id="function-function-minisql-catalog-schema-history-writejournal-function-writejournal-databasepath-value-src-minisql-catalog-schema-history-ml-1604940859"></a>
### writeJournal

```ml
function writeJournal(databasePath, value)
```

Writes the journal. Inputs: `databasePath`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1724)

<a id="function-function-minisql-catalog-schema-history-writemaintenance-function-writemaintenance-databasepath-value-src-minisql-catalog-schema-history-ml-1805491219"></a>
### writeMaintenance

```ml
function writeMaintenance(databasePath, value)
```

Writes the maintenance. Inputs: `databasePath`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L1768)

<a id="function-function-minisql-catalog-schema-history-writestring-function-writestring-output-offset-value-src-minisql-catalog-schema-history-ml-476662019"></a>
### writeString

```ml
function writeString(output, offset, value)
```

Writes the string. Inputs: `output`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L493)

<a id="function-function-minisql-catalog-schema-history-writestringarray-function-writestringarray-output-offset-values-src-minisql-catalog-schema-history-ml-502389460"></a>
### writeStringArray

```ml
function writeStringArray(output, offset, values)
```

Writes the string array. Inputs: `output`, `offset`, `values`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L525)

<a id="function-function-minisql-catalog-schema-history-writewhole-function-writewhole-path-data-src-minisql-catalog-schema-history-ml-1467431125"></a>
### writeWhole

```ml
function writeWhole(path, data)
```

Writes the whole. Inputs: `path`, `data`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L463)
