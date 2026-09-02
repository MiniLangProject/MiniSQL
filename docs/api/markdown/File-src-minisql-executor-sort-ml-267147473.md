# `src/minisql/executor/sort.ml`

[Home](README.md) · [Files](Files.md)

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

Implements bytes equal for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L66)

<a id="function-function-minisql-executor-sort-cleanupruns-function-cleanupruns-runs-src-minisql-executor-sort-ml-1620652992"></a>
### cleanupRuns

```ml
function cleanupRuns(runs)
```

Implements cleanup runs for this module. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `runs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L413)

<a id="function-function-minisql-executor-sort-combinedvalues-function-combinedvalues-row-src-minisql-executor-sort-ml-1768930856"></a>
### combinedValues

```ml
function combinedValues(row)
```

Implements combined values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `row` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L213)

<a id="function-function-minisql-executor-sort-comparenullable-function-comparenullable-left-right-descending-nullsfirst-nullsspecified-src-minisql-executor-sort-ml-2086897419"></a>
### compareNullable

```ml
function compareNullable(left, right, descending, nullsFirst, nullsSpecified)
```

Compares nullable using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |
| `descending` | `dynamic` | — |  |
| `nullsFirst` | `dynamic` | — |  |
| `nullsSpecified` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L78)

<a id="function-function-minisql-executor-sort-comparerows-function-comparerows-left-right-orderitems-src-minisql-executor-sort-ml-1321908421"></a>
### compareRows

```ml
function compareRows(left, right, orderItems)
```

Compares rows using the supplied inputs. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |
| `orderItems` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L97)

<a id="function-function-minisql-executor-sort-componentname-function-componentname-src-minisql-executor-sort-ml-1485606542"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L504)

<a id="constant-constant-minisql-executor-sort-corrupt-data-const-corrupt-data-9004-src-minisql-executor-sort-ml-949147782"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L25)

<a id="function-function-minisql-executor-sort-decodesqlvalue-function-decodesqlvalue-kind-raw-src-minisql-executor-sort-ml-660078412"></a>
### decodeSqlValue

```ml
function decodeSqlValue(kind, raw)
```

Decodes SQL value using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L330)

<a id="function-function-minisql-executor-sort-encodeheader-function-encodeheader-valuecount-ordercount-encrypted-src-minisql-executor-sort-ml-887163397"></a>
### encodeHeader

```ml
function encodeHeader(valueCount, orderCount, encrypted)
```

Encodes header using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `valueCount` | `dynamic` | — |  |
| `orderCount` | `dynamic` | — |  |
| `encrypted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L258)

<a id="function-function-minisql-executor-sort-fail-function-fail-code-operation-message-src-minisql-executor-sort-ml-952056199"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L51)

<a id="constant-constant-minisql-executor-sort-invalid-argument-const-invalid-argument-9001-src-minisql-executor-sort-ml-450573233"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Stable merge sorting for projected rows. M46 adds a correctness-first external-run path: initial sorted chunks are encoded with row_codec into durable temporary files and merged pairwise. The current pairwise merge reads two complete runs and the QueryResult contract materializes the final array, so this is not yet a hard total-memory bound or a fully streaming executor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L24)

<a id="function-function-minisql-executor-sort-isimplemented-function-isimplemented-src-minisql-executor-sort-ml-1237356158"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L518)

<a id="constant-constant-minisql-executor-sort-max-spill-file-bytes-const-max-spill-file-bytes-268435456-src-minisql-executor-sort-ml-128573526"></a>
### MAX_SPILL_FILE_BYTES

```ml
const MAX_SPILL_FILE_BYTES = 268435456
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L28)

<a id="function-function-minisql-executor-sort-merge-function-merge-left-right-orderitems-src-minisql-executor-sort-ml-954716497"></a>
### merge

```ml
function merge(left, right, orderItems)
```

Implements merge for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |
| `orderItems` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L112)

<a id="function-function-minisql-executor-sort-nextspilltoken-synchronized-function-nextspilltoken-src-minisql-executor-sort-ml-510667170"></a>
### nextSpillToken

```ml
synchronized function nextSpillToken()
```

Generates a process-unique spill namespace under an intrinsic function lock. The synchronized modifier serializes nonce updates across parallel SELECT workers.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L422)

<a id="function-function-minisql-executor-sort-rawvalues-function-rawvalues-input-src-minisql-executor-sort-ml-1645235892"></a>
### rawValues

```ml
function rawValues(input)
```

Implements raw values for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L247)

<a id="function-function-minisql-executor-sort-readrun-function-readrun-run-src-minisql-executor-sort-ml-865847215"></a>
### readRun

```ml
function readRun(run)
```

Reads run using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `run` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L339)

<a id="function-function-minisql-executor-sort-runpath-function-runpath-root-token-index-src-minisql-executor-sort-ml-1486832257"></a>
### runPath

```ml
function runPath(root, token, index)
```

Runs path using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `root` | `dynamic` | — |  |
| `token` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L432)

<a id="function-function-minisql-executor-sort-sortprojected-function-sortprojected-rows-orderitems-src-minisql-executor-sort-ml-1723376011"></a>
### sortProjected

```ml
function sortProjected(rows, orderItems)
```

Sorts projected using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `orderItems` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L140)

<a id="function-function-minisql-executor-sort-sortprojectedwithspill-function-sortprojectedwithspill-rows-orderitems-temporaryroot-threshold-src-minisql-executor-sort-ml-1872830833"></a>
### sortProjectedWithSpill

```ml
function sortProjectedWithSpill(rows, orderItems, temporaryRoot, threshold)
```

Performs stable external merge sorting when rows exceed `threshold`. Sorted chunks are written as validated runs, then merged pairwise until one remains. Every success and failure path removes owned temporary files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `orderItems` | `dynamic` | — |  |
| `temporaryRoot` | `dynamic` | — |  |
| `threshold` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L439)

<a id="constant-constant-minisql-executor-sort-spill-header-size-const-spill-header-size-16-src-minisql-executor-sort-ml-117544562"></a>
### SPILL_HEADER_SIZE

```ml
const SPILL_HEADER_SIZE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L27)

<a id="constant-constant-minisql-executor-sort-spill-version-const-spill-version-1-src-minisql-executor-sort-ml-1734409364"></a>
### SPILL_VERSION

```ml
const SPILL_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L26)

<a id="function-function-minisql-executor-sort-spillaad-function-spillaad-rowindex-src-minisql-executor-sort-ml-1708080306"></a>
### spillAad

```ml
function spillAad(rowIndex)
```

Creates domain-separated AAD for one ordered spill row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L269)

<a id="function-function-minisql-executor-sort-spillmagic-function-spillmagic-src-minisql-executor-sort-ml-244061314"></a>
### spillMagic

```ml
function spillMagic()
```

Implements spill magic for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L58)

<a id="global-global-minisql-executor-sort-spillnonce-spillnonce-src-minisql-executor-sort-ml-2117164018"></a>
### spillNonce

```ml
spillNonce
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L30)

- [minisql.executor.sort.SpillRun](Type-minisql-executor-sort-spillrun-632012310.md) — struct
<a id="function-function-minisql-executor-sort-spillschema-function-spillschema-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1979130154"></a>
### spillSchema

```ml
function spillSchema(rows, valueCount, orderCount)
```

Implements spill schema for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `valueCount` | `dynamic` | — |  |
| `orderCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L221)

<a id="function-function-minisql-executor-sort-spillspec-function-spillspec-kind-src-minisql-executor-sort-ml-1981031390"></a>
### spillSpec

```ml
function spillSpec(kind)
```

Implements spill spec for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L203)

<a id="function-function-minisql-executor-sort-spilltype-function-spilltype-kind-src-minisql-executor-sort-ml-20392400"></a>
### spillType

```ml
function spillType(kind)
```

Implements spill type for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L194)

<a id="function-function-minisql-executor-sort-targetmilestone-function-targetmilestone-src-minisql-executor-sort-ml-206580668"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L511)

<a id="function-function-minisql-executor-sort-topnprojected-function-topnprojected-rows-orderitems-count-src-minisql-executor-sort-ml-1665386162"></a>
### topNProjected

```ml
function topNProjected(rows, orderItems, count)
```

Retains only the best `count` rows in stable ORDER BY order. The optimizer limits this O(rows*count) implementation to small windows, avoiding external runs and a complete result sort for interactive ORDER BY ... LIMIT queries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — |  |
| `orderItems` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L155)

<a id="function-function-minisql-executor-sort-writerun-function-writerun-path-rows-valuecount-ordercount-src-minisql-executor-sort-ml-1745860299"></a>
### writeRun

```ml
function writeRun(path, rows, valueCount, orderCount)
```

Writes run using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `rows` | `dynamic` | — |  |
| `valueCount` | `dynamic` | — |  |
| `orderCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/sort.ml#L277)
