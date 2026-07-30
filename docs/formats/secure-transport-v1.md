# Secure transport v1

A protected payload is 8-byte little-endian sequence, ciphertext of the same
length as the plaintext, and 16-byte GCM tag. The wire header retains protocol
v1 and sets `FLAG_SECURE`. The GCM associated data covers message type, protected
flags, request ID, sequence and plaintext length. This format is MiniSQL-specific
and not TLS.
