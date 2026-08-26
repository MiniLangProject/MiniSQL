# ADR-0084: Native Windows x64 and Linux x64 targets

Status: Accepted

## Context

MiniSQL's persisted formats, SQL engine, wire protocol, authentication, and
scheduler are platform-independent, but the first implementation called Win32,
Winsock, CNG, Schannel, and console APIs directly. MiniLang 1.1 adds stable
Windows-x64 PE and Linux-x64 ELF targets plus portable standard-library file,
network, crypto, UUID, time, console, and TLS services.

## Decision

The shared MiniSQL modules import one platform facade. Conditional compilation
selects Win32 or Linux implementations only at that boundary:

- files use Win32 positioned I/O and byte-range locks or Linux `pread`/`pwrite`,
  `fsync`, and `flock`;
- sockets use Winsock or libc sockets with `fcntl`, `poll`, and `errno`;
- clocks, console input, UUIDs, and cryptography use the corresponding MiniLang
  standard-library service;
- TLS uses Schannel on Windows and OpenSSL 3 on Linux. Windows server identities
  are `store:` or `pfx:` references; Linux identities are
  `pem:<certificate>|<private-key>` references;
- the Win32 Workbench remains Windows-only. All five command-line applications
  build for both targets.

Every target uses the same database, page, WAL, catalog, backup, wire, secure
transport, and SQL semantics. Paths are normalized only at the platform facade;
durable identifiers and serialized bytes are unchanged.

## Consequences

`build.ps1 -Target windows-x64|linux-x64` is the supported cross-build entry
point. Linux outputs have no `.exe` suffix and require glibc plus OpenSSL 3.
The complete historical 106-phase suite remains the Windows release gate; the
Linux gate builds all CLI applications and exercises storage, loopback network,
authentication, parallel scheduling, cryptography, and the release contract.

Platform-specific GUI, raw ABI, and crash-injection tests are not compiled into
the Linux suite. New non-GUI engine behavior must remain source-identical and be
covered on both native targets.

## Verification status

The portable gate validates component behavior, a loopback session, and the
scheduler contract, but it does not establish sustained multi-client server
readiness. The 2026-08-26 Windows/WSL2 comparison found that one Linux client is
stable while repeated runs with two or more clients can close a connection or
stall after `recv` reports `EAGAIN`/`EWOULDBLOCK`. Consequently Linux remains a
supported build, offline-tool, and single-client evaluation target; Windows is
the accepted concurrent-server target until that native socket blocker is fixed.
