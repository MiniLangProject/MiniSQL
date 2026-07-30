# Audit log v1

Files: `audit/audit.key`, `audit.anchor`, `audit.log`, optional
`audit.previous`. Magic `MSAUD001`, version 1, fixed header 120 bytes, maximum
detail 4096 bytes. Records are sequenced and HMAC-SHA-256 chained. The anchor is
32 bytes and is the previous hash for the current segment.

Sequence numbers start at 1 within each segment and increase by exactly one. A
full-segment verifier requires the first record to be sequence 1. An append
verifier may validate a suffix only when supplied with the exact predecessor
sequence and predecessor hash. This distinction does not change the v1 byte
layout.
