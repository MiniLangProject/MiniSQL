# `minisql.sql.ast.CommonTableExpression`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-commontableexpression-struct-commontableexpression-src-minisql-sql-ast-ml-758641035"></a>
## CommonTableExpression

```ml
struct CommonTableExpression
```

Groups the common table expression state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L666)

## Members

<a id="field-field-minisql-sql-ast-commontableexpression-columnnames-columnnames-src-minisql-sql-ast-ml-1194830656"></a>
### columnNames

```ml
columnNames
```

Stores the column names associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L672)

<a id="field-field-minisql-sql-ast-commontableexpression-name-name-src-minisql-sql-ast-ml-2127395038"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L668)

<a id="field-field-minisql-sql-ast-commontableexpression-query-query-src-minisql-sql-ast-ml-781073148"></a>
### query

```ml
query
```

Stores the query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L670)

<a id="field-field-minisql-sql-ast-commontableexpression-recursive-recursive-src-minisql-sql-ast-ml-994502916"></a>
### recursive

```ml
recursive
```

Indicates whether this CTE may reference its own working table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L674)
