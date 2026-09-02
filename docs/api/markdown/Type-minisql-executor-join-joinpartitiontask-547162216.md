# `minisql.executor.join.JoinPartitionTask`

[Home](README.md) · [Source file](File-src-minisql-executor-join-ml-2069389245.md)

<a id="struct-struct-minisql-executor-join-joinpartitiontask-struct-joinpartitiontask-src-minisql-executor-join-ml-1062636711"></a>
## JoinPartitionTask

```ml
struct JoinPartitionTask
```

Immutable work package for one independent grace-hash-join partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L37)

## Members

<a id="field-field-minisql-executor-join-joinpartitiontask-boundjoin-boundjoin-src-minisql-executor-join-ml-729746348"></a>
### boundJoin

```ml
boundJoin
```

Bound join metadata used for equality and residual-predicate checks.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L43)

<a id="field-field-minisql-executor-join-joinpartitiontask-buildright-buildright-src-minisql-executor-join-ml-1124451404"></a>
### buildRight

```ml
buildRight
```

Optimizer-selected hash-table build orientation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L45)

<a id="field-field-minisql-executor-join-joinpartitiontask-database-database-src-minisql-executor-join-ml-224779910"></a>
### database

```ml
database
```

Optional managed database used for cooperative worker cancellation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L47)

<a id="field-field-minisql-executor-join-joinpartitiontask-leftrun-leftrun-src-minisql-executor-join-ml-1797459252"></a>
### leftRun

```ml
leftRun
```

Optional validated spill run for the left input partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L39)

<a id="field-field-minisql-executor-join-joinpartitiontask-rightrun-rightrun-src-minisql-executor-join-ml-1834903494"></a>
### rightRun

```ml
rightRun
```

Optional validated spill run for the right input partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L41)

<a id="field-field-minisql-executor-join-joinpartitiontask-sessionid-sessionid-src-minisql-executor-join-ml-559716168"></a>
### sessionId

```ml
sessionId
```

Owning session identifier when database is present.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/join.ml#L49)
