# `minisql.planner.execution_plan.ExecutionPlan`

[Home](README.md) · [Source file](File-src-minisql-planner-execution-plan-ml-1727378828.md)

<a id="struct-struct-minisql-planner-execution-plan-executionplan-struct-executionplan-src-minisql-planner-execution-plan-ml-488855773"></a>
## ExecutionPlan

```ml
struct ExecutionPlan
```

Complete executable contract for one BoundSelect.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L124)

## Members

<a id="field-field-minisql-planner-execution-plan-executionplan-aggregatealgorithm-aggregatealgorithm-src-minisql-planner-execution-plan-ml-2015556470"></a>
### aggregateAlgorithm

```ml
aggregateAlgorithm
```

AGGREGATE_* strategy selected for the query.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L132)

<a id="field-field-minisql-planner-execution-plan-executionplan-constantempty-constantempty-src-minisql-planner-execution-plan-ml-1365142978"></a>
### constantEmpty

```ml
constantEmpty
```

True when a constant WHERE predicate proves the input empty.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L136)

<a id="field-field-minisql-planner-execution-plan-executionplan-joins-joins-src-minisql-planner-execution-plan-ml-1379362894"></a>
### joins

```ml
joins
```

Physical join steps in execution order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L128)

<a id="field-field-minisql-planner-execution-plan-executionplan-reorderedjoins-reorderedjoins-src-minisql-planner-execution-plan-ml-938301472"></a>
### reorderedJoins

```ml
reorderedJoins
```

True when join steps differ from bound SQL order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L140)

<a id="field-field-minisql-planner-execution-plan-executionplan-sortalgorithm-sortalgorithm-src-minisql-planner-execution-plan-ml-1080693110"></a>
### sortAlgorithm

```ml
sortAlgorithm
```

SORT_* strategy selected for the query.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L134)

<a id="field-field-minisql-planner-execution-plan-executionplan-sources-sources-src-minisql-planner-execution-plan-ml-1451754302"></a>
### sources

```ml
sources
```

Access decision indexed by bound source position.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L126)

<a id="field-field-minisql-planner-execution-plan-executionplan-startsource-startsource-src-minisql-planner-execution-plan-ml-1936488314"></a>
### startSource

```ml
startSource
```

Source that seeds a reordered inner-join graph.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L130)

<a id="field-field-minisql-planner-execution-plan-executionplan-wherepredicate-wherepredicate-src-minisql-planner-execution-plan-ml-358688662"></a>
### wherePredicate

```ml
wherePredicate
```

Simplified WHERE expression retained as the correctness filter.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L138)
