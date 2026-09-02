# `minisql.executor.aggregate.AggregatePartitionTask`

[Home](README.md) · [Source file](File-src-minisql-executor-aggregate-ml-1058141144.md)

<a id="struct-struct-minisql-executor-aggregate-aggregatepartitiontask-struct-aggregatepartitiontask-src-minisql-executor-aggregate-ml-162519147"></a>
## AggregatePartitionTask

```ml
struct AggregatePartitionTask
```

Immutable work package for one independent aggregate hash partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L55)

## Members

<a id="field-field-minisql-executor-aggregate-aggregatepartitiontask-groupexpressions-groupexpressions-src-minisql-executor-aggregate-ml-352004163"></a>
### groupExpressions

```ml
groupExpressions
```

Bound grouping expressions whose hash selected this partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L61)

<a id="field-field-minisql-executor-aggregate-aggregatepartitiontask-havingexpression-havingexpression-src-minisql-executor-aggregate-ml-1750267517"></a>
### havingExpression

```ml
havingExpression
```

Optional bound HAVING predicate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L63)

<a id="field-field-minisql-executor-aggregate-aggregatepartitiontask-orderexpressions-orderexpressions-src-minisql-executor-aggregate-ml-1568939309"></a>
### orderExpressions

```ml
orderExpressions
```

Bound ORDER BY expressions retained for the final merge/sort stage.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L65)

<a id="field-field-minisql-executor-aggregate-aggregatepartitiontask-run-run-src-minisql-executor-aggregate-ml-1918718779"></a>
### run

```ml
run
```

Validated spill run containing every row for this hash partition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L57)

<a id="field-field-minisql-executor-aggregate-aggregatepartitiontask-selectexpressions-selectexpressions-src-minisql-executor-aggregate-ml-1345213179"></a>
### selectExpressions

```ml
selectExpressions
```

Bound SELECT expressions evaluated for each completed group.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L59)
