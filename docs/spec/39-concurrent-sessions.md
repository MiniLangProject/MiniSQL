# Concurrent sessions and scheduling

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
and catalog mutations consequently remain writer-only. CNG RNG, PBKDF2,
SHA/HMAC and AES-GCM provider lifecycles share a narrow process-wide
synchronization gate because the native calls use compiler-managed argument
buffers and AES descriptors contain pointers to managed temporary buffers.

Each read scan owns its file handle and acquires a shared Win32 byte-range lock;
table and B+ tree writers retain their exclusive locks. Only UTF-16 path
marshalling is briefly serialized because the current compiler runtime supplies
process-wide scratch buffers for `wstr` extern arguments. Positioned reads on
independent handles remain parallel.

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

Acceptance must demonstrate executor overlap rather than infer concurrency from
multiple open sockets. The deterministic M27 gate starts two connection workers,
holds both at a shared start gate, executes 100 indexed reads per worker and
requires the observed peak number of simultaneously executing query sections to
be greater than one.
