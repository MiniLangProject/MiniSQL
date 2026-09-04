# `minisql.sql.ast.CreateProcedureStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-createprocedurestatement-struct-createprocedurestatement-src-minisql-sql-ast-ml-697740043"></a>
## CreateProcedureStatement

```ml
struct CreateProcedureStatement
```

Represents a persisted single-statement stored procedure.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L601)

## Members

<a id="field-field-minisql-sql-ast-createprocedurestatement-body-body-src-minisql-sql-ast-ml-1458649717"></a>
### body

```ml
body
```

Stores the procedure's DML body.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L607)

<a id="field-field-minisql-sql-ast-createprocedurestatement-name-name-src-minisql-sql-ast-ml-1407481323"></a>
### name

```ml
name
```

Stores the qualified procedure name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L603)

<a id="field-field-minisql-sql-ast-createprocedurestatement-parameters-parameters-src-minisql-sql-ast-ml-724145521"></a>
### parameters

```ml
parameters
```

Contains ordered input parameters.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L605)

<a id="field-field-minisql-sql-ast-createprocedurestatement-replace-replace-src-minisql-sql-ast-ml-1463890905"></a>
### replace

```ml
replace
```

Indicates CREATE OR REPLACE behavior.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L609)
