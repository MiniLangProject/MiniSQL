# `src/minisql/transaction/checkpoint.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql transaction checkpoint facilities for this project.

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
| `log` | `dynamic` | — | log value consumed by this operation. |
| `checkpointId` | `dynamic` | — | Identifier of checkpoint. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L323)

<a id="function-function-minisql-transaction-checkpoint-bytesequal-function-bytesequal-left-right-src-minisql-transaction-checkpoint-ml-179775275"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql transaction checkpoint module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L104)

- [minisql.transaction.checkpoint.CheckpointFile](Type-minisql-transaction-checkpoint-checkpointfile-1475200366.md) — struct
- [minisql.transaction.checkpoint.CheckpointMetadata](Type-minisql-transaction-checkpoint-checkpointmetadata-275933805.md) — struct
<a id="constant-constant-minisql-transaction-checkpoint-checksum-offset-const-checksum-offset-64-src-minisql-transaction-checkpoint-ml-389063961"></a>
### CHECKSUM_OFFSET

```ml
const CHECKSUM_OFFSET = 64
```

Defines the checksum offset constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L40)

<a id="function-function-minisql-transaction-checkpoint-choose-function-choose-firstresult-secondresult-src-minisql-transaction-checkpoint-ml-1227770978"></a>
### choose

```ml
function choose(firstResult, secondResult)
```

Performs the choose operation for this module. Inputs: `firstResult`, `secondResult`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `firstResult` | `dynamic` | — | firstResult value consumed by this operation. |
| `secondResult` | `dynamic` | — | secondResult value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L243)

<a id="function-function-minisql-transaction-checkpoint-close-function-close-checkpointfile-src-minisql-transaction-checkpoint-ml-1754047644"></a>
### close

```ml
function close(checkpointFile)
```

Closes close owned by the minisql transaction checkpoint module. Inputs: `checkpointFile`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — | checkpointFile value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L361)

<a id="constant-constant-minisql-transaction-checkpoint-closed-handle-const-closed-handle-9008-src-minisql-transaction-checkpoint-ml-2004125754"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L23)

<a id="function-function-minisql-transaction-checkpoint-completewalcheckpoint-function-completewalcheckpoint-log-checkpointfile-checkpointid-redostartlsn-recordcount-src-minisql-transaction-checkpoint-ml-852147306"></a>
### completeWalCheckpoint

```ml
function completeWalCheckpoint(log, checkpointFile, checkpointId, redoStartLsn, recordCount)
```

Performs the complete wal checkpoint operation for this module. Inputs: `log`, `checkpointFile`, `checkpointId`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `checkpointFile` | `dynamic` | — | checkpointFile value consumed by this operation. |
| `checkpointId` | `dynamic` | — | Identifier of checkpoint. |
| `redoStartLsn` | `dynamic` | — | redoStartLsn value consumed by this operation. |
| `recordCount` | `dynamic` | — | Number of record to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L334)

<a id="function-function-minisql-transaction-checkpoint-componentname-function-componentname-src-minisql-transaction-checkpoint-ml-172726536"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql transaction checkpoint module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L370)

<a id="function-function-minisql-transaction-checkpoint-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-transaction-checkpoint-ml-2099695941"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Performs the copyExact operation for the minisql transaction checkpoint module. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L92)

<a id="constant-constant-minisql-transaction-checkpoint-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-checkpoint-ml-1210441576"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L21)

<a id="function-function-minisql-transaction-checkpoint-create-function-create-path-databaseid-src-minisql-transaction-checkpoint-ml-1463417473"></a>
### create

```ml
function create(path, databaseId)
```

Creates create for the minisql transaction checkpoint module. Inputs: `path`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L265)

<a id="function-function-minisql-transaction-checkpoint-decodenative-function-decodenative-words-operation-name-src-minisql-transaction-checkpoint-ml-2092959195"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes native for the minisql transaction checkpoint workflow. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | words value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L137)

<a id="function-function-minisql-transaction-checkpoint-decodeslot-function-decodeslot-source-src-minisql-transaction-checkpoint-ml-1969868543"></a>
### decodeSlot

```ml
function decodeSlot(source)
```

Decodes the slot. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L184)

<a id="function-function-minisql-transaction-checkpoint-encodeslot-function-encodeslot-value-src-minisql-transaction-checkpoint-ml-471548411"></a>
### encodeSlot

```ml
function encodeSlot(value)
```

Encodes the slot. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L162)

<a id="function-function-minisql-transaction-checkpoint-fail-function-fail-code-operation-message-src-minisql-transaction-checkpoint-ml-17392655"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql transaction checkpoint module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L75)

<a id="constant-constant-minisql-transaction-checkpoint-file-size-const-file-size-512-src-minisql-transaction-checkpoint-ml-618877159"></a>
### FILE_SIZE

```ml
const FILE_SIZE = 512
```

Defines the file size constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L38)

<a id="constant-constant-minisql-transaction-checkpoint-format-version-const-format-version-1-src-minisql-transaction-checkpoint-ml-71751766"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```

Defines the format version constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L26)

<a id="constant-constant-minisql-transaction-checkpoint-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-checkpoint-ml-941936781"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Durable checkpoint metadata and orchestration. A checkpoint flushes dirty


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L17)

<a id="function-function-minisql-transaction-checkpoint-isimplemented-function-isimplemented-src-minisql-transaction-checkpoint-ml-659723536"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql transaction checkpoint module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L382)

<a id="function-function-minisql-transaction-checkpoint-magicbytes-function-magicbytes-src-minisql-transaction-checkpoint-ml-969017320"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magicBytes operation for the minisql transaction checkpoint module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L81)

<a id="function-function-minisql-transaction-checkpoint-newmetadata-function-newmetadata-generation-checkpointlsn-redostartlsn-recordcount-databaseid-src-minisql-transaction-checkpoint-ml-1870545986"></a>
### newMetadata

```ml
function newMetadata(generation, checkpointLsn, redoStartLsn, recordCount, databaseId)
```

Performs the new metadata operation for this module. Inputs: `generation`, `checkpointLsn`, `redoStartLsn`, `recordCount`, `databaseId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `generation` | `dynamic` | — | generation value consumed by this operation. |
| `checkpointLsn` | `dynamic` | — | checkpointLsn value consumed by this operation. |
| `redoStartLsn` | `dynamic` | — | redoStartLsn value consumed by this operation. |
| `recordCount` | `dynamic` | — | Number of record to process. |
| `databaseId` | `dynamic` | — | Identifier of database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L149)

<a id="function-function-minisql-transaction-checkpoint-open-function-open-path-src-minisql-transaction-checkpoint-ml-518534133"></a>
### open

```ml
function open(path)
```

Opens open for the minisql transaction checkpoint module. Inputs: `path`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L279)

<a id="function-function-minisql-transaction-checkpoint-perform-function-perform-log-checkpointfile-checkpointid-pagedfiles-redostartlsn-src-minisql-transaction-checkpoint-ml-2046176022"></a>
### perform

```ml
function perform(log, checkpointFile, checkpointId, pagedFiles, redoStartLsn)
```

Performs the perform operation for this module. Inputs: `log`, `checkpointFile`, `checkpointId`, `pagedFiles`, `redoStartLsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `log` | `dynamic` | — | log value consumed by this operation. |
| `checkpointFile` | `dynamic` | — | checkpointFile value consumed by this operation. |
| `checkpointId` | `dynamic` | — | Identifier of checkpoint. |
| `pagedFiles` | `dynamic` | — | pagedFiles value consumed by this operation. |
| `redoStartLsn` | `dynamic` | — | redoStartLsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L347)

<a id="function-function-minisql-transaction-checkpoint-publish-function-publish-checkpointfile-checkpointlsn-redostartlsn-recordcount-src-minisql-transaction-checkpoint-ml-105464480"></a>
### publish

```ml
function publish(checkpointFile, checkpointLsn, redoStartLsn, recordCount)
```

Performs the publish operation for this module. Inputs: `checkpointFile`, `checkpointLsn`, `redoStartLsn`, `recordCount`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — | checkpointFile value consumed by this operation. |
| `checkpointLsn` | `dynamic` | — | checkpointLsn value consumed by this operation. |
| `redoStartLsn` | `dynamic` | — | redoStartLsn value consumed by this operation. |
| `recordCount` | `dynamic` | — | Number of record to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L306)

<a id="function-function-minisql-transaction-checkpoint-readslot-function-readslot-file-slot-src-minisql-transaction-checkpoint-ml-2118763782"></a>
### readSlot

```ml
function readSlot(file, slot)
```

Reads the slot. Inputs: `file`, `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `slot` | `dynamic` | — | slot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L222)

<a id="constant-constant-minisql-transaction-checkpoint-slot-a-const-slot-a-0-src-minisql-transaction-checkpoint-ml-1498131313"></a>
### SLOT_A

```ml
const SLOT_A = 0
```

Defines the slot a constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L30)

<a id="constant-constant-minisql-transaction-checkpoint-slot-a-offset-const-slot-a-offset-0-src-minisql-transaction-checkpoint-ml-1753449983"></a>
### SLOT_A_OFFSET

```ml
const SLOT_A_OFFSET = 0
```

Defines the slot a offset constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L34)

<a id="constant-constant-minisql-transaction-checkpoint-slot-b-const-slot-b-1-src-minisql-transaction-checkpoint-ml-1958200604"></a>
### SLOT_B

```ml
const SLOT_B = 1
```

Defines the slot b constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L32)

<a id="constant-constant-minisql-transaction-checkpoint-slot-b-offset-const-slot-b-offset-256-src-minisql-transaction-checkpoint-ml-1421527066"></a>
### SLOT_B_OFFSET

```ml
const SLOT_B_OFFSET = 256
```

Defines the slot b offset constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L36)

<a id="constant-constant-minisql-transaction-checkpoint-slot-size-const-slot-size-256-src-minisql-transaction-checkpoint-ml-1160274022"></a>
### SLOT_SIZE

```ml
const SLOT_SIZE = 256
```

Defines the slot size constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L28)

<a id="function-function-minisql-transaction-checkpoint-slotoffset-function-slotoffset-slot-src-minisql-transaction-checkpoint-ml-1104826312"></a>
### slotOffset

```ml
function slotOffset(slot)
```

Performs the slotOffset operation for the minisql transaction checkpoint module. Inputs: `slot`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — | slot value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L212)

<a id="function-function-minisql-transaction-checkpoint-targetmilestone-function-targetmilestone-src-minisql-transaction-checkpoint-ml-1685547750"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql transaction checkpoint module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L376)

<a id="constant-constant-minisql-transaction-checkpoint-unsupported-format-const-unsupported-format-9003-src-minisql-transaction-checkpoint-ml-2021314619"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql transaction checkpoint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L19)

<a id="function-function-minisql-transaction-checkpoint-validatedatabaseid-function-validatedatabaseid-databaseid-operation-src-minisql-transaction-checkpoint-ml-105316383"></a>
### validateDatabaseId

```ml
function validateDatabaseId(databaseId, operation)
```

Validates database id for the minisql transaction checkpoint workflow. Inputs: `databaseId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databaseId` | `dynamic` | — | Identifier of database. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L127)

<a id="function-function-minisql-transaction-checkpoint-validatenative-function-validatenative-value-operation-name-src-minisql-transaction-checkpoint-ml-2096759679"></a>
### validateNative

```ml
function validateNative(value, operation, name)
```

Validates native for the minisql transaction checkpoint workflow. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L118)

<a id="function-function-minisql-transaction-checkpoint-validateopen-function-validateopen-checkpointfile-operation-src-minisql-transaction-checkpoint-ml-1272704327"></a>
### validateOpen

```ml
function validateOpen(checkpointFile, operation)
```

Validates open for the minisql transaction checkpoint workflow. Inputs: `checkpointFile`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `checkpointFile` | `dynamic` | — | checkpointFile value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L294)

<a id="function-function-minisql-transaction-checkpoint-writeslot-function-writeslot-file-slot-value-src-minisql-transaction-checkpoint-ml-2090083399"></a>
### writeSlot

```ml
function writeSlot(file, slot, value)
```

Writes the slot. Inputs: `file`, `slot`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `slot` | `dynamic` | — | slot value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/checkpoint.ml#L233)
