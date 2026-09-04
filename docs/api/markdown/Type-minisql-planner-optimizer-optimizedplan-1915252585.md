# `minisql.planner.optimizer.OptimizedPlan`

[Home](README.md) · [Source file](File-src-minisql-planner-optimizer-ml-1479207859.md)

<a id="struct-struct-minisql-planner-optimizer-optimizedplan-struct-optimizedplan-src-minisql-planner-optimizer-ml-1157764775"></a>
## OptimizedPlan

```ml
struct OptimizedPlan
```

Groups the optimized plan state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L47)

## Members

<a id="field-field-minisql-planner-optimizer-optimizedplan-execution-execution-src-minisql-planner-optimizer-ml-442502125"></a>
### execution

```ml
execution
```

Stores the typed physical decisions consumed by the executor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L53)

<a id="field-field-minisql-planner-optimizer-optimizedplan-root-root-src-minisql-planner-optimizer-ml-375436693"></a>
### root

```ml
root
```

Stores the root associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L49)

<a id="field-field-minisql-planner-optimizer-optimizedplan-usedstatistics-usedstatistics-src-minisql-planner-optimizer-ml-634305429"></a>
### usedStatistics

```ml
usedStatistics
```

Stores the used statistics associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L51)
