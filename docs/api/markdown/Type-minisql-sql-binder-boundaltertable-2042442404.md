# `minisql.sql.binder.BoundAlterTable`

[Home](README.md) · [Source file](File-src-minisql-sql-binder-ml-1729118960.md)

<a id="struct-struct-minisql-sql-binder-boundaltertable-struct-boundaltertable-src-minisql-sql-binder-ml-353222855"></a>
## BoundAlterTable

```ml
struct BoundAlterTable
```

Groups the bound alter table state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L240)

## Members

<a id="field-field-minisql-sql-binder-boundaltertable-columntype-columntype-src-minisql-sql-binder-ml-772148527"></a>
### columnType

```ml
columnType
```

Stores the column type associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L246)

<a id="field-field-minisql-sql-binder-boundaltertable-command-command-src-minisql-sql-binder-ml-45311603"></a>
### command

```ml
command
```

Preserves the user-visible DDL command when several syntaxes share one journal action.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L248)

<a id="field-field-minisql-sql-binder-boundaltertable-statement-statement-src-minisql-sql-binder-ml-1129455587"></a>
### statement

```ml
statement
```

Stores the statement associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L242)

<a id="field-field-minisql-sql-binder-boundaltertable-table-table-src-minisql-sql-binder-ml-1660743915"></a>
### table

```ml
table
```

Stores the table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L244)
