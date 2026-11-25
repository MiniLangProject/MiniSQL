# MiniSQL wire protocol v1

Header size: 32 bytes, little endian.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 4 | ASCII `MSQL` |
| 4 | 2 | protocol version = 1 |
| 6 | 2 | message type |
| 8 | 4 | flags |
| 12 | 4 | request ID |
| 16 | 4 | payload length, defensive maximum 16,777,216 |
| 20 | 4 | payload CRC-32C |
| 24 | 4 | header CRC-32C with this field zeroed |
| 28 | 4 | reserved, zero |

Unknown versions/types, non-zero reserved fields, length mismatch and either
checksum mismatch are rejected. Plaintext trusted-local service remains
loopback-only. Production remote listeners use native TLS 1.3 as specified in
`docs/spec/59-native-tls13-x509.md`; the historical M29 authenticated framing
mode remains a distinct compatibility transport and is not represented as TLS.

Response bit `0x00000002` (`FLAG_MORE`) means another response frame with the
same request identifier follows. Every row frame repeats the column schema and
normally contains at most 512 rows and targets less than one MiB. One row that
cannot be split across frames may occupy a frame up to the 16 MiB defensive
transport maximum.
Clients validate request identifiers and schemas before appending a continuation.
The final frame clears `FLAG_MORE`. Bit `0x00000001` remains the authenticated
MiniSQL framing flag used beneath deployments that enable that transport.

Cursor-aware clients consume one continuation frame at a time. The legacy
convenience query API appends batches for compatibility and is therefore not a
bounded-memory API. Only one cursor may own a protocol-v1 connection because
responses are ordered and not multiplexed.

The successful `HELLO` command message includes the backward-compatible field
`session=<positive-u32>` after a semicolon. Clients use that server-assigned
identifier as the target of an administrative cancellation request. Older
clients may continue treating the complete message as informational text.

## Administrative cancellation extension

Message type `9` (`CANCEL`) carries exactly one little-endian U32 target session
identifier. It is sent on a separate connection because the target connection
may be blocked receiving its current result. Trusted-local administrators or an
authenticated principal with database `ADMIN` may issue it. A successful
response confirms only that the cooperative token was set; the target reports
error `9035` after its next execution poll. Type values `1`–`8` retain their
original meanings, so existing protocol-v1 framing and result decoders remain
compatible.

## Stored procedure result boundaries

Bit `0x00000004` (`FLAG_RESULT_START`) marks the first frame of a separate
result in a `CALL` response. It is independent of `FLAG_MORE`: a result can
span several batches, and the last result can consist of a single frame.
Every result's first frame repeats its column schema. Identical schemas do
not imply the same result set; clients must obey the boundary flag.

A procedure with two `SELECT` statements and a completion response can emit:

| Frame | Content | Flags |
|---|---|---:|
| 1 | First SELECT, rows 1–512 | `0x06` (result start + more) |
| 2 | First SELECT, remaining rows | `0x02` (more) |
| 3 | Second SELECT | `0x06` (result start + more) |
| 4 | Final CALL command and affected count | `0x04` (result start) |

Empty SELECT results still produce one result frame. Nested procedure SELECTs
appear in execution order, followed by the outer CALL completion. Server row
and byte limits apply across the complete response stream. Clients must drain
all remaining results when closing or replacing a query to keep the socket
aligned for the next request.

If a routine fails after completing SELECT statements, those results precede
the terminal error frame, which sets `FLAG_RESULT_START` and clears `FLAG_MORE`.
Clients finish reading the completed result and raise the error when advancing
with `nextset()` or `getMoreResults()`. A native lock error after such results
does not replay the CALL. A failure within an ordinary streamed SELECT keeps
the original immediate continuation-error behavior.

Ordinary single-result queries retain their existing flags and payload format.
The payload's response statuses remain command `1`, rows `2`, and error `3`.
Use updated clients for multi-result procedures; older clients assume every
continuation belongs to a single result and cannot represent CALL boundaries.
The MiniLang client's `STATUS_MULTIPLE = 4` is an in-memory aggregate only and
is never serialized as a new wire response status.

Application conditions raised with `SIGNAL`/`RESIGNAL` retain their requested
`MYSQL_ERRNO`, including values that coincide with internal MiniSQL error codes.
The server tracks the condition origin locally: application error `9007` is
returned once rather than retried as a logical lock conflict, and application
error `9031` does not trigger the listener's native deadlock rollback path.
This distinction does not change the numeric error carried on the wire.
