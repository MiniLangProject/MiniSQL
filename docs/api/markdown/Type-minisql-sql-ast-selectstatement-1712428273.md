# `minisql.sql.ast.SelectStatement`

[Home](README.md) · [Source file](File-src-minisql-sql-ast-ml-1617141018.md)

<a id="struct-struct-minisql-sql-ast-selectstatement-struct-selectstatement-src-minisql-sql-ast-ml-68074971"></a>
## SelectStatement

```ml
struct SelectStatement
```

Groups the select statement state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L767)

## Members

<a id="field-field-minisql-sql-ast-selectstatement-ctes-ctes-src-minisql-sql-ast-ml-904951830"></a>
### ctes

```ml
ctes
```

Stores the ctes associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L793)

<a id="field-field-minisql-sql-ast-selectstatement-distinct-distinct-src-minisql-sql-ast-ml-1132310256"></a>
### distinct

```ml
distinct
```

Indicates whether the distinct condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L769)

<a id="field-field-minisql-sql-ast-selectstatement-groupby-groupby-src-minisql-sql-ast-ml-285701808"></a>
### groupBy

```ml
groupBy
```

Stores the group by associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L781)

<a id="field-field-minisql-sql-ast-selectstatement-havingexpression-havingexpression-src-minisql-sql-ast-ml-1555709162"></a>
### havingExpression

```ml
havingExpression
```

Stores the having expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L783)

<a id="field-field-minisql-sql-ast-selectstatement-items-items-src-minisql-sql-ast-ml-1526436700"></a>
### items

```ml
items
```

Tracks the items numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L771)

<a id="field-field-minisql-sql-ast-selectstatement-joins-joins-src-minisql-sql-ast-ml-1694666240"></a>
### joins

```ml
joins
```

Contains the ordered joins collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L777)

<a id="field-field-minisql-sql-ast-selectstatement-limit-limit-src-minisql-sql-ast-ml-619447220"></a>
### limit

```ml
limit
```

Tracks the limit numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L789)

<a id="field-field-minisql-sql-ast-selectstatement-offset-offset-src-minisql-sql-ast-ml-1901059442"></a>
### offset

```ml
offset
```

Tracks the offset numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L791)

<a id="field-field-minisql-sql-ast-selectstatement-orderby-orderby-src-minisql-sql-ast-ml-925151280"></a>
### orderBy

```ml
orderBy
```

Contains the ordered order by collection.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L787)

<a id="field-field-minisql-sql-ast-selectstatement-setoperations-setoperations-src-minisql-sql-ast-ml-310619312"></a>
### setOperations

```ml
setOperations
```

Stores the set operations associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L785)

<a id="field-field-minisql-sql-ast-selectstatement-tablealias-tablealias-src-minisql-sql-ast-ml-1019113920"></a>
### tableAlias

```ml
tableAlias
```

Stores the table alias associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L775)

<a id="field-field-minisql-sql-ast-selectstatement-tablename-tablename-src-minisql-sql-ast-ml-432128992"></a>
### tableName

```ml
tableName
```

Stores the table name associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L773)

<a id="field-field-minisql-sql-ast-selectstatement-whereexpression-whereexpression-src-minisql-sql-ast-ml-1656176104"></a>
### whereExpression

```ml
whereExpression
```

Stores the where expression associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/ast.ml#L779)
