# `minisql.transaction.lock_manager.LockManager`

[Home](README.md) · [Source file](File-src-minisql-transaction-lock-manager-ml-829760585.md)

<a id="struct-struct-minisql-transaction-lock-manager-lockmanager-struct-lockmanager-src-minisql-transaction-lock-manager-ml-248888927"></a>
## LockManager

```ml
struct LockManager
```

Defines the lock manager record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L32)

## Members

<a id="field-field-minisql-transaction-lock-manager-lockmanager-activewriter-activewriter-src-minisql-transaction-lock-manager-ml-26798721"></a>
### activeWriter

```ml
activeWriter
```

Active writer field of the lock manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L36)

<a id="field-field-minisql-transaction-lock-manager-lockmanager-guard-guard-src-minisql-transaction-lock-manager-ml-1828618559"></a>
### guard

```ml
guard
```

Guard field of the lock manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L34)

<a id="field-field-minisql-transaction-lock-manager-lockmanager-readers-readers-src-minisql-transaction-lock-manager-ml-269409831"></a>
### readers

```ml
readers
```

Readers field of the lock manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L38)

<a id="field-field-minisql-transaction-lock-manager-lockmanager-waits-waits-src-minisql-transaction-lock-manager-ml-1402971995"></a>
### waits

```ml
waits
```

Waits field of the lock manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L40)
