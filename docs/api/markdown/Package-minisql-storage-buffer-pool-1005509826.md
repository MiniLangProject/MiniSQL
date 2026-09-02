# Package `minisql.storage.buffer_pool`

[Home](README.md) · [Packages](Packages.md)

## Files

- [src/minisql/storage/buffer_pool.ml](File-src-minisql-storage-buffer-pool-ml-1867626530.md)

## Symbols

- [`minisql.storage.buffer_pool.BUFFER_POOL_EXHAUSTED`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#constant-constant-minisql-storage-buffer-pool-buffer-pool-exhausted-const-buffer-pool-exhausted-9009-src-minisql-storage-buffer-pool-ml-533716185) — constant
- [`minisql.storage.buffer_pool.BufferFrame`](Type-minisql-storage-buffer-pool-bufferframe-638046543.md) — struct
- [`minisql.storage.buffer_pool.BufferPool`](Type-minisql-storage-buffer-pool-bufferpool-1687714260.md) — struct
- [`minisql.storage.buffer_pool.BufferPoolStats`](Type-minisql-storage-buffer-pool-bufferpoolstats-1872246015.md) — struct
- [`minisql.storage.buffer_pool.cachedRowCount`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-cachedrowcount-function-cachedrowcount-cache-tablepath-src-minisql-storage-buffer-pool-ml-1274774075) — function
- [`minisql.storage.buffer_pool.chooseReadVictim`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-choosereadvictim-function-choosereadvictim-cache-src-minisql-storage-buffer-pool-ml-18702156) — function
- [`minisql.storage.buffer_pool.chooseVictim`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-choosevictim-function-choosevictim-pool-src-minisql-storage-buffer-pool-ml-1046285356) — function
- [`minisql.storage.buffer_pool.clearReadCache`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-clearreadcache-function-clearreadcache-cache-src-minisql-storage-buffer-pool-ml-2054206908) — function
- [`minisql.storage.buffer_pool.close`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-close-function-close-pool-src-minisql-storage-buffer-pool-ml-1343295024) — function
- [`minisql.storage.buffer_pool.CLOSED_HANDLE`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#constant-constant-minisql-storage-buffer-pool-closed-handle-const-closed-handle-9008-src-minisql-storage-buffer-pool-ml-1104187820) — constant
- [`minisql.storage.buffer_pool.closeReadCache`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-closereadcache-function-closereadcache-cache-src-minisql-storage-buffer-pool-ml-2135176572) — function
- [`minisql.storage.buffer_pool.componentName`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-componentname-function-componentname-src-minisql-storage-buffer-pool-ml-741996378) — function
- [`minisql.storage.buffer_pool.create`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-create-function-create-capacity-src-minisql-storage-buffer-pool-ml-1670214626) — function
- [`minisql.storage.buffer_pool.createForBytes`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-createforbytes-function-createforbytes-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1645980885) — function
- [`minisql.storage.buffer_pool.createReadCache`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-createreadcache-function-createreadcache-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1210908789) — function
- [`minisql.storage.buffer_pool.data`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-data-function-data-guard-src-minisql-storage-buffer-pool-ml-2136919623) — function
- [`minisql.storage.buffer_pool.emptyFrame`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-emptyframe-function-emptyframe-src-minisql-storage-buffer-pool-ml-390741682) — function
- [`minisql.storage.buffer_pool.fail`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-fail-function-fail-code-operation-message-src-minisql-storage-buffer-pool-ml-1163316955) — function
- [`minisql.storage.buffer_pool.findFrame`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-findframe-function-findframe-pool-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1783315445) — function
- [`minisql.storage.buffer_pool.flushAll`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-flushall-function-flushall-pool-src-minisql-storage-buffer-pool-ml-713790404) — function
- [`minisql.storage.buffer_pool.flushFrame`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-flushframe-function-flushframe-pool-frameindex-src-minisql-storage-buffer-pool-ml-1353113699) — function
- [`minisql.storage.buffer_pool.frameMatchesFile`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-framematchesfile-function-framematchesfile-frame-pagedfile-src-minisql-storage-buffer-pool-ml-2008803846) — function
- [`minisql.storage.buffer_pool.INVALID_ARGUMENT`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#constant-constant-minisql-storage-buffer-pool-invalid-argument-const-invalid-argument-9001-src-minisql-storage-buffer-pool-ml-1360933269) — constant
- [`minisql.storage.buffer_pool.invalidateFile`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-invalidatefile-function-invalidatefile-pool-pagedfile-src-minisql-storage-buffer-pool-ml-1733667803) — function
- [`minisql.storage.buffer_pool.isImplemented`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-isimplemented-function-isimplemented-src-minisql-storage-buffer-pool-ml-133080114) — function
- [`minisql.storage.buffer_pool.markDirty`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-markdirty-function-markdirty-guard-src-minisql-storage-buffer-pool-ml-1660583357) — function
- [`minisql.storage.buffer_pool.pageCapacity`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-pagecapacity-function-pagecapacity-maxbytes-pagesize-src-minisql-storage-buffer-pool-ml-1883188421) — function
- [`minisql.storage.buffer_pool.PageGuard`](Type-minisql-storage-buffer-pool-pageguard-224112748.md) — struct
- [`minisql.storage.buffer_pool.pin`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-pin-function-pin-pool-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1230847963) — function
- [`minisql.storage.buffer_pool.PINNED_PAGE`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#constant-constant-minisql-storage-buffer-pool-pinned-page-const-pinned-page-9010-src-minisql-storage-buffer-pool-ml-65569783) — constant
- [`minisql.storage.buffer_pool.readCached`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-readcached-function-readcached-cache-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-1764087589) — function
- [`minisql.storage.buffer_pool.ReadCacheFrame`](Type-minisql-storage-buffer-pool-readcacheframe-1870403107.md) — struct
- [`minisql.storage.buffer_pool.readCacheKey`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-readcachekey-function-readcachekey-pagedfile-pagenumber-src-minisql-storage-buffer-pool-ml-2037418875) — function
- [`minisql.storage.buffer_pool.readCacheStats`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-readcachestats-function-readcachestats-cache-src-minisql-storage-buffer-pool-ml-1211588368) — function
- [`minisql.storage.buffer_pool.ReadPageCache`](Type-minisql-storage-buffer-pool-readpagecache-1005097079.md) — struct
- [`minisql.storage.buffer_pool.ReadPageCacheStats`](Type-minisql-storage-buffer-pool-readpagecachestats-126033402.md) — struct
- [`minisql.storage.buffer_pool.release`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-release-function-release-guard-src-minisql-storage-buffer-pool-ml-340368909) — function
- [`minisql.storage.buffer_pool.rememberRowCount`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-rememberrowcount-function-rememberrowcount-cache-tablepath-rowcount-src-minisql-storage-buffer-pool-ml-1785565004) — function
- [`minisql.storage.buffer_pool.stats`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-stats-function-stats-pool-src-minisql-storage-buffer-pool-ml-669831546) — function
- [`minisql.storage.buffer_pool.targetMilestone`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-targetmilestone-function-targetmilestone-src-minisql-storage-buffer-pool-ml-617924676) — function
- [`minisql.storage.buffer_pool.validateGuard`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-validateguard-function-validateguard-guard-operation-src-minisql-storage-buffer-pool-ml-1576480310) — function
- [`minisql.storage.buffer_pool.validatePool`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-validatepool-function-validatepool-pool-operation-src-minisql-storage-buffer-pool-ml-537066945) — function
- [`minisql.storage.buffer_pool.validateReadCache`](File-src-minisql-storage-buffer-pool-ml-1867626530.md#function-function-minisql-storage-buffer-pool-validatereadcache-function-validatereadcache-cache-operation-src-minisql-storage-buffer-pool-ml-218451729) — function
