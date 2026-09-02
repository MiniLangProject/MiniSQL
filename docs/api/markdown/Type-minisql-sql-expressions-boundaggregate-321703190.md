# `minisql.sql.expressions.BoundAggregate`

[Home](README.md) · [Source file](File-src-minisql-sql-expressions-ml-980820199.md)

<a id="struct-struct-minisql-sql-expressions-boundaggregate-struct-boundaggregate-src-minisql-sql-expressions-ml-1013364785"></a>
## BoundAggregate

```ml
struct BoundAggregate
```

Groups the bound aggregate state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L55)

## Members

<a id="field-field-minisql-sql-expressions-boundaggregate-argument-argument-src-minisql-sql-expressions-ml-1260207054"></a>
### argument

```ml
argument
```

Stores the argument associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L61)

<a id="field-field-minisql-sql-expressions-boundaggregate-countstar-countstar-src-minisql-sql-expressions-ml-1497725308"></a>
### countStar

```ml
countStar
```

Stores the count star associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L69)

<a id="field-field-minisql-sql-expressions-boundaggregate-distinct-distinct-src-minisql-sql-expressions-ml-2506396"></a>
### distinct

```ml
distinct
```

Indicates whether the distinct condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L65)

<a id="field-field-minisql-sql-expressions-boundaggregate-kind-kind-src-minisql-sql-expressions-ml-686366972"></a>
### kind

```ml
kind
```

Stores the kind associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L57)

<a id="field-field-minisql-sql-expressions-boundaggregate-name-name-src-minisql-sql-expressions-ml-1065485346"></a>
### name

```ml
name
```

Stores the name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L59)

<a id="field-field-minisql-sql-expressions-boundaggregate-separator-separator-src-minisql-sql-expressions-ml-1924660692"></a>
### separator

```ml
separator
```

Stores the optional delimiter or secondary aggregate argument.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L63)

<a id="field-field-minisql-sql-expressions-boundaggregate-typeinfo-typeinfo-src-minisql-sql-expressions-ml-158710628"></a>
### typeInfo

```ml
typeInfo
```

Stores the type info associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L67)
