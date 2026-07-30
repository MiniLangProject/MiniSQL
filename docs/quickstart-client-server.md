# Client/server quickstart

```powershell
$compiler = "C:\Users\nilsk\Desktop\MiniLangCompilerPy\mlc_win64.py"
.\build.ps1 -Compiler $compiler -AppsOnly

.\build\bin\minisqld.exe --init .\data demo 4096
# Copy the db_<uuid> path printed by the command.

.\build\bin\minisqld.exe --serve .\data\db_<uuid> 7432 32
```

In a second PowerShell window:

```powershell
.\build\bin\minisql.exe --shell 7432
```

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

## TLS 1.3/X.509 sidecar (M47)

Keep the native MiniSQL server on loopback and terminate standard TLS in front
of it:

```powershell
python .\tools\tls\minisql_tls_proxy.py server `
  --listen-host 0.0.0.0 --listen-port 7443 `
  --backend-host 127.0.0.1 --backend-port 7432 `
  --cert C:\certs\server.pem --key C:\certs\server-key.pem
```

On the client machine, expose a verified loopback proxy:

```powershell
python .\tools\tls\minisql_tls_proxy.py client `
  --listen-host 127.0.0.1 --listen-port 7432 `
  --remote-host db.example.org --remote-port 7443 `
  --server-name db.example.org --ca C:\certs\ca.pem

.\build\bin\minisql.exe --shell 7432
```

The client rejects untrusted certificates, hostname mismatches and protocol
versions other than TLS 1.3. Test certificates under `tests\fixtures\tls` are
not deployment credentials.

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
