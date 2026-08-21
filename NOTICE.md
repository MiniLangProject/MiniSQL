# Notice

MiniSQL is implemented primarily in MiniLang. TLS 1.3 and X.509 processing use
the Windows Schannel and CryptoAPI system interfaces. The hot-replication
controller is a Python sidecar built only from Python's standard library.

Native TLS tests create an ephemeral localhost certificate and private key at
runtime; no reusable test identity is distributed with the source tree.

MiniSQL 1.0 does not bundle third-party binary libraries. Operators are
responsible for protecting database files, backup archives, audit keys,
certificates, private keys, and host credentials.

MiniSQL is licensed under the Apache License, Version 2.0. Source files carry
the corresponding copyright and SPDX notices; the complete license text is in
`LICENSE`.
