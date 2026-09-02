# `minisql.sql.types.SqlTypeKind`

[Home](README.md) · [Source file](File-src-minisql-sql-types-ml-1842329761.md)

<a id="enum-enum-minisql-sql-types-sqltypekind-enum-sqltypekind-src-minisql-sql-types-ml-1119007031"></a>
## SqlTypeKind

```ml
enum SqlTypeKind
```

Type codes intentionally match storage.row_codec so catalog metadata can be turned into row schemas without a translation table. Enumerates the supported SQL type kind variants used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L16)

## Members

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-bigint-bigint-4-src-minisql-sql-types-ml-1199120205"></a>
### BigInt

```ml
BigInt = 4
```

Represents the big int variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L26)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-binary-binary-11-src-minisql-sql-types-ml-1665854833"></a>
### Binary

```ml
Binary = 11
```

Represents the binary variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L40)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-blob-blob-13-src-minisql-sql-types-ml-373813711"></a>
### Blob

```ml
Blob = 13
```

Represents the blob variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L44)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-boolean-boolean-1-src-minisql-sql-types-ml-677567410"></a>
### Boolean

```ml
Boolean = 1
```

Represents the boolean variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L20)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-char-char-8-src-minisql-sql-types-ml-1447161947"></a>
### Char

```ml
Char = 8
```

Represents the char variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L34)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-date-date-14-src-minisql-sql-types-ml-29555946"></a>
### Date

```ml
Date = 14
```

Represents the date variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L46)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-decimal-decimal-7-src-minisql-sql-types-ml-2026949964"></a>
### Decimal

```ml
Decimal = 7
```

Represents the decimal variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L32)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-double-double-6-src-minisql-sql-types-ml-1986804459"></a>
### Double

```ml
Double = 6
```

Represents the double variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L30)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-integer-integer-3-src-minisql-sql-types-ml-451337580"></a>
### Integer

```ml
Integer = 3
```

Represents the integer variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L24)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-real-real-5-src-minisql-sql-types-ml-1635177110"></a>
### Real

```ml
Real = 5
```

Represents the real variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L28)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-smallint-smallint-2-src-minisql-sql-types-ml-1957522109"></a>
### SmallInt

```ml
SmallInt = 2
```

Represents the small int variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L22)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-text-text-10-src-minisql-sql-types-ml-1771229248"></a>
### Text

```ml
Text = 10
```

Represents the text variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L38)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-time-time-15-src-minisql-sql-types-ml-544840249"></a>
### Time

```ml
Time = 15
```

Represents the time variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L48)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-timestamp-timestamp-16-src-minisql-sql-types-ml-139121636"></a>
### Timestamp

```ml
Timestamp = 16
```

Represents the timestamp variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L50)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-unknown-unknown-0-src-minisql-sql-types-ml-443485623"></a>
### Unknown

```ml
Unknown = 0
```

Represents the unknown variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L18)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-varbinary-varbinary-12-src-minisql-sql-types-ml-1746062712"></a>
### VarBinary

```ml
VarBinary = 12
```

Represents the var binary variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L42)

<a id="enum_variant-enum-variant-minisql-sql-types-sqltypekind-varchar-varchar-9-src-minisql-sql-types-ml-1567585750"></a>
### VarChar

```ml
VarChar = 9
```

Represents the var char variant.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/types.ml#L36)
