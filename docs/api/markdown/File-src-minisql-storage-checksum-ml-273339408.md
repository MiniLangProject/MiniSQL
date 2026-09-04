# `src/minisql/storage/checksum.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage checksum facilities for this project.

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

Defines the algorithm crc32 c constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L21)

<a id="constant-constant-minisql-storage-checksum-algorithm-none-const-algorithm-none-0-src-minisql-storage-checksum-ml-318745161"></a>
### ALGORITHM_NONE

```ml
const ALGORITHM_NONE = 0
```

Defines the algorithm none constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L19)

<a id="function-function-minisql-storage-checksum-bytesequal-function-bytesequal-left-right-src-minisql-storage-checksum-ml-1377846155"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql storage checksum module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L93)

<a id="function-function-minisql-storage-checksum-componentname-function-componentname-src-minisql-storage-checksum-ml-1103900248"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage checksum module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L230)

<a id="function-function-minisql-storage-checksum-compute-function-compute-algorithm-buffer-offset-length-src-minisql-storage-checksum-ml-1370988998"></a>
### compute

```ml
function compute(algorithm, buffer, offset, length)
```

Computes the requested value. Inputs: `algorithm`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `dynamic` | — | algorithm value consumed by this operation. |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L124)

<a id="function-function-minisql-storage-checksum-copyexact-function-copyexact-destination-destinationoffset-source-sourceoffset-count-src-minisql-storage-checksum-ml-1045951745"></a>
### copyExact

```ml
function copyExact(destination, destinationOffset, source, sourceOffset, count)
```

Performs the copyExact operation for the minisql storage checksum module. Inputs: `destination`, `destinationOffset`, `source`, `sourceOffset`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | destination value consumed by this operation. |
| `destinationOffset` | `dynamic` | — | destinationOffset value consumed by this operation. |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `sourceOffset` | `dynamic` | — | sourceOffset value consumed by this operation. |
| `count` | `dynamic` | — | Number of items or units to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L111)

<a id="constant-constant-minisql-storage-checksum-corrupt-data-const-corrupt-data-9004-src-minisql-storage-checksum-ml-1093335900"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L17)

<a id="function-function-minisql-storage-checksum-decodeenvelope-function-decodeenvelope-source-expectedmagic-expectedversion-expectedkind-src-minisql-storage-checksum-ml-675708118"></a>
### decodeEnvelope

```ml
function decodeEnvelope(source, expectedMagic, expectedVersion, expectedKind)
```

Decodes the envelope. Inputs: `source`, `expectedMagic`, `expectedVersion`, `expectedKind`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `expectedMagic` | `dynamic` | — | expectedMagic value consumed by this operation. |
| `expectedVersion` | `dynamic` | — | expectedVersion value consumed by this operation. |
| `expectedKind` | `dynamic` | — | expectedKind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L184)

<a id="function-function-minisql-storage-checksum-encodeenvelope-function-encodeenvelope-magic-version-kind-flags-payload-src-minisql-storage-checksum-ml-1602467716"></a>
### encodeEnvelope

```ml
function encodeEnvelope(magic, version, kind, flags, payload)
```

Encodes the envelope. Inputs: `magic`, `version`, `kind`, `flags`, `payload`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `magic` | `dynamic` | — | magic value consumed by this operation. |
| `version` | `dynamic` | — | version value consumed by this operation. |
| `kind` | `dynamic` | — | kind value consumed by this operation. |
| `flags` | `dynamic` | — | Bit flags controlling the operation. |
| `payload` | `dynamic` | — | payload value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L150)

- [minisql.storage.checksum.Envelope](Type-minisql-storage-checksum-envelope-1228406520.md) — struct
<a id="constant-constant-minisql-storage-checksum-envelope-checksum-offset-const-envelope-checksum-offset-24-src-minisql-storage-checksum-ml-188061911"></a>
### ENVELOPE_CHECKSUM_OFFSET

```ml
const ENVELOPE_CHECKSUM_OFFSET = 24
```

Defines the envelope checksum offset constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L25)

<a id="constant-constant-minisql-storage-checksum-envelope-header-size-const-envelope-header-size-32-src-minisql-storage-checksum-ml-662317724"></a>
### ENVELOPE_HEADER_SIZE

```ml
const ENVELOPE_HEADER_SIZE = 32
```

Defines the envelope header size constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L23)

<a id="function-function-minisql-storage-checksum-fail-function-fail-code-operation-message-src-minisql-storage-checksum-ml-1664279283"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage checksum module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L50)

<a id="constant-constant-minisql-storage-checksum-invalid-argument-const-invalid-argument-9001-src-minisql-storage-checksum-ml-321064213"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Generic checksum envelope for sidecar and metadata payloads. The fixed header


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L13)

<a id="function-function-minisql-storage-checksum-isimplemented-function-isimplemented-src-minisql-storage-checksum-ml-597318736"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage checksum module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L242)

<a id="function-function-minisql-storage-checksum-targetmilestone-function-targetmilestone-src-minisql-storage-checksum-ml-70478226"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage checksum module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L236)

<a id="constant-constant-minisql-storage-checksum-unsupported-format-const-unsupported-format-9003-src-minisql-storage-checksum-ml-461183731"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql storage checksum module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L15)

<a id="function-function-minisql-storage-checksum-validatemagic-function-validatemagic-magic-operation-src-minisql-storage-checksum-ml-1297379006"></a>
### validateMagic

```ml
function validateMagic(magic, operation)
```

Validates the magic. Inputs: `magic`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `magic` | `dynamic` | — | magic value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L58)

<a id="function-function-minisql-storage-checksum-validateu16-function-validateu16-value-operation-name-src-minisql-storage-checksum-ml-225364923"></a>
### validateU16

```ml
function validateU16(value, operation, name)
```

Validates the u16. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L70)

<a id="function-function-minisql-storage-checksum-validateu32-function-validateu32-value-operation-name-src-minisql-storage-checksum-ml-1266453647"></a>
### validateU32

```ml
function validateU32(value, operation, name)
```

Validates the u32. Inputs: `value`, `operation`, `name`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `name` | `dynamic` | — | Name of the affected item. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L82)

<a id="function-function-minisql-storage-checksum-verify-function-verify-algorithm-buffer-offset-length-expected-src-minisql-storage-checksum-ml-619603340"></a>
### verify

```ml
function verify(algorithm, buffer, offset, length, expected)
```

Performs the verify operation for the minisql storage checksum module. Inputs: `algorithm`, `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `algorithm` | `dynamic` | — | algorithm value consumed by this operation. |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/checksum.ml#L138)
