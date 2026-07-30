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

## 20.4 Bootstrap catalog v1

M8 stores database metadata, immutable format defaults, next object ID, next transaction ID,
tables and columns in protected envelopes inside one catalog page. The one-page size limit
is explicit. M14 will migrate logical metadata to ordinary system relations while retaining
the bootstrap identity required to open those relations.

Identifier allocation is monotonic. `db.meta` is the authoritative high-water mark. A crash
may leave harmless gaps, but an object or transaction ID MUST never move backwards and reuse
a previously published identity.

M8 catalog operations are storage primitives, not SQL DDL. Transactional SQL catalog
changes and constraints arrive in M14.

## 20.5 Pre-DCL safety

The configuration parser is strict and rejects duplicate keys, unsupported numeric forms,
unknown persisted format versions and unsafe remote binding unless an explicit unsafe flag
is present. The distributed default binds only to loopback and uses full durability.
