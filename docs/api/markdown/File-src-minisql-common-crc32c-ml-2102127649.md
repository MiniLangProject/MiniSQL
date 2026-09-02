# `src/minisql/common/crc32c.ml`

[Home](README.md) · [Files](Files.md)

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

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L73)

<a id="function-function-minisql-common-crc32c-compute-function-compute-buffer-src-minisql-common-crc32c-ml-2143744414"></a>
### compute

```ml
function compute(buffer)
```

Computes the requested value. Inputs: `buffer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L55)

<a id="function-function-minisql-common-crc32c-computerange-function-computerange-buffer-offset-length-src-minisql-common-crc32c-ml-132163775"></a>
### computeRange

```ml
function computeRange(buffer, offset, length)
```

Computes the range. Inputs: `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L49)

<a id="function-function-minisql-common-crc32c-invalid-function-invalid-operation-message-src-minisql-common-crc32c-ml-542999196"></a>
### invalid

```ml
function invalid(operation, message)
```

Creates an invalid-argument error with operation context. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L18)

<a id="constant-constant-minisql-common-crc32c-invalid-argument-const-invalid-argument-9001-src-minisql-common-crc32c-ml-875172417"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

MiniSQL's stable CRC-32C facade preserves its structured error contract while delegating the checksum hot path to MiniLang's CPU-dispatched implementation. The standard primitive uses SSE4.2 on supported processors and an exact Castagnoli lookup-table fallback everywhere else.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L13)

<a id="function-function-minisql-common-crc32c-isimplemented-function-isimplemented-src-minisql-common-crc32c-ml-681260826"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L85)

<a id="constant-constant-minisql-common-crc32c-max-u32-const-max-u32-4294967295-src-minisql-common-crc32c-ml-1700760274"></a>
### MAX_U32

```ml
const MAX_U32 = 4294967295
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L14)

<a id="function-function-minisql-common-crc32c-targetmilestone-function-targetmilestone-src-minisql-common-crc32c-ml-499543736"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L79)

<a id="function-function-minisql-common-crc32c-update-function-update-previous-buffer-offset-length-src-minisql-common-crc32c-ml-280192266"></a>
### update

```ml
function update(previous, buffer, offset, length)
```

Continues a finalized CRC-32C value over the requested byte range. Inputs: `previous`, `buffer`, `offset`, `length`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `previous` | `dynamic` | — |  |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L39)

<a id="function-function-minisql-common-crc32c-validaterange-function-validaterange-buffer-offset-length-operation-src-minisql-common-crc32c-ml-1376068524"></a>
### validateRange

```ml
function validateRange(buffer, offset, length, operation)
```

Validates the range. Inputs: `buffer`, `offset`, `length`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L24)

<a id="function-function-minisql-common-crc32c-verifyrange-function-verifyrange-buffer-offset-length-expected-src-minisql-common-crc32c-ml-1408395411"></a>
### verifyRange

```ml
function verifyRange(buffer, offset, length, expected)
```

Verifies the range. Inputs: `buffer`, `offset`, `length`, `expected`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |
| `expected` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/crc32c.ml#L64)
