# `src/minisql/executor/sort.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql executor sort facilities for this project.

Package: [`minisql.executor.sort`](Package-minisql-executor-sort-1346135293.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/executor/projection.ml` as `projection` → [src/minisql/executor/projection.ml](File-src-minisql-executor-projection-ml-1842888238.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/security/key_provider.ml` as `key_provider` → [src/minisql/security/key_provider.ml](File-src-minisql-security-key-provider-ml-1192998689.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/sql/values.ml` as `values` → [src/minisql/sql/values.ml](File-src-minisql-sql-values-ml-1302895578.md)
- `minisql/storage/row_codec.ml` as `row_codec` → [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency

## Declarations

<a id="function-function-minisql-executor-sort-bytesequal-function-bytesequal-left-right-src-minisql-executor-sort-ml-1570919653"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql executor sort module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L74)

<a id="function-function-minisql-executor-sort-cleanupruns-function-cleanupruns-runs-src-minisql-executor-sort-ml-1620652992"></a>
### cleanupRuns

```ml
function cleanupRuns(runs)
```

Implements cleanup runs for this module. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `runs` | `dynamic` | — | runs value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L456)

<a id="function-function-minisql-executor-sort-combinedvalues-function-combinedvalues-row-src-minisql-executor-sort-ml-1768930856"></a>
### combinedValues

```ml
function combinedValues(row)
```

Implements combined values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `row` | `dynamic` | — | row value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L240)

<a id="function-function-minisql-executor-sort-comparenullable-function-comparenullable-left-right-descending-nullsfirst-nullsspecified-src-minisql-executor-sort-ml-2086897419"></a>
### compareNullable

```ml
function compareNullable(left, right, descending, nullsFirst, nullsSpecified)
```

Compares nullable using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `descending` | `dynamic` | — | descending value consumed by this operation. |
| `nullsFirst` | `dynamic` | — | nullsFirst value consumed by this operation. |
| `nullsSpecified` | `dynamic` | — | nullsSpecified value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L91)

<a id="function-function-minisql-executor-sort-comparerows-function-comparerows-left-right-orderitems-src-minisql-executor-sort-ml-1321908421"></a>
### compareRows

```ml
function compareRows(left, right, orderItems)
```

Compares rows using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L113)

<a id="function-function-minisql-executor-sort-componentname-function-componentname-src-minisql-executor-sort-ml-1485606542"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql executor sort module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L554)

<a id="constant-constant-minisql-executor-sort-corrupt-data-const-corrupt-data-9004-src-minisql-executor-sort-ml-949147782"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql executor sort module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L24)

<a id="function-function-minisql-executor-sort-decodesqlvalue-function-decodesqlvalue-kind-raw-src-minisql-executor-sort-ml-660078412"></a>
### decodeSqlValue

```ml
function decodeSqlValue(kind, raw)
```

Decodes SQL value using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |
| `raw` | `dynamic` | — | raw value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L371)

<a id="function-function-minisql-executor-sort-encodeheader-function-encodeheader-valuecount-ordercount-encrypted-src-minisql-executor-sort-ml-887163397"></a>
### encodeHeader

```ml
function encodeHeader(valueCount, orderCount, encrypted)
```

Encodes header using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueCount` | `dynamic` | — | Number of value to process. |
| `orderCount` | `dynamic` | — | Number of order to process. |
| `encrypted` | `dynamic` | — | encrypted value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L292)

<a id="function-function-minisql-executor-sort-fail-function-fail-code-operation-message-src-minisql-executor-sort-ml-952056199"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql executor sort module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L57)

<a id="constant-constant-minisql-executor-sort-invalid-argument-const-invalid-argument-9001-src-minisql-executor-sort-ml-450573233"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Stable merge sorting for projected rows. M46 adds a correctness-first


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L22)

<a id="function-function-minisql-executor-sort-isimplemented-function-isimplemented-src-minisql-executor-sort-ml-1237356158"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql executor sort module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L568)

<a id="constant-constant-minisql-executor-sort-max-spill-file-bytes-const-max-spill-file-bytes-268435456-src-minisql-executor-sort-ml-128573526"></a>
### MAX_SPILL_FILE_BYTES

```ml
const MAX_SPILL_FILE_BYTES = 268435456
```

Defines the max spill file bytes constant used by the minisql executor sort module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L30)

<a id="function-function-minisql-executor-sort-merge-function-merge-left-right-orderitems-src-minisql-executor-sort-ml-954716497"></a>
### merge

```ml
function merge(left, right, orderItems)
```

Implements merge for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L131)

<a id="function-function-minisql-executor-sort-nextspilltoken-synchronized-function-nextspilltoken-src-minisql-executor-sort-ml-510667170"></a>
### nextSpillToken

```ml
synchronized function nextSpillToken()
```

Generates a process-unique spill namespace under an intrinsic function lock. The synchronized modifier serializes nonce updates across parallel SELECT workers.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L465)

<a id="function-function-minisql-executor-sort-rawvalues-function-rawvalues-input-src-minisql-executor-sort-ml-1645235892"></a>
### rawValues

```ml
function rawValues(input)
```

Implements raw values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | input value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L278)

<a id="function-function-minisql-executor-sort-readrun-function-readrun-run-src-minisql-executor-sort-ml-865847215"></a>
### readRun

```ml
function readRun(run)
```

Reads run using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `run` | `dynamic` | — | run value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L381)

<a id="function-function-minisql-executor-sort-runpath-function-runpath-root-token-index-src-minisql-executor-sort-ml-1486832257"></a>
### runPath

```ml
function runPath(root, token, index)
```

Runs path using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — | root value consumed by this operation. |
| `token` | `dynamic` | — | token value consumed by this operation. |
| `index` | `dynamic` | — | Zero-based index of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L478)

<a id="function-function-minisql-executor-sort-sortprojected-function-sortprojected-rows-orderitems-src-minisql-executor-sort-ml-1723376011"></a>
### sortProjected

```ml
function sortProjected(rows, orderItems)
```

Sorts projected using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L161)

<a id="function-function-minisql-executor-sort-sortprojectedwithspill-function-sortprojectedwithspill-rows-orderitems-temporaryroot-threshold-src-minisql-executor-sort-ml-1872830833"></a>
### sortProjectedWithSpill

```ml
function sortProjectedWithSpill(rows, orderItems, temporaryRoot, threshold)
```

Performs stable external merge sorting when rows exceed `threshold`. Sorted chunks are written as validated runs, then merged pairwise until one remains. Every success and failure path removes owned temporary files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |
| `temporaryRoot` | `dynamic` | — | temporaryRoot value consumed by this operation. |
| `threshold` | `dynamic` | — | threshold value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L489)

<a id="constant-constant-minisql-executor-sort-spill-header-size-const-spill-header-size-16-src-minisql-executor-sort-ml-117544562"></a>
### SPILL_HEADER_SIZE

```ml
const SPILL_HEADER_SIZE = 16
```

Defines the spill header size constant used by the minisql executor sort module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L28)

<a id="constant-constant-minisql-executor-sort-spill-version-const-spill-version-1-src-minisql-executor-sort-ml-1734409364"></a>
### SPILL_VERSION

```ml
const SPILL_VERSION = 1
```

Defines the spill version constant used by the minisql executor sort module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L26)

<a id="function-function-minisql-executor-sort-spillaad-function-spillaad-rowindex-src-minisql-executor-sort-ml-1708080306"></a>
### spillAad

```ml
function spillAad(rowIndex)
```

Creates domain-separated AAD for one ordered spill row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowIndex` | `dynamic` | — | Zero-based index of row. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L304)

<a id="function-function-minisql-executor-sort-spillmagic-function-spillmagic-src-minisql-executor-sort-ml-244061314"></a>
### spillMagic

```ml
function spillMagic()
```

Implements spill magic for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L64)

<a id="global-global-minisql-executor-sort-spillnonce-spillnonce-src-minisql-executor-sort-ml-2117164018"></a>
### spillNonce

```ml
spillNonce
```

Stores module-wide spill nonce state for the minisql executor sort module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L33)

- [minisql.executor.sort.SpillRun](Type-minisql-executor-sort-spillrun-632012310.md) — struct
<a id="function-function-minisql-executor-sort-spillschema-function-spillschema-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1979130154"></a>
### spillSchema

```ml
function spillSchema(rows, valueCount, orderCount)
```

Implements spill schema for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `valueCount` | `dynamic` | — | Number of value to process. |
| `orderCount` | `dynamic` | — | Number of order to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L251)

<a id="function-function-minisql-executor-sort-spillspec-function-spillspec-kind-src-minisql-executor-sort-ml-1981031390"></a>
### spillSpec

```ml
function spillSpec(kind)
```

Implements spill spec for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L229)

<a id="function-function-minisql-executor-sort-spilltype-function-spilltype-kind-src-minisql-executor-sort-ml-20392400"></a>
### spillType

```ml
function spillType(kind)
```

Implements spill type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | kind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L219)

<a id="function-function-minisql-executor-sort-targetmilestone-function-targetmilestone-src-minisql-executor-sort-ml-206580668"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql executor sort module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L561)

<a id="function-function-minisql-executor-sort-topnprojected-function-topnprojected-rows-orderitems-count-src-minisql-executor-sort-ml-1665386162"></a>
### topNProjected

```ml
function topNProjected(rows, orderItems, count)
```

Retains only the best `count` rows in stable ORDER BY order. The optimizer limits this O(rows*count) implementation to small windows, avoiding external runs and a complete result sort for interactive ORDER BY ... LIMIT queries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `orderItems` | `dynamic` | — | orderItems value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L179)

<a id="function-function-minisql-executor-sort-writerun-function-writerun-path-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1745860299"></a>
### writeRun

```ml
function writeRun(path, rows, valueCount, orderCount)
```

Writes run using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `rows` | `dynamic` | — | rows value consumed by this operation. |
| `valueCount` | `dynamic` | — | Number of value to process. |
| `orderCount` | `dynamic` | — | Number of order to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L316)
