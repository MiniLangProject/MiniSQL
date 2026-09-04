# `src/minisql/tools/check.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql tools check facilities for this project.

Package: [`minisql.tools.check`](Package-minisql-tools-check-603842937.md)

Reachable from entry: **no**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/catalog/statistics.ml` as `statistics` → [src/minisql/catalog/statistics.ml](File-src-minisql-catalog-statistics-ml-1707584758.md)
- `minisql/common/diagnostics.ml` as `diagnostics` → [src/minisql/common/diagnostics.ml](File-src-minisql-common-diagnostics-ml-1805539733.md)
- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/executor/dml.ml` as `dml` → [src/minisql/executor/dml.ml](File-src-minisql-executor-dml-ml-1278137778.md)
- `minisql/executor/scan.ml` as `scan` → [src/minisql/executor/scan.ml](File-src-minisql-executor-scan-ml-657274302.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/storage/btree.ml` as `btree` → [src/minisql/storage/btree.ml](File-src-minisql-storage-btree-ml-1474397187.md)

## Declarations

<a id="function-function-minisql-tools-check-bytesequal-function-bytesequal-left-right-src-minisql-tools-check-ml-1338363263"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql tools check module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L70)

<a id="function-function-minisql-tools-check-cataloghastable-function-cataloghastable-database-tableid-src-minisql-tools-check-ml-546156702"></a>
### catalogHasTable

```ml
function catalogHasTable(database, tableId)
```

Implements catalog has table for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `tableId` | `dynamic` | — | Identifier of table. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L96)

<a id="function-function-minisql-tools-check-checkopen-function-checkopen-database-src-minisql-tools-check-ml-1766366021"></a>
### checkOpen

```ml
function checkOpen(database)
```

Checks open using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L137)

- [minisql.tools.check.CheckReport](Type-minisql-tools-check-checkreport-210937097.md) — struct
<a id="function-function-minisql-tools-check-componentname-function-componentname-src-minisql-tools-check-ml-1130301704"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql tools check module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L235)

<a id="function-function-minisql-tools-check-containsint-function-containsint-values-expected-src-minisql-tools-check-ml-1502558234"></a>
### containsInt

```ml
function containsInt(values, expected)
```

Returns whether the supplied value satisfies the int condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L84)

<a id="constant-constant-minisql-tools-check-corrupt-data-const-corrupt-data-9004-src-minisql-tools-check-ml-330124712"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql tools check module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L24)

<a id="function-function-minisql-tools-check-fail-function-fail-code-operation-message-src-minisql-tools-check-ml-1863167065"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql tools check module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L52)

<a id="constant-constant-minisql-tools-check-invalid-argument-const-invalid-argument-9001-src-minisql-tools-check-ml-987852859"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

M20 offline consistency checker. The database manager obtains the database-wide


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L22)

<a id="function-function-minisql-tools-check-ischeckreport-function-ischeckreport-value-src-minisql-tools-check-ml-1372242763"></a>
### isCheckReport

```ml
function isCheckReport(value)
```

Returns whether the supplied value satisfies the check report condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L60)

<a id="function-function-minisql-tools-check-isimplemented-function-isimplemented-src-minisql-tools-check-ml-1487704216"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql tools check module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L249)

<a id="function-function-minisql-tools-check-m0selftestline-function-m0selftestline-src-minisql-tools-check-ml-121508448"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Performs the m0SelfTestLine operation for the minisql tools check module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L221)

<a id="function-function-minisql-tools-check-run-function-run-databasepath-src-minisql-tools-check-ml-1262899924"></a>
### run

```ml
function run(databasePath)
```

Runs run for the minisql tools check workflow. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L206)

<a id="function-function-minisql-tools-check-schemahastable-function-schemahastable-state-tableid-src-minisql-tools-check-ml-1055246554"></a>
### schemaHasTable

```ml
function schemaHasTable(state, tableId)
```

Implements schema has table for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Mutable state inspected or updated by the operation. |
| `tableId` | `dynamic` | — | Identifier of table. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L108)

<a id="function-function-minisql-tools-check-targetmilestone-function-targetmilestone-src-minisql-tools-check-ml-1378469990"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql tools check module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L242)

<a id="function-function-minisql-tools-check-verifyindex-function-verifyindex-databasepath-indexid-src-minisql-tools-check-ml-2051746995"></a>
### verifyIndex

```ml
function verifyIndex(databasePath, indexId)
```

Verifies index using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |
| `indexId` | `dynamic` | — | Identifier of index. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L121)

<a id="function-function-minisql-tools-check-versionline-function-versionline-src-minisql-tools-check-ml-678304144"></a>
### versionLine

```ml
function versionLine()
```

Performs the versionLine operation for the minisql tools check module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/tools/check.ml#L228)
