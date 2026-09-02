# `minisql.sql.ast.DropIndexStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-dropindexstatement-struct-dropindexstatement-src-minisql-sql-ast-ml-1375377431"></a>
## DropIndexStatement

```ml
struct DropIndexStatement
```

Represents removal of one explicitly-created index by its database-wide name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L428)

## Members

<a id="field-field-minisql-sql-ast-dropindexstatement-ifexists-ifexists-src-minisql-sql-ast-ml-893995917"></a>
### ifExists

```ml
ifExists
```

Allows the command to succeed without mutation when the index is absent.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L432)

<a id="field-field-minisql-sql-ast-dropindexstatement-name-name-src-minisql-sql-ast-ml-133884873"></a>
### name

```ml
name
```

Stores the index name selected for removal.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L430)
