# `minisql.sql.binder.BoundRecursiveReference`

[Home](README.md) · [Source file](File-src-minisql-sql-binder-ml-1729118960.md)

<a id="struct-struct-minisql-sql-binder-boundrecursivereference-struct-boundrecursivereference-src-minisql-sql-binder-ml-1328043797"></a>
## BoundRecursiveReference

```ml
struct BoundRecursiveReference
```

Marks a recursive self-reference that scans the current iteration's delta rows.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L67)

## Members

<a id="field-field-minisql-sql-binder-boundrecursivereference-name-name-src-minisql-sql-binder-ml-1216145844"></a>
### name

```ml
name
```

Stores the recursive CTE name associated with the working table.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L69)
