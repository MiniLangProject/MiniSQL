# `src/minisql/storage/heap_file.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.storage.heap_file`](Package-minisql-storage-heap-file-555422342.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/storage/checksum.ml` as `checksum` → [src/minisql/storage/checksum.ml](File-src-minisql-storage-checksum-ml-273339408.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/slotted_page.ml` as `slotted` → [src/minisql/storage/slotted_page.ml](File-src-minisql-storage-slotted-page-ml-1299577846.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-storage-heap-file-bytesequal-function-bytesequal-left-right-src-minisql-storage-heap-file-ml-79159967"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L119)

<a id="function-function-minisql-storage-heap-file-classifyheappages-function-classifyheappages-file-startpage-prefix-src-minisql-storage-heap-file-ml-571435123"></a>
### classifyHeapPages

```ml
function classifyHeapPages(file, startPage, prefix)
```

Classifies a source suffix after the caller has established that an existing directory prefix is reusable. Each new page is checksum-verified exactly once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `startPage` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L237)

<a id="function-function-minisql-storage-heap-file-close-function-close-heap-src-minisql-storage-heap-file-ml-178387068"></a>
### close

```ml
function close(heap)
```

Closes the requested value. Inputs: `heap`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L631)

<a id="constant-constant-minisql-storage-heap-file-closed-handle-const-closed-handle-9008-src-minisql-storage-heap-file-ml-653597136"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L21)

<a id="function-function-minisql-storage-heap-file-componentname-function-componentname-src-minisql-storage-heap-file-ml-1344332010"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L640)

<a id="function-function-minisql-storage-heap-file-containsrowid-function-containsrowid-values-sought-src-minisql-storage-heap-file-ml-1626062382"></a>
### containsRowId

```ml
function containsRowId(values, sought)
```

Performs the contains row id operation for this module. Inputs: `values`, `sought`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `sought` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L327)

<a id="constant-constant-minisql-storage-heap-file-corrupt-data-const-corrupt-data-9004-src-minisql-storage-heap-file-ml-521517622"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L20)

<a id="function-function-minisql-storage-heap-file-count-function-count-heap-src-minisql-storage-heap-file-ml-1106331446"></a>
### count

```ml
function count(heap)
```

Counts the requested value. Inputs: `heap`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L625)

<a id="function-function-minisql-storage-heap-file-create-function-create-path-pagesize-fileid-databaseid-src-minisql-storage-heap-file-ml-535174448"></a>
### create

```ml
function create(path, pageSize, fileId, databaseId)
```

Creates the requested value. Inputs: `path`, `pageSize`, `fileId`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |
| `fileId` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L363)

<a id="function-function-minisql-storage-heap-file-decodedirectorynative-function-decodedirectorynative-words-operation-name-src-minisql-storage-heap-file-ml-831587347"></a>
### decodeDirectoryNative

```ml
function decodeDirectoryNative(words, operation, name)
```

Converts a persisted U64 into the native MiniLang range used by page APIs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L129)

<a id="function-function-minisql-storage-heap-file-decodeforward-function-decodeforward-value-src-minisql-storage-heap-file-ml-135225589"></a>
### decodeForward

```ml
function decodeForward(value)
```

Decodes the forward. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L352)

<a id="function-function-minisql-storage-heap-file-decodepagedirectory-function-decodepagedirectory-file-encoded-src-minisql-storage-heap-file-ml-724228542"></a>
### decodePageDirectory

```ml
function decodePageDirectory(file, encoded)
```

Decodes and validates a page directory against immutable table identity. Ordering and bounds checks prevent a malformed sidecar from causing repeated, out-of-range, or non-monotonic page reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L197)

<a id="function-function-minisql-storage-heap-file-encodeforward-function-encodeforward-target-src-minisql-storage-heap-file-ml-357007645"></a>
### encodeForward

```ml
function encodeForward(target)
```

Encodes the forward. Inputs: `target`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L336)

<a id="function-function-minisql-storage-heap-file-encodepagedirectory-function-encodepagedirectory-file-directory-src-minisql-storage-heap-file-ml-452538919"></a>
### encodePageDirectory

```ml
function encodePageDirectory(file, directory)
```

Encodes the table identity, source frontier, generation, and heap page list. Every number is U64 on disk so directory capacity follows the table format.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `directory` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L172)

<a id="function-function-minisql-storage-heap-file-fail-function-fail-code-operation-message-src-minisql-storage-heap-file-ml-1461836375"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L94)

<a id="constant-constant-minisql-storage-heap-file-forward-size-const-forward-size-24-src-minisql-storage-heap-file-ml-2080602417"></a>
### FORWARD_SIZE

```ml
const FORWARD_SIZE = 24
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L25)

<a id="function-function-minisql-storage-heap-file-forwardingmagic-function-forwardingmagic-src-minisql-storage-heap-file-ml-1428612930"></a>
### forwardingMagic

```ml
function forwardingMagic()
```

Performs the forwarding magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L100)

- [minisql.storage.heap_file.HeapFile](Type-minisql-storage-heap-file-heapfile-2088479080.md) — struct
- [minisql.storage.heap_file.HeapPageDirectory](Type-minisql-storage-heap-file-heappagedirectory-873951192.md) — struct
<a id="function-function-minisql-storage-heap-file-heappagenumbers-function-heappagenumbers-file-src-minisql-storage-heap-file-ml-1360821622"></a>
### heapPageNumbers

```ml
function heapPageNumbers(file)
```

Returns the persistent physical heap-page index for an open table. The immutable exact-generation fast path is safe for parallel readers and avoids serializing every SELECT. Only stale or missing sidecars enter the guarded rebuild, which rechecks after acquiring the publication lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L288)

- [minisql.storage.heap_file.HeapRow](Type-minisql-storage-heap-file-heaprow-40418530.md) — struct
<a id="function-function-minisql-storage-heap-file-initialinsertionpage-function-initialinsertionpage-file-src-minisql-storage-heap-file-ml-1143491132"></a>
### initialInsertionPage

```ml
function initialInsertionPage(file)
```

Finds the first page containing a reusable deleted slot after reopening a heap, otherwise selecting the append frontier. The one-time scan preserves durable slot reuse without repeating it for every row in a batch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L371)

<a id="function-function-minisql-storage-heap-file-insert-function-insert-heap-recordbytes-src-minisql-storage-heap-file-ml-253062440"></a>
### insert

```ml
function insert(heap, recordBytes)
```

Inserts the requested value. Inputs: `heap`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L515)

<a id="function-function-minisql-storage-heap-file-insertwithflags-function-insertwithflags-heap-recordbytes-slotflags-src-minisql-storage-heap-file-ml-1810912075"></a>
### insertWithFlags

```ml
function insertWithFlags(heap, recordBytes, slotFlags)
```

Inserts the with flags. Inputs: `heap`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |
| `slotFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L458)

<a id="constant-constant-minisql-storage-heap-file-invalid-argument-const-invalid-argument-9001-src-minisql-storage-heap-file-ml-145240741"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Heap-file storage built on stable slotted pages. External RowId values contain the slot generation, so a deleted and later reused slot cannot alias an older row. Growing updates preserve the original RowId through forwarding records.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L19)

<a id="function-function-minisql-storage-heap-file-invalidatepagedirectory-synchronized-function-invalidatepagedirectory-tablepath-src-minisql-storage-heap-file-ml-1895287139"></a>
### invalidatePageDirectory

```ml
synchronized function invalidatePageDirectory(tablePath)
```

Removes the live and interrupted page-directory generations. Callers use this before physical table replacement; a subsequent scan rebuilds safely.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tablePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L301)

<a id="function-function-minisql-storage-heap-file-isheappagedirectory-function-isheappagedirectory-value-src-minisql-storage-heap-file-ml-1202133551"></a>
### isHeapPageDirectory

```ml
function isHeapPageDirectory(value)
```

Reports whether a value is a decoded heap-page directory snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L88)

<a id="function-function-minisql-storage-heap-file-isimplemented-function-isimplemented-src-minisql-storage-heap-file-ml-1146114082"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L652)

<a id="function-function-minisql-storage-heap-file-loadpagedirectory-function-loadpagedirectory-file-src-minisql-storage-heap-file-ml-944916308"></a>
### loadPageDirectory

```ml
function loadPageDirectory(file)
```

Returns a decoded sidecar or void when it is missing, stale, unreadable, or corrupt. Derived metadata never makes authoritative table data unavailable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L225)

<a id="function-function-minisql-storage-heap-file-loadslot-function-loadslot-heap-identifier-operation-src-minisql-storage-heap-file-ml-650579536"></a>
### loadSlot

```ml
function loadSlot(heap, identifier, operation)
```

Loads the slot. Inputs: `heap`, `identifier`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `identifier` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L418)

<a id="constant-constant-minisql-storage-heap-file-max-forward-depth-const-max-forward-depth-64-src-minisql-storage-heap-file-ml-284393849"></a>
### MAX_FORWARD_DEPTH

```ml
const MAX_FORWARD_DEPTH = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L26)

<a id="function-function-minisql-storage-heap-file-open-function-open-path-src-minisql-storage-heap-file-ml-265442793"></a>
### open

```ml
function open(path)
```

Opens the requested value. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L391)

<a id="constant-constant-minisql-storage-heap-file-page-directory-format-version-const-page-directory-format-version-1-src-minisql-storage-heap-file-ml-922673938"></a>
### PAGE_DIRECTORY_FORMAT_VERSION

```ml
const PAGE_DIRECTORY_FORMAT_VERSION = 1
```

The page directory is derived metadata: it records only physical heap-page numbers and can always be reconstructed from the checksummed table file. Its atomic envelope makes interrupted updates harmless, while the source page count and superblock generation detect stale snapshots after file growth.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L32)

<a id="constant-constant-minisql-storage-heap-file-page-directory-header-bytes-const-page-directory-header-bytes-64-src-minisql-storage-heap-file-ml-24710745"></a>
### PAGE_DIRECTORY_HEADER_BYTES

```ml
const PAGE_DIRECTORY_HEADER_BYTES = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L34)

<a id="constant-constant-minisql-storage-heap-file-page-directory-record-kind-const-page-directory-record-kind-51-src-minisql-storage-heap-file-ml-962896439"></a>
### PAGE_DIRECTORY_RECORD_KIND

```ml
const PAGE_DIRECTORY_RECORD_KIND = 51
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L33)

<a id="function-function-minisql-storage-heap-file-pagedirectorymagic-function-pagedirectorymagic-src-minisql-storage-heap-file-ml-1284114298"></a>
### pageDirectoryMagic

```ml
function pageDirectoryMagic()
```

Returns the fixed magic used by persistent heap-page directory envelopes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L105)

<a id="function-function-minisql-storage-heap-file-pagedirectorypath-function-pagedirectorypath-tablepath-src-minisql-storage-heap-file-ml-1267126387"></a>
### pageDirectoryPath

```ml
function pageDirectoryPath(tablePath)
```

Returns the sidecar path associated with a physical table file. Keeping the suffix next to the table makes backup/restore tooling able to ignore it as derived state without changing the authoritative database format.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tablePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L112)

<a id="function-function-minisql-storage-heap-file-read-function-read-heap-identifier-src-minisql-storage-heap-file-ml-1974969595"></a>
### read

```ml
function read(heap, identifier)
```

Reads the requested value. Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `identifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L521)

<a id="function-function-minisql-storage-heap-file-readdirectorybytes-function-readdirectorybytes-path-src-minisql-storage-heap-file-ml-1696064845"></a>
### readDirectoryBytes

```ml
function readDirectoryBytes(path)
```

Reads an arbitrarily sized derived sidecar without imposing a catalog-style policy limit. The native file and byte-array limits remain the only bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L136)

<a id="function-function-minisql-storage-heap-file-rebuildheappagenumbers-synchronized-function-rebuildheappagenumbers-file-src-minisql-storage-heap-file-ml-1781913850"></a>
### rebuildHeapPageNumbers

```ml
synchronized function rebuildHeapPageNumbers(file)
```

Rechecks and rebuilds a stale page directory under the process-wide publication guard. The single return path is intentional: every platform must release the synchronized-function guard before a caller can retry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L259)

<a id="function-function-minisql-storage-heap-file-remove-function-remove-heap-identifier-src-minisql-storage-heap-file-ml-818635795"></a>
### remove

```ml
function remove(heap, identifier)
```

Removes the requested value. Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `identifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L563)

<a id="function-function-minisql-storage-heap-file-resolve-function-resolve-heap-identifier-src-minisql-storage-heap-file-ml-657359131"></a>
### resolve

```ml
function resolve(heap, identifier)
```

Performs the resolve operation for this module. Inputs: `heap`, `identifier`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `identifier` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L432)

- [minisql.storage.heap_file.ResolvedRow](Type-minisql-storage-heap-file-resolvedrow-1857803540.md) — struct
<a id="constant-constant-minisql-storage-heap-file-row-not-found-const-row-not-found-9016-src-minisql-storage-heap-file-ml-1731797833"></a>
### ROW_NOT_FOUND

```ml
const ROW_NOT_FOUND = 9016
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L22)

<a id="function-function-minisql-storage-heap-file-rowid-function-rowid-pagenumber-slotid-generation-src-minisql-storage-heap-file-ml-499360953"></a>
### rowId

```ml
function rowId(pageNumber, slotId, generation)
```

Performs the row id operation for this module. Inputs: `pageNumber`, `slotId`, `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageNumber` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `generation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L311)

- [minisql.storage.heap_file.RowId](Type-minisql-storage-heap-file-rowid-60550609.md) — struct
<a id="function-function-minisql-storage-heap-file-samerowid-function-samerowid-left-right-src-minisql-storage-heap-file-ml-1007505825"></a>
### sameRowId

```ml
function sameRowId(left, right)
```

Compares the row id. Inputs: `left`, `right`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L320)

<a id="function-function-minisql-storage-heap-file-scan-function-scan-heap-src-minisql-storage-heap-file-ml-2129234564"></a>
### scan

```ml
function scan(heap)
```

Scans the requested value. Inputs: `heap`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L602)

<a id="constant-constant-minisql-storage-heap-file-stale-reference-const-stale-reference-9018-src-minisql-storage-heap-file-ml-244491267"></a>
### STALE_REFERENCE

```ml
const STALE_REFERENCE = 9018
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L23)

<a id="function-function-minisql-storage-heap-file-targetmilestone-function-targetmilestone-src-minisql-storage-heap-file-ml-1698423216"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L646)

<a id="function-function-minisql-storage-heap-file-update-function-update-heap-identifier-recordbytes-src-minisql-storage-heap-file-ml-1276580385"></a>
### update

```ml
function update(heap, identifier, recordBytes)
```

Updates the requested value. Inputs: `heap`, `identifier`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `identifier` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L527)

<a id="function-function-minisql-storage-heap-file-validateidentifier-function-validateidentifier-identifier-operation-src-minisql-storage-heap-file-ml-333123162"></a>
### validateIdentifier

```ml
function validateIdentifier(identifier, operation)
```

Validates the identifier. Inputs: `identifier`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `identifier` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L410)

<a id="function-function-minisql-storage-heap-file-validateopen-function-validateopen-heap-operation-src-minisql-storage-heap-file-ml-2137086473"></a>
### validateOpen

```ml
function validateOpen(heap, operation)
```

Validates the open. Inputs: `heap`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L401)

<a id="function-function-minisql-storage-heap-file-writedirectoryatomic-function-writedirectoryatomic-path-encoded-src-minisql-storage-heap-file-ml-1877778845"></a>
### writeDirectoryAtomic

```ml
function writeDirectoryAtomic(path, encoded)
```

Atomically publishes a checksummed directory. A crash leaves either the old complete generation or an ignorable `.new` file, never a partial live map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/heap_file.ml#L153)
