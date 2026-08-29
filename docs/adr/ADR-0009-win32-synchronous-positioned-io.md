# ADR-0009: Synchronous Win32 positioned I/O

Status: superseded by explicit-offset `OVERLAPPED` reads on 2026-08-29.

The first storage layer uses one synchronous Windows handle and implements positioned
operations with `SetFilePointerEx` followed by `ReadFile` or `WriteFile`. This keeps the
MiniLang/Win32 boundary small and testable. A handle is therefore single-threaded by
contract. Durability is explicit through `FlushFileBuffers`; whole-file exclusion uses
`LockFileEx`. Overlapped I/O may be added later without changing higher storage APIs.

The later implementation made that planned change: immutable read handles now
use `ReadFile` with a unique operation-local `OVERLAPPED` record, while a
database pool lends one completion event to each active index-query lease.
Manual-reset events are reset before reuse. Writable cursor operations retain
their original serialized contract, and durability still uses explicit
`FlushFileBuffers`.
