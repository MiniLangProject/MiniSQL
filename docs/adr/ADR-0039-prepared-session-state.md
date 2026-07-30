# ADR-0039: Prepared statements retain ASTs per session

**Status:** candidate design for M22.

MiniSQL stores prepared statement ASTs in the session `Engine`, with positional
parameter count and observed schema generation. EXECUTE substitutes constant AST
arguments and invokes the normal binder, authorizer, planner, and executor.

This avoids SQL-text injection and stale plans while keeping the first
implementation small. Physical plan caching is deferred until dependency-based
invalidation is available.
