# `src/minisql/transaction/recovery.ml`

[Home](README.md) · [Files](Files.md)

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
| `record` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `forceRedo` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L143)

<a id="function-function-minisql-transaction-recovery-buildstatuses-function-buildstatuses-records-startlsn-src-minisql-transaction-recovery-ml-1495084111"></a>
### buildStatuses

```ml
function buildStatuses(records, startLsn)
```

Builds the statuses. Inputs: `records`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `dynamic` | — |  |
| `startLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L105)

<a id="function-function-minisql-transaction-recovery-componentname-function-componentname-src-minisql-transaction-recovery-ml-1452025212"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L256)

<a id="constant-constant-minisql-transaction-recovery-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-recovery-ml-891917980"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L18)

<a id="function-function-minisql-transaction-recovery-fail-function-fail-code-operation-message-src-minisql-transaction-recovery-ml-1982310551"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L60)

<a id="function-function-minisql-transaction-recovery-findstatus-function-findstatus-statuses-transactionid-src-minisql-transaction-recovery-ml-442597899"></a>
### findStatus

```ml
function findStatus(statuses, transactionId)
```

Finds the status. Inputs: `statuses`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statuses` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L95)

<a id="function-function-minisql-transaction-recovery-findtarget-function-findtarget-targets-fileid-src-minisql-transaction-recovery-ml-605586401"></a>
### findTarget

```ml
function findTarget(targets, fileId)
```

Finds the target. Inputs: `targets`, `fileId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `targets` | `dynamic` | — |  |
| `fileId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L85)

<a id="constant-constant-minisql-transaction-recovery-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-recovery-ml-1271194969"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Crash recovery reconstructs transaction status from the WAL, redoes committed page images in log order, and restores before-images for incomplete work in reverse order. Page LSN checks make repeated recovery idempotent.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L17)

<a id="function-function-minisql-transaction-recovery-iscommitted-function-iscommitted-statuses-transactionid-src-minisql-transaction-recovery-ml-1900494759"></a>
### isCommitted

```ml
function isCommitted(statuses, transactionId)
```

Evaluates whether the supplied input satisfies the committed predicate. Inputs: `statuses`, `transactionId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `statuses` | `dynamic` | — |  |
| `transactionId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L135)

<a id="function-function-minisql-transaction-recovery-isimplemented-function-isimplemented-src-minisql-transaction-recovery-ml-1303940012"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L268)

<a id="function-function-minisql-transaction-recovery-recover-function-recover-log-targets-startlsn-src-minisql-transaction-recovery-ml-334849867"></a>
### recover

```ml
function recover(log, targets, startLsn)
```

Recovers the requested value. Inputs: `log`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |
| `startLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L238)

<a id="function-function-minisql-transaction-recovery-recoverpath-function-recoverpath-path-segmentbytes-targets-startlsn-src-minisql-transaction-recovery-ml-1900136110"></a>
### recoverPath

```ml
function recoverPath(path, segmentBytes, targets, startLsn)
```

Recovers the path. Inputs: `path`, `segmentBytes`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `segmentBytes` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |
| `startLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L246)

<a id="function-function-minisql-transaction-recovery-recoverscan-function-recoverscan-scanresult-targets-startlsn-src-minisql-transaction-recovery-ml-2043594785"></a>
### recoverScan

```ml
function recoverScan(scanResult, targets, startLsn)
```

Recovers a conventional monotonically increasing WAL using page-LSN skips.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |
| `startLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L225)

<a id="function-function-minisql-transaction-recovery-recoverscanforced-function-recoverscanforced-scanresult-targets-src-minisql-transaction-recovery-ml-1135472736"></a>
### recoverScanForced

```ml
function recoverScanForced(scanResult, targets)
```

Replays every committed image in the bounded post-reset WAL. Page LSNs from an earlier physical WAL epoch may be numerically larger, so they cannot be a skip predicate. Full page-image replay is still idempotent and log ordered.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L232)

<a id="function-function-minisql-transaction-recovery-recoverscanmode-function-recoverscanmode-scanresult-targets-startlsn-forceredo-src-minisql-transaction-recovery-ml-1688749078"></a>
### recoverScanMode

```ml
function recoverScanMode(scanResult, targets, startLsn, forceRedo)
```

Recovers the scan. Inputs: `scanResult`, `targets`, `startLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scanResult` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |
| `startLsn` | `dynamic` | — |  |
| `forceRedo` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L164)

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
| `fileId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L78)

<a id="function-function-minisql-transaction-recovery-target-function-target-fileid-pagedfile-src-minisql-transaction-recovery-ml-1544692000"></a>
### target

```ml
function target(fileId, pagedFile)
```

Performs the target operation for this module. Inputs: `fileId`, `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — |  |
| `pagedFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L66)

<a id="function-function-minisql-transaction-recovery-targetmilestone-function-targetmilestone-src-minisql-transaction-recovery-ml-969420042"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/recovery.ml#L262)

- [minisql.transaction.recovery.TransactionStatus](Type-minisql-transaction-recovery-transactionstatus-2076451289.md) — struct
