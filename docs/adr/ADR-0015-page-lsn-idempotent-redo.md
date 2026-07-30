# ADR-0015: Full-page redo guarded by pageLSN

Status: accepted for M7.

Recovery redoes only committed full page images. A page image is applied only when its WAL LSN
is newer than the page's persisted pageLSN. Repeating recovery therefore produces the same
state. Full images trade WAL volume for a smaller and more auditable first recovery algorithm.
