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
| 2, when present | `__minisql_routine_context_v1__` |
| 3 onward | Alternating attribute-name/value strings |

The canonical SQL includes typed parameter directions, characteristics, and the
complete body. The principal ID is authoritative for definer execution; a
same-named replacement account must not inherit the old identity. Legacy
body-only procedure records, including typed parameter metadata, remain readable
and retain invoker security semantics. Replacing a definition writes the new
representation. The sidecar envelope version remains `1` because the framing
does not change; old executors cannot execute the new tagged program records.

## Routine execution context suffix

The optional context suffix retains the existing view-record framing and V2
identity prefix. Keys must be unique, and only these keys are accepted:

| Attribute | Representation and lifetime |
|---|---|
| `created` | Decimal UTC Unix epoch microseconds captured from the real clock at first creation. |
| `last_altered` | Decimal UTC Unix epoch microseconds captured at successful CREATE/ALTER/OR REPLACE. |
| `sql_mode` | Validated SQL mode captured by CREATE or ALTER; the empty string is a valid mode. |
| `character_set_client` | Supported client character set in effect at CREATE/OR REPLACE. |
| `collation_connection` | Supported connection collation in effect at CREATE/OR REPLACE. |
| `database_collation` | Supported database default collation in effect at CREATE/OR REPLACE. |

The executor restores captured execution context around CALL. ALTER preserves
known creation time and original character settings while updating modification
time and SQL mode. OR REPLACE preserves the existing object's identity and any
known original creation time, and captures the new definition's context.

Legacy records without the suffix remain readable. Their unknown timestamps
and context attributes are not reconstructed from unrelated catalog generations
or the current clock: INFORMATION_SCHEMA and SHOW report SQL NULL. ALTER of a
legacy record records its modification time and SQL mode, while retaining NULL
for unavailable original history. At execution, missing context uses the
explicit legacy fallback supplied by the executor.

An unknown suffix marker, unsupported or duplicate key, odd number of key/value
strings, or malformed timestamp is a corruption error. Timestamps use the same
epoch-microsecond representation as the TIMESTAMP SQL type; SHOW formats them
as UTC calendar timestamps with six fractional digits. The current platform
clock has millisecond resolution, so its final three stored fractional digits
are zero.

Existing V2 readers can decode the string-array framing but do not enforce this
execution-context contract. Downgrading after creating context-bearing routines
is unsupported, even if an older binary happens to accept the record. Security
snapshots containing the new privileges also require the updated decoder.

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
