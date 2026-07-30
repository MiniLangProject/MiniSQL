# M49 – Fuzzing, crash matrix, soak and performance hardening

M49 is a release-quality gate rather than a new SQL feature.

The gate includes:

* deterministic SQL parser corpus processing;
* single-bit corruption of complete wire frames and WAL records;
* repeated committed and uncommitted crash/recovery cases;
* a persistent workload with DDL, AUTO_INCREMENT, DECIMAL, DML, aggregation,
  ANALYZE, restart and consistency validation;
* repeated soak executions with machine-readable duration reports;
* heap/GC instrumentation sanity checks;
* explicit safety ceilings instead of machine-specific benchmark promises.

Every fuzz input must end in either a normal value or a documented MiniSQL error.
An unhandled runtime error, process crash or timeout fails M49.
