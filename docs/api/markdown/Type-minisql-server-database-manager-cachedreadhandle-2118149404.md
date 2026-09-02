# `minisql.server.database_manager.CachedReadHandle`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-cachedreadhandle-struct-cachedreadhandle-src-minisql-server-database-manager-ml-1252186617"></a>
## CachedReadHandle

```ml
struct CachedReadHandle
```

One persistent immutable table or index handle. Native positioned reads let all database readers use the same object concurrently without a shared file cursor; the database writer gate still owns invalidation and close.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L217)

## Members

<a id="field-field-minisql-server-database-manager-cachedreadhandle-indexhandle-indexhandle-src-minisql-server-database-manager-ml-91870941"></a>
### indexHandle

```ml
indexHandle
```

Distinguishes BTree handles from PagedFile handles during close.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L223)

<a id="field-field-minisql-server-database-manager-cachedreadhandle-path-path-src-minisql-server-database-manager-ml-1158830631"></a>
### path

```ml
path
```

Stable absolute or database-relative path used as the registry key.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L219)

<a id="field-field-minisql-server-database-manager-cachedreadhandle-value-value-src-minisql-server-database-manager-ml-1077872857"></a>
### value

```ml
value
```

Open PagedFile or BTree owned exclusively by the database registry.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L221)
