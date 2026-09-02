# `minisql.transaction.recovery.RecoveryResult`

[Home](README.md) · [Source file](File-src-minisql-transaction-recovery-ml-1551350049.md)

<a id="struct-struct-minisql-transaction-recovery-recoveryresult-struct-recoveryresult-src-minisql-transaction-recovery-ml-1462652561"></a>
## RecoveryResult

```ml
struct RecoveryResult
```

Defines the recovery result record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L43)

## Members

<a id="field-field-minisql-transaction-recovery-recoveryresult-committedtransactions-committedtransactions-src-minisql-transaction-recovery-ml-1821638225"></a>
### committedTransactions

```ml
committedTransactions
```

Committed transactions field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L47)

<a id="field-field-minisql-transaction-recovery-recoveryresult-pagesredone-pagesredone-src-minisql-transaction-recovery-ml-589933041"></a>
### pagesRedone

```ml
pagesRedone
```

Pages redone field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L49)

<a id="field-field-minisql-transaction-recovery-recoveryresult-pagesskipped-pagesskipped-src-minisql-transaction-recovery-ml-383491077"></a>
### pagesSkipped

```ml
pagesSkipped
```

Pages skipped field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L51)

<a id="field-field-minisql-transaction-recovery-recoveryresult-scannedrecords-scannedrecords-src-minisql-transaction-recovery-ml-1235181741"></a>
### scannedRecords

```ml
scannedRecords
```

Scanned records field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L45)

<a id="field-field-minisql-transaction-recovery-recoveryresult-truncatedtail-truncatedtail-src-minisql-transaction-recovery-ml-488111177"></a>
### truncatedTail

```ml
truncatedTail
```

Truncated tail field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L55)

<a id="field-field-minisql-transaction-recovery-recoveryresult-validwalbytes-validwalbytes-src-minisql-transaction-recovery-ml-787032329"></a>
### validWalBytes

```ml
validWalBytes
```

Valid wal bytes field of the recovery result.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L53)
