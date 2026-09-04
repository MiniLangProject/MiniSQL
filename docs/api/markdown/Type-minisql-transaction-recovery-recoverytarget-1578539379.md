# `minisql.transaction.recovery.RecoveryTarget`

[Home](README.md) · [Source file](File-src-minisql-transaction-recovery-ml-1551350049.md)

<a id="struct-struct-minisql-transaction-recovery-recoverytarget-struct-recoverytarget-src-minisql-transaction-recovery-ml-1844748405"></a>
## RecoveryTarget

```ml
struct RecoveryTarget
```

Defines the recovery target record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L22)

## Members

<a id="field-field-minisql-transaction-recovery-recoverytarget-fileid-fileid-src-minisql-transaction-recovery-ml-902666579"></a>
### fileId

```ml
fileId
```

File id field of the recovery target.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L24)

<a id="field-field-minisql-transaction-recovery-recoverytarget-pagedfile-pagedfile-src-minisql-transaction-recovery-ml-1803173749"></a>
### pagedFile

```ml
pagedFile
```

Open paged file that receives redo, or void for a deliberately retired file ID.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L26)

<a id="field-field-minisql-transaction-recovery-recoverytarget-retired-retired-src-minisql-transaction-recovery-ml-127667469"></a>
### retired

```ml
retired
```

Distinguishes a dropped file from an accidentally omitted live recovery target.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L28)
