# `minisql.executor.routine_state.Flow`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-flow-struct-flow-src-minisql-executor-routine-state-ml-1503788791"></a>
## Flow

```ml
struct Flow
```

Explicit control flow keeps cleanup independent of MiniLang error propagation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L185)

## Members

<a id="field-field-minisql-executor-routine-state-flow-kind-kind-src-minisql-executor-routine-state-ml-958928321"></a>
### kind

```ml
kind
```

NORMAL, LEAVE, ITERATE, EXIT, or ERROR.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L187)

<a id="field-field-minisql-executor-routine-state-flow-target-target-src-minisql-executor-routine-state-ml-1469147103"></a>
### target

```ml
target
```

Label, scope identity, or Diagnostic, depending on kind.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L189)
