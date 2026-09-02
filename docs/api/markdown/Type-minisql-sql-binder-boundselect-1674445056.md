# `minisql.sql.binder.BoundSelect`

[Home](README.md) · [Source file](File-src-minisql-sql-binder-ml-1729118960.md)

<a id="struct-struct-minisql-sql-binder-boundselect-struct-boundselect-src-minisql-sql-binder-ml-957731563"></a>
## BoundSelect

```ml
struct BoundSelect
```

Groups the bound select state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L100)

## Members

<a id="field-field-minisql-sql-binder-boundselect-aggregatequery-aggregatequery-src-minisql-sql-binder-ml-798901137"></a>
### aggregateQuery

```ml
aggregateQuery
```

Stores the aggregate query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L124)

<a id="field-field-minisql-sql-binder-boundselect-groupexpressions-groupexpressions-src-minisql-sql-binder-ml-1963964283"></a>
### groupExpressions

```ml
groupExpressions
```

Stores the group expressions associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L116)

<a id="field-field-minisql-sql-binder-boundselect-havingexpression-havingexpression-src-minisql-sql-binder-ml-855502481"></a>
### havingExpression

```ml
havingExpression
```

Stores the having expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L118)

<a id="field-field-minisql-sql-binder-boundselect-itemnames-itemnames-src-minisql-sql-binder-ml-193855651"></a>
### itemNames

```ml
itemNames
```

Stores the item names associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L112)

<a id="field-field-minisql-sql-binder-boundselect-items-items-src-minisql-sql-binder-ml-1783186815"></a>
### items

```ml
items
```

Tracks the items numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L110)

<a id="field-field-minisql-sql-binder-boundselect-joins-joins-src-minisql-sql-binder-ml-1989381355"></a>
### joins

```ml
joins
```

Contains the ordered joins collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L108)

<a id="field-field-minisql-sql-binder-boundselect-orderexpressions-orderexpressions-src-minisql-sql-binder-ml-2070575713"></a>
### orderExpressions

```ml
orderExpressions
```

Contains the ordered order expressions collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L120)

<a id="field-field-minisql-sql-binder-boundselect-setoperations-setoperations-src-minisql-sql-binder-ml-2092721147"></a>
### setOperations

```ml
setOperations
```

Stores the set operations associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L122)

<a id="field-field-minisql-sql-binder-boundselect-sources-sources-src-minisql-sql-binder-ml-642209179"></a>
### sources

```ml
sources
```

Contains the ordered sources collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L106)

<a id="field-field-minisql-sql-binder-boundselect-statement-statement-src-minisql-sql-binder-ml-1662724127"></a>
### statement

```ml
statement
```

Stores the statement associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L102)

<a id="field-field-minisql-sql-binder-boundselect-table-table-src-minisql-sql-binder-ml-1894389959"></a>
### table

```ml
table
```

Stores the table associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L104)

<a id="field-field-minisql-sql-binder-boundselect-whereexpression-whereexpression-src-minisql-sql-binder-ml-855327115"></a>
### whereExpression

```ml
whereExpression
```

Stores the where expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L114)

<a id="field-field-minisql-sql-binder-boundselect-windowquery-windowquery-src-minisql-sql-binder-ml-1044454239"></a>
### windowQuery

```ml
windowQuery
```

Stores the window query associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/binder.ml#L126)
