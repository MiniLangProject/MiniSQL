# TDE and hardened-authentication evaluation — 2026-09-02

## Scope

This evaluation compares the same native MiniSQL workload with plaintext paged
storage and with AES-256-GCM TDE. Each case creates one primary-key table,
commits 500 rows containing a 48-byte text value in one transaction, then runs
500 indexed point reads. The executable is
`tests/performance/tde_overhead.ml`. Three independent database pairs were
measured after one untimed compiler/build pass.

Correctness was checked separately by `m79_security_at_rest.ml`: offline
migration, ciphertext inspection, WAL reopen/recovery, KEK rotation after the
old key was retired, encrypted backup/restore, and wrong-key rejection. The
M21/M28 suites cover scheme-2 proofs, server proof, fake-user behavior, secret
wiping and the inability to replay a stored credential as a legacy verifier.

## Test system

- Windows 11 Pro x64, version 10.0.26200
- AMD Ryzen 9 9900X, 12 cores / 24 logical processors
- 64,604,972 KiB visible physical memory (61.6 GiB)
- MiniLang Python compiler 1.2.0; Python 3.11.9
- MiniSQL base revision `53573cd` plus the uncommitted change set under test
- 4096-byte database pages; native Windows x64 executables

## Results

| Metric | Plain median | TDE median | Delta |
|---|---:|---:|---:|
| 500 inserts | 8,813 ms | 9,359 ms | +6.2% |
| Insert throughput | 56.73 rows/s | 53.42 rows/s | -5.8% |
| 500 indexed reads | 297 ms | 360 ms | +21.2% |
| Indexed-read throughput | 1,683.5 queries/s | 1,388.9 queries/s | -17.5% |
| Table file | 65,536 bytes | 65,928 bytes | +0.60% |
| WAL file | 58,624 bytes | 59,072 bytes | +0.76% |
| Peak working set | 95.42 MiB | 99.88 MiB | +4.46 MiB |
| Peak private memory | 146.96 MiB | 147.03 MiB | +0.07 MiB |

Raw write/read milliseconds were `9750/344`, `8813/250`, `8000/297` for
plaintext and `9188/375`, `9359/281`, `9484/360` for TDE. Every run produced
the same checksum (`7650`) and physical sizes. Medians are reported rather than
selecting the best result because short durability-heavy runs show measurable
scheduler and storage-cache noise.

Peak memory was sampled every 10 ms in two additional single-mode processes so
the plaintext process could not retain allocations for the encrypted case.
Those samples completed the same workload and checksum but are not included in
the timing medians. TDE increased the observed peak working set by 4.46 MiB,
while peak private memory was effectively unchanged (+0.07 MiB). The encrypted
implementation adds one page-sized ciphertext buffer plus a 28-byte record
envelope while a page is encoded/decoded; it does not retain a second
database-sized copy. The existing bounded-memory acceptance and large-capacity
suites remain the memory gate and are run by the cumulative test entry point.

## Interpretation

The measured cost is consistent with one CSPRNG nonce and one AES-GCM operation
per durable page/WAL record. Space amplification is small because the fixed
28-byte page envelope is amortized over 4096-byte pages and WAL headers. The
write path remains dominated by SQL execution and durability barriers. Read
overhead is visible in this small hot-cache point-lookup test; larger rows and
storage-bound scans should amortize it better and must be measured separately
before changing the default encryption policy.
