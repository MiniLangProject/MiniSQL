# `src/minisql/common/crc32c.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common crc32c facilities for this project.

Package: [`minisql.common.crc32c`](Package-minisql-common-crc32c-843614877.md)

Reachable from entry: **yes**

## Imports

- `std/checksum/crc32c.ml` as `stdCrc32c` → `../MiniLangCompilerML/std/checksum/crc32c.ml` — external dependency

## Declarations

<a id="function-function-minisql-common-crc32c-componentname-function-componentname-src-minisql-common-crc32c-ml-1264954026"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common crc32c module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L91)

<a id="function-function-minisql-common-crc32c-compute-function-compute-buffer-src-minisql-common-crc32c-ml-2143744414"></a>
### compute

```ml
function compute(buffer)
```

Computes the requested value. Inputs: `buffer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L69)

<a id="function-function-minisql-common-crc32c-computerange-function-computerange-buffer-offset-length-src-minisql-common-crc32c-ml-132163775"></a>
### computeRange

```ml
function computeRange(buffer, offset, length)
```

Computes the range. Inputs: `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L62)

<a id="function-function-minisql-common-crc32c-invalid-function-invalid-operation-message-src-minisql-common-crc32c-ml-542999196"></a>
### invalid

```ml
function invalid(operation, message)
```

Performs the invalid operation for the minisql common crc32c module. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L20)

<a id="constant-constant-minisql-common-crc32c-invalid-argument-const-invalid-argument-9001-src-minisql-common-crc32c-ml-875172417"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

MiniSQL's stable CRC-32C facade preserves its structured error contract while


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L12)

<a id="function-function-minisql-common-crc32c-isimplemented-function-isimplemented-src-minisql-common-crc32c-ml-681260826"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common crc32c module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L103)

<a id="constant-constant-minisql-common-crc32c-max-u32-const-max-u32-4294967295-src-minisql-common-crc32c-ml-1700760274"></a>
### MAX_U32

```ml
const MAX_U32 = 4294967295
```

Defines the max u32 constant used by the minisql common crc32c module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L14)

<a id="function-function-minisql-common-crc32c-targetmilestone-function-targetmilestone-src-minisql-common-crc32c-ml-499543736"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql common crc32c module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L97)

<a id="function-function-minisql-common-crc32c-update-function-update-previous-buffer-offset-length-src-minisql-common-crc32c-ml-280192266"></a>
### update

```ml
function update(previous, buffer, offset, length)
```

Continues a finalized CRC-32C value over the requested byte range. Inputs: `previous`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previous` | `dynamic` | — | previous value consumed by this operation. |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L49)

<a id="function-function-minisql-common-crc32c-validaterange-function-validaterange-buffer-offset-length-operation-src-minisql-common-crc32c-ml-1376068524"></a>
### validateRange

```ml
function validateRange(buffer, offset, length, operation)
```

Validates the range. Inputs: `buffer`, `offset`, `length`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L30)

<a id="function-function-minisql-common-crc32c-verifyrange-function-verifyrange-buffer-offset-length-expected-src-minisql-common-crc32c-ml-1408395411"></a>
### verifyRange

```ml
function verifyRange(buffer, offset, length, expected)
```

Verifies the range. Inputs: `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `length` | `dynamic` | — | length value consumed by this operation. |
| `expected` | `dynamic` | — | expected value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L82)
