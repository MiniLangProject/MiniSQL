# `minisql.sql.ast.RoutineStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-routinestatement-struct-routinestatement-src-minisql-sql-ast-ml-264888011"></a>
## RoutineStatement

```ml
struct RoutineStatement
```

Represents one procedural statement without weakening ordinary SQL AST types. The kind determines the contracts of its remaining fields; nested statements always live in body/alternate and expressions remain ordinary SQL AST nodes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L603)

## Members

<a id="field-field-minisql-sql-ast-routinestatement-alternate-alternate-src-minisql-sql-ast-ml-1689908712"></a>
### alternate

```ml
alternate
```

ELSE branch statements, when present.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L615)

<a id="field-field-minisql-sql-ast-routinestatement-body-body-src-minisql-sql-ast-ml-2048580848"></a>
### body

```ml
body
```

Ordered nested statements or branch BLOCK nodes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L613)

<a id="field-field-minisql-sql-ast-routinestatement-expressions-expressions-src-minisql-sql-ast-ml-2043126304"></a>
### expressions

```ml
expressions
```

Ordered SQL expression operands.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L611)

<a id="field-field-minisql-sql-ast-routinestatement-kind-kind-src-minisql-sql-ast-ml-973550396"></a>
### kind

```ml
kind
```

Uppercase procedural operation (BLOCK, DECLARE, IF, SET, and so on).


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L605)

<a id="field-field-minisql-sql-ast-routinestatement-name-name-src-minisql-sql-ast-ml-1514226110"></a>
### name

```ml
name
```

Label, cursor, condition, procedure name, or handler action when applicable.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L607)

<a id="field-field-minisql-sql-ast-routinestatement-names-names-src-minisql-sql-ast-ml-1720586224"></a>
### names

```ml
names
```

Ordered variable targets or diagnostic item names.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L609)

<a id="field-field-minisql-sql-ast-routinestatement-options-options-src-minisql-sql-ast-ml-1247937320"></a>
### options

```ml
options
```

Kind-specific type, condition, or characteristic metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L617)
