# `minisql.planner.execution_plan.JoinPlan`

[Home](README.md) · [Source file](File-src-minisql-planner-execution-plan-ml-1727378828.md)

<a id="struct-struct-minisql-planner-execution-plan-joinplan-struct-joinplan-src-minisql-planner-execution-plan-ml-490155817"></a>
## JoinPlan

```ml
struct JoinPlan
```

Selects exactly one algorithm for a join in the bound SQL join sequence. Hash joins may build either side while still returning canonical left/right column order. Runtime fallbacks are allowed only for transaction visibility or index availability changes and never alter SQL semantics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L88)

## Members

<a id="field-field-minisql-planner-execution-plan-joinplan-algorithm-algorithm-src-minisql-planner-execution-plan-ml-1392520544"></a>
### algorithm

```ml
algorithm
```

JOIN_* algorithm selected by the cost model.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L94)

<a id="field-field-minisql-planner-execution-plan-joinplan-buildright-buildright-src-minisql-planner-execution-plan-ml-747871696"></a>
### buildRight

```ml
buildRight
```

True when the right/new source is the hash build input.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L96)

<a id="field-field-minisql-planner-execution-plan-joinplan-estimatedcost-estimatedcost-src-minisql-planner-execution-plan-ml-173990464"></a>
### estimatedCost

```ml
estimatedCost
```

Cumulative deterministic integer cost.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L100)

<a id="field-field-minisql-planner-execution-plan-joinplan-estimatedrows-estimatedrows-src-minisql-planner-execution-plan-ml-1945139568"></a>
### estimatedRows

```ml
estimatedRows
```

Estimated output cardinality after this join.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L98)

<a id="field-field-minisql-planner-execution-plan-joinplan-joinindex-joinindex-src-minisql-planner-execution-plan-ml-1455668728"></a>
### joinIndex

```ml
joinIndex
```

Position of the predicate in BoundSelect.joins.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L90)

<a id="field-field-minisql-planner-execution-plan-joinplan-sourceindex-sourceindex-src-minisql-planner-execution-plan-ml-585982944"></a>
### sourceIndex

```ml
sourceIndex
```

Source attached by this physical join step.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L92)
