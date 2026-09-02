# `minisql.client.console.SqlBatch`

[Home](README.md) · [Source file](File-src-minisql-client-console-ml-931665780.md)

<a id="struct-struct-minisql-client-console-sqlbatch-struct-sqlbatch-src-minisql-client-console-ml-780005243"></a>
## SqlBatch

```ml
struct SqlBatch
```

Splits complete SQL statements from an unfinished interactive input suffix.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L27)

## Members

<a id="field-field-minisql-client-console-sqlbatch-remainder-remainder-src-minisql-client-console-ml-601392701"></a>
### remainder

```ml
remainder
```

Trailing text that does not yet form a complete statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L31)

<a id="field-field-minisql-client-console-sqlbatch-statements-statements-src-minisql-client-console-ml-359112645"></a>
### statements

```ml
statements
```

Complete statements, in source order and without their delimiters.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/client/console.ml#L29)
