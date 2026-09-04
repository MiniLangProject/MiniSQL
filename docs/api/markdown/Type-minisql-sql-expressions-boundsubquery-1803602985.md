# `minisql.sql.expressions.BoundSubquery`

[Home](README.md) · [Source file](File-src-minisql-sql-expressions-ml-980820199.md)

<a id="struct-struct-minisql-sql-expressions-boundsubquery-struct-boundsubquery-src-minisql-sql-expressions-ml-2041668559"></a>
## BoundSubquery

```ml
struct BoundSubquery
```

Carries a SELECT that must be evaluated against the current outer row. The binder records its SQL result type while the executor substitutes qualified outer references immediately before running the nested query.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L185)

## Members

<a id="field-field-minisql-sql-expressions-boundsubquery-negated-negated-src-minisql-sql-expressions-ml-1543113093"></a>
### negated

```ml
negated
```

Indicates whether an IN result is negated.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L193)

<a id="field-field-minisql-sql-expressions-boundsubquery-operand-operand-src-minisql-sql-expressions-ml-83531385"></a>
### operand

```ml
operand
```

Stores the bound left operand for IN, or void for scalar and EXISTS forms.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L191)

<a id="field-field-minisql-sql-expressions-boundsubquery-query-query-src-minisql-sql-expressions-ml-760003633"></a>
### query

```ml
query
```

Retains the parsed nested SELECT until an outer row is available.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L189)

<a id="field-field-minisql-sql-expressions-boundsubquery-subquerykind-subquerykind-src-minisql-sql-expressions-ml-321200845"></a>
### subqueryKind

```ml
subqueryKind
```

Identifies scalar, EXISTS, or IN result semantics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L187)

<a id="field-field-minisql-sql-expressions-boundsubquery-typeinfo-typeinfo-src-minisql-sql-expressions-ml-188898661"></a>
### typeInfo

```ml
typeInfo
```

Stores the statically inferred SQL result type.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/expressions.ml#L195)
