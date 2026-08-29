# Concurrent sessions and scheduling

This document defines the cross-platform concurrency contract. Windows x64
satisfies it through the complete 106-phase release gate. Linux x64 uses the
same database scheduler and locking design and satisfies the focused portable
gate, including repeated multi-client network operation. The Linux gate remains
smaller than the Windows release matrix, but concurrent Linux-server readiness
is no longer blocked.

A server process owns one `ManagedDatabase` and creates one logical SQL session
per connection. The acceptor submits each connection to a bounded native
MiniLang thread pool with at most `maximumClients` workers and queued jobs. One
worker exclusively owns a connection and its session until disconnect, idle
expiry or server shutdown. Slow and fragmented clients therefore do not block
acceptance or framing work for unrelated clients.

SQL parsing is session-local and concurrent. Execution then enters a
writer-prioritized readers/writer gate owned by the `ManagedDatabase`.
Read-only SELECT, EXPLAIN and metadata statements share the reader side, so
their plans can execute simultaneously against the same database. DML, DDL,
DCL, sequence-consuming SELECT, maintenance and session-state statements use
the exclusive writer side. Once a writer owns the turnstile, new readers wait;
this prevents a continuous read workload from starving mutations.

Schema-history and temporary-sort directories are initialized before the
database is published to workers. Normal read plans do not rebuild indexes; a
durable dirty marker causes the read to leave its shared gate, enter the writer
gate, repair indexes and only then execute. External-sort spill identifiers are
synchronized. The WAL cursor, audit stream
and catalog mutations consequently remain writer-only. Native RNG, PBKDF2,
SHA/HMAC and AES-GCM provider lifecycles share a narrow process-wide
synchronization gate because the native calls use compiler-managed argument
buffers and AES descriptors contain pointers to managed temporary buffers.

The managed database owns one persistent read-only handle per opened table or
B+ tree generation. Concurrent scans share that immutable handle and issue
explicit-offset reads: Windows uses an overlapped `ReadFile` operation with a
unique completion record, while Linux uses `pread`. These operations neither
observe nor change a shared file cursor. The database writer gate prevents a
handle from being invalidated or closed while readers hold leases; writers keep
their conventional serialized handles and exclusive native file locks. Only
UTF-16 path marshalling is briefly serialized on Windows because the compiler
runtime supplies process-wide scratch buffers for `wstr` extern arguments.

The independently mutex-protected lock manager supports multiple logical readers
and one writer. Wait edges are recorded as waiter-to-blocker relationships;
insertion that closes a cycle fails with error 9031 and selects the requester as
victim. Error 9007 is retried by the owning worker until the bounded wait expires,
after which error 9032 is returned and the transaction is rolled back. READ
COMMITTED read leases end with the statement; SERIALIZABLE leases end with the
transaction. Closing or losing a connection releases all locks and
prepared/session state.

A positive global request budget is reserved atomically before dispatch and is
counted only after a response is sent. Zero remains unlimited. First fatal
server errors and shutdown state are published under a server-state mutex.

Acceptance must demonstrate storage and executor overlap rather than infer
concurrency from multiple open sockets. The deterministic M27 gate starts two
connection workers, holds both at a shared start gate, executes 100 indexed
reads per worker, and requires both the executor peak and the persistent-handle
lease peak to be greater than one. M3 additionally drives one Windows handle
from eight threads at distinct offsets and checks every returned byte.

The portable Linux gate exercises the scheduler scenario, a loopback session,
and two successive waves of four simultaneous native clients. It requires exact
request draining after both waves, which covers parallel dispatch, worker
completion, and reuse of the bounded thread pool. The original transport failure
and its pthread-based resolution remain documented as historical evidence in
`tests/performance/WINDOWS_LINUX_COMPARISON_2026-08-26.md`.
