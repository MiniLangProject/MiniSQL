# SQL index keys and values v2

SQL indexes are B+ trees described in `btree-v2.md`, with shared paged-file
superblocks. Catalog metadata owns the index key schema, table identity and
INCLUDE column order. Version 1 is not accepted by this format.

## SQL key envelope

| Offset | Bytes | Field |
|---:|---:|---|
| 0 | 3 | ASCII `MSK` (reserved typed-key family) |
| 3 | 1 | SQL key version `2` |
| 4 | variable | One or more self-delimiting typed components |

The complete encoded key, including this prefix, is limited to 256 bytes.
Components have a one-byte tag followed by the payload below.

| Tag | SQL types | Component payload |
|---:|---|---|
| `01` | NULL of any type | Empty |
| `02` | BOOLEAN | One byte: `00` or `01` |
| `03` | SMALLINT, INTEGER, BIGINT, DECIMAL, DATE, TIME, TIMESTAMP | Plain signed 64-bit two's-complement **little-endian** |
| `04` | REAL, DOUBLE | IEEE-754 binary64 **little-endian**, 8 bytes |
| `05` | CHAR, VARCHAR, TEXT | Escaped UTF-8 bytes followed by `00 00` |
| `06` | BINARY, VARBINARY, BLOB | Escaped raw bytes followed by `00 00` |

DECIMAL uses its already-scaled integer value and temporal values use their
existing integer units; precision, scale and type identity remain catalog
metadata. REAL and DOUBLE both use the runtime's binary64 precision. NaN and
infinity are rejected by the codec and the typed-key validator.

Every zero byte in a variable-width payload is encoded as `00 FF`. Other
bytes are unchanged. The terminator is `00 00`, so adjacent components remain
unambiguous, including empty values and embedded zero bytes.

### Numeric ordering

The key comparator reads numeric payloads as values. Integers compare signed
high words and then unsigned low words; floating values compare IEEE-754
magnitude words with the order reversed for negative values. No stored sign
bit is flipped and no key integer is stored big-endian. Different component
tags sort by tag number; a valid SQL index fixes each position's type through
its catalog schema, while NULL sorts first at that position.

Persisted keys and INCLUDE values preserve both floating zero signs. The tree
comparator equates their numerical values for searches and uniqueness. Only
ephemeral constraint hash keys canonicalize zero, because byte hashing has no
numeric comparator. Covering equality scans return the actual stored keys,
not a reconstruction from the search literal, so looking up positive zero
still returns a stored negative zero with its original bits.

Examples:

```text
INTEGER 1:   4D 53 4B 02 03 01 00 00 00 00 00 00 00
INTEGER -1:  4D 53 4B 02 03 FF FF FF FF FF FF FF FF
INTEGER 256: 4D 53 4B 02 03 00 01 00 00 00 00 00 00
DOUBLE 0.1:  4D 53 4B 02 04 9A 99 99 99 99 99 B9 3F
TEXT Nils:   4D 53 4B 02 05 4E 69 6C 73 00 00
```

## Ordinary leaf values

The physical row reference occupies exactly 12 bytes. Every multi-byte field
is little-endian.

| Offset | Bytes | Field |
|---:|---:|---|
| 0 | 4 | Heap page number |
| 4 | 2 | Slot ID |
| 6 | 2 | Slot generation |
| 8 | 4 | Table ID |

An index without INCLUDE columns ends at byte 12. The stable slot generation
guards against treating a reused slot as the previous row.

## Covering leaf values

| Offset | Bytes | Field |
|---:|---:|---|
| 0 | 12 | Physical row reference |
| 12 | 3 | ASCII `MSI` |
| 15 | 1 | INCLUDE payload version `2` |
| 16 | variable | One typed component per catalog-ordered INCLUDE column |

INCLUDE components use the same tags and payload widths as keys, without an
`MSK` prefix. Their REAL/DOUBLE payloads are binary64 and are decoded directly
for index-only scans; no textual floating representation or float-specific
heap fallback remains. The payload does not duplicate column names or count.
Absent or mismatched version markers, truncated components, trailing bytes,
non-finite floating data and catalog type mismatches are corruption errors.
Leaf values remain limited to 3584 bytes on every supported page size.

## Regression coverage

`src/tests/storage_v2_indexes.ml` checks byte goldens, signed INT64 limits,
255/256 ordering, IEEE-754 finite extremes/subnormals, zero signs, malformed
encodings, composite prefix bounds, escaped bytes, opaque value tie ordering,
unique/range/reopen behavior and rejection of v1 metadata. Its SQL scenarios
compare floating index-only results to heap results, verify INCLUDE values
bit for bit, and repeat reads after reopen and mutation.
