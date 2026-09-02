# `minisql.admin.fullclient.SqlSyntaxAccumulator`

[Home](README.md) · [Source file](File-src-minisql-admin-fullclient-ml-1896932593.md)

<a id="struct-struct-minisql-admin-fullclient-sqlsyntaxaccumulator-struct-sqlsyntaxaccumulator-src-minisql-admin-fullclient-ml-874311617"></a>
## SqlSyntaxAccumulator

```ml
struct SqlSyntaxAccumulator
```

Owns the mutable head/tail state used to avoid quadratic array appends.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L151)

## Members

<a id="field-field-minisql-admin-fullclient-sqlsyntaxaccumulator-count-count-src-minisql-admin-fullclient-ml-449063892"></a>
### count

```ml
count
```

Counts nodes for one exactly sized result allocation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L157)

<a id="field-field-minisql-admin-fullclient-sqlsyntaxaccumulator-first-first-src-minisql-admin-fullclient-ml-993870472"></a>
### first

```ml
first
```

Points to the first collected span node.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L153)

<a id="field-field-minisql-admin-fullclient-sqlsyntaxaccumulator-last-last-src-minisql-admin-fullclient-ml-1866906856"></a>
### last

```ml
last
```

Points to the final collected span node.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/admin/fullclient.ml#L155)
