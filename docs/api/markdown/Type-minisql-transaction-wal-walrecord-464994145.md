# `minisql.transaction.wal.WalRecord`

[Home](README.md) · [Source file](File-src-minisql-transaction-wal-ml-860713478.md)

<a id="struct-struct-minisql-transaction-wal-walrecord-struct-walrecord-src-minisql-transaction-wal-ml-1584307863"></a>
## WalRecord

```ml
struct WalRecord
```

Defines the wal record record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L54)

## Members

<a id="field-field-minisql-transaction-wal-walrecord-encryptedpayload-encryptedpayload-src-minisql-transaction-wal-ml-711463148"></a>
### encryptedPayload

```ml
encryptedPayload
```

True only while the encoded payload contains nonce, ciphertext and tag. Decoders clear this implementation field before returning a logical record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L75)

<a id="field-field-minisql-transaction-wal-walrecord-fileid-fileid-src-minisql-transaction-wal-ml-828830874"></a>
### fileId

```ml
fileId
```

File id field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L66)

<a id="field-field-minisql-transaction-wal-walrecord-flags-flags-src-minisql-transaction-wal-ml-849208704"></a>
### flags

```ml
flags
```

Flags field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L58)

<a id="field-field-minisql-transaction-wal-walrecord-lsn-lsn-src-minisql-transaction-wal-ml-1480479828"></a>
### lsn

```ml
lsn
```

Lsn field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L60)

<a id="field-field-minisql-transaction-wal-walrecord-pagelsn-pagelsn-src-minisql-transaction-wal-ml-1362367932"></a>
### pageLsn

```ml
pageLsn
```

Page lsn field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L70)

<a id="field-field-minisql-transaction-wal-walrecord-pagenumber-pagenumber-src-minisql-transaction-wal-ml-1995091036"></a>
### pageNumber

```ml
pageNumber
```

Page number field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L68)

<a id="field-field-minisql-transaction-wal-walrecord-payload-payload-src-minisql-transaction-wal-ml-2001445416"></a>
### payload

```ml
payload
```

Payload field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L72)

<a id="field-field-minisql-transaction-wal-walrecord-recordtype-recordtype-src-minisql-transaction-wal-ml-1300630610"></a>
### recordType

```ml
recordType
```

Record type field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L56)

<a id="field-field-minisql-transaction-wal-walrecord-totallength-totallength-src-minisql-transaction-wal-ml-2132037592"></a>
### totalLength

```ml
totalLength
```

Total length field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L62)

<a id="field-field-minisql-transaction-wal-walrecord-transactionid-transactionid-src-minisql-transaction-wal-ml-1690138988"></a>
### transactionId

```ml
transactionId
```

Transaction id field of the wal record.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L64)
