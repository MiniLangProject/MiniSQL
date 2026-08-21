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
- Use system-trusted server certificates for normal deployments. Certificate
  pinning is intended for deliberately self-signed installations; distribute
  the expected SHA-256 leaf-certificate pin through an authenticated channel.
- Review `docs/release/SECURITY_GUIDE.md` and `docs/release/LIMITATIONS.md` before
  deployment.
- Treat the native TLS credential configuration, its certificate stores or PFX
  files, and the Python replication controller as security-sensitive assets.
