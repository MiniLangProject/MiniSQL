# `minisql.planner.execution_plan.SourcePlan`

[Home](README.md) · [Source file](File-src-minisql-planner-execution-plan-ml-1727378828.md)

<a id="struct-struct-minisql-planner-execution-plan-sourceplan-struct-sourceplan-src-minisql-planner-execution-plan-ml-240849917"></a>
## SourcePlan

```ml
struct SourcePlan
```

Selects the physical access path and safe pushed predicate for one source.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L87)

## Members

<a id="field-field-minisql-planner-execution-plan-sourceplan-accesskind-accesskind-src-minisql-planner-execution-plan-ml-1505840601"></a>
### accessKind

```ml
accessKind
```

ACCESS_* algorithm selected by the cost model.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L91)

<a id="field-field-minisql-planner-execution-plan-sourceplan-estimatedcost-estimatedcost-src-minisql-planner-execution-plan-ml-1421331989"></a>
### estimatedCost

```ml
estimatedCost
```

Deterministic integer cost of this access path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L99)

<a id="field-field-minisql-planner-execution-plan-sourceplan-estimatedrows-estimatedrows-src-minisql-planner-execution-plan-ml-1184029157"></a>
### estimatedRows

```ml
estimatedRows
```

Estimated rows surviving source-local predicates.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L97)

<a id="field-field-minisql-planner-execution-plan-sourceplan-indexname-indexname-src-minisql-planner-execution-plan-ml-1249042129"></a>
### indexName

```ml
indexName
```

Selected index name or an empty string for a sequential scan.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L93)

<a id="field-field-minisql-planner-execution-plan-sourceplan-indexnames-indexnames-src-minisql-planner-execution-plan-ml-1458792573"></a>
### indexNames

```ml
indexNames
```

Stable names participating in an intersection/union access path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L95)

<a id="field-field-minisql-planner-execution-plan-sourceplan-pushedpredicate-pushedpredicate-src-minisql-planner-execution-plan-ml-1712631237"></a>
### pushedPredicate

```ml
pushedPredicate
```

Safe single-source predicate evaluated before joining.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L101)

<a id="field-field-minisql-planner-execution-plan-sourceplan-sourceindex-sourceindex-src-minisql-planner-execution-plan-ml-1947860949"></a>
### sourceIndex

```ml
sourceIndex
```

Position in BoundSelect.sources.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L89)
