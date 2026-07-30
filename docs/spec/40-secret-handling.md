# Secret handling

Interactive password input uses the Windows console API with echo disabled.
Passwords enter the client as mutable UTF-8 `bytes`, are never required in a
command-line argument, and are wiped after derivation. Password verifier, proof,
nonce and directional transport-key buffers are wiped on every success and
failure path. Unknown users use deterministic fake salt and verifier material
bound to the database ID. Externally observable authentication failures use the
same error 9027. Authentication retries have bounded delay, the handshake has a
30-second limit, and an idle session has a five-minute limit.
