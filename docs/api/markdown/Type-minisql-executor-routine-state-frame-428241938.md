# `minisql.executor.routine_state.Frame`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-frame-struct-frame-src-minisql-executor-routine-state-ml-1521747315"></a>
## Frame

```ml
struct Frame
```

Each invocation owns independent scopes and output collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L71)

## Members

<a id="field-field-minisql-executor-routine-state-frame-affectedrows-affectedrows-src-minisql-executor-routine-state-ml-638998312"></a>
### affectedRows

```ml
affectedRows
```

Last statement's affected row count, normalized for CALL completion.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L79)

<a id="field-field-minisql-executor-routine-state-frame-name-name-src-minisql-executor-routine-state-ml-1283740448"></a>
### name

```ml
name
```

Canonical routine name for recursive call accounting.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L73)

<a id="field-field-minisql-executor-routine-state-frame-results-results-src-minisql-executor-routine-state-ml-833965634"></a>
### results

```ml
results
```

Ordered QueryResult values emitted by SELECT or nested CALL.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L77)

<a id="field-field-minisql-executor-routine-state-frame-schema-schema-src-minisql-executor-routine-state-ml-745429612"></a>
### schema

```ml
schema
```

Default schema inherited from the procedure's qualified name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L81)

<a id="field-field-minisql-executor-routine-state-frame-scopes-scopes-src-minisql-executor-routine-state-ml-575436168"></a>
### scopes

```ml
scopes
```

Active lexical scopes, outermost first.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L75)

<a id="field-field-minisql-executor-routine-state-frame-visiblectes-visiblectes-src-minisql-executor-routine-state-ml-635403426"></a>
### visibleCtes

```ml
visibleCtes
```

CTE declarations visible while rewriting one query and its nested subqueries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L83)
