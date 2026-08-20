# 20. Database directories, configuration and bootstrap catalog

## 20.1 Configuration authority

`minisql.json` contains mutable server/runtime settings and **defaults for newly created
databases only**. Existing databases MUST NOT derive page size, encoding, checksum choice,
row format or other persisted format versions from the current global configuration.

The authority order is:

1. supported format rules in the engine;
2. persisted `db.meta` metadata;
3. self-describing catalog/table/index file headers;
4. catalog object metadata;
5. global defaults only during creation.

Changing `databaseDefaults.pageSize` after shutdown MUST affect only databases created
later. Changing an existing database requires a future explicit offline migration.

## 20.2 Directory creation

Each database receives a unique directory containing at least:

```text
db.meta
db.lock
catalog/catalog.tbl
catalog/security.tbl
catalog/security.0.tbl
catalog/security.1.tbl
catalog/security.v2
tables/
indexes/
wal/wal.log
wal/checkpoint.meta
tmp/
```

Creation occurs under `.db_<uuid>.creating`. After every required file is valid and durable,
the temporary directory is atomically renamed to `db_<uuid>`. User-controlled SQL names
MUST NOT become arbitrary file paths; physical object files use numeric IDs.

## 20.3 Identity and validation

Every database has a 16-byte UUID. `db.meta`, catalog, checkpoint and physical object files
MUST agree on database identity. Table files MUST agree on object ID, file type and page
size. Missing expected files, contradictory headers and files copied from another database
MUST be rejected rather than guessed or rewritten automatically.

## 20.4 Scalable bootstrap catalog

The original M8 layout stored tables and columns in one protected catalog page.
Current writers transparently migrate that payload to a checksummed multi-page
blob. Continuation pages repeat the total byte length, page index, and page
count; page zero is published only after all continuations are durable. Catalog
capacity therefore grows with the paged file instead of stopping at one page.
Readers continue to accept an original one-page database and migrate it on the
next metadata write.

Authorization metadata uses two independent multi-page generation files. The
newest valid generation wins and the other remains a torn-write fallback. The
`security.v2` marker prevents a published database with a missing generation
from silently downgrading to its legacy `security.tbl` bootstrap copy.

Identifier allocation is monotonic. `db.meta` is the authoritative high-water mark. A crash
may leave harmless gaps, but an object or transaction ID MUST never move backwards and reuse
a previously published identity.

M8 catalog operations are storage primitives, not SQL DDL. Transactional SQL catalog
changes and constraints arrive in M14.

## 20.5 Pre-DCL safety

The configuration parser is strict and rejects duplicate keys, unsupported numeric forms,
unknown persisted format versions and unsafe remote binding unless an explicit unsafe flag
is present. The distributed default binds only to loopback and uses full durability.
