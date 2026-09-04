# `src/minisql/transaction/wal.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql transaction wal facilities for this project.

Package: [`minisql.transaction.wal`](Package-minisql-transaction-wal-1468394746.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/security/key_provider.ml` as `key_provider` → [src/minisql/security/key_provider.ml](File-src-minisql-security-key-provider-ml-1192998689.md)
- `minisql/storage/page.ml` as `page` → [src/minisql/storage/page.ml](File-src-minisql-storage-page-ml-792931788.md)
- `std/crypto/aes_gcm.ml` as `aes_gcm` → `../MiniLangCompilerML/std/crypto/aes_gcm.ml` — external dependency
- `std/ds/list.ml` as `list` → `../MiniLangCompilerML/std/ds/list.ml` — external dependency

## Declarations

<a id="constant-constant-minisql-transaction-wal-append-batch-bytes-const-append-batch-bytes-4194304-src-minisql-transaction-wal-ml-322702482"></a>
### APPEND_BATCH_BYTES

```ml
const APPEND_BATCH_BYTES = 4194304
```

Defines the append batch bytes constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L42)

<a id="function-function-minisql-transaction-wal-appendabort-function-appendabort-writer-transactionid-src-minisql-transaction-wal-ml-1903344086"></a>
### appendAbort

```ml
function appendAbort(writer, transactionId)
```

Appends the abort. Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L800)

<a id="function-function-minisql-transaction-wal-appendbatchrecord-function-appendbatchrecord-batch-record-src-minisql-transaction-wal-ml-854064689"></a>
### appendBatchRecord

```ml
function appendBatchRecord(batch, record)
```

Adds one record to the bounded batch, flushing or directly appending records larger than the staging buffer. At most APPEND_BATCH_BYTES are duplicated.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `batch` | `dynamic` | — | batch value consumed by this operation. |
| `record` | `dynamic` | — | record value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L715)

<a id="function-function-minisql-transaction-wal-appendbegin-function-appendbegin-writer-transactionid-src-minisql-transaction-wal-ml-930188240"></a>
### appendBegin

```ml
function appendBegin(writer, transactionId)
```

Appends the begin. Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L773)

<a id="function-function-minisql-transaction-wal-appendcheckpointbegin-function-appendcheckpointbegin-writer-checkpointid-payload-src-minisql-transaction-wal-ml-1634850574"></a>
### appendCheckpointBegin

```ml
function appendCheckpointBegin(writer, checkpointId, payload)
```

Appends the checkpoint begin. Inputs: `writer`, `checkpointId`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `checkpointId` | `dynamic` | — | Identifier of checkpoint. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L809)

<a id="function-function-minisql-transaction-wal-appendcheckpointend-function-appendcheckpointend-writer-checkpointid-payload-src-minisql-transaction-wal-ml-1723538650"></a>
### appendCheckpointEnd

```ml
function appendCheckpointEnd(writer, checkpointId, payload)
```

Appends the checkpoint end. Inputs: `writer`, `checkpointId`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `checkpointId` | `dynamic` | — | Identifier of checkpoint. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L818)

<a id="function-function-minisql-transaction-wal-appendcommit-function-appendcommit-writer-transactionid-src-minisql-transaction-wal-ml-1451373646"></a>
### appendCommit

```ml
function appendCommit(writer, transactionId)
```

Appends the commit. Inputs: `writer`, `transactionId`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L792)

<a id="function-function-minisql-transaction-wal-appendpageimage-function-appendpageimage-writer-transactionid-fileid-pagenumber-pagebytes-src-minisql-transaction-wal-ml-192433459"></a>
### appendPageImage

```ml
function appendPageImage(writer, transactionId, fileId, pageNumber, pageBytes)
```

Appends the page image. Inputs: `writer`, `transactionId`, `fileId`, `pageNumber`, `pageBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `pageBytes` | `dynamic` | — | pageBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L784)

<a id="function-function-minisql-transaction-wal-appendrecord-function-appendrecord-writer-recordtype-flags-transactionid-fileid-pagenumber-payload-src-minisql-transaction-wal-ml-810671269"></a>
### appendRecord

```ml
function appendRecord(writer, recordType, flags, transactionId, fileId, pageNumber, payload)
```

Appends the record. Inputs: `writer`, `recordType`, `flags`, `transactionId`, `fileId`, `pageNumber`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `recordType` | `dynamic` | — | recordType value consumed by this operation. |
| `flags` | `dynamic` | — | Bit flags controlling the operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L654)

<a id="function-function-minisql-transaction-wal-appendtransaction-function-appendtransaction-writer-transactionid-changes-src-minisql-transaction-wal-ml-311048587"></a>
### appendTransaction

```ml
function appendTransaction(writer, transactionId, changes)
```

Appends a complete transaction using a bounded staging buffer. This reduces one kernel write per page image to roughly one write per 4 MiB while retaining the existing single FlushFileBuffers durability boundary and rewind-on-error behavior. `changes` contain fileId, pageNumber and pageBytes fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `changes` | `dynamic` | — | changes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L738)

<a id="function-function-minisql-transaction-wal-bytesequal-function-bytesequal-left-right-src-minisql-transaction-wal-ml-1064207079"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql transaction wal module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L183)

<a id="function-function-minisql-transaction-wal-close-function-close-writer-src-minisql-transaction-wal-ml-1543838361"></a>
### close

```ml
function close(writer)
```

Closes close owned by the minisql transaction wal module. Inputs: `writer`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L898)

<a id="constant-constant-minisql-transaction-wal-closed-handle-const-closed-handle-9008-src-minisql-transaction-wal-ml-652378928"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L27)

<a id="function-function-minisql-transaction-wal-componentname-function-componentname-src-minisql-transaction-wal-ml-1785815390"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql transaction wal module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L909)

<a id="function-function-minisql-transaction-wal-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-transaction-wal-ml-2143075749"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Performs the copyExact operation for the minisql transaction wal module. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L171)

<a id="constant-constant-minisql-transaction-wal-corrupt-data-const-corrupt-data-9004-src-minisql-transaction-wal-ml-738627906"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L23)

<a id="function-function-minisql-transaction-wal-create-function-create-path-segmentbytes-src-minisql-transaction-wal-ml-1517957857"></a>
### create

```ml
function create(path, segmentBytes)
```

Creates create for the minisql transaction wal module. Inputs: `path`, `segmentBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `segmentBytes` | `dynamic` | — | segmentBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L578)

<a id="function-function-minisql-transaction-wal-createrecord-function-createrecord-recordtype-flags-transactionid-fileid-pagenumber-payload-src-minisql-transaction-wal-ml-1732986708"></a>
### createRecord

```ml
function createRecord(recordType, flags, transactionId, fileId, pageNumber, payload)
```

Creates the record. Inputs: `recordType`, `flags`, `transactionId`, `fileId`, `pageNumber`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recordType` | `dynamic` | — | recordType value consumed by this operation. |
| `flags` | `dynamic` | — | Bit flags controlling the operation. |
| `transactionId` | `dynamic` | — | Identifier of transaction. |
| `fileId` | `dynamic` | — | Identifier of file. |
| `pageNumber` | `dynamic` | — | pageNumber value consumed by this operation. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L315)

<a id="function-function-minisql-transaction-wal-decode-function-decode-source-src-minisql-transaction-wal-ml-1435933563"></a>
### decode

```ml
function decode(source)
```

Public compatibility wrapper. Qualified calls such as wal.decode(...) resolve to this package function. Internal WAL code deliberately uses decodeRecord so the MiniLang builtin decode(bytes) cannot shadow the WAL record decoder. Decodes the requested value. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L483)

<a id="function-function-minisql-transaction-wal-decodedurablemarker-function-decodedurablemarker-source-src-minisql-transaction-wal-ml-1290525973"></a>
### decodeDurableMarker

```ml
function decodeDurableMarker(source)
```

Decodes the durable marker. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L261)

<a id="function-function-minisql-transaction-wal-decodenative-function-decodenative-words-operation-name-src-minisql-transaction-wal-ml-976111771"></a>
### decodeNative

```ml
function decodeNative(words, operation, name)
```

Decodes native for the minisql transaction wal workflow. Inputs: `words`, `operation`, `name`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `words` | `dynamic` | — | words value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L209)

<a id="function-function-minisql-transaction-wal-decoderecord-function-decoderecord-source-src-minisql-transaction-wal-ml-673424431"></a>
### decodeRecord

```ml
function decodeRecord(source)
```

Decodes a compatibility plaintext WAL record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L473)

<a id="function-function-minisql-transaction-wal-decoderecordwithkey-function-decoderecordwithkey-source-encryptionkey-src-minisql-transaction-wal-ml-419076701"></a>
### decodeRecordWithKey

```ml
function decodeRecordWithKey(source, encryptionKey)
```

Decodes one plaintext or encrypted WAL record with an optional DEK.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `encryptionKey` | `dynamic` | — | encryptionKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L419)

<a id="constant-constant-minisql-transaction-wal-durable-marker-checksum-offset-const-durable-marker-checksum-offset-24-src-minisql-transaction-wal-ml-1253847487"></a>
### DURABLE_MARKER_CHECKSUM_OFFSET

```ml
const DURABLE_MARKER_CHECKSUM_OFFSET = 24
```

Defines the durable marker checksum offset constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L53)

<a id="constant-constant-minisql-transaction-wal-durable-marker-size-const-durable-marker-size-32-src-minisql-transaction-wal-ml-128126620"></a>
### DURABLE_MARKER_SIZE

```ml
const DURABLE_MARKER_SIZE = 32
```

Defines the durable marker size constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L51)

<a id="constant-constant-minisql-transaction-wal-durable-marker-version-const-durable-marker-version-1-src-minisql-transaction-wal-ml-103749146"></a>
### DURABLE_MARKER_VERSION

```ml
const DURABLE_MARKER_VERSION = 1
```

M48 durable-export marker. The WAL itself remains format v1. The sidecar


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L49)

<a id="function-function-minisql-transaction-wal-durablemarkermagic-function-durablemarkermagic-src-minisql-transaction-wal-ml-856140390"></a>
### durableMarkerMagic

```ml
function durableMarkerMagic()
```

Performs the durable marker magic operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L229)

<a id="function-function-minisql-transaction-wal-durablemarkerpath-function-durablemarkerpath-walpath-src-minisql-transaction-wal-ml-481551449"></a>
### durableMarkerPath

```ml
function durableMarkerPath(walPath)
```

Performs the durable marker path operation for this module. Inputs: `walPath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `walPath` | `dynamic` | — | Path associated with wal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L236)

<a id="function-function-minisql-transaction-wal-encode-function-encode-record-src-minisql-transaction-wal-ml-1342607379"></a>
### encode

```ml
function encode(record)
```

Encodes encode for the minisql transaction wal workflow. Inputs: `record`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | record value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L358)

<a id="function-function-minisql-transaction-wal-encodedurablemarker-function-encodedurablemarker-lsn-src-minisql-transaction-wal-ml-546690561"></a>
### encodeDurableMarker

```ml
function encodeDurableMarker(lsn)
```

Encodes the durable marker. Inputs: `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L244)

<a id="function-function-minisql-transaction-wal-encoderecordat-function-encoderecordat-writer-record-lsn-src-minisql-transaction-wal-ml-2098018453"></a>
### encodeRecordAt

```ml
function encodeRecordAt(writer, record, lsn)
```

Assigns an LSN, updates a PAGE_IMAGE header and returns the encoded record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `record` | `dynamic` | — | record value consumed by this operation. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L684)

<a id="constant-constant-minisql-transaction-wal-encryption-marker-high-const-encryption-marker-high-827081047-src-minisql-transaction-wal-ml-379574050"></a>
### ENCRYPTION_MARKER_HIGH

```ml
const ENCRYPTION_MARKER_HIGH = 827081047
```

Defines the encryption marker high constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L46)

<a id="constant-constant-minisql-transaction-wal-encryption-marker-low-const-encryption-marker-low-826623060-src-minisql-transaction-wal-ml-103956588"></a>
### ENCRYPTION_MARKER_LOW

```ml
const ENCRYPTION_MARKER_LOW = 826623060
```

The formerly reserved final U64 identifies an encrypted payload without


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L44)

<a id="function-function-minisql-transaction-wal-fail-function-fail-code-operation-message-src-minisql-transaction-wal-ml-597183503"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql transaction wal module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L154)

<a id="function-function-minisql-transaction-wal-flush-function-flush-writer-src-minisql-transaction-wal-ml-1449699693"></a>
### flush

```ml
function flush(writer)
```

Performs the flush operation for the minisql transaction wal module. Inputs: `writer`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L844)

<a id="function-function-minisql-transaction-wal-flushappendbatch-function-flushappendbatch-batch-src-minisql-transaction-wal-ml-960733410"></a>
### flushAppendBatch

```ml
function flushAppendBatch(batch)
```

Flushes the occupied prefix of a bounded append batch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `batch` | `dynamic` | — | batch value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L702)

<a id="constant-constant-minisql-transaction-wal-format-version-const-format-version-1-src-minisql-transaction-wal-ml-1931763152"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = 1
```

Defines the format version constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L30)

<a id="constant-constant-minisql-transaction-wal-header-checksum-offset-const-header-checksum-offset-68-src-minisql-transaction-wal-ml-1338722233"></a>
### HEADER_CHECKSUM_OFFSET

```ml
const HEADER_CHECKSUM_OFFSET = 68
```

Defines the header checksum offset constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L38)

<a id="constant-constant-minisql-transaction-wal-header-size-const-header-size-80-src-minisql-transaction-wal-ml-657617671"></a>
### HEADER_SIZE

```ml
const HEADER_SIZE = 80
```

Defines the header size constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L32)

<a id="function-function-minisql-transaction-wal-injectflushfailure-function-injectflushfailure-writer-src-minisql-transaction-wal-ml-550845309"></a>
### injectFlushFailure

```ml
function injectFlushFailure(writer)
```

Performs the inject flush failure operation for this module. Inputs: `writer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L889)

<a id="function-function-minisql-transaction-wal-injectwritefailure-function-injectwritefailure-writer-src-minisql-transaction-wal-ml-1108506517"></a>
### injectWriteFailure

```ml
function injectWriteFailure(writer)
```

Performs the inject write failure operation for this module. Inputs: `writer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L880)

<a id="constant-constant-minisql-transaction-wal-invalid-argument-const-invalid-argument-9001-src-minisql-transaction-wal-ml-2047170601"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Write-ahead log format v1. Records are append-only, length-prefixed and


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L19)

<a id="constant-constant-minisql-transaction-wal-io-failure-const-io-failure-9005-src-minisql-transaction-wal-ml-1396012329"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L25)

<a id="function-function-minisql-transaction-wal-isimplemented-function-isimplemented-src-minisql-transaction-wal-ml-972947062"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql transaction wal module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L921)

<a id="function-function-minisql-transaction-wal-iswalscan-function-iswalscan-value-src-minisql-transaction-wal-ml-1445900905"></a>
### isWalScan

```ml
function isWalScan(value)
```

Evaluates whether the supplied input satisfies the wal scan predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L105)

<a id="constant-constant-minisql-transaction-wal-magic-size-const-magic-size-8-src-minisql-transaction-wal-ml-1057215835"></a>
### MAGIC_SIZE

```ml
const MAGIC_SIZE = 8
```

Defines the magic size constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L34)

<a id="function-function-minisql-transaction-wal-magicbytes-function-magicbytes-src-minisql-transaction-wal-ml-824236846"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magicBytes operation for the minisql transaction wal module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L160)

<a id="constant-constant-minisql-transaction-wal-max-record-size-const-max-record-size-67108864-src-minisql-transaction-wal-ml-1703726415"></a>
### MAX_RECORD_SIZE

```ml
const MAX_RECORD_SIZE = 67108864
```

Defines the max record size constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L40)

<a id="function-function-minisql-transaction-wal-open-function-open-path-segmentbytes-src-minisql-transaction-wal-ml-712970529"></a>
### open

```ml
function open(path, segmentBytes)
```

Opens open for the minisql transaction wal module. Inputs: `path`, `segmentBytes`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path of the file or directory used by the operation. |
| `segmentBytes` | `dynamic` | — | segmentBytes value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L593)

<a id="constant-constant-minisql-transaction-wal-payload-checksum-offset-const-payload-checksum-offset-64-src-minisql-transaction-wal-ml-1653445853"></a>
### PAYLOAD_CHECKSUM_OFFSET

```ml
const PAYLOAD_CHECKSUM_OFFSET = 64
```

Defines the payload checksum offset constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L36)

<a id="function-function-minisql-transaction-wal-protectrecord-function-protectrecord-record-encryptionkey-src-minisql-transaction-wal-ml-675575781"></a>
### protectRecord

```ml
function protectRecord(record, encryptionKey)
```

Encrypts a logical WAL payload after its final LSN is assigned.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | record value consumed by this operation. |
| `encryptionKey` | `dynamic` | — | encryptionKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L401)

<a id="function-function-minisql-transaction-wal-readdurablemarker-function-readdurablemarker-walpath-src-minisql-transaction-wal-ml-2076815543"></a>
### readDurableMarker

```ml
function readDurableMarker(walPath)
```

Reads the durable marker. Inputs: `walPath`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `walPath` | `dynamic` | — | Path associated with wal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L278)

<a id="constant-constant-minisql-transaction-wal-record-checkpoint-begin-const-record-checkpoint-begin-5-src-minisql-transaction-wal-ml-668215974"></a>
### RECORD_CHECKPOINT_BEGIN

```ml
const RECORD_CHECKPOINT_BEGIN = 5
```

Defines the record checkpoint begin constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L64)

<a id="constant-constant-minisql-transaction-wal-record-checkpoint-end-const-record-checkpoint-end-6-src-minisql-transaction-wal-ml-1351871261"></a>
### RECORD_CHECKPOINT_END

```ml
const RECORD_CHECKPOINT_END = 6
```

Defines the record checkpoint end constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L66)

<a id="constant-constant-minisql-transaction-wal-record-page-image-const-record-page-image-2-src-minisql-transaction-wal-ml-406686021"></a>
### RECORD_PAGE_IMAGE

```ml
const RECORD_PAGE_IMAGE = 2
```

Defines the record page image constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L58)

<a id="constant-constant-minisql-transaction-wal-record-tx-abort-const-record-tx-abort-4-src-minisql-transaction-wal-ml-1717353835"></a>
### RECORD_TX_ABORT

```ml
const RECORD_TX_ABORT = 4
```

Defines the record tx abort constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L62)

<a id="constant-constant-minisql-transaction-wal-record-tx-begin-const-record-tx-begin-1-src-minisql-transaction-wal-ml-535761158"></a>
### RECORD_TX_BEGIN

```ml
const RECORD_TX_BEGIN = 1
```

Defines the record tx begin constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L56)

<a id="constant-constant-minisql-transaction-wal-record-tx-commit-const-record-tx-commit-3-src-minisql-transaction-wal-ml-1603961114"></a>
### RECORD_TX_COMMIT

```ml
const RECORD_TX_COMMIT = 3
```

Defines the record tx commit constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L60)

<a id="function-function-minisql-transaction-wal-rewind-function-rewind-writer-lsn-src-minisql-transaction-wal-ml-1515352962"></a>
### rewind

```ml
function rewind(writer, lsn)
```

Performs the rewind operation for this module. Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L863)

<a id="function-function-minisql-transaction-wal-scan-function-scan-writer-repairtail-src-minisql-transaction-wal-ml-1295189914"></a>
### scan

```ml
function scan(writer, repairTail)
```

Scans the requested value. Inputs: `writer`, `repairTail`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `repairTail` | `dynamic` | — | repairTail value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L826)

<a id="function-function-minisql-transaction-wal-scanfile-function-scanfile-file-encryptionkey-src-minisql-transaction-wal-ml-8707740"></a>
### scanFile

```ml
function scanFile(file, encryptionKey)
```

Scans the file. Inputs: `file`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `file` | `dynamic` | — | file value consumed by this operation. |
| `encryptionKey` | `dynamic` | — | encryptionKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L491)

<a id="function-function-minisql-transaction-wal-scansnapshot-function-scansnapshot-source-src-minisql-transaction-wal-ml-1827890139"></a>
### scanSnapshot

```ml
function scanSnapshot(source)
```

Scans the snapshot. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L520)

<a id="function-function-minisql-transaction-wal-scansnapshotforpath-function-scansnapshotforpath-source-walpath-src-minisql-transaction-wal-ml-95926036"></a>
### scanSnapshotForPath

```ml
function scanSnapshotForPath(source, walPath)
```

Scans a WAL snapshot using the database key resolved from its path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `walPath` | `dynamic` | — | Path associated with wal. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L527)

<a id="function-function-minisql-transaction-wal-scansnapshotwithkey-function-scansnapshotwithkey-source-encryptionkey-src-minisql-transaction-wal-ml-1300245849"></a>
### scanSnapshotWithKey

```ml
function scanSnapshotWithKey(source, encryptionKey)
```

Scans a bounded snapshot containing plaintext or encrypted records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `encryptionKey` | `dynamic` | — | encryptionKey value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L539)

<a id="function-function-minisql-transaction-wal-segmentnumber-function-segmentnumber-writer-lsn-src-minisql-transaction-wal-ml-1265920074"></a>
### segmentNumber

```ml
function segmentNumber(writer, lsn)
```

Performs the segment number operation for this module. Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L629)

<a id="function-function-minisql-transaction-wal-segmentoffset-function-segmentoffset-writer-lsn-src-minisql-transaction-wal-ml-1219776114"></a>
### segmentOffset

```ml
function segmentOffset(writer, lsn)
```

Performs the segment offset operation for this module. Inputs: `writer`, `lsn`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L639)

<a id="function-function-minisql-transaction-wal-targetmilestone-function-targetmilestone-src-minisql-transaction-wal-ml-1227326512"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql transaction wal module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L915)

<a id="constant-constant-minisql-transaction-wal-unsupported-format-const-unsupported-format-9003-src-minisql-transaction-wal-ml-1857691143"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql transaction wal module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L21)

<a id="function-function-minisql-transaction-wal-validatenative-function-validatenative-value-operation-name-src-minisql-transaction-wal-ml-1785952243"></a>
### validateNative

```ml
function validateNative(value, operation, name)
```

Validates native for the minisql transaction wal workflow. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L197)

<a id="function-function-minisql-transaction-wal-validateopen-function-validateopen-writer-operation-src-minisql-transaction-wal-ml-420631446"></a>
### validateOpen

```ml
function validateOpen(writer, operation)
```

Validates open for the minisql transaction wal workflow. Inputs: `writer`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `writer` | `dynamic` | — | writer value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L618)

<a id="function-function-minisql-transaction-wal-validaterecord-function-validaterecord-record-operation-src-minisql-transaction-wal-ml-1244178532"></a>
### validateRecord

```ml
function validateRecord(record, operation)
```

Validates the record. Inputs: `record`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | record value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L339)

<a id="function-function-minisql-transaction-wal-validaterecordtype-function-validaterecordtype-recordtype-operation-src-minisql-transaction-wal-ml-971576724"></a>
### validateRecordType

```ml
function validateRecordType(recordType, operation)
```

Validates the record type. Inputs: `recordType`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recordType` | `dynamic` | — | recordType value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L219)

<a id="function-function-minisql-transaction-wal-validatesegmentbytes-function-validatesegmentbytes-segmentbytes-operation-src-minisql-transaction-wal-ml-59993947"></a>
### validateSegmentBytes

```ml
function validateSegmentBytes(segmentBytes, operation)
```

Validates the segment bytes. Inputs: `segmentBytes`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `segmentBytes` | `dynamic` | — | segmentBytes value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L567)

<a id="function-function-minisql-transaction-wal-walaad-function-walaad-record-src-minisql-transaction-wal-ml-1107537779"></a>
### walAad

```ml
function walAad(record)
```

Decodes the record. Inputs: `source`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | record value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L387)

- [minisql.transaction.wal.WalAppendBatch](Type-minisql-transaction-wal-walappendbatch-530879772.md) — struct
- [minisql.transaction.wal.WalRecord](Type-minisql-transaction-wal-walrecord-464994145.md) — struct
- [minisql.transaction.wal.WalScan](Type-minisql-transaction-wal-walscan-1549767333.md) — struct
- [minisql.transaction.wal.WalWriter](Type-minisql-transaction-wal-walwriter-1814373443.md) — struct
<a id="function-function-minisql-transaction-wal-writedurablemarker-function-writedurablemarker-walpath-lsn-src-minisql-transaction-wal-ml-31016566"></a>
### writeDurableMarker

```ml
function writeDurableMarker(walPath, lsn)
```

Writes the durable marker. Inputs: `walPath`, `lsn`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `walPath` | `dynamic` | — | Path associated with wal. |
| `lsn` | `dynamic` | — | lsn value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/transaction/wal.ml#L289)
