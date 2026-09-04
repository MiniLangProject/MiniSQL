# `minisql.sql.ast.IsNullExpression`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-isnullexpression-struct-isnullexpression-src-minisql-sql-ast-ml-177643731"></a>
## IsNullExpression

```ml
struct IsNullExpression
```

Groups the is null expression state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L201)

## Members

<a id="field-field-minisql-sql-ast-isnullexpression-kind-kind-src-minisql-sql-ast-ml-1462408654"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L203)

<a id="field-field-minisql-sql-ast-isnullexpression-negated-negated-src-minisql-sql-ast-ml-375653930"></a>
### negated

```ml
negated
```

Indicates whether the negated condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L207)

<a id="field-field-minisql-sql-ast-isnullexpression-operand-operand-src-minisql-sql-ast-ml-357552222"></a>
### operand

```ml
operand
```

Stores the operand associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L205)
