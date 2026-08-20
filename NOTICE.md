# Notice

MiniSQL is implemented primarily in MiniLang. The TLS 1.3/X.509 terminator and
hot-replication controller are Python sidecars built only from Python's
standard library.

The certificates and private key under `tests/fixtures/tls/` are public
localhost test fixtures. They must not be reused in production.

MiniSQL 1.0 does not bundle third-party binary libraries. Operators are
responsible for protecting database files, backup archives, audit keys,
certificates, private keys, and host credentials.

MiniSQL is licensed under the Apache License, Version 2.0. Source files carry
the corresponding copyright and SPDX notices; the complete license text is in
`LICENSE`.
