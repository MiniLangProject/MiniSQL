# 11. DCL roadmap and status

M21 implements the first DCL/authentication stage after the accepted DDL, DML, transaction and recovery foundation.

Implemented in M21:

- users and login identities;
- roles, transitive role membership and cycle rejection;
- salted PBKDF2-HMAC-SHA-256 password verifiers through Windows CNG;
- database and table privileges;
- `GRANT` and `REVOKE`;
- owner semantics;
- authenticated challenge-response protocol handshake;
- statement authorization in the executor;
- security-aware backup and consistency checking.

Still planned:

- column and schema privileges;
- grant-chain tracking and cascade revocation;
- audit-event persistence;
- memory-hard password hashing when a suitable stable platform primitive is selected;
- TLS-protected remote connections;
- secure interactive credential input;
- session concurrency and connection pooling.

Storage files never trust client-supplied object IDs. Names are bound to catalog objects before authorization is evaluated.
