# `minisql.transaction.transaction.Transaction`

[Home](README.md) · [Source file](File-src-minisql-transaction-transaction-ml-1157597470.md)

<a id="struct-struct-minisql-transaction-transaction-transaction-struct-transaction-src-minisql-transaction-transaction-ml-1554831533"></a>
## Transaction

```ml
struct Transaction
```

Defines the transaction record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L42)

## Members

<a id="field-field-minisql-transaction-transaction-transaction-beginlogged-beginlogged-src-minisql-transaction-transaction-ml-1953432251"></a>
### beginLogged

```ml
beginLogged
```

Begin logged field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L58)

<a id="field-field-minisql-transaction-transaction-transaction-beginlsn-beginlsn-src-minisql-transaction-transaction-ml-842112043"></a>
### beginLsn

```ml
beginLsn
```

Begin lsn field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L52)

<a id="field-field-minisql-transaction-transaction-transaction-changeindexes-changeindexes-src-minisql-transaction-transaction-ml-30764775"></a>
### changeIndexes

```ml
changeIndexes
```

Maps a stable file/page key to its position in the growable change list.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L62)

<a id="field-field-minisql-transaction-transaction-transaction-changes-changes-src-minisql-transaction-transaction-ml-1303050535"></a>
### changes

```ml
changes
```

Changes field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L60)

<a id="field-field-minisql-transaction-transaction-transaction-commitlsn-commitlsn-src-minisql-transaction-transaction-ml-1274427451"></a>
### commitLsn

```ml
commitLsn
```

Commit lsn field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L54)

<a id="field-field-minisql-transaction-transaction-transaction-committedchanges-committedchanges-src-minisql-transaction-transaction-ml-1901149677"></a>
### committedChanges

```ml
committedChanges
```

Committed changes field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L64)

<a id="field-field-minisql-transaction-transaction-transaction-isolationlevel-isolationlevel-src-minisql-transaction-transaction-ml-817478331"></a>
### isolationLevel

```ml
isolationLevel
```

Isolation level field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L48)

<a id="field-field-minisql-transaction-transaction-transaction-readonly-readonly-src-minisql-transaction-transaction-ml-1014254483"></a>
### readOnly

```ml
readOnly
```

Read only field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L50)

<a id="field-field-minisql-transaction-transaction-transaction-savepoints-savepoints-src-minisql-transaction-transaction-ml-1608136307"></a>
### savepoints

```ml
savepoints
```

Savepoints field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L66)

<a id="field-field-minisql-transaction-transaction-transaction-state-state-src-minisql-transaction-transaction-ml-238013711"></a>
### state

```ml
state
```

State field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L46)

<a id="field-field-minisql-transaction-transaction-transaction-transactionid-transactionid-src-minisql-transaction-transaction-ml-1323728247"></a>
### transactionId

```ml
transactionId
```

Transaction id field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L44)

<a id="field-field-minisql-transaction-transaction-transaction-walwriter-walwriter-src-minisql-transaction-transaction-ml-400493571"></a>
### walWriter

```ml
walWriter
```

Wal writer field of the transaction.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L56)
