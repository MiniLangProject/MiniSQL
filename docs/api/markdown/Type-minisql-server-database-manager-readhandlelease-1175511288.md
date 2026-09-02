# `minisql.server.database_manager.ReadHandleLease`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-readhandlelease-struct-readhandlelease-src-minisql-server-database-manager-ml-134019351"></a>
## ReadHandleLease

```ml
struct ReadHandleLease
```

Caller ownership token for one acquired persistent read handle.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L227)

## Members

<a id="field-field-minisql-server-database-manager-readhandlelease-cache-cache-src-minisql-server-database-manager-ml-1181440921"></a>
### cache

```ml
cache
```

Owning registry whose concurrency counters track this lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L229)

<a id="field-field-minisql-server-database-manager-readhandlelease-entry-entry-src-minisql-server-database-manager-ml-1071247265"></a>
### entry

```ml
entry
```

Immutable registry entry kept alive by the database execution gate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L231)

<a id="field-field-minisql-server-database-manager-readhandlelease-readcontext-readcontext-src-minisql-server-database-manager-ml-1456656481"></a>
### readContext

```ml
readContext
```

Lazily allocated query-local positioned-read completion state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L233)

<a id="field-field-minisql-server-database-manager-readhandlelease-released-released-src-minisql-server-database-manager-ml-398917607"></a>
### released

```ml
released
```

Prevents double release and use after release.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L235)
