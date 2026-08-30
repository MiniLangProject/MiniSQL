# Production controls, observability and HA qualification

MiniSQL applies one absolute monotonic deadline to each admitted statement.
Parsing, physical readers/writer-gate admission, executor operators, page scans,
DML row loops, lock waits, and streaming result production share the same
cooperative token. Administrative cancellation uses a distinct protocol message
on a second privileged connection. The engine never terminates a native worker
asynchronously because doing so could strand a lock or partially staged page.
Nested-loop candidates, hash build/probe loops, spill workers, and serial or
parallel streaming aggregates poll that token at bounded batch boundaries.
Authentication uses a shared catalog gate, allowing an authenticated control
connection to be established while the target reader remains active.

Server result rows and complete encoded wire bytes have independent limits.
Blocking operators keep their per-query soft memory threshold, while spill
reservations additionally consume one synchronized database-wide temporary
storage quota. New work is rejected and active work is cooperatively aborted
when the live managed heap reaches the configured process ceiling.
Operating-system RSS enforcement remains a deployment responsibility.

Every completed statement contributes elapsed time and encoded result bytes to
`SHOW STATUS`. Cancellation, deadline, resource rejection, maximum latency and
slow-query counts are separate counters. Reaching `slowQueryMs` emits a warning
without copying SQL literals into the ordinary log. The loopback monitoring
bridge translates the same stable status rows into Prometheus text and reports
scrape health.

HA qualification includes both explicit and automatic paths. The production
drill performs concurrent primary writes, durable-prefix export, materialized
standby reads under concurrency, explicit promotion, a post-promotion write and
an offline integrity check. The fencing drill leaves the old primary reachable,
proves that its direct writes fail as 9038, promotes a new term, switches a
stable endpoint, and rejoins the retired copy as read-only. The controller live
test kills a managed leader and verifies automatic promotion. Recovery also
advances the transaction allocator past every replayed WAL transaction.

The native write boundary validates a persistent database epoch and a shared
expiring lease before mutations and immediately before durable DML/DDL commit.
This is split-brain protection for the controller-owned single-host topology,
not a distributed consensus or synchronous quorum protocol.
