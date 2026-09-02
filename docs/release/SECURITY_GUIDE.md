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
