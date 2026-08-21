# ADR-0066: Terminate TLS 1.3 natively through Windows Schannel

Status: Accepted, revised by the native TLS M73 implementation.

## Context

The original release used a Python TLS terminator and a plaintext loopback hop.
That design added another runtime, process-lifecycle coupling, duplicated
listener limits, and left TLS outside the MiniLang server.

Writing a TLS state machine or cryptographic primitives inside MiniSQL would be
unsafe and difficult to validate. Windows already provides a maintained TLS 1.3
implementation, X.509 chain engine, key isolation, and AEAD record API through
Schannel.

## Decision

MiniSQL uses Schannel through SSPI inside `minisqld.exe` and `minisql.exe`.
It uses crypto-agile `SCH_CREDENTIALS`, permits TLS 1.3 only, disables the NIST
ECDHE groups for this profile, and fails unless ServerHello selects X25519 and
`TLS_AES_256_GCM_SHA384`. Schannel's cipher report is cross-checked against
the wire selection.

The normal client uses automatic Windows X.509 and hostname validation. Pin mode
uses manual validation: Windows SSL policy checks the certificate and DNS name
while ignoring only an unknown root, then MiniSQL constant-time compares the
leaf DER SHA-256 digest. This permits an explicitly pinned self-signed
certificate without disabling identity, lifetime, EKU, or signature checks.

The Python TLS proxy and its static private-key fixtures are removed from source,
acceptance tests, and release archives.

## Consequences

TLS keys remain owned by Schannel and are not exposed as MiniLang byte arrays.
MiniSQL handles fragmented/coalesced encrypted records, TLS 1.3 post-handshake
tickets and KeyUpdate notifications, and authenticated shutdown.

The implementation is Windows-specific. Windows 11 or Windows Server 2022 is
the minimum native TLS platform. Machine crypto policy may make the required
profile unavailable, in which case MiniSQL fails closed.

New algorithms are added through typed policy registries and explicit
allow-lists. They require new negotiation tests and never broaden an existing
policy automatically.
