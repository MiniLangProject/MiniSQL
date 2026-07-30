# ADR-0009: Synchronous Win32 positioned I/O

Status: accepted for M3.

The first storage layer uses one synchronous Windows handle and implements positioned
operations with `SetFilePointerEx` followed by `ReadFile` or `WriteFile`. This keeps the
MiniLang/Win32 boundary small and testable. A handle is therefore single-threaded by
contract. Durability is explicit through `FlushFileBuffers`; whole-file exclusion uses
`LockFileEx`. Overlapped I/O may be added later without changing higher storage APIs.
