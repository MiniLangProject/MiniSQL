# Offline page-size migration — M26

The legacy two-argument migration command remains fail-closed: a same-size
request is a no-op and an in-place page-size change is rejected.

A real migration requires distinct source and target paths:

```powershell
minisql-migrate.exe --rewrite <source-path> <target-root> <target-name> 8192
```

Supported target page sizes are 4096, 8192, 16384, and 32768 bytes.

The source is opened exclusively and recovered. MiniSQL creates a fresh target
database with a new database UUID and the requested frozen page size, copies the
logical catalog and schema history, rewrites all live rows and LOB chains,
preserves object/principal IDs and DCL state, rebuilds every index, closes the
target, and runs the consistency checker. Only then is the generated directory
atomically renamed to its generated `db_<uuid>` target path inside the requested target root.

The source is never modified. Existing targets are never overwritten. On
failure, a complete or partial generated directory remains under its unique
internal name for diagnosis; it is never published as the requested target.
Statistics are intentionally invalidated and may be regenerated with ANALYZE.
