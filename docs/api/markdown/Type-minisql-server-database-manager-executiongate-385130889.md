# `minisql.server.database_manager.ExecutionGate`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-executiongate-struct-executiongate-src-minisql-server-database-manager-ml-1226031957"></a>
## ExecutionGate

```ml
struct ExecutionGate
```

Writer-prioritized readers/writer gate. A waiting writer owns turnstile, so newly arriving readers cannot continuously postpone database mutations. Coordinates physical execution for one database. The three synchronization objects implement a writer-prioritized readers/writer gate; `readers` is accessed only while `stateLock` is held.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L89)

## Members

<a id="field-field-minisql-server-database-manager-executiongate-peakreaders-peakreaders-src-minisql-server-database-manager-ml-925744210"></a>
### peakReaders

```ml
peakReaders
```

Records the greatest observed reader count for diagnostics and tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L99)

<a id="field-field-minisql-server-database-manager-executiongate-readers-readers-src-minisql-server-database-manager-ml-1102880326"></a>
### readers

```ml
readers
```

Counts readers currently admitted to the database execution section.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L97)

<a id="field-field-minisql-server-database-manager-executiongate-roomempty-roomempty-src-minisql-server-database-manager-ml-1019553262"></a>
### roomEmpty

```ml
roomEmpty
```

Is held by the first reader or the active writer until the database is empty.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L95)

<a id="field-field-minisql-server-database-manager-executiongate-statelock-statelock-src-minisql-server-database-manager-ml-1000270506"></a>
### stateLock

```ml
stateLock
```

Protects `readers` and `peakReaders` from concurrent updates.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L91)

<a id="field-field-minisql-server-database-manager-executiongate-turnstile-turnstile-src-minisql-server-database-manager-ml-1911111286"></a>
### turnstile

```ml
turnstile
```

Serializes writers and prevents new readers from bypassing a waiting writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L93)
