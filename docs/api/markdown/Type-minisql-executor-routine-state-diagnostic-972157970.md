# `minisql.executor.routine_state.Diagnostic`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-diagnostic-struct-diagnostic-src-minisql-executor-routine-state-ml-1455312683"></a>
## Diagnostic

```ml
struct Diagnostic
```

SQL diagnostics remain available after handlers and top-level statements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L87)

## Members

<a id="field-field-minisql-executor-routine-state-diagnostic-errno-errno-src-minisql-executor-routine-state-ml-160724938"></a>
### errno

```ml
errno
```

MySQL-compatible routine error number.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L91)

<a id="field-field-minisql-executor-routine-state-diagnostic-items-items-src-minisql-executor-routine-state-ml-1076311166"></a>
### items

```ml
items
```

Optional condition information [name, SqlValue] pairs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L95)

<a id="field-field-minisql-executor-routine-state-diagnostic-message-message-src-minisql-executor-routine-state-ml-1617248718"></a>
### message

```ml
message
```

Human-readable condition text.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L93)

<a id="field-field-minisql-executor-routine-state-diagnostic-nativeerror-nativeerror-src-minisql-executor-routine-state-ml-706967350"></a>
### nativeError

```ml
nativeError
```

Original structured MiniSQL error, retained when one caused this condition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L103)

<a id="field-field-minisql-executor-routine-state-diagnostic-number-number-src-minisql-executor-routine-state-ml-364243980"></a>
### number

```ml
number
```

Number of conditions in this diagnostics area.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L99)

<a id="field-field-minisql-executor-routine-state-diagnostic-preceding-preceding-src-minisql-executor-routine-state-ml-2004154118"></a>
### preceding

```ml
preceding
```

Earlier conditions in the same area, in GET DIAGNOSTICS ordinal order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L105)

<a id="field-field-minisql-executor-routine-state-diagnostic-rowcount-rowcount-src-minisql-executor-routine-state-ml-952900688"></a>
### rowCount

```ml
rowCount
```

Affected row count for statement diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L97)

<a id="field-field-minisql-executor-routine-state-diagnostic-serial-serial-src-minisql-executor-routine-state-ml-1313101206"></a>
### serial

```ml
serial
```

Statement instruction identity used to distinguish newly raised identical conditions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L107)

<a id="field-field-minisql-executor-routine-state-diagnostic-signaled-signaled-src-minisql-executor-routine-state-ml-1921684768"></a>
### signaled

```ml
signaled
```

Distinguishes explicit NOT FOUND signals from normal exhaustion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L101)

<a id="field-field-minisql-executor-routine-state-diagnostic-sqlstate-sqlstate-src-minisql-executor-routine-state-ml-1508685348"></a>
### sqlstate

```ml
sqlstate
```

Five-character SQLSTATE.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L89)
