# Maintenance journal v1

The M25 maintenance journal is a CRC-32C protected envelope stored at:

```text
catalog/maintenance.pending
```

The envelope uses:

```text
magic:          MSMAINT1 (8 bytes)
format version: 1
kind:           42
flags:          0
```

Its little-endian payload is:

```text
u32 status       1 PREPARED | 2 COMMITTED
u32 reserved     must be zero
string original  u32 byte length + UTF-8 bytes
string temporary u32 byte length + UTF-8 bytes
string backup    u32 byte length + UTF-8 bytes
```

The three paths are non-empty engine-generated database-internal paths. They are
never accepted directly from SQL. Unknown versions or statuses, non-zero
reserved fields, malformed lengths, trailing bytes, and checksum failures are
rejected.

The PREPARED generation is flushed before the first destructive rename. The
COMMITTED generation is flushed after the replacement is durable and the WAL
redo horizon has been reset. Recovery restores the backup for PREPARED and
keeps the replacement for COMMITTED. Cleanup removes temporary/backup files and
then the journal.
