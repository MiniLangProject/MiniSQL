# `minisql.executor.routine_state.Cursor`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-cursor-struct-cursor-src-minisql-executor-routine-state-ml-845975743"></a>
## Cursor

```ml
struct Cursor
```

A forward-only cursor owns its materialized snapshot until close or scope exit.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L23)

## Members

<a id="field-field-minisql-executor-routine-state-cursor-columns-columns-src-minisql-executor-routine-state-ml-1945841611"></a>
### columns

```ml
columns
```

Snapshot column metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L31)

<a id="field-field-minisql-executor-routine-state-cursor-index-index-src-minisql-executor-routine-state-ml-781899515"></a>
### index

```ml
index
```

Index of the next row to fetch.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L33)

<a id="field-field-minisql-executor-routine-state-cursor-lexicalscopes-lexicalscopes-src-minisql-executor-routine-state-ml-1373644259"></a>
### lexicalScopes

```ml
lexicalScopes
```

Declaration-time scope references; values remain live, shadowing cannot rebind them.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L37)

<a id="field-field-minisql-executor-routine-state-cursor-name-name-src-minisql-executor-routine-state-ml-1215309633"></a>
### name

```ml
name
```

Lexical cursor name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L25)

<a id="field-field-minisql-executor-routine-state-cursor-opened-opened-src-minisql-executor-routine-state-ml-1386159585"></a>
### opened

```ml
opened
```

Whether OPEN has succeeded without a corresponding CLOSE.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L35)

<a id="field-field-minisql-executor-routine-state-cursor-query-query-src-minisql-executor-routine-state-ml-1885637643"></a>
### query

```ml
query
```

Unsubstituted SELECT syntax tree evaluated by OPEN.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L27)

<a id="field-field-minisql-executor-routine-state-cursor-rows-rows-src-minisql-executor-routine-state-ml-641066725"></a>
### rows

```ml
rows
```

Snapshot rows captured by OPEN.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L29)
