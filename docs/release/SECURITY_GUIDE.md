# MiniSQL 1.0 security guide

Use users, roles and least-privilege grants. Set the initial administrator
password locally with `minisqld.exe --set-admin-password` and use prompt-based
client commands so secrets do not appear in process command lines.

The native server binds to loopback unless an authenticated encrypted transport
mode is selected. For standards-compatible remote transport, use the native TLS
listener. Its system mode validates the X.509 chain, hostname, validity period,
signature and Server Authentication EKU. For a deliberately self-signed server,
use client pinning with the exact SHA-256 digest of the leaf certificate and
deliver that pin through an authenticated channel. Protect database files,
audit keys, backup archives, PFX files, private keys and replication directories
with operating-system ACLs.

## Stored procedure authorization

New MySQL-style procedure definitions default to `SQL SECURITY DEFINER`.
Explicit `SQL SECURITY INVOKER`, and legacy `AS` definitions without an explicit
security characteristic, use the caller's authority. Both forms require the
caller to have applicable `EXECUTE` permission for newly created definitions.
A definer-context call additionally requires the definer to hold EXECUTE on the
procedure; the creator and definer can be different accounts.
The body is authorized using the selected effective principal, which is restored
after normal or exceptional return. A missing or disabled definer fails closed.

`CREATE ROUTINE` applies to the database. `EXECUTE` and `ALTER ROUTINE` apply
either to a named procedure or to all procedures in the database. Generic
`CREATE` no longer permits procedure creation. Existing author roles must be
migrated with an explicit grant:

```sql
GRANT CREATE ROUTINE ON DATABASE TO procedure_author;
GRANT SHOW_ROUTINE ON DATABASE TO routine_inspector;
```

Creators receive procedure EXECUTE and ALTER ROUTINE without GRANT OPTION when
`automatic_sp_privileges` is enabled. This administrative session setting is
true by default and controls subsequent creations in that session; it does not
remove previously granted privileges. A false value leaves the creator without
implicit execution or alteration authority.

Definition visibility is independent of execution. EXECUTE, ALTER ROUTINE and
CREATE ROUTINE expose the relevant metadata, while `routine_definition` and
SHOW CREATE's definition column remain SQL NULL. The durable definer,
administrators, and accounts with SHOW_ROUTINE or database SELECT may read the
source. SHOW_ROUTINE grants neither CALL nor table access. Database SELECT also
grants SELECT on all tables in that database and should be used only when that
broader access is intended.

Selecting another existing ordinary user as definer requires SET_ANY_DEFINER or
administration. SET_ANY_DEFINER alone cannot choose a superuser. Missing or
disabled accounts are rejected; MiniSQL does not create orphan definers. Roles
and delegation use the existing security catalog, including transitive role
membership. MySQL host-qualified account matching, separate active/default role
sets, and the SYSTEM_USER/ALLOW_NONEXISTENT_DEFINER administration model are not
introduced by these routine privileges.

Review definer bodies and dynamic SQL before granting execution to less
privileged callers. Keep untrusted values in bound parameters. Procedure output
parameters are copied back only on successful completion, but a failing call is
not automatically a transaction rollback; transaction boundaries must be explicit.

Procedure grants reference the durable extension object ID. Drop/recreate gives
the replacement a new ID, and cleanup removes the old grants. Definers likewise
use persisted principal IDs rather than resolving a potentially reused user name.
Interrupted cleanup therefore cannot transfer an old procedure grant to a new
object. Restore schema and security snapshots together using supported tools.

## Encryption at rest and key management

Use BitLocker on Windows or LUKS/dm-crypt on Linux in addition to MiniSQL TDE.
Volume encryption covers paths, deleted-file remnants, filesystem metadata,
logs and crash dumps. TDE adds a database-aware boundary for copied paged
files, WAL records and temporary query spills. Neither protects plaintext in a
running compromised process.

`--generate-encryption-key` creates exactly 32 random bytes. Store that key
outside database, backup and replication trees. TDE creates a separate random
database encryption key (DEK), wraps it with the external key-encryption key
(KEK) using AES-256-GCM, and stores only the envelope in `encryption.meta`.
Every page uses an independent 96-bit nonce and 128-bit tag; AAD binds it to
database ID, file ID and page number. WAL and spill records use independent
nonces and domain-separated AAD.

Enable TDE while the database is stopped:

```powershell
minisqld.exe --generate-encryption-key D:\MiniSQL-Keys\primary.key
minisqld.exe --enable-encryption D:\MiniSQL-Data\db_<uuid> D:\MiniSQL-Keys\primary.key
```

Migration is resumable: each paged file publishes its encryption feature only
after the encrypted replacement is durable. Do not retire the old KEK until a
checker and a recovery drill have succeeded.

Online KEK rotation atomically rewraps the unchanged DEK:

```powershell
minisqld.exe --generate-encryption-key D:\MiniSQL-Keys\primary-next.key
minisqld.exe --rotate-encryption-key D:\MiniSQL-Data\db_<uuid> D:\MiniSQL-Keys\primary-next.key
```

Use `backup-encrypted` with a distinct backup key. Each captured file is
independently authenticated and remains covered by the manifest. Restore
verifies checksums and GCM tags before publication; wrong keys and modifications
fail closed. The TDE envelope is rewrapped for the backup key, whose configured
path must remain available while the backup is created. On restore, the same
key bytes may be supplied from a different machine-local path; MiniSQL
authenticates the exported envelope and rewraps the DEK to that restore
provider identity before opening the database.

The provider- and algorithm-tagged key API is crypto-agile. Version 1 installs
a raw 32-byte file provider and AES-256-GCM wrapping. OS keystore, HSM and cloud
KMS providers can implement the same contract without changing page, WAL,
spill or backup consumers. Raw files are an automation baseline, not an HSM.

## Password authentication

Passwords contain 12 to 1024 UTF-8 bytes. PBKDF2-HMAC-SHA-256 with 600,000
iterations derives a salted secret, but new accounts persist only a SCRAM-style
32-byte `StoredKey` and 32-byte `ServerKey`. The salted password-equivalent
secret is wiped. A fresh nonce binds client and server proofs to one transcript.
Unknown and disabled users use deterministic database-bound fake scheme-2
material and share the wrong-password response. Legacy 32-byte verifier records
remain readable until an account password change upgrades them. TLS remains
mandatory for remote connections; this protocol is not a PAKE.

The optional SQL binlog records every valid UTF-8 statement before parsing or
execution, including statements that later fail. It can therefore contain
credentials or personal data embedded in SQL literals. Keep binlog and ordinary
rolling log directories outside web roots, restrict them with operating-system
ACLs, include them in retention/deletion policies, and enable the binlog only
when this complete statement history is explicitly required. A binlog write
failure rejects the statement before execution so an enabled binlog cannot
silently develop gaps.
