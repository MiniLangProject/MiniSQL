# 33. DCL, authentication and authorization

## Principals

MiniSQL has `USER` and `ROLE` principals. Names are unique across both kinds. The built-in principals are:

- `admin` (ID 1): enabled login user and superuser.
- `public` (ID 2): enabled non-login role implicitly effective for every user.

The administrator is created without a password so an existing M20 database can be opened locally and upgraded without inventing credentials. Before authenticated service is used, trusted local administration must set one with `ALTER USER admin WITH PASSWORD '...'`.

## DCL syntax

```sql
CREATE USER alice WITH PASSWORD 'a-long-password';
CREATE ROLE reader;
ALTER USER alice WITH PASSWORD 'another-long-password';
ALTER USER alice ENABLE;
ALTER USER alice DISABLE;
DROP USER [IF EXISTS] alice;
DROP ROLE [IF EXISTS] reader;

GRANT reader TO alice [WITH ADMIN OPTION];
REVOKE reader FROM alice;

GRANT SELECT, INSERT ON TABLE document TO reader [WITH GRANT OPTION];
REVOKE INSERT ON TABLE document FROM reader;
GRANT CONNECT, CREATE ON DATABASE TO alice;
```

`ALL [PRIVILEGES]` expands to the complete privilege set valid for the selected object kind.

## Privileges

Database privileges are `CONNECT`, `CREATE`, `MAINTAIN`, and `ADMIN`. Table privileges are `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `REFERENCES`, `INDEX`, `ALTER`, `DROP`, and the internal `OWNER` privilege. `OWNER` implies every table privilege and grant option.

A principal's effective set contains itself, `public`, and the transitive closure of granted roles. Cyclic role grants are rejected. `WITH ADMIN OPTION` permits delegating a role. `WITH GRANT OPTION` permits delegating the corresponding object privilege.

DCL and authenticated DDL are autocommit-only in M21. Direct matching grants are revoked; grant-chain cascade semantics are not yet implemented.

## Authentication

Passwords must contain 12 to 1024 UTF-8 bytes and no NUL. PBKDF2-HMAC-SHA-256
with 600,000 iterations derives a 32-byte salted secret. New credentials persist
`SHA256(HMAC(salted, "MiniSQL Client Key")) || HMAC(salted, "MiniSQL Server Key")`
instead of that password-equivalent secret. A fresh nonce and transcript produce
SCRAM-style client and server proofs. Legacy 32-byte verifier records negotiate
scheme 1 until a password reset writes the 64-byte scheme-2 credential.

The wire sequence is:

```text
HELLO
AUTH_BEGIN(username)
AUTH_CHALLENGE(iterations, salt, nonce, scheme)
AUTH_PROOF(client proof)
AUTH_OK(server proof)
```

A secure session requires `CONNECT` (or superuser) before SQL is accepted. Three failed attempts request connection closure.

## Security boundaries and M21 limitations

- Authenticated service supports native TLS 1.3 for remote binding; trusted plaintext mode remains loopback-only.
- `--serve-one` is a trusted local compatibility/maintenance mode and bypasses DCL. `--serve-auth` enforces authentication and privileges.
- Supplying a password as a command-line argument is provided only for tests and convenience; operating systems can expose command lines to other local processes.
- Legacy scheme-1 verifier theft can enable impersonation until the password is reset. Scheme-2 stored credentials cannot be replayed as client proofs.
- MiniSQL authentication is not a PAKE. TLS remains mandatory for remote connections.
- Authenticated `CREATE TABLE` commits DDL first and then persists the owner grant. M21 does not yet provide one cross-file atomic commit spanning the DDL journal and security sidecar.
