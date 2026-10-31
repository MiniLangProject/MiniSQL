# `src/minisql/common/byte_ops.ml`

[Home](README.md) · [Files](Files.md)

Provides allocation-free byte hashing and comparison primitives.

Package: [`minisql.common.byte_ops`](Package-minisql-common-byte-ops-655610004.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-minisql-common-byte-ops-comparelexicographic-inline-function-comparelexicographic-left-right-src-minisql-common-byte-ops-ml-81929950"></a>
### compareLexicographic

```ml
inline function compareLexicographic(left, right)
```

Compares two byte sequences in unsigned lexicographic order. The assembly loop only reads indices below the shorter input length; length ordering is resolved in MiniLang after equal prefixes have been exhausted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | Left byte sequence. |
| `right` | `dynamic` | — | Right byte sequence. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L76)

<a id="function-function-minisql-common-byte-ops-componentname-function-componentname-src-minisql-common-byte-ops-ml-1087781652"></a>
### componentName

```ml
function componentName()
```

Returns the stable module-catalog component name.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L14)

<a id="function-function-minisql-common-byte-ops-fnv1a31-inline-function-fnv1a31-input-seed-src-minisql-common-byte-ops-ml-1230510686"></a>
### fnv1a31

```ml
inline function fnv1a31(input, seed)
```

Hashes a byte sequence with MiniSQL's stable 31-bit FNV-1a variant. The caller supplies the initial state so composite SQL values can preserve their existing serialized hash contract. The unsafe load is bounded by the loop condition before every access and the input remains rooted by asm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | Byte sequence to hash without allocating a copy. |
| `seed` | `dynamic` | — | Initial FNV state; only its low 31 bits participate. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L34)

<a id="function-function-minisql-common-byte-ops-fnv1a31adaptive-inline-function-fnv1a31adaptive-input-seed-src-minisql-common-byte-ops-ml-1324371654"></a>
### fnv1a31Adaptive

```ml
inline function fnv1a31Adaptive(input, seed)
```

Hashes bytes through the fastest measured implementation for their length. Generated MiniLang wins below 16 bytes because it avoids assembly operand setup; the bounded assembly scanner wins for longer SQL text/binary values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input` | `dynamic` | — | Byte sequence to hash without allocating a copy. |
| `seed` | `dynamic` | — | Initial FNV state; only its low 31 bits participate. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L58)

<a id="constant-constant-minisql-common-byte-ops-inline-asm-hash-min-bytes-const-inline-asm-hash-min-bytes-16-src-minisql-common-byte-ops-ml-364024604"></a>
### INLINE_ASM_HASH_MIN_BYTES

```ml
const INLINE_ASM_HASH_MIN_BYTES = 16
```

Small byte sequences remain faster in generated MiniLang than across the inline-assembly operand boundary.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L11)

<a id="function-function-minisql-common-byte-ops-isimplemented-function-isimplemented-src-minisql-common-byte-ops-ml-1926948604"></a>
### isImplemented

```ml
function isImplemented()
```

Confirms that the cataloged byte primitives are available.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L24)

<a id="function-function-minisql-common-byte-ops-targetmilestone-function-targetmilestone-src-minisql-common-byte-ops-ml-2026285082"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the first milestone whose byte-processing contracts this module extends.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/common/byte_ops.ml#L19)
