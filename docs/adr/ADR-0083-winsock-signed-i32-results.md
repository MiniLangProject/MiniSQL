# ADR-0083: WinSock signed 32-bit result ABI

Status: Accepted in MiniSQL 1.0.0.

## Context

The Windows WinSock APIs `send` and `recv` return C `int`, a signed 32-bit
value. Positive values are byte counts, zero denotes an orderly receive close,
and `SOCKET_ERROR` is `-1`.

MiniLang distinguishes the ABI types `int` and `i32`. Declaring a C 32-bit
return as MiniLang `int` is not equivalent on Windows x64. Native code returns a
C `int` through EAX. A 64-bit interpretation can observe the error bit pattern
as unsigned `0xFFFFFFFF`, causing the sentinel check to fail and an impossible
large byte count to enter framing code.

## Decision

All WinSock functions returning C `int` use `returns i32`. The `send` and `recv`
count/flag parameters also use `i32`.

Network code checks the primary signed sentinel and, defensively, the
zero-extended bit pattern:

```text
-1
4294967295
```

A direct loopback test forces a non-blocking would-block result and validates
both non-blocking and blocking receive paths.

## Consequences

- `WSAEWOULDBLOCK` is handled as an expected poll result rather than a corrupt
  byte count.
- blocking peers report the actual WinSock error instead of an impossible count.
- no wire or persistent format changes.
- the regression is detected before the multi-client integration phase.
