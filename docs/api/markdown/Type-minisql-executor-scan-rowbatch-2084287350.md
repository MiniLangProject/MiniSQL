# `minisql.executor.scan.RowBatch`

[Home](README.md) · [Source file](File-src-minisql-executor-scan-ml-657274302.md)

<a id="struct-struct-minisql-executor-scan-rowbatch-struct-rowbatch-src-minisql-executor-scan-ml-798274785"></a>
## RowBatch

```ml
struct RowBatch
```

Bounded group of rows transferred between streaming physical operators. The batch itself owns no storage handles; rows remain ordinary ScannedRow values and may safely outlive the cursor.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L108)

## Members

<a id="field-field-minisql-executor-scan-rowbatch-rows-rows-src-minisql-executor-scan-ml-1018190463"></a>
### rows

```ml
rows
```

Ordered rows contained in this bounded transfer unit.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/scan.ml#L110)
