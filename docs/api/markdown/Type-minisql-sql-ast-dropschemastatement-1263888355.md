# `minisql.sql.ast.DropSchemaStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-dropschemastatement-struct-dropschemastatement-src-minisql-sql-ast-ml-484150075"></a>
## DropSchemaStatement

```ml
struct DropSchemaStatement
```

Represents removal of an empty SQL object namespace.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L507)

## Members

<a id="field-field-minisql-sql-ast-dropschemastatement-ifexists-ifexists-src-minisql-sql-ast-ml-2027460680"></a>
### ifExists

```ml
ifExists
```

Indicates whether a missing schema is accepted.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L511)

<a id="field-field-minisql-sql-ast-dropschemastatement-name-name-src-minisql-sql-ast-ml-107194380"></a>
### name

```ml
name
```

Stores the schema name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L509)
