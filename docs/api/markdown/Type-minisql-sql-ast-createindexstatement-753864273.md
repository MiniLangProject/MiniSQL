# `minisql.sql.ast.CreateIndexStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-createindexstatement-struct-createindexstatement-src-minisql-sql-ast-ml-1533478219"></a>
## CreateIndexStatement

```ml
struct CreateIndexStatement
```

Groups the create index statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L465)

## Members

<a id="field-field-minisql-sql-ast-createindexstatement-columns-columns-src-minisql-sql-ast-ml-355163804"></a>
### columns

```ml
columns
```

Contains ordered column or deterministic expression key AST nodes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L471)

<a id="field-field-minisql-sql-ast-createindexstatement-ifnotexists-ifnotexists-src-minisql-sql-ast-ml-1568622572"></a>
### ifNotExists

```ml
ifNotExists
```

Stores the if not exists associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L479)

<a id="field-field-minisql-sql-ast-createindexstatement-includecolumns-includecolumns-src-minisql-sql-ast-ml-1823700614"></a>
### includeColumns

```ml
includeColumns
```

Ordered non-key columns persisted in each leaf entry for covering scans.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L473)

<a id="field-field-minisql-sql-ast-createindexstatement-name-name-src-minisql-sql-ast-ml-935304174"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L467)

<a id="field-field-minisql-sql-ast-createindexstatement-tablename-tablename-src-minisql-sql-ast-ml-578987552"></a>
### tableName

```ml
tableName
```

Stores the table name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L469)

<a id="field-field-minisql-sql-ast-createindexstatement-unique-unique-src-minisql-sql-ast-ml-1117084674"></a>
### unique

```ml
unique
```

Indicates whether the unique condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L477)

<a id="field-field-minisql-sql-ast-createindexstatement-whereexpression-whereexpression-src-minisql-sql-ast-ml-1210705960"></a>
### whereExpression

```ml
whereExpression
```

Optional deterministic predicate selecting rows stored by a partial index.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L475)
