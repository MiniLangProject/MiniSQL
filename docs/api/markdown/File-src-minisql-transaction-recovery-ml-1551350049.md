# `src/minisql/transaction/recovery.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql transaction recovery facilities for this project.

Package: [`minisql.transaction.recovery`](Package-minisql-transaction-recovery-1517014565.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="function-function-minisql-transaction-recovery-applypage-function-applypage-record-destination-forceredo-src-minisql-transaction-recovery-ml-1140321084"></a>
### applyPage

```ml
function applyPage(record, destination, forceRedo)
```

Applies the page. Inputs: `record`, `destination`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | record value consumed by this operation. |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `forceRedo` | `dynamic` | — | forceRedo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L161)

<a id="function-function-minisql-transaction-recovery-buildstatuses-function-buildstatuses-records-startlsn-src-minisql-transaction-recovery-ml-1495084111"></a>
### buildStatuses

```ml
function buildStatuses(records, startLsn)
```

Builds the statuses. Inputs: `records`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `dynamic` | — | records value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L118)

<a id="function-function-minisql-transaction-recovery-componentname-function-componentname-src-minisql-transaction-recovery-ml-1452025212"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql transaction recovery module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L290)

<a id="constant-constant-minisql-transaction-recovery-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-recovery-ml-891917980"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql transaction recovery module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L19)

<a id="function-function-minisql-transaction-recovery-fail-function-fail-code-operation-message-src-minisql-transaction-recovery-ml-1982310551"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql transaction recovery module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L64)

<a id="function-function-minisql-transaction-recovery-findstatus-function-findstatus-statuses-transactionid-src-minisql-transaction-recovery-ml-442597899"></a>
### findStatus

```ml
function findStatus(statuses, transactionId)
```

Finds the status. Inputs: `statuses`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statuses` | `dynamic` | — | statuses value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L106)

<a id="function-function-minisql-transaction-recovery-findtarget-function-findtarget-targets-fileid-src-minisql-transaction-recovery-ml-605586401"></a>
### findTarget

```ml
function findTarget(targets, fileId)
```

Finds the target. Inputs: `targets`, `fileId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `targets` | `dynamic` | — | targets value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L94)

<a id="constant-constant-minisql-transaction-recovery-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-recovery-ml-1271194969"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Crash recovery reconstructs transaction status from the WAL, redoes committed


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L17)

<a id="function-function-minisql-transaction-recovery-iscommitted-function-iscommitted-statuses-transactionid-src-minisql-transaction-recovery-ml-1900494759"></a>
### isCommitted

```ml
function isCommitted(statuses, transactionId)
```

Evaluates whether the supplied input satisfies the committed predicate. Inputs: `statuses`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statuses` | `dynamic` | — | statuses value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L150)

<a id="function-function-minisql-transaction-recovery-isimplemented-function-isimplemented-src-minisql-transaction-recovery-ml-1303940012"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql transaction recovery module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L302)

<a id="function-function-minisql-transaction-recovery-recover-function-recover-log-targets-startlsn-src-minisql-transaction-recovery-ml-334849867"></a>
### recover

```ml
function recover(log, targets, startLsn)
```

Recovers the requested value. Inputs: `log`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `targets` | `dynamic` | — | targets value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L268)

<a id="function-function-minisql-transaction-recovery-recoverpath-function-recoverpath-path-segmentbytes-targets-startlsn-src-minisql-transaction-recovery-ml-1900136110"></a>
### recoverPath

```ml
function recoverPath(path, segmentBytes, targets, startLsn)
```

Recovers the path. Inputs: `path`, `segmentBytes`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `segmentBytes` | `dynamic` | — | segmentBytes value consumed by this operation. |
| `targets` | `dynamic` | — | targets value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L280)

<a id="function-function-minisql-transaction-recovery-recoverscan-function-recoverscan-scanresult-targets-startlsn-src-minisql-transaction-recovery-ml-2043594785"></a>
### recoverScan

```ml
function recoverScan(scanResult, targets, startLsn)
```

Recovers a conventional monotonically increasing WAL using page-LSN skips.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — | scanResult value consumed by this operation. |
| `targets` | `dynamic` | — | targets value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L250)

<a id="function-function-minisql-transaction-recovery-recoverscanforced-function-recoverscanforced-scanresult-targets-src-minisql-transaction-recovery-ml-1135472736"></a>
### recoverScanForced

```ml
function recoverScanForced(scanResult, targets)
```

Replays every committed image in the bounded post-reset WAL. Page LSNs from an earlier physical WAL epoch may be numerically larger, so they cannot be a skip predicate. Full page-image replay is still idempotent and log ordered.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — | scanResult value consumed by this operation. |
| `targets` | `dynamic` | — | targets value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L259)

<a id="function-function-minisql-transaction-recovery-recoverscanmode-function-recoverscanmode-scanresult-targets-startlsn-forceredo-src-minisql-transaction-recovery-ml-1688749078"></a>
### recoverScanMode

```ml
function recoverScanMode(scanResult, targets, startLsn, forceRedo)
```

Recovers the scan. Inputs: `scanResult`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — | scanResult value consumed by this operation. |
| `targets` | `dynamic` | — | targets value consumed by this operation. |
| `startLsn` | `dynamic` | — | startLsn value consumed by this operation. |
| `forceRedo` | `dynamic` | — | forceRedo value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L186)

- [minisql.transaction.recovery.RecoveryResult](Type-minisql-transaction-recovery-recoveryresult-147029803.md) — struct
- [minisql.transaction.recovery.RecoveryTarget](Type-minisql-transaction-recovery-recoverytarget-1578539379.md) — struct
<a id="function-function-minisql-transaction-recovery-retiredtarget-function-retiredtarget-fileid-src-minisql-transaction-recovery-ml-1830130769"></a>
### retiredTarget

```ml
function retiredTarget(fileId)
```

Marks one durable object ID as intentionally retired so historical committed WAL images for a dropped file are counted as skipped instead of treated as an accidentally omitted live target. Callers must prove retirement from their current durable catalog; the generic recovery entry points remain strict. Inputs: `fileId`. Returns a target without an open paged file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — | Identifier of file. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L85)

<a id="function-function-minisql-transaction-recovery-target-function-target-fileid-pagedfile-src-minisql-transaction-recovery-ml-1544692000"></a>
### target

```ml
function target(fileId, pagedFile)
```

Performs the target operation for this module. Inputs: `fileId`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pagedFile` | `dynamic` | — | pagedFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L72)

<a id="function-function-minisql-transaction-recovery-targetmilestone-function-targetmilestone-src-minisql-transaction-recovery-ml-969420042"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql transaction recovery module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L296)

- [minisql.transaction.recovery.TransactionStatus](Type-minisql-transaction-recovery-transactionstatus-2076451289.md) — struct
