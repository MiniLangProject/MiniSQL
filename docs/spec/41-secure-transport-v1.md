# MiniSQL Secure Transport v1

The authentication response is the final plaintext frame. Both peers then
derive independent directional 32-byte keys from the password verifier,
challenge nonce, username and direction label. Every later wire payload is
encoded as `sequence:u64 || ciphertext || tag:16`. AES-256-GCM authenticates the
message type, flags, request ID, sequence and plaintext length as associated
data. Sequence numbers begin at zero and must be exact. Plaintext after
activation, repeated sequence numbers and invalid tags fail closed with 9030.

Remote binding is reachable only through the authenticated secure listener.
This protocol is not TLS: it has no certificate, X.509 validation, TLS record
layer or standard interoperability.
