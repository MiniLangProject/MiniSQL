# `minisql.catalog.statistics.TableStatistics`

[Home](README.md) · [Source file](File-src-minisql-catalog-statistics-ml-1707584758.md)

<a id="struct-struct-minisql-catalog-statistics-tablestatistics-struct-tablestatistics-src-minisql-catalog-statistics-ml-1871156117"></a>
## TableStatistics

```ml
struct TableStatistics
```

Defines the table statistics record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L105)

## Members

<a id="field-field-minisql-catalog-statistics-tablestatistics-columngroups-columngroups-src-minisql-catalog-statistics-ml-142856744"></a>
### columnGroups

```ml
columnGroups
```

Joint statistics for bounded-width composite index keys.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L117)

<a id="field-field-minisql-catalog-statistics-tablestatistics-columns-columns-src-minisql-catalog-statistics-ml-2041183284"></a>
### columns

```ml
columns
```

Columns field of the table statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L115)

<a id="field-field-minisql-catalog-statistics-tablestatistics-pagecount-pagecount-src-minisql-catalog-statistics-ml-1998009072"></a>
### pageCount

```ml
pageCount
```

Page count field of the table statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L111)

<a id="field-field-minisql-catalog-statistics-tablestatistics-rowcount-rowcount-src-minisql-catalog-statistics-ml-1127900794"></a>
### rowCount

```ml
rowCount
```

Row count field of the table statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L109)

<a id="field-field-minisql-catalog-statistics-tablestatistics-samplecount-samplecount-src-minisql-catalog-statistics-ml-1688122768"></a>
### sampleCount

```ml
sampleCount
```

Number of decoded rows contributing column distribution statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L113)

<a id="field-field-minisql-catalog-statistics-tablestatistics-tableid-tableid-src-minisql-catalog-statistics-ml-647627036"></a>
### tableId

```ml
tableId
```

Table id field of the table statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L107)
