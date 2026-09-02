# `minisql.executor.aggregate.AggregateAccumulator`

[Home](README.md) · [Source file](File-src-minisql-executor-aggregate-ml-1058141144.md)

<a id="struct-struct-minisql-executor-aggregate-aggregateaccumulator-struct-aggregateaccumulator-src-minisql-executor-aggregate-ml-1999889507"></a>
## AggregateAccumulator

```ml
struct AggregateAccumulator
```

Fixed-size state for one direct scalar aggregate in the streaming fast path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L69)

## Members

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-booleanvalue-booleanvalue-src-minisql-executor-aggregate-ml-1270643204"></a>
### booleanValue

```ml
booleanValue
```

Current boolean fold used by BOOL_AND and BOOL_OR.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L79)

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-count-count-src-minisql-executor-aggregate-ml-2031354894"></a>
### count

```ml
count
```

Number of contributing non-NULL values, or input rows for COUNT(*).


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L73)

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-expression-expression-src-minisql-executor-aggregate-ml-1072287386"></a>
### expression

```ml
expression
```

Bound aggregate whose semantics this state implements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L71)

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-hasvalue-hasvalue-src-minisql-executor-aggregate-ml-1165737720"></a>
### hasValue

```ml
hasValue
```

Indicates whether any non-NULL input contributed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L81)

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-selected-selected-src-minisql-executor-aggregate-ml-439725596"></a>
### selected

```ml
selected
```

Current extremum used by MIN and MAX.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L77)

<a id="field-field-minisql-executor-aggregate-aggregateaccumulator-total-total-src-minisql-executor-aggregate-ml-1072807778"></a>
### total

```ml
total
```

Running numeric SUM used by SUM and AVG.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/aggregate.ml#L75)
