# `minisql.sql.ast.ColumnDefinition`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-columndefinition-struct-columndefinition-src-minisql-sql-ast-ml-250949043"></a>
## ColumnDefinition

```ml
struct ColumnDefinition
```

Groups the column definition state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L294)

## Members

<a id="field-field-minisql-sql-ast-columndefinition-checkexpression-checkexpression-src-minisql-sql-ast-ml-1938472018"></a>
### checkExpression

```ml
checkExpression
```

Stores the check expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L310)

<a id="field-field-minisql-sql-ast-columndefinition-defaultexpression-defaultexpression-src-minisql-sql-ast-ml-1311032150"></a>
### defaultExpression

```ml
defaultExpression
```

Stores the default expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L308)

<a id="field-field-minisql-sql-ast-columndefinition-generatedexpression-generatedexpression-src-minisql-sql-ast-ml-555956918"></a>
### generatedExpression

```ml
generatedExpression
```

Stores the generated expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L322)

<a id="field-field-minisql-sql-ast-columndefinition-generatedstored-generatedstored-src-minisql-sql-ast-ml-737892962"></a>
### generatedStored

```ml
generatedStored
```

Stores the generated stored associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L324)

<a id="field-field-minisql-sql-ast-columndefinition-identity-identity-src-minisql-sql-ast-ml-356714402"></a>
### identity

```ml
identity
```

Stores the identity associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L320)

<a id="field-field-minisql-sql-ast-columndefinition-name-name-src-minisql-sql-ast-ml-71156608"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L296)

<a id="field-field-minisql-sql-ast-columndefinition-nullable-nullable-src-minisql-sql-ast-ml-1449895712"></a>
### nullable

```ml
nullable
```

Indicates whether the nullable condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L300)

<a id="field-field-minisql-sql-ast-columndefinition-nullablespecified-nullablespecified-src-minisql-sql-ast-ml-1143191586"></a>
### nullableSpecified

```ml
nullableSpecified
```

Indicates whether the nullable specified condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L302)

<a id="field-field-minisql-sql-ast-columndefinition-ondelete-ondelete-src-minisql-sql-ast-ml-1752450782"></a>
### onDelete

```ml
onDelete
```

Stores the on delete associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L316)

<a id="field-field-minisql-sql-ast-columndefinition-onupdate-onupdate-src-minisql-sql-ast-ml-1616574498"></a>
### onUpdate

```ml
onUpdate
```

Stores the on update associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L318)

<a id="field-field-minisql-sql-ast-columndefinition-primarykey-primarykey-src-minisql-sql-ast-ml-1022968320"></a>
### primaryKey

```ml
primaryKey
```

Indicates whether the primary key condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L304)

<a id="field-field-minisql-sql-ast-columndefinition-referencescolumns-referencescolumns-src-minisql-sql-ast-ml-89636634"></a>
### referencesColumns

```ml
referencesColumns
```

Stores the references columns associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L314)

<a id="field-field-minisql-sql-ast-columndefinition-referencestable-referencestable-src-minisql-sql-ast-ml-1438326018"></a>
### referencesTable

```ml
referencesTable
```

Stores the references table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L312)

<a id="field-field-minisql-sql-ast-columndefinition-typename-typename-src-minisql-sql-ast-ml-1294956640"></a>
### typeName

```ml
typeName
```

Stores the type name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L298)

<a id="field-field-minisql-sql-ast-columndefinition-unique-unique-src-minisql-sql-ast-ml-1903033052"></a>
### unique

```ml
unique
```

Indicates whether the unique condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L306)
