# `minisql.executor.executor.QueryControl`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-querycontrol-struct-querycontrol-src-minisql-executor-executor-ml-1927547305"></a>
## QueryControl

```ml
struct QueryControl
```

Session-local token polled at bounded executor and storage batch boundaries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L234)

## Members

<a id="field-field-minisql-executor-executor-querycontrol-active-active-src-minisql-executor-executor-ml-1064673574"></a>
### active

```ml
active
```

True while a top-level statement or streaming cursor owns the token.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L236)

<a id="field-field-minisql-executor-executor-querycontrol-deadlineat-deadlineat-src-minisql-executor-executor-ml-1749163772"></a>
### deadlineAt

```ml
deadlineAt
```

Absolute monotonic timestamp after which cooperative polling fails.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L240)

<a id="field-field-minisql-executor-executor-querycontrol-startedat-startedat-src-minisql-executor-executor-ml-252147026"></a>
### startedAt

```ml
startedAt
```

Monotonic timestamp at which the top-level statement was admitted.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L238)
