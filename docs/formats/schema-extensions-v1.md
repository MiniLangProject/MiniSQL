# Schema extensions v1

`catalog/schema.extensions` is a protected envelope with magic `MSEXT001`,
version 1 and kind 43. Its payload binds to the 16-byte database identity and
contains a generation followed by counts and records for views, sequences,
generated columns and triggers. Reserved fields and unknown flags MUST be zero.
The complete payload is atomically replaced and has no artificial 1 MiB
ceiling; its practical capacity is the native address space and available disk.

## Stored procedure records

Procedure definitions reuse a view-shaped extension record with the internal
name prefix `__minisql_procedure__`. This record is not a user-queryable view.
The record contains a U64 little-endian `viewId`, then the existing length-framed
name, SQL text, and string-array fields.

New full routine definitions store canonical `CREATE PROCEDURE` text in
`sqlText`. The `columnNames` array is a tagged metadata payload:

| Array position | Value |
|---:|---|
| 0 | `__minisql_routine_metadata_v2__` |
| 1 | Decimal text of the durable definer principal ID |

The canonical SQL includes typed parameter directions, characteristics, and the
complete body. The principal ID is authoritative for definer execution; a
same-named replacement account must not inherit the old identity. Legacy
body-only procedure records, including typed parameter metadata, remain readable
and retain invoker security semantics. Replacing a definition writes the new
representation. The sidecar envelope version remains `1` because the framing
does not change; old executors cannot execute the new tagged program records.

## Identifier lifetime

Procedure privilege records refer to `viewId`, so extension IDs must not be
reused after deletion. New allocation selects an ID above both the persisted
schema generation and every live extension ID. If an older object has a higher
ID, allocation first raises the generation high-water mark. The caller then
increments and persists the generation with the mutation. Every successful
drop also advances generation.

Consequently a drop/reopen/recreate cycle allocates a fresh ID even if the
dropped object was the only extension. Replacing or altering an existing object
preserves its ID. Dropped-procedure grants are removed from the independent
security snapshot; an interrupted cleanup can leave only inert grants, because
later definitions cannot reuse the old identifier. The generation field has its
existing encoding, so this safety property requires no new sidecar field.
