# `minisql.executor.aggregate.ParallelAggregateTask`

[Home](README.md) · [Source file](File-src-minisql-executor-aggregate-ml-1058141144.md)

<a id="struct-struct-minisql-executor-aggregate-parallelaggregatetask-struct-parallelaggregatetask-src-minisql-executor-aggregate-ml-97703359"></a>
## ParallelAggregateTask

```ml
struct ParallelAggregateTask
```

Immutable input for one page-range partial aggregate. Workers open private read handles while sharing only the database's thread-safe read cache.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L95)

## Members

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-database-database-src-minisql-executor-aggregate-ml-464491692"></a>
### database

```ml
database
```

Optional managed database used by controlled server scans.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L111)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-databasepath-databasepath-src-minisql-executor-aggregate-ml-665063998"></a>
### databasePath

```ml
databasePath
```

Filesystem root containing the table file and schema history.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L97)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-endpageindex-endpageindex-src-minisql-executor-aggregate-ml-2108540546"></a>
### endPageIndex

```ml
endPageIndex
```

Exclusive index into the persistent heap-page directory.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L109)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-firstpageindex-firstpageindex-src-minisql-executor-aggregate-ml-1161454904"></a>
### firstPageIndex

```ml
firstPageIndex
```

Inclusive index into the persistent heap-page directory.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L107)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-readcache-readcache-src-minisql-executor-aggregate-ml-761247882"></a>
### readCache

```ml
readCache
```

Database-owned concurrent read cache shared by worker readers.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L101)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-requiredcolumns-requiredcolumns-src-minisql-executor-aggregate-ml-637917858"></a>
### requiredColumns

```ml
requiredColumns
```

Column mask that prevents unrelated overflow-value reads.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L105)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-selectexpressions-selectexpressions-src-minisql-executor-aggregate-ml-704191938"></a>
### selectExpressions

```ml
selectExpressions
```

Direct scalar aggregates updated by this worker.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L103)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-sessionid-sessionid-src-minisql-executor-aggregate-ml-485332774"></a>
### sessionId

```ml
sessionId
```

Owning query session when database is present.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L113)

<a id="field-field-minisql-executor-aggregate-parallelaggregatetask-table-table-src-minisql-executor-aggregate-ml-1038314902"></a>
### table

```ml
table
```

Immutable catalog metadata for the scanned table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L99)
