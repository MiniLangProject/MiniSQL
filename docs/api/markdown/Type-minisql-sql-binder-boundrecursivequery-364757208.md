# `minisql.sql.binder.BoundRecursiveQuery`

[Home](README.md) · [Source file](File-src-minisql-sql-binder-ml-1729118960.md)

<a id="struct-struct-minisql-sql-binder-boundrecursivequery-struct-boundrecursivequery-src-minisql-sql-binder-ml-265801019"></a>
## BoundRecursiveQuery

```ml
struct BoundRecursiveQuery
```

Represents the two executable halves of a recursive CTE fixpoint.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L55)

## Members

<a id="field-field-minisql-sql-binder-boundrecursivequery-anchor-anchor-src-minisql-sql-binder-ml-1034816761"></a>
### anchor

```ml
anchor
```

Stores the non-recursive seed SELECT.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L59)

<a id="field-field-minisql-sql-binder-boundrecursivequery-name-name-src-minisql-sql-binder-ml-1547022505"></a>
### name

```ml
name
```

Stores the CTE name used to identify its working-table frame.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L57)

<a id="field-field-minisql-sql-binder-boundrecursivequery-recursiveterm-recursiveterm-src-minisql-sql-binder-ml-156931899"></a>
### recursiveTerm

```ml
recursiveTerm
```

Stores the recursive SELECT evaluated for each delta.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L61)

<a id="field-field-minisql-sql-binder-boundrecursivequery-unionall-unionall-src-minisql-sql-binder-ml-252875947"></a>
### unionAll

```ml
unionAll
```

Indicates UNION ALL bag semantics rather than UNION deduplication.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L63)
