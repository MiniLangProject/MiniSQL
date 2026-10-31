# MiniLang 1.3 and inline-assembly evaluation (31 October 2026)

This report separates three questions that are easy to conflate:

1. whether the updated compiler and standard library make unchanged MiniSQL
   workloads faster;
2. whether new inline-assembly primitives outperform the equivalent MiniLang
   loops in isolation; and
3. whether those primitives improve complete SQL requests without increasing
   memory use or changing database semantics.

The retained implementation is deliberately hybrid. It keeps short FNV-1a
inputs in MiniLang, moves byte hashing of 16 bytes or more to inline assembly,
and uses an inline-assembly scanner for B+ tree key comparison. An attempted
four-byte integer hash was removed because it was slower.

## Revisions and test system

- MiniSQL baseline: `eaa034526d0dffce9a7e57821e023e4f7c7ab683`
- previous compiler/std comparison point: MiniLang 1.2.26,
  `37646ab0897602efa459a2eccea1115dba249495`
- updated self-hosted compiler/std: MiniLang 1.3.0 plus one commit,
  `dee8ff794cf66787a3b420622697b3b41cee56fb`
- updated Python compiler: MiniLang 1.3.0 plus one commit,
  `83f25c0f81578fede961a4c50569122ab4068b5d`
- CPU: AMD Ryzen 9 9900X, 12 cores / 24 logical processors
- memory: 64,604,972 KiB visible (61.61 GiB)
- OS: Windows 11 Pro x64, version 10.0.26300, build 26300
- Linux check: WSL, using the same host and the compiler's `linux-x64` target

All old/new SQL comparisons used separately built server executables against
the same retained database. Each reported SQL median pools two fresh-server
runs. Memory values are peak Windows private bytes, not working set. The host
showed occasional large scheduler outliers, so the 10% trimmed mean is retained
beside the median and changes below roughly 5% are treated as inconclusive.

## Updated compiler and standard library

First, unchanged MiniSQL source was compiled with MiniLang 1.2.26 and the new
1.3 compiler/std. Eighteen measurements per query produced:

| Query | 1.2.26 median | 1.3 median | Change | 1.2.26 trimmed | 1.3 trimmed |
| --- | ---: | ---: | ---: | ---: | ---: |
| integer sort | 220.937 ms | 216.250 ms | **-2.1%** | 222.679 ms | 215.060 ms |
| integer group | 218.264 ms | 224.099 ms | +2.7% | 221.286 ms | 224.490 ms |
| integer join | 493.312 ms | 512.056 ms | +3.8% | 496.439 ms | 521.300 ms |

The old server peaked at 165.04/165.05 MiB. The two updated runs sampled
148.75 and 165.04 MiB; the lower value missed the early allocation peak, so the
defensible conclusion is **no sustained MiniSQL memory change**. The query
timings are within host variance. MiniLang 1.3 therefore does not provide an
automatic, general SQL speedup for these operator-heavy requests.

That result does not invalidate the updated standard library. Its dedicated
paired measurements show large wins in code paths that this SQL fixture does
not dominate, including Base64 decoding (500-547 to 265-282 ms), repeated-byte
RLE (766-828 to 47-62 ms), repeated-block LZ4 (297-375 to 187-250 ms), stack
bulk copies (437-469 to 46-78 ms), quoting (531-578 to 46-63 ms), and TLS pin
comparison (250-282 to 46-47 ms). The full standard-library matrix lives in
the compiler repository's `docs/reports/STDLIB_PERFORMANCE_2026-10-31.md`.

## Inline-assembly candidates

MiniSQL contained three copies of the same byte-wise 31-bit FNV-1a loop in
statistics, grouping, and hash joins, plus a byte-wise lexicographic B+ tree
comparison. The candidate benchmark keeps total processed data broadly similar
across sizes and places the first difference at the final byte for comparison.
Each cell below is the median of three process runs.

### FNV-1a byte hashing

| Bytes | Iterations | MiniLang | ASM | Relative result |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 5,000,000 | 31 ms | 125 ms | ASM 4.03x slower |
| 4 | 5,000,000 | 78 ms | 140 ms | ASM 1.79x slower |
| 8 | 5,000,000 | 141 ms | 156 ms | ASM 1.11x slower |
| 16 | 3,000,000 | 172 ms | 110 ms | **1.56x faster** |
| 32 | 2,000,000 | 203 ms | 93 ms | **2.18x faster** |
| 64 | 1,000,000 | 203 ms | 79 ms | **2.57x faster** |
| 128 | 500,000 | 187 ms | 63 ms | **2.97x faster** |
| 256 | 300,000 | 218 ms | 78 ms | **2.79x faster** |
| 512 | 200,000 | 296 ms | 94 ms | **3.15x faster** |
| 4,096 | 50,000 | 672 ms | 203 ms | **3.31x faster** |

The retained 16-byte crossover follows the measured call/setup cost instead of
assuming that assembly is always faster.

### Unsigned lexicographic comparison

| Bytes | Iterations | MiniLang | ASM | Relative result |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 5,000,000 | 63 ms | 125 ms | ASM 1.98x slower |
| 4 | 5,000,000 | 141 ms | 125 ms | **1.13x faster** |
| 8 | 5,000,000 | 297 ms | 141 ms | **2.11x faster** |
| 16 | 3,000,000 | 328 ms | 109 ms | **3.01x faster** |
| 32 | 2,000,000 | 422 ms | 94 ms | **4.49x faster** |
| 64 | 1,000,000 | 406 ms | 78 ms | **5.21x faster** |
| 128 | 500,000 | 406 ms | 63 ms | **6.44x faster** |
| 256 | 300,000 | 641 ms | 109 ms | **5.88x faster** |
| 512 | 200,000 | 953 ms | 109 ms | **8.74x faster** |
| 3,584 | 50,000 | 1,421 ms | 125 ms | **11.37x faster** |

Empty B+ tree entries are not published, and even four-byte keys break even in
this test, so the scanner is retained for the complete key-comparison path.
Length ordering remains in MiniLang after the bounded common prefix.

### Rejected integer hash

An inline-assembly implementation of the existing four-byte integer FNV mix
took 94-109 ms for five million hashes, while the MiniLang expression took
47-63 ms. It was removed. This negative result is important: integer ALU code
already lowers efficiently, and an ASM boundary can cost more than it saves.

## End-to-end SQL effect

The final server was compared with a new-compiler server built immediately
before the MiniSQL ASM changes. The integer fixture has 3,000 rows and exercises
sort, group, join, and indexed storage. It does not directly benefit from the
long-byte FNV path, but still exercises B+ tree comparison.

| Integer query | Before median | Final median | Change | Before trimmed | Final trimmed |
| --- | ---: | ---: | ---: | ---: | ---: |
| sort | 250.469 ms | 257.087 ms | +2.6% | 281.336 ms | 259.984 ms |
| group | 235.148 ms | 244.112 ms | +3.8% | 241.087 ms | 245.458 ms |
| join | 618.923 ms | 544.439 ms | **-12.0%** | 657.496 ms | 563.970 ms |

Peak private memory remained exactly bounded at 165.04-165.05 MiB before and
after. Sort and group are inconclusive because median and trimmed behavior do
not establish a consistent regression. The join improved in both statistics,
but this host's outliers mean it should be confirmed by a larger dedicated
join run before being advertised as a general 12% gain.

The long-text fixture uses 3,000 rows with approximately 189-byte group/index
keys. Eighteen measurements per query produced:

| Text query | Before median | Final median | Change | Before trimmed | Final trimmed | Interpretation |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| group | 345.103 ms | 293.542 ms | **-14.9%** | 341.195 ms | 310.150 ms | retained win |
| join | 806.726 ms | 840.562 ms | +4.2% | 816.923 ms | 844.578 ms | within the 5% noise band |

The text-group result demonstrates that long-key hashing can affect a complete
SQL request. The join is dominated by other work and does not demonstrate a
measurable gain. One-operation indexed lookup samples were intentionally
discarded because connection and scheduler noise dwarfed the key comparison;
the dedicated comparison benchmark is the defensible measurement for that
primitive.

MiniDoc's duplication ratchet subsequently led to centralizing the three
identical short-key fallbacks in one inline adaptive helper. A fresh two-process,
18-sample run against that exact final source measured **295.240 ms** group
median and **297.658 ms** trimmed mean, respectively **14.4%** and **12.8%**
faster than the same pre-ASM reference. Its join measured **757.030 ms** median
and **756.294 ms** trimmed mean, 6.2-7.4% faster in that later window. Because
the earlier balanced run put the join 3.4-4.2% in the other direction, the
honest conclusion remains that long-text grouping is the repeatable SQL win
while the complete join effect is unresolved host variance.

## Safety and verification

The assembly reads are marked `unsafe`, but both loops establish their bounds
in MiniLang and re-check the index against the rooted byte-array length passed
to assembly. The comparison uses unsigned byte loads and resolves equal-prefix
lengths outside assembly. Hash output remains masked to the existing 31-bit
contract.

Validation completed against the final source:

- repository/static contract validation: 4/4 phases;
- complete native acceptance run: 106/106 phases immediately before the
  behavior-preserving adaptive-helper deduplication;
- native Windows M2 byte/CRC/envelope tests;
- native Windows M11 B+ tree tests;
- native Windows M16 relational execution tests;
- native Windows M17 statistics/optimizer tests;
- M2 compiled and run with both current Python and self-hosted compilers;
- M2 compiled by the self-hosted compiler for Linux x64 and run successfully
  under WSL.

All three compiler/target variants produced the same successful assertions and
observable output. The final Windows binaries were not byte-identical: the
self-hosted monolithic and object-pipeline builds were identical at 651,264
bytes with SHA-256
`E578997B9EAEB6FE44E52CB205154B32B9516BC287A88033B6949F0CFFF33CB6`,
while the Python compiler produced 685,568 bytes (+5.3%) with SHA-256
`C1915B686D89A9AC6FAE173526A08D692B3F0224021ADA37019F4BF804B8CBC1`.
This is a compiler code-generation/binary-parity difference, not a demonstrated
MiniSQL semantic difference; it should be tracked separately if reproducible
binary parity across compiler implementations remains a release requirement.

The retained change is therefore a targeted primitive optimization, not a
claim that inline assembly should replace ordinary MiniLang code generally.
