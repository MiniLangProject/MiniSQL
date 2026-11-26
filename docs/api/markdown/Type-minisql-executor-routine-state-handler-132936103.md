# `minisql.executor.routine_state.Handler`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-handler-struct-handler-src-minisql-executor-routine-state-ml-1583009465"></a>
## Handler

```ml
struct Handler
```

A handler is registered in one lexical scope and never catches its own errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L41)

## Members

<a id="field-field-minisql-executor-routine-state-handler-action-action-src-minisql-executor-routine-state-ml-2016534883"></a>
### action

```ml
action
```

CONTINUE or EXIT.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L43)

<a id="field-field-minisql-executor-routine-state-handler-body-body-src-minisql-executor-routine-state-ml-397219547"></a>
### body

```ml
body
```

One statement or compound block.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L47)

<a id="field-field-minisql-executor-routine-state-handler-conditions-conditions-src-minisql-executor-routine-state-ml-1716892511"></a>
### conditions

```ml
conditions
```

Resolved [SQLSTATE|ERRNO|CLASS, value] pairs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L45)
