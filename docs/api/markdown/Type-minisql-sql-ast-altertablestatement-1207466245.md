# `minisql.sql.ast.AlterTableStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-altertablestatement-struct-altertablestatement-src-minisql-sql-ast-ml-1426991787"></a>
## AlterTableStatement

```ml
struct AlterTableStatement
```

Groups the alter table statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L629)

## Members

<a id="field-field-minisql-sql-ast-altertablestatement-action-action-src-minisql-sql-ast-ml-7523668"></a>
### action

```ml
action
```

Stores the action associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L633)

<a id="field-field-minisql-sql-ast-altertablestatement-columndefinition-columndefinition-src-minisql-sql-ast-ml-1803101622"></a>
### columnDefinition

```ml
columnDefinition
```

Stores the column definition associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L635)

<a id="field-field-minisql-sql-ast-altertablestatement-constraint-constraint-src-minisql-sql-ast-ml-1409317434"></a>
### constraint

```ml
constraint
```

Stores the constraint associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L641)

<a id="field-field-minisql-sql-ast-altertablestatement-constraintname-constraintname-src-minisql-sql-ast-ml-1803450252"></a>
### constraintName

```ml
constraintName
```

Stores the constraint name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L643)

<a id="field-field-minisql-sql-ast-altertablestatement-newname-newname-src-minisql-sql-ast-ml-35162436"></a>
### newName

```ml
newName
```

Stores the new name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L639)

<a id="field-field-minisql-sql-ast-altertablestatement-oldname-oldname-src-minisql-sql-ast-ml-339169012"></a>
### oldName

```ml
oldName
```

Stores the old name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L637)

<a id="field-field-minisql-sql-ast-altertablestatement-tablename-tablename-src-minisql-sql-ast-ml-2095417340"></a>
### tableName

```ml
tableName
```

Stores the table name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L631)
