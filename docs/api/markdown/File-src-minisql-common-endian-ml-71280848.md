# `src/minisql/common/endian.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql common endian facilities for this project.

Package: [`minisql.common.endian`](Package-minisql-common-endian-441442362.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-endian-componentname-function-componentname-src-minisql-common-endian-ml-2067350712"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql common endian module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L715)

<a id="constant-constant-minisql-common-endian-i64-max-high-const-i64-max-high-2147483647-src-minisql-common-endian-ml-439719905"></a>
### I64_MAX_HIGH

```ml
const I64_MAX_HIGH = 2147483647
```

Defines the i64 max high constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L58)

<a id="constant-constant-minisql-common-endian-i64-max-low-const-i64-max-low-4294967295-src-minisql-common-endian-ml-450149860"></a>
### I64_MAX_LOW

```ml
const I64_MAX_LOW = 4294967295
```

Defines the i64 max low constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L60)

<a id="constant-constant-minisql-common-endian-i64-min-high-const-i64-min-high-2147483648-src-minisql-common-endian-ml-1295183602"></a>
### I64_MIN_HIGH

```ml
const I64_MIN_HIGH = 2147483648
```

Defines the i64 min high constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L54)

<a id="constant-constant-minisql-common-endian-i64-min-low-const-i64-min-low-0-src-minisql-common-endian-ml-1341438925"></a>
### I64_MIN_LOW

```ml
const I64_MIN_LOW = 0
```

Defines the i64 min low constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L56)

<a id="function-function-minisql-common-endian-int64bitstouint64-function-int64bitstouint64-value-src-minisql-common-endian-ml-1345654821"></a>
### int64BitsToUInt64

```ml
function int64BitsToUInt64(value)
```

Performs the int64 bits to uint64 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L301)

<a id="function-function-minisql-common-endian-int64equals-function-int64equals-left-right-src-minisql-common-endian-ml-295964661"></a>
### int64Equals

```ml
function int64Equals(left, right)
```

Performs the int64 equals operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L276)

<a id="function-function-minisql-common-endian-int64fromint-function-int64fromint-value-src-minisql-common-endian-ml-1487442893"></a>
### int64FromInt

```ml
function int64FromInt(value)
```

Performs the int64 from int operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L238)

<a id="function-function-minisql-common-endian-int64isnegative-function-int64isnegative-value-src-minisql-common-endian-ml-1234760473"></a>
### int64IsNegative

```ml
function int64IsNegative(value)
```

Performs the int64 is negative operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L285)

<a id="function-function-minisql-common-endian-int64toint-function-int64toint-value-src-minisql-common-endian-ml-675082573"></a>
### int64ToInt

```ml
function int64ToInt(value)
```

Performs the int64 to int operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L255)

- [minisql.common.endian.Int64Words](Type-minisql-common-endian-int64words-296456168.md) — struct
<a id="function-function-minisql-common-endian-invalid-function-invalid-operation-message-src-minisql-common-endian-ml-1268301362"></a>
### invalid

```ml
function invalid(operation, message)
```

Performs the invalid operation for the minisql common endian module. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L96)

<a id="constant-constant-minisql-common-endian-invalid-argument-const-invalid-argument-9001-src-minisql-common-endian-ml-1063311231"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

MiniSQL M1 fixed-width integer codecs, revision 1.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L10)

<a id="function-function-minisql-common-endian-isimplemented-function-isimplemented-src-minisql-common-endian-ml-1176242624"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql common endian module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L727)

<a id="function-function-minisql-common-endian-isint64words-function-isint64words-value-src-minisql-common-endian-ml-671343897"></a>
### isInt64Words

```ml
function isInt64Words(value)
```

Evaluates whether the supplied input satisfies the int64 words predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L88)

<a id="function-function-minisql-common-endian-isuint64words-function-isuint64words-value-src-minisql-common-endian-ml-529510215"></a>
### isUInt64Words

```ml
function isUInt64Words(value)
```

Evaluates whether the supplied input satisfies the uint64 words predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L81)

<a id="function-function-minisql-common-endian-makeint64-function-makeint64-high-low-src-minisql-common-endian-ml-2059212384"></a>
### makeInt64

```ml
function makeInt64(high, low)
```

Constructs the int64. Inputs: `high`, `low`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `high` | `dynamic` | — | high value consumed by this operation. |
| `low` | `dynamic` | — | low value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L186)

<a id="function-function-minisql-common-endian-makeuint64-function-makeuint64-high-low-src-minisql-common-endian-ml-1251403210"></a>
### makeUInt64

```ml
function makeUInt64(high, low)
```

Constructs the uint64. Inputs: `high`, `low`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `high` | `dynamic` | — | high value consumed by this operation. |
| `low` | `dynamic` | — | low value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L176)

<a id="constant-constant-minisql-common-endian-max-i16-const-max-i16-32767-src-minisql-common-endian-ml-1416790018"></a>
### MAX_I16

```ml
const MAX_I16 = 32767
```

Defines the max i16 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L31)

<a id="constant-constant-minisql-common-endian-max-i32-const-max-i32-2147483647-src-minisql-common-endian-ml-601646245"></a>
### MAX_I32

```ml
const MAX_I32 = 2147483647
```

Defines the max i32 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L38)

<a id="constant-constant-minisql-common-endian-max-i8-const-max-i8-127-src-minisql-common-endian-ml-700230755"></a>
### MAX_I8

```ml
const MAX_I8 = 127
```

Defines the max i8 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L24)

<a id="constant-constant-minisql-common-endian-max-minilang-int-const-max-minilang-int-1152921504606846975-src-minisql-common-endian-ml-1859102748"></a>
### MAX_MINILANG_INT

```ml
const MAX_MINILANG_INT = 1152921504606846975
```

Defines the max minilang int constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L47)

<a id="constant-constant-minisql-common-endian-max-scalar-high-const-max-scalar-high-268435455-src-minisql-common-endian-ml-2037627523"></a>
### MAX_SCALAR_HIGH

```ml
const MAX_SCALAR_HIGH = 268435455
```

Defines the max scalar high constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L49)

<a id="constant-constant-minisql-common-endian-max-u16-const-max-u16-65535-src-minisql-common-endian-ml-1916240465"></a>
### MAX_U16

```ml
const MAX_U16 = 65535
```

Defines the max u16 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L33)

<a id="constant-constant-minisql-common-endian-max-u32-const-max-u32-4294967295-src-minisql-common-endian-ml-2044762496"></a>
### MAX_U32

```ml
const MAX_U32 = 4294967295
```

Defines the max u32 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L40)

<a id="constant-constant-minisql-common-endian-max-u8-const-max-u8-255-src-minisql-common-endian-ml-840934139"></a>
### MAX_U8

```ml
const MAX_U8 = 255
```

Defines the max u8 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L26)

<a id="function-function-minisql-common-endian-maxint64-function-maxint64-src-minisql-common-endian-ml-788196164"></a>
### maxInt64

```ml
function maxInt64()
```

Performs the max int64 operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L200)

<a id="constant-constant-minisql-common-endian-min-i16-const-min-i16-32768-src-minisql-common-endian-ml-475810526"></a>
### MIN_I16

```ml
const MIN_I16 = -32768
```

Defines the min i16 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L29)

<a id="constant-constant-minisql-common-endian-min-i32-const-min-i32-2147483648-src-minisql-common-endian-ml-564668879"></a>
### MIN_I32

```ml
const MIN_I32 = -2147483648
```

Defines the min i32 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L36)

<a id="constant-constant-minisql-common-endian-min-i8-const-min-i8-128-src-minisql-common-endian-ml-255740635"></a>
### MIN_I8

```ml
const MIN_I8 = -128
```

Defines the min i8 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L22)

<a id="constant-constant-minisql-common-endian-min-minilang-int-const-min-minilang-int-1152921504606846976-src-minisql-common-endian-ml-445456221"></a>
### MIN_MINILANG_INT

```ml
const MIN_MINILANG_INT = --1152921504606846976
```

Native MiniLang integer payload limits with three tag bits.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L45)

<a id="constant-constant-minisql-common-endian-min-scalar-high-const-min-scalar-high-4026531840-src-minisql-common-endian-ml-447684662"></a>
### MIN_SCALAR_HIGH

```ml
const MIN_SCALAR_HIGH = 4026531840
```

Defines the min scalar high constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L51)

<a id="function-function-minisql-common-endian-minint64-function-minint64-src-minisql-common-endian-ml-307764344"></a>
### minInt64

```ml
function minInt64()
```

Performs the min int64 operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L194)

<a id="function-function-minisql-common-endian-readi16be-function-readi16be-buffer-offset-src-minisql-common-endian-ml-865361739"></a>
### readI16BE

```ml
function readI16BE(buffer, offset)
```

Reads the i16 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L389)

<a id="function-function-minisql-common-endian-readi16le-function-readi16le-buffer-offset-src-minisql-common-endian-ml-1622123307"></a>
### readI16LE

```ml
function readI16LE(buffer, offset)
```

Reads the i16 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L377)

<a id="function-function-minisql-common-endian-readi32be-function-readi32be-buffer-offset-src-minisql-common-endian-ml-1389495267"></a>
### readI32BE

```ml
function readI32BE(buffer, offset)
```

Reads the i32 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L497)

<a id="function-function-minisql-common-endian-readi32le-function-readi32le-buffer-offset-src-minisql-common-endian-ml-1890594339"></a>
### readI32LE

```ml
function readI32LE(buffer, offset)
```

Reads the i32 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L485)

<a id="function-function-minisql-common-endian-readi64asintbe-function-readi64asintbe-buffer-offset-src-minisql-common-endian-ml-251619581"></a>
### readI64AsIntBE

```ml
function readI64AsIntBE(buffer, offset)
```

Reads the i64 as int be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L629)

<a id="function-function-minisql-common-endian-readi64asintle-function-readi64asintle-buffer-offset-src-minisql-common-endian-ml-733221745"></a>
### readI64AsIntLE

```ml
function readI64AsIntLE(buffer, offset)
```

Reads the i64 as int le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L621)

<a id="function-function-minisql-common-endian-readi64be-function-readi64be-buffer-offset-src-minisql-common-endian-ml-463969109"></a>
### readI64BE

```ml
function readI64BE(buffer, offset)
```

Reads the i64 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L610)

<a id="function-function-minisql-common-endian-readi64le-function-readi64le-buffer-offset-src-minisql-common-endian-ml-843658177"></a>
### readI64LE

```ml
function readI64LE(buffer, offset)
```

Reads the i64 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L599)

<a id="function-function-minisql-common-endian-readi8-function-readi8-buffer-offset-src-minisql-common-endian-ml-1345458373"></a>
### readI8

```ml
function readI8(buffer, offset)
```

Reads the i8. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L319)

<a id="function-function-minisql-common-endian-readu16be-function-readu16be-buffer-offset-src-minisql-common-endian-ml-124805907"></a>
### readU16BE

```ml
function readU16BE(buffer, offset)
```

Reads the u16 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L368)

<a id="function-function-minisql-common-endian-readu16le-function-readu16le-buffer-offset-src-minisql-common-endian-ml-872070347"></a>
### readU16LE

```ml
function readU16LE(buffer, offset)
```

Reads the u16 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L359)

<a id="function-function-minisql-common-endian-readu32be-function-readu32be-buffer-offset-src-minisql-common-endian-ml-2134852083"></a>
### readU32BE

```ml
function readU32BE(buffer, offset)
```

Reads the u32 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L473)

<a id="function-function-minisql-common-endian-readu32le-function-readu32le-buffer-offset-src-minisql-common-endian-ml-1064858571"></a>
### readU32LE

```ml
function readU32LE(buffer, offset)
```

Reads the u32 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L461)

<a id="function-function-minisql-common-endian-readu64be-function-readu64be-buffer-offset-src-minisql-common-endian-ml-391249461"></a>
### readU64BE

```ml
function readU64BE(buffer, offset)
```

Reads the u64 be. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L588)

<a id="function-function-minisql-common-endian-readu64le-function-readu64le-buffer-offset-src-minisql-common-endian-ml-1390010601"></a>
### readU64LE

```ml
function readU64LE(buffer, offset)
```

Reads the u64 le. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L577)

<a id="function-function-minisql-common-endian-readu8-function-readu8-buffer-offset-src-minisql-common-endian-ml-1867266597"></a>
### readU8

```ml
function readU8(buffer, offset)
```

Reads the u8. Inputs: `buffer`, `offset`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L310)

<a id="function-function-minisql-common-endian-targetmilestone-function-targetmilestone-src-minisql-common-endian-ml-813685886"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql common endian module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L721)

<a id="constant-constant-minisql-common-endian-u32-base-const-u32-base-4294967296-src-minisql-common-endian-ml-1649135721"></a>
### U32_BASE

```ml
const U32_BASE = 4294967296
```

Defines the u32 base constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L42)

<a id="function-function-minisql-common-endian-uint64bitstoint64-function-uint64bitstoint64-value-src-minisql-common-endian-ml-1791421553"></a>
### uint64BitsToInt64

```ml
function uint64BitsToInt64(value)
```

Performs the uint64 bits to int64 operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L293)

<a id="function-function-minisql-common-endian-uint64equals-function-uint64equals-left-right-src-minisql-common-endian-ml-568957753"></a>
### uint64Equals

```ml
function uint64Equals(left, right)
```

Performs the uint64 equals operation for this module. Inputs: `left`, `right`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L229)

<a id="function-function-minisql-common-endian-uint64fromint-function-uint64fromint-value-src-minisql-common-endian-ml-1283856115"></a>
### uint64FromInt

```ml
function uint64FromInt(value)
```

Performs the uint64 from int operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L207)

<a id="function-function-minisql-common-endian-uint64toint-function-uint64toint-value-src-minisql-common-endian-ml-1829755537"></a>
### uint64ToInt

```ml
function uint64ToInt(value)
```

Performs the uint64 to int operation for this module. Inputs: `value`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L217)

- [minisql.common.endian.UInt64Words](Type-minisql-common-endian-uint64words-2117218771.md) — struct
<a id="function-function-minisql-common-endian-validateint64words-function-validateint64words-value-operation-src-minisql-common-endian-ml-770131730"></a>
### validateInt64Words

```ml
function validateInt64Words(value, operation)
```

Validates the int64 words. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L163)

<a id="function-function-minisql-common-endian-validateintrange-function-validateintrange-value-minimum-maximum-operation-src-minisql-common-endian-ml-869709868"></a>
### validateIntRange

```ml
function validateIntRange(value, minimum, maximum, operation)
```

Validates the int range. Inputs: `value`, `minimum`, `maximum`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `minimum` | `dynamic` | — | minimum value consumed by this operation. |
| `maximum` | `dynamic` | — | maximum value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L136)

<a id="function-function-minisql-common-endian-validaterange-function-validaterange-buffer-offset-width-operation-src-minisql-common-endian-ml-1212873638"></a>
### validateRange

```ml
function validateRange(buffer, offset, width, operation)
```

Validates the range. Inputs: `buffer`, `offset`, `width`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `width` | `dynamic` | — | Width in the coordinate or storage units used by the caller. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L106)

<a id="function-function-minisql-common-endian-validateuint64words-function-validateuint64words-value-operation-src-minisql-common-endian-ml-1780176672"></a>
### validateUInt64Words

```ml
function validateUInt64Words(value, operation)
```

Validates the uint64 words. Inputs: `value`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L150)

<a id="constant-constant-minisql-common-endian-width-u16-const-width-u16-2-src-minisql-common-endian-ml-1992647583"></a>
### WIDTH_U16

```ml
const WIDTH_U16 = 2
```

Defines the width u16 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L15)

<a id="constant-constant-minisql-common-endian-width-u32-const-width-u32-4-src-minisql-common-endian-ml-1959649633"></a>
### WIDTH_U32

```ml
const WIDTH_U32 = 4
```

Defines the width u32 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L17)

<a id="constant-constant-minisql-common-endian-width-u64-const-width-u64-8-src-minisql-common-endian-ml-1757689817"></a>
### WIDTH_U64

```ml
const WIDTH_U64 = 8
```

Defines the width u64 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L19)

<a id="constant-constant-minisql-common-endian-width-u8-const-width-u8-1-src-minisql-common-endian-ml-51569770"></a>
### WIDTH_U8

```ml
const WIDTH_U8 = 1
```

Defines the width u8 constant used by the minisql common endian module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L13)

<a id="function-function-minisql-common-endian-writei16be-function-writei16be-buffer-offset-value-src-minisql-common-endian-ml-1530312798"></a>
### writeI16BE

```ml
function writeI16BE(buffer, offset, value)
```

Writes the i16 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L445)

<a id="function-function-minisql-common-endian-writei16le-function-writei16le-buffer-offset-value-src-minisql-common-endian-ml-679374242"></a>
### writeI16LE

```ml
function writeI16LE(buffer, offset, value)
```

Writes the i16 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L428)

<a id="function-function-minisql-common-endian-writei32be-function-writei32be-buffer-offset-value-src-minisql-common-endian-ml-620604162"></a>
### writeI32BE

```ml
function writeI32BE(buffer, offset, value)
```

Writes the i32 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L559)

<a id="function-function-minisql-common-endian-writei32le-function-writei32le-buffer-offset-value-src-minisql-common-endian-ml-857031422"></a>
### writeI32LE

```ml
function writeI32LE(buffer, offset, value)
```

Writes the i32 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L540)

<a id="function-function-minisql-common-endian-writei64be-function-writei64be-buffer-offset-value-src-minisql-common-endian-ml-1703923570"></a>
### writeI64BE

```ml
function writeI64BE(buffer, offset, value)
```

Writes the i64 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L680)

<a id="function-function-minisql-common-endian-writei64fromintbe-function-writei64fromintbe-buffer-offset-value-src-minisql-common-endian-ml-1712750370"></a>
### writeI64FromIntBE

```ml
function writeI64FromIntBE(buffer, offset, value)
```

Writes the i64 from int be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L706)

<a id="function-function-minisql-common-endian-writei64fromintle-function-writei64fromintle-buffer-offset-value-src-minisql-common-endian-ml-472035730"></a>
### writeI64FromIntLE

```ml
function writeI64FromIntLE(buffer, offset, value)
```

Writes the i64 from int le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L694)

<a id="function-function-minisql-common-endian-writei64le-function-writei64le-buffer-offset-value-src-minisql-common-endian-ml-472293686"></a>
### writeI64LE

```ml
function writeI64LE(buffer, offset, value)
```

Writes the i64 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L666)

<a id="function-function-minisql-common-endian-writei8-function-writei8-buffer-offset-value-src-minisql-common-endian-ml-510060330"></a>
### writeI8

```ml
function writeI8(buffer, offset, value)
```

Writes the i8. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L344)

<a id="function-function-minisql-common-endian-writeu16be-function-writeu16be-buffer-offset-value-src-minisql-common-endian-ml-1365019182"></a>
### writeU16BE

```ml
function writeU16BE(buffer, offset, value)
```

Writes the u16 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L415)

<a id="function-function-minisql-common-endian-writeu16le-function-writeu16le-buffer-offset-value-src-minisql-common-endian-ml-704234914"></a>
### writeU16LE

```ml
function writeU16LE(buffer, offset, value)
```

Writes the u16 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L402)

<a id="function-function-minisql-common-endian-writeu32be-function-writeu32be-buffer-offset-value-src-minisql-common-endian-ml-363496578"></a>
### writeU32BE

```ml
function writeU32BE(buffer, offset, value)
```

Writes the u32 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L525)

<a id="function-function-minisql-common-endian-writeu32le-function-writeu32le-buffer-offset-value-src-minisql-common-endian-ml-355872590"></a>
### writeU32LE

```ml
function writeU32LE(buffer, offset, value)
```

Writes the u32 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L510)

<a id="function-function-minisql-common-endian-writeu64be-function-writeu64be-buffer-offset-value-src-minisql-common-endian-ml-546387098"></a>
### writeU64BE

```ml
function writeU64BE(buffer, offset, value)
```

Writes the u64 be. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L652)

<a id="function-function-minisql-common-endian-writeu64le-function-writeu64le-buffer-offset-value-src-minisql-common-endian-ml-1278621286"></a>
### writeU64LE

```ml
function writeU64LE(buffer, offset, value)
```

Writes the u64 le. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L638)

<a id="function-function-minisql-common-endian-writeu8-function-writeu8-buffer-offset-value-src-minisql-common-endian-ml-1689769698"></a>
### writeU8

```ml
function writeU8(buffer, offset, value)
```

Writes the u8. Inputs: `buffer`, `offset`, `value`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buffer` | `dynamic` | — | Buffer that receives or supplies the operation data. |
| `offset` | `dynamic` | — | Zero-based offset at which processing starts. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/endian.ml#L332)
