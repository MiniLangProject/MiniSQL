# `minisql.executor.aggregate.AggregateGroup`

[Home](README.md) · [Source file](File-src-minisql-executor-aggregate-ml-1058141144.md)

<a id="struct-struct-minisql-executor-aggregate-aggregategroup-struct-aggregategroup-src-minisql-executor-aggregate-ml-1110110775"></a>
## AggregateGroup

```ml
struct AggregateGroup
```

Owns one SQL grouping key and all input rows assigned to that key.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L48)

## Members

<a id="field-field-minisql-executor-aggregate-aggregategroup-keyvalues-keyvalues-src-minisql-executor-aggregate-ml-1503890711"></a>
### keyValues

```ml
keyValues
```

Evaluated GROUP BY values; NULL values compare equal for grouping.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L50)

<a id="field-field-minisql-executor-aggregate-aggregategroup-rows-rows-src-minisql-executor-aggregate-ml-1616904457"></a>
### rows

```ml
rows
```

Input rows in stable scan order for aggregate evaluation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L52)
