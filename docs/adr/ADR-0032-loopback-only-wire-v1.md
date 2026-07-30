# ADR-0032: Loopback-only wire protocol v1

Before DCL, authentication and TLS, bind only to IPv4 loopback. Use bounded, length-prefixed, checksummed binary frames rather than newline-delimited SQL.
