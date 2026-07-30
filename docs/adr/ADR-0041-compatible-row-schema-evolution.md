# ADR-0041: Metadata-only ADD COLUMN uses compatible row decoding

**Status:** candidate design for M24.

Rows retain their stored schema version and encoded column count. A current
schema may decode an older prefix when types match, then materialize missing
trailing columns from persisted defaults. This makes safe ADD COLUMN operations
instant and avoids rewriting table data. Destructive shape/type changes require
an offline rewrite.
