# `src/minisql/transaction/checkpoint.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.transaction.checkpoint`](Package-minisql-transaction-checkpoint-2107964044.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/superblock.ml` as `superblock` → [src/minisql/storage/superblock.ml](File-src-minisql-storage-superblock-ml-1268029913.md)
- `minisql/transaction/wal.ml` as `wal` → [src/minisql/transaction/wal.ml](File-src-minisql-transaction-wal-ml-860713478.md)

## Declarations

<a id="function-function-minisql-transaction-checkpoint-beginwalcheckpoint-function-beginwalcheckpoint-log-checkpointid-src-minisql-transaction-checkpoint-ml-1059230563"></a>
### beginWalCheckpoint

```ml
function beginWalCheckpoint(log, checkpointId)
```

Begins the wal checkpoint. Inputs: `log`, `checkpointId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — |  |
| `checkpointId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L268)

<a id="function-function-minisql-transaction-checkpoint-bytesequal-function-bytesequal-left-right-src-minisql-transaction-checkpoint-ml-179775275"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L83)

- [minisql.transaction.checkpoint.CheckpointFile](Type-minisql-transaction-checkpoint-checkpointfile-1475200366.md) — struct
- [minisql.transaction.checkpoint.CheckpointMetadata](Type-minisql-transaction-checkpoint-checkpointmetadata-275933805.md) — struct
<a id="constant-constant-minisql-transaction-checkpoint-checksum-offset-const-checksum-offset-64-src-minisql-transaction-checkpoint-ml-389063961"></a>
### CHECKSUM_OFFSET

```ml
const CHECKSUM_OFFSET = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L29)

<a id="function-function-minisql-transaction-checkpoint-choose-function-choose-firstresult-secondresult-src-minisql-transaction-checkpoint-ml-1227770978"></a>
### choose

```ml
function choose(firstResult, secondResult)
```

Performs the choose operation for this module. Inputs: `firstResult`, `secondResult`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `firstResult` | `dynamic` | — |  |
| `secondResult` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L199)

<a id="function-function-minisql-transaction-checkpoint-close-function-close-checkpointfile-src-minisql-transaction-checkpoint-ml-1754047644"></a>
### close

```ml
function close(checkpointFile)
```

Closes the requested value. Inputs: `checkpointFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L295)

<a id="constant-constant-minisql-transaction-checkpoint-closed-handle-const-closed-handle-9008-src-minisql-transaction-checkpoint-ml-2004125754"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L20)

<a id="function-function-minisql-transaction-checkpoint-completewalcheckpoint-function-completewalcheckpoint-log-checkpointfile-checkpointid-redostartlsn-recordcount-src-minisql-transaction-checkpoint-ml-852147306"></a>
### completeWalCheckpoint

```ml
function completeWalCheckpoint(log, checkpointFile, checkpointId, redoStartLsn, recordCount)
```

Performs the complete wal checkpoint operation for this module. Inputs: `log`, `checkpointFile`, `checkpointId`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — |  |
| `checkpointFile` | `dynamic` | — |  |
| `checkpointId` | `dynamic` | — |  |
| `redoStartLsn` | `dynamic` | — |  |
| `recordCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L274)

<a id="function-function-minisql-transaction-checkpoint-componentname-function-componentname-src-minisql-transaction-checkpoint-ml-172726536"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L304)

<a id="function-function-minisql-transaction-checkpoint-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-transaction-checkpoint-ml-2099695941"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Copies the exact. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — |  |
| `destinationOffset` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `sourceOffset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L73)

<a id="constant-constant-minisql-transaction-checkpoint-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-checkpoint-ml-1210441576"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L19)

<a id="function-function-minisql-transaction-checkpoint-create-function-create-path-databaseid-src-minisql-transaction-checkpoint-ml-1463417473"></a>
### create

```ml
function create(path, databaseId)
```

Creates the requested value. Inputs: `path`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L219)

<a id="function-function-minisql-transaction-checkpoint-decodenative-function-decodenative-words-operation-name-src-minisql-transaction-checkpoint-ml-2092959195"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes the native. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L108)

<a id="function-function-minisql-transaction-checkpoint-decodeslot-function-decodeslot-source-src-minisql-transaction-checkpoint-ml-1969868543"></a>
### decodeSlot

```ml
function decodeSlot(source)
```

Decodes the slot. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L148)

<a id="function-function-minisql-transaction-checkpoint-encodeslot-function-encodeslot-value-src-minisql-transaction-checkpoint-ml-471548411"></a>
### encodeSlot

```ml
function encodeSlot(value)
```

Encodes the slot. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L127)

<a id="function-function-minisql-transaction-checkpoint-fail-function-fail-code-operation-message-src-minisql-transaction-checkpoint-ml-17392655"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L61)

<a id="constant-constant-minisql-transaction-checkpoint-file-size-const-file-size-512-src-minisql-transaction-checkpoint-ml-618877159"></a>
### FILE_SIZE

```ml
const FILE_SIZE = 512
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L28)

<a id="constant-constant-minisql-transaction-checkpoint-format-version-const-format-version-1-src-minisql-transaction-checkpoint-ml-71751766"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L22)

<a id="constant-constant-minisql-transaction-checkpoint-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-checkpoint-ml-941936781"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Durable checkpoint metadata and orchestration. A checkpoint flushes dirty database pages before publishing the WAL boundary from which crash recovery may safely resume.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L17)

<a id="function-function-minisql-transaction-checkpoint-isimplemented-function-isimplemented-src-minisql-transaction-checkpoint-ml-659723536"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L316)

<a id="function-function-minisql-transaction-checkpoint-magicbytes-function-magicbytes-src-minisql-transaction-checkpoint-ml-969017320"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magic bytes operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L67)

<a id="function-function-minisql-transaction-checkpoint-newmetadata-function-newmetadata-generation-checkpointlsn-redostartlsn-recordcount-databaseid-src-minisql-transaction-checkpoint-ml-1870545986"></a>
### newMetadata

```ml
function newMetadata(generation, checkpointLsn, redoStartLsn, recordCount, databaseId)
```

Performs the new metadata operation for this module. Inputs: `generation`, `checkpointLsn`, `redoStartLsn`, `recordCount`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `generation` | `dynamic` | — |  |
| `checkpointLsn` | `dynamic` | — |  |
| `redoStartLsn` | `dynamic` | — |  |
| `recordCount` | `dynamic` | — |  |
| `databaseId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L115)

<a id="function-function-minisql-transaction-checkpoint-open-function-open-path-src-minisql-transaction-checkpoint-ml-518534133"></a>
### open

```ml
function open(path)
```

Opens the requested value. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L232)

<a id="function-function-minisql-transaction-checkpoint-perform-function-perform-log-checkpointfile-checkpointid-pagedfiles-redostartlsn-src-minisql-transaction-checkpoint-ml-2046176022"></a>
### perform

```ml
function perform(log, checkpointFile, checkpointId, pagedFiles, redoStartLsn)
```

Performs the perform operation for this module. Inputs: `log`, `checkpointFile`, `checkpointId`, `pagedFiles`, `redoStartLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — |  |
| `checkpointFile` | `dynamic` | — |  |
| `checkpointId` | `dynamic` | — |  |
| `pagedFiles` | `dynamic` | — |  |
| `redoStartLsn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L282)

<a id="function-function-minisql-transaction-checkpoint-publish-function-publish-checkpointfile-checkpointlsn-redostartlsn-recordcount-src-minisql-transaction-checkpoint-ml-105464480"></a>
### publish

```ml
function publish(checkpointFile, checkpointLsn, redoStartLsn, recordCount)
```

Performs the publish operation for this module. Inputs: `checkpointFile`, `checkpointLsn`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — |  |
| `checkpointLsn` | `dynamic` | — |  |
| `redoStartLsn` | `dynamic` | — |  |
| `recordCount` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L253)

<a id="function-function-minisql-transaction-checkpoint-readslot-function-readslot-file-slot-src-minisql-transaction-checkpoint-ml-2118763782"></a>
### readSlot

```ml
function readSlot(file, slot)
```

Reads the slot. Inputs: `file`, `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `slot` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L183)

<a id="constant-constant-minisql-transaction-checkpoint-slot-a-const-slot-a-0-src-minisql-transaction-checkpoint-ml-1498131313"></a>
### SLOT_A

```ml
const SLOT_A = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L24)

<a id="constant-constant-minisql-transaction-checkpoint-slot-a-offset-const-slot-a-offset-0-src-minisql-transaction-checkpoint-ml-1753449983"></a>
### SLOT_A_OFFSET

```ml
const SLOT_A_OFFSET = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L26)

<a id="constant-constant-minisql-transaction-checkpoint-slot-b-const-slot-b-1-src-minisql-transaction-checkpoint-ml-1958200604"></a>
### SLOT_B

```ml
const SLOT_B = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L25)

<a id="constant-constant-minisql-transaction-checkpoint-slot-b-offset-const-slot-b-offset-256-src-minisql-transaction-checkpoint-ml-1421527066"></a>
### SLOT_B_OFFSET

```ml
const SLOT_B_OFFSET = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L27)

<a id="constant-constant-minisql-transaction-checkpoint-slot-size-const-slot-size-256-src-minisql-transaction-checkpoint-ml-1160274022"></a>
### SLOT_SIZE

```ml
const SLOT_SIZE = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L23)

<a id="function-function-minisql-transaction-checkpoint-slotoffset-function-slotoffset-slot-src-minisql-transaction-checkpoint-ml-1104826312"></a>
### slotOffset

```ml
function slotOffset(slot)
```

Performs the slot offset operation for this module. Inputs: `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L175)

<a id="function-function-minisql-transaction-checkpoint-targetmilestone-function-targetmilestone-src-minisql-transaction-checkpoint-ml-1685547750"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L310)

<a id="constant-constant-minisql-transaction-checkpoint-unsupported-format-const-unsupported-format-9003-src-minisql-transaction-checkpoint-ml-2021314619"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L18)

<a id="function-function-minisql-transaction-checkpoint-validatedatabaseid-function-validatedatabaseid-databaseid-operation-src-minisql-transaction-checkpoint-ml-105316383"></a>
### validateDatabaseId

```ml
function validateDatabaseId(databaseId, operation)
```

Validates the database id. Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L101)

<a id="function-function-minisql-transaction-checkpoint-validatenative-function-validatenative-value-operation-name-src-minisql-transaction-checkpoint-ml-2096759679"></a>
### validateNative

```ml
function validateNative(value, operation, name)
```

Validates the native. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L94)

<a id="function-function-minisql-transaction-checkpoint-validateopen-function-validateopen-checkpointfile-operation-src-minisql-transaction-checkpoint-ml-1272704327"></a>
### validateOpen

```ml
function validateOpen(checkpointFile, operation)
```

Validates the open. Inputs: `checkpointFile`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L245)

<a id="function-function-minisql-transaction-checkpoint-writeslot-function-writeslot-file-slot-value-src-minisql-transaction-checkpoint-ml-2090083399"></a>
### writeSlot

```ml
function writeSlot(file, slot, value)
```

Writes the slot. Inputs: `file`, `slot`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — |  |
| `slot` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L191)
