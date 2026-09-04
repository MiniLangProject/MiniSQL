# `minisql.sql.ast.InsertStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-insertstatement-struct-insertstatement-src-minisql-sql-ast-ml-816115929"></a>
## InsertStatement

```ml
struct InsertStatement
```

Groups the insert statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L647)

## Members

<a id="field-field-minisql-sql-ast-insertstatement-columns-columns-src-minisql-sql-ast-ml-766630705"></a>
### columns

```ml
columns
```

Contains the ordered columns collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L651)

<a id="field-field-minisql-sql-ast-insertstatement-conflictaction-conflictaction-src-minisql-sql-ast-ml-690966337"></a>
### conflictAction

```ml
conflictAction
```

Stores the conflict action associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L659)

<a id="field-field-minisql-sql-ast-insertstatement-conflictassignments-conflictassignments-src-minisql-sql-ast-ml-662122753"></a>
### conflictAssignments

```ml
conflictAssignments
```

Stores the conflict assignments associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L661)

<a id="field-field-minisql-sql-ast-insertstatement-conflicttarget-conflicttarget-src-minisql-sql-ast-ml-1247351491"></a>
### conflictTarget

```ml
conflictTarget
```

Stores the conflict target associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L657)

<a id="field-field-minisql-sql-ast-insertstatement-conflictwhere-conflictwhere-src-minisql-sql-ast-ml-944006317"></a>
### conflictWhere

```ml
conflictWhere
```

Stores the conflict where associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L663)

<a id="field-field-minisql-sql-ast-insertstatement-returning-returning-src-minisql-sql-ast-ml-1537359085"></a>
### returning

```ml
returning
```

Stores the returning associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L665)

<a id="field-field-minisql-sql-ast-insertstatement-rows-rows-src-minisql-sql-ast-ml-1771621047"></a>
### rows

```ml
rows
```

Contains the ordered rows collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L653)

<a id="field-field-minisql-sql-ast-insertstatement-sourcequery-sourcequery-src-minisql-sql-ast-ml-1817797461"></a>
### sourceQuery

```ml
sourceQuery
```

Stores the source query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L655)

<a id="field-field-minisql-sql-ast-insertstatement-tablename-tablename-src-minisql-sql-ast-ml-1172104853"></a>
### tableName

```ml
tableName
```

Stores the table name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L649)
