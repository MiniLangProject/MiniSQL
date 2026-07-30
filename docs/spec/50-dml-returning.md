# DML RETURNING

## Scope

MiniSQL MUST accept `RETURNING <select-item-list>` after INSERT, UPDATE and
DELETE. `RETURNING *` expands in physical table-column order.

## Semantics

- INSERT MUST evaluate RETURNING against each inserted row.
- UPDATE MUST evaluate RETURNING against each final updated row.
- DELETE MUST evaluate RETURNING before deleting each matching row.
- Rows skipped by ON CONFLICT DO NOTHING or an UPSERT WHERE condition MUST NOT
  appear.
- Output expressions use normal scalar SQL semantics and MAY use aliases.
- Aggregate expressions MUST be rejected.
- RETURNING MUST NOT imply commit; explicit transaction rollback remains valid.
