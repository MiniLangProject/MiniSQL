# `minisql.catalog.statistics.ColumnGroupStatistics`

[Home](README.md) · [Source file](File-src-minisql-catalog-statistics-ml-1707584758.md)

<a id="struct-struct-minisql-catalog-statistics-columngroupstatistics-struct-columngroupstatistics-src-minisql-catalog-statistics-ml-1607068923"></a>
## ColumnGroupStatistics

```ml
struct ColumnGroupStatistics
```

Captures joint distinctness for columns that form a composite index key. These statistics prevent the optimizer from assuming that correlated key columns are independent when estimating complete equality probes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L93)

## Members

<a id="field-field-minisql-catalog-statistics-columngroupstatistics-columnindexes-columnindexes-src-minisql-catalog-statistics-ml-1162712521"></a>
### columnIndexes

```ml
columnIndexes
```

Ordered table-local column indexes in the analyzed key prefix.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L95)

<a id="field-field-minisql-catalog-statistics-columngroupstatistics-distinctcount-distinctcount-src-minisql-catalog-statistics-ml-924914609"></a>
### distinctCount

```ml
distinctCount
```

Estimated number of distinct non-NULL tuples in the table population.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L97)

<a id="field-field-minisql-catalog-statistics-columngroupstatistics-mostcommoncounts-mostcommoncounts-src-minisql-catalog-statistics-ml-1238053417"></a>
### mostCommonCounts

```ml
mostCommonCounts
```

Population-scaled frequencies paired with mostCommonHashes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L101)

<a id="field-field-minisql-catalog-statistics-columngroupstatistics-mostcommonhashes-mostcommonhashes-src-minisql-catalog-statistics-ml-1188344105"></a>
### mostCommonHashes

```ml
mostCommonHashes
```

Stable hashes for the most frequent complete tuples.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L99)
