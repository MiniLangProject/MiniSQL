# ADR-0061: M42 TRUNCATE is logical and transactional

Status: accepted for M42 candidate.

TRUNCATE reuses staged row deletion and normal WAL publication rather than
introducing a new cross-file generation protocol. This is slower than a
constant-time file swap but preserves the established crash/rollback model.
Physical fast TRUNCATE may be added after persistent sequences and generation
reclamation are available.
