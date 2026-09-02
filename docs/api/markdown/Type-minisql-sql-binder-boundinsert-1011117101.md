# `minisql.sql.binder.BoundInsert`

[Home](README.md) · [Source file](File-src-minisql-sql-binder-ml-1729118960.md)

<a id="struct-struct-minisql-sql-binder-boundinsert-struct-boundinsert-src-minisql-sql-binder-ml-1804669985"></a>
## BoundInsert

```ml
struct BoundInsert
```

Groups the bound insert state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L138)

## Members

<a id="field-field-minisql-sql-binder-boundinsert-columnindexes-columnindexes-src-minisql-sql-binder-ml-1388757826"></a>
### columnIndexes

```ml
columnIndexes
```

Stores the column indexes associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L144)

<a id="field-field-minisql-sql-binder-boundinsert-conflictassignments-conflictassignments-src-minisql-sql-binder-ml-1499334806"></a>
### conflictAssignments

```ml
conflictAssignments
```

Stores the conflict assignments associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L152)

<a id="field-field-minisql-sql-binder-boundinsert-conflictconstraint-conflictconstraint-src-minisql-sql-binder-ml-946544300"></a>
### conflictConstraint

```ml
conflictConstraint
```

Stores the conflict constraint associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L150)

<a id="field-field-minisql-sql-binder-boundinsert-conflictwhere-conflictwhere-src-minisql-sql-binder-ml-1610555762"></a>
### conflictWhere

```ml
conflictWhere
```

Stores the conflict where associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L154)

<a id="field-field-minisql-sql-binder-boundinsert-returning-returning-src-minisql-sql-binder-ml-1144758762"></a>
### returning

```ml
returning
```

Stores the returning associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L156)

<a id="field-field-minisql-sql-binder-boundinsert-rows-rows-src-minisql-sql-binder-ml-203954928"></a>
### rows

```ml
rows
```

Contains the ordered rows collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L146)

<a id="field-field-minisql-sql-binder-boundinsert-sourcequery-sourcequery-src-minisql-sql-binder-ml-1817925658"></a>
### sourceQuery

```ml
sourceQuery
```

Stores the source query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L148)

<a id="field-field-minisql-sql-binder-boundinsert-statement-statement-src-minisql-sql-binder-ml-709021726"></a>
### statement

```ml
statement
```

Stores the statement associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L140)

<a id="field-field-minisql-sql-binder-boundinsert-table-table-src-minisql-sql-binder-ml-1066913286"></a>
### table

```ml
table
```

Stores the table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L142)
