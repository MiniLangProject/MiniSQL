# Unreleased storage-v2 development guide

This development patch intentionally changes the database format to **2**.
The product-version string remains **1.1.1**. Existing 1.1.1 release artifacts
and historical test reports refer to their original builds; their database
compatibility and acceptance evidence have not been relabeled as storage-v2
evidence.

## Existing databases are rejected

The current engine does not open database-format-1 files, including databases
created by the M8-M50 milestones or earlier 1.0.0, 1.1.0 and 1.1.1 builds.
It supplies **no automatic upgrade, legacy import or in-place conversion**.
The development format is intended for newly created databases. Existing data
must continue to be accessed with its compatible older build; no data-transfer
procedure is promised by this patch.

Changing configuration defaults or editing a version number cannot convert a
database. The representation changed for REAL/DOUBLE values, row alignment,
table page zero, overflow pointers and numeric index keys. Retain existing
files separately when trying this development tree. New storage-v2 databases
cannot be opened by format-1 binaries.

## What changed and what retained its framing

The required database/table/index/WAL/row version tuple is `2/2/2/1/2`.
Overflow pointers and chain pages also use version 2. `db.meta` uses the same
32-byte protected-envelope structure, with its own envelope version set to 2.
User tables reserve page zero for their checked immutable identity header.

The 64-byte common page header, 4096-byte superblock slots, WAL record framing,
wire protocol, and encryption-record framing retain their existing versions.
These retained wrappers can contain new storage-v2 data; they do not provide
cross-generation compatibility. The catalog envelope and auxiliary metadata
retain their independently defined versions.

## Tools and backups

The consistency checker and backup/restore paths enforce the current database
format. A backup created by the current engine contains a storage-v2 database;
an unchanged backup-manifest or archive version is not a legacy-import path.
WAL page images must belong to the matching database generation and identity.

Offline page-size rewriting is available between databases already supported
by this engine. It creates a fresh storage-v2 target and verifies it before
publication. It is **not** a format-1 to format-2 upgrader. Supported database
page sizes remain 4096, 8192, 16384 and 32768 bytes.

Optimizer-statistics sidecar evolution is independent of this change: the
writer uses version 5 and its reader retains the supported earlier statistics
representations. Such sidecar compatibility is evaluated only after a database
passes the storage-v2 format gate. Removing a sidecar cannot make the database
compatible with an older engine.

See the [format index](../formats/README.md),
[compatibility contract](../formats/FORMAT_COMPATIBILITY.md), and
[machine-readable matrix](upgrade-matrix.json) for the current development
state. Dated release reports remain historical evidence for their named builds.
