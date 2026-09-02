# `minisql.storage.buffer_pool.ReadCacheFrame`

[Home](README.md) · [Source file](File-src-minisql-storage-buffer-pool-ml-1867626530.md)

<a id="struct-struct-minisql-storage-buffer-pool-readcacheframe-struct-readcacheframe-src-minisql-storage-buffer-pool-ml-1219830831"></a>
## ReadCacheFrame

```ml
struct ReadCacheFrame
```

Immutable read-cache frame keyed by a stable file path and page number. It deliberately does not retain a PagedFile handle, allowing short-lived scan handles to close without leaving dangling cache ownership.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L89)

## Members

<a id="field-field-minisql-storage-buffer-pool-readcacheframe-data-data-src-minisql-storage-buffer-pool-ml-1149725610"></a>
### data

```ml
data
```

Immutable verified-size page image retained independently of file handles.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L93)

<a id="field-field-minisql-storage-buffer-pool-readcacheframe-key-key-src-minisql-storage-buffer-pool-ml-1975516486"></a>
### key

```ml
key
```

Stable file-path and page-number identity used by the lookup map.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L91)

<a id="field-field-minisql-storage-buffer-pool-readcacheframe-referenced-referenced-src-minisql-storage-buffer-pool-ml-961587240"></a>
### referenced

```ml
referenced
```

CLOCK reference bit set by every successful lookup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/buffer_pool.ml#L95)
