# Wire protocol and loopback service (M18)

Each frame has a fixed 32-byte little-endian header, protocol magic/version, message type, flags, request ID, bounded payload length, payload CRC-32C and header CRC-32C. Payloads are limited to 1 MiB. The initial message set is HELLO, QUERY, PING, CLOSE, RESPONSE, PONG and ERROR. Exactly one SQL statement is accepted per QUERY. Result rows are bounded batches of UTF-8 strings. Until DCL and authenticated encryption exist, the listener binds only to `127.0.0.1`. Connections are blocking and one-session-per-listener in M18.

## Fragmentation requirement (M48-M50R1 clarification)

TCP packet boundaries are never protocol boundaries. A 32-byte MiniSQL header
and its payload may each arrive in one or many positive-length fragments.
Blocking reads must accumulate exactly the requested count, validate every
native return value, and must not apply operations such as `len` to an optional
or unchecked byte-range result. Acceptance routes public client traffic through
a TLS relay that deliberately forwards small fragments.

## Direct-offset and cooperative receive contract (M48-M50R2 clarification)

A synchronous WinSock transfer receives a pointer into a live MiniLang `bytes`
object plus a validated offset and count. The pointer is never retained after
`send` or `recv` returns. Blocking exact reads fill one final buffer in place.

A cooperative non-blocking connection owns one reusable 64-KiB scratch buffer.
Only the prefix reported by `recv` is appended to the bounded frame buffer.
Header, frame, and secure-payload ranges are copied into exact-size buffers with
`copyBytes`; the framing path does not consume optional `slice` results and does
not use overloaded `+` for byte accumulation.

The accumulated receive buffer may never exceed one maximum frame plus the
fixed receive scratch window:

```text
HEADER_BYTES + MAX_PAYLOAD_BYTES + POLL_RECEIVE_BYTES
```

A peer close with a partial frame is a protocol error. A peer close with an empty
buffer is a clean connection close.

### R2 bounded pipelining window

The cooperative connection reader reserves one fixed receive scratch buffer and
allows the persistent receive buffer to hold at most one maximum-sized frame
plus one scratch window. This permits a single TCP receive to complete one
frame and already carry the beginning of the next frame, while retaining a
strict per-connection memory bound.


## Signed WinSock result contract (M48-M50R3 clarification)

WinSock functions returning C `int` are declared with the signed MiniLang ABI
type `i32`. This is mandatory for `send` and `recv`: positive values are byte
counts, zero is an orderly receive close, and `SOCKET_ERROR` is signed `-1`.

The implementation also recognizes the zero-extended bit pattern `4294967295`
as an error sentinel. This defensive fallback does not redefine the ABI; it
prevents an older compiler from converting a native error into a framing count.

Acceptance creates a real loopback socket pair, forces a non-blocking receive
with no data available, and requires it to yield the would-block state before
checking direct-offset transfer and blocking exact-read behavior.
