# ADR-0037: Trusted local and authenticated server modes

**Status:** accepted for M21.

Existing embedded and maintenance callers retain a trusted local engine and `--serve-one` compatibility mode. New network deployments use `--serve-auth`, which starts unauthenticated, requires challenge-response login plus `CONNECT`, and then applies DCL authorization per statement. Both modes remain bound to `127.0.0.1` until TLS, secure credential entry, and remote hardening are implemented.
