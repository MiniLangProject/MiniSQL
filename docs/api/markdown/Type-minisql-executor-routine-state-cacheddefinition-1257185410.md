# `minisql.executor.routine_state.CachedDefinition`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-cacheddefinition-struct-cacheddefinition-src-minisql-executor-routine-state-ml-1575351735"></a>
## CachedDefinition

```ml
struct CachedDefinition
```

A cache entry is keyed by durable identity, full definition and metadata bytes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L173)

## Members

<a id="field-field-minisql-executor-routine-state-cacheddefinition-definition-definition-src-minisql-executor-routine-state-ml-1693595664"></a>
### definition

```ml
definition
```

Parsed immutable CreateProcedureStatement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L181)

<a id="field-field-minisql-executor-routine-state-cacheddefinition-id-id-src-minisql-executor-routine-state-ml-1435114916"></a>
### id

```ml
id
```

Stable procedure object identity, never reused after DROP.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L175)

<a id="field-field-minisql-executor-routine-state-cacheddefinition-metadata-metadata-src-minisql-executor-routine-state-ml-1992904108"></a>
### metadata

```ml
metadata
```

Exact persisted metadata representation, including captured context.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L179)

<a id="field-field-minisql-executor-routine-state-cacheddefinition-sql-sql-src-minisql-executor-routine-state-ml-1028565922"></a>
### sql

```ml
sql
```

Exact canonical SQL text, including the entire body.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L177)
