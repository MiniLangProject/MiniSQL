# `src/minisql/storage/buffer_pool.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.storage.buffer_pool`](Package-minisql-storage-buffer-pool-1005509826.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/limits.ml` as `limits` → [src/minisql/common/limits.ml](File-src-minisql-common-limits-ml-173680577.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency
- `std/threading.ml` as `threading` → `../MiniLangCompilerML/std/threading.ml` — external dependency

## Declarations

<a id="constant-constant-minisql-storage-buffer-pool-buffer-pool-exhausted-const-buffer-pool-exhausted-9009-src-minisql-storage-buffer-pool-ml-533716185"></a>
### BUFFER_POOL_EXHAUSTED

```ml
const BUFFER_POOL_EXHAUSTED = 9009
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L17)

- [minisql.storage.buffer_pool.BufferFrame](Type-minisql-storage-buffer-pool-bufferframe-638046543.md) — struct
- [minisql.storage.buffer_pool.BufferPool](Type-minisql-storage-buffer-pool-bufferpool-1687714260.md) — struct
- [minisql.storage.buffer_pool.BufferPoolStats](Type-minisql-storage-buffer-pool-bufferpoolstats-1872246015.md) — struct
<a id="function-function-minisql-storage-buffer-pool-cachedrowcount-function-cachedrowcount-cache-tablepath-src-minisql-storage-buffer-pool-ml-1274774075"></a>
### cachedRowCount

```ml
function cachedRowCount(cache, tablePath)
```

Returns a previously verified autocommit row count or void on a cache miss.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |
| `tablePath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L297)

<a id="function-function-minisql-storage-buffer-pool-choosereadvictim-function-choosereadvictim-cache-src-minisql-storage-buffer-pool-ml-18702156"></a>
### chooseReadVictim

```ml
function chooseReadVictim(cache)
```

Chooses an empty frame or an unreferenced CLOCK victim while the cache guard is held. Read frames are never pinned or dirty, so two passes always suffice.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L224)

<a id="function-function-minisql-storage-buffer-pool-choosevictim-function-choosevictim-pool-src-minisql-storage-buffer-pool-ml-1046285356"></a>
### chooseVictim

```ml
function chooseVictim(pool)
```

Performs the choose victim operation for this module. Inputs: `pool`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L399)

<a id="function-function-minisql-storage-buffer-pool-clearreadcache-function-clearreadcache-cache-src-minisql-storage-buffer-pool-ml-2054206908"></a>
### clearReadCache

```ml
function clearReadCache(cache)
```

Invalidates all cached base pages after a successful database mutation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L285)

<a id="function-function-minisql-storage-buffer-pool-close-function-close-pool-src-minisql-storage-buffer-pool-ml-1343295024"></a>
### close

```ml
function close(pool)
```

Closes the requested value. Inputs: `pool`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L541)

<a id="constant-constant-minisql-storage-buffer-pool-closed-handle-const-closed-handle-9008-src-minisql-storage-buffer-pool-ml-1104187820"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L16)

<a id="function-function-minisql-storage-buffer-pool-closereadcache-function-closereadcache-cache-src-minisql-storage-buffer-pool-ml-2135176572"></a>
### closeReadCache

```ml
function closeReadCache(cache)
```

Closes a read cache after the owning database execution gate is empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L328)

<a id="function-function-minisql-storage-buffer-pool-componentname-function-componentname-src-minisql-storage-buffer-pool-ml-741996378"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L556)

<a id="function-function-minisql-storage-buffer-pool-create-function-create-capacity-src-minisql-storage-buffer-pool-ml-1670214626"></a>
### create

```ml
function create(capacity)
```

Creates the requested value. Inputs: `capacity`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `capacity` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L153)

<a id="function-function-minisql-storage-buffer-pool-createforbytes-function-createforbytes-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1645980885"></a>
### createForBytes

```ml
function createForBytes(maxBytes, pageSize)
```

Creates the for bytes. Inputs: `maxBytes`, `pageSize`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxBytes` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L166)

<a id="function-function-minisql-storage-buffer-pool-createreadcache-function-createreadcache-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1210908789"></a>
### createReadCache

```ml
function createReadCache(maxBytes, pageSize)
```

Creates the concurrent read cache for a configured memory budget.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxBytes` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L205)

<a id="function-function-minisql-storage-buffer-pool-data-function-data-guard-src-minisql-storage-buffer-pool-ml-2136919623"></a>
### data

```ml
function data(guard)
```

Performs the data operation for this module. Inputs: `guard`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `guard` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L466)

<a id="function-function-minisql-storage-buffer-pool-emptyframe-function-emptyframe-src-minisql-storage-buffer-pool-ml-390741682"></a>
### emptyFrame

```ml
function emptyFrame()
```

Performs the empty frame operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L147)

<a id="function-function-minisql-storage-buffer-pool-fail-function-fail-code-operation-message-src-minisql-storage-buffer-pool-ml-1163316955"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L141)

<a id="function-function-minisql-storage-buffer-pool-findframe-function-findframe-pool-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1783315445"></a>
### findFrame

```ml
function findFrame(pool, pagedFile, pageNumber)
```

Finds the frame. Inputs: `pool`, `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L376)

<a id="function-function-minisql-storage-buffer-pool-flushall-function-flushall-pool-src-minisql-storage-buffer-pool-ml-713790404"></a>
### flushAll

```ml
function flushAll(pool)
```

Flushes the all. Inputs: `pool`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L491)

<a id="function-function-minisql-storage-buffer-pool-flushframe-function-flushframe-pool-frameindex-src-minisql-storage-buffer-pool-ml-1353113699"></a>
### flushFrame

```ml
function flushFrame(pool, frameIndex)
```

Flushes the frame. Inputs: `pool`, `frameIndex`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `frameIndex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L386)

<a id="function-function-minisql-storage-buffer-pool-framematchesfile-function-framematchesfile-frame-pagedfile-src-minisql-storage-buffer-pool-ml-2008803846"></a>
### frameMatchesFile

```ml
function frameMatchesFile(frame, pagedFile)
```

Performs the frame matches file operation for this module. Inputs: `frame`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L366)

<a id="constant-constant-minisql-storage-buffer-pool-invalid-argument-const-invalid-argument-9001-src-minisql-storage-buffer-pool-ml-1360933269"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Fixed-capacity buffer pool with explicit pin/unpin guards and CLOCK eviction. Dirty pages are resealed and written through the owning PagedFile before reuse.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L15)

<a id="function-function-minisql-storage-buffer-pool-invalidatefile-function-invalidatefile-pool-pagedfile-src-minisql-storage-buffer-pool-ml-1733667803"></a>
### invalidateFile

```ml
function invalidateFile(pool, pagedFile)
```

Performs the invalidate file operation for this module. Inputs: `pool`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L502)

<a id="function-function-minisql-storage-buffer-pool-isimplemented-function-isimplemented-src-minisql-storage-buffer-pool-ml-133080114"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L568)

<a id="function-function-minisql-storage-buffer-pool-markdirty-function-markdirty-guard-src-minisql-storage-buffer-pool-ml-1660583357"></a>
### markDirty

```ml
function markDirty(guard)
```

Marks the dirty. Inputs: `guard`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `guard` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L473)

<a id="function-function-minisql-storage-buffer-pool-pagecapacity-function-pagecapacity-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1883188421"></a>
### pageCapacity

```ml
function pageCapacity(maxBytes, pageSize)
```

Converts a byte budget to pages using the database's validated page size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxBytes` | `dynamic` | — |  |
| `pageSize` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L190)

- [minisql.storage.buffer_pool.PageGuard](Type-minisql-storage-buffer-pool-pageguard-224112748.md) — struct
<a id="function-function-minisql-storage-buffer-pool-pin-function-pin-pool-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1230847963"></a>
### pin

```ml
function pin(pool, pagedFile, pageNumber)
```

Performs the pin operation for this module. Inputs: `pool`, `pagedFile`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L426)

<a id="constant-constant-minisql-storage-buffer-pool-pinned-page-const-pinned-page-9010-src-minisql-storage-buffer-pool-ml-65569783"></a>
### PINNED_PAGE

```ml
const PINNED_PAGE = 9010
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L18)

<a id="function-function-minisql-storage-buffer-pool-readcached-function-readcached-cache-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1764087589"></a>
### readCached

```ml
function readCached(cache, pagedFile, pageNumber)
```

Reads through the concurrent cache. Disk I/O occurs without holding the cache guard; a second lookup collapses races when two readers miss together.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L244)

- [minisql.storage.buffer_pool.ReadCacheFrame](Type-minisql-storage-buffer-pool-readcacheframe-1870403107.md) — struct
<a id="function-function-minisql-storage-buffer-pool-readcachekey-function-readcachekey-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-2037418875"></a>
### readCacheKey

```ml
function readCacheKey(pagedFile, pageNumber)
```

Builds an unambiguous cache key; page paths cannot contain a NUL character.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L218)

<a id="function-function-minisql-storage-buffer-pool-readcachestats-function-readcachestats-cache-src-minisql-storage-buffer-pool-ml-1211588368"></a>
### readCacheStats

```ml
function readCacheStats(cache)
```

Returns a synchronized diagnostic snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L319)

- [minisql.storage.buffer_pool.ReadPageCache](Type-minisql-storage-buffer-pool-readpagecache-1005097079.md) — struct
- [minisql.storage.buffer_pool.ReadPageCacheStats](Type-minisql-storage-buffer-pool-readpagecachestats-126033402.md) — struct
<a id="function-function-minisql-storage-buffer-pool-release-function-release-guard-src-minisql-storage-buffer-pool-ml-340368909"></a>
### release

```ml
function release(guard)
```

Releases the requested value. Inputs: `guard`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `guard` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L482)

<a id="function-function-minisql-storage-buffer-pool-rememberrowcount-function-rememberrowcount-cache-tablepath-rowcount-src-minisql-storage-buffer-pool-ml-1785565004"></a>
### rememberRowCount

```ml
function rememberRowCount(cache, tablePath, rowCount)
```

Publishes a verified autocommit row count. Concurrent readers may race to publish the same value because writers are excluded by the execution gate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |
| `tablePath` | `dynamic` | — |  |
| `rowCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L308)

<a id="function-function-minisql-storage-buffer-pool-stats-function-stats-pool-src-minisql-storage-buffer-pool-ml-669831546"></a>
### stats

```ml
function stats(pool)
```

Performs the stats operation for this module. Inputs: `pool`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L525)

<a id="function-function-minisql-storage-buffer-pool-targetmilestone-function-targetmilestone-src-minisql-storage-buffer-pool-ml-617924676"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L562)

<a id="function-function-minisql-storage-buffer-pool-validateguard-function-validateguard-guard-operation-src-minisql-storage-buffer-pool-ml-1576480310"></a>
### validateGuard

```ml
function validateGuard(guard, operation)
```

Validates the guard. Inputs: `guard`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `guard` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L350)

<a id="function-function-minisql-storage-buffer-pool-validatepool-function-validatepool-pool-operation-src-minisql-storage-buffer-pool-ml-537066945"></a>
### validatePool

```ml
function validatePool(pool, operation)
```

Validates the pool. Inputs: `pool`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L342)

<a id="function-function-minisql-storage-buffer-pool-validatereadcache-function-validatereadcache-cache-operation-src-minisql-storage-buffer-pool-ml-218451729"></a>
### validateReadCache

```ml
function validateReadCache(cache, operation)
```

Validates a read cache before synchronization or I/O.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L211)
