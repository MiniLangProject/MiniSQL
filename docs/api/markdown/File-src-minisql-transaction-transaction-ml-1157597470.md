# `src/minisql/transaction/transaction.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql transaction transaction facilities for this project.

Package: [`minisql.transaction.transaction`](Package-minisql-transaction-transaction-1977973526.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-transaction-transaction-acknowledgecommittedpages-function-acknowledgecommittedpages-transaction-src-minisql-transaction-transaction-ml-296997574"></a>
### acknowledgeCommittedPages

```ml
function acknowledgeCommittedPages(transaction)
```

Performs the acknowledge committed pages operation for this module. Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L454)

<a id="function-function-minisql-transaction-transaction-beginmanaged-function-beginmanaged-manager-isolationlevel-readonly-walwriter-src-minisql-transaction-transaction-ml-1035256460"></a>
### beginManaged

```ml
function beginManaged(manager, isolationLevel, readOnly, walWriter)
```

Begins the managed. Inputs: `manager`, `isolationLevel`, `readOnly`, `walWriter`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `isolationLevel` | `dynamic` | — | isolationLevel value consumed by this operation. |
| `readOnly` | `dynamic` | — | readOnly value consumed by this operation. |
| `walWriter` | `dynamic` | — | walWriter value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L182)

<a id="function-function-minisql-transaction-transaction-begintransaction-function-begintransaction-transactionid-isolationlevel-readonly-walwriter-src-minisql-transaction-transaction-ml-1486551942"></a>
### beginTransaction

```ml
function beginTransaction(transactionId, isolationLevel, readOnly, walWriter)
```

Begins the transaction. Inputs: `transactionId`, `isolationLevel`, `readOnly`, `walWriter`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `isolationLevel` | `dynamic` | — | isolationLevel value consumed by this operation. |
| `readOnly` | `dynamic` | — | readOnly value consumed by this operation. |
| `walWriter` | `dynamic` | — | walWriter value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L147)

<a id="function-function-minisql-transaction-transaction-changekey-function-changekey-fileid-pagenumber-src-minisql-transaction-transaction-ml-1790875933"></a>
### changeKey

```ml
function changeKey(fileId, pageNumber)
```

Builds the collision-free textual key used by the transaction's change index. File and page identifiers are non-negative decimal integers, so the separator makes every pair unambiguous without imposing an artificial numeric limit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L195)

<a id="function-function-minisql-transaction-transaction-clonechanges-function-clonechanges-changes-src-minisql-transaction-transaction-ml-1630004031"></a>
### cloneChanges

```ml
function cloneChanges(changes)
```

Clones the changes. Inputs: `changes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `changes` | `dynamic` | — | changes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L279)

<a id="function-function-minisql-transaction-transaction-commit-function-commit-transaction-src-minisql-transaction-transaction-ml-2084756502"></a>
### commit

```ml
function commit(transaction)
```

Commits the requested value. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L394)

<a id="function-function-minisql-transaction-transaction-committedpagecount-function-committedpagecount-transaction-src-minisql-transaction-transaction-ml-1944806762"></a>
### committedPageCount

```ml
function committedPageCount(transaction)
```

Commits the ted page count. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L419)

<a id="function-function-minisql-transaction-transaction-committedpages-function-committedpages-transaction-src-minisql-transaction-transaction-ml-1760082758"></a>
### committedPages

```ml
function committedPages(transaction)
```

Commits the ted pages. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L427)

<a id="function-function-minisql-transaction-transaction-committedpagesforpublication-function-committedpagesforpublication-transaction-src-minisql-transaction-transaction-ml-4525754"></a>
### committedPagesForPublication

```ml
function committedPagesForPublication(transaction)
```

Returns a shallow publication view of the immutable committed page batch. Only the storage publisher may use this helper; unlike committedPages(), its page buffers are intentionally not cloned so publishing a large transaction does not temporarily duplicate every full-page image in the MiniLang heap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L445)

<a id="function-function-minisql-transaction-transaction-componentname-function-componentname-src-minisql-transaction-transaction-ml-2099182218"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql transaction transaction module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L493)

<a id="function-function-minisql-transaction-transaction-createmanager-function-createmanager-firsttransactionid-src-minisql-transaction-transaction-ml-74756771"></a>
### createManager

```ml
function createManager(firstTransactionId)
```

Creates the manager. Inputs: `firstTransactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `firstTransactionId` | `dynamic` | — | Identifier of first transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L171)

<a id="function-function-minisql-transaction-transaction-fail-function-fail-code-operation-message-src-minisql-transaction-transaction-ml-184503011"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql transaction transaction module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L100)

<a id="function-function-minisql-transaction-transaction-failcommit-function-failcommit-transaction-startlsn-failure-src-minisql-transaction-transaction-ml-533182667"></a>
### failCommit

```ml
function failCommit(transaction, startLsn, failure)
```

Performs the fail commit operation for this module. Inputs: `transaction`, `startLsn`, `failure`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |
| `failure` | `dynamic` | — | failure value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L378)

<a id="function-function-minisql-transaction-transaction-findchange-function-findchange-transaction-fileid-pagenumber-src-minisql-transaction-transaction-ml-992232199"></a>
### findChange

```ml
function findChange(transaction, fileId, pageNumber)
```

Finds a staged page in expected constant time through the private hash index. Inputs: `transaction`, `fileId`, `pageNumber`. Returns its list index or `-1`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L204)

<a id="function-function-minisql-transaction-transaction-findsavepoint-function-findsavepoint-transaction-name-src-minisql-transaction-transaction-ml-766501281"></a>
### findSavepoint

```ml
function findSavepoint(transaction, name)
```

Finds the savepoint. Inputs: `transaction`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L314)

<a id="function-function-minisql-transaction-transaction-indexchanges-function-indexchanges-changes-src-minisql-transaction-transaction-ml-1579270851"></a>
### indexChanges

```ml
function indexChanges(changes)
```

Rebuilds the change index after restoring an array-backed savepoint snapshot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `changes` | `dynamic` | — | changes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L212)

<a id="constant-constant-minisql-transaction-transaction-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-transaction-ml-2137495961"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Transaction state machine and page-level change tracking. Write-ahead-log


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L16)

<a id="function-function-minisql-transaction-transaction-isimplemented-function-isimplemented-src-minisql-transaction-transaction-ml-1383163858"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql transaction transaction module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L505)

<a id="constant-constant-minisql-transaction-transaction-isolation-read-committed-const-isolation-read-committed-1-src-minisql-transaction-transaction-ml-1096910848"></a>
### ISOLATION_READ_COMMITTED

```ml
const ISOLATION_READ_COMMITTED = 1
```

Defines the isolation read committed constant used by the minisql transaction transaction module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L23)

<a id="constant-constant-minisql-transaction-transaction-isolation-serializable-const-isolation-serializable-2-src-minisql-transaction-transaction-ml-2143391891"></a>
### ISOLATION_SERIALIZABLE

```ml
const ISOLATION_SERIALIZABLE = 2
```

Defines the isolation serializable constant used by the minisql transaction transaction module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L25)

<a id="function-function-minisql-transaction-transaction-markfailed-function-markfailed-transaction-src-minisql-transaction-transaction-ml-1010363590"></a>
### markFailed

```ml
function markFailed(transaction)
```

Marks the failed. Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L270)

- [minisql.transaction.transaction.PageChange](Type-minisql-transaction-transaction-pagechange-1020587671.md) — struct
<a id="constant-constant-minisql-transaction-transaction-read-only-violation-const-read-only-violation-9012-src-minisql-transaction-transaction-ml-103406661"></a>
### READ_ONLY_VIOLATION

```ml
const READ_ONLY_VIOLATION = 9012
```

Defines the read only violation constant used by the minisql transaction transaction module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L20)

<a id="function-function-minisql-transaction-transaction-readprivatepage-function-readprivatepage-transaction-fileid-pagenumber-src-minisql-transaction-transaction-ml-2051059795"></a>
### readPrivatePage

```ml
function readPrivatePage(transaction, fileId, pageNumber)
```

Reads the private page. Inputs: `transaction`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L260)

<a id="function-function-minisql-transaction-transaction-releasesavepoint-function-releasesavepoint-transaction-name-src-minisql-transaction-transaction-ml-142228977"></a>
### releaseSavepoint

```ml
function releaseSavepoint(transaction, name)
```

Releases the savepoint. Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L350)

<a id="function-function-minisql-transaction-transaction-requireactive-function-requireactive-transaction-operation-src-minisql-transaction-transaction-ml-1212622613"></a>
### requireActive

```ml
function requireActive(transaction, operation)
```

Performs the require active operation for this module. Inputs: `transaction`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L135)

<a id="function-function-minisql-transaction-transaction-rollback-function-rollback-transaction-src-minisql-transaction-transaction-ml-1207322838"></a>
### rollback

```ml
function rollback(transaction)
```

Rolls back the requested value. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L476)

<a id="function-function-minisql-transaction-transaction-rollbacktosavepoint-function-rollbacktosavepoint-transaction-name-src-minisql-transaction-transaction-ml-1737077633"></a>
### rollbackToSavepoint

```ml
function rollbackToSavepoint(transaction, name)
```

Rolls back the to savepoint. Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L328)

<a id="function-function-minisql-transaction-transaction-savepoint-function-savepoint-transaction-name-src-minisql-transaction-transaction-ml-525556295"></a>
### savepoint

```ml
function savepoint(transaction, name)
```

Persists the point. Inputs: `transaction`, `name`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L303)

- [minisql.transaction.transaction.Savepoint](Type-minisql-transaction-transaction-savepoint-249077873.md) — struct
<a id="function-function-minisql-transaction-transaction-savepointcount-function-savepointcount-transaction-src-minisql-transaction-transaction-ml-1013268222"></a>
### savepointCount

```ml
function savepointCount(transaction)
```

Persists the point count. Inputs: `transaction`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L368)

<a id="function-function-minisql-transaction-transaction-stagedpagecount-function-stagedpagecount-transaction-src-minisql-transaction-transaction-ml-1250744830"></a>
### stagedPageCount

```ml
function stagedPageCount(transaction)
```

Performs the staged page count operation for this module. Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L250)

<a id="function-function-minisql-transaction-transaction-stagepage-function-stagepage-transaction-fileid-pagenumber-pagebytes-src-minisql-transaction-transaction-ml-384517141"></a>
### stagePage

```ml
function stagePage(transaction, fileId, pageNumber, pageBytes)
```

Performs the stage page operation for this module. Inputs: `transaction`, `fileId`, `pageNumber`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L229)

<a id="function-function-minisql-transaction-transaction-takecommittedpages-function-takecommittedpages-transaction-src-minisql-transaction-transaction-ml-1896123862"></a>
### takeCommittedPages

```ml
function takeCommittedPages(transaction)
```

Performs the take committed pages operation for this module. Inputs: `transaction`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L464)

<a id="function-function-minisql-transaction-transaction-targetmilestone-function-targetmilestone-src-minisql-transaction-transaction-ml-1783705680"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql transaction transaction module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L499)

- [minisql.transaction.transaction.Transaction](Type-minisql-transaction-transaction-transaction-1554971120.md) — struct
<a id="constant-constant-minisql-transaction-transaction-transaction-state-const-transaction-state-9011-src-minisql-transaction-transaction-ml-1701432970"></a>
### TRANSACTION_STATE

```ml
const TRANSACTION_STATE = 9011
```

Defines the transaction state constant used by the minisql transaction transaction module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L18)

- [minisql.transaction.transaction.TransactionManager](Type-minisql-transaction-transaction-transactionmanager-1642601039.md) — struct
- [minisql.transaction.transaction.TransactionState](Type-minisql-transaction-transaction-transactionstate-1323137189.md) — enum
<a id="function-function-minisql-transaction-transaction-validateid-function-validateid-value-operation-src-minisql-transaction-transaction-ml-1041796740"></a>
### validateId

```ml
function validateId(value, operation)
```

Validates the id. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L108)

<a id="function-function-minisql-transaction-transaction-validateisolation-function-validateisolation-value-operation-src-minisql-transaction-transaction-ml-1882585004"></a>
### validateIsolation

```ml
function validateIsolation(value, operation)
```

Validates the isolation. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L117)

<a id="function-function-minisql-transaction-transaction-validatesavepointname-function-validatesavepointname-name-operation-src-minisql-transaction-transaction-ml-1210752318"></a>
### validateSavepointName

```ml
function validateSavepointName(name, operation)
```

Validates the savepoint name. Inputs: `name`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the affected item. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L294)

<a id="function-function-minisql-transaction-transaction-validatetransaction-function-validatetransaction-transaction-operation-src-minisql-transaction-transaction-ml-1119049431"></a>
### validateTransaction

```ml
function validateTransaction(transaction, operation)
```

Validates the transaction. Inputs: `transaction`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transaction` | `dynamic` | — | transaction value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/transaction.ml#L126)
