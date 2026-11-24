# Storage format 2

This is the normative format for the current development tree. It is an
intentional compatibility break: databases created with storage format 1 do not
open with this implementation. There is no automatic format-1 migration.

## Changes

| Area | Format 2 contract | Detailed layout |
|---|---|---|
| REAL / DOUBLE | Both use 8-byte IEEE-754 binary64, little-endian; no decimal text conversion | [Row v2](row-v2.md) |
| Alignment | Row start and length are multiples of 8; fixed-width values are naturally aligned; every padding byte is zero | [Row v2](row-v2.md), [slotted pages v2](slotted-page-v2.md) |
| User tables | Logical page 0 is a mandatory immutable `MSTB` metadata page; data pages start at 1 | [Table file v2](table-file-v2.md) |
| Overflow | Total length is U32 at pointer offset 24; the aligned pointer remains 48 bytes and has its own CRC-32C | [Overflow v2](overflow-v2.md) |
| SQL indexes | Signed integral components use I64LE; floating components use binary64LE; typed comparison supplies numeric ordering | [Index file v2](index-file-v2.md), [B+ tree v2](btree-v2.md) |

REAL retains its existing MiniSQL binary64 precision; this change does not narrow
it to binary32. The floating codec preserves finite values exactly, including
subnormals and both zero signs. NaN and infinities are rejected. Index comparison
treats both zero signs as equal; an INCLUDE payload preserves the value's sign.

Little-endian numeric index bytes are not lexicographically sortable. For
example, integer 255 ends in the component bytes `ff 00 00 00 00 00 00 00`, while
256 uses `00 01 00 00 00 00 00 00`. The typed B+ tree comparator still orders 255
before 256. SQL keys begin with `MSK` and byte 2; raw keys outside this reserved
family retain their bytewise ordering. Leaf values remain opaque byte strings.

The 48-byte overflow pointer intentionally retains four zero alignment bytes at
offset 28, so the owner ID remains U64-aligned at offset 32. They are reserved
bytes, not part of the U32 length. The last four bytes now protect the pointer
itself with CRC-32C. The maximum external length remains 4,294,967,295 bytes.

## Version identities

`minisql.common.format_version` is the single registry for the affected formats.

| Identifier | Version |
|---|---:|
| Database metadata envelope and database identity | 2 |
| Table header | 2 |
| Row | 2 |
| Overflow pointer and chain page payload | 2 |
| Index metadata, B+ tree payload, typed key and INCLUDE payload | 2 |
| Generic superblock, common page and WAL framing | 1 |
| Wire protocol | 1 |

Configuration defaults and persisted database metadata require the version tuple
`database=2, table=2, index=2, wal=1, row=2`. Changing a configuration file or a
version field does not convert old data. Unknown versions and mixed old/new
identities are rejected. The generic 32-byte protected-envelope structure is
unchanged; its database-specific version field is now 2.

## Validation

Run the focused gate on its native host:

```powershell
./test.ps1 -StorageV2 -Target linux-x64 -Compiler ../MiniLangCompilerPy/mlc_win64.py
```

Use `-Target windows-x64` on Windows. The internal portable runner also supports
`--integration` to include the relevant catalog, heap, overflow, B+ tree, WAL,
recovery, SQL, schema-evolution, maintenance, migration and encryption suites.
Every invocation uses fresh directories under `build/storage-v2/gates` and saves
compiler logs, test logs and `results.json`. `--compile-only` explicitly records
a compilation check without claiming native execution.

The new format tests cover exact byte vectors, old-format rejection, checksummed
corruptions, alignment and padding, full signed integer range, floating-point
edge cases, index ordering/uniqueness, persistence after reopening, and index-only
results compared bit for bit against heap values. Historical release acceptance
reports remain historical evidence; they are not a new Windows acceptance run.
