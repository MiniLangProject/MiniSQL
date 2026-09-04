# `minisql.planner.execution_plan.IndexInfo`

[Home](README.md) · [Source file](File-src-minisql-planner-execution-plan-ml-1727378828.md)

<a id="struct-struct-minisql-planner-execution-plan-indexinfo-struct-indexinfo-src-minisql-planner-execution-plan-ml-758307927"></a>
## IndexInfo

```ml
struct IndexInfo
```

Describes one persistent index without exposing catalog implementation details to the optimizer. Column indexes are local to the owning table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L59)

## Members

<a id="field-field-minisql-planner-execution-plan-indexinfo-columnindexes-columnindexes-src-minisql-planner-execution-plan-ml-1256923379"></a>
### columnIndexes

```ml
columnIndexes
```

Ordered table-local key columns; -1 marks an expression-key position.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L65)

<a id="field-field-minisql-planner-execution-plan-indexinfo-includedcolumnindexes-includedcolumnindexes-src-minisql-planner-execution-plan-ml-2050928659"></a>
### includedColumnIndexes

```ml
includedColumnIndexes
```

Ordered table-local non-key columns stored in leaf payloads.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L69)

<a id="field-field-minisql-planner-execution-plan-indexinfo-keyexpressions-keyexpressions-src-minisql-planner-execution-plan-ml-619192171"></a>
### keyExpressions

```ml
keyExpressions
```

Position-aligned bound expression keys; ordinary column positions are void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L67)

<a id="field-field-minisql-planner-execution-plan-indexinfo-name-name-src-minisql-planner-execution-plan-ml-819824353"></a>
### name

```ml
name
```

Stable catalog index name used by execution diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L63)

<a id="field-field-minisql-planner-execution-plan-indexinfo-predicate-predicate-src-minisql-planner-execution-plan-ml-2054308859"></a>
### predicate

```ml
predicate
```

Optional bound predicate restricting rows physically present in the index.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L71)

<a id="field-field-minisql-planner-execution-plan-indexinfo-tableid-tableid-src-minisql-planner-execution-plan-ml-357257591"></a>
### tableId

```ml
tableId
```

Owning catalog table identifier.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L61)

<a id="field-field-minisql-planner-execution-plan-indexinfo-unique-unique-src-minisql-planner-execution-plan-ml-1608215125"></a>
### unique

```ml
unique
```

Whether the complete key enforces uniqueness.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/planner/execution_plan.ml#L73)
