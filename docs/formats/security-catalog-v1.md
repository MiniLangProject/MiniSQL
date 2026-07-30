# Security catalog format v1

`catalog/security.tbl` is a normal MiniSQL paged file with file ID 0 and exactly two catalog pages. Each page stores one protected envelope:

- Magic: `MSSEC001`
- Format version: 1
- Kind: 70
- Envelope CRC-32C protects header and payload.

The payload contains the database UUID, generation, next principal ID, counts, principals, role memberships, and privilege grants. All IDs are unsigned 64-bit fields constrained to the native supported range when decoded.

A mutation clones the current state, validates all semantics, increments the generation, writes slot `(generation - 1) mod 2`, reseals the page, and durably flushes it. Open validates both slots independently and selects the highest valid generation. A torn or corrupt newest generation therefore falls back to the previous state. Equal-generation disagreement and cross-database identity mismatches are corruption errors.

Principal records include flags, UTF-8 name, PBKDF2 iteration count, salt, and verifier. Roles have empty password fields. Membership and grant records contain grantor identity and their option bit.

The complete encoded envelope must fit in `pageSize - 68` bytes in M21. Exceeding this limit fails before durable state is replaced.
