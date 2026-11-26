# `src/minisql/storage/table_header.ml`

[Home](README.md) · [Files](Files.md)

Validates the immutable page-zero identity of format-v2 heap tables.

Package: [`minisql.storage.table_header`](Package-minisql-storage-table-header-935002309.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/format_version.ml` as `format_version` → [src/minisql/common/format_version.ml](File-src-minisql-common-format-version-ml-1671630705.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)

## Declarations

<a id="function-function-minisql-storage-table-header-checkedopen-function-checkedopen-file-src-minisql-storage-table-header-ml-1514298088"></a>
### checkedOpen

```ml
function checkedOpen(file)
```

Validates an acquired table handle and releases it on every failure path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | Open paged file returned by the selected access mode. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L127)

<a id="function-function-minisql-storage-table-header-componentname-function-componentname-src-minisql-storage-table-header-ml-371312416"></a>
### componentName

```ml
function componentName()
```

Returns the component identifier used by documentation tooling.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L152)

<a id="constant-constant-minisql-storage-table-header-corrupt-data-const-corrupt-data-9004-src-minisql-storage-table-header-ml-1874705648"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Persisted identity or checksum does not match the table file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L20)

<a id="function-function-minisql-storage-table-header-create-function-create-path-pagesize-fileid-databaseid-src-minisql-storage-table-header-ml-125210106"></a>
### create

```ml
function create(path, pageSize, fileId, databaseId)
```

Creates a physical user table with its required immutable header page. Catalog and security paged files intentionally use their own page formats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Destination table path. |
| `pageSize` | `dynamic` | — | Database page size. |
| `fileId` | `dynamic` | — | Table object identifier. |
| `databaseId` | `dynamic` | — | Sixteen-byte database identifier. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L118)

<a id="function-function-minisql-storage-table-header-encode-function-encode-file-src-minisql-storage-table-header-ml-1598247638"></a>
### encode

```ml
function encode(file)
```

Creates the immutable page-zero image for a newly created empty table. Creation generation is recorded once; subsequent data-page allocations do not rewrite page zero or publish potentially stale allocation hints.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | Open newly created user-table paged file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L43)

<a id="function-function-minisql-storage-table-header-fail-function-fail-code-operation-message-src-minisql-storage-table-header-ml-1759817003"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates a structured table-header error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | Stable MiniSQL error code. |
| `operation` | `dynamic` | — | Name of the failed operation. |
| `message` | `dynamic` | — | Details of the violated invariant. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L30)

<a id="constant-constant-minisql-storage-table-header-first-data-page-const-first-data-page-1-src-minisql-storage-table-header-ml-1951401238"></a>
### FIRST_DATA_PAGE

```ml
const FIRST_DATA_PAGE = 1
```

First physical page that can hold heap records or overflow data.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L24)

<a id="constant-constant-minisql-storage-table-header-header-bytes-const-header-bytes-128-src-minisql-storage-table-header-ml-2010949332"></a>
### HEADER_BYTES

```ml
const HEADER_BYTES = 128
```

Bytes occupied by the general page header and table-specific metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L22)

<a id="function-function-minisql-storage-table-header-initialize-function-initialize-file-src-minisql-storage-table-header-ml-1769849982"></a>
### initialize

```ml
function initialize(file)
```

Durably reserves page zero before any heap or overflow allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | Newly created empty user-table paged file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L106)

<a id="constant-constant-minisql-storage-table-header-invalid-argument-const-invalid-argument-9001-src-minisql-storage-table-header-ml-202595733"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Invalid caller input.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L16)

<a id="function-function-minisql-storage-table-header-isimplemented-function-isimplemented-src-minisql-storage-table-header-ml-2012697232"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the table-header codec is implemented.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L162)

<a id="function-function-minisql-storage-table-header-magicbytes-function-magicbytes-src-minisql-storage-table-header-ml-263971968"></a>
### magicBytes

```ml
function magicBytes()
```

Returns the four-byte table-header magic.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L35)

<a id="function-function-minisql-storage-table-header-open-function-open-path-src-minisql-storage-table-header-ml-273552913"></a>
### open

```ml
function open(path)
```

Opens and validates a writable user table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Existing table path. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L135)

<a id="function-function-minisql-storage-table-header-openreadonly-function-openreadonly-path-src-minisql-storage-table-header-ml-1738425165"></a>
### openReadOnly

```ml
function openReadOnly(path)
```

Opens and validates a shared read-only user table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Existing table path. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L141)

<a id="function-function-minisql-storage-table-header-openreadonlymanaged-function-openreadonlymanaged-path-src-minisql-storage-table-header-ml-1476524283"></a>
### openReadOnlyManaged

```ml
function openReadOnlyManaged(path)
```

Opens and validates a database-managed read-only user table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Existing table path protected by the database manager. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L147)

<a id="function-function-minisql-storage-table-header-targetmilestone-function-targetmilestone-src-minisql-storage-table-header-ml-1722140838"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the storage-format milestone owned by this component.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L157)

<a id="constant-constant-minisql-storage-table-header-unsupported-format-const-unsupported-format-9003-src-minisql-storage-table-header-ml-1802325603"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

A legacy or unknown physical table format cannot be opened.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L18)

<a id="function-function-minisql-storage-table-header-validate-function-validate-file-src-minisql-storage-table-header-ml-456992630"></a>
### validate

```ml
function validate(file)
```

Validates an open table, including read-only handles. Empty legacy table files and legacy tables with heap data on page zero are rejected.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | Open user-table paged file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L97)

<a id="function-function-minisql-storage-table-header-validatepage-function-validatepage-file-encoded-src-minisql-storage-table-header-ml-1851821314"></a>
### validatePage

```ml
function validatePage(file, encoded)
```

Checks table identity, versions and reserved bytes after both page CRCs have been verified. The redundant identity must agree with the file superblock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | Open user-table paged file. |
| `encoded` | `dynamic` | — | Complete logical page-zero image. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/table_header.ml#L70)
