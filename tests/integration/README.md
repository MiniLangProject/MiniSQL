# Integration tests

The cumulative native runner compiles the complete module graph and exercises
storage, SQL, server/client, transaction, TLS, replication, and release paths.

After the HA drill has created and promoted its deterministic `ha_load`
database, the production-control live gate validates real protocol cancellation,
a one-millisecond deadline, aggregate result-byte rejection, slow-query log
persistence, status counters, Python PING/PONG, and a live Prometheus scrape:

```powershell
python .\tests\integration\production_controls_live.py `
  --database .\build\ha-drill\standby `
  --work-root .\build\production-controls-live
```

The native M77 test independently covers token, quota, heap admission, status,
and cancel-frame contracts without requiring a listener.
