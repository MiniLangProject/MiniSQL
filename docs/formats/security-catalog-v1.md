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
