# ADR-0058: Materialize INSERT SELECT before mutation

Status: accepted for M39 candidate.

MiniSQL materializes the complete SELECT output before target writes. The
memory cost is accepted for this milestone because it gives deterministic
self-insert and statement-atomic behavior. Streaming/spill is deferred to M46.
