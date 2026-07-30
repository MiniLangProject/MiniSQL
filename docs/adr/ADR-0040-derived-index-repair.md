# ADR-0040: Heap/WAL are authoritative; indexes are repairable derivatives

**Status:** candidate design for M23.

A durable dirty marker brackets every committed heap change that requires index
maintenance. Index publication failure cannot undo an acknowledged heap commit;
instead MiniSQL keeps the marker and rebuilds from the heap before later index
use. This provides deterministic crash repair without a cross-file atomic commit
protocol in M23.
