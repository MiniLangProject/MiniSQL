# Database metadata format v2

This is the current **unreleased storage-v2** contract. Product version 1.1.1
is unchanged by the development patch. Database-format-1 metadata is rejected;
this format provides no legacy conversion path.

All multibyte numeric fields below are little-endian. Offsets are relative to
the structure named in each table. UUIDs and UTF-8 names are stored as raw
bytes rather than integer values.

## Physical file and page wrapper

`db.meta` is a [paged file](paged-file-v1.md) with file type 4
(`DATABASE_META`) and file ID 1. Its two 4096-byte superblocks retain version 1.
Logical page 0 stores database metadata using common page-header version 1,
page type 5 (`CATALOG`):

| Page offset | Bytes | Field |
|---:|---:|---|
| 0 | 64 | Common page header and its header/payload CRC-32C fields |
| 64 | 4 | Length `E` of the database metadata envelope |
| 68 | `E` | Complete `MSDBM001` envelope |
| `68 + E` | remaining | Zero-filled page tail written by the current serializer |

The metadata envelope must fit in this page. For an unencrypted file, page 0
starts at file offset 8192, the envelope at 8260, and its payload at 8292.
With TDE, those are logical offsets after authenticated page decryption;
physical page records use the `pageSize + 28` stride described in
[encryption-envelope-v1.md](encryption-envelope-v1.md).

The new `MSTB` user-table header does not apply to `db.meta`, the bootstrap
catalog, or security metadata files.

## Database metadata envelope

The generic [protected-envelope v1](protected-envelope-v1.md) **header
structure** is unchanged. Its enclosed-format version is now 2:

| Envelope offset | Bytes | Field |
|---:|---:|---|
| 0 | 8 | ASCII magic `MSDBM001` |
| 8 | 2 | Database metadata format version = 2 |
| 10 | 2 | Kind = 1 |
| 12 | 4 | Flags = 0; no flags are currently supported |
| 16 | 4 | Payload length `N` |
| 20 | 4 | CRC-32C of exactly the `N` payload bytes |
| 24 | 4 | CRC-32C of all 32 header bytes with this field zero |
| 28 | 4 | Reserved, zero |
| 32 | `N` | Database metadata payload |

`E` must equal `32 + N`. The unchanged ASCII suffix `001` is part of the
format-family magic; it does not supersede the explicit U16 version field.
The page checksum and both envelope checksums are validated independently.

## Payload

| Payload offset | Bytes | Field / required value |
|---:|---:|---|
| 0 | 4 | Database page size: 4096, 8192, 16384 or 32768 |
| 4 | 4 | Configured WAL logical segment size in bytes |
| 8 | 2 | Database format version = 2 |
| 10 | 2 | Table-file format version = 2 |
| 12 | 2 | Index-file format version = 2 |
| 14 | 2 | WAL framing version = 1 |
| 16 | 2 | Physical row format version = 2 |
| 18 | 2 | Text encoding ID = 1 (UTF-8) |
| 20 | 2 | Default collation ID = 1 (binary) |
| 22 | 2 | Database-name length `L`, in UTF-8 bytes |
| 24 | 8 | Next object ID |
| 32 | 8 | Next transaction ID |
| 40 | 8 | Checkpoint LSN |
| 48 | 16 | Database UUID |
| 64 | 4 | Reserved, zero |
| 68 | 4 | Reserved, zero |
| 72 | 8 | Reserved, zero |
| 80 | `L` | UTF-8 database name, without a terminator |

The payload length is exactly `80 + L`. The metadata codec accepts a nonempty
name of at most 255 UTF-8 bytes; database-creation APIs apply their stricter
identifier rules before encoding. Initial values are next-object ID 3,
next-transaction ID 1 and checkpoint LSN 0. The persisted U64 identifiers and
LSNs in this payload are constrained to the supported nonnegative MiniLang
scalar range, at most `2^60 - 1`.

There are **no payload flag bits** in this layout. Bytes 64 through 79 are all
reserved zero; they must not be repurposed as feature flags. Unknown envelope
flags, nonzero reserved fields, an unsupported version tuple, invalid lengths,
checksum failures or contradictory database identity cause open failure.
The overflow format has its own version-2 fields and is selected by database
generation 2; this fixed payload has no separate overflow-version slot.

## Catalog companion

`catalog/catalog.tbl` remains a paged file of type 1, file ID 2. Its catalog
envelope is still `MSCAT001`, version 1, kind 2, flags 0. This is independent of
the version-2 database envelope and user-table files.

Current catalog writers divide the entire encoded catalog envelope into
consecutive chunks. Each page has common type 5 and this continuation header:

| Page offset | Bytes | Field |
|---:|---:|---|
| 64 | 4 | ASCII `BLB2` |
| 68 | 2 | Continuation format version = 1 |
| 70 | 2 | Reserved, zero |
| 72 | 8 | Total encoded envelope length |
| 80 | 8 | Zero-based chunk index |
| 88 | 8 | Total chunk-page count |
| 96 | 4 | Chunk length on this page |
| 100 | 4 | Reserved, zero |
| 104 | variable | Chunk bytes, at most `pageSize - 104` |

The catalog is therefore not restricted to one page. Continuation pages repeat
global length and page count so missing, reordered and stale pages can be
detected. The reader's retained one-page catalog representation is an
independent catalog compatibility detail; it does not bypass the database-v2
gate or permit opening a legacy database.

`db.meta` owns database format identity and ID high-water marks. The catalog
UUID and object metadata, user-table headers and selected file superblocks
must agree with that identity. The implementation is in
[`metadata.ml`](../../src/minisql/catalog/metadata.ml) and
[`catalog.ml`](../../src/minisql/catalog/catalog.ml).
