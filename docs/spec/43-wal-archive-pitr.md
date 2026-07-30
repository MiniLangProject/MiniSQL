# WAL archive, PITR and standby

An archive contains a verified base backup, `archive.manifest`, and one or more
complete-prefix WAL generations. A new generation must extend the exact previous
prefix and match the database identity. PITR accepts an exact WAL record-boundary
LSN from the base boundary through the newest archive boundary. Restore writes
the selected prefix, resets checkpoint redo start to zero, performs recovery in
a temporary destination and publishes only after identity validation.

A standby is built under a staging path, receives a durable CRC-protected
`standby.state`, and is only then atomically published at its requested path.
Normal open refuses it with 9033. Refresh requires archive/database identity and WAL
prefix continuity, resets redo start and recovers the new prefix. Promotion
validates and recovers the standby, records an audit event, writes a promotion
marker and removes `standby.state`.

The mechanism is offline log shipping. It does not provide hot query serving,
continuous socket streaming or timestamp targeting.
