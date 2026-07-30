# 15. Random-access file and locking layer

## 15.1 Scope

M3 provides the only direct Win32 file API used by higher MiniSQL storage modules. It
wraps `CreateFileW`, `SetFilePointerEx`, `ReadFile`, `WriteFile`, `GetFileSizeEx`,
`SetEndOfFile`, `FlushFileBuffers`, `LockFileEx`, `UnlockFileEx` and `CloseHandle`.

The initial implementation is synchronous. A `FileHandle` MUST NOT be used concurrently
because positioned operations consist of a seek followed by a read or write on one
shared OS file pointer.

## 15.2 Exact I/O

`readAt` may return fewer bytes at end of file. `readExactAt` MUST fail on a short read.
`writeAt` MUST fail on a short write. Buffer and file ranges are validated before I/O.
Offsets are non-negative native MiniLang integers; a future wider-offset layer may use
explicit U64 words.

`truncate` changes the physical end of file. `append` obtains the current size and then
writes at that offset; it is not a multi-writer atomic append primitive.

## 15.3 Durability

A successful MiniSQL durable boundary requires an explicit `flush`, which maps to
`FlushFileBuffers`. Closing a handle is not substituted for this protocol step. The
write-through creation mode is an additional safeguard, not a replacement for flush.

## 15.4 Locks

M3 uses an advisory whole-file exclusive byte-range lock. A non-blocking contender MUST
receive MiniSQL error code 9007. The server will later combine this primitive with its
own lock-file and process ownership protocol.

## Ownership rule

Every opened paged file owns an exclusive byte-range lock for the complete handle lifetime. This prevents two MiniSQL server processes from modifying the same physical file concurrently.
