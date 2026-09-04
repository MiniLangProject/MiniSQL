# `src/minisql/storage/slotted_page.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage slotted page facilities for this project.

Package: [`minisql.storage.slotted_page`](Package-minisql-storage-slotted-page-585559320.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)

## Declarations

<a id="function-function-minisql-storage-slotted-page-compact-function-compact-pagebytes-src-minisql-storage-slotted-page-ml-396206152"></a>
### compact

```ml
function compact(pageBytes)
```

Performs the compact operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L340)

<a id="function-function-minisql-storage-slotted-page-componentname-function-componentname-src-minisql-storage-slotted-page-ml-1734353156"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage slotted page module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L447)

<a id="constant-constant-minisql-storage-slotted-page-corrupt-data-const-corrupt-data-9004-src-minisql-storage-slotted-page-ml-452190524"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L15)

<a id="function-function-minisql-storage-slotted-page-create-function-create-pagesize-fileid-pagenumber-src-minisql-storage-slotted-page-ml-1205780357"></a>
### create

```ml
function create(pageSize, fileId, pageNumber)
```

Creates create for the minisql storage slotted page module. Inputs: `pageSize`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — | pageSize value consumed by this operation. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L62)

<a id="function-function-minisql-storage-slotted-page-entry-function-entry-pagebytes-slotid-src-minisql-storage-slotted-page-ml-1397706437"></a>
### entry

```ml
function entry(pageBytes, slotId)
```

Performs the entry operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L197)

<a id="function-function-minisql-storage-slotted-page-entryflags-function-entryflags-pagebytes-slotid-src-minisql-storage-slotted-page-ml-132371629"></a>
### entryFlags

```ml
function entryFlags(pageBytes, slotId)
```

Performs the entry flags operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L207)

<a id="function-function-minisql-storage-slotted-page-entrygeneration-function-entrygeneration-pagebytes-slotid-src-minisql-storage-slotted-page-ml-326943125"></a>
### entryGeneration

```ml
function entryGeneration(pageBytes, slotId)
```

Performs the entry generation operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L215)

<a id="function-function-minisql-storage-slotted-page-fail-function-fail-code-operation-message-src-minisql-storage-slotted-page-ml-689668219"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage slotted page module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L53)

<a id="function-function-minisql-storage-slotted-page-finddeleted-function-finddeleted-pagebytes-header-src-minisql-storage-slotted-page-ml-170390069"></a>
### findDeleted

```ml
function findDeleted(pageBytes, header)
```

Finds the deleted. Inputs: `pageBytes`, `header`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `header` | `dynamic` | — | header value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L262)

<a id="function-function-minisql-storage-slotted-page-freebytes-function-freebytes-pagebytes-src-minisql-storage-slotted-page-ml-15890068"></a>
### freeBytes

```ml
function freeBytes(pageBytes)
```

Releases the bytes. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L253)

<a id="function-function-minisql-storage-slotted-page-insert-function-insert-pagebytes-recordbytes-src-minisql-storage-slotted-page-ml-217612346"></a>
### insert

```ml
function insert(pageBytes, recordBytes)
```

Performs the insert operation for the minisql storage slotted page module. Inputs: `pageBytes`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `recordBytes` | `dynamic` | — | recordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L385)

<a id="function-function-minisql-storage-slotted-page-insertwithflags-function-insertwithflags-pagebytes-recordbytes-slotflags-src-minisql-storage-slotted-page-ml-76260359"></a>
### insertWithFlags

```ml
function insertWithFlags(pageBytes, recordBytes, slotFlags)
```

Inserts the with flags. Inputs: `pageBytes`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `recordBytes` | `dynamic` | — | recordBytes value consumed by this operation. |
| `slotFlags` | `dynamic` | — | slotFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L349)

<a id="constant-constant-minisql-storage-slotted-page-invalid-argument-const-invalid-argument-9001-src-minisql-storage-slotted-page-ml-1157750917"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Slotted-page format v1. The slot directory grows from the beginning of the


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L13)

<a id="function-function-minisql-storage-slotted-page-isdeleted-function-isdeleted-pagebytes-slotid-src-minisql-storage-slotted-page-ml-427638467"></a>
### isDeleted

```ml
function isDeleted(pageBytes, slotId)
```

Evaluates whether the supplied input satisfies the deleted predicate. Inputs: `pageBytes`, `slotId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L223)

<a id="function-function-minisql-storage-slotted-page-isimplemented-function-isimplemented-src-minisql-storage-slotted-page-ml-1346163100"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage slotted page module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L459)

<a id="function-function-minisql-storage-slotted-page-liveslotcount-function-liveslotcount-pagebytes-src-minisql-storage-slotted-page-ml-680545728"></a>
### liveSlotCount

```ml
function liveSlotCount(pageBytes)
```

Performs the live slot count operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L182)

<a id="function-function-minisql-storage-slotted-page-nextgeneration-function-nextgeneration-generation-src-minisql-storage-slotted-page-ml-115433590"></a>
### nextGeneration

```ml
function nextGeneration(generation)
```

Performs the next generation operation for this module. Inputs: `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `generation` | `dynamic` | — | generation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L83)

<a id="constant-constant-minisql-storage-slotted-page-page-full-const-page-full-9015-src-minisql-storage-slotted-page-ml-1329631020"></a>
### PAGE_FULL

```ml
const PAGE_FULL = 9015
```

Defines the page full constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L17)

<a id="function-function-minisql-storage-slotted-page-rawentry-function-rawentry-pagebytes-slotid-src-minisql-storage-slotted-page-ml-713380397"></a>
### rawEntry

```ml
function rawEntry(pageBytes, slotId)
```

Performs the raw entry operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L96)

<a id="function-function-minisql-storage-slotted-page-read-function-read-pagebytes-slotid-src-minisql-storage-slotted-page-ml-642326629"></a>
### read

```ml
function read(pageBytes, slotId)
```

Reads read for the minisql storage slotted page workflow. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L231)

<a id="function-function-minisql-storage-slotted-page-readgeneration-function-readgeneration-pagebytes-slotid-generation-src-minisql-storage-slotted-page-ml-610956027"></a>
### readGeneration

```ml
function readGeneration(pageBytes, slotId, generation)
```

Reads the generation. Inputs: `pageBytes`, `slotId`, `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `generation` | `dynamic` | — | generation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L242)

<a id="function-function-minisql-storage-slotted-page-rebuild-function-rebuild-pagebytes-replacementslot-replacement-replacementflags-deletereplacement-src-minisql-storage-slotted-page-ml-2044350824"></a>
### rebuild

```ml
function rebuild(pageBytes, replacementSlot, replacement, replacementFlags, deleteReplacement)
```

Rebuilds a compact copy. replacementSlot=-1 means pure compaction. Mutation of pageBytes happens only after the complete replacement page was validated. Performs the rebuild operation for this module. Inputs: `pageBytes`, `replacementSlot`, `replacement`, `replacementFlags`, `deleteReplacement`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `replacementSlot` | `dynamic` | — | replacementSlot value consumed by this operation. |
| `replacement` | `dynamic` | — | replacement value consumed by this operation. |
| `replacementFlags` | `dynamic` | — | replacementFlags value consumed by this operation. |
| `deleteReplacement` | `dynamic` | — | deleteReplacement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L282)

<a id="function-function-minisql-storage-slotted-page-remove-function-remove-pagebytes-slotid-src-minisql-storage-slotted-page-ml-89433613"></a>
### remove

```ml
function remove(pageBytes, slotId)
```

Removes remove from the state managed by the minisql storage slotted page module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L434)

<a id="constant-constant-minisql-storage-slotted-page-row-not-found-const-row-not-found-9016-src-minisql-storage-slotted-page-ml-1541783725"></a>
### ROW_NOT_FOUND

```ml
const ROW_NOT_FOUND = 9016
```

Defines the row not found constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L19)

<a id="function-function-minisql-storage-slotted-page-setflags-function-setflags-pagebytes-slotid-slotflags-src-minisql-storage-slotted-page-ml-340195934"></a>
### setFlags

```ml
function setFlags(pageBytes, slotId, slotFlags)
```

Updates the flags. Inputs: `pageBytes`, `slotId`, `slotFlags`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `slotFlags` | `dynamic` | — | slotFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L424)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-deleted-const-slot-flag-deleted-1-src-minisql-storage-slotted-page-ml-1692538648"></a>
### SLOT_FLAG_DELETED

```ml
const SLOT_FLAG_DELETED = 1
```

Defines the slot flag deleted constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L28)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-forward-internal-const-slot-flag-forward-internal-3-src-minisql-storage-slotted-page-ml-45772718"></a>
### SLOT_FLAG_FORWARD_INTERNAL

```ml
const SLOT_FLAG_FORWARD_INTERNAL = 3
```

Defines the slot flag forward internal constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L32)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-forward-root-const-slot-flag-forward-root-2-src-minisql-storage-slotted-page-ml-59710931"></a>
### SLOT_FLAG_FORWARD_ROOT

```ml
const SLOT_FLAG_FORWARD_ROOT = 2
```

Defines the slot flag forward root constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L30)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-live-const-slot-flag-live-0-src-minisql-storage-slotted-page-ml-723647285"></a>
### SLOT_FLAG_LIVE

```ml
const SLOT_FLAG_LIVE = 0
```

Defines the slot flag live constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L26)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-moved-const-slot-flag-moved-4-src-minisql-storage-slotted-page-ml-517499071"></a>
### SLOT_FLAG_MOVED

```ml
const SLOT_FLAG_MOVED = 4
```

Defines the slot flag moved constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L34)

<a id="constant-constant-minisql-storage-slotted-page-slot-size-const-slot-size-8-src-minisql-storage-slotted-page-ml-2049082295"></a>
### SLOT_SIZE

```ml
const SLOT_SIZE = 8
```

Defines the slot size constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L24)

<a id="function-function-minisql-storage-slotted-page-slotcount-function-slotcount-pagebytes-src-minisql-storage-slotted-page-ml-1836713560"></a>
### slotCount

```ml
function slotCount(pageBytes)
```

Performs the slot count operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L175)

- [minisql.storage.slotted_page.SlotEntry](Type-minisql-storage-slotted-page-slotentry-717930366.md) — struct
<a id="function-function-minisql-storage-slotted-page-slotoffset-function-slotoffset-slotid-src-minisql-storage-slotted-page-ml-1080260691"></a>
### slotOffset

```ml
function slotOffset(slotId)
```

Performs the slotOffset operation for the minisql storage slotted page module. Inputs: `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slotId` | `dynamic` | — | Identifier of slot. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L69)

<a id="constant-constant-minisql-storage-slotted-page-stale-reference-const-stale-reference-9018-src-minisql-storage-slotted-page-ml-736418087"></a>
### STALE_REFERENCE

```ml
const STALE_REFERENCE = 9018
```

Defines the stale reference constant used by the minisql storage slotted page module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L21)

<a id="function-function-minisql-storage-slotted-page-targetmilestone-function-targetmilestone-src-minisql-storage-slotted-page-ml-842606430"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage slotted page module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L453)

<a id="function-function-minisql-storage-slotted-page-update-function-update-pagebytes-slotid-recordbytes-src-minisql-storage-slotted-page-ml-568776087"></a>
### update

```ml
function update(pageBytes, slotId, recordBytes)
```

Updates the requested value. Inputs: `pageBytes`, `slotId`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `recordBytes` | `dynamic` | — | recordBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L413)

<a id="function-function-minisql-storage-slotted-page-updatewithflags-function-updatewithflags-pagebytes-slotid-recordbytes-slotflags-src-minisql-storage-slotted-page-ml-1853420048"></a>
### updateWithFlags

```ml
function updateWithFlags(pageBytes, slotId, recordBytes, slotFlags)
```

Updates the with flags. Inputs: `pageBytes`, `slotId`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `recordBytes` | `dynamic` | — | recordBytes value consumed by this operation. |
| `slotFlags` | `dynamic` | — | slotFlags value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L395)

<a id="function-function-minisql-storage-slotted-page-validate-function-validate-pagebytes-operation-src-minisql-storage-slotted-page-ml-1234155001"></a>
### validate

```ml
function validate(pageBytes, operation)
```

Validates validate for the minisql storage slotted page workflow. Inputs: `pageBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L137)

<a id="function-function-minisql-storage-slotted-page-validateslot-function-validateslot-header-slotid-operation-src-minisql-storage-slotted-page-ml-1512466467"></a>
### validateSlot

```ml
function validateSlot(header, slotId, operation)
```

Validates the slot. Inputs: `header`, `slotId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — | header value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L126)

<a id="function-function-minisql-storage-slotted-page-validflags-function-validflags-flags-src-minisql-storage-slotted-page-ml-227709657"></a>
### validFlags

```ml
function validFlags(flags)
```

Performs the valid flags operation for this module. Inputs: `flags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `flags` | `dynamic` | — | Bit flags controlling the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L76)

<a id="function-function-minisql-storage-slotted-page-writeentry-function-writeentry-pagebytes-slotid-entry-src-minisql-storage-slotted-page-ml-1049029423"></a>
### writeEntry

```ml
function writeEntry(pageBytes, slotId, entry)
```

Writes the entry. Inputs: `pageBytes`, `slotId`, `entry`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |
| `slotId` | `dynamic` | — | Identifier of slot. |
| `entry` | `dynamic` | — | entry value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L111)
