# `minisql.sql.ast.TypedLiteralExpression`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-typedliteralexpression-struct-typedliteralexpression-src-minisql-sql-ast-ml-107293731"></a>
## TypedLiteralExpression

```ml
struct TypedLiteralExpression
```

Internal typed literals preserve a fully decoded SqlValue while the executor materializes non-correlated subqueries and sequence calls before binding. Groups the typed literal expression state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L244)

## Members

<a id="field-field-minisql-sql-ast-typedliteralexpression-kind-kind-src-minisql-sql-ast-ml-236227096"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L246)

<a id="field-field-minisql-sql-ast-typedliteralexpression-value-value-src-minisql-sql-ast-ml-880918576"></a>
### value

```ml
value
```

Stores the value associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L248)
