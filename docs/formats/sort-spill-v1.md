# External sort spill v1

Temporary M46 sort runs use magic `MSSPILL1` and version 1. The fixed 16-byte
header contains the magic, version, projected-value count, order-value count,
and a reserved zero field. Each row is encoded with the existing row codec and
prefixed by a 32-bit length. The expected row count is retained in the
in-memory `SpillRun` descriptor and checked after decoding; it is not stored in
the file header.

Run files are temporary, limited to 256 MiB each, structurally validated before
use, and never included in database backup or recovery state. Spill v1 does not
add a separate per-run checksum; corruption detectable by the header, lengths,
row codec, shape checks, or expected row count is rejected.
