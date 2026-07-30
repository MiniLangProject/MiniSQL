# TLS 1.3 and X.509 sidecar

M47 adds a standards-compatible transport around the unchanged MiniSQL wire
protocol through `tools/tls/minisql_tls_proxy.py`.

Server mode terminates TLS 1.3 and forwards plaintext only to a host that
resolves exclusively to loopback. Client mode exposes a plaintext listener only
on loopback and establishes TLS 1.3 to the remote endpoint with mandatory CA and
hostname verification. Protocol downgrade, untrusted certificates, and hostname
mismatches MUST be rejected.

This milestone uses Python's standard `ssl` module and the platform OpenSSL
runtime. It is a deployable sidecar/terminator, not an embedded MiniLang TLS
stack. Production deployments MUST supply their own private key and certificate
chain; files under `tests/fixtures/tls` are test-only.

M47 authenticates the server certificate; it does not require a client X.509
certificate and therefore does not provide mutual TLS. MiniSQL user
authentication remains a separate protocol concern.
