# Test-only TLS material

These files are **only** for the M47 automated acceptance test. The certificate
is signed by a private test CA whose key is deliberately not distributed. Never
use this certificate or private key in a real deployment. Generate a dedicated
private key and X.509 certificate for every MiniSQL installation.
