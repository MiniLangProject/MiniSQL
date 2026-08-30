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

HA qualification is intentionally evidence-driven rather than automatic. The
drill performs concurrent primary writes, durable-prefix export, materialized
standby reads under concurrency, explicit promotion, a post-promotion write and
an offline integrity check. Recovery also advances the transaction allocator
past every replayed WAL transaction. Consensus, fencing and split-brain
prevention remain external operational requirements.
