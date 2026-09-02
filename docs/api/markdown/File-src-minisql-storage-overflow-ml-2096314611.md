# `src/minisql/storage/overflow.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.storage.overflow`](Package-minisql-storage-overflow-279754395.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `minisql/storage/paged_file.ml` as `paged_file` → [src/minisql/storage/paged_file.ml](File-src-minisql-storage-paged-file-ml-1675839025.md)
- `minisql/storage/row_codec.ml` as `row_codec` → [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)

## Declarations

<a id="function-function-minisql-storage-overflow-abortreplace-function-abortreplace-pagedfile-replacement-src-minisql-storage-overflow-ml-1226285659"></a>
### abortReplace

```ml
function abortReplace(pagedFile, replacement)
```

Performs the abort replace operation for this module. Inputs: `pagedFile`, `replacement`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `replacement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L422)

<a id="function-function-minisql-storage-overflow-allocatepagenumbers-function-allocatepagenumbers-pagedfile-count-src-minisql-storage-overflow-ml-1767540990"></a>
### allocatePageNumbers

```ml
function allocatePageNumbers(pagedFile, count)
```

Allocates the page numbers. Inputs: `pagedFile`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L242)

<a id="function-function-minisql-storage-overflow-bytesequal-function-bytesequal-left-right-src-minisql-storage-overflow-ml-308644533"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L74)

<a id="constant-constant-minisql-storage-overflow-chain-header-offset-const-chain-header-offset-64-src-minisql-storage-overflow-ml-1644255521"></a>
### CHAIN_HEADER_OFFSET

```ml
const CHAIN_HEADER_OFFSET = 64
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L22)

<a id="constant-constant-minisql-storage-overflow-chain-header-size-const-chain-header-size-40-src-minisql-storage-overflow-ml-1312042007"></a>
### CHAIN_HEADER_SIZE

```ml
const CHAIN_HEADER_SIZE = 40
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L23)

<a id="constant-constant-minisql-storage-overflow-chunk-length-offset-const-chunk-length-offset-88-src-minisql-storage-overflow-ml-1930680579"></a>
### CHUNK_LENGTH_OFFSET

```ml
const CHUNK_LENGTH_OFFSET = 88
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L26)

<a id="function-function-minisql-storage-overflow-chunkcapacity-function-chunkcapacity-pagedfile-src-minisql-storage-overflow-ml-138369749"></a>
### chunkCapacity

```ml
function chunkCapacity(pagedFile)
```

Performs the chunk capacity operation for this module. Inputs: `pagedFile`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L168)

<a id="function-function-minisql-storage-overflow-commitreplace-function-commitreplace-pagedfile-replacement-src-minisql-storage-overflow-ml-247521497"></a>
### commitReplace

```ml
function commitReplace(pagedFile, replacement)
```

Commits the replace. Inputs: `pagedFile`, `replacement`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `replacement` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L410)

<a id="function-function-minisql-storage-overflow-componentname-function-componentname-src-minisql-storage-overflow-ml-493640988"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L456)

<a id="constant-constant-minisql-storage-overflow-corrupt-data-const-corrupt-data-9004-src-minisql-storage-overflow-ml-317644872"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L18)

<a id="function-function-minisql-storage-overflow-createpointer-function-createpointer-fileid-firstpage-totallength-ownerid-valuechecksum-src-minisql-storage-overflow-ml-136600320"></a>
### createPointer

```ml
function createPointer(fileId, firstPage, totalLength, ownerId, valueChecksum)
```

Creates the pointer. Inputs: `fileId`, `firstPage`, `totalLength`, `ownerId`, `valueChecksum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fileId` | `dynamic` | — |  |
| `firstPage` | `dynamic` | — |  |
| `totalLength` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `valueChecksum` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L94)

<a id="constant-constant-minisql-storage-overflow-data-offset-const-data-offset-104-src-minisql-storage-overflow-ml-1229116102"></a>
### DATA_OFFSET

```ml
const DATA_OFFSET = 104
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L24)

<a id="function-function-minisql-storage-overflow-decodenative-function-decodenative-words-operation-name-src-minisql-storage-overflow-ml-1325354679"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L130)

<a id="function-function-minisql-storage-overflow-decodenext-function-decodenext-pagebytes-src-minisql-storage-overflow-ml-748107312"></a>
### decodeNext

```ml
function decodeNext(pageBytes)
```

Decodes the next. Inputs: `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pageBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L203)

<a id="function-function-minisql-storage-overflow-decodepointer-function-decodepointer-encoded-src-minisql-storage-overflow-ml-875987966"></a>
### decodePointer

```ml
function decodePointer(encoded)
```

Decodes the pointer. Inputs: `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L137)

<a id="function-function-minisql-storage-overflow-encodepage-function-encodepage-pagedfile-pagenumber-ownerid-nextpage-totallength-sequence-chunk-src-minisql-storage-overflow-ml-1327676373"></a>
### encodePage

```ml
function encodePage(pagedFile, pageNumber, ownerId, nextPage, totalLength, sequence, chunk)
```

Encodes the page. Inputs: `pagedFile`, `pageNumber`, `ownerId`, `nextPage`, `totalLength`, `sequence`, `chunk`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageNumber` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `nextPage` | `dynamic` | — |  |
| `totalLength` | `dynamic` | — |  |
| `sequence` | `dynamic` | — |  |
| `chunk` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L176)

<a id="function-function-minisql-storage-overflow-encodepointer-function-encodepointer-pointer-src-minisql-storage-overflow-ml-962920583"></a>
### encodePointer

```ml
function encodePointer(pointer)
```

Encodes the pointer. Inputs: `pointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pointer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L108)

<a id="function-function-minisql-storage-overflow-fail-function-fail-code-operation-message-src-minisql-storage-overflow-ml-1049687223"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L56)

<a id="constant-constant-minisql-storage-overflow-format-version-const-format-version-1-src-minisql-storage-overflow-ml-1749092064"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L20)

<a id="function-function-minisql-storage-overflow-free-function-free-pagedfile-pointer-src-minisql-storage-overflow-ml-1300206016"></a>
### free

```ml
function free(pagedFile, pointer)
```

Releases the requested value. Inputs: `pagedFile`, `pointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L378)

<a id="function-function-minisql-storage-overflow-fromexternal-function-fromexternal-value-src-minisql-storage-overflow-ml-1997172957"></a>
### fromExternal

```ml
function fromExternal(value)
```

Constructs the external. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L161)

<a id="constant-constant-minisql-storage-overflow-invalid-argument-const-invalid-argument-9001-src-minisql-storage-overflow-ml-667916541"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Overflow-chain format v1 for large TEXT/BLOB values. Every chain page is a normal checksummed MiniSQL page and additionally carries owner, sequence and total-length metadata. The pointer stores a whole-value CRC-32C.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L16)

<a id="function-function-minisql-storage-overflow-isimplemented-function-isimplemented-src-minisql-storage-overflow-ml-779605716"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L468)

<a id="constant-constant-minisql-storage-overflow-next-page-offset-const-next-page-offset-80-src-minisql-storage-overflow-ml-1610291567"></a>
### NEXT_PAGE_OFFSET

```ml
const NEXT_PAGE_OFFSET = 80
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L25)

- [minisql.storage.overflow.OverflowPointer](Type-minisql-storage-overflow-overflowpointer-507137354.md) — struct
- [minisql.storage.overflow.OverflowReplacement](Type-minisql-storage-overflow-overflowreplacement-1476181223.md) — struct
<a id="function-function-minisql-storage-overflow-pagecountforlength-function-pagecountforlength-pagedfile-length-src-minisql-storage-overflow-ml-1521682731"></a>
### pageCountForLength

```ml
function pageCountForLength(pagedFile, length)
```

Performs the page count for length operation for this module. Inputs: `pagedFile`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L227)

<a id="function-function-minisql-storage-overflow-pagemagic-function-pagemagic-src-minisql-storage-overflow-ml-123890664"></a>
### pageMagic

```ml
function pageMagic()
```

Performs the page magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L68)

<a id="constant-constant-minisql-storage-overflow-pointer-size-const-pointer-size-48-src-minisql-storage-overflow-ml-1732029711"></a>
### POINTER_SIZE

```ml
const POINTER_SIZE = 48
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L21)

<a id="function-function-minisql-storage-overflow-pointermagic-function-pointermagic-src-minisql-storage-overflow-ml-331054636"></a>
### pointerMagic

```ml
function pointerMagic()
```

Performs the pointer magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L62)

<a id="function-function-minisql-storage-overflow-preparereplace-function-preparereplace-pagedfile-oldpointer-ownerid-newvalue-src-minisql-storage-overflow-ml-825443226"></a>
### prepareReplace

```ml
function prepareReplace(pagedFile, oldPointer, ownerId, newValue)
```

Performs the prepare replace operation for this module. Inputs: `pagedFile`, `oldPointer`, `ownerId`, `newValue`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `oldPointer` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `newValue` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L400)

<a id="function-function-minisql-storage-overflow-read-function-read-pagedfile-pointer-src-minisql-storage-overflow-ml-914711680"></a>
### read

```ml
function read(pagedFile, pointer)
```

Reads the requested value. Inputs: `pagedFile`, `pointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L371)

<a id="function-function-minisql-storage-overflow-readrange-function-readrange-pagedfile-pointer-requestedoffset-requestedlength-src-minisql-storage-overflow-ml-290782517"></a>
### readRange

```ml
function readRange(pagedFile, pointer, requestedOffset, requestedLength)
```

Traverses and validates the complete chain while copying only the requested range. This keeps range reads bounded by the requested output size while still checking the whole-value checksum and every chain link. Reads the range. Inputs: `pagedFile`, `pointer`, `requestedOffset`, `requestedLength`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |
| `requestedOffset` | `dynamic` | — |  |
| `requestedLength` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L318)

<a id="function-function-minisql-storage-overflow-readtext-function-readtext-pagedfile-pointer-src-minisql-storage-overflow-ml-451057656"></a>
### readText

```ml
function readText(pagedFile, pointer)
```

Reads the text. Inputs: `pagedFile`, `pointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L448)

<a id="function-function-minisql-storage-overflow-replace-function-replace-pagedfile-oldpointer-ownerid-newvalue-src-minisql-storage-overflow-ml-1714543266"></a>
### replace

```ml
function replace(pagedFile, oldPointer, ownerId, newValue)
```

Convenience helper with leak-safe semantics: write and return the new value, but never destroy oldPointer implicitly. Call free(oldPointer) only after the new pointer is durably published. Replaces the requested value. Inputs: `pagedFile`, `oldPointer`, `ownerId`, `newValue`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `oldPointer` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `newValue` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L435)

<a id="constant-constant-minisql-storage-overflow-sequence-offset-const-sequence-offset-96-src-minisql-storage-overflow-ml-197451904"></a>
### SEQUENCE_OFFSET

```ml
const SEQUENCE_OFFSET = 96
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L28)

<a id="function-function-minisql-storage-overflow-storetext-function-storetext-pagedfile-ownerid-text-src-minisql-storage-overflow-ml-221721332"></a>
### storeText

```ml
function storeText(pagedFile, ownerId, text)
```

Performs the store text operation for this module. Inputs: `pagedFile`, `ownerId`, `text`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L441)

<a id="function-function-minisql-storage-overflow-targetmilestone-function-targetmilestone-src-minisql-storage-overflow-ml-1065735998"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L462)

<a id="function-function-minisql-storage-overflow-toexternal-function-toexternal-pointer-src-minisql-storage-overflow-ml-1073137437"></a>
### toExternal

```ml
function toExternal(pointer)
```

Converts the external. Inputs: `pointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pointer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L155)

<a id="constant-constant-minisql-storage-overflow-total-length-offset-const-total-length-offset-92-src-minisql-storage-overflow-ml-17356800"></a>
### TOTAL_LENGTH_OFFSET

```ml
const TOTAL_LENGTH_OFFSET = 92
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L27)

<a id="constant-constant-minisql-storage-overflow-unsupported-format-const-unsupported-format-9003-src-minisql-storage-overflow-ml-1365635915"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L17)

<a id="function-function-minisql-storage-overflow-validatechainpage-function-validatechainpage-pagedfile-pagebytes-pointer-expectedpage-expectedsequence-src-minisql-storage-overflow-ml-1300362844"></a>
### validateChainPage

```ml
function validateChainPage(pagedFile, pageBytes, pointer, expectedPage, expectedSequence)
```

Validates the chain page. Inputs: `pagedFile`, `pageBytes`, `pointer`, `expectedPage`, `expectedSequence`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pageBytes` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |
| `expectedPage` | `dynamic` | — |  |
| `expectedSequence` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L211)

<a id="function-function-minisql-storage-overflow-validatenative-function-validatenative-value-operation-name-allowminusone-src-minisql-storage-overflow-ml-305923936"></a>
### validateNative

```ml
function validateNative(value, operation, name, allowMinusOne)
```

Validates the native. Inputs: `value`, `operation`, `name`, `allowMinusOne`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `allowMinusOne` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L85)

<a id="function-function-minisql-storage-overflow-validatepointerforfile-function-validatepointerforfile-pagedfile-pointer-operation-src-minisql-storage-overflow-ml-939664329"></a>
### validatePointerForFile

```ml
function validatePointerForFile(pagedFile, pointer, operation)
```

Validates the pointer for file. Inputs: `pagedFile`, `pointer`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `pointer` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L305)

<a id="function-function-minisql-storage-overflow-write-function-write-pagedfile-ownerid-value-src-minisql-storage-overflow-ml-960735172"></a>
### write

```ml
function write(pagedFile, ownerId, value)
```

Writes the requested value. Inputs: `pagedFile`, `ownerId`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pagedFile` | `dynamic` | — |  |
| `ownerId` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/overflow.ml#L279)
