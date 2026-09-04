# `minisql.sql.ast.DropProcedureStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-dropprocedurestatement-struct-dropprocedurestatement-src-minisql-sql-ast-ml-1211187719"></a>
## DropProcedureStatement

```ml
struct DropProcedureStatement
```

Represents removal of a stored procedure.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L613)

## Members

<a id="field-field-minisql-sql-ast-dropprocedurestatement-ifexists-ifexists-src-minisql-sql-ast-ml-289120404"></a>
### ifExists

```ml
ifExists
```

Indicates whether a missing procedure is accepted.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L617)

<a id="field-field-minisql-sql-ast-dropprocedurestatement-name-name-src-minisql-sql-ast-ml-1952902680"></a>
### name

```ml
name
```

Stores the qualified procedure name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L615)
