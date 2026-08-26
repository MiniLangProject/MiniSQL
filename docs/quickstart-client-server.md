# Client/server quickstart

```powershell
$compiler = "C:\path\to\MiniLangCompilerPy\mlc_win64.py"
# Use MiniLangCompilerPy or MiniLangCompilerML 1.1.0 or newer.
.\build.ps1 -Compiler $compiler -Target windows-x64 -AppsOnly

.\build\bin\minisqld.exe --init .\data demo 4096
# Copy the db_<uuid> path printed by the command.

.\build\bin\minisqld.exe --serve .\data\db_<uuid> 7432 32
```

For a Linux x64 build and single-client evaluation from Windows/WSL:

```powershell
.\build.ps1 -Compiler $compiler -Target linux-x64 -AppsOnly
wsl -- ./build/bin-linux/minisqld --init ./data demo 4096
wsl -- ./build/bin-linux/minisqld --serve ./data/db_<uuid> 7432 1
```

Linux offline tools, TLS, and single-client server/client operation are
validated. The current Linux socket path can fail or stall with two or more
simultaneous clients, so it is not yet supported for concurrent production
traffic. See `docs/release/LIMITATIONS.md` before deployment.

The final argument bounds native MiniLang connection workers. Each active
client owns one thread-pool job. Read-only plans from different clients may run
in parallel on the same database; a writer-prioritized gate keeps mutations
exclusive. Slow clients no longer stall other connections. Choose the bound for
the expected number of simultaneously connected clients and available memory;
raising it increases connection and read concurrency but does not create
multiple physical writers for one database. These concurrency guarantees are
currently validated end-to-end on Windows; the Linux limitation above takes
precedence.

## Configured logging and SQL binlog

Start a trusted loopback server from the complete JSON configuration:

```powershell
.\build\bin\minisqld.exe --serve-config `
  .\data\db_<uuid> .\config\minisql.example.json
```

Use `--serve-authenticated-config` for the authenticated encrypted server and
`--serve-standby-config` for a loopback standby. The configuration controls the
address, port, connection bound, log directory, severity threshold, stdout and
file destinations, rolling interval, and SQL binlog.

```json
"runtime": { "logLevel": "info" },
"logging": {
  "stdoutEnabled": true,
  "fileEnabled": true,
  "fileName": "minisql.log",
  "rotationHours": 24
},
"binlog": {
  "enabled": true,
  "fileName": "minisql-bin.log"
}
```

Ordinary records use DEBUG, INFO, WARNING, and ERROR. SQL binlog records are
independent of that threshold and are flushed before the statement executes.
The binlog contains complete statement text and can therefore contain personal
data or SQL literals that act as secrets; restrict access to the log directory.

`runtime.bufferPoolBytes` is the actual database-owned, thread-safe committed
page-cache budget. `runtime.checkpointWalBytes` is the current-WAL threshold:
after a committed writer has durably published all table pages, MiniSQL creates
crash-safe epoch/pending markers, resets the WAL, and keeps recovery correct
across the new low-LSN generation. The example configuration uses a 256 MiB
cache and a 64 MiB WAL threshold. A failed maintenance reset leaves the intact
WAL or pending marker for the next writer/open to finish; it never changes an
already durable SQL result into a client retry.

Clean derived indexes are accepted immediately after restart because every
mutation creates a durable `catalog/indexes.dirty` marker before heap commit
and removes it only after index publication. A present marker or missing index
file performs rebuild plus verification under the exclusive database gate.
Use `minisql-check` for an explicit full heap/index integrity audit.

Read-only statements share the database gate only after parsing and
classification. A durable dirty-index marker is repaired under the exclusive
gate before a read proceeds. New readers stop entering once a writer is waiting,
so a sustained read workload cannot starve DML or maintenance.

In a second PowerShell window:

```powershell
.\build\bin\minisql.exe --shell 7432
```

For the native graphical client, launch:

```powershell
.\build\bin\minisql-admin.exe
```

The workbench provides MiniSQL-only connection aliases, an object tree,
multiple SQL worksheets, searchable history, result tabs, CSV export, a paged
data editor with staged changes, and a schema designer with exact DDL preview.
See `docs/release/WORKBENCH.md` for trusted-local, authenticated, TLS, and
pinned-certificate setup.

Statements may span lines and are executed when a real SQL terminator `;` is
seen. Semicolons inside strings, quoted identifiers and comments do not split
the statement. Use `\g` to execute a non-terminated buffer.

Useful shell commands:

```text
\tables
\describe <table>
\indexes <table>
\source <file>
\reset
\ping
\q
```

For authentication:

```powershell
.\build\bin\minisqld.exe --set-admin-password .\data\db_<uuid>
.\build\bin\minisqld.exe --serve-authenticated .\data\db_<uuid> 7432 32
.\build\bin\minisql.exe --auth-shell-prompt 7432 admin
```

For non-interactive SQL that still needs one transaction/session:

```powershell
.\build\bin\minisql.exe --script 7432 .\commands.sql
```

The SQL-aware script scanner supports multiline statements, multiple statements
per line and a final statement without a semicolon.

## M38-M42 write examples

```sql
INSERT INTO target_item(id, label)
SELECT id, label FROM source_item
ON CONFLICT (id) DO UPDATE
SET label = excluded.label
RETURNING id, label;

TRUNCATE TABLE staging RESTART IDENTITY;
```

## Native TLS 1.3 and X.509

MiniSQL terminates TLS directly through the operating system's native provider.
Windows uses Schannel. For a PFX certificate, put the password in the server
process environment and start the native listener:

```powershell
$env:MINISQL_TLS_PFX_PASSWORD = "replace-with-the-PFX-password"
.\build\bin\minisqld.exe --serve-tls `
  .\data\db_<uuid> 0.0.0.0 7443 32 pfx:C:\certs\server.pfx
```

For a certificate installed with its private key in `CurrentUser\MY` or
`LocalMachine\MY`, use `store:<SHA1-thumbprint>`. The thumbprint is only a local
store lookup key.

Connect with ordinary Windows root-store and DNS-name validation:

```powershell
.\build\bin\minisql.exe --tls-shell `
  db.example.org 7443 db.example.org admin
```

For a private self-signed leaf, calculate the SHA-256 digest of its DER and pin
it explicitly:

```powershell
$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new("C:\certs\server.cer")
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$pin = ([BitConverter]::ToString($sha256.ComputeHash($certificate.RawData))).Replace("-", "").ToLowerInvariant()
.\build\bin\minisql.exe --tls-pin-shell `
  127.0.0.1 7443 localhost ("sha256:" + $pin) admin
```

Pin mode ignores only an unknown certificate root. It still rejects expired or
not-yet-valid certificates, a wrong hostname/EKU/signature, and a pin mismatch.
Every connection must negotiate TLS 1.3, `TLS_AES_256_GCM_SHA384`, and X25519.
There is no Python TLS process or plaintext proxy hop. Native TLS requires
Windows 11 or Windows Server 2022 or newer.

Linux uses OpenSSL 3 and an unencrypted PEM certificate/key pair. Separate the
two paths with `|`; quote the complete reference so the shell does not interpret
that character:

```bash
./build/bin-linux/minisqld --serve-tls \
  ./data/db_<uuid> 0.0.0.0 7443 32 'pem:/etc/minisql/server.crt|/etc/minisql/server.key'

./build/bin-linux/minisql --tls-shell \
  db.example.org 7443 db.example.org admin
```

The Linux client uses OpenSSL's default trust paths plus hostname validation.
`--tls-pin-shell` applies the same `sha256:<DER-fingerprint>` leaf pin contract
as Windows. Encrypted PEM private keys are not currently accepted by the native
Linux adapter; protect the key with filesystem permissions and a dedicated
service account.

## Continuous read-only hot standby (M48)

Create the initial archive while the database is not being served:

```powershell
.\build\bin\minisql-backup.exe archive-init `
  .\data\db_<uuid> .\archive\demo
```

Start durable WAL export alongside the primary:

```powershell
python .\tools\replication\minisql_hot_replica.py primary `
  --database .\data\db_<uuid> `
  --archive .\archive\demo `
  --backup-exe .\build\bin\minisql-backup.exe
```

Start the double-buffer standby controller:

```powershell
python .\tools\replication\minisql_hot_replica.py standby `
  --archive .\archive\demo `
  --slot-root .\standby\demo `
  --backup-exe .\build\bin\minisql-backup.exe `
  --server-exe .\build\bin\minisqld.exe `
  --listen-port 7433
```

Connect read-only clients to port 7433. Replication is asynchronous and does not
provide automatic promotion, quorum commits or split-brain prevention.

## Build the MiniSQL 1.0 distribution

```powershell
.\release.ps1 -Compiler $compiler
```

The release archive and its SHA-256 sidecar are written to `build\release`.
