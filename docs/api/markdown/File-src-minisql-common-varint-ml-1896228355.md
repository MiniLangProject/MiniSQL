# `src/minisql/common/varint.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common varint facilities for this project.

Package: [`minisql.common.varint`](Package-minisql-common-varint-2057421671.md)

Reachable from entry: **no**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)

## Declarations

<a id="function-function-minisql-common-varint-componentname-function-componentname-src-minisql-common-varint-ml-344659426"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common varint module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L328)

<a id="function-function-minisql-common-varint-corrupt-function-corrupt-operation-message-src-minisql-common-varint-ml-962564292"></a>
### corrupt

```ml
function corrupt(operation, message)
```

Performs the corrupt operation for this module. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L52)

<a id="constant-constant-minisql-common-varint-corrupt-data-const-corrupt-data-9004-src-minisql-common-varint-ml-251948934"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql common varint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L14)

<a id="function-function-minisql-common-varint-encodedlengthu32-function-encodedlengthu32-value-src-minisql-common-varint-ml-1141514753"></a>
### encodedLengthU32

```ml
function encodedLengthU32(value)
```

Encodes the d length u32. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L94)

<a id="function-function-minisql-common-varint-encodedlengthu64-function-encodedlengthu64-value-src-minisql-common-varint-ml-655623993"></a>
### encodedLengthU64

```ml
function encodedLengthU64(value)
```

Encodes the d length u64. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L110)

<a id="function-function-minisql-common-varint-invalid-function-invalid-operation-message-src-minisql-common-varint-ml-1475661228"></a>
### invalid

```ml
function invalid(operation, message)
```

Performs the invalid operation for the minisql common varint module. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L44)

<a id="constant-constant-minisql-common-varint-invalid-argument-const-invalid-argument-9001-src-minisql-common-varint-ml-2068598785"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Canonical unsigned LEB128 plus ZigZag signed codecs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L12)

<a id="function-function-minisql-common-varint-isimplemented-function-isimplemented-src-minisql-common-varint-ml-688073018"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common varint module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L340)

<a id="constant-constant-minisql-common-varint-max-u32-bytes-const-max-u32-bytes-5-src-minisql-common-varint-ml-365598440"></a>
### MAX_U32_BYTES

```ml
const MAX_U32_BYTES = 5
```

Defines the max u32 bytes constant used by the minisql common varint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L16)

<a id="constant-constant-minisql-common-varint-max-u64-bytes-const-max-u64-bytes-10-src-minisql-common-varint-ml-1486673076"></a>
### MAX_U64_BYTES

```ml
const MAX_U64_BYTES = 10
```

Defines the max u64 bytes constant used by the minisql common varint module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L18)

<a id="function-function-minisql-common-varint-readi32-function-readi32-buffer-offset-src-minisql-common-varint-ml-1655665547"></a>
### readI32

```ml
function readI32(buffer, offset)
```

Reads the i32. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L275)

<a id="function-function-minisql-common-varint-readi64-function-readi64-buffer-offset-src-minisql-common-varint-ml-1703899737"></a>
### readI64

```ml
function readI64(buffer, offset)
```

Reads the i64. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L321)

<a id="function-function-minisql-common-varint-readu32-function-readu32-buffer-offset-src-minisql-common-varint-ml-1246037371"></a>
### readU32

```ml
function readU32(buffer, offset)
```

Reads the u32. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L146)

<a id="function-function-minisql-common-varint-readu64-function-readu64-buffer-offset-src-minisql-common-varint-ml-718251201"></a>
### readU64

```ml
function readU64(buffer, offset)
```

Reads the u64. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L198)

<a id="function-function-minisql-common-varint-targetmilestone-function-targetmilestone-src-minisql-common-varint-ml-1474775132"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql common varint module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L334)

<a id="function-function-minisql-common-varint-validatebufferoffset-function-validatebufferoffset-buffer-offset-operation-src-minisql-common-varint-ml-1278018834"></a>
### validateBufferOffset

```ml
function validateBufferOffset(buffer, offset, operation)
```

Validates the buffer offset. Inputs: `buffer`, `offset`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L61)

<a id="function-function-minisql-common-varint-validatewriterange-function-validatewriterange-buffer-offset-width-operation-src-minisql-common-varint-ml-617212410"></a>
### validateWriteRange

```ml
function validateWriteRange(buffer, offset, width, operation)
```

Validates the write range. Inputs: `buffer`, `offset`, `width`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `width` | `dynamic` | — | Width in the coordinate or storage units used by the caller. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L80)

- [minisql.common.varint.Varint32Result](Type-minisql-common-varint-varint32result-1135300293.md) — struct
- [minisql.common.varint.Varint64Result](Type-minisql-common-varint-varint64result-1745848426.md) — struct
<a id="function-function-minisql-common-varint-writei32-function-writei32-buffer-offset-value-src-minisql-common-varint-ml-730851666"></a>
### writeI32

```ml
function writeI32(buffer, offset, value)
```

Writes the i32. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L267)

<a id="function-function-minisql-common-varint-writei64-function-writei64-buffer-offset-value-src-minisql-common-varint-ml-1334453846"></a>
### writeI64

```ml
function writeI64(buffer, offset, value)
```

Writes the i64. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L313)

<a id="function-function-minisql-common-varint-writeu32-function-writeu32-buffer-offset-value-src-minisql-common-varint-ml-671714290"></a>
### writeU32

```ml
function writeU32(buffer, offset, value)
```

Writes the u32. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L128)

<a id="function-function-minisql-common-varint-writeu64-function-writeu64-buffer-offset-value-src-minisql-common-varint-ml-717802894"></a>
### writeU64

```ml
function writeU64(buffer, offset, value)
```

Writes the u64. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L178)

<a id="function-function-minisql-common-varint-zigzagdecodei32-function-zigzagdecodei32-value-src-minisql-common-varint-ml-1073412801"></a>
### zigZagDecodeI32

```ml
function zigZagDecodeI32(value)
```

Performs the zig zag decode i32 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L251)

<a id="function-function-minisql-common-varint-zigzagdecodei64-function-zigzagdecodei64-value-src-minisql-common-varint-ml-1276168987"></a>
### zigZagDecodeI64

```ml
function zigZagDecodeI64(value)
```

Performs the zig zag decode i64 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L297)

<a id="function-function-minisql-common-varint-zigzagencodei32-function-zigzagencodei32-value-src-minisql-common-varint-ml-680792409"></a>
### zigZagEncodeI32

```ml
function zigZagEncodeI32(value)
```

Performs the zig zag encode i32 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L238)

<a id="function-function-minisql-common-varint-zigzagencodei64-function-zigzagencodei64-value-src-minisql-common-varint-ml-1451841023"></a>
### zigZagEncodeI64

```ml
function zigZagEncodeI64(value)
```

Performs the zig zag encode i64 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/varint.ml#L283)
