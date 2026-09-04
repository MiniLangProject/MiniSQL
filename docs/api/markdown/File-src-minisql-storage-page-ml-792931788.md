# `src/minisql/storage/page.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage page facilities for this project.

Package: [`minisql.storage.page`](Package-minisql-storage-page-1439504742.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)

## Declarations

<a id="function-function-minisql-storage-page-bytesequal-function-bytesequal-left-right-src-minisql-storage-page-ml-546423855"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql storage page module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L99)

<a id="function-function-minisql-storage-page-comparelsn-function-comparelsn-left-right-src-minisql-storage-page-ml-1404447731"></a>
### compareLsn

```ml
function compareLsn(left, right)
```

Compares the lsn. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L393)

<a id="function-function-minisql-storage-page-componentname-function-componentname-src-minisql-storage-page-ml-1611715800"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage page module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L418)

<a id="function-function-minisql-storage-page-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-page-ml-1146974041"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Performs the copyExact operation for the minisql storage page module. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L116)

<a id="constant-constant-minisql-storage-page-corrupt-data-const-corrupt-data-9004-src-minisql-storage-page-ml-1880155572"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L18)

<a id="function-function-minisql-storage-page-create-function-create-pagesize-pagetype-fileid-pagenumber-src-minisql-storage-page-ml-172780160"></a>
### create

```ml
function create(pageSize, pageType, fileId, pageNumber)
```

Creates create for the minisql storage page module. Inputs: `pageSize`, `pageType`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `pageType` | `dynamic` | — | pageType value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L371)

<a id="function-function-minisql-storage-page-createpageid-function-createpageid-fileid-pagenumber-src-minisql-storage-page-ml-829668231"></a>
### createPageId

```ml
function createPageId(fileId, pageNumber)
```

Creates the page id. Inputs: `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L190)

<a id="function-function-minisql-storage-page-decodenativeid-function-decodenativeid-value-operation-name-src-minisql-storage-page-ml-944603091"></a>
### decodeNativeId

```ml
function decodeNativeId(value, operation, name)
```

Decodes the native id. Inputs: `value`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L141)

<a id="function-function-minisql-storage-page-decodepageheader-function-decodepageheader-source-src-minisql-storage-page-ml-1523355231"></a>
### decodePageHeader

```ml
function decodePageHeader(source)
```

Decodes the page header. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L293)

<a id="function-function-minisql-storage-page-encodepageheader-function-encodepageheader-header-destination-src-minisql-storage-page-ml-1620133033"></a>
### encodePageHeader

```ml
function encodePageHeader(header, destination)
```

Encodes the page header. Inputs: `header`, `destination`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | header value consumed by this operation. |
| `destination` | `dynamic` | — | destination value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L264)

<a id="function-function-minisql-storage-page-fail-function-fail-code-operation-message-src-minisql-storage-page-ml-145257751"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage page module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L85)

<a id="constant-constant-minisql-storage-page-format-version-const-format-version-1-src-minisql-storage-page-ml-1382878926"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```

Defines the format version constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L21)

<a id="constant-constant-minisql-storage-page-header-checksum-offset-const-header-checksum-offset-60-src-minisql-storage-page-ml-1071638965"></a>
### HEADER_CHECKSUM_OFFSET

```ml
const HEADER_CHECKSUM_OFFSET = 60
```

Defines the header checksum offset constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L29)

<a id="constant-constant-minisql-storage-page-header-size-const-header-size-64-src-minisql-storage-page-ml-165044873"></a>
### HEADER_SIZE

```ml
const HEADER_SIZE = 64
```

Defines the header size constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L23)

<a id="constant-constant-minisql-storage-page-invalid-argument-const-invalid-argument-9001-src-minisql-storage-page-ml-247732101"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

MiniSQL page format version 1.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L14)

<a id="function-function-minisql-storage-page-isimplemented-function-isimplemented-src-minisql-storage-page-ml-1236222240"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage page module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L430)

<a id="constant-constant-minisql-storage-page-magic-size-const-magic-size-4-src-minisql-storage-page-ml-757155631"></a>
### MAGIC_SIZE

```ml
const MAGIC_SIZE = 4
```

Defines the magic size constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L25)

<a id="function-function-minisql-storage-page-magicbytes-function-magicbytes-src-minisql-storage-page-ml-346578040"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magicBytes operation for the minisql storage page module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L91)

<a id="function-function-minisql-storage-page-newheader-function-newheader-pagetype-pageid-pagesize-src-minisql-storage-page-ml-1402566195"></a>
### newHeader

```ml
function newHeader(pageType, pageId, pageSize)
```

Performs the new header operation for this module. Inputs: `pageType`, `pageId`, `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageType` | `dynamic` | — | pageType value consumed by this operation. |
| `pageId` | `dynamic` | — | Identifier of page. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L201)

- [minisql.storage.page.PageHeader](Type-minisql-storage-page-pageheader-38785874.md) — struct
- [minisql.storage.page.PageId](Type-minisql-storage-page-pageid-1131505422.md) — struct
<a id="constant-constant-minisql-storage-page-payload-checksum-offset-const-payload-checksum-offset-56-src-minisql-storage-page-ml-1375952372"></a>
### PAYLOAD_CHECKSUM_OFFSET

```ml
const PAYLOAD_CHECKSUM_OFFSET = 56
```

Defines the payload checksum offset constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L27)

<a id="function-function-minisql-storage-page-reseal-function-reseal-pagebytes-src-minisql-storage-page-ml-1377155554"></a>
### reseal

```ml
function reseal(pageBytes)
```

Performs the reseal operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L382)

<a id="function-function-minisql-storage-page-seal-function-seal-pagebytes-header-src-minisql-storage-page-ml-137564969"></a>
### seal

```ml
function seal(pageBytes, header)
```

Performs the seal operation for this module. Inputs: `pageBytes`, `header`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `header` | `dynamic` | — | header value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L341)

<a id="function-function-minisql-storage-page-setlsn-function-setlsn-pagebytes-lsn-src-minisql-storage-page-ml-1593770705"></a>
### setLsn

```ml
function setLsn(pageBytes, lsn)
```

Updates the lsn. Inputs: `pageBytes`, `lsn`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L407)

<a id="function-function-minisql-storage-page-targetmilestone-function-targetmilestone-src-minisql-storage-page-ml-1525109030"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage page module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L424)

<a id="constant-constant-minisql-storage-page-type-btree-internal-const-type-btree-internal-3-src-minisql-storage-page-ml-1816321862"></a>
### TYPE_BTREE_INTERNAL

```ml
const TYPE_BTREE_INTERNAL = 3
```

Defines the type btree internal constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L38)

<a id="constant-constant-minisql-storage-page-type-btree-leaf-const-type-btree-leaf-4-src-minisql-storage-page-ml-1149099115"></a>
### TYPE_BTREE_LEAF

```ml
const TYPE_BTREE_LEAF = 4
```

Defines the type btree leaf constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L40)

<a id="constant-constant-minisql-storage-page-type-catalog-const-type-catalog-5-src-minisql-storage-page-ml-1749695602"></a>
### TYPE_CATALOG

```ml
const TYPE_CATALOG = 5
```

Defines the type catalog constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L42)

<a id="constant-constant-minisql-storage-page-type-free-const-type-free-0-src-minisql-storage-page-ml-164652775"></a>
### TYPE_FREE

```ml
const TYPE_FREE = 0
```

Defines the type free constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L32)

<a id="constant-constant-minisql-storage-page-type-generic-const-type-generic-255-src-minisql-storage-page-ml-2000011725"></a>
### TYPE_GENERIC

```ml
const TYPE_GENERIC = 255
```

Defines the type generic constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L44)

<a id="constant-constant-minisql-storage-page-type-heap-const-type-heap-1-src-minisql-storage-page-ml-1734479264"></a>
### TYPE_HEAP

```ml
const TYPE_HEAP = 1
```

Defines the type heap constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L34)

<a id="constant-constant-minisql-storage-page-type-overflow-const-type-overflow-2-src-minisql-storage-page-ml-1788757645"></a>
### TYPE_OVERFLOW

```ml
const TYPE_OVERFLOW = 2
```

Defines the type overflow constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L36)

<a id="constant-constant-minisql-storage-page-unsupported-format-const-unsupported-format-9003-src-minisql-storage-page-ml-1070137087"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql storage page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L16)

<a id="function-function-minisql-storage-page-validateheader-function-validateheader-header-pagesize-operation-src-minisql-storage-page-ml-1805710224"></a>
### validateHeader

```ml
function validateHeader(header, pageSize, operation)
```

Validates the header. Inputs: `header`, `pageSize`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | header value consumed by this operation. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L227)

<a id="function-function-minisql-storage-page-validatenativeid-function-validatenativeid-value-operation-name-src-minisql-storage-page-ml-1435170287"></a>
### validateNativeId

```ml
function validateNativeId(value, operation, name)
```

Validates native id for the minisql storage page workflow. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L129)

<a id="function-function-minisql-storage-page-validatepagebuffer-function-validatepagebuffer-pagebytes-operation-src-minisql-storage-page-ml-625609429"></a>
### validatePageBuffer

```ml
function validatePageBuffer(pageBytes, operation)
```

Validates the page buffer. Inputs: `pageBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L178)

<a id="function-function-minisql-storage-page-validatepagesize-function-validatepagesize-pagesize-operation-src-minisql-storage-page-ml-956255381"></a>
### validatePageSize

```ml
function validatePageSize(pageSize, operation)
```

Validates the page size. Inputs: `pageSize`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L164)

<a id="function-function-minisql-storage-page-validatepagetype-function-validatepagetype-value-operation-src-minisql-storage-page-ml-676555070"></a>
### validatePageType

```ml
function validatePageType(value, operation)
```

Validates the page type. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L153)

<a id="function-function-minisql-storage-page-verify-function-verify-pagebytes-src-minisql-storage-page-ml-652437490"></a>
### verify

```ml
function verify(pageBytes)
```

Performs the verify operation for the minisql storage page module. Inputs: `pageBytes`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/page.ml#L355)
