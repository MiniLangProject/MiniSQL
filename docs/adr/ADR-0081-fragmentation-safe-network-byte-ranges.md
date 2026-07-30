# ADR-0081: Fragmentation-safe network byte ranges

## Status

Accepted for the M48-M50R1 candidate.

## Context

MiniSQL wire frames are length-prefixed, but TCP is a byte stream and can split
one header or payload across any number of reads. The original WinSock wrapper
used `slice(source, offset, count)` to construct every send and receive chunk,
then immediately used `len` on the result. MiniLang's `slice` returns `void` on
an invalid or unmaterializable range, so an unchecked result can become a raw
runtime `len(void)` failure instead of a structured network error.

The first M48-M50 acceptance run exposed this through the TLS 1.3 sidecar after
92 successful cumulative phases.

## Decision

1. Network byte ranges are materialized by `copyByteRange` using validated
   offsets, `bytes(count, 0)`, and `copyBytes`.
2. `sendAll`, `receive`, `receiveAvailable`, and `receiveExact` validate concrete
   byte values and native byte counts before use.
3. `receiveExact` remains a loop and must tolerate any positive fragment size.
4. The TLS sidecar exposes test-only bounded relay fragmentation. Defaults keep
   the production path equivalent to the former `sendall(data)` behavior.
5. Acceptance forces small fragments in both proxy directions.

## Consequences

- Protocol framing no longer depends on packet boundaries.
- A failed byte-range materialization returns a MiniSQL error rather than a raw
  runtime error.
- Partial send and receive paths receive direct deterministic coverage.
- There is a small copy cost only after a genuinely partial send or receive;
  a full range can reuse the original buffer.
- No persisted or wire format changes.
