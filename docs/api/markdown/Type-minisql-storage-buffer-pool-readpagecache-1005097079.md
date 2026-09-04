# `minisql.storage.buffer_pool.ReadPageCache`

[Home](README.md) · [Source file](File-src-minisql-storage-buffer-pool-ml-1867626530.md)

<a id="struct-struct-minisql-storage-buffer-pool-readpagecache-struct-readpagecache-src-minisql-storage-buffer-pool-ml-2030585519"></a>
## ReadPageCache

```ml
struct ReadPageCache
```

Thread-safe sparse CLOCK cache used by concurrent SQL table scans. Frames are allocated only when populated, so a large byte budget does not eagerly allocate one object per possible page.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L105)

## Members

<a id="field-field-minisql-storage-buffer-pool-readpagecache-clockhand-clockhand-src-minisql-storage-buffer-pool-ml-690462298"></a>
### clockHand

```ml
clockHand
```

Next CLOCK slot examined for insertion or eviction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L111)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-closed-closed-src-minisql-storage-buffer-pool-ml-1187353790"></a>
### closed

```ml
closed
```

Prevents use after the database-owned cache has been released.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L125)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-evictions-evictions-src-minisql-storage-buffer-pool-ml-875313230"></a>
### evictions

```ml
evictions
```

Number of resident page images replaced by CLOCK.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L123)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-frames-frames-src-minisql-storage-buffer-pool-ml-115267542"></a>
### frames

```ml
frames
```

Sparse CLOCK frame array; unused slots remain void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L109)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-guard-guard-src-minisql-storage-buffer-pool-ml-561334690"></a>
### guard

```ml
guard
```

Serializes lookups and metadata changes without covering disk I/O.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L117)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-hits-hits-src-minisql-storage-buffer-pool-ml-1601681958"></a>
### hits

```ml
hits
```

Number of requests served from resident page images.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L119)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-index-index-src-minisql-storage-buffer-pool-ml-268076314"></a>
### index

```ml
index
```

Maps stable page keys to their current frame indexes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L113)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-maxpages-maxpages-src-minisql-storage-buffer-pool-ml-808965306"></a>
### maxPages

```ml
maxPages
```

Maximum number of page images derived from the configured byte budget.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L107)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-misses-misses-src-minisql-storage-buffer-pool-ml-1245053630"></a>
### misses

```ml
misses
```

Number of requests that required a physical page read.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L121)

<a id="field-field-minisql-storage-buffer-pool-readpagecache-rowcounts-rowcounts-src-minisql-storage-buffer-pool-ml-1895045466"></a>
### rowCounts

```ml
rowCounts
```

Memoizes live-row counts for autocommit COUNT(*) queries. The owning


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L115)
