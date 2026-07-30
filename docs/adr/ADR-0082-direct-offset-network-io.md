# ADR-0082: Direct-offset WinSock I/O and explicit protocol buffering

Status: Accepted for the M48-M50R2 candidate.

## Context

MiniLang's `slice(bytes, offset, length)` is optional and returns `void` for an
invalid or unmaterializable range. The initial 1.0 candidate consumed such a
result in blocking network I/O. R1 replaced those calls with temporary copied
ranges, but a concurrent regression then failed without enough diagnostics and
the non-blocking protocol path still used optional slices.

Network framing must tolerate arbitrary TCP segmentation without depending on
heap-allocation timing, packet boundaries, or silent optional results.

## Decision

1. Declare WinSock `send`/`recv` buffers as native pointers.
2. Obtain each pointer with `nativeBytesPtr` from a validated `bytes` value.
3. Add the validated byte offset numerically and use the pointer only for the
   immediately following synchronous native call.
4. Keep the owning `bytes` value referenced for the complete call and never
   retain the pointer afterward.
5. Fill blocking exact-read outputs directly in place.
6. Give each protocol connection a reusable 64-KiB receive scratch buffer.
7. Split/append protocol buffers with exact-size `bytes` allocations and
   `copyBytes`, not unchecked `slice` or overloaded concatenation.
8. Bound accumulated bytes by one maximum frame plus one receive-scratch
   window, permitting a read to include the next frame prefix.
9. Preserve all client and server diagnostics for concurrent process failures.

## Consequences

- Partial reads and writes no longer require one temporary heap object per
  transfer attempt.
- The cooperative multi-session server no longer depends on optional slices in
  its framing hot path.
- A connection uses an additional 64 KiB scratch buffer, bounded by the existing
  maximum-client configuration.
- No on-disk or wire-format byte changes occur.
- The implementation relies only on documented MiniLang interop: a `bytes`
  payload pointer can be passed to a native `ptr` parameter, and the owner stays
  live while the synchronous call executes.
