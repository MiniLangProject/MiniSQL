# `src/minisql/storage/checksum.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.storage.checksum`](Package-minisql-storage-checksum-997838882.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)

## Declarations

<a id="constant-constant-minisql-storage-checksum-algorithm-crc32c-const-algorithm-crc32c-1-src-minisql-storage-checksum-ml-1365832422"></a>
### ALGORITHM_CRC32C

```ml
const ALGORITHM_CRC32C = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L17)

<a id="constant-constant-minisql-storage-checksum-algorithm-none-const-algorithm-none-0-src-minisql-storage-checksum-ml-318745161"></a>
### ALGORITHM_NONE

```ml
const ALGORITHM_NONE = 0
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L16)

<a id="function-function-minisql-storage-checksum-bytesequal-function-bytesequal-left-right-src-minisql-storage-checksum-ml-1377846155"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytes equal operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L74)

<a id="function-function-minisql-storage-checksum-componentname-function-componentname-src-minisql-storage-checksum-ml-1103900248"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L188)

<a id="function-function-minisql-storage-checksum-compute-function-compute-algorithm-buffer-offset-length-src-minisql-storage-checksum-ml-1370988998"></a>
### compute

```ml
function compute(algorithm, buffer, offset, length)
```

Computes the requested value. Inputs: `algorithm`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `dynamic` | — |  |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L96)

<a id="function-function-minisql-storage-checksum-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-checksum-ml-1045951745"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L87)

<a id="constant-constant-minisql-storage-checksum-corrupt-data-const-corrupt-data-9004-src-minisql-storage-checksum-ml-1093335900"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L15)

<a id="function-function-minisql-storage-checksum-decodeenvelope-function-decodeenvelope-source-expectedmagic-expectedversion-expectedkind-src-minisql-storage-checksum-ml-675708118"></a>
### decodeEnvelope

```ml
function decodeEnvelope(source, expectedMagic, expectedVersion, expectedKind)
```

Decodes the envelope. Inputs: `source`, `expectedMagic`, `expectedVersion`, `expectedKind`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `expectedMagic` | `dynamic` | — |  |
| `expectedVersion` | `dynamic` | — |  |
| `expectedKind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L142)

<a id="function-function-minisql-storage-checksum-encodeenvelope-function-encodeenvelope-magic-version-kind-flags-payload-src-minisql-storage-checksum-ml-1602467716"></a>
### encodeEnvelope

```ml
function encodeEnvelope(magic, version, kind, flags, payload)
```

Encodes the envelope. Inputs: `magic`, `version`, `kind`, `flags`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `magic` | `dynamic` | — |  |
| `version` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `payload` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L112)

- [minisql.storage.checksum.Envelope](Type-minisql-storage-checksum-envelope-1228406520.md) — struct
<a id="constant-constant-minisql-storage-checksum-envelope-checksum-offset-const-envelope-checksum-offset-24-src-minisql-storage-checksum-ml-188061911"></a>
### ENVELOPE_CHECKSUM_OFFSET

```ml
const ENVELOPE_CHECKSUM_OFFSET = 24
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L19)

<a id="constant-constant-minisql-storage-checksum-envelope-header-size-const-envelope-header-size-32-src-minisql-storage-checksum-ml-662317724"></a>
### ENVELOPE_HEADER_SIZE

```ml
const ENVELOPE_HEADER_SIZE = 32
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L18)

<a id="function-function-minisql-storage-checksum-fail-function-fail-code-operation-message-src-minisql-storage-checksum-ml-1664279283"></a>
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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L41)

<a id="constant-constant-minisql-storage-checksum-invalid-argument-const-invalid-argument-9001-src-minisql-storage-checksum-ml-321064213"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Generic checksum envelope for sidecar and metadata payloads. The fixed header binds format version, object kind, payload length, and selected checksum algorithm so decoders can reject incompatible or truncated data early.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L13)

<a id="function-function-minisql-storage-checksum-isimplemented-function-isimplemented-src-minisql-storage-checksum-ml-597318736"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L200)

<a id="function-function-minisql-storage-checksum-targetmilestone-function-targetmilestone-src-minisql-storage-checksum-ml-70478226"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L194)

<a id="constant-constant-minisql-storage-checksum-unsupported-format-const-unsupported-format-9003-src-minisql-storage-checksum-ml-461183731"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L14)

<a id="function-function-minisql-storage-checksum-validatemagic-function-validatemagic-magic-operation-src-minisql-storage-checksum-ml-1297379006"></a>
### validateMagic

```ml
function validateMagic(magic, operation)
```

Validates the magic. Inputs: `magic`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `magic` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L47)

<a id="function-function-minisql-storage-checksum-validateu16-function-validateu16-value-operation-name-src-minisql-storage-checksum-ml-225364923"></a>
### validateU16

```ml
function validateU16(value, operation, name)
```

Validates the u16. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L56)

<a id="function-function-minisql-storage-checksum-validateu32-function-validateu32-value-operation-name-src-minisql-storage-checksum-ml-1266453647"></a>
### validateU32

```ml
function validateU32(value, operation, name)
```

Validates the u32. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L65)

<a id="function-function-minisql-storage-checksum-verify-function-verify-algorithm-buffer-offset-length-expected-src-minisql-storage-checksum-ml-619603340"></a>
### verify

```ml
function verify(algorithm, buffer, offset, length, expected)
```

Verifies the requested value. Inputs: `algorithm`, `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `dynamic` | — |  |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |
| `expected` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L105)
