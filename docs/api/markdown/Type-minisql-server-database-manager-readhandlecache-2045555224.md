# `minisql.server.database_manager.ReadHandleCache`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-readhandlecache-struct-readhandlecache-src-minisql-server-database-manager-ml-1310056131"></a>
## ReadHandleCache

```ml
struct ReadHandleCache
```

Thread-safe per-database registry. DDL and mutations invalidate it while the physical writer gate excludes readers, so cached metadata never outlives a published table or index generation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L260)

## Members

<a id="field-field-minisql-server-database-manager-readhandlecache-activeleases-activeleases-src-minisql-server-database-manager-ml-2101117123"></a>
### activeLeases

```ml
activeLeases
```

Number of query operations currently using cached handles.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L272)

<a id="field-field-minisql-server-database-manager-readhandlecache-availablereadcontexts-availablereadcontexts-src-minisql-server-database-manager-ml-784851753"></a>
### availableReadContexts

```ml
availableReadContexts
```

Idle positioned-read contexts available for the next index lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L276)

<a id="field-field-minisql-server-database-manager-readhandlecache-closed-closed-src-minisql-server-database-manager-ml-1961535557"></a>
### closed

```ml
closed
```

Prevents acquisitions after database shutdown.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L280)

<a id="field-field-minisql-server-database-manager-readhandlecache-guard-guard-src-minisql-server-database-manager-ml-1344502505"></a>
### guard

```ml
guard
```

Serializes registry lookup and first-open publication.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L266)

<a id="field-field-minisql-server-database-manager-readhandlecache-hits-hits-src-minisql-server-database-manager-ml-1608242389"></a>
### hits

```ml
hits
```

Counts acquisitions satisfied without opening a native handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L268)

<a id="field-field-minisql-server-database-manager-readhandlecache-indexes-indexes-src-minisql-server-database-manager-ml-470163861"></a>
### indexes

```ml
indexes
```

Maps index paths to CachedReadHandle values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L264)

<a id="field-field-minisql-server-database-manager-readhandlecache-misses-misses-src-minisql-server-database-manager-ml-1776539893"></a>
### misses

```ml
misses
```

Counts acquisitions that opened and published a native handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L270)

<a id="field-field-minisql-server-database-manager-readhandlecache-peakleases-peakleases-src-minisql-server-database-manager-ml-1109691189"></a>
### peakLeases

```ml
peakLeases
```

Highest simultaneous cached-handle lease count since open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L274)

<a id="field-field-minisql-server-database-manager-readhandlecache-readcontextcount-readcontextcount-src-minisql-server-database-manager-ml-2047244157"></a>
### readContextCount

```ml
readContextCount
```

Total query contexts created by this database.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L278)

<a id="field-field-minisql-server-database-manager-readhandlecache-tables-tables-src-minisql-server-database-manager-ml-741016355"></a>
### tables

```ml
tables
```

Maps table paths to CachedReadHandle values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L262)
