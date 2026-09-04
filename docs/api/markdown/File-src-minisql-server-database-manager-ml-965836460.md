# `src/minisql/server/database_manager.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql server database manager facilities for this project.

Package: [`minisql.server.database_manager`](Package-minisql-server-database-manager-4763150.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/schema_history.ml` as `schema_history` → [src/minisql/catalog/schema_history.ml](File-src-minisql-catalog-schema-history-ml-67428687.md)
- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/diagnostics.ml` as `diagnostics` → [src/minisql/common/diagnostics.ml](File-src-minisql-common-diagnostics-ml-1805539733.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/logger.ml` as `logger` → [src/minisql/common/logger.ml](File-src-minisql-common-logger-ml-1571638233.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/lock.ml` as `file_lock` → [src/minisql/platform/lock.ml](File-src-minisql-platform-lock-ml-271785262.md)
- `minisql/storage/btree.ml` as `btree` → [src/minisql/storage/btree.ml](File-src-minisql-storage-btree-ml-1474397187.md)
- `minisql/storage/buffer_pool.ml` as `buffer_pool` → [src/minisql/storage/buffer_pool.ml](File-src-minisql-storage-buffer-pool-ml-1867626530.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/transaction/checkpoint.ml` as `checkpoint` → [src/minisql/transaction/checkpoint.ml](File-src-minisql-transaction-checkpoint-ml-1306482346.md)
- `minisql/transaction/lock_manager.ml` as `lock_manager` → [src/minisql/transaction/lock_manager.ml](File-src-minisql-transaction-lock-manager-ml-829760585.md)
- `minisql/transaction/recovery.ml` as `recovery` → [src/minisql/transaction/recovery.ml](File-src-minisql-transaction-recovery-ml-1551350049.md)
- `minisql/transaction/transaction.ml` as `transaction` → [src/minisql/transaction/transaction.ml](File-src-minisql-transaction-transaction-ml-1157597470.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)
- `std/ds/hashmap.ml` as `hashmap` → `../MiniLangCompilerML/std/ds/hashmap.ml` — external dependency
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency
- `std/threading.ml` as `threading` → `../MiniLangCompilerML/std/threading.ml` — external dependency
- `std/time.ml` as `time_api` → `../MiniLangCompilerML/std/time.ml` — external dependency

## Declarations

<a id="function-function-minisql-server-database-manager-acquireindexreadhandle-function-acquireindexreadhandle-database-path-src-minisql-server-database-manager-ml-1939490106"></a>
### acquireIndexReadHandle

```ml
function acquireIndexReadHandle(database, path)
```

Acquires or lazily opens one persistent read-only index tree. The registry guard prevents duplicate publication; explicit-offset native reads require no per-query lock after the immutable tree has been published.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L582)

<a id="function-function-minisql-server-database-manager-acquirestatementread-function-acquirestatementread-database-transactionid-isolationlevel-src-minisql-server-database-manager-ml-1770792312"></a>
### acquireStatementRead

```ml
function acquireStatementRead(database, transactionId, isolationLevel)
```

Acquires statement read using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `isolationLevel` | `dynamic` | — | isolationLevel value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1700)

<a id="function-function-minisql-server-database-manager-acquiretablereadhandle-function-acquiretablereadhandle-database-path-src-minisql-server-database-manager-ml-1197905130"></a>
### acquireTableReadHandle

```ml
function acquireTableReadHandle(database, path)
```

Acquires or lazily opens one persistent read-only table PagedFile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L606)

<a id="function-function-minisql-server-database-manager-acquirewrite-function-acquirewrite-database-transactionid-src-minisql-server-database-manager-ml-354799822"></a>
### acquireWrite

```ml
function acquireWrite(database, transactionId)
```

Acquires write using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1720)

<a id="function-function-minisql-server-database-manager-activeconcurrentreaders-function-activeconcurrentreaders-database-src-minisql-server-database-manager-ml-1058579915"></a>
### activeConcurrentReaders

```ml
function activeConcurrentReaders(database)
```

Returns the number of readers currently admitted through the physical execution gate. This diagnostic is safe while sessions are still active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L820)

<a id="function-function-minisql-server-database-manager-activewriter-function-activewriter-database-src-minisql-server-database-manager-ml-1433518617"></a>
### activeWriter

```ml
function activeWriter(database)
```

Implements active writer for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1767)

<a id="function-function-minisql-server-database-manager-admitstatement-function-admitstatement-database-src-minisql-server-database-manager-ml-746818001"></a>
### admitStatement

```ml
function admitStatement(database)
```

Rejects new statements before they can amplify an already exhausted heap. `heap_bytes_committed` is the runtime's reserved arena and may deliberately exceed the policy, so admission is based on live managed bytes instead.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1370)

<a id="function-function-minisql-server-database-manager-advanceplanninggeneration-function-advanceplanninggeneration-database-src-minisql-server-database-manager-ml-1358904795"></a>
### advancePlanningGeneration

```ml
function advancePlanningGeneration(database)
```

Advances the shared generation after committed DDL or statistics maintenance.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1684)

<a id="function-function-minisql-server-database-manager-allocatesessionid-function-allocatesessionid-database-src-minisql-server-database-manager-ml-460304021"></a>
### allocateSessionId

```ml
function allocateSessionId(database)
```

Implements allocate session identifier for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1270)

<a id="function-function-minisql-server-database-manager-audit-function-audit-database-eventtype-outcome-sessionid-principalid-detail-src-minisql-server-database-manager-ml-103372822"></a>
### audit

```ml
function audit(database, eventType, outcome, sessionId, principalId, detail)
```

Implements audit for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `eventType` | `dynamic` | — | eventType value consumed by this operation. |
| `outcome` | `dynamic` | — | outcome value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |
| `detail` | `dynamic` | — | detail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1790)

<a id="function-function-minisql-server-database-manager-begin-function-begin-database-isolationlevel-readonly-src-minisql-server-database-manager-ml-982779975"></a>
### begin

```ml
function begin(database, isolationLevel, readOnly)
```

Implements begin for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `isolationLevel` | `dynamic` | — | isolationLevel value consumed by this operation. |
| `readOnly` | `dynamic` | — | readOnly value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1259)

<a id="function-function-minisql-server-database-manager-beginoperationalstatement-function-beginoperationalstatement-database-sessionid-principalid-sqltext-src-minisql-server-database-manager-ml-1918730044"></a>
### beginOperationalStatement

```ml
function beginOperationalStatement(database, sessionId, principalId, sqlText)
```

Marks a session as executing and stores only a bounded SQL summary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1458)

<a id="function-function-minisql-server-database-manager-bytesequal-function-bytesequal-left-right-src-minisql-server-database-manager-ml-1960047517"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql server database manager module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L327)

- [minisql.server.database_manager.CachedReadHandle](Type-minisql-server-database-manager-cachedreadhandle-2118149404.md) — struct
<a id="function-function-minisql-server-database-manager-cancellockwait-function-cancellockwait-database-transactionid-src-minisql-server-database-manager-ml-1877412974"></a>
### cancelLockWait

```ml
function cancelLockWait(database, transactionId)
```

Implements cancel lock wait for this module. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1740)

<a id="constant-constant-minisql-server-database-manager-checkpoint-marker-bytes-const-checkpoint-marker-bytes-24-src-minisql-server-database-manager-ml-1686015107"></a>
### CHECKPOINT_MARKER_BYTES

```ml
const CHECKPOINT_MARKER_BYTES = 24
```

Durable marker formats used to make physical WAL reset crash-safe. The epoch


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L103)

<a id="function-function-minisql-server-database-manager-checkpointafterstatement-function-checkpointafterstatement-database-src-minisql-server-database-manager-ml-1516369273"></a>
### checkpointAfterStatement

```ml
function checkpointAfterStatement(database)
```

Runs post-commit checkpoint maintenance without changing an already durable SQL outcome into a retryable client error. Failures remain visible in the server log and the next writer retries while the intact WAL stays recoverable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1902)

<a id="function-function-minisql-server-database-manager-checkpointifneeded-function-checkpointifneeded-database-src-minisql-server-database-manager-ml-555174705"></a>
### checkpointIfNeeded

```ml
function checkpointIfNeeded(database)
```

Resets the current WAL at a fully published statement boundary once it reaches the configured threshold. The caller must hold exclusive database execution, which guarantees that every WAL record being discarded already has a durable base-file page image and that no commit can race the reset. Persistent epoch replay avoids comparing new low LSNs with page LSNs from a previous physical WAL generation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1842)

<a id="function-function-minisql-server-database-manager-checkpointmarkerbytes-function-checkpointmarkerbytes-magic-databaseid-src-minisql-server-database-manager-ml-1050544329"></a>
### checkpointMarkerBytes

```ml
function checkpointMarkerBytes(magic, databaseId)
```

Encodes an eight-byte marker magic and the database identity into one small, self-identifying durable record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `magic` | `dynamic` | — | magic value consumed by this operation. |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L423)

<a id="function-function-minisql-server-database-manager-checkpointresetcount-function-checkpointresetcount-database-src-minisql-server-database-manager-ml-1168345789"></a>
### checkpointResetCount

```ml
function checkpointResetCount(database)
```

Returns the number of successful process-local automatic WAL resets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1874)

<a id="function-function-minisql-server-database-manager-close-function-close-database-src-minisql-server-database-manager-ml-2115470381"></a>
### close

```ml
function close(database)
```

Closes close owned by the minisql server database manager module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1927)

<a id="constant-constant-minisql-server-database-manager-closed-handle-const-closed-handle-9008-src-minisql-server-database-manager-ml-951772886"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L36)

<a id="function-function-minisql-server-database-manager-closereadhandlecache-function-closereadhandlecache-database-src-minisql-server-database-manager-ml-1728057825"></a>
### closeReadHandleCache

```ml
function closeReadHandleCache(database)
```

Permanently closes the database-owned registry during database shutdown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L672)

<a id="function-function-minisql-server-database-manager-closereadhandlemap-function-closereadhandlemap-values-src-minisql-server-database-manager-ml-1506922758"></a>
### closeReadHandleMap

```ml
function closeReadHandleMap(values)
```

Closes every entry in one raw HashMap while the registry and writer gates are held. Iterating occupied slots avoids allocating a temporary values array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L630)

<a id="function-function-minisql-server-database-manager-closerecoveryfiles-function-closerecoveryfiles-files-src-minisql-server-database-manager-ml-1438142183"></a>
### closeRecoveryFiles

```ml
function closeRecoveryFiles(files)
```

Closes recovery files using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `files` | `dynamic` | — | files value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L477)

<a id="function-function-minisql-server-database-manager-componentname-function-componentname-src-minisql-server-database-manager-ml-646902112"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql server database manager module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1964)

<a id="function-function-minisql-server-database-manager-configureoperationallimits-function-configureoperationallimits-database-maxstatementbytes-maxframebytes-maxresultrows-idletimeoutms-src-minisql-server-database-manager-ml-1533075502"></a>
### configureOperationalLimits

```ml
function configureOperationalLimits(database, maxStatementBytes, maxFrameBytes, maxResultRows, idleTimeoutMs)
```

Applies validated protocol and result limits before the listener accepts clients.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `maxStatementBytes` | `dynamic` | — | maxStatementBytes value consumed by this operation. |
| `maxFrameBytes` | `dynamic` | — | maxFrameBytes value consumed by this operation. |
| `maxResultRows` | `dynamic` | — | maxResultRows value consumed by this operation. |
| `idleTimeoutMs` | `dynamic` | — | idleTimeoutMs value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1289)

<a id="function-function-minisql-server-database-manager-configureproductioncontrols-function-configureproductioncontrols-database-querytimeoutms-maxresultbytes-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-database-manager-ml-1117987113"></a>
### configureProductionControls

```ml
function configureProductionControls(database, queryTimeoutMs, maxResultBytes, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Applies process-wide admission, response, spill, timeout, and slow-query policy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `queryTimeoutMs` | `dynamic` | — | queryTimeoutMs value consumed by this operation. |
| `maxResultBytes` | `dynamic` | — | maxResultBytes value consumed by this operation. |
| `processMemoryBytes` | `dynamic` | — | processMemoryBytes value consumed by this operation. |
| `temporaryStorageBytes` | `dynamic` | — | temporaryStorageBytes value consumed by this operation. |
| `slowQueryMs` | `dynamic` | — | slowQueryMs value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1309)

<a id="function-function-minisql-server-database-manager-configurewritefencing-function-configurewritefencing-database-leasepath-epoch-nodeid-clockskewms-src-minisql-server-database-manager-ml-1659031164"></a>
### configureWriteFencing

```ml
function configureWriteFencing(database, leasePath, epoch, nodeId, clockSkewMs)
```

Enables controller-backed write fencing for this process. Startup fails closed unless the persistent database term exactly matches the process term; this prevents an old command line from restarting a retired primary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `leasePath` | `dynamic` | — | Path associated with lease. |
| `epoch` | `dynamic` | — | epoch value consumed by this operation. |
| `nodeId` | `dynamic` | — | Identifier of node. |
| `clockSkewMs` | `dynamic` | — | clockSkewMs value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1197)

<a id="constant-constant-minisql-server-database-manager-corrupt-data-const-corrupt-data-9004-src-minisql-server-database-manager-ml-1267010572"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L34)

<a id="function-function-minisql-server-database-manager-create-function-create-dataroot-name-defaults-src-minisql-server-database-manager-ml-294799589"></a>
### create

```ml
function create(dataRoot, name, defaults)
```

Creates create for the minisql server database manager module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dataRoot` | `dynamic` | — | dataRoot value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |
| `defaults` | `dynamic` | — | defaults value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1245)

<a id="function-function-minisql-server-database-manager-createexecutiongate-function-createexecutiongate-src-minisql-server-database-manager-ml-1842104750"></a>
### createExecutionGate

```ml
function createExecutionGate()
```

Creates a writer-prioritized gate in the empty state. Returns the gate or a threading error after closing any partially created primitive.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L498)

<a id="function-function-minisql-server-database-manager-createreadhandlecache-function-createreadhandlecache-src-minisql-server-database-manager-ml-575842536"></a>
### createReadHandleCache

```ml
function createReadHandleCache()
```

Creates an empty persistent read-handle registry. Handles are opened lazily so databases with many cold tables consume no native handle resources.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L509)

<a id="function-function-minisql-server-database-manager-createtable-function-createtable-database-name-definitions-src-minisql-server-database-manager-ml-1828741756"></a>
### createTable

```ml
function createTable(database, name, definitions)
```

Creates table using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |
| `definitions` | `dynamic` | — | definitions value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1917)

<a id="constant-constant-minisql-server-database-manager-default-buffer-pool-bytes-const-default-buffer-pool-bytes-268435456-src-minisql-server-database-manager-ml-546526936"></a>
### DEFAULT_BUFFER_POOL_BYTES

```ml
const DEFAULT_BUFFER_POOL_BYTES = 268435456
```

Defines the default buffer pool bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L42)

<a id="constant-constant-minisql-server-database-manager-default-checkpoint-wal-bytes-const-default-checkpoint-wal-bytes-67108864-src-minisql-server-database-manager-ml-1300344905"></a>
### DEFAULT_CHECKPOINT_WAL_BYTES

```ml
const DEFAULT_CHECKPOINT_WAL_BYTES = 67108864
```

Defines the default checkpoint wal bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L40)

<a id="constant-constant-minisql-server-database-manager-default-idle-timeout-ms-const-default-idle-timeout-ms-300000-src-minisql-server-database-manager-ml-1963309740"></a>
### DEFAULT_IDLE_TIMEOUT_MS

```ml
const DEFAULT_IDLE_TIMEOUT_MS = 300000
```

Defines the default idle timeout ms constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L52)

<a id="constant-constant-minisql-server-database-manager-default-max-frame-bytes-const-default-max-frame-bytes-8388608-src-minisql-server-database-manager-ml-1292238002"></a>
### DEFAULT_MAX_FRAME_BYTES

```ml
const DEFAULT_MAX_FRAME_BYTES = 8388608
```

Defines the default max frame bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L48)

<a id="constant-constant-minisql-server-database-manager-default-max-result-bytes-const-default-max-result-bytes-268435456-src-minisql-server-database-manager-ml-87944274"></a>
### DEFAULT_MAX_RESULT_BYTES

```ml
const DEFAULT_MAX_RESULT_BYTES = 268435456
```

Defines the default max result bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L56)

<a id="constant-constant-minisql-server-database-manager-default-max-result-rows-const-default-max-result-rows-1000000-src-minisql-server-database-manager-ml-2040934280"></a>
### DEFAULT_MAX_RESULT_ROWS

```ml
const DEFAULT_MAX_RESULT_ROWS = 1000000
```

Defines the default max result rows constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L50)

<a id="constant-constant-minisql-server-database-manager-default-max-statement-bytes-const-default-max-statement-bytes-1048576-src-minisql-server-database-manager-ml-719685438"></a>
### DEFAULT_MAX_STATEMENT_BYTES

```ml
const DEFAULT_MAX_STATEMENT_BYTES = 1048576
```

Defines the default max statement bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L46)

<a id="constant-constant-minisql-server-database-manager-default-process-memory-bytes-const-default-process-memory-bytes-2147483648-src-minisql-server-database-manager-ml-325976282"></a>
### DEFAULT_PROCESS_MEMORY_BYTES

```ml
const DEFAULT_PROCESS_MEMORY_BYTES = 2147483648
```

Defines the default process memory bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L58)

<a id="constant-constant-minisql-server-database-manager-default-query-memory-bytes-const-default-query-memory-bytes-67108864-src-minisql-server-database-manager-ml-1766523231"></a>
### DEFAULT_QUERY_MEMORY_BYTES

```ml
const DEFAULT_QUERY_MEMORY_BYTES = 67108864
```

Defines the default query memory bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L44)

<a id="constant-constant-minisql-server-database-manager-default-query-timeout-ms-const-default-query-timeout-ms-30000-src-minisql-server-database-manager-ml-1995372186"></a>
### DEFAULT_QUERY_TIMEOUT_MS

```ml
const DEFAULT_QUERY_TIMEOUT_MS = 30000
```

Defines the default query timeout ms constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L54)

<a id="constant-constant-minisql-server-database-manager-default-slow-query-ms-const-default-slow-query-ms-1000-src-minisql-server-database-manager-ml-830951850"></a>
### DEFAULT_SLOW_QUERY_MS

```ml
const DEFAULT_SLOW_QUERY_MS = 1000
```

Defines the default slow query ms constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L62)

<a id="constant-constant-minisql-server-database-manager-default-temporary-storage-bytes-const-default-temporary-storage-bytes-1073741824-src-minisql-server-database-manager-ml-1081239336"></a>
### DEFAULT_TEMPORARY_STORAGE_BYTES

```ml
const DEFAULT_TEMPORARY_STORAGE_BYTES = 1073741824
```

Defines the default temporary storage bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L60)

<a id="function-function-minisql-server-database-manager-enforceprocessmemory-function-enforceprocessmemory-database-src-minisql-server-database-manager-ml-71376621"></a>
### enforceProcessMemory

```ml
function enforceProcessMemory(database)
```

Enforces the managed-heap ceiling for already admitted work at cooperative executor/storage poll boundaries. The terminal statement accounts the single resource rejection, avoiding one counter increment per observed boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1383)

<a id="function-function-minisql-server-database-manager-ensurecheckpointmarker-function-ensurecheckpointmarker-path-expected-src-minisql-server-database-manager-ml-1489144155"></a>
### ensureCheckpointMarker

```ml
function ensureCheckpointMarker(path, expected)
```

Creates a marker durably or validates an already durable retry instance.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L456)

<a id="function-function-minisql-server-database-manager-enterexecution-function-enterexecution-database-src-minisql-server-database-manager-ml-646115193"></a>
### enterExecution

```ml
function enterExecution(database)
```

Backward-compatible names denote exclusive engine execution. Authentication, session lifecycle and every mutating SQL statement use this writer path. Acquires exclusive database execution in writer-priority order. Holding the turnstile while waiting for `roomEmpty` blocks newly arriving readers, so a sustained read workload cannot starve mutations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L763)

<a id="function-function-minisql-server-database-manager-enterexecutioncontrolled-function-enterexecutioncontrolled-database-sessionid-src-minisql-server-database-manager-ml-594284070"></a>
### enterExecutionControlled

```ml
function enterExecutionControlled(database, sessionId)
```

Cancellation-aware exclusive admission. The writer retains turnstile while waiting for readers to leave, preserving writer priority between timed polls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L778)

<a id="function-function-minisql-server-database-manager-enterreadexecution-function-enterreadexecution-database-src-minisql-server-database-manager-ml-1522272589"></a>
### enterReadExecution

```ml
function enterReadExecution(database)
```

Admits one shared reader through the writer-priority turnstile. The first reader acquires `roomEmpty`; later readers only increment the protected count. Returns true or an unavailable/closed-gate error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L691)

<a id="function-function-minisql-server-database-manager-enterreadexecutioncontrolled-function-enterreadexecutioncontrolled-database-sessionid-src-minisql-server-database-manager-ml-1895639478"></a>
### enterReadExecutionControlled

```ml
function enterReadExecutionControlled(database, sessionId)
```

Cancellation-aware shared-gate admission for SQL statements. Short timed waits keep administrative cancellation and the absolute statement deadline observable even while a writer currently owns the physical database gate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L713)

- [minisql.server.database_manager.ExecutionGate](Type-minisql-server-database-manager-executiongate-385130889.md) — struct
<a id="function-function-minisql-server-database-manager-fail-function-fail-code-operation-message-src-minisql-server-database-manager-ml-135974469"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql server database manager module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L317)

<a id="function-function-minisql-server-database-manager-findtable-function-findtable-database-name-src-minisql-server-database-manager-ml-1903622680"></a>
### findTable

```ml
function findTable(database, name)
```

Finds table using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1830)

<a id="function-function-minisql-server-database-manager-finishoperationalstatement-function-finishoperationalstatement-database-sessionid-success-rowcount-src-minisql-server-database-manager-ml-1392504750"></a>
### finishOperationalStatement

```ml
function finishOperationalStatement(database, sessionId, success, rowCount)
```

Completes one operational statement and advances cumulative counters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `success` | `dynamic` | — | success value consumed by this operation. |
| `rowCount` | `dynamic` | — | Number of row to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1476)

<a id="function-function-minisql-server-database-manager-finishstatement-function-finishstatement-database-lease-src-minisql-server-database-manager-ml-1274153445"></a>
### finishStatement

```ml
function finishStatement(database, lease)
```

Implements finish statement for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `lease` | `dynamic` | — | lease value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1710)

<a id="function-function-minisql-server-database-manager-idletimeoutms-function-idletimeoutms-database-src-minisql-server-database-manager-ml-426767567"></a>
### idleTimeoutMs

```ml
function idleTimeoutMs(database)
```

Returns the configured idle-connection timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1347)

<a id="function-function-minisql-server-database-manager-indexesready-function-indexesready-database-src-minisql-server-database-manager-ml-1712937393"></a>
### indexesReady

```ml
function indexesReady(database)
```

Returns whether the one-time process-local index readiness pass completed. The execution-gate state lock makes this probe safe during concurrent accepts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1627)

<a id="constant-constant-minisql-server-database-manager-invalid-argument-const-invalid-argument-9001-src-minisql-server-database-manager-ml-1730538539"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L32)

<a id="function-function-minisql-server-database-manager-invalidatereadcache-function-invalidatereadcache-database-src-minisql-server-database-manager-ml-918297051"></a>
### invalidateReadCache

```ml
function invalidateReadCache(database)
```

Invalidates committed page images after a successful mutation. The caller holds exclusive execution, so no reader can observe a stale/new mixture.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1882)

<a id="function-function-minisql-server-database-manager-invalidatereadhandles-function-invalidatereadhandles-database-src-minisql-server-database-manager-ml-1609019581"></a>
### invalidateReadHandles

```ml
function invalidateReadHandles(database)
```

Invalidates persistent file and metadata handles after any successful writer. The caller owns the database writer gate, so no active lease can race close.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L648)

<a id="function-function-minisql-server-database-manager-isimplemented-function-isimplemented-src-minisql-server-database-manager-ml-2067905176"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql server database manager module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1978)

<a id="function-function-minisql-server-database-manager-islockwaiting-function-islockwaiting-database-transactionid-src-minisql-server-database-manager-ml-1859443638"></a>
### isLockWaiting

```ml
function isLockWaiting(database, transactionId)
```

Returns whether a transaction is still blocked in the logical lock graph. Listener workers use this probe to wait without reparsing or re-executing SQL.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1749)

<a id="function-function-minisql-server-database-manager-ismanageddatabase-function-ismanageddatabase-value-src-minisql-server-database-manager-ml-186633161"></a>
### isManagedDatabase

```ml
function isManagedDatabase(value)
```

Returns whether the supplied value satisfies the managed database condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L307)

<a id="function-function-minisql-server-database-manager-issessioncancellationrequested-function-issessioncancellationrequested-database-sessionid-src-minisql-server-database-manager-ml-729790150"></a>
### isSessionCancellationRequested

```ml
function isSessionCancellationRequested(database, sessionId)
```

Returns the synchronized cancellation flag polled by executor operators.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1568)

<a id="function-function-minisql-server-database-manager-isshutdownrequested-function-isshutdownrequested-database-src-minisql-server-database-manager-ml-1265970265"></a>
### isShutdownRequested

```ml
function isShutdownRequested(database)
```

Returns whether an administrator requested cooperative listener shutdown.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1615)

<a id="function-function-minisql-server-database-manager-isstandby-function-isstandby-database-src-minisql-server-database-manager-ml-325508019"></a>
### isStandby

```ml
function isStandby(database)
```

Returns whether the supplied value satisfies the standby condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1820)

<a id="constant-constant-minisql-server-database-manager-leader-epoch-bytes-const-leader-epoch-bytes-32-src-minisql-server-database-manager-ml-1346413530"></a>
### LEADER_EPOCH_BYTES

```ml
const LEADER_EPOCH_BYTES = 32
```

Defines the leader epoch bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L72)

<a id="constant-constant-minisql-server-database-manager-leader-lease-bytes-const-leader-lease-bytes-64-src-minisql-server-database-manager-ml-1845112381"></a>
### LEADER_LEASE_BYTES

```ml
const LEADER_LEASE_BYTES = 64
```

Defines the leader lease bytes constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L74)

<a id="function-function-minisql-server-database-manager-leaderepochpath-function-leaderepochpath-path-src-minisql-server-database-manager-ml-609038073"></a>
### leaderEpochPath

```ml
function leaderEpochPath(path)
```

Returns the durable per-database leadership-term record path. The HA controller replaces this record while the database is offline before it starts a process for a newer epoch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L340)

<a id="function-function-minisql-server-database-manager-leaveexecution-function-leaveexecution-database-src-minisql-server-database-manager-ml-930930397"></a>
### leaveExecution

```ml
function leaveExecution(database)
```

Releases exclusive database execution, opening the room before the turnstile. Returns an error if either synchronization primitive cannot be released.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L795)

<a id="function-function-minisql-server-database-manager-leavereadexecution-function-leavereadexecution-database-src-minisql-server-database-manager-ml-615932341"></a>
### leaveReadExecution

```ml
function leaveReadExecution(database)
```

Removes one shared reader and releases `roomEmpty` when the last reader exits. Returns an error for an invalid database, unavailable lock, or unbalanced leave.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L742)

- [minisql.server.database_manager.ManagedDatabase](Type-minisql-server-database-manager-manageddatabase-1773265508.md) — struct
<a id="function-function-minisql-server-database-manager-markindexesready-function-markindexesready-database-src-minisql-server-database-manager-ml-6030617"></a>
### markIndexesReady

```ml
function markIndexesReady(database)
```

Publishes completion of process-local index readiness to later sessions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1637)

<a id="function-function-minisql-server-database-manager-maxframebytes-function-maxframebytes-database-src-minisql-server-database-manager-ml-648575145"></a>
### maxFrameBytes

```ml
function maxFrameBytes(database)
```

Returns the configured hard response-frame limit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1333)

<a id="function-function-minisql-server-database-manager-maxresultbytes-function-maxresultbytes-database-src-minisql-server-database-manager-ml-1979174281"></a>
### maxResultBytes

```ml
function maxResultBytes(database)
```

Returns the aggregate encoded result byte ceiling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1361)

<a id="function-function-minisql-server-database-manager-maxresultrows-function-maxresultrows-database-src-minisql-server-database-manager-ml-25154889"></a>
### maxResultRows

```ml
function maxResultRows(database)
```

Returns the configured hard result-row limit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1340)

<a id="function-function-minisql-server-database-manager-maxstatementbytes-function-maxstatementbytes-database-src-minisql-server-database-manager-ml-1165713673"></a>
### maxStatementBytes

```ml
function maxStatementBytes(database)
```

Returns the configured hard statement-size limit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1326)

<a id="function-function-minisql-server-database-manager-open-function-open-path-src-minisql-server-database-manager-ml-737630767"></a>
### open

```ml
function open(path)
```

Opens open for the minisql server database manager module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1111)

<a id="function-function-minisql-server-database-manager-openinternal-function-openinternal-path-allowstandby-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-database-manager-ml-342255397"></a>
### openInternal

```ml
function openInternal(path, allowStandby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Opens internal using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `allowStandby` | `dynamic` | — | allowStandby value consumed by this operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |
| `bufferPoolBytes` | `dynamic` | — | bufferPoolBytes value consumed by this operation. |
| `queryMemoryBytes` | `dynamic` | — | queryMemoryBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L855)

<a id="function-function-minisql-server-database-manager-openstandby-function-openstandby-path-src-minisql-server-database-manager-ml-1858909533"></a>
### openStandby

```ml
function openStandby(path)
```

Opens standby using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1143)

<a id="function-function-minisql-server-database-manager-openstandbywithbudgets-function-openstandbywithbudgets-path-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-database-manager-ml-1280297299"></a>
### openStandbyWithBudgets

```ml
function openStandbyWithBudgets(path, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Opens a standby database with explicit WAL, cache, and per-query budgets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |
| `bufferPoolBytes` | `dynamic` | — | bufferPoolBytes value consumed by this operation. |
| `queryMemoryBytes` | `dynamic` | — | queryMemoryBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1168)

<a id="function-function-minisql-server-database-manager-openstandbywithcheckpoint-function-openstandbywithcheckpoint-path-checkpointwalbytes-src-minisql-server-database-manager-ml-864524504"></a>
### openStandbyWithCheckpoint

```ml
function openStandbyWithCheckpoint(path, checkpointWalBytes)
```

Opens a standby with the configured checkpoint threshold. Standbys never initiate a reset, but retaining the value keeps promotion configuration exact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1151)

<a id="function-function-minisql-server-database-manager-openstandbywithruntime-function-openstandbywithruntime-path-checkpointwalbytes-bufferpoolbytes-src-minisql-server-database-manager-ml-609454305"></a>
### openStandbyWithRuntime

```ml
function openStandbyWithRuntime(path, checkpointWalBytes, bufferPoolBytes)
```

Opens a standby with configured WAL and buffer-pool budgets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |
| `bufferPoolBytes` | `dynamic` | — | bufferPoolBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1159)

<a id="function-function-minisql-server-database-manager-openwithbudgets-function-openwithbudgets-path-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-database-manager-ml-179142775"></a>
### openWithBudgets

```ml
function openWithBudgets(path, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Opens a writable database with explicit WAL, cache, and per-query budgets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |
| `bufferPoolBytes` | `dynamic` | — | bufferPoolBytes value consumed by this operation. |
| `queryMemoryBytes` | `dynamic` | — | queryMemoryBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1135)

<a id="function-function-minisql-server-database-manager-openwithcheckpoint-function-openwithcheckpoint-path-checkpointwalbytes-src-minisql-server-database-manager-ml-73357826"></a>
### openWithCheckpoint

```ml
function openWithCheckpoint(path, checkpointWalBytes)
```

Opens a primary database with a configured maximum current-WAL size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1118)

<a id="function-function-minisql-server-database-manager-openwithruntime-function-openwithruntime-path-checkpointwalbytes-bufferpoolbytes-src-minisql-server-database-manager-ml-1223594185"></a>
### openWithRuntime

```ml
function openWithRuntime(path, checkpointWalBytes, bufferPoolBytes)
```

Opens a primary database with configured WAL and buffer-pool budgets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `checkpointWalBytes` | `dynamic` | — | checkpointWalBytes value consumed by this operation. |
| `bufferPoolBytes` | `dynamic` | — | bufferPoolBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1126)

- [minisql.server.database_manager.OperationalSession](Type-minisql-server-database-manager-operationalsession-1915062952.md) — struct
<a id="function-function-minisql-server-database-manager-operationalsessions-function-operationalsessions-database-src-minisql-server-database-manager-ml-1443595955"></a>
### operationalSessions

```ml
function operationalSessions(database)
```

Returns immutable copies of all active process-list entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1507)

<a id="function-function-minisql-server-database-manager-operationalstatus-function-operationalstatus-database-src-minisql-server-database-manager-ml-1623327153"></a>
### operationalStatus

```ml
function operationalStatus(database)
```

Returns a compact numeric snapshot used by SHOW STATUS.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1520)

<a id="function-function-minisql-server-database-manager-peakconcurrentreaders-function-peakconcurrentreaders-database-src-minisql-server-database-manager-ml-1304322137"></a>
### peakConcurrentReaders

```ml
function peakConcurrentReaders(database)
```

Implements peak concurrent readers for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L808)

<a id="function-function-minisql-server-database-manager-planninggeneration-function-planninggeneration-database-src-minisql-server-database-manager-ml-2123825853"></a>
### planningGeneration

```ml
function planningGeneration(database)
```

Returns the process-local optimizer invalidation generation shared by every session attached to this managed database.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1648)

<a id="function-function-minisql-server-database-manager-pollsessioncontrol-function-pollsessioncontrol-database-sessionid-src-minisql-server-database-manager-ml-939367718"></a>
### pollSessionControl

```ml
function pollSessionControl(database, sessionId)
```

Polls the registry without depending on executor-owned state. Storage batch loops use this to stop long scans at page/row boundaries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1583)

<a id="function-function-minisql-server-database-manager-publishreadhandlelease-function-publishreadhandlelease-cache-entry-src-minisql-server-database-manager-ml-1264777182"></a>
### publishReadHandleLease

```ml
function publishReadHandleLease(cache, entry)
```

Records one lease while the registry guard is held and returns its token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — | cache value consumed by this operation. |
| `entry` | `dynamic` | — | entry value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L571)

<a id="constant-constant-minisql-server-database-manager-query-cancelled-const-query-cancelled-9035-src-minisql-server-database-manager-ml-1471689558"></a>
### QUERY_CANCELLED

```ml
const QUERY_CANCELLED = 9035
```

Defines the query cancelled constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L64)

<a id="constant-constant-minisql-server-database-manager-query-timeout-const-query-timeout-9036-src-minisql-server-database-manager-ml-2096549633"></a>
### QUERY_TIMEOUT

```ml
const QUERY_TIMEOUT = 9036
```

Defines the query timeout constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L66)

<a id="function-function-minisql-server-database-manager-querymemorylimit-function-querymemorylimit-database-src-minisql-server-database-manager-ml-754382457"></a>
### queryMemoryLimit

```ml
function queryMemoryLimit(database)
```

Returns the soft blocking-operator budget inherited by a new session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1174)

<a id="function-function-minisql-server-database-manager-querytimeoutms-function-querytimeoutms-database-src-minisql-server-database-manager-ml-1603275293"></a>
### queryTimeoutMs

```ml
function queryTimeoutMs(database)
```

Returns the cooperative execution deadline interval.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1354)

<a id="function-function-minisql-server-database-manager-readcachestats-function-readcachestats-database-src-minisql-server-database-manager-ml-578516013"></a>
### readCacheStats

```ml
function readCacheStats(database)
```

Returns synchronized buffer-cache diagnostics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1893)

<a id="function-function-minisql-server-database-manager-readercount-function-readercount-database-src-minisql-server-database-manager-ml-1282915241"></a>
### readerCount

```ml
function readerCount(database)
```

Implements reader count for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1776)

<a id="function-function-minisql-server-database-manager-readfencebytes-function-readfencebytes-path-expectedsize-operation-src-minisql-server-database-manager-ml-1148460563"></a>
### readFenceBytes

```ml
function readFenceBytes(path, expectedSize, operation)
```

Reads one exact fencing record without accepting a prefix, trailing bytes, or a partially replaced file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `expectedSize` | `dynamic` | — | expectedSize value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L349)

- [minisql.server.database_manager.ReadHandleCache](Type-minisql-server-database-manager-readhandlecache-2045555224.md) — struct
- [minisql.server.database_manager.ReadHandleCacheStats](Type-minisql-server-database-manager-readhandlecachestats-905434043.md) — struct
<a id="function-function-minisql-server-database-manager-readhandlecontext-function-readhandlecontext-lease-src-minisql-server-database-manager-ml-1816157088"></a>
### readHandleContext

```ml
function readHandleContext(lease)
```

Returns one context reused by every page read in this handle lease. Table scans that remain entirely in the buffer pool never allocate the context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — | lease value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L525)

- [minisql.server.database_manager.ReadHandleLease](Type-minisql-server-database-manager-readhandlelease-1175511288.md) — struct
<a id="function-function-minisql-server-database-manager-readhandlestats-function-readhandlestats-database-src-minisql-server-database-manager-ml-1889147495"></a>
### readHandleStats

```ml
function readHandleStats(database)
```

Returns synchronized persistent-handle cache counters.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L660)

<a id="function-function-minisql-server-database-manager-readhandlevalue-function-readhandlevalue-lease-src-minisql-server-database-manager-ml-1438398172"></a>
### readHandleValue

```ml
function readHandleValue(lease)
```

Validates a caller lease and returns its storage value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — | lease value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L517)

<a id="function-function-minisql-server-database-manager-readleaderepoch-function-readleaderepoch-path-src-minisql-server-database-manager-ml-272366675"></a>
### readLeaderEpoch

```ml
function readLeaderEpoch(path)
```

Decodes the persistent database term and node identity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L382)

<a id="function-function-minisql-server-database-manager-readleaderlease-function-readleaderlease-path-src-minisql-server-database-manager-ml-1186030409"></a>
### readLeaderLease

```ml
function readLeaderLease(path)
```

Decodes the shared leader lease used as the online write-authority token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L395)

<a id="function-function-minisql-server-database-manager-recordstatementdiagnostics-function-recordstatementdiagnostics-database-elapsedms-resultbytes-errorcode-src-minisql-server-database-manager-ml-2139957964"></a>
### recordStatementDiagnostics

```ml
function recordStatementDiagnostics(database, elapsedMs, resultBytes, errorCode)
```

Records latency, encoded output, and terminal production-control outcomes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `elapsedMs` | `dynamic` | — | elapsedMs value consumed by this operation. |
| `resultBytes` | `dynamic` | — | resultBytes value consumed by this operation. |
| `errorCode` | `dynamic` | — | errorCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1535)

<a id="function-function-minisql-server-database-manager-refreshschemasnapshot-function-refreshschemasnapshot-database-src-minisql-server-database-manager-ml-1990122817"></a>
### refreshSchemaSnapshot

```ml
function refreshSchemaSnapshot(database)
```

Reloads and atomically publishes durable schema metadata after successful DDL. The relatively expensive file validation therefore occurs once per schema change instead of once per query or affected row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1672)

<a id="function-function-minisql-server-database-manager-registersessionpeer-function-registersessionpeer-database-sessionid-peerendpoint-secure-authenticated-src-minisql-server-database-manager-ml-846329239"></a>
### registerSessionPeer

```ml
function registerSessionPeer(database, sessionId, peerEndpoint, secure, authenticated)
```

Updates connection metadata after the listener resolves the remote endpoint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `peerEndpoint` | `dynamic` | — | peerEndpoint value consumed by this operation. |
| `secure` | `dynamic` | — | secure value consumed by this operation. |
| `authenticated` | `dynamic` | — | authenticated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1425)

<a id="function-function-minisql-server-database-manager-releaselocks-function-releaselocks-database-transactionid-src-minisql-server-database-manager-ml-1667334502"></a>
### releaseLocks

```ml
function releaseLocks(database, transactionId)
```

Releases locks using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1730)

<a id="function-function-minisql-server-database-manager-releasereadhandle-function-releasereadhandle-lease-src-minisql-server-database-manager-ml-1605521988"></a>
### releaseReadHandle

```ml
function releaseReadHandle(lease)
```

Releases one table or index lease after the complete storage operation. The owning execution-gate read lease prevents concurrent invalidation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lease` | `dynamic` | — | lease value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L554)

<a id="function-function-minisql-server-database-manager-releasetemporarystorage-function-releasetemporarystorage-database-bytecount-src-minisql-server-database-manager-ml-43073184"></a>
### releaseTemporaryStorage

```ml
function releaseTemporaryStorage(database, byteCount)
```

Releases a prior spill reservation; cleanup is idempotent at zero.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `byteCount` | `dynamic` | — | Number of byte to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1409)

<a id="function-function-minisql-server-database-manager-requestsessioncancellation-function-requestsessioncancellation-database-sessionid-src-minisql-server-database-manager-ml-1396021146"></a>
### requestSessionCancellation

```ml
function requestSessionCancellation(database, sessionId)
```

Requests cancellation of one currently executing session.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1552)

<a id="function-function-minisql-server-database-manager-requestshutdown-function-requestshutdown-database-src-minisql-server-database-manager-ml-961217527"></a>
### requestShutdown

```ml
function requestShutdown(database)
```

Requests a cooperative listener stop after the current statement response.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1605)

<a id="function-function-minisql-server-database-manager-reservetemporarystorage-function-reservetemporarystorage-database-bytecount-src-minisql-server-database-manager-ml-1873353186"></a>
### reserveTemporaryStorage

```ml
function reserveTemporaryStorage(database, byteCount)
```

Reserves spill capacity atomically across all concurrent statements.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `byteCount` | `dynamic` | — | Number of byte to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1392)

<a id="function-function-minisql-server-database-manager-resetpeakconcurrentreaders-function-resetpeakconcurrentreaders-database-src-minisql-server-database-manager-ml-156920753"></a>
### resetPeakConcurrentReaders

```ml
function resetPeakConcurrentReaders(database)
```

Resets peak concurrent readers using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L833)

<a id="constant-constant-minisql-server-database-manager-resource-limit-const-resource-limit-9037-src-minisql-server-database-manager-ml-1816069710"></a>
### RESOURCE_LIMIT

```ml
const RESOURCE_LIMIT = 9037
```

Defines the resource limit constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L68)

<a id="function-function-minisql-server-database-manager-rotateaudit-function-rotateaudit-database-sessionid-principalid-src-minisql-server-database-manager-ml-890621"></a>
### rotateAudit

```ml
function rotateAudit(database, sessionId, principalId)
```

Implements rotate audit for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1801)

<a id="function-function-minisql-server-database-manager-schemasnapshot-function-schemasnapshot-database-src-minisql-server-database-manager-ml-1469614845"></a>
### schemaSnapshot

```ml
function schemaSnapshot(database)
```

Returns the immutable schema snapshot published for this database. Schema states are never modified after publication, so readers may safely retain the returned value for the duration of their physical execution-gate lease.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1660)

<a id="function-function-minisql-server-database-manager-setoperationalprincipal-function-setoperationalprincipal-database-sessionid-principalid-src-minisql-server-database-manager-ml-1754907365"></a>
### setOperationalPrincipal

```ml
function setOperationalPrincipal(database, sessionId, principalId)
```

Publishes the principal selected by a successful authentication exchange.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |
| `principalId` | `dynamic` | — | Identifier of principal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1443)

<a id="function-function-minisql-server-database-manager-setquerymemorylimit-function-setquerymemorylimit-database-querymemorybytes-src-minisql-server-database-manager-ml-417629779"></a>
### setQueryMemoryLimit

```ml
function setQueryMemoryLimit(database, queryMemoryBytes)
```

Configures the per-session query budget before a listener accepts clients.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `queryMemoryBytes` | `dynamic` | — | queryMemoryBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1182)

<a id="constant-constant-minisql-server-database-manager-standby-not-promoted-const-standby-not-promoted-9033-src-minisql-server-database-manager-ml-1725338562"></a>
### STANDBY_NOT_PROMOTED

```ml
const STANDBY_NOT_PROMOTED = 9033
```

Defines the standby not promoted constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L38)

<a id="function-function-minisql-server-database-manager-targetmilestone-function-targetmilestone-src-minisql-server-database-manager-ml-1590397494"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql server database manager module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1971)

<a id="function-function-minisql-server-database-manager-unregistersession-function-unregistersession-database-sessionid-src-minisql-server-database-manager-ml-1279373646"></a>
### unregisterSession

```ml
function unregisterSession(database, sessionId)
```

Removes a closed session from the process list without changing cumulative totals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `sessionId` | `dynamic` | — | Identifier of session. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1493)

<a id="function-function-minisql-server-database-manager-validatecheckpointmarker-function-validatecheckpointmarker-path-expected-src-minisql-server-database-manager-ml-481301675"></a>
### validateCheckpointMarker

```ml
function validateCheckpointMarker(path, expected)
```

Reads and validates a checkpoint marker before its state can affect recovery.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L439)

<a id="function-function-minisql-server-database-manager-validatefenceheader-function-validatefenceheader-payload-magic-expectedsize-operation-src-minisql-server-database-manager-ml-1668528269"></a>
### validateFenceHeader

```ml
function validateFenceHeader(payload, magic, expectedSize, operation)
```

Validates a fixed-size CRC-32C protected record header shared with the Python HA controller. The checksum field is always the final four bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `payload` | `dynamic` | — | payload value consumed by this operation. |
| `magic` | `dynamic` | — | magic value consumed by this operation. |
| `expectedSize` | `dynamic` | — | expectedSize value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L369)

<a id="function-function-minisql-server-database-manager-validateopen-function-validateopen-database-operation-src-minisql-server-database-manager-ml-694200926"></a>
### validateOpen

```ml
function validateOpen(database, operation)
```

Validates open for the minisql server database manager workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L490)

<a id="function-function-minisql-server-database-manager-validatewritefence-function-validatewritefence-database-src-minisql-server-database-manager-ml-1387252521"></a>
### validateWriteFence

```ml
function validateWriteFence(database)
```

Validates persistent and live leadership immediately before a mutation or durable commit. Missing, malformed, expired, foreign, and rolled-back terms all reject writes while reads and rollback remain available.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1222)

<a id="function-function-minisql-server-database-manager-verifyaudit-function-verifyaudit-database-src-minisql-server-database-manager-ml-1008732981"></a>
### verifyAudit

```ml
function verifyAudit(database)
```

Verifies audit using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1811)

<a id="function-function-minisql-server-database-manager-waitercount-function-waitercount-database-src-minisql-server-database-manager-ml-968716011"></a>
### waiterCount

```ml
function waiterCount(database)
```

Implements waiter count for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L1758)

<a id="function-function-minisql-server-database-manager-walepochpath-function-walepochpath-path-src-minisql-server-database-manager-ml-1572688611"></a>
### walEpochPath

```ml
function walEpochPath(path)
```

Returns the persistent marker path that selects bounded-WAL epoch recovery.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L409)

<a id="function-function-minisql-server-database-manager-walresetpendingpath-function-walresetpendingpath-path-src-minisql-server-database-manager-ml-2014514181"></a>
### walResetPendingPath

```ml
function walResetPendingPath(path)
```

Returns the transient crash-recovery journal for an in-progress WAL reset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L415)

<a id="constant-constant-minisql-server-database-manager-write-fenced-const-write-fenced-9038-src-minisql-server-database-manager-ml-126149299"></a>
### WRITE_FENCED

```ml
const WRITE_FENCED = 9038
```

Defines the write fenced constant used by the minisql server database manager module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L70)
