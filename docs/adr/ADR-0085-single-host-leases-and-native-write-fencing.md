# ADR-0085 — Single-host leases and native write fencing

Decision: MiniSQL provides a file-witness HA reference controller and enforces
its leadership term inside the native SQL write path. A persistent per-database
epoch prevents an old command line from restarting a retired term. A shared,
expiring lease revokes a running process. Both fixed records are versioned,
length-checked, CRC-32C protected, and atomically replaced by the controller.

The server validates authority before mutations and again immediately before
durable DML or DDL commit. It fails closed as error 9038 while retaining reads
and rollback. Promotion waits for lease expiry plus bounded clock skew, then
advances the epoch and switches new connections through a stable proxy.

Rationale: process supervision alone cannot stop direct clients from reaching a
partitioned old primary. Native enforcement places revocation at the database
write boundary. A dedicated renewal thread prevents slow archive I/O from
causing accidental expiry.

Consequence: this solves split-brain prevention only under the documented
single-writer, atomic-file-witness assumption. It deliberately does not claim
distributed consensus, synchronous quorum durability, or storage-array fencing.
Those require an external authority that preserves the same monotonically
increasing term contract.
