# ADR-0066: Deliver TLS 1.3 through an X.509-verifying sidecar

Status: accepted for the M47 candidate.

Embedding Schannel or OpenSSL directly through MiniLang's current interop layer
would add substantial unaudited marshaling and certificate code. M47 instead
uses a small Python-standard-library TLS terminator, restricts every plaintext
leg to loopback, pins TLS 1.3, and requires normal CA/hostname verification. The
MiniSQL framing protocol is unchanged.
