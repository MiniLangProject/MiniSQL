# Native TLS 1.3 and X.509 transport

MiniSQL terminates TLS inside the MiniLang process through the Windows Schannel
SSPI. No Python process, plaintext loopback hop, or TLS proxy is involved.

## Security profile

The current profile is intentionally narrow and fail-closed:

- protocol: TLS 1.3 only;
- cipher suite: `TLS_AES_256_GCM_SHA384` (`0x1302`);
- record protection: AES-256-GCM;
- TLS HKDF/transcript hash: SHA-384;
- ephemeral key exchange: X25519 (`0x001D`);
- peer identity: X.509 server certificate plus DNS-name validation;
- optional client policy: exact SHA-256 pin of the leaf certificate DER.

Schannel implements the TLS state machine, HKDF key schedule, X25519 operation,
CertificateVerify verification, traffic-key updates, AES-GCM record protection,
and authenticated `close_notify`. MiniSQL does not reimplement cryptographic
primitives. It constrains Schannel through crypto-agile credentials and then
parses the plaintext ServerHello and queries Schannel's negotiated connection
metadata before any database frame is accepted. A version, suite, or group
outside the policy aborts the connection.

## Certificate validation

The default client mode delegates chain construction, Windows root-store trust,
validity, EKU, signature, and hostname checks to Schannel.

Pin mode is intended for private and self-signed deployments. MiniSQL performs
Windows SSL chain-policy validation for the requested DNS name and ignores only
the unknown-root result. It then compares the SHA-256 digest of the complete
leaf certificate DER with the configured pin in constant time. Expired,
not-yet-valid, wrong-host, wrong-EKU, malformed, or differently pinned
certificates are still rejected. The pin is checked before any MiniSQL
authentication or SQL bytes are sent.

A `store:<thumbprint>` server reference uses a SHA-1 certificate-store
thumbprint only as a local lookup key; it is not a cryptographic trust decision.
A `pfx:<path>` reference imports the certificate and private key. Its password
is read from `MINISQL_TLS_PFX_PASSWORD` and is never accepted as a command-line
argument.

## Extensibility

`minisql.platform.tls_policy` contains typed registries for cipher suites,
named groups, hashes, AEAD properties, protocol versions, and certificate
policies. The active policy contains explicit allow-lists. A future release can
add an algorithm descriptor and corresponding provider restrictions without
changing connection framing or certificate code. Adding a registry entry never
changes the current default policy implicitly.

## Operations

The server exposes `--serve-tls` and `--serve-tls-config`. Clients expose
`--tls-*` for Windows trust and `--tls-pin-*` for exact leaf pins. Native TLS
can wrap MiniSQL's password-derived authenticated transport, providing defense
in depth and retaining the existing user authentication protocol.

TLS 1.3 through Schannel requires Windows 11 or Windows Server 2022 or newer.
A platform or machine policy that disables the required cipher or X25519 causes
startup or handshake failure; MiniSQL never falls back to TLS 1.2 or another
algorithm.

