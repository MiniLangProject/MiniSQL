# ADR-0051: Public operational CLI and unlimited daemon lifecycle

## Status

Accepted for the M32 candidate.

## Context

The engine, protocol and test workers were functional, but a user could not
create a database, bootstrap the administrator safely, or keep SQL transaction
state across repeated public client invocations. The public multi-session server
also had a finite default request budget and a global idle timeout intended for
tests.

## Decision

1. Add database initialization and password bootstrap to `minisqld.exe`.
2. Add stateful shell and script modes to `minisql.exe`.
3. Define request budget zero as unlimited in both single-session and concurrent
   listener loops.
4. Disable only the global daemon idle deadline in unlimited mode; retain
   per-session authentication and idle timeouts.
5. Retain positive request budgets for bounded deterministic test runs.
6. Test the actual public executables, not only dedicated worker programs.

## Consequences

The public applications now support a complete local workflow without changing
any persistent or wire format. The script grammar is one statement per line for
now; richer multiline parsing can be added later without changing the protocol.
Graceful console-control shutdown and Windows service integration remain future
work.
