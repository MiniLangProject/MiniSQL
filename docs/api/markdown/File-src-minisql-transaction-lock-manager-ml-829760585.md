# `src/minisql/transaction/lock_manager.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql transaction lock manager facilities for this project.

Package: [`minisql.transaction.lock_manager`](Package-minisql-transaction-lock-manager-541238173.md)

Reachable from entry: **yes**

## Imports

- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `std/threading.ml` as `threading` → `../MiniLangCompilerML/std/threading.ml` — external dependency

## Declarations

<a id="function-function-minisql-transaction-lock-manager-acquireread-function-acquireread-manager-transactionid-src-minisql-transaction-lock-manager-ml-1749195692"></a>
### acquireRead

```ml
function acquireRead(manager, transactionId)
```

Acquires the read. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L217)

<a id="function-function-minisql-transaction-lock-manager-acquirereadunlocked-function-acquirereadunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-1450459990"></a>
### acquireReadUnlocked

```ml
function acquireReadUnlocked(manager, transactionId)
```

Acquires the read unlocked. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L205)

<a id="function-function-minisql-transaction-lock-manager-acquirestatementread-function-acquirestatementread-manager-transactionid-isolationlevel-src-minisql-transaction-lock-manager-ml-204590674"></a>
### acquireStatementRead

```ml
function acquireStatementRead(manager, transactionId, isolationLevel)
```

Acquires the statement read. Inputs: `manager`, `transactionId`, `isolationLevel`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `isolationLevel` | `dynamic` | — | isolationLevel value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L366)

<a id="function-function-minisql-transaction-lock-manager-acquirewrite-function-acquirewrite-manager-transactionid-src-minisql-transaction-lock-manager-ml-1494741924"></a>
### acquireWrite

```ml
function acquireWrite(manager, transactionId)
```

Acquires the write. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L242)

<a id="function-function-minisql-transaction-lock-manager-acquirewriteunlocked-function-acquirewriteunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-431754348"></a>
### acquireWriteUnlocked

```ml
function acquireWriteUnlocked(manager, transactionId)
```

Acquires the write unlocked. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L230)

<a id="function-function-minisql-transaction-lock-manager-activewriter-function-activewriter-manager-src-minisql-transaction-lock-manager-ml-1977221495"></a>
### activeWriter

```ml
function activeWriter(manager)
```

Performs the active writer operation for this module. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L406)

<a id="function-function-minisql-transaction-lock-manager-cancelwait-function-cancelwait-manager-transactionid-src-minisql-transaction-lock-manager-ml-1776972756"></a>
### cancelWait

```ml
function cancelWait(manager, transactionId)
```

Removes the transaction's pending wait edges after cancellation or timeout. Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L255)

<a id="function-function-minisql-transaction-lock-manager-cleartransactionwaits-function-cleartransactionwaits-manager-transactionid-src-minisql-transaction-lock-manager-ml-1908216882"></a>
### clearTransactionWaits

```ml
function clearTransactionWaits(manager, transactionId)
```

Clears the transaction waits. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L124)

<a id="function-function-minisql-transaction-lock-manager-clearwaiter-function-clearwaiter-manager-transactionid-src-minisql-transaction-lock-manager-ml-2107465634"></a>
### clearWaiter

```ml
function clearWaiter(manager, transactionId)
```

Clears the waiter. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L111)

<a id="function-function-minisql-transaction-lock-manager-close-function-close-manager-src-minisql-transaction-lock-manager-ml-345488415"></a>
### close

```ml
function close(manager)
```

Closes close owned by the minisql transaction lock manager module. Inputs: `manager`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L417)

<a id="function-function-minisql-transaction-lock-manager-componentname-function-componentname-src-minisql-transaction-lock-manager-ml-41894428"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql transaction lock manager module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L429)

<a id="function-function-minisql-transaction-lock-manager-containsid-function-containsid-values-wanted-src-minisql-transaction-lock-manager-ml-1330442163"></a>
### containsId

```ml
function containsId(values, wanted)
```

Performs the contains id operation for this module. Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |
| `wanted` | `dynamic` | — | wanted value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L92)

<a id="function-function-minisql-transaction-lock-manager-containsreader-function-containsreader-manager-transactionid-src-minisql-transaction-lock-manager-ml-1839877356"></a>
### containsReader

```ml
function containsReader(manager, transactionId)
```

Performs the contains reader operation for this module. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L103)

<a id="function-function-minisql-transaction-lock-manager-create-function-create-src-minisql-transaction-lock-manager-ml-1032285464"></a>
### create

```ml
function create()
```

Creates create for the minisql transaction lock manager module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L66)

<a id="constant-constant-minisql-transaction-lock-manager-deadlock-detected-const-deadlock-detected-9031-src-minisql-transaction-lock-manager-ml-1601684258"></a>
### DEADLOCK_DETECTED

```ml
const DEADLOCK_DETECTED = 9031
```

Defines the deadlock detected constant used by the minisql transaction lock manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L17)

<a id="function-function-minisql-transaction-lock-manager-fail-function-fail-code-operation-message-src-minisql-transaction-lock-manager-ml-1389035727"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql transaction lock manager module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L60)

<a id="function-function-minisql-transaction-lock-manager-finishstatement-function-finishstatement-manager-lease-src-minisql-transaction-lock-manager-ml-860817441"></a>
### finishStatement

```ml
function finishStatement(manager, lease)
```

Performs the finish statement operation for this module. Inputs: `manager`, `lease`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `lease` | `dynamic` | — | lease value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L385)

<a id="function-function-minisql-transaction-lock-manager-finishtransaction-function-finishtransaction-manager-transactionid-src-minisql-transaction-lock-manager-ml-883466970"></a>
### finishTransaction

```ml
function finishTransaction(manager, transactionId)
```

Performs the finish transaction operation for this module. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L399)

<a id="constant-constant-minisql-transaction-lock-manager-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-lock-manager-ml-1734488969"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

In-process writer-prioritized reader/writer gate shared by connections using


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L13)

<a id="function-function-minisql-transaction-lock-manager-isimplemented-function-isimplemented-src-minisql-transaction-lock-manager-ml-303922572"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql transaction lock manager module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L441)

<a id="function-function-minisql-transaction-lock-manager-iswaiting-function-iswaiting-manager-transactionid-src-minisql-transaction-lock-manager-ml-433367886"></a>
### isWaiting

```ml
function isWaiting(manager, transactionId)
```

Evaluates whether the supplied input satisfies the waiting predicate. Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L322)

<a id="constant-constant-minisql-transaction-lock-manager-lock-conflict-const-lock-conflict-9007-src-minisql-transaction-lock-manager-ml-292177235"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```

Defines the lock conflict constant used by the minisql transaction lock manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L15)

<a id="constant-constant-minisql-transaction-lock-manager-lock-timeout-const-lock-timeout-9032-src-minisql-transaction-lock-manager-ml-1041855299"></a>
### LOCK_TIMEOUT

```ml
const LOCK_TIMEOUT = 9032
```

Defines the lock timeout constant used by the minisql transaction lock manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L19)

- [minisql.transaction.lock_manager.LockManager](Type-minisql-transaction-lock-manager-lockmanager-1949619269.md) — struct
<a id="function-function-minisql-transaction-lock-manager-pathexists-function-pathexists-manager-current-target-visited-src-minisql-transaction-lock-manager-ml-389820057"></a>
### pathExists

```ml
function pathExists(manager, current, target, visited)
```

Performs the pathExists operation for the minisql transaction lock manager module. Inputs: `manager`, `current`, `target`, `visited`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `current` | `dynamic` | — | current value consumed by this operation. |
| `target` | `dynamic` | — | target value consumed by this operation. |
| `visited` | `dynamic` | — | visited value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L139)

<a id="function-function-minisql-transaction-lock-manager-readblockers-function-readblockers-manager-transactionid-src-minisql-transaction-lock-manager-ml-448957980"></a>
### readBlockers

```ml
function readBlockers(manager, transactionId)
```

Reads the blockers. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L182)

<a id="function-function-minisql-transaction-lock-manager-readercount-function-readercount-manager-src-minisql-transaction-lock-manager-ml-379700851"></a>
### readerCount

```ml
function readerCount(manager)
```

Reads the er count. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L295)

- [minisql.transaction.lock_manager.ReadLease](Type-minisql-transaction-lock-manager-readlease-795074461.md) — struct
<a id="function-function-minisql-transaction-lock-manager-registerwait-function-registerwait-manager-transactionid-blockers-operation-src-minisql-transaction-lock-manager-ml-327851830"></a>
### registerWait

```ml
function registerWait(manager, transactionId, blockers, operation)
```

Performs the register wait operation for this module. Inputs: `manager`, `transactionId`, `blockers`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `blockers` | `dynamic` | — | blockers value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L157)

<a id="function-function-minisql-transaction-lock-manager-release-function-release-manager-transactionid-src-minisql-transaction-lock-manager-ml-1719603838"></a>
### release

```ml
function release(manager, transactionId)
```

Performs the release operation for the minisql transaction lock manager module. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L283)

<a id="function-function-minisql-transaction-lock-manager-releaseread-function-releaseread-manager-transactionid-src-minisql-transaction-lock-manager-ml-733818918"></a>
### releaseRead

```ml
function releaseRead(manager, transactionId)
```

Releases the read. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L352)

<a id="function-function-minisql-transaction-lock-manager-releasereadunlocked-function-releasereadunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-1445121404"></a>
### releaseReadUnlocked

```ml
function releaseReadUnlocked(manager, transactionId)
```

Releases the read unlocked. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L338)

<a id="function-function-minisql-transaction-lock-manager-releaseunlocked-function-releaseunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-636235052"></a>
### releaseUnlocked

```ml
function releaseUnlocked(manager, transactionId)
```

Releases the unlocked. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L268)

<a id="function-function-minisql-transaction-lock-manager-targetmilestone-function-targetmilestone-src-minisql-transaction-lock-manager-ml-166893162"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql transaction lock manager module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L435)

<a id="function-function-minisql-transaction-lock-manager-validate-function-validate-manager-operation-src-minisql-transaction-lock-manager-ml-523810864"></a>
### validate

```ml
function validate(manager, operation)
```

Validates validate for the minisql transaction lock manager workflow. Inputs: `manager`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L74)

<a id="function-function-minisql-transaction-lock-manager-validtransactionid-function-validtransactionid-transactionid-operation-src-minisql-transaction-lock-manager-ml-1160477250"></a>
### validTransactionId

```ml
function validTransactionId(transactionId, operation)
```

Performs the valid transaction id operation for this module. Inputs: `transactionId`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L83)

- [minisql.transaction.lock_manager.WaitEdge](Type-minisql-transaction-lock-manager-waitedge-1759094537.md) — struct
<a id="function-function-minisql-transaction-lock-manager-waitercount-function-waitercount-manager-src-minisql-transaction-lock-manager-ml-2119985337"></a>
### waiterCount

```ml
function waiterCount(manager)
```

Performs the waiter count operation for this module. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L306)

<a id="function-function-minisql-transaction-lock-manager-writeblockers-function-writeblockers-manager-transactionid-src-minisql-transaction-lock-manager-ml-364480732"></a>
### writeBlockers

```ml
function writeBlockers(manager, transactionId)
```

Writes the blockers. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — | manager value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L192)
