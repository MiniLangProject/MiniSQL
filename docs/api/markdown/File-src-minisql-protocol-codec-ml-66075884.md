# `src/minisql/protocol/codec.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql protocol codec facilities for this project.

Package: [`minisql.protocol.codec`](Package-minisql-protocol-codec-1695794568.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/crc32c.ml` as `crc32c` → [src/minisql/common/crc32c.ml](File-src-minisql-common-crc32c-ml-2102127649.md)
- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)

## Declarations

<a id="function-function-minisql-protocol-codec-componentname-function-componentname-src-minisql-protocol-codec-ml-167344938"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql protocol codec module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L168)

<a id="function-function-minisql-protocol-codec-copyrange-function-copyrange-source-offset-count-operation-src-minisql-protocol-codec-ml-916468148"></a>
### copyRange

```ml
function copyRange(source, offset, count, operation)
```

Implements copy range for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `count` | `dynamic` | — | Number of items or units to process. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L61)

<a id="constant-constant-minisql-protocol-codec-corrupt-data-const-corrupt-data-9004-src-minisql-protocol-codec-ml-1584260330"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql protocol codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L19)

<a id="function-function-minisql-protocol-codec-decodeheader-function-decodeheader-source-src-minisql-protocol-codec-ml-2086991909"></a>
### decodeHeader

```ml
function decodeHeader(source)
```

Decodes header using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L118)

<a id="function-function-minisql-protocol-codec-decodemessage-function-decodemessage-source-src-minisql-protocol-codec-ml-1244312395"></a>
### decodeMessage

```ml
function decodeMessage(source)
```

Decodes message using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L152)

<a id="function-function-minisql-protocol-codec-encodeheader-function-encodeheader-message-src-minisql-protocol-codec-ml-529012203"></a>
### encodeHeader

```ml
function encodeHeader(message)
```

Encodes header using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L97)

<a id="function-function-minisql-protocol-codec-encodemessage-function-encodemessage-message-src-minisql-protocol-codec-ml-1635379925"></a>
### encodeMessage

```ml
function encodeMessage(message)
```

Encodes message using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L139)

<a id="function-function-minisql-protocol-codec-fail-function-fail-code-operation-message-src-minisql-protocol-codec-ml-2006222549"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql protocol codec module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L41)

- [minisql.protocol.codec.Header](Type-minisql-protocol-codec-header-559488939.md) — struct
<a id="constant-constant-minisql-protocol-codec-invalid-argument-const-invalid-argument-9001-src-minisql-protocol-codec-ml-702980279"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql protocol codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L15)

<a id="function-function-minisql-protocol-codec-isheader-function-isheader-value-src-minisql-protocol-codec-ml-509824949"></a>
### isHeader

```ml
function isHeader(value)
```

Returns whether the supplied value satisfies the header condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L49)

<a id="function-function-minisql-protocol-codec-isimplemented-function-isimplemented-src-minisql-protocol-codec-ml-740447378"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql protocol codec module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L182)

<a id="function-function-minisql-protocol-codec-magicmatches-function-magicmatches-source-src-minisql-protocol-codec-ml-114462569"></a>
### magicMatches

```ml
function magicMatches(source)
```

Implements magic matches for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | source value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L84)

<a id="function-function-minisql-protocol-codec-targetmilestone-function-targetmilestone-src-minisql-protocol-codec-ml-1844068236"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql protocol codec module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L175)

<a id="constant-constant-minisql-protocol-codec-unsupported-format-const-unsupported-format-9003-src-minisql-protocol-codec-ml-1316412849"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql protocol codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L17)

<a id="function-function-minisql-protocol-codec-writemagic-function-writemagic-output-src-minisql-protocol-codec-ml-417899021"></a>
### writeMagic

```ml
function writeMagic(output)
```

Writes magic using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output` | `dynamic` | — | Output collection or buffer populated by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/protocol/codec.ml#L74)
