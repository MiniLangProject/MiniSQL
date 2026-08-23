# MiniSQL 1.0 backup and recovery

Use `minisql-backup.exe backup <db> <destination>` for a verified base backup and
`restore` for a checked restore into a new path. WAL archives support exact-LSN
PITR and `latest`. A restore is staged and validated before publication.

A successful backup is not sufficient evidence by itself. Keep at least one copy
on a different failure domain and perform periodic restore drills followed by
`minisql-check.exe`.

Files ending in `.heap-pages` are derived physical scan directories. Verified
base backups do not depend on them, and restored databases recreate them lazily
from checksummed table pages. Never substitute a directory from another table
or an older physical table generation; deleting it while the database is stopped
is the safe repair action.

PITR and standby refresh replay authoritative table-page WAL after restoring a
base archive. MiniSQL marks the base archive's B+ tree files dirty and rebuilds
them before publishing any post-base generation. An exact base-boundary restore
keeps the already verified base indexes without an unnecessary rebuild.
