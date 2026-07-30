# MiniSQL 1.0 backup and recovery

Use `minisql-backup.exe backup <db> <destination>` for a verified base backup and
`restore` for a checked restore into a new path. WAL archives support exact-LSN
PITR and `latest`. A restore is staged and validated before publication.

A successful backup is not sufficient evidence by itself. Keep at least one copy
on a different failure domain and perform periodic restore drills followed by
`minisql-check.exe`.
