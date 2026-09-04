# `minisql.catalog.statistics.ColumnStatistics`

[Home](README.md) · [Source file](File-src-minisql-catalog-statistics-ml-1707584758.md)

<a id="struct-struct-minisql-catalog-statistics-columnstatistics-struct-columnstatistics-src-minisql-catalog-statistics-ml-1752263141"></a>
## ColumnStatistics

```ml
struct ColumnStatistics
```

Defines the column statistics record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L63)

## Members

<a id="field-field-minisql-catalog-statistics-columnstatistics-averagewidth-averagewidth-src-minisql-catalog-statistics-ml-437257476"></a>
### averageWidth

```ml
averageWidth
```

Average width field of the column statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L71)

<a id="field-field-minisql-catalog-statistics-columnstatistics-columnindex-columnindex-src-minisql-catalog-statistics-ml-654504354"></a>
### columnIndex

```ml
columnIndex
```

Column index field of the column statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L65)

<a id="field-field-minisql-catalog-statistics-columnstatistics-distinctcount-distinctcount-src-minisql-catalog-statistics-ml-883025506"></a>
### distinctCount

```ml
distinctCount
```

Distinct count field of the column statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L69)

<a id="field-field-minisql-catalog-statistics-columnstatistics-hasintegralbounds-hasintegralbounds-src-minisql-catalog-statistics-ml-1007167178"></a>
### hasIntegralBounds

```ml
hasIntegralBounds
```

True when the sample supplied a comparable signed 32-bit minimum/maximum.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L73)

<a id="field-field-minisql-catalog-statistics-columnstatistics-histogrambounds-histogrambounds-src-minisql-catalog-statistics-ml-1499660934"></a>
### histogramBounds

```ml
histogramBounds
```

Inclusive upper bound of each equi-width integral histogram bucket.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L79)

<a id="field-field-minisql-catalog-statistics-columnstatistics-histogramcounts-histogramcounts-src-minisql-catalog-statistics-ml-1953147578"></a>
### histogramCounts

```ml
histogramCounts
```

Estimated cumulative non-NULL population at each histogram bound.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L81)

<a id="field-field-minisql-catalog-statistics-columnstatistics-maximumintegral-maximumintegral-src-minisql-catalog-statistics-ml-1510383282"></a>
### maximumIntegral

```ml
maximumIntegral
```

Largest sampled SMALLINT, INTEGER, or DATE representation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L77)

<a id="field-field-minisql-catalog-statistics-columnstatistics-minimumintegral-minimumintegral-src-minisql-catalog-statistics-ml-1841595970"></a>
### minimumIntegral

```ml
minimumIntegral
```

Smallest sampled SMALLINT, INTEGER, or DATE representation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L75)

<a id="field-field-minisql-catalog-statistics-columnstatistics-mostcommoncounts-mostcommoncounts-src-minisql-catalog-statistics-ml-1191272302"></a>
### mostCommonCounts

```ml
mostCommonCounts
```

Estimated table-population frequency paired with mostCommonValues.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L85)

<a id="field-field-minisql-catalog-statistics-columnstatistics-mostcommonhashed-mostcommonhashed-src-minisql-catalog-statistics-ml-1620607532"></a>
### mostCommonHashed

```ml
mostCommonHashed
```

True when mostCommonValues contains stable value hashes rather than values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L87)

<a id="field-field-minisql-catalog-statistics-columnstatistics-mostcommonvalues-mostcommonvalues-src-minisql-catalog-statistics-ml-625710242"></a>
### mostCommonValues

```ml
mostCommonValues
```

Most frequent sampled integral values, ordered by descending frequency.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L83)

<a id="field-field-minisql-catalog-statistics-columnstatistics-nullcount-nullcount-src-minisql-catalog-statistics-ml-865082746"></a>
### nullCount

```ml
nullCount
```

Null count field of the column statistics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/statistics.ml#L67)
