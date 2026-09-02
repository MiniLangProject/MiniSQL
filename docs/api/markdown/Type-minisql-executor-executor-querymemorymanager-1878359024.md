# `minisql.executor.executor.QueryMemoryManager`

[Home](README.md) · [Source file](File-src-minisql-executor-executor-ml-1548110730.md)

<a id="struct-struct-minisql-executor-executor-querymemorymanager-struct-querymemorymanager-src-minisql-executor-executor-ml-1577217577"></a>
## QueryMemoryManager

```ml
struct QueryMemoryManager
```

Per-session query memory policy and last-statement diagnostics. Operators use byte-derived row thresholds instead of assuming that every row has one size.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L204)

## Members

<a id="field-field-minisql-executor-executor-querymemorymanager-limitbytes-limitbytes-src-minisql-executor-executor-ml-193234867"></a>
### limitBytes

```ml
limitBytes
```

Configured soft memory limit for blocking operators.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L206)

<a id="field-field-minisql-executor-executor-querymemorymanager-peakbytes-peakbytes-src-minisql-executor-executor-ml-1338884443"></a>
### peakBytes

```ml
peakBytes
```

Largest estimated resident operator input observed by the statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L208)

<a id="field-field-minisql-executor-executor-querymemorymanager-spillbytes-spillbytes-src-minisql-executor-executor-ml-1844773529"></a>
### spillBytes

```ml
spillBytes
```

Estimated bytes delegated to temporary spill runs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L210)

<a id="field-field-minisql-executor-executor-querymemorymanager-spillruns-spillruns-src-minisql-executor-executor-ml-2028913651"></a>
### spillRuns

```ml
spillRuns
```

Number of blocking operators that selected a spill path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/executor.ml#L212)
