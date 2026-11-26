# `minisql.executor.executor.SelectCursor`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-selectcursor-struct-selectcursor-src-minisql-executor-executor-ml-1456894341"></a>
## SelectCursor

```ml
struct SelectCursor
```

Holds the resources of a simple forward-only SELECT. The physical read gate and logical statement lease remain owned until exhaustion or explicit close, preventing writers from changing pages while protocol batches are emitted.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L208)

## Members

<a id="field-field-minisql-executor-executor-selectcursor-bound-bound-src-minisql-executor-executor-ml-740968979"></a>
### bound

```ml
bound
```

Bound SELECT expressions and LIMIT/OFFSET metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L212)

<a id="field-field-minisql-executor-executor-selectcursor-closed-closed-src-minisql-executor-executor-ml-987380015"></a>
### closed

```ml
closed
```

True after resources have been released.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L226)

<a id="field-field-minisql-executor-executor-selectcursor-emitted-emitted-src-minisql-executor-executor-ml-44381567"></a>
### emitted

```ml
emitted
```

Number of projected rows returned to the caller.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L224)

<a id="field-field-minisql-executor-executor-selectcursor-engine-engine-src-minisql-executor-executor-ml-2011611983"></a>
### engine

```ml
engine
```

Session engine that owns permissions, locks, and database handles.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L210)

<a id="field-field-minisql-executor-executor-selectcursor-ownsgate-ownsgate-src-minisql-executor-executor-ml-736361903"></a>
### ownsGate

```ml
ownsGate
```

False when a stored procedure already owns the physical execution gate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L228)

<a id="field-field-minisql-executor-executor-selectcursor-reader-reader-src-minisql-executor-executor-ml-395250037"></a>
### reader

```ml
reader
```

Open table reader retained for the cursor lifetime.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L216)

<a id="field-field-minisql-executor-executor-selectcursor-readlease-readlease-src-minisql-executor-executor-ml-563175119"></a>
### readLease

```ml
readLease
```

Logical statement read lease released at cursor completion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L220)

<a id="field-field-minisql-executor-executor-selectcursor-scancursor-scancursor-src-minisql-executor-executor-ml-1430287641"></a>
### scanCursor

```ml
scanCursor
```

Bounded storage cursor over the selected source columns.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L218)

<a id="field-field-minisql-executor-executor-selectcursor-skipped-skipped-src-minisql-executor-executor-ml-1956876831"></a>
### skipped

```ml
skipped
```

Number of qualifying rows discarded for OFFSET.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L222)

<a id="field-field-minisql-executor-executor-selectcursor-wherepredicate-wherepredicate-src-minisql-executor-executor-ml-1746095963"></a>
### wherePredicate

```ml
wherePredicate
```

Optimizer-normalized predicate evaluated for every source row.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L214)
