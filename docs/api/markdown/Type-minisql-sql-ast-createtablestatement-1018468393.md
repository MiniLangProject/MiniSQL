# `minisql.sql.ast.CreateTableStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-createtablestatement-struct-createtablestatement-src-minisql-sql-ast-ml-15894355"></a>
## CreateTableStatement

```ml
struct CreateTableStatement
```

Groups the create table statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L398)

## Members

<a id="field-field-minisql-sql-ast-createtablestatement-columns-columns-src-minisql-sql-ast-ml-650788940"></a>
### columns

```ml
columns
```

Contains the ordered columns collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L402)

<a id="field-field-minisql-sql-ast-createtablestatement-constraints-constraints-src-minisql-sql-ast-ml-525140980"></a>
### constraints

```ml
constraints
```

Contains the ordered constraints collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L404)

<a id="field-field-minisql-sql-ast-createtablestatement-ifnotexists-ifnotexists-src-minisql-sql-ast-ml-1609439004"></a>
### ifNotExists

```ml
ifNotExists
```

Stores the if not exists associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L406)

<a id="field-field-minisql-sql-ast-createtablestatement-name-name-src-minisql-sql-ast-ml-511554654"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L400)
