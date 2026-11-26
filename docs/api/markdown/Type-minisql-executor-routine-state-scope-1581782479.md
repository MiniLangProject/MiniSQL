# `minisql.executor.routine_state.Scope`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-scope-struct-scope-src-minisql-executor-routine-state-ml-1669046665"></a>
## Scope

```ml
struct Scope
```

One lexical scope; resources become unreachable on every exit path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L51)

## Members

<a id="field-field-minisql-executor-routine-state-scope-conditions-conditions-src-minisql-executor-routine-state-ml-2040103107"></a>
### conditions

```ml
conditions
```

Named condition definitions [name, kind, value].


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L59)

<a id="field-field-minisql-executor-routine-state-scope-cursors-cursors-src-minisql-executor-routine-state-ml-1162844667"></a>
### cursors

```ml
cursors
```

Declared Cursor records.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L61)

<a id="field-field-minisql-executor-routine-state-scope-handlers-handlers-src-minisql-executor-routine-state-ml-1409397457"></a>
### handlers

```ml
handlers
```

Declared Handler records.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L63)

<a id="field-field-minisql-executor-routine-state-scope-handling-handling-src-minisql-executor-routine-state-ml-336203585"></a>
### handling

```ml
handling
```

Suppresses this scope's handlers while one of them is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L65)

<a id="field-field-minisql-executor-routine-state-scope-id-id-src-minisql-executor-routine-state-ml-459368437"></a>
### id

```ml
id
```

Monotonic session identity used by EXIT handler unwinding.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L53)

<a id="field-field-minisql-executor-routine-state-scope-label-label-src-minisql-executor-routine-state-ml-1169862927"></a>
### label

```ml
label
```

Optional block label, or an empty string.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L55)

<a id="field-field-minisql-executor-routine-state-scope-qualifiedonly-qualifiedonly-src-minisql-executor-routine-state-ml-1585064155"></a>
### qualifiedOnly

```ml
qualifiedOnly
```

OLD/NEW fields resolve only through their qualifier, never as bare locals.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L67)

<a id="field-field-minisql-executor-routine-state-scope-variables-variables-src-minisql-executor-routine-state-ml-1542303307"></a>
### variables

```ml
variables
```

Ordered Variable records; duplicate names are rejected.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L57)
