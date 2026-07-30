# ADR-0012: WAL record v1, logical segments and full-page images

Status: accepted for M6.

MiniSQL uses fixed 80-byte WAL headers, independent header/payload CRC-32C values and
transaction-private full-page images. Full images increase WAL volume but drastically reduce
recovery ambiguity in the first durable engine. The initial writer stores logical segments in
one physical file while exposing configured segment numbers and offsets, allowing physical
rotation later without changing record v1.
