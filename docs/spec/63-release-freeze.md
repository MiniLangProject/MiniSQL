# M50 – MiniSQL 1.0 release freeze

M50 freezes the first public compatibility target:

* product version `1.0.0`;
* database format version 1;
* wire protocol version 1;
* supported page sizes 4096, 8192, 16384 and 32768 bytes;
* Windows x64 native applications;
* native Windows Schannel TLS 1.3/X.509 and a Python 3 sidecar for continuous
  hot replication.

The deterministic release builder packages five native applications,
configuration schemas, operational documentation and the replication sidecar. Every
member is covered by SHA-256 checksums and a machine-readable release manifest.

M50 does not imply that every ISO SQL feature exists. The supported SQL dialect
and known limits are normative parts of the release documentation.
