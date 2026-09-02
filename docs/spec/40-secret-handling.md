# Secret handling

Interactive password input uses the Windows console API or POSIX `getpass`,
with echo disabled on both targets.
Passwords enter the client as mutable UTF-8 `bytes`, are never required in a
command-line argument, and are wiped after derivation. New accounts persist a
SCRAM-style StoredKey/ServerKey pair rather than the password-equivalent salted
PBKDF2 result. Password-derived secrets, proofs, nonces, session secrets and
directional transport keys are wiped on success and failure paths. Unknown
users use deterministic database-bound fake scheme-2 material. Observable
authentication failures use error 9027, retries have bounded delay, the
handshake has a 30-second limit, and idle sessions have a five-minute limit.
