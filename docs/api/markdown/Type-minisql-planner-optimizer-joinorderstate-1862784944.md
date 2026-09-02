# `minisql.planner.optimizer.JoinOrderState`

[Home](README.md) · [Source file](File-src-minisql-planner-optimizer-ml-1479207859.md)

<a id="struct-struct-minisql-planner-optimizer-joinorderstate-struct-joinorderstate-src-minisql-planner-optimizer-ml-2049465649"></a>
## JoinOrderState

```ml
struct JoinOrderState
```

Best known left-deep join prefix for one source subset. The bounded dynamic program stores one state per bit mask and therefore avoids factorial search.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L55)

## Members

<a id="field-field-minisql-planner-optimizer-joinorderstate-estimate-estimate-src-minisql-planner-optimizer-ml-1100483418"></a>
### estimate

```ml
estimate
```

Cumulative cost and cardinality of this prefix.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L65)

<a id="field-field-minisql-planner-optimizer-joinorderstate-joinindexes-joinindexes-src-minisql-planner-optimizer-ml-1512840742"></a>
### joinIndexes

```ml
joinIndexes
```

Bound join predicates in physical attachment order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L61)

<a id="field-field-minisql-planner-optimizer-joinorderstate-sourceindexes-sourceindexes-src-minisql-planner-optimizer-ml-548977154"></a>
### sourceIndexes

```ml
sourceIndexes
```

Source attached by each corresponding join predicate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L63)

<a id="field-field-minisql-planner-optimizer-joinorderstate-sourcemask-sourcemask-src-minisql-planner-optimizer-ml-549869608"></a>
### sourceMask

```ml
sourceMask
```

Bit set for every source already present in the prefix.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L57)

<a id="field-field-minisql-planner-optimizer-joinorderstate-startsource-startsource-src-minisql-planner-optimizer-ml-160238390"></a>
### startSource

```ml
startSource
```

Source that seeds the executable left-deep plan.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/optimizer.ml#L59)
