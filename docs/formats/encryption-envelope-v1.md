# Encryption envelope and records v1

`encryption.meta` starts with `MSTDE001`, a version, provider ID, wrapping
algorithm ID, database UUID, 96-bit nonce, a 32-byte DEK plus 128-bit GCM tag,
the provider identifier and CRC-32C. The CRC detects storage damage before key
access; AES-GCM authenticates the key envelope. Reserved bytes are zero.

Paged files retain two plaintext 4096-byte superblocks. Feature bit 0 changes
the physical page stride from `pageSize` to `pageSize + 28`; each record is a
12-byte random nonce followed by page-size ciphertext and a 16-byte tag. AAD is
domain-separated and includes database ID, file ID and page number.

Encrypted WAL payloads place the ASCII marker `TDE1WAL1` in the formerly
reserved final U64 header field and contain nonce, ciphertext and tag. Caller
record flags remain untouched. Headers and CRC-32C remain parseable for
truncation recovery, while GCM authenticates the logical identity and payload.
Legacy plaintext records, including records whose application flags use bit 0,
may coexist with encrypted records during upgrade. Spill headers expose
shape/count metadata; every row record is independently encrypted when TDE is
active.

Encrypted backup file records start with `MSBAKENC`, followed by nonce,
ciphertext and tag. The relative backup path is AAD. The ordinary manifest
covers the encrypted length and CRC, and GCM provides authenticity and
confidentiality. Restore accepts the same provider key bytes from a different
machine-local identifier and rewraps `encryption.meta` to that new identifier
before the restored database is published.
