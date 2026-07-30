# MiniSQL operational client/server specification v1

## Purpose

The earlier public binaries exposed protocol primitives but not a complete
from-zero workflow. M32 defines the operational lifecycle for the public
applications.

## Database initialization

```text
minisqld.exe --init <data-root> <database-name> [page-size]
```

The page size defaults to 4096 and must be one of 4096, 8192, 16384 or 32768.
The command creates a new UUID-named database directory, closes it cleanly and
prints the exact physical path. It never opens or rewrites an existing database.

## Local password bootstrap

```text
minisqld.exe --set-admin-password <database-path>
minisqld.exe --set-user-password <database-path> <user>
```

Passwords are collected twice from an attached Windows console with echo
disabled. The application passes mutable UTF-8 bytes directly to the catalog
password material API and wipes the caller buffer after use. Passwords do not
appear in argv or SQL text.

## Operational server lifetime

```text
minisqld.exe --serve <database-path> <port> [max-clients]
minisqld.exe --serve-authenticated <database-path> <port> [max-clients]
```

These modes use a request budget of zero. In the server contract, zero means
unlimited and disables the global scheduler idle exit. Individual sessions
retain their existing handshake and idle timeouts. The process remains available
until terminated by the operator or until a fatal database/network error occurs.

Positive request budgets remain supported by the compatibility modes and cause
a deterministic exit after the exact number of handled protocol requests.

## Stateful client

```text
minisql.exe --shell <port>
minisql.exe --script <port> <file>
```

Both modes open one client connection, perform one HELLO handshake, execute all
commands on that same session and close it exactly once. Consequently explicit
transactions, savepoints and prepared statements persist between commands.

The first script grammar is intentionally deterministic:

- UTF-8 text, at most 1 MiB;
- one complete SQL statement per line;
- blank lines ignored;
- lines whose trimmed form begins with `#` or `--` ignored.

The shell accepts one complete SQL statement per line and the local commands
`\help`, `\ping`, `\q` and `\quit`.

## Public application acceptance

Acceptance must compile the normal public application entry points and invoke
those resulting executables. Worker-only integration tests are not sufficient
for M32.
