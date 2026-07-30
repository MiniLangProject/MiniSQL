# 2. Configuration and format identity

## 2.1 Fundamental rule

**Global configuration describes defaults and runtime policy. Persisted files
describe their actual physical format.**

An existing database MUST NOT derive page size, checksum algorithm, row format,
WAL format, encoding, or other physical-format decisions from the current global
configuration.

## 2.2 Setting classes

### Runtime/server settings

Examples: data/log/temporary roots, bind address, port, maximum connections, buffer-pool budget, query
timeout, log level, temporary-memory limit and checkpoint trigger. These MAY be
changed between runs, provided validation succeeds.

### Defaults for new databases

Examples: page size, checksum algorithm, WAL segment size, encoding, collation and
initial format versions. These values are copied into persistent metadata during
`CREATE DATABASE`. Later edits affect only databases created afterwards.

### Engine constants

Magic values, field meanings, endian order and the semantics of a supported format
version are defined by source code and format specifications, not configuration.

## 2.3 Persistent metadata hierarchy

1. supported semantics in the engine and format specification
2. redundant `db.meta` superblocks
3. self-describing table/index/WAL file headers
4. system catalog object metadata
5. global configuration defaults

`db.meta` is authoritative for database-wide format identity. Every table, index
and WAL segment MUST repeat enough identity fields to detect mismatches.

## 2.4 Page size policy

MiniSQL 1.0 uses exactly one page size per database. Every table and index header
repeats that page size. The repeated field is a validation guard, not permission
for per-table page sizes.

A mismatch between `db.meta` and any object file MUST prevent normal writable
opening. MiniSQL MUST NOT guess, silently reinterpret, or overwrite the value.

## 2.5 Physical changes

Changing page size, fundamental row format, checksum scheme or incompatible file
format is an offline migration. It MUST create a new physical database generation,
copy/rebuild all objects, validate them, durably checkpoint them and only then
perform an atomic directory-generation switch. Editing a metadata number in place
is forbidden.

## 2.6 Version separation

The following versions are distinct:

- database format version
- table file format version
- index file format version
- WAL format version
- row format version
- wire protocol version
- per-table schema version

A schema change does not automatically imply an on-disk container format change.
