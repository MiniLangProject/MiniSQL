# 15. Random-access file and locking layer

## 15.1 Scope

M3 provides the only platform file API used by higher MiniSQL storage modules.
Windows delegates to Win32 handles and positioned `OVERLAPPED` I/O. Linux
delegates to MiniLang `std.io.file`, whose positioned operations use
`pread`/`pwrite`; durability and locks map to `fsync` and `flock`.

The implementation is synchronous. Positioned operations do not mutate a shared
logical cursor and may be issued by independent reader handles concurrently.

## 15.2 Exact I/O

`readAt` may return fewer bytes at end of file. `readExactAt` MUST fail on a short read.
`writeAt` MUST fail on a short write. Buffer and file ranges are validated before I/O.
Offsets are non-negative native MiniLang integers; a future wider-offset layer may use
explicit U64 words.

`truncate` changes the physical end of file. `append` obtains the current size and then
writes at that offset; it is not a multi-writer atomic append primitive.

## 15.3 Durability

A successful MiniSQL durable boundary requires an explicit `flush`, which maps to
`FlushFileBuffers` on Windows and `fsync` on Linux. Closing a handle is not
substituted for this protocol step. The
write-through creation mode is an additional safeguard, not a replacement for flush.

## 15.4 Locks

M3 uses a native whole-file shared or exclusive lock. A non-blocking contender MUST
receive MiniSQL error code 9007. The server will later combine this primitive with its
own lock-file and process ownership protocol.

## Ownership rule

Writable paged files own an exclusive lock for the complete handle lifetime;
read-only scans use compatible shared locks. This prevents two MiniSQL server
processes from modifying the same physical file concurrently on either target.
