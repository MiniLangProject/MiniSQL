# `minisql.sql.ast.ProcedureParameter`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-procedureparameter-struct-procedureparameter-src-minisql-sql-ast-ml-2000095011"></a>
## ProcedureParameter

```ml
struct ProcedureParameter
```

Defines one named stored-procedure parameter and its passing direction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L621)

## Members

<a id="field-field-minisql-sql-ast-procedureparameter-mode-mode-src-minisql-sql-ast-ml-1962560865"></a>
### mode

```ml
mode
```

IN, OUT, or INOUT; omitted SQL directions become IN.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L627)

<a id="field-field-minisql-sql-ast-procedureparameter-name-name-src-minisql-sql-ast-ml-1426121309"></a>
### name

```ml
name
```

Stores the parameter name used in the procedure body.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L623)

<a id="field-field-minisql-sql-ast-procedureparameter-typename-typename-src-minisql-sql-ast-ml-1899241405"></a>
### typeName

```ml
typeName
```

Stores its declared SQL type.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L625)
