# Security policy

## Supported version

Security fixes are currently applied to MiniSQL 1.0.x.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Use a private GitHub
security advisory for the repository so the report, reproducer, and proposed
fix can be reviewed confidentially.

Include, where possible:

- affected component and version;
- attack prerequisites and impact;
- minimal reproducer or database image;
- relevant server/client logs with secrets removed;
- whether a persistent or wire format is affected.

## Operational cautions

- Do not expose plaintext or trusted-local server modes to untrusted networks.
- Protect database directories, backup archives, audit keys, TLS private keys,
  and operator credentials using OS-level access controls.
- Never use `tests/fixtures/tls/server-key.pem` or its certificates outside the
  test suite.
- Review `docs/release/SECURITY_GUIDE.md` and `docs/release/LIMITATIONS.md` before
  deployment.
- Treat the Python TLS and replication sidecars as security-sensitive processes
  and run them with least privilege.
