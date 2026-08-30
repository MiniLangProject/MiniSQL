# Automatic HA and native write fencing

MiniSQL's single-host HA controller combines asynchronous durable-WAL shipping,
an offline double-buffer standby, an expiring leader lease, and one loopback TCP
endpoint. The controller owns every managed server process. It never promotes a
standby until the previous lease expiry plus the configured maximum clock skew.

Each leadership term has a strictly increasing positive epoch and a positive
node identifier. Before a server starts, the controller atomically writes that
identity into `leader.epoch` inside the offline database. The process receives
the same immutable identity through `--serve-fenced`. Startup fails closed if
the persistent record, command line, and current shared lease do not agree.

The executor validates write authority after authorization and before acquiring
logical mutation locks. DML and DDL validate it again immediately before their
durable commit. Missing files, partial replacements, unsupported versions,
CRC-32C damage, identity mismatch, clock failure, and expiry all return error
9038. SELECT, metadata inspection, and rollback do not require write authority,
so operators can inspect or unwind a fenced session.

Lease renewal runs on a dedicated controller thread and therefore continues
while WAL export or standby materialization performs long filesystem I/O. The
stable proxy chooses a backend only when accepting a connection. Existing
connections remain attached to their selected backend and observe native fence
errors after retirement; clients reconnect to reach the promoted leader.

The file witness assumes one writer and atomic replacement on shared storage.
It is not Raft, Paxos, quorum replication, or a storage fencing token. A
multi-host deployment must replace the witness authority with a consensus-backed
lease and must prevent a server that cannot observe that authority from writing
to authoritative shared storage. Replication remains asynchronous and an
acknowledged transaction newer than the last exported durable prefix can be lost
when the leader host is destroyed.
