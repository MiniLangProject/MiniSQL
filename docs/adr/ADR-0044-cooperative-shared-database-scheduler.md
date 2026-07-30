# ADR-0044: cooperative shared-database scheduler

Decision: one process opens each served database once and multiplexes bounded
nonblocking client slots in a cooperative loop. Sessions share a database lock
manager but retain independent transaction, prepared-statement and principal
state. This avoids unsynchronized MiniLang heap access from OS threads while
still allowing multiple live clients and deterministic reader/writer waits.
