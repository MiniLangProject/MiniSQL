# `minisql.storage.buffer_pool.ReadPageCacheStats`

[Home](README.md) · [Source file](File-src-minisql-storage-buffer-pool-ml-1867626530.md)

<a id="struct-struct-minisql-storage-buffer-pool-readpagecachestats-struct-readpagecachestats-src-minisql-storage-buffer-pool-ml-1245336987"></a>
## ReadPageCacheStats

```ml
struct ReadPageCacheStats
```

Snapshot of read-cache counters used by diagnostics and regression tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L126)

## Members

<a id="field-field-minisql-storage-buffer-pool-readpagecachestats-evictions-evictions-src-minisql-storage-buffer-pool-ml-210492881"></a>
### evictions

```ml
evictions
```

Snapshot of CLOCK replacements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L132)

<a id="field-field-minisql-storage-buffer-pool-readpagecachestats-hits-hits-src-minisql-storage-buffer-pool-ml-1705749945"></a>
### hits

```ml
hits
```

Snapshot of successful resident lookups.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L128)

<a id="field-field-minisql-storage-buffer-pool-readpagecachestats-maxpages-maxpages-src-minisql-storage-buffer-pool-ml-277065153"></a>
### maxPages

```ml
maxPages
```

Configured maximum number of frames.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L136)

<a id="field-field-minisql-storage-buffer-pool-readpagecachestats-misses-misses-src-minisql-storage-buffer-pool-ml-1385009921"></a>
### misses

```ml
misses
```

Snapshot of physical-read lookups.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L130)

<a id="field-field-minisql-storage-buffer-pool-readpagecachestats-residentpages-residentpages-src-minisql-storage-buffer-pool-ml-1619195541"></a>
### residentPages

```ml
residentPages
```

Number of populated frames at snapshot time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L134)
