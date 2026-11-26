# `src/minisql/common/float_codec.ml`

[Home](README.md) · [Files](Files.md)

Exact finite IEEE-754 binary64 codecs for persistent MiniSQL values.

Package: [`minisql.common.float_codec`](Package-minisql-common-float-codec-1778688856.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `std/math.ml` as `math` → `../MiniLangCompilerML/std/math.ml` — external dependency

## Declarations

<a id="function-function-minisql-common-float-codec-componentname-function-componentname-src-minisql-common-float-codec-ml-642637070"></a>
### componentName

```ml
function componentName()
```

Returns this module's stable registry name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L113)

<a id="constant-constant-minisql-common-float-codec-corrupt-data-const-corrupt-data-9004-src-minisql-common-float-codec-ml-1833795430"></a>
### CORRUPT_DATA

```ml
const CORRUPT_DATA = 9004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L12)

<a id="function-function-minisql-common-float-codec-decodefloat64le-function-decodefloat64le-source-offset-src-minisql-common-float-codec-ml-54266986"></a>
### decodeFloat64LE

```ml
function decodeFloat64LE(source, offset)
```

Decodes finite binary64, preserving negative zero and the full 53-bit significand.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Input byte buffer. |
| `offset` | `dynamic` | — | Start of the eight-byte value. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L95)

<a id="function-function-minisql-common-float-codec-encodefloat64le-function-encodefloat64le-value-src-minisql-common-float-codec-ml-88570491"></a>
### encodeFloat64LE

```ml
function encodeFloat64LE(value)
```

Encodes a finite number without changing zero's sign or losing subnormal bits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | MiniLang numeric value; integers convert to binary64 by normal numeric semantics. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L50)

<a id="constant-constant-minisql-common-float-codec-fraction-unit-const-fraction-unit-4503599627370496-src-minisql-common-float-codec-ml-1305484696"></a>
### FRACTION_UNIT

```ml
const FRACTION_UNIT = 4503599627370496
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L15)

<a id="constant-constant-minisql-common-float-codec-invalid-argument-const-invalid-argument-9001-src-minisql-common-float-codec-ml-249121859"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L11)

<a id="function-function-minisql-common-float-codec-isfiniteencoded-function-isfiniteencoded-source-offset-src-minisql-common-float-codec-ml-1414998802"></a>
### isFiniteEncoded

```ml
function isFiniteEncoded(source, offset)
```

Reports whether an encoded binary64 has a finite exponent, after bounds checks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Input byte buffer. |
| `offset` | `dynamic` | — | Start of the eight-byte value. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L42)

<a id="function-function-minisql-common-float-codec-isimplemented-function-isimplemented-src-minisql-common-float-codec-ml-414713814"></a>
### isImplemented

```ml
function isImplemented()
```

Reports that the binary64 codec is available.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L123)

<a id="extern_function-extern-function-minisql-common-float-codec-nativecopysign-extern-function-nativecopysign-value-as-double-signvalue-as-double-from-msvcrt-dll-symbol-copysign-returns-double-src-minisql-common-float-codec-ml-1296095908"></a>
### nativeCopySign

```ml
extern function nativeCopySign(value as double, signValue as double) from "msvcrt.dll" symbol "_copysign" returns double
```

Copies the sign bit, including the sign of zero.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | — |  |
| `signValue` | `double` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L25)

<a id="extern_function-extern-function-minisql-common-float-codec-nativefinite-extern-function-nativefinite-value-as-double-from-msvcrt-dll-symbol-finite-returns-i32-src-minisql-common-float-codec-ml-407491061"></a>
### nativeFinite

```ml
extern function nativeFinite(value as double) from "msvcrt.dll" symbol "_finite" returns i32
```

Reports whether the native value is finite without unordered comparisons.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L27)

<a id="extern_function-extern-function-minisql-common-float-codec-nativefrexp-extern-function-nativefrexp-value-as-double-exponent-as-bytes-from-msvcrt-dll-symbol-frexp-returns-double-src-minisql-common-float-codec-ml-624109855"></a>
### nativeFrexp

```ml
extern function nativeFrexp(value as double, exponent as bytes) from "msvcrt.dll" symbol "frexp" returns double
```

Splits a native double into its exact binary significand and exponent.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | — |  |
| `exponent` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L21)

<a id="extern_function-extern-function-minisql-common-float-codec-nativeldexp-extern-function-nativeldexp-value-as-double-exponent-as-i32-from-msvcrt-dll-symbol-ldexp-returns-double-src-minisql-common-float-codec-ml-468166784"></a>
### nativeLdexp

```ml
extern function nativeLdexp(value as double, exponent as i32) from "msvcrt.dll" symbol "ldexp" returns double
```

Scales a native double by an integral power of two.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | — |  |
| `exponent` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L23)

<a id="function-function-minisql-common-float-codec-targetmilestone-function-targetmilestone-src-minisql-common-float-codec-ml-529584928"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the storage generation that introduced this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L118)

<a id="constant-constant-minisql-common-float-codec-type-mismatch-const-type-mismatch-9017-src-minisql-common-float-codec-ml-464086980"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L13)

<a id="constant-constant-minisql-common-float-codec-width-const-width-8-src-minisql-common-float-codec-ml-822338613"></a>
### WIDTH

```ml
const WIDTH = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L14)

<a id="function-function-minisql-common-float-codec-writefloat64le-function-writefloat64le-destination-offset-value-src-minisql-common-float-codec-ml-88831990"></a>
### writeFloat64LE

```ml
function writeFloat64LE(destination, offset, value)
```

Writes a complete finite binary64 only after value and destination validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Output byte buffer. |
| `offset` | `dynamic` | — | Start of the eight-byte destination. |
| `value` | `dynamic` | — | Numeric value to encode. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/float_codec.ml#L85)
