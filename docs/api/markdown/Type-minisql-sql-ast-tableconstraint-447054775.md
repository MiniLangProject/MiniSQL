# `minisql.sql.ast.TableConstraint`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-tableconstraint-struct-tableconstraint-src-minisql-sql-ast-ml-490743163"></a>
## TableConstraint

```ml
struct TableConstraint
```

Groups the table constraint state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L328)

## Members

<a id="field-field-minisql-sql-ast-tableconstraint-columns-columns-src-minisql-sql-ast-ml-568396642"></a>
### columns

```ml
columns
```

Contains the ordered columns collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L334)

<a id="field-field-minisql-sql-ast-tableconstraint-expression-expression-src-minisql-sql-ast-ml-397560126"></a>
### expression

```ml
expression
```

Stores the expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L336)

<a id="field-field-minisql-sql-ast-tableconstraint-kind-kind-src-minisql-sql-ast-ml-1535399466"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L330)

<a id="field-field-minisql-sql-ast-tableconstraint-name-name-src-minisql-sql-ast-ml-371539700"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L332)

<a id="field-field-minisql-sql-ast-tableconstraint-ondelete-ondelete-src-minisql-sql-ast-ml-539929682"></a>
### onDelete

```ml
onDelete
```

Stores the on delete associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L342)

<a id="field-field-minisql-sql-ast-tableconstraint-onupdate-onupdate-src-minisql-sql-ast-ml-211146630"></a>
### onUpdate

```ml
onUpdate
```

Stores the on update associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L344)

<a id="field-field-minisql-sql-ast-tableconstraint-referencescolumns-referencescolumns-src-minisql-sql-ast-ml-818277374"></a>
### referencesColumns

```ml
referencesColumns
```

Stores the references columns associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L340)

<a id="field-field-minisql-sql-ast-tableconstraint-referencestable-referencestable-src-minisql-sql-ast-ml-873819014"></a>
### referencesTable

```ml
referencesTable
```

Stores the references table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L338)
