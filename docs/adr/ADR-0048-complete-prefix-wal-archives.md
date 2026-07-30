# ADR-0048: complete-prefix WAL archives

Decision: each archive generation stores a complete validated WAL prefix rather
than delta segments. This costs space but makes continuity, corruption checks
and exact-LSN restore straightforward. Standby refresh is offline and requires
prefix continuity; streaming replication is deferred.
