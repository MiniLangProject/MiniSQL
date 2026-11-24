# B+ tree format v2

Version 2 is a breaking storage format. Version-1 metadata and node payloads
are rejected; no implicit conversion is performed. All multi-byte numeric
fields below, including SQL key payloads, are little-endian.

An index uses the shared paged-file wrapper with file type `2`. The first
8192 physical bytes contain two 4096-byte superblocks. Logical pages `0` and
`1` contain redundant tree metadata; nodes begin at logical page `2`.
For an unencrypted file, logical page `n` starts at `8192 + n * pageSize`.
The shared page-v1 header occupies bytes `0..63` of every logical page and
provides the page identity, generation, LSN, free-space bounds and CRC-32C.

## Metadata pages

The common page type is `3` (internal) and its flags are `0x8000` (metadata).
The common item count is zero, free-start is `128`, and free-end is page size.
Offsets in all tables are relative to the logical page.

| Offset | Bytes | Field |
|---:|---:|---|
| 64 | 4 | ASCII `MSBM` |
| 68 | 2 | B+ tree format version `2` |
| 70 | 2 | Flags: `1` for unique, otherwise `0` |
| 72 | 8 | Tree generation |
| 80 | 8 | Root page number |
| 88 | 8 | First leaf page number |
| 96 | 8 | Last leaf page number |
| 104 | 4 | Total entry count |
| 108 | 2 | Tree height |
| 110 | 18 | Reserved, zero |

An empty tree has zero height, entry count and all three page references.
Nonempty references are at least `2`. Publication alternates metadata pages.
New nodes are appended before the new generation is published. A full tree
open verifies the highest valid generation and can fall back to the older
independently valid generation if the latest referenced graph is damaged.

## Leaf pages

The common page type is `4` and flags are zero.

| Offset | Bytes | Field |
|---:|---:|---|
| 64 | 4 | ASCII `MSBL` |
| 68 | 2 | Version `2` |
| 70 | 2 | Reserved, zero |
| 72 | 2 | Entry count |
| 74 | 2 | Reserved, zero |
| 76 | 8 | Previous leaf; zero means none |
| 84 | 8 | Next leaf; zero means none |
| 92 | 4 | Reserved, zero |
| 96 | variable | Consecutive leaf entries |

Each entry is `U16 keyLength`, `U16 valueLength`, key bytes, then value bytes.
The next entry begins exactly `4 + keyLength + valueLength` bytes later.
Keys contain 1..256 bytes; values contain 1..3584 bytes. The current node
capacity is at most 10 entries, also on larger pages. The common item count
repeats the entry count and free-start points immediately after the last
entry. Free-end remains page size.

## Internal pages

The common page type is `3` and flags are zero.

| Offset | Bytes | Field |
|---:|---:|---|
| 64 | 4 | ASCII `MSBI` |
| 68 | 2 | Version `2` |
| 70 | 2 | Positive node level |
| 72 | 2 | Separator count `N` |
| 74 | 2 | Reserved, zero |
| 76 | 8 | First child page |
| 84 | 4 | Reserved, zero |
| 88 | variable | Consecutive separator records |

A separator record is `U16 keyLength`, `U16 reservedZero`, `U64 rightChild`,
then key bytes. There are `N + 1` children. The current implementation permits
2..12 children and therefore 1..11 separators. A separator equals the first
key in its right-hand child under the key comparator.

## Key ordering and opaque values

The reserved `MSK` key family carries the SQL key format defined in
`index-file-v2.md`. SQL numeric components are stored without a sign-bit flip
or a big-endian transform. The comparator interprets their types to preserve
signed numeric order, including values beyond MiniLang's scalar integer range.
It compares finite binary64 words directly without string conversions or
temporary decoded SQL values. Both floating zero signs compare equal.

Text and binary components retain byte ordering and use self-delimiting zero
escapes. Composite keys compare component by component; a complete component
prefix sorts before its extensions. This does not change the SQL optimizer's
supported access paths: partial composite predicates still need an explicitly
implemented prefix-range plan.

Raw keys outside the reserved `MSK` family retain lexicographic byte ordering.
When a raw and a SQL key are compared, the raw key sorts first, giving a stable
total order even in a mixed tree. An unknown version in the reserved family is
an error. Leaf values are always opaque bytes: equal keys use lexicographic
value ordering, even if a value happens to begin with the `MSK` marker.
