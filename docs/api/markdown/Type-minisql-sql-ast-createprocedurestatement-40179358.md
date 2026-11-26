# `minisql.sql.ast.CreateProcedureStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-createprocedurestatement-struct-createprocedurestatement-src-minisql-sql-ast-ml-697740043"></a>
## CreateProcedureStatement

```ml
struct CreateProcedureStatement
```

Represents a persisted procedure with a single SQL or compound body.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L631)

## Members

<a id="field-field-minisql-sql-ast-createprocedurestatement-body-body-src-minisql-sql-ast-ml-1458649717"></a>
### body

```ml
body
```

Stores the procedure's SQL or procedural body.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L637)

<a id="field-field-minisql-sql-ast-createprocedurestatement-characteristics-characteristics-src-minisql-sql-ast-ml-1944941777"></a>
### characteristics

```ml
characteristics
```

Ordered [name, value] characteristic pairs explicitly supplied by the user.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L641)

<a id="field-field-minisql-sql-ast-createprocedurestatement-ifnotexists-ifnotexists-src-minisql-sql-ast-ml-389823973"></a>
### ifNotExists

```ml
ifNotExists
```

Allows creation to succeed when the procedure already exists.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L643)

<a id="field-field-minisql-sql-ast-createprocedurestatement-name-name-src-minisql-sql-ast-ml-1407481323"></a>
### name

```ml
name
```

Stores the qualified procedure name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L633)

<a id="field-field-minisql-sql-ast-createprocedurestatement-parameters-parameters-src-minisql-sql-ast-ml-724145521"></a>
### parameters

```ml
parameters
```

Contains ordered input parameters.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L635)

<a id="field-field-minisql-sql-ast-createprocedurestatement-replace-replace-src-minisql-sql-ast-ml-1463890905"></a>
### replace

```ml
replace
```

Indicates CREATE OR REPLACE behavior.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L639)
