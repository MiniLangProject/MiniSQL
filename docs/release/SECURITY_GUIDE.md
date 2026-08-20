# MiniSQL 1.0 security guide

Use users, roles and least-privilege grants. Set the initial administrator
password locally with `minisqld.exe --set-admin-password` and use prompt-based
client commands so secrets do not appear in process command lines.

The native server binds to loopback unless the authenticated encrypted transport
mode is selected. For standards-compatible remote transport, place the M47 TLS
1.3/X.509 sidecar in front of a loopback backend and validate hostnames and the
issuing CA. Protect database files, audit keys, backup archives, private keys and
replication directories with operating-system ACLs.

The optional SQL binlog records every valid UTF-8 statement before parsing or
execution, including statements that later fail. It can therefore contain
credentials or personal data embedded in SQL literals. Keep binlog and ordinary
rolling log directories outside web roots, restrict them with operating-system
ACLs, include them in retention/deletion policies, and enable the binlog only
when this complete statement history is explicitly required. A binlog write
failure rejects the statement before execution so an enabled binlog cannot
silently develop gaps.
