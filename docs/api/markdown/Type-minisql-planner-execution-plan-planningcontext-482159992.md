# `minisql.planner.execution_plan.PlanningContext`

[Home](README.md) · [Source file](File-src-minisql-planner-execution-plan-ml-1727378828.md)

<a id="struct-struct-minisql-planner-execution-plan-planningcontext-struct-planningcontext-src-minisql-planner-execution-plan-ml-52363803"></a>
## PlanningContext

```ml
struct PlanningContext
```

Immutable planning inputs loaded by the executor from one catalog snapshot.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L57)

## Members

<a id="field-field-minisql-planner-execution-plan-planningcontext-indexes-indexes-src-minisql-planner-execution-plan-ml-73860247"></a>
### indexes

```ml
indexes
```

Immutable index metadata snapshot.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L61)

<a id="field-field-minisql-planner-execution-plan-planningcontext-schemageneration-schemageneration-src-minisql-planner-execution-plan-ml-949086025"></a>
### schemaGeneration

```ml
schemaGeneration
```

Process-local DDL and maintenance generation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L63)

<a id="field-field-minisql-planner-execution-plan-planningcontext-statistics-statistics-src-minisql-planner-execution-plan-ml-329442493"></a>
### statistics

```ml
statistics
```

Immutable statistics catalog snapshot.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L59)
