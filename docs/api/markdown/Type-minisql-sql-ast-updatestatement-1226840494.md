# `minisql.sql.ast.UpdateStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-updatestatement-struct-updatestatement-src-minisql-sql-ast-ml-550195105"></a>
## UpdateStatement

```ml
struct UpdateStatement
```

Groups the update statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L669)

## Members

<a id="field-field-minisql-sql-ast-updatestatement-assignments-assignments-src-minisql-sql-ast-ml-1867215309"></a>
### assignments

```ml
assignments
```

Contains the ordered assignments collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L673)

<a id="field-field-minisql-sql-ast-updatestatement-returning-returning-src-minisql-sql-ast-ml-1725096141"></a>
### returning

```ml
returning
```

Stores the returning associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L677)

<a id="field-field-minisql-sql-ast-updatestatement-tablename-tablename-src-minisql-sql-ast-ml-1235354997"></a>
### tableName

```ml
tableName
```

Stores the table name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L671)

<a id="field-field-minisql-sql-ast-updatestatement-whereexpression-whereexpression-src-minisql-sql-ast-ml-558282981"></a>
### whereExpression

```ml
whereExpression
```

Stores the where expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L675)
