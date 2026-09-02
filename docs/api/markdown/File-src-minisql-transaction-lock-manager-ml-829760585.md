# `src/minisql/transaction/lock_manager.ml`

[Home](README.md) · [Files](Files.md)

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
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L184)

<a id="function-function-minisql-transaction-lock-manager-acquirereadunlocked-function-acquirereadunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-1450459990"></a>
### acquireReadUnlocked

```ml
function acquireReadUnlocked(manager, transactionId)
```

Acquires the read unlocked. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L174)

<a id="function-function-minisql-transaction-lock-manager-acquirestatementread-function-acquirestatementread-manager-transactionid-isolationlevel-src-minisql-transaction-lock-manager-ml-204590674"></a>
### acquireStatementRead

```ml
function acquireStatementRead(manager, transactionId, isolationLevel)
```

Acquires the statement read. Inputs: `manager`, `transactionId`, `isolationLevel`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |
| `isolationLevel` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L312)

<a id="function-function-minisql-transaction-lock-manager-acquirewrite-function-acquirewrite-manager-transactionid-src-minisql-transaction-lock-manager-ml-1494741924"></a>
### acquireWrite

```ml
function acquireWrite(manager, transactionId)
```

Acquires the write. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L205)

<a id="function-function-minisql-transaction-lock-manager-acquirewriteunlocked-function-acquirewriteunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-431754348"></a>
### acquireWriteUnlocked

```ml
function acquireWriteUnlocked(manager, transactionId)
```

Acquires the write unlocked. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L195)

<a id="function-function-minisql-transaction-lock-manager-activewriter-function-activewriter-manager-src-minisql-transaction-lock-manager-ml-1977221495"></a>
### activeWriter

```ml
function activeWriter(manager)
```

Performs the active writer operation for this module. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L347)

<a id="function-function-minisql-transaction-lock-manager-cancelwait-function-cancelwait-manager-transactionid-src-minisql-transaction-lock-manager-ml-1776972756"></a>
### cancelWait

```ml
function cancelWait(manager, transactionId)
```

Removes the transaction's pending wait edges after cancellation or timeout. Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L216)

<a id="function-function-minisql-transaction-lock-manager-cleartransactionwaits-function-cleartransactionwaits-manager-transactionid-src-minisql-transaction-lock-manager-ml-1908216882"></a>
### clearTransactionWaits

```ml
function clearTransactionWaits(manager, transactionId)
```

Clears the transaction waits. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L107)

<a id="function-function-minisql-transaction-lock-manager-clearwaiter-function-clearwaiter-manager-transactionid-src-minisql-transaction-lock-manager-ml-2107465634"></a>
### clearWaiter

```ml
function clearWaiter(manager, transactionId)
```

Clears the waiter. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L96)

<a id="function-function-minisql-transaction-lock-manager-close-function-close-manager-src-minisql-transaction-lock-manager-ml-345488415"></a>
### close

```ml
function close(manager)
```

Closes the requested value. Inputs: `manager`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L357)

<a id="function-function-minisql-transaction-lock-manager-componentname-function-componentname-src-minisql-transaction-lock-manager-ml-41894428"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L369)

<a id="function-function-minisql-transaction-lock-manager-containsid-function-containsid-values-wanted-src-minisql-transaction-lock-manager-ml-1330442163"></a>
### containsId

```ml
function containsId(values, wanted)
```

Performs the contains id operation for this module. Inputs: `values`, `wanted`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L81)

<a id="function-function-minisql-transaction-lock-manager-containsreader-function-containsreader-manager-transactionid-src-minisql-transaction-lock-manager-ml-1839877356"></a>
### containsReader

```ml
function containsReader(manager, transactionId)
```

Performs the contains reader operation for this module. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L90)

<a id="function-function-minisql-transaction-lock-manager-create-function-create-src-minisql-transaction-lock-manager-ml-1032285464"></a>
### create

```ml
function create()
```

Creates the requested value. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L61)

<a id="constant-constant-minisql-transaction-lock-manager-deadlock-detected-const-deadlock-detected-9031-src-minisql-transaction-lock-manager-ml-1601684258"></a>
### DEADLOCK_DETECTED

```ml
const DEADLOCK_DETECTED = 9031
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L16)

<a id="function-function-minisql-transaction-lock-manager-fail-function-fail-code-operation-message-src-minisql-transaction-lock-manager-ml-1389035727"></a>
### fail

```ml
function fail(code, operation, message)
```

Creates the module's structured error with operation context. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L55)

<a id="function-function-minisql-transaction-lock-manager-finishstatement-function-finishstatement-manager-lease-src-minisql-transaction-lock-manager-ml-860817441"></a>
### finishStatement

```ml
function finishStatement(manager, lease)
```

Performs the finish statement operation for this module. Inputs: `manager`, `lease`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `lease` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L329)

<a id="function-function-minisql-transaction-lock-manager-finishtransaction-function-finishtransaction-manager-transactionid-src-minisql-transaction-lock-manager-ml-883466970"></a>
### finishTransaction

```ml
function finishTransaction(manager, transactionId)
```

Performs the finish transaction operation for this module. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L341)

<a id="constant-constant-minisql-transaction-lock-manager-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-lock-manager-ml-1734488969"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

In-process writer-prioritized reader/writer gate shared by connections using one database. The manager serializes state transitions with a mutex, prevents new readers from starving queued writers, and exposes wait-for edges for deterministic timeout and deadlock diagnostics.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L14)

<a id="function-function-minisql-transaction-lock-manager-isimplemented-function-isimplemented-src-minisql-transaction-lock-manager-ml-303922572"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L381)

<a id="function-function-minisql-transaction-lock-manager-iswaiting-function-iswaiting-manager-transactionid-src-minisql-transaction-lock-manager-ml-433367886"></a>
### isWaiting

```ml
function isWaiting(manager, transactionId)
```

Evaluates whether the supplied input satisfies the waiting predicate. Inputs: `manager`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L275)

<a id="constant-constant-minisql-transaction-lock-manager-lock-conflict-const-lock-conflict-9007-src-minisql-transaction-lock-manager-ml-292177235"></a>
### LOCK_CONFLICT

```ml
const LOCK_CONFLICT = 9007
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L15)

<a id="constant-constant-minisql-transaction-lock-manager-lock-timeout-const-lock-timeout-9032-src-minisql-transaction-lock-manager-ml-1041855299"></a>
### LOCK_TIMEOUT

```ml
const LOCK_TIMEOUT = 9032
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L17)

- [minisql.transaction.lock_manager.LockManager](Type-minisql-transaction-lock-manager-lockmanager-1949619269.md) — struct
<a id="function-function-minisql-transaction-lock-manager-pathexists-function-pathexists-manager-current-target-visited-src-minisql-transaction-lock-manager-ml-389820057"></a>
### pathExists

```ml
function pathExists(manager, current, target, visited)
```

Performs the path exists operation for this module. Inputs: `manager`, `current`, `target`, `visited`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `current` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |
| `visited` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L118)

<a id="function-function-minisql-transaction-lock-manager-readblockers-function-readblockers-manager-transactionid-src-minisql-transaction-lock-manager-ml-448957980"></a>
### readBlockers

```ml
function readBlockers(manager, transactionId)
```

Reads the blockers. Inputs: `manager`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L155)

<a id="function-function-minisql-transaction-lock-manager-readercount-function-readercount-manager-src-minisql-transaction-lock-manager-ml-379700851"></a>
### readerCount

```ml
function readerCount(manager)
```

Reads the er count. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L251)

- [minisql.transaction.lock_manager.ReadLease](Type-minisql-transaction-lock-manager-readlease-795074461.md) — struct
<a id="function-function-minisql-transaction-lock-manager-registerwait-function-registerwait-manager-transactionid-blockers-operation-src-minisql-transaction-lock-manager-ml-327851830"></a>
### registerWait

```ml
function registerWait(manager, transactionId, blockers, operation)
```

Performs the register wait operation for this module. Inputs: `manager`, `transactionId`, `blockers`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |
| `blockers` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L132)

<a id="function-function-minisql-transaction-lock-manager-release-function-release-manager-transactionid-src-minisql-transaction-lock-manager-ml-1719603838"></a>
### release

```ml
function release(manager, transactionId)
```

Releases the requested value. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L240)

<a id="function-function-minisql-transaction-lock-manager-releaseread-function-releaseread-manager-transactionid-src-minisql-transaction-lock-manager-ml-733818918"></a>
### releaseRead

```ml
function releaseRead(manager, transactionId)
```

Releases the read. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L301)

<a id="function-function-minisql-transaction-lock-manager-releasereadunlocked-function-releasereadunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-1445121404"></a>
### releaseReadUnlocked

```ml
function releaseReadUnlocked(manager, transactionId)
```

Releases the read unlocked. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L289)

<a id="function-function-minisql-transaction-lock-manager-releaseunlocked-function-releaseunlocked-manager-transactionid-src-minisql-transaction-lock-manager-ml-636235052"></a>
### releaseUnlocked

```ml
function releaseUnlocked(manager, transactionId)
```

Releases the unlocked. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L227)

<a id="function-function-minisql-transaction-lock-manager-targetmilestone-function-targetmilestone-src-minisql-transaction-lock-manager-ml-166893162"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L375)

<a id="function-function-minisql-transaction-lock-manager-validate-function-validate-manager-operation-src-minisql-transaction-lock-manager-ml-523810864"></a>
### validate

```ml
function validate(manager, operation)
```

Validates the requested value. Inputs: `manager`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L67)

<a id="function-function-minisql-transaction-lock-manager-validtransactionid-function-validtransactionid-transactionid-operation-src-minisql-transaction-lock-manager-ml-1160477250"></a>
### validTransactionId

```ml
function validTransactionId(transactionId, operation)
```

Performs the valid transaction id operation for this module. Inputs: `transactionId`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `transactionId` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L74)

- [minisql.transaction.lock_manager.WaitEdge](Type-minisql-transaction-lock-manager-waitedge-1759094537.md) — struct
<a id="function-function-minisql-transaction-lock-manager-waitercount-function-waitercount-manager-src-minisql-transaction-lock-manager-ml-2119985337"></a>
### waiterCount

```ml
function waiterCount(manager)
```

Performs the waiter count operation for this module. Inputs: `manager`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L261)

<a id="function-function-minisql-transaction-lock-manager-writeblockers-function-writeblockers-manager-transactionid-src-minisql-transaction-lock-manager-ml-364480732"></a>
### writeBlockers

```ml
function writeBlockers(manager, transactionId)
```

Writes the blockers. Inputs: `manager`, `transactionId`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `manager` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/lock_manager.ml#L163)
