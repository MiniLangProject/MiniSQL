# ADR-0086: Envelope TDE and non-password-equivalent authentication

## Status

Accepted.

## Decision

MiniSQL uses a random per-database DEK wrapped by an external provider-supplied
KEK. Paged files store plaintext redundant superblocks followed by fixed
`nonce || ciphertext || tag` records. AAD binds database, file and page
identity. WAL payloads and temporary spill rows use domain-separated record
encryption. Encrypted backup exports protect each captured file independently
and rewrap the TDE envelope for the backup key.

The provider and wrapping algorithm are tagged in `encryption.meta`. Version 1
uses a raw 32-byte file provider and AES-256-GCM. Rotation atomically rewraps
the DEK without rewriting pages.

New password records store SCRAM-style StoredKey and ServerKey values. The wire
challenge declares its scheme; legacy verifier records remain compatible until
password reset.

## Consequences

Each page costs 28 physical bytes and each encrypted WAL/spill record adds a
nonce, tag and AEAD operation. Superblocks, paths, sizes and selected sidecar
metadata remain observable, so OS volume encryption is still recommended.
Losing every copy of an external key is unrecoverable.
