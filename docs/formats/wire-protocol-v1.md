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

## Response payload

The fixed response prefix is 24 bytes. All integers are little endian. A string
field is a U32 UTF-8 byte length followed by exactly that many bytes.

| Offset | Size | Field |
|---:|---:|---|
| 0 | 2 | status: command `1`, rows `2`, error `3` |
| 2 | 2 | reserved, zero |
| 4 | 4 | column count |
| 8 | 4 | row count |
| 12 | 4 | affected-row count |
| 16 | 4 | numeric error code; zero on success |
| 20 | 4 | metadata trailer byte length; zero for unextended responses |

The prefix is followed by the command string, message string, one string per
column name, and row-major cell strings. Optional negotiated metadata follows
the last cell. Legacy responses have no trailer and retain a zero at offset 20.
Legacy SQL NULL cells use the text token `NULL`, which is indistinguishable from
a text value containing those four characters.

## Negotiated structured results (`results-v2`)

This extension retains protocol version 1 and the existing message types. A
client requests it with the exact HELLO payload
`MiniSQL/1; capabilities=results-v2`. A supporting server includes
`; capabilities=results-v2` in its HELLO acknowledgement. Only after that
acknowledgement may the client set bit `0x00000008` (`FLAG_METADATA`) on query
requests. Each extended response repeats that bit and includes the trailer
described below. The bit is independent of authentication, continuation, and
result-start flags; CRC-32C covers the complete extended payload as usual.

The server rejects use of the metadata request flag before negotiation. An old
HELLO payload does not opt in, and an older server that does not advertise the
capability receives ordinary query flags. Unextended response encoding remains
byte-for-byte compatible. The connection's negotiated capability does not
force trailers onto requests without the flag, including authentication and
administrative control exchanges.

### Metadata trailer layout

The U32 value at response offset 20 is the complete trailer length. The trailer
starts immediately after the last ordinary response field and ends exactly at
the end of the payload. Fields occur in this order:

| Field | Representation |
|---|---|
| Magic | four bytes, ASCII `MDV1` |
| SQLSTATE | string field containing exactly five uppercase ASCII letters or digits |
| Warning count | U32 |
| Warnings | repeated: SQLSTATE string, U32 numeric code, message string |
| NULL bitmap length | U32, exactly `ceil(rowCount * columnCount / 8)` |
| NULL bitmap | that many bytes, row-major cells, least-significant bit first |
| Column type count | U32, exactly equal to column count |
| Column types | one U16 native type kind per column |
| Output parameter count | U32 |
| Output parameters | repeated: U32 ordinal, name string, U16 type kind, U16 null flag, value string |

SQLSTATE is `00000` for successful responses; native and application errors carry
their mapped or explicitly raised state. Unclassified errors use `HY000`.
The original numeric error code remains at prefix offset 16. A warning entry
contains its own SQLSTATE, code, and message; the terminal command or error frame
contains retained nonfatal records from SQLSTATE classes `01` and `02`. The
retained diagnostic area is subject to the session's `max_error_count`;
`@@warning_count` and `@@error_count` expose the server's total condition and error
counts, not the trailer's filtered and retained list length.

A set NULL bit is authoritative even if the ordinary cell string differs. A
clear bit with the cell string `NULL` represents those literal text characters.
Padding bits in the final bitmap byte are unused. Decoders validate every field
length, the exact bitmap and type-count shapes, SQLSTATE syntax, type-kind range,
output null flags, and the absence of trailing bytes. Warning and output entry
counts are limited to 65,535; the full frame remains subject to the 16 MiB limit.

Native type kinds are:

| Kind | Type | Kind | Type |
|---:|---|---:|---|
| 0 | unknown | 9 | VARCHAR |
| 1 | BOOLEAN | 10 | TEXT |
| 2 | SMALLINT | 11 | BINARY |
| 3 | INTEGER | 12 | VARBINARY |
| 4 | BIGINT | 13 | BLOB |
| 5 | REAL | 14 | DATE |
| 6 | DOUBLE | 15 | TIME |
| 7 | DECIMAL | 16 | TIMESTAMP |
| 8 | CHAR | | |

Ordinary row type information is derived from available values and can be
unknown for empty results or all-NULL columns. It does not carry declared
precision, scale, length, or collation. In particular, generic DECIMAL result
rows retain their existing text representation without a scale descriptor.
Clients use catalog queries when they need declared routine parameter metadata.

The successful outer CALL's terminal command includes only OUT and INOUT
parameters. Ordinals are one-based positions among **all** declared parameters,
including IN parameters. An output null flag is either zero or one; a null
output uses an empty value string. Non-null output values use their declared
native kind. Integer output strings represent the complete signed integer,
including 64-bit values. Decimal output strings have their declared decimal
point and scale applied, for example internal `725` at scale 2 becomes `7.25`.
Binary outputs use the existing `0x` hexadecimal rendering; clients decode
native kinds 11–13 to bytes. Temporal output values retain MiniSQL's native
text representation and clients apply the corresponding temporal conversion.
Nested CALLs contribute their row results but do not publish separate output
snapshots. Failed calls do not publish successful output parameters.

### Streaming, output retrieval, and client storage

Simple SELECTs executed inside CALL stream through the same bounded batch
mechanism as direct SELECTs. A completed result's final batch still has
`FLAG_MORE` because another result or the terminal CALL status follows. A sink
or transport failure stops further routine execution and bypasses SQL condition
handlers. Blocking operators can still materialize their own result before
emitting batches. Server result limits apply across the entire CALL, not
independently to each SELECT.

Python `execute("CALL ...")` and JDBC `Statement.execute("CALL ...")` consume the
stream incrementally. Python `callproc()` and JDBC `CallableStatement` must reach
the terminal CALL frame before making output parameters available, so they
store intervening frames in private temporary spools. Python spills after one
MiB; JDBC writes frames to a temporary file with bounded IO buffers. Replay
retains only a bounded number of frames. JDBC `KEEP_CURRENT_RESULT` uses the same
disk-backed retention. Spools are removed on exhaustion or close. This bounds
client memory by buffered frames and parameter values; it does not bound the
disk space needed for a complete retained result or the memory used by blocking
SQL operators inside the server.

Negotiated clients use the terminal output snapshot without a subsequent SQL
SELECT or cleanup query, preserving the CALL's diagnostics. Older servers keep
the legacy session-variable output lookup. Binary input binding, complete
result-column metadata, and MySQL's native wire protocol are not provided by
this extension.

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
