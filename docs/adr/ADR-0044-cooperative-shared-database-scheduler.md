# ADR-0044: shared-database server scheduling

Status: amended on 2026-08-20 after MiniLang gained a process-wide managed heap,
native threads, synchronization objects and managed thread pools.

The original decision used one cooperative loop to multiplex bounded
nonblocking client slots. That constraint avoided unsafe cross-thread managed
heap access in the old runtime.

The server now opens each database once and runs one long-lived connection job
per active client on a bounded native thread pool. The acceptor applies the
configured maximum-client limit and the pool queue provides backpressure.
Connection buffers and session state have one worker owner. Small protocol
control messages, socket I/O, ordinary framing and SQL parsing can progress in
parallel.

The database catalog, WAL writer, audit stream and logical lock graph remain
shared state. A writer-prioritized readers/writer gate owned by
`ManagedDatabase` permits genuinely parallel read-only plans, while all catalog,
WAL, audit and maintenance mutations are exclusive. Sequence-consuming SELECT
and conservative session-state operations also take the writer path. The lock
graph has its own mutex, so simultaneous reader registration cannot corrupt its
wait edges. Sessions retain independent transaction, prepared-statement and
principal state, and lock conflicts are retried by the owning connection worker
with the existing timeout/deadlock semantics.

Read paths must not lazily mutate shared state. Schema history and the sort-temp
directory are therefore initialized while opening the database, index repair is
performed while attaching under the writer gate, and spill-name allocation is
synchronized. A read that observes the durable dirty-index marker explicitly
escalates to the writer gate for repair before running its plan. Read scans lease
persistent database-owned table and index handles. Their explicit-offset reads
remain independent; Windows index probes additionally lease separate reusable
completion events, while Linux uses stateless `pread`. The compiler's
process-wide UTF-16 extern scratch buffers require a very short synchronization
region around path-bearing Win32
calls; the actual positioned reads are not inside that region.

All Windows CNG sequences (RNG, PBKDF2, SHA/HMAC and AES-GCM) share MiniLang's
recursive process monitor. AES authentication descriptors contain pointers into
managed temporary buffers, and the compiler currently also uses shared native
argument storage for external string/pointer marshalling. Keeping the complete
provider lifecycles in this narrow gate prevents authentication and secure-frame
workers from corrupting one another; socket polling and SQL parsing remain
concurrent.

The acceptance contract measures real same-database executor overlap with two
workers and 200 indexed reads in total. A test that merely establishes multiple
connections is insufficient. The complete 106-phase suite, including concurrent
plain and authenticated network integrations, passed after this amendment.
