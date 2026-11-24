# Overflow pointer and page format v2

Storage generation 2 deliberately rejects v1 pointers and overflow pages. All
fixed-width numeric fields are little-endian. Large TEXT/BLOB values retain the
existing page-chain representation; their total byte length is now explicitly
U32 in both the row pointer and every chain page.

## External pointer: 48 bytes

Offsets are relative to the start of the external value in a row. The row aligns
this pointer to eight bytes, so its U64 identifiers are naturally aligned.

| Offset | Bytes | Field |
|---:|---:|---|
| 0 | 4 | ASCII `MSOP` |
| 4 | 2 | version = 2 |
| 6 | 2 | reserved, zero |
| 8 | 8 | file ID |
| 16 | 8 | first logical overflow page |
| 24 | 4 | total value length, U32 |
| 28 | 4 | reserved alignment bytes, zero |
| 32 | 8 | owner ID |
| 40 | 4 | CRC-32C of the complete external value |
| 44 | 4 | CRC-32C of all 48 pointer bytes, this field zeroed |

The four bytes at 28 are not the high word of a length. Values larger than
4,294,967,295 bytes are rejected before allocation. An empty value has length
zero, no chain, and first page `UINT64_MAX`. Pointer CRC validation is independent
of the containing row's page checksum and the external value's checksum.

## Chain pages

Each page begins with the common 64-byte `MSPG` header, type 2. The user table's
logical page zero is reserved for its table header; overflow chains use data
pages following it.

| Page offset | Bytes | Field |
|---:|---:|---|
| 64 | 4 | ASCII `MSOV` |
| 68 | 2 | version = 2 |
| 70 | 2 | reserved, zero |
| 72 | 8 | owner ID |
| 80 | 8 | next page; `UINT64_MAX` terminates the chain |
| 88 | 4 | chunk byte length |
| 92 | 4 | total value byte length, U32 |
| 96 | 4 | zero-based sequence number |
| 100 | 4 | reserved, zero |
| 104 | variable | chunk bytes |

A page carries at most `pageSize - 104` chunk bytes. The reader checks page
identity, version, checksums, owner, sequence, length and termination before
returning a value. The SQL writer externalizes TEXT/BLOB values larger than
`pageSize / 4`; that policy is unchanged.
