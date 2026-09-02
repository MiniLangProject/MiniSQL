# `src/minisql/storage/slotted_page.ml`

[Home](README.md) · [Files](Files.md)

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
| `pageBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L288)

<a id="function-function-minisql-storage-slotted-page-componentname-function-componentname-src-minisql-storage-slotted-page-ml-1734353156"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L378)

<a id="constant-constant-minisql-storage-slotted-page-corrupt-data-const-corrupt-data-9004-src-minisql-storage-slotted-page-ml-452190524"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L15)

<a id="function-function-minisql-storage-slotted-page-create-function-create-pagesize-fileid-pagenumber-src-minisql-storage-slotted-page-ml-1205780357"></a>
### create

```ml
function create(pageSize, fileId, pageNumber)
```

Creates the requested value. Inputs: `pageSize`, `fileId`, `pageNumber`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageSize` | `dynamic` | — |  |
| `fileId` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L47)

<a id="function-function-minisql-storage-slotted-page-entry-function-entry-pagebytes-slotid-src-minisql-storage-slotted-page-ml-1397706437"></a>
### entry

```ml
function entry(pageBytes, slotId)
```

Performs the entry operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L165)

<a id="function-function-minisql-storage-slotted-page-entryflags-function-entryflags-pagebytes-slotid-src-minisql-storage-slotted-page-ml-132371629"></a>
### entryFlags

```ml
function entryFlags(pageBytes, slotId)
```

Performs the entry flags operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L173)

<a id="function-function-minisql-storage-slotted-page-entrygeneration-function-entrygeneration-pagebytes-slotid-src-minisql-storage-slotted-page-ml-326943125"></a>
### entryGeneration

```ml
function entryGeneration(pageBytes, slotId)
```

Performs the entry generation operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L179)

<a id="function-function-minisql-storage-slotted-page-fail-function-fail-code-operation-message-src-minisql-storage-slotted-page-ml-689668219"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L41)

<a id="function-function-minisql-storage-slotted-page-finddeleted-function-finddeleted-pagebytes-header-src-minisql-storage-slotted-page-ml-170390069"></a>
### findDeleted

```ml
function findDeleted(pageBytes, header)
```

Finds the deleted. Inputs: `pageBytes`, `header`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `header` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L216)

<a id="function-function-minisql-storage-slotted-page-freebytes-function-freebytes-pagebytes-src-minisql-storage-slotted-page-ml-15890068"></a>
### freeBytes

```ml
function freeBytes(pageBytes)
```

Releases the bytes. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L209)

<a id="function-function-minisql-storage-slotted-page-insert-function-insert-pagebytes-recordbytes-src-minisql-storage-slotted-page-ml-217612346"></a>
### insert

```ml
function insert(pageBytes, recordBytes)
```

Inserts the requested value. Inputs: `pageBytes`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L328)

<a id="function-function-minisql-storage-slotted-page-insertwithflags-function-insertwithflags-pagebytes-recordbytes-slotflags-src-minisql-storage-slotted-page-ml-76260359"></a>
### insertWithFlags

```ml
function insertWithFlags(pageBytes, recordBytes, slotFlags)
```

Inserts the with flags. Inputs: `pageBytes`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |
| `slotFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L294)

<a id="constant-constant-minisql-storage-slotted-page-invalid-argument-const-invalid-argument-9001-src-minisql-storage-slotted-page-ml-1157750917"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Slotted-page format v1. The slot directory grows from the beginning of the payload while record bodies grow backwards from the end of the page. Slot indices remain stable across compaction. A 16-bit generation protects RowId values against delete/reuse aliasing.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L14)

<a id="function-function-minisql-storage-slotted-page-isdeleted-function-isdeleted-pagebytes-slotid-src-minisql-storage-slotted-page-ml-427638467"></a>
### isDeleted

```ml
function isDeleted(pageBytes, slotId)
```

Evaluates whether the supplied input satisfies the deleted predicate. Inputs: `pageBytes`, `slotId`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L185)

<a id="function-function-minisql-storage-slotted-page-isimplemented-function-isimplemented-src-minisql-storage-slotted-page-ml-1346163100"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L390)

<a id="function-function-minisql-storage-slotted-page-liveslotcount-function-liveslotcount-pagebytes-src-minisql-storage-slotted-page-ml-680545728"></a>
### liveSlotCount

```ml
function liveSlotCount(pageBytes)
```

Performs the live slot count operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L152)

<a id="function-function-minisql-storage-slotted-page-nextgeneration-function-nextgeneration-generation-src-minisql-storage-slotted-page-ml-115433590"></a>
### nextGeneration

```ml
function nextGeneration(generation)
```

Performs the next generation operation for this module. Inputs: `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `generation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L65)

<a id="constant-constant-minisql-storage-slotted-page-page-full-const-page-full-9015-src-minisql-storage-slotted-page-ml-1329631020"></a>
### PAGE_FULL

```ml
const PAGE_FULL = 9015
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L16)

<a id="function-function-minisql-storage-slotted-page-rawentry-function-rawentry-pagebytes-slotid-src-minisql-storage-slotted-page-ml-713380397"></a>
### rawEntry

```ml
function rawEntry(pageBytes, slotId)
```

Performs the raw entry operation for this module. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L76)

<a id="function-function-minisql-storage-slotted-page-read-function-read-pagebytes-slotid-src-minisql-storage-slotted-page-ml-642326629"></a>
### read

```ml
function read(pageBytes, slotId)
```

Reads the requested value. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L191)

<a id="function-function-minisql-storage-slotted-page-readgeneration-function-readgeneration-pagebytes-slotid-generation-src-minisql-storage-slotted-page-ml-610956027"></a>
### readGeneration

```ml
function readGeneration(pageBytes, slotId, generation)
```

Reads the generation. Inputs: `pageBytes`, `slotId`, `generation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `generation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L199)

<a id="function-function-minisql-storage-slotted-page-rebuild-function-rebuild-pagebytes-replacementslot-replacement-replacementflags-deletereplacement-src-minisql-storage-slotted-page-ml-2044350824"></a>
### rebuild

```ml
function rebuild(pageBytes, replacementSlot, replacement, replacementFlags, deleteReplacement)
```

Rebuilds a compact copy. replacementSlot=-1 means pure compaction. Mutation of pageBytes happens only after the complete replacement page was validated. Performs the rebuild operation for this module. Inputs: `pageBytes`, `replacementSlot`, `replacement`, `replacementFlags`, `deleteReplacement`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `replacementSlot` | `dynamic` | — |  |
| `replacement` | `dynamic` | — |  |
| `replacementFlags` | `dynamic` | — |  |
| `deleteReplacement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L231)

<a id="function-function-minisql-storage-slotted-page-remove-function-remove-pagebytes-slotid-src-minisql-storage-slotted-page-ml-89433613"></a>
### remove

```ml
function remove(pageBytes, slotId)
```

Removes the requested value. Inputs: `pageBytes`, `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L365)

<a id="constant-constant-minisql-storage-slotted-page-row-not-found-const-row-not-found-9016-src-minisql-storage-slotted-page-ml-1541783725"></a>
### ROW_NOT_FOUND

```ml
const ROW_NOT_FOUND = 9016
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L17)

<a id="function-function-minisql-storage-slotted-page-setflags-function-setflags-pagebytes-slotid-slotflags-src-minisql-storage-slotted-page-ml-340195934"></a>
### setFlags

```ml
function setFlags(pageBytes, slotId, slotFlags)
```

Updates the flags. Inputs: `pageBytes`, `slotId`, `slotFlags`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `slotFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L357)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-deleted-const-slot-flag-deleted-1-src-minisql-storage-slotted-page-ml-1692538648"></a>
### SLOT_FLAG_DELETED

```ml
const SLOT_FLAG_DELETED = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L22)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-forward-internal-const-slot-flag-forward-internal-3-src-minisql-storage-slotted-page-ml-45772718"></a>
### SLOT_FLAG_FORWARD_INTERNAL

```ml
const SLOT_FLAG_FORWARD_INTERNAL = 3
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L24)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-forward-root-const-slot-flag-forward-root-2-src-minisql-storage-slotted-page-ml-59710931"></a>
### SLOT_FLAG_FORWARD_ROOT

```ml
const SLOT_FLAG_FORWARD_ROOT = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L23)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-live-const-slot-flag-live-0-src-minisql-storage-slotted-page-ml-723647285"></a>
### SLOT_FLAG_LIVE

```ml
const SLOT_FLAG_LIVE = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L21)

<a id="constant-constant-minisql-storage-slotted-page-slot-flag-moved-const-slot-flag-moved-4-src-minisql-storage-slotted-page-ml-517499071"></a>
### SLOT_FLAG_MOVED

```ml
const SLOT_FLAG_MOVED = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L25)

<a id="constant-constant-minisql-storage-slotted-page-slot-size-const-slot-size-8-src-minisql-storage-slotted-page-ml-2049082295"></a>
### SLOT_SIZE

```ml
const SLOT_SIZE = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L20)

<a id="function-function-minisql-storage-slotted-page-slotcount-function-slotcount-pagebytes-src-minisql-storage-slotted-page-ml-1836713560"></a>
### slotCount

```ml
function slotCount(pageBytes)
```

Performs the slot count operation for this module. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L146)

- [minisql.storage.slotted_page.SlotEntry](Type-minisql-storage-slotted-page-slotentry-717930366.md) — struct
<a id="function-function-minisql-storage-slotted-page-slotoffset-function-slotoffset-slotid-src-minisql-storage-slotted-page-ml-1080260691"></a>
### slotOffset

```ml
function slotOffset(slotId)
```

Performs the slot offset operation for this module. Inputs: `slotId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slotId` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L53)

<a id="constant-constant-minisql-storage-slotted-page-stale-reference-const-stale-reference-9018-src-minisql-storage-slotted-page-ml-736418087"></a>
### STALE_REFERENCE

```ml
const STALE_REFERENCE = 9018
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L18)

<a id="function-function-minisql-storage-slotted-page-targetmilestone-function-targetmilestone-src-minisql-storage-slotted-page-ml-842606430"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L384)

<a id="function-function-minisql-storage-slotted-page-update-function-update-pagebytes-slotid-recordbytes-src-minisql-storage-slotted-page-ml-568776087"></a>
### update

```ml
function update(pageBytes, slotId, recordBytes)
```

Updates the requested value. Inputs: `pageBytes`, `slotId`, `recordBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L349)

<a id="function-function-minisql-storage-slotted-page-updatewithflags-function-updatewithflags-pagebytes-slotid-recordbytes-slotflags-src-minisql-storage-slotted-page-ml-1853420048"></a>
### updateWithFlags

```ml
function updateWithFlags(pageBytes, slotId, recordBytes, slotFlags)
```

Updates the with flags. Inputs: `pageBytes`, `slotId`, `recordBytes`, `slotFlags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `recordBytes` | `dynamic` | — |  |
| `slotFlags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L334)

<a id="function-function-minisql-storage-slotted-page-validate-function-validate-pagebytes-operation-src-minisql-storage-slotted-page-ml-1234155001"></a>
### validate

```ml
function validate(pageBytes, operation)
```

Validates the requested value. Inputs: `pageBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L109)

<a id="function-function-minisql-storage-slotted-page-validateslot-function-validateslot-header-slotid-operation-src-minisql-storage-slotted-page-ml-1512466467"></a>
### validateSlot

```ml
function validateSlot(header, slotId, operation)
```

Validates the slot. Inputs: `header`, `slotId`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L100)

<a id="function-function-minisql-storage-slotted-page-validflags-function-validflags-flags-src-minisql-storage-slotted-page-ml-227709657"></a>
### validFlags

```ml
function validFlags(flags)
```

Performs the valid flags operation for this module. Inputs: `flags`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `flags` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L59)

<a id="function-function-minisql-storage-slotted-page-writeentry-function-writeentry-pagebytes-slotid-entry-src-minisql-storage-slotted-page-ml-1049029423"></a>
### writeEntry

```ml
function writeEntry(pageBytes, slotId, entry)
```

Writes the entry. Inputs: `pageBytes`, `slotId`, `entry`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |
| `slotId` | `dynamic` | — |  |
| `entry` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/slotted_page.ml#L88)
