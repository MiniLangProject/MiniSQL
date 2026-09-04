# `minisql.sql.values.SqlValue`

[Home](README.md) · [Source file](File-src-minisql-sql-values-ml-1302895578.md)

<a id="struct-struct-minisql-sql-values-sqlvalue-struct-sqlvalue-src-minisql-sql-values-ml-606540525"></a>
## SqlValue

```ml
struct SqlValue
```

Groups the SQL value state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L26)

## Members

<a id="field-field-minisql-sql-values-sqlvalue-isnull-isnull-src-minisql-sql-values-ml-1908467320"></a>
### isNull

```ml
isNull
```

Indicates whether the is null condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L30)

<a id="field-field-minisql-sql-values-sqlvalue-typekind-typekind-src-minisql-sql-values-ml-652400806"></a>
### typeKind

```ml
typeKind
```

Stores the type kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L28)

<a id="field-field-minisql-sql-values-sqlvalue-value-value-src-minisql-sql-values-ml-57467238"></a>
### value

```ml
value
```

Stores the value associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L32)
