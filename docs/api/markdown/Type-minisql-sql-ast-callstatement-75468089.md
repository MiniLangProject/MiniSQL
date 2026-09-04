# `minisql.sql.ast.CallStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-callstatement-struct-callstatement-src-minisql-sql-ast-ml-2009370567"></a>
## CallStatement

```ml
struct CallStatement
```

Represents invocation of a stored procedure with positional arguments.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L621)

## Members

<a id="field-field-minisql-sql-ast-callstatement-arguments-arguments-src-minisql-sql-ast-ml-903686212"></a>
### arguments

```ml
arguments
```

Contains ordered argument expressions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L625)

<a id="field-field-minisql-sql-ast-callstatement-name-name-src-minisql-sql-ast-ml-147198642"></a>
### name

```ml
name
```

Stores the qualified procedure name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L623)
