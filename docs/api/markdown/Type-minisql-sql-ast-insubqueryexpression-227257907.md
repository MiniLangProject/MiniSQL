# `minisql.sql.ast.InSubqueryExpression`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-insubqueryexpression-struct-insubqueryexpression-src-minisql-sql-ast-ml-810519075"></a>
## InSubqueryExpression

```ml
struct InSubqueryExpression
```

Groups the in subquery expression state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L323)

## Members

<a id="field-field-minisql-sql-ast-insubqueryexpression-kind-kind-src-minisql-sql-ast-ml-865139610"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L325)

<a id="field-field-minisql-sql-ast-insubqueryexpression-negated-negated-src-minisql-sql-ast-ml-1734928534"></a>
### negated

```ml
negated
```

Indicates whether the negated condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L331)

<a id="field-field-minisql-sql-ast-insubqueryexpression-operand-operand-src-minisql-sql-ast-ml-795914442"></a>
### operand

```ml
operand
```

Stores the operand associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L327)

<a id="field-field-minisql-sql-ast-insubqueryexpression-query-query-src-minisql-sql-ast-ml-672834306"></a>
### query

```ml
query
```

Stores the query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L329)
