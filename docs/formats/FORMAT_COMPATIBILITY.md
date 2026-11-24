# Format compatibility: unreleased storage v2

The current development tree requires **database format 2**. Its product
version is still **1.1.1**; the earlier format-1 builds bearing that version and
their dated release evidence are unchanged. Persisted version fields, rather
than the product-version string, determine compatibility.

## Version boundaries

| Component | Current version |
|---|---:|
| Database metadata envelope and database format | 2 |
| User-table file header | 2 |
| Physical row record | 2 |
| Overflow pointer and chain page | 2 |
| B+ tree metadata/node payload | 2 |
| SQL index key and INCLUDE payload | 2 |
| Common page header | 1 |
| Paged-file superblock | 1 |
| WAL record framing | 1 |
| Generic protected-envelope header structure | 1 |
| Catalog envelope | 1 |
| Wire protocol | 1 |

The slotted-page payload uses the aligned v2 allocation contract, selected by
the database/table format. Its common page-header version remains 1. The
generic protected-envelope structure has no independent outer version field:
the U16 at offset 8 is the enclosed format's version, which is 2 for `db.meta`.

## Accepted and rejected input

- A database created by this storage-v2 implementation opens only when all
  required identities, supported versions, reserved fields and checksums agree.
- Existing database-format-1 files are rejected, including empty databases and
  databases from earlier 1.1.1 builds. No compatibility decoder or automatic
  upgrade is provided.
- Legacy table files without the required metadata page 0, row records with
  version 1, overflow version 1, and B+ tree version 1 are rejected.
- Unknown versions or unsupported flags are rejected. Configuration defaults
  cannot override persisted identity or reinterpret existing bytes.
- There is no supported downgrade of storage-v2 databases to format-1 engines.

Schema versions remain separate from physical row-format versions: compatible
column evolution inside a storage-v2 database does not enable reading a
row-format-1 record.

## WAL, backups and auxiliary records

Unchanged WAL framing does not make old and new page images interchangeable.
Storage-v2 recovery operates on the current database and its matching page
images. Backup and WAL-archive framing also keep their existing versions, but
their contained database must pass the storage-v2 checks. No legacy-backup
import path is introduced by this patch.

The durable-WAL marker and HA epoch/lease records retain their independent
layouts and do not select a storage generation. Existing statistics and
security-sidecar compatibility rules apply only after the enclosing database
has passed the database-format gate.

The offline page-size rewrite operates between databases supported by the
current engine. It creates a new storage-v2 database; it is not a format-1 to
format-2 conversion tool. See [UPGRADE.md](../release/UPGRADE.md) for the
development-build policy.
