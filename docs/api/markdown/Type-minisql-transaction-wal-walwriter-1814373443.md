# `minisql.transaction.wal.WalWriter`

[Home](README.md) · [Source file](File-src-minisql-transaction-wal-ml-860713478.md)

<a id="struct-struct-minisql-transaction-wal-walwriter-struct-walwriter-src-minisql-transaction-wal-ml-515060491"></a>
## WalWriter

```ml
struct WalWriter
```

Defines the wal writer record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L95)

## Members

<a id="field-field-minisql-transaction-wal-walwriter-closed-closed-src-minisql-transaction-wal-ml-467542022"></a>
### closed

```ml
closed
```

Closed field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L115)

<a id="field-field-minisql-transaction-wal-walwriter-encryptionkey-encryptionkey-src-minisql-transaction-wal-ml-1417692174"></a>
### encryptionKey

```ml
encryptionKey
```

Database TDE key, or void for a plaintext database.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L109)

<a id="field-field-minisql-transaction-wal-walwriter-failnextflush-failnextflush-src-minisql-transaction-wal-ml-599617762"></a>
### failNextFlush

```ml
failNextFlush
```

Fail next flush field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L113)

<a id="field-field-minisql-transaction-wal-walwriter-failnextwrite-failnextwrite-src-minisql-transaction-wal-ml-437440998"></a>
### failNextWrite

```ml
failNextWrite
```

Fail next write field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L111)

<a id="field-field-minisql-transaction-wal-walwriter-file-file-src-minisql-transaction-wal-ml-746721454"></a>
### file

```ml
file
```

File field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L99)

<a id="field-field-minisql-transaction-wal-walwriter-lastflushedlsn-lastflushedlsn-src-minisql-transaction-wal-ml-701690094"></a>
### lastFlushedLsn

```ml
lastFlushedLsn
```

Last flushed lsn field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L105)

<a id="field-field-minisql-transaction-wal-walwriter-nextlsn-nextlsn-src-minisql-transaction-wal-ml-947079014"></a>
### nextLsn

```ml
nextLsn
```

Next lsn field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L103)

<a id="field-field-minisql-transaction-wal-walwriter-path-path-src-minisql-transaction-wal-ml-1335834076"></a>
### path

```ml
path
```

Path field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L97)

<a id="field-field-minisql-transaction-wal-walwriter-recordcount-recordcount-src-minisql-transaction-wal-ml-119002258"></a>
### recordCount

```ml
recordCount
```

Record count field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L107)

<a id="field-field-minisql-transaction-wal-walwriter-segmentbytes-segmentbytes-src-minisql-transaction-wal-ml-1206048598"></a>
### segmentBytes

```ml
segmentBytes
```

Segment bytes field of the wal writer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L101)
