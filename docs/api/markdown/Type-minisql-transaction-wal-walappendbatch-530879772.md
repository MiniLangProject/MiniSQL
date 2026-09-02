# `minisql.transaction.wal.WalAppendBatch`

[Home](README.md) · [Source file](File-src-minisql-transaction-wal-ml-860713478.md)

<a id="struct-struct-minisql-transaction-wal-walappendbatch-struct-walappendbatch-src-minisql-transaction-wal-ml-365045519"></a>
## WalAppendBatch

```ml
struct WalAppendBatch
```

Holds one bounded WAL append buffer. `nextLsn` advances logically while the physical writer position is published only after the complete transaction batch has been appended successfully.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L121)

## Members

<a id="field-field-minisql-transaction-wal-walappendbatch-buffer-buffer-src-minisql-transaction-wal-ml-1647528743"></a>
### buffer

```ml
buffer
```

Contiguous encoded records awaiting one file write.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L125)

<a id="field-field-minisql-transaction-wal-walappendbatch-nextlsn-nextlsn-src-minisql-transaction-wal-ml-438606887"></a>
### nextLsn

```ml
nextLsn
```

Logical LSN assigned to the next record in this batch.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L129)

<a id="field-field-minisql-transaction-wal-walappendbatch-records-records-src-minisql-transaction-wal-ml-925941911"></a>
### records

```ml
records
```

Number of complete encoded records accumulated in the batch.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L131)

<a id="field-field-minisql-transaction-wal-walappendbatch-used-used-src-minisql-transaction-wal-ml-2089074525"></a>
### used

```ml
used
```

Number of populated bytes in the bounded append buffer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L127)

<a id="field-field-minisql-transaction-wal-walappendbatch-writer-writer-src-minisql-transaction-wal-ml-553117613"></a>
### writer

```ml
writer
```

WAL writer whose physical append position is published on commit.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L123)
