# ADR-0003: Conservative initial concurrency

Status: accepted in M0.

The first implementation permits concurrent readers and at most one writer per
database, with SERIALIZABLE as the default. This prioritizes observable correctness
and recovery. Finer-grained locking/MVCC follows only after the crash suite is stable.
