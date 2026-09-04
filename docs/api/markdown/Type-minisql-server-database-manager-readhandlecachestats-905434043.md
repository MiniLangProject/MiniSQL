# `minisql.server.database_manager.ReadHandleCacheStats`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-readhandlecachestats-struct-readhandlecachestats-src-minisql-server-database-manager-ml-1881992265"></a>
## ReadHandleCacheStats

```ml
struct ReadHandleCacheStats
```

Immutable diagnostic snapshot for handle-cache tests and performance logs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L284)

## Members

<a id="field-field-minisql-server-database-manager-readhandlecachestats-activeleases-activeleases-src-minisql-server-database-manager-ml-1288313042"></a>
### activeLeases

```ml
activeLeases
```

Number of handle leases active at snapshot time.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L294)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-availablereadcontexts-availablereadcontexts-src-minisql-server-database-manager-ml-1528791592"></a>
### availableReadContexts

```ml
availableReadContexts
```

Number of contexts currently idle in the pool.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L300)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-hits-hits-src-minisql-server-database-manager-ml-1828477564"></a>
### hits

```ml
hits
```

Number of acquisitions served by an existing persistent handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L286)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-indexhandles-indexhandles-src-minisql-server-database-manager-ml-9612366"></a>
### indexHandles

```ml
indexHandles
```

Number of currently cached index BTree handles.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L292)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-misses-misses-src-minisql-server-database-manager-ml-53373812"></a>
### misses

```ml
misses
```

Number of acquisitions that opened a new native storage handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L288)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-peakleases-peakleases-src-minisql-server-database-manager-ml-1941490836"></a>
### peakLeases

```ml
peakLeases
```

Highest simultaneous handle lease count since database open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L296)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-readcontexts-readcontexts-src-minisql-server-database-manager-ml-1282511428"></a>
### readContexts

```ml
readContexts
```

Number of reusable positioned-read contexts owned by the database.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L298)

<a id="field-field-minisql-server-database-manager-readhandlecachestats-tablehandles-tablehandles-src-minisql-server-database-manager-ml-1563215962"></a>
### tableHandles

```ml
tableHandles
```

Number of currently cached table PagedFile handles.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L290)
