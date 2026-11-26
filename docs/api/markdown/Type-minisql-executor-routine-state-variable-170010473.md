# `minisql.executor.routine_state.Variable`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-variable-struct-variable-src-minisql-executor-routine-state-ml-2138936071"></a>
## Variable

```ml
struct Variable
```

One typed lexical variable, or an untyped session variable when typeInfo is void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L13)

## Members

<a id="field-field-minisql-executor-routine-state-variable-name-name-src-minisql-executor-routine-state-ml-297123623"></a>
### name

```ml
name
```

Case-folded identifier, including @ for session variables.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L15)

<a id="field-field-minisql-executor-routine-state-variable-typeinfo-typeinfo-src-minisql-executor-routine-state-ml-2085440933"></a>
### typeInfo

```ml
typeInfo
```

Declared SQL type, or void for a session variable.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L17)

<a id="field-field-minisql-executor-routine-state-variable-value-value-src-minisql-executor-routine-state-ml-1381792585"></a>
### value

```ml
value
```

Current SqlValue, including a typed SQL NULL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L19)
