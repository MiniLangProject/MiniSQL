# `src/minisql/storage/superblock.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.storage.superblock`](Package-minisql-storage-superblock-1024868957.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)

## Declarations

<a id="function-function-minisql-storage-superblock-bytesequal-function-bytesequal-left-right-src-minisql-storage-superblock-ml-143455021"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L64)

<a id="constant-constant-minisql-storage-superblock-checksum-offset-const-checksum-offset-72-src-minisql-storage-superblock-ml-1098178802"></a>
### CHECKSUM_OFFSET

```ml
const CHECKSUM_OFFSET = 72
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L22)

<a id="function-function-minisql-storage-superblock-comparegeneration-function-comparegeneration-left-right-src-minisql-storage-superblock-ml-187893335"></a>
### compareGeneration

```ml
function compareGeneration(left, right)
```

Compares the generation. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L217)

<a id="function-function-minisql-storage-superblock-componentname-function-componentname-src-minisql-storage-superblock-ml-1186223768"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L267)

<a id="function-function-minisql-storage-superblock-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-superblock-ml-2005440139"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L76)

<a id="constant-constant-minisql-storage-superblock-corrupt-data-const-corrupt-data-9004-src-minisql-storage-superblock-ml-866366320"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L16)

<a id="function-function-minisql-storage-superblock-create-function-create-formatversion-generation-pagesize-filetype-fileid-pagecount-databaseid-featureflags-src-minisql-storage-superblock-ml-857825497"></a>
### create

```ml
function create(formatVersion, generation, pageSize, fileType, fileId, pageCount, databaseId, featureFlags)
```

Creates the requested value. Inputs: `formatVersion`, `generation`, `pageSize`, `fileType`, `fileId`, `pageCount`, `databaseId`, `featureFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `formatVersion` | `dynamic` | — |  |
| `generation` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `fileType` | `dynamic` | — |  |
| `fileId` | `dynamic` | — |  |
| `pageCount` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |
| `featureFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L123)

<a id="constant-constant-minisql-storage-superblock-database-id-size-const-database-id-size-16-src-minisql-storage-superblock-ml-1965362984"></a>
### DATABASE_ID_SIZE

```ml
const DATABASE_ID_SIZE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L21)

<a id="function-function-minisql-storage-superblock-decode-function-decode-source-src-minisql-storage-superblock-ml-2131296055"></a>
### decode

```ml
function decode(source)
```

Decodes the requested value. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L178)

<a id="function-function-minisql-storage-superblock-decodenativeid-function-decodenativeid-value-operation-name-src-minisql-storage-superblock-ml-1561575535"></a>
### decodeNativeId

```ml
function decodeNativeId(value, operation, name)
```

Decodes the native id. Inputs: `value`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L95)

<a id="function-function-minisql-storage-superblock-encode-function-encode-superblock-src-minisql-storage-superblock-ml-211795616"></a>
### encode

```ml
function encode(superblock)
```

Encodes the requested value. Inputs: `superblock`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `superblock` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L143)

<a id="function-function-minisql-storage-superblock-fail-function-fail-code-operation-message-src-minisql-storage-superblock-ml-918059683"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L52)

<a id="constant-constant-minisql-storage-superblock-file-type-database-meta-const-file-type-database-meta-4-src-minisql-storage-superblock-ml-1185852097"></a>
### FILE_TYPE_DATABASE_META

```ml
const FILE_TYPE_DATABASE_META = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L27)

<a id="constant-constant-minisql-storage-superblock-file-type-generic-const-file-type-generic-255-src-minisql-storage-superblock-ml-266420945"></a>
### FILE_TYPE_GENERIC

```ml
const FILE_TYPE_GENERIC = 255
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L28)

<a id="constant-constant-minisql-storage-superblock-file-type-index-const-file-type-index-2-src-minisql-storage-superblock-ml-206131539"></a>
### FILE_TYPE_INDEX

```ml
const FILE_TYPE_INDEX = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L25)

<a id="constant-constant-minisql-storage-superblock-file-type-table-const-file-type-table-1-src-minisql-storage-superblock-ml-262091530"></a>
### FILE_TYPE_TABLE

```ml
const FILE_TYPE_TABLE = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L24)

<a id="constant-constant-minisql-storage-superblock-file-type-wal-const-file-type-wal-3-src-minisql-storage-superblock-ml-1150984676"></a>
### FILE_TYPE_WAL

```ml
const FILE_TYPE_WAL = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L26)

<a id="constant-constant-minisql-storage-superblock-format-version-const-format-version-1-src-minisql-storage-superblock-ml-1405430500"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L18)

<a id="constant-constant-minisql-storage-superblock-header-size-const-header-size-128-src-minisql-storage-superblock-ml-1715962944"></a>
### HEADER_SIZE

```ml
const HEADER_SIZE = 128
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L20)

<a id="function-function-minisql-storage-superblock-immutableidentitymatches-function-immutableidentitymatches-left-right-src-minisql-storage-superblock-ml-651913081"></a>
### immutableIdentityMatches

```ml
function immutableIdentityMatches(left, right)
```

Performs the immutable identity matches operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L253)

<a id="function-function-minisql-storage-superblock-incrementgeneration-function-incrementgeneration-value-src-minisql-storage-superblock-ml-567024075"></a>
### incrementGeneration

```ml
function incrementGeneration(value)
```

Performs the increment generation operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L229)

<a id="constant-constant-minisql-storage-superblock-invalid-argument-const-invalid-argument-9001-src-minisql-storage-superblock-ml-1625683225"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Fixed 4096-byte metadata slot used twice at the beginning of every paged file. The two copies are updated alternately. The valid copy with the highest generation is authoritative after a crash.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L14)

<a id="function-function-minisql-storage-superblock-isimplemented-function-isimplemented-src-minisql-storage-superblock-ml-1639247848"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L279)

<a id="function-function-minisql-storage-superblock-magicbytes-function-magicbytes-src-minisql-storage-superblock-ml-896338232"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magic bytes operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L58)

<a id="function-function-minisql-storage-superblock-samedatabaseid-function-samedatabaseid-left-right-src-minisql-storage-superblock-ml-1253092185"></a>
### sameDatabaseId

```ml
function sameDatabaseId(left, right)
```

Compares the database id. Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L245)

<a id="constant-constant-minisql-storage-superblock-slot-size-const-slot-size-4096-src-minisql-storage-superblock-ml-1237792916"></a>
### SLOT_SIZE

```ml
const SLOT_SIZE = 4096
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L19)

- [minisql.storage.superblock.Superblock](Type-minisql-storage-superblock-superblock-1928044593.md) — struct
<a id="function-function-minisql-storage-superblock-targetmilestone-function-targetmilestone-src-minisql-storage-superblock-ml-577867690"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L273)

<a id="constant-constant-minisql-storage-superblock-unsupported-format-const-unsupported-format-9003-src-minisql-storage-superblock-ml-426358211"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L15)

<a id="function-function-minisql-storage-superblock-validatedatabaseid-function-validatedatabaseid-databaseid-operation-src-minisql-storage-superblock-ml-250969645"></a>
### validateDatabaseId

```ml
function validateDatabaseId(databaseId, operation)
```

Validates the database id. Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L114)

<a id="function-function-minisql-storage-superblock-validatefiletype-function-validatefiletype-filetype-operation-src-minisql-storage-superblock-ml-553372391"></a>
### validateFileType

```ml
function validateFileType(fileType, operation)
```

Validates the file type. Inputs: `fileType`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileType` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L105)

<a id="function-function-minisql-storage-superblock-validatenativeid-function-validatenativeid-value-operation-name-src-minisql-storage-superblock-ml-86386115"></a>
### validateNativeId

```ml
function validateNativeId(value, operation, name)
```

Validates the native id. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/superblock.ml#L86)
