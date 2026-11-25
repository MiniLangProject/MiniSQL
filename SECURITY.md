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
- Review stored procedures with `SQL SECURITY DEFINER` as programs that execute
  with the definer's authority. Grant callers `EXECUTE` only for intended entry
  points, use `SQL SECURITY INVOKER` when callers must retain ordinary body
  permissions, and parameterize dynamic SQL values. Procedure grants and definer
  identities use durable IDs so dropping and recreating a name cannot adopt its
  predecessor's authority. See `docs/sql/stored-procedures.md`.

## Routine source and definer privileges

Procedure execution does not grant access to its SQL source. EXECUTE,
ALTER ROUTINE and CREATE ROUTINE allow scoped metadata inspection; definition
columns remain NULL unless the effective user is the durable definer, an
administrator, or holds SHOW_ROUTINE/database SELECT. Prefer SHOW_ROUTINE when
an inspection role needs definitions without general table access.

Definer-context calls require EXECUTE for both caller and definer. Creating a
procedure requires CREATE ROUTINE; migrate author roles that previously relied
on generic CREATE. Grant SET_ANY_DEFINER only to trusted authors who may select
other ordinary users' security contexts. This privilege does not allow selecting
a superuser without administration. Review `GRANT ALL ON DATABASE` accordingly.
