# `minisql.sql.ast.ShutdownStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-shutdownstatement-struct-shutdownstatement-src-minisql-sql-ast-ml-1796411131"></a>
## ShutdownStatement

```ml
struct ShutdownStatement
```

Requests a cooperative, draining shutdown of the database listener.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L947)

## Members

<a id="field-field-minisql-sql-ast-shutdownstatement-marker-marker-src-minisql-sql-ast-ml-1512058938"></a>
### marker

```ml
marker
```

Keeps the statement non-empty without attaching mutable execution state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L949)
