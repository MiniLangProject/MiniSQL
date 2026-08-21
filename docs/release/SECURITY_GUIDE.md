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

The optional SQL binlog records every valid UTF-8 statement before parsing or
execution, including statements that later fail. It can therefore contain
credentials or personal data embedded in SQL literals. Keep binlog and ordinary
rolling log directories outside web roots, restrict them with operating-system
ACLs, include them in retention/deletion policies, and enable the binlog only
when this complete statement history is explicitly required. A binlog write
failure rejects the statement before execution so an enabled binlog cannot
silently develop gaps.
