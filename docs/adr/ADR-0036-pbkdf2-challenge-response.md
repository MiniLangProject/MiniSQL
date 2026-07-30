# ADR-0036: PBKDF2 verifier challenge-response

**Status:** accepted for M21.

MiniSQL uses BCrypt PBKDF2-HMAC-SHA-256 with a random salt and 600,000 iterations. A fresh nonce and domain-separated client/server proofs avoid sending the password or verifier over the connection and provide mutual proof of verifier possession. Buffers containing password bytes, derived verifiers, and proofs are overwritten after use. This is a first local protocol; verifier theft remains password-equivalent and TLS is still required before remote deployment.

## Known M21 limitation

The dummy challenge for an unknown username is generated afresh, while a real account uses its persisted salt. Repeated challenges can therefore disclose whether an account exists. This is accepted only for the loopback-only M21 stage and must be replaced by a server-secret-derived indistinguishable challenge or a PAKE before remote exposure.
