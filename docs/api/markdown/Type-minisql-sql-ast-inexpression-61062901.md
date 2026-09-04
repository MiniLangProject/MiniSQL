# `minisql.sql.ast.InExpression`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-inexpression-struct-inexpression-src-minisql-sql-ast-ml-1104510715"></a>
## InExpression

```ml
struct InExpression
```

Groups the in expression state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L259)

## Members

<a id="field-field-minisql-sql-ast-inexpression-kind-kind-src-minisql-sql-ast-ml-962375980"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L261)

<a id="field-field-minisql-sql-ast-inexpression-negated-negated-src-minisql-sql-ast-ml-1994027400"></a>
### negated

```ml
negated
```

Indicates whether the negated condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L267)

<a id="field-field-minisql-sql-ast-inexpression-operand-operand-src-minisql-sql-ast-ml-75248884"></a>
### operand

```ml
operand
```

Stores the operand associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L263)

<a id="field-field-minisql-sql-ast-inexpression-values-values-src-minisql-sql-ast-ml-368811316"></a>
### values

```ml
values
```

Contains the ordered values collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L265)
