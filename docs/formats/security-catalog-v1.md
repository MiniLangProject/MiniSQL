# Security catalog format v1

The protected envelope payload remains security format v1:

- Magic: `MSSEC001`
- Format version: 1
- Kind: 70
- Envelope CRC-32C protects header and payload.

The payload contains the database UUID, generation, next principal ID, counts,
principals, role memberships, and privilege grants. All IDs are unsigned 64-bit
fields constrained to the native supported range when decoded. New snapshots set
envelope flag `1` and store the three collection counts as U32 values in a
48-byte payload header. The reader also accepts legacy flag `0` snapshots with
the original 40-byte header and U16 counts; the next security mutation rewrites
that state in the extended layout. The protected envelope version intentionally
remains `1`, because record encodings and all remaining semantics are unchanged.

A mutation clones the current state, validates all semantics, increments the
generation, and writes slot `(generation - 1) mod 2`. Each slot is now an
independent scalable paged file, `catalog/security.0.tbl` or
`catalog/security.1.tbl`, using the same continuation layout as the bootstrap
catalog. Open validates both files independently and selects the highest valid
generation. A torn or corrupt newest generation therefore falls back to the
previous state. Equal-generation disagreement and cross-database identity
mismatches are corruption errors.

Principal records include flags, UTF-8 name, PBKDF2 iteration count, salt, and verifier. Roles have empty password fields. Membership and grant records contain grantor identity and their option bit.

`catalog/security.tbl` remains a two-page legacy bootstrap copy for backward
compatibility. Older databases are migrated under their exclusive database lock;
`catalog/security.v2` is published only after both scalable generations are
durable. The envelope is no longer constrained to one page and no longer has
the former 65,535-entry collection ceiling.

## Routine privilege codes

Stored-procedure support adds codes to the existing 40-byte privilege record;
the record layout and envelope version remain unchanged.

| Record offset | Width | Meaning |
|---:|---:|---|
| 0 | 8 | Grantee principal ID, unsigned little endian |
| 8 | 8 | Grantor principal ID, unsigned little endian |
| 16 | 8 | Object ID, unsigned little endian |
| 24 | 2 | Object type, unsigned little endian |
| 26 | 2 | Privilege code, unsigned little endian |
| 28 | 4 | Flags; bit 0 is GRANT OPTION |
| 32 | 8 | Reserved zero bytes |

Object types are database `1`, table `2`, and procedure `3`. A database grant
uses object ID zero; a procedure grant uses its positive persisted
`ViewDefinition.viewId` from `schema.extensions`.

| Privilege | Code | Accepted scopes |
|---|---:|---|
| EXECUTE | 20 | Database or procedure |
| ALTER ROUTINE | 21 | Database or procedure |
| CREATE ROUTINE | 22 | Database only |

Database EXECUTE/ALTER ROUTINE grants include each procedure, including grants
inherited through roles. GRANT OPTION is checked independently of execution or
alteration authority. CREATE ROUTINE is invalid on one procedure. These codes
are never accepted as table privileges.

The updated reader accepts older snapshots. Older binaries do not understand
the new object/privilege codes and reject snapshots containing them; do not
downgrade an updated database after creating routine grants. Unknown codes must
remain errors rather than silently granting or discarding authority.
