# `src/minisql/storage/paged_file.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage paged file facilities for this project.

Package: [`minisql.storage.paged_file`](Package-minisql-storage-paged-file-923880469.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/lock.ml` as `file_lock` → [src/minisql/platform/lock.ml](File-src-minisql-platform-lock-ml-271785262.md)
- `minisql/security/key_provider.ml` as `key_provider` → [src/minisql/security/key_provider.ml](File-src-minisql-security-key-provider-ml-1192998689.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency

## Declarations

<a id="function-function-minisql-storage-paged-file-allocatepage-function-allocatepage-pagedfile-pagetype-src-minisql-storage-paged-file-ml-1782932330"></a>
### allocatePage

```ml
function allocatePage(pagedFile, pageType)
```

Allocates the page. Inputs: `pagedFile`, `pageType`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageType` | `dynamic` | — | pageType value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L661)

<a id="function-function-minisql-storage-paged-file-allocatepages-function-allocatepages-pagedfile-pagetype-count-src-minisql-storage-paged-file-ml-1741497779"></a>
### allocatePages

```ml
function allocatePages(pagedFile, pageType, count)
```

Allocates a contiguous group of initialized pages with one durability barrier and one superblock publication. Page bytes reach stable storage before the increased page count becomes visible, preserving the single-page crash rule.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageType` | `dynamic` | — | pageType value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L671)

<a id="function-function-minisql-storage-paged-file-appendpage-function-appendpage-pagedfile-pagebytes-src-minisql-storage-paged-file-ml-52306433"></a>
### appendPage

```ml
function appendPage(pagedFile, pageBytes)
```

Appends the page. Inputs: `pagedFile`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L608)

<a id="function-function-minisql-storage-paged-file-appendpages-function-appendpages-pagedfile-pageimages-src-minisql-storage-paged-file-ml-790093168"></a>
### appendPages

```ml
function appendPages(pagedFile, pageImages)
```

Appends a complete copy-on-write page generation with one data durability barrier and one redundant-superblock publication. Page identity is validated before I/O; bounded 512 KiB writes avoid a second generation-sized buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageImages` | `dynamic` | — | pageImages value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L624)

<a id="function-function-minisql-storage-paged-file-choosemetadata-function-choosemetadata-firstresult-secondresult-src-minisql-storage-paged-file-ml-2045390736"></a>
### chooseMetadata

```ml
function chooseMetadata(firstResult, secondResult)
```

Performs the choose metadata operation for this module. Inputs: `firstResult`, `secondResult`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `firstResult` | `dynamic` | — | firstResult value consumed by this operation. |
| `secondResult` | `dynamic` | — | secondResult value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L303)

<a id="function-function-minisql-storage-paged-file-close-function-close-pagedfile-src-minisql-storage-paged-file-ml-1505146723"></a>
### close

```ml
function close(pagedFile)
```

Closes close owned by the minisql storage paged file module. Inputs: `pagedFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L757)

<a id="constant-constant-minisql-storage-paged-file-closed-handle-const-closed-handle-9008-src-minisql-storage-paged-file-ml-402824510"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L24)

<a id="function-function-minisql-storage-paged-file-commitmetadata-function-commitmetadata-pagedfile-newpagecount-src-minisql-storage-paged-file-ml-87774543"></a>
### commitMetadata

```ml
function commitMetadata(pagedFile, newPageCount)
```

Commits the metadata. Inputs: `pagedFile`, `newPageCount`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `newPageCount` | `dynamic` | — | Number of new page to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L214)

<a id="function-function-minisql-storage-paged-file-committedsize-function-committedsize-pagesize-pagecount-featureflags-src-minisql-storage-paged-file-ml-137586767"></a>
### committedSize

```ml
function committedSize(pageSize, pageCount, featureFlags)
```

Commits the ted size. Inputs: `pageSize`, `pageCount`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `pageCount` | `dynamic` | — | Number of page to process. |
| `featureFlags` | `dynamic` | — | featureFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L170)

<a id="function-function-minisql-storage-paged-file-componentname-function-componentname-src-minisql-storage-paged-file-ml-1618716352"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage paged file module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L819)

<a id="constant-constant-minisql-storage-paged-file-corrupt-data-const-corrupt-data-9004-src-minisql-storage-paged-file-ml-433802480"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L22)

<a id="function-function-minisql-storage-paged-file-create-function-create-path-pagesize-filetype-fileid-databaseid-src-minisql-storage-paged-file-ml-1000346296"></a>
### create

```ml
function create(path, pageSize, fileType, fileId, databaseId)
```

Creates create for the minisql storage paged file module. Inputs: `path`, `pageSize`, `fileType`, `fileId`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `fileType` | `dynamic` | — | fileType value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L236)

<a id="constant-constant-minisql-storage-paged-file-data-offset-const-data-offset-8192-src-minisql-storage-paged-file-ml-929695559"></a>
### DATA_OFFSET

```ml
const DATA_OFFSET = 8192
```

Defines the data offset constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L35)

<a id="function-function-minisql-storage-paged-file-decodestoredpage-function-decodestoredpage-pagedfile-pagenumber-stored-src-minisql-storage-paged-file-ml-759274120"></a>
### decodeStoredPage

```ml
function decodeStoredPage(pagedFile, pageNumber, stored)
```

Authenticates and decrypts one physical page record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `stored` | `dynamic` | — | stored value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L559)

<a id="function-function-minisql-storage-paged-file-encodestoredpage-function-encodestoredpage-pagedfile-pagenumber-plaintext-src-minisql-storage-paged-file-ml-925043848"></a>
### encodeStoredPage

```ml
function encodeStoredPage(pagedFile, pageNumber, plaintext)
```

Encrypts one logical page into its nonce/ciphertext/tag record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `plaintext` | `dynamic` | — | plaintext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L541)

<a id="function-function-minisql-storage-paged-file-encryptexisting-function-encryptexisting-path-src-minisql-storage-paged-file-ml-72630673"></a>
### encryptExisting

```ml
function encryptExisting(path)
```

Converts one closed plaintext paged file to the encrypted physical stride. The original is replaced only after the complete encrypted copy is durable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L795)

<a id="constant-constant-minisql-storage-paged-file-encryption-nonce-bytes-const-encryption-nonce-bytes-12-src-minisql-storage-paged-file-ml-788842768"></a>
### ENCRYPTION_NONCE_BYTES

```ml
const ENCRYPTION_NONCE_BYTES = 12
```

Defines the encryption nonce bytes constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L39)

<a id="constant-constant-minisql-storage-paged-file-encryption-tag-bytes-const-encryption-tag-bytes-16-src-minisql-storage-paged-file-ml-1819616990"></a>
### ENCRYPTION_TAG_BYTES

```ml
const ENCRYPTION_TAG_BYTES = 16
```

Defines the encryption tag bytes constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L41)

<a id="function-function-minisql-storage-paged-file-fail-function-fail-code-operation-message-src-minisql-storage-paged-file-ml-1707986375"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage paged file module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L78)

<a id="constant-constant-minisql-storage-paged-file-feature-page-encryption-const-feature-page-encryption-1-src-minisql-storage-paged-file-ml-74158586"></a>
### FEATURE_PAGE_ENCRYPTION

```ml
const FEATURE_PAGE_ENCRYPTION = 1
```

Defines the feature page encryption constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L37)

<a id="function-function-minisql-storage-paged-file-flush-function-flush-pagedfile-src-minisql-storage-paged-file-ml-1417914851"></a>
### flush

```ml
function flush(pagedFile)
```

Performs the flush operation for the minisql storage paged file module. Inputs: `pagedFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L731)

<a id="constant-constant-minisql-storage-paged-file-invalid-argument-const-invalid-argument-9001-src-minisql-storage-paged-file-ml-1763068441"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

A paged file begins with two fixed 4096-byte superblock slots followed by a


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L20)

<a id="function-function-minisql-storage-paged-file-isencryptedflags-function-isencryptedflags-featureflags-src-minisql-storage-paged-file-ml-1228996579"></a>
### isEncryptedFlags

```ml
function isEncryptedFlags(featureFlags)
```

Tests the persisted page-encryption feature bit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `featureFlags` | `dynamic` | — | featureFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L148)

<a id="function-function-minisql-storage-paged-file-isimplemented-function-isimplemented-src-minisql-storage-paged-file-ml-1444377680"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage paged file module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L831)

<a id="function-function-minisql-storage-paged-file-maxpagecountfor-function-maxpagecountfor-pagesize-src-minisql-storage-paged-file-ml-751705560"></a>
### maxPageCountFor

```ml
function maxPageCountFor(pageSize)
```

Performs the max page count for operation for this module. Inputs: `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L127)

<a id="function-function-minisql-storage-paged-file-metadatafor-function-metadatafor-pagedfile-generation-pagecount-src-minisql-storage-paged-file-ml-2002367455"></a>
### metadataFor

```ml
function metadataFor(pagedFile, generation, pageCount)
```

Performs the metadata for operation for this module. Inputs: `pagedFile`, `generation`, `pageCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `generation` | `dynamic` | — | generation value consumed by this operation. |
| `pageCount` | `dynamic` | — | Number of page to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L186)

<a id="function-function-minisql-storage-paged-file-open-function-open-path-src-minisql-storage-paged-file-ml-260561029"></a>
### open

```ml
function open(path)
```

Opens open for the minisql storage paged file module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L329)

<a id="function-function-minisql-storage-paged-file-openreadonly-function-openreadonly-path-src-minisql-storage-paged-file-ml-46309937"></a>
### openReadOnly

```ml
function openReadOnly(path)
```

Read plans use independent handles with compatible shared byte-range locks. The database writer gate guarantees that no in-process mutation overlaps; the lock still rejects a lock-aware writer from another owner. Opens the read only. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L394)

<a id="function-function-minisql-storage-paged-file-openreadonlymanaged-function-openreadonlymanaged-path-src-minisql-storage-paged-file-ml-114365527"></a>
### openReadOnlyManaged

```ml
function openReadOnlyManaged(path)
```

Opens a persistent read handle without a per-file byte-range lock. This is restricted to ManagedDatabase-owned caches: the database lock excludes other owners and the physical execution gate excludes in-process writers. Avoiding a long-lived shared file lock lets a later writer replace/rebuild the file before the cache is invalidated at its statement boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L454)

<a id="function-function-minisql-storage-paged-file-pageaad-function-pageaad-pagedfile-pagenumber-src-minisql-storage-paged-file-ml-248335779"></a>
### pageAad

```ml
function pageAad(pagedFile, pageNumber)
```

Binds every encrypted record to its immutable database/file/page identity. Moving ciphertext between pages or files therefore fails GCM authentication.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L528)

- [minisql.storage.paged_file.PagedFile](Type-minisql-storage-paged-file-pagedfile-849665396.md) — struct
<a id="function-function-minisql-storage-paged-file-pageoffset-function-pageoffset-pagedfile-pagenumber-src-minisql-storage-paged-file-ml-357351073"></a>
### pageOffset

```ml
function pageOffset(pagedFile, pageNumber)
```

Performs the page offset operation for this module. Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L156)

<a id="function-function-minisql-storage-paged-file-physicalpagesize-function-physicalpagesize-pagesize-featureflags-src-minisql-storage-paged-file-ml-1634818569"></a>
### physicalPageSize

```ml
function physicalPageSize(pageSize, featureFlags)
```

Returns the fixed physical stride for plaintext or encrypted page records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `featureFlags` | `dynamic` | — | featureFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L141)

<a id="function-function-minisql-storage-paged-file-readpage-function-readpage-pagedfile-pagenumber-src-minisql-storage-paged-file-ml-2025164005"></a>
### readPage

```ml
function readPage(pagedFile, pageNumber)
```

Reads the page. Inputs: `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L584)

<a id="function-function-minisql-storage-paged-file-readpagewithcontext-function-readpagewithcontext-pagedfile-pagenumber-readcontext-src-minisql-storage-paged-file-ml-1803038240"></a>
### readPageWithContext

```ml
function readPageWithContext(pagedFile, pageNumber, readContext)
```

Reads and verifies one page while reusing the caller's positioned-I/O state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `readContext` | `dynamic` | — | readContext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L592)

<a id="function-function-minisql-storage-paged-file-readslot-function-readslot-file-slot-src-minisql-storage-paged-file-ml-1083646958"></a>
### readSlot

```ml
function readSlot(file, slot)
```

Reads the slot. Inputs: `file`, `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `slot` | `dynamic` | — | slot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L293)

<a id="constant-constant-minisql-storage-paged-file-slot-a-const-slot-a-0-src-minisql-storage-paged-file-ml-1654825035"></a>
### SLOT_A

```ml
const SLOT_A = 0
```

Defines the slot a constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L27)

<a id="constant-constant-minisql-storage-paged-file-slot-a-offset-const-slot-a-offset-0-src-minisql-storage-paged-file-ml-587222861"></a>
### SLOT_A_OFFSET

```ml
const SLOT_A_OFFSET = 0
```

Defines the slot a offset constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L31)

<a id="constant-constant-minisql-storage-paged-file-slot-b-const-slot-b-1-src-minisql-storage-paged-file-ml-1538045490"></a>
### SLOT_B

```ml
const SLOT_B = 1
```

Defines the slot b constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L29)

<a id="constant-constant-minisql-storage-paged-file-slot-b-offset-const-slot-b-offset-4096-src-minisql-storage-paged-file-ml-1019520760"></a>
### SLOT_B_OFFSET

```ml
const SLOT_B_OFFSET = 4096
```

Defines the slot b offset constant used by the minisql storage paged file module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L33)

<a id="function-function-minisql-storage-paged-file-slotoffset-function-slotoffset-slot-src-minisql-storage-paged-file-ml-337781288"></a>
### slotOffset

```ml
function slotOffset(slot)
```

Performs the slotOffset operation for the minisql storage paged file module. Inputs: `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — | slot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L118)

<a id="function-function-minisql-storage-paged-file-snapshotdurablebytes-function-snapshotdurablebytes-pagedfile-maxbytes-src-minisql-storage-paged-file-ml-764852268"></a>
### snapshotDurableBytes

```ml
function snapshotDurableBytes(pagedFile, maxBytes)
```

Flush and return a byte-for-byte image through the handle that already owns the exclusive file lock. Opening the same path through a second handle would make Windows reject overlapping reads with ERROR_LOCK_VIOLATION (33). Transactional DDL uses this to capture durable before-images without weakening the paged-file single-owner lock contract. Performs the snapshot durable bytes operation for this module. Inputs: `pagedFile`, `maxBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `maxBytes` | `dynamic` | — | maxBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L775)

<a id="function-function-minisql-storage-paged-file-storepage-function-storepage-pagedfile-pagenumber-plaintext-src-minisql-storage-paged-file-ml-1683452264"></a>
### storePage

```ml
function storePage(pagedFile, pageNumber, plaintext)
```

Encodes and writes one logical page at its fixed physical offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `plaintext` | `dynamic` | — | plaintext value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L572)

<a id="function-function-minisql-storage-paged-file-targetmilestone-function-targetmilestone-src-minisql-storage-paged-file-ml-334697006"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage paged file module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L825)

<a id="function-function-minisql-storage-paged-file-truncatepages-function-truncatepages-pagedfile-newpagecount-src-minisql-storage-paged-file-ml-745997407"></a>
### truncatePages

```ml
function truncatePages(pagedFile, newPageCount)
```

Shrinks the committed page range without ever advertising bytes that are not durable. Publishing the smaller superblock first makes an interrupted physical truncate recoverable: open() already discards an uncommitted tail. Inputs: `pagedFile`, `newPageCount`. Returns true after the smaller page range and physical file length are durable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `newPageCount` | `dynamic` | — | Number of new page to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L742)

<a id="function-function-minisql-storage-paged-file-validatedatabaseid-function-validatedatabaseid-databaseid-operation-src-minisql-storage-paged-file-ml-1749429277"></a>
### validateDatabaseId

```ml
function validateDatabaseId(databaseId, operation)
```

Validates database id for the minisql storage paged file workflow. Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L86)

<a id="function-function-minisql-storage-paged-file-validatenativeid-function-validatenativeid-value-operation-name-src-minisql-storage-paged-file-ml-1103863335"></a>
### validateNativeId

```ml
function validateNativeId(value, operation, name)
```

Validates native id for the minisql storage paged file workflow. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L98)

<a id="function-function-minisql-storage-paged-file-validateopen-function-validateopen-pagedfile-operation-src-minisql-storage-paged-file-ml-567239104"></a>
### validateOpen

```ml
function validateOpen(pagedFile, operation)
```

Validates open for the minisql storage paged file workflow. Inputs: `pagedFile`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L109)

<a id="function-function-minisql-storage-paged-file-validatepageidentity-function-validatepageidentity-pagedfile-pagebytes-expectedpagenumber-operation-src-minisql-storage-paged-file-ml-339178968"></a>
### validatePageIdentity

```ml
function validatePageIdentity(pagedFile, pageBytes, expectedPageNumber, operation)
```

Validates the page identity. Inputs: `pagedFile`, `pageBytes`, `expectedPageNumber`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `expectedPageNumber` | `dynamic` | — | expectedPageNumber value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L509)

<a id="function-function-minisql-storage-paged-file-writecontiguouspages-function-writecontiguouspages-pagedfile-firstpagenumber-pageimages-src-minisql-storage-paged-file-ml-1947973420"></a>
### writeContiguousPages

```ml
function writeContiguousPages(pagedFile, firstPageNumber, pageImages)
```

Publishes a bounded sequence of consecutive page images with one positioned operating-system write. Every image is validated before any byte is written, so a malformed batch cannot partially modify the base file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `firstPageNumber` | `dynamic` | — | firstPageNumber value consumed by this operation. |
| `pageImages` | `dynamic` | — | pageImages value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L707)

<a id="function-function-minisql-storage-paged-file-writepage-function-writepage-pagedfile-pagenumber-pagebytes-src-minisql-storage-paged-file-ml-33689443"></a>
### writePage

```ml
function writePage(pagedFile, pageNumber, pageBytes)
```

Writes the page. Inputs: `pagedFile`, `pageNumber`, `pageBytes`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L692)

<a id="function-function-minisql-storage-paged-file-writeslot-function-writeslot-file-slot-metadata-src-minisql-storage-paged-file-ml-547582859"></a>
### writeSlot

```ml
function writeSlot(file, slot, metadata)
```

Writes the slot. Inputs: `file`, `slot`, `metadata`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `slot` | `dynamic` | — | slot value consumed by this operation. |
| `metadata` | `dynamic` | — | metadata value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/paged_file.ml#L204)
