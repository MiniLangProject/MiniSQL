# `src/minisql/storage/row_codec.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql storage row codec facilities for this project.

Package: [`minisql.storage.row_codec`](Package-minisql-storage-row-codec-1408594286.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/common/float_codec.ml` as `float_codec` → [src/minisql/common/float_codec.ml](File-src-minisql-common-float-codec-ml-1746004680.md)
- `minisql/common/format_version.ml` as `format_version` → [src/minisql/common/format_version.ml](File-src-minisql-common-format-version-ml-1671630705.md)

## Declarations

<a id="function-function-minisql-storage-row-codec-alignoffset-function-alignoffset-offset-alignment-src-minisql-storage-row-codec-ml-305971170"></a>
### alignOffset

```ml
function alignOffset(offset, alignment)
```

Rounds an offset upward to its natural power-of-two alignment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offset` | `dynamic` | — | Non-negative byte offset. |
| `alignment` | `dynamic` | — | Required alignment in bytes. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L149)

<a id="function-function-minisql-storage-row-codec-bytesequal-function-bytesequal-left-right-src-minisql-storage-row-codec-ml-598731699"></a>
### bytesEqual

```ml
function bytesEqual(left, right)
```

Performs the bytesEqual operation for the minisql storage row codec module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L137)

<a id="function-function-minisql-storage-row-codec-column-function-column-typecode-nullable-maxlength-precision-scale-src-minisql-storage-row-codec-ml-1524663962"></a>
### column

```ml
function column(typeCode, nullable, maxLength, precision, scale)
```

Performs the column operation for this module. Inputs: `typeCode`, `nullable`, `maxLength`, `precision`, `scale`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | typeCode value consumed by this operation. |
| `nullable` | `dynamic` | — | nullable value consumed by this operation. |
| `maxLength` | `dynamic` | — | maxLength value consumed by this operation. |
| `precision` | `dynamic` | — | precision value consumed by this operation. |
| `scale` | `dynamic` | — | scale value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L231)

- [minisql.storage.row_codec.ColumnSpec](Type-minisql-storage-row-codec-columnspec-758963501.md) — struct
<a id="function-function-minisql-storage-row-codec-componentname-function-componentname-src-minisql-storage-row-codec-ml-1469793138"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql storage row codec module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L542)

<a id="constant-constant-minisql-storage-row-codec-corrupt-data-const-corrupt-data-9004-src-minisql-storage-row-codec-ml-1601240734"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```

Defines the corrupt data constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L18)

<a id="function-function-minisql-storage-row-codec-decodealigned-function-decodealigned-rowschema-encoded-compatible-src-minisql-storage-row-codec-ml-2053119171"></a>
### decodeAligned

```ml
function decodeAligned(rowSchema, encoded, compatible)
```

Shared v2 decoder: checks canonical alignment, all padding, and schema shape.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — | Schema used to decode physical column values. |
| `encoded` | `dynamic` | — | Complete row bytes, including zero tail padding. |
| `compatible` | `dynamic` | — | Whether an older schema with a matching column prefix is accepted. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L469)

<a id="function-function-minisql-storage-row-codec-decodebinary-function-decodebinary-spec-encoded-src-minisql-storage-row-codec-ml-975449589"></a>
### decodeBinary

```ml
function decodeBinary(spec, encoded)
```

Decodes the binary. Inputs: `spec`, `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L336)

<a id="function-function-minisql-storage-row-codec-decodecompatible-function-decodecompatible-rowschema-encoded-src-minisql-storage-row-codec-ml-369361365"></a>
### decodeCompatible

```ml
function decodeCompatible(rowSchema, encoded)
```

Decodes the compatible. Inputs: `rowSchema`, `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — | rowSchema value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L461)

<a id="function-function-minisql-storage-row-codec-decoderow-function-decoderow-rowschema-encoded-src-minisql-storage-row-codec-ml-1585141317"></a>
### decodeRow

```ml
function decodeRow(rowSchema, encoded)
```

Decodes the row. Inputs: `rowSchema`, `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — | rowSchema value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L453)

<a id="function-function-minisql-storage-row-codec-decodescalar-function-decodescalar-spec-encoded-src-minisql-storage-row-codec-ml-670523345"></a>
### decodeScalar

```ml
function decodeScalar(spec, encoded)
```

Decodes the scalar. Inputs: `spec`, `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L346)

<a id="function-function-minisql-storage-row-codec-decodetext-function-decodetext-spec-encoded-src-minisql-storage-row-codec-ml-1197078753"></a>
### decodeText

```ml
function decodeText(spec, encoded)
```

Decodes the text. Inputs: `spec`, `encoded`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `encoded` | `dynamic` | — | encoded value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L324)

<a id="constant-constant-minisql-storage-row-codec-directory-entry-size-const-directory-entry-size-8-src-minisql-storage-row-codec-ml-1493453633"></a>
### DIRECTORY_ENTRY_SIZE

```ml
const DIRECTORY_ENTRY_SIZE = 8
```

Defines the directory entry size constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L27)

<a id="function-function-minisql-storage-row-codec-encode-function-encode-rowschema-values-src-minisql-storage-row-codec-ml-301403203"></a>
### encode

```ml
function encode(rowSchema, values)
```

Encodes encode for the minisql storage row codec workflow. Inputs: `rowSchema`, `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — | rowSchema value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L376)

<a id="function-function-minisql-storage-row-codec-encodebinary-function-encodebinary-spec-value-src-minisql-storage-row-codec-ml-572243650"></a>
### encodeBinary

```ml
function encodeBinary(spec, value)
```

Encodes the binary. Inputs: `spec`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L275)

<a id="function-function-minisql-storage-row-codec-encoderow-function-encoderow-rowschema-values-src-minisql-storage-row-codec-ml-1440850843"></a>
### encodeRow

```ml
function encodeRow(rowSchema, values)
```

Encodes the row. Inputs: `rowSchema`, `values`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rowSchema` | `dynamic` | — | rowSchema value consumed by this operation. |
| `values` | `dynamic` | — | values value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L445)

<a id="function-function-minisql-storage-row-codec-encodescalar-function-encodescalar-spec-value-src-minisql-storage-row-codec-ml-1998781438"></a>
### encodeScalar

```ml
function encodeScalar(spec, value)
```

Encodes the scalar. Inputs: `spec`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L286)

<a id="function-function-minisql-storage-row-codec-encodetext-function-encodetext-spec-value-src-minisql-storage-row-codec-ml-1734285986"></a>
### encodeText

```ml
function encodeText(spec, value)
```

Encodes the text. Inputs: `spec`, `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `spec` | `dynamic` | — | spec value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L258)

<a id="function-function-minisql-storage-row-codec-external-function-external-encodedpointer-src-minisql-storage-row-codec-ml-171784825"></a>
### external

```ml
function external(encodedPointer)
```

Performs the external operation for this module. Inputs: `encodedPointer`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encodedPointer` | `dynamic` | — | encodedPointer value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L535)

- [minisql.storage.row_codec.ExternalValue](Type-minisql-storage-row-codec-externalvalue-1393329628.md) — struct
<a id="function-function-minisql-storage-row-codec-fail-function-fail-code-operation-message-src-minisql-storage-row-codec-ml-2022930651"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql storage row codec module. Inputs: `code`, `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L123)

<a id="constant-constant-minisql-storage-row-codec-flag-external-const-flag-external-2-src-minisql-storage-row-codec-ml-1036953661"></a>
### FLAG_EXTERNAL

```ml
const FLAG_EXTERNAL = 2
```

Defines the flag external constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L67)

<a id="constant-constant-minisql-storage-row-codec-flag-null-const-flag-null-1-src-minisql-storage-row-codec-ml-1877188006"></a>
### FLAG_NULL

```ml
const FLAG_NULL = 1
```

Defines the flag null constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L65)

<a id="constant-constant-minisql-storage-row-codec-format-version-const-format-version-format-version-row-src-minisql-storage-row-codec-ml-1059455811"></a>
### FORMAT_VERSION

```ml
const FORMAT_VERSION = format_version.ROW
```

Defines the format version constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L23)

<a id="constant-constant-minisql-storage-row-codec-header-size-const-header-size-16-src-minisql-storage-row-codec-ml-2060538730"></a>
### HEADER_SIZE

```ml
const HEADER_SIZE = 16
```

Defines the header size constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L25)

<a id="constant-constant-minisql-storage-row-codec-invalid-argument-const-invalid-argument-9001-src-minisql-storage-row-codec-ml-1499762893"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Row format v2 uses aligned fields and finite IEEE-754 binary64 values.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L14)

<a id="function-function-minisql-storage-row-codec-isbinarytype-function-isbinarytype-typecode-src-minisql-storage-row-codec-ml-1503835983"></a>
### isBinaryType

```ml
function isBinaryType(typeCode)
```

Evaluates whether the supplied input satisfies the binary type predicate. Inputs: `typeCode`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | typeCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L213)

<a id="function-function-minisql-storage-row-codec-isexternaltype-function-isexternaltype-typecode-src-minisql-storage-row-codec-ml-1223654191"></a>
### isExternalType

```ml
function isExternalType(typeCode)
```

Evaluates whether the supplied input satisfies the external type predicate. Inputs: `typeCode`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | typeCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L220)

<a id="function-function-minisql-storage-row-codec-isexternalvalue-function-isexternalvalue-value-src-minisql-storage-row-codec-ml-1217040491"></a>
### isExternalValue

```ml
function isExternalValue(value)
```

Evaluates whether the supplied input satisfies the external value predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L114)

<a id="function-function-minisql-storage-row-codec-isimplemented-function-isimplemented-src-minisql-storage-row-codec-ml-1675540762"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql storage row codec module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L554)

<a id="function-function-minisql-storage-row-codec-isnull-function-isnull-value-src-minisql-storage-row-codec-ml-1364475411"></a>
### isNull

```ml
function isNull(value)
```

Evaluates whether the supplied input satisfies the null predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L192)

<a id="function-function-minisql-storage-row-codec-istexttype-function-istexttype-typecode-src-minisql-storage-row-codec-ml-1248090283"></a>
### isTextType

```ml
function isTextType(typeCode)
```

Evaluates whether the supplied input satisfies the text type predicate. Inputs: `typeCode`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | typeCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L206)

<a id="function-function-minisql-storage-row-codec-magicbytes-function-magicbytes-src-minisql-storage-row-codec-ml-2106157778"></a>
### magicBytes

```ml
function magicBytes()
```

Performs the magicBytes operation for the minisql storage row codec module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L129)

<a id="function-function-minisql-storage-row-codec-nullvalue-function-nullvalue-src-minisql-storage-row-codec-ml-1709090746"></a>
### nullValue

```ml
function nullValue()
```

Performs the null value operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L185)

<a id="constant-constant-minisql-storage-row-codec-row-alignment-const-row-alignment-8-src-minisql-storage-row-codec-ml-348287867"></a>
### ROW_ALIGNMENT

```ml
const ROW_ALIGNMENT = 8
```

Rows and the column directory begin on eight-byte boundaries.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L29)

- [minisql.storage.row_codec.RowData](Type-minisql-storage-row-codec-rowdata-1101042380.md) — struct
- [minisql.storage.row_codec.RowSchema](Type-minisql-storage-row-codec-rowschema-2012310495.md) — struct
<a id="function-function-minisql-storage-row-codec-schema-function-schema-version-columns-src-minisql-storage-row-codec-ml-647148125"></a>
### schema

```ml
function schema(version, columns)
```

Performs the schema operation for this module. Inputs: `version`, `columns`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | `dynamic` | — | version value consumed by this operation. |
| `columns` | `dynamic` | — | columns value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L245)

- [minisql.storage.row_codec.SqlNull](Type-minisql-storage-row-codec-sqlnull-286022569.md) — struct
<a id="function-function-minisql-storage-row-codec-targetmilestone-function-targetmilestone-src-minisql-storage-row-codec-ml-1288005948"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql storage row codec module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L548)

<a id="constant-constant-minisql-storage-row-codec-type-bigint-const-type-bigint-4-src-minisql-storage-row-codec-ml-919592391"></a>
### TYPE_BIGINT

```ml
const TYPE_BIGINT = 4
```

Defines the type bigint constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L38)

<a id="constant-constant-minisql-storage-row-codec-type-binary-const-type-binary-11-src-minisql-storage-row-codec-ml-120856425"></a>
### TYPE_BINARY

```ml
const TYPE_BINARY = 11
```

Defines the type binary constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L52)

<a id="constant-constant-minisql-storage-row-codec-type-blob-const-type-blob-13-src-minisql-storage-row-codec-ml-581405183"></a>
### TYPE_BLOB

```ml
const TYPE_BLOB = 13
```

Defines the type blob constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L56)

<a id="constant-constant-minisql-storage-row-codec-type-boolean-const-type-boolean-1-src-minisql-storage-row-codec-ml-1298432742"></a>
### TYPE_BOOLEAN

```ml
const TYPE_BOOLEAN = 1
```

Defines the type boolean constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L32)

<a id="constant-constant-minisql-storage-row-codec-type-char-const-type-char-8-src-minisql-storage-row-codec-ml-496746111"></a>
### TYPE_CHAR

```ml
const TYPE_CHAR = 8
```

Defines the type char constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L46)

<a id="constant-constant-minisql-storage-row-codec-type-date-const-type-date-14-src-minisql-storage-row-codec-ml-2070001380"></a>
### TYPE_DATE

```ml
const TYPE_DATE = 14
```

Defines the type date constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L58)

<a id="constant-constant-minisql-storage-row-codec-type-decimal-const-type-decimal-7-src-minisql-storage-row-codec-ml-2126398578"></a>
### TYPE_DECIMAL

```ml
const TYPE_DECIMAL = 7
```

Defines the type decimal constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L44)

<a id="constant-constant-minisql-storage-row-codec-type-double-const-type-double-6-src-minisql-storage-row-codec-ml-1875877593"></a>
### TYPE_DOUBLE

```ml
const TYPE_DOUBLE = 6
```

Defines the type double constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L42)

<a id="constant-constant-minisql-storage-row-codec-type-integer-const-type-integer-3-src-minisql-storage-row-codec-ml-1315628040"></a>
### TYPE_INTEGER

```ml
const TYPE_INTEGER = 3
```

Defines the type integer constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L36)

<a id="constant-constant-minisql-storage-row-codec-type-mismatch-const-type-mismatch-9017-src-minisql-storage-row-codec-ml-1174863968"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```

Defines the type mismatch constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L20)

<a id="constant-constant-minisql-storage-row-codec-type-real-const-type-real-5-src-minisql-storage-row-codec-ml-238101938"></a>
### TYPE_REAL

```ml
const TYPE_REAL = 5
```

Defines the type real constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L40)

<a id="constant-constant-minisql-storage-row-codec-type-smallint-const-type-smallint-2-src-minisql-storage-row-codec-ml-1526105977"></a>
### TYPE_SMALLINT

```ml
const TYPE_SMALLINT = 2
```

Defines the type smallint constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L34)

<a id="constant-constant-minisql-storage-row-codec-type-text-const-type-text-10-src-minisql-storage-row-codec-ml-1635552812"></a>
### TYPE_TEXT

```ml
const TYPE_TEXT = 10
```

Defines the type text constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L50)

<a id="constant-constant-minisql-storage-row-codec-type-time-const-type-time-15-src-minisql-storage-row-codec-ml-1208377217"></a>
### TYPE_TIME

```ml
const TYPE_TIME = 15
```

Defines the type time constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L60)

<a id="constant-constant-minisql-storage-row-codec-type-timestamp-const-type-timestamp-16-src-minisql-storage-row-codec-ml-1332625398"></a>
### TYPE_TIMESTAMP

```ml
const TYPE_TIMESTAMP = 16
```

Defines the type timestamp constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L62)

<a id="constant-constant-minisql-storage-row-codec-type-varbinary-const-type-varbinary-12-src-minisql-storage-row-codec-ml-1237202394"></a>
### TYPE_VARBINARY

```ml
const TYPE_VARBINARY = 12
```

Defines the type varbinary constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L54)

<a id="constant-constant-minisql-storage-row-codec-type-varchar-const-type-varchar-9-src-minisql-storage-row-codec-ml-972587244"></a>
### TYPE_VARCHAR

```ml
const TYPE_VARCHAR = 9
```

Defines the type varchar constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L48)

<a id="constant-constant-minisql-storage-row-codec-unsupported-format-const-unsupported-format-9003-src-minisql-storage-row-codec-ml-121070795"></a>
### UNSUPPORTED_FORMAT

```ml
const UNSUPPORTED_FORMAT = 9003
```

Defines the unsupported format constant used by the minisql storage row codec module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L16)

<a id="function-function-minisql-storage-row-codec-validatepadding-function-validatepadding-encoded-first-ending-operation-src-minisql-storage-row-codec-ml-1784344164"></a>
### validatePadding

```ml
function validatePadding(encoded, first, ending, operation)
```

Rejects nonzero bytes in a bounded, half-open alignment-padding range.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `encoded` | `dynamic` | — | Encoded row bytes. |
| `first` | `dynamic` | — | First padding byte. |
| `ending` | `dynamic` | — | Offset immediately after the padding. |
| `operation` | `dynamic` | — | Decoder operation used in diagnostics. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L173)

<a id="function-function-minisql-storage-row-codec-validtype-function-validtype-typecode-src-minisql-storage-row-codec-ml-2019194487"></a>
### validType

```ml
function validType(typeCode)
```

Performs the valid type operation for this module. Inputs: `typeCode`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | typeCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L199)

<a id="function-function-minisql-storage-row-codec-valuealignment-function-valuealignment-typecode-flags-src-minisql-storage-row-codec-ml-158071354"></a>
### valueAlignment

```ml
function valueAlignment(typeCode, flags)
```

Returns the physical alignment for a stored column, including external pointers. NULL owns no storage and therefore adds no alignment padding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeCode` | `dynamic` | — | Physical column type. |
| `flags` | `dynamic` | — | Column directory flags. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/storage/row_codec.ml#L159)
