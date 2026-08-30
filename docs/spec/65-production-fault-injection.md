# Production fault injection and endurance qualification

MiniSQL qualifies failure behavior with isolated, reproducible scenarios rather
than destructive experiments on an operator's data volume. The production fault
drill creates a new database below an explicitly empty work root and never
modifies an existing database.

The native storage failpoint is process-local and programmatic. It is not exposed
through configuration, SQL, environment variables, or the network protocol.
Tests assign an all-or-nothing byte budget to the platform file layer: writes
inside the budget complete normally, while the first larger write returns I/O
error 9005 before reaching the operating system. This safely models an `ENOSPC`
write failure without filling the workstation's real disk or manufacturing a
torn write. Tests then clear the failpoint, reopen the database, verify that the
failed transaction is absent, and prove that new durable writes remain possible.

The process-crash scenario runs concurrent autocommit writers and records every
commit acknowledged before forcibly terminating the server. After restart, the
recovered row count must cover every acknowledged commit, a new write must
succeed, and the offline checker must accept the database. The native M7 matrix
separately repeats committed and uncommitted low-level crash boundaries.

Network fault injection disconnects peers at varying incomplete frame offsets.
Periodic and final valid PING exchanges prove that malformed or abandoned
sessions do not terminate the listener or prevent later clients from connecting.

WAL corruption is injected only into a stopped database clone. The drill parses
complete record boundaries, changes a non-tail record covered by CRC32C, and
requires the offline checker to fail closed with a corruption diagnostic. Tail
truncation remains a distinct recoverable crash case; middle-record corruption
must never be silently discarded.

The generic endurance runner repeatedly launches a caller-provided workload
against an already running server. It records latency percentiles, peak RSS,
handles/file descriptors and threads, compares early and late medians, detects a
disappearing server process, and writes JSON evidence. A short run validates the
harness only. Production release qualification uses at least 24 hours; important
deployments should additionally run a 72-hour candidate soak on the target OS,
filesystem, antivirus configuration and storage hardware.

Neither the deterministic failpoint nor a short drill proves how a particular
filesystem behaves when its whole volume is exhausted. That final deployment
test belongs on a disposable, quota-limited volume or container whose exhaustion
cannot affect the host operating system.
