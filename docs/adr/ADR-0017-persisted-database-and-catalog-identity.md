# ADR-0017: Persisted format identity outranks global defaults

Status: accepted for M8.

Global database settings are creation defaults only. Existing databases use persisted db.meta
and self-describing file headers. Database UUID, file type, object ID and page size are checked
when opening every managed object. Format changes require explicit offline migration rather
than editing configuration.
