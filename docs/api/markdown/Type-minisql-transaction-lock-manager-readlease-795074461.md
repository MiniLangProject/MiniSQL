# `minisql.transaction.lock_manager.ReadLease`

[Home](README.md) · [Source file](File-src-minisql-transaction-lock-manager-ml-829760585.md)

<a id="struct-struct-minisql-transaction-lock-manager-readlease-struct-readlease-src-minisql-transaction-lock-manager-ml-1699837507"></a>
## ReadLease

```ml
struct ReadLease
```

Defines the read lease record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L42)

## Members

<a id="field-field-minisql-transaction-lock-manager-readlease-active-active-src-minisql-transaction-lock-manager-ml-491173447"></a>
### active

```ml
active
```

Active field of the read lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L50)

<a id="field-field-minisql-transaction-lock-manager-readlease-isolationlevel-isolationlevel-src-minisql-transaction-lock-manager-ml-954070835"></a>
### isolationLevel

```ml
isolationLevel
```

Isolation level field of the read lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L46)

<a id="field-field-minisql-transaction-lock-manager-readlease-releaseonfinish-releaseonfinish-src-minisql-transaction-lock-manager-ml-260965827"></a>
### releaseOnFinish

```ml
releaseOnFinish
```

Release on finish field of the read lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L48)

<a id="field-field-minisql-transaction-lock-manager-readlease-transactionid-transactionid-src-minisql-transaction-lock-manager-ml-1326064495"></a>
### transactionId

```ml
transactionId
```

Transaction id field of the read lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L44)
