# RIGHT and FULL OUTER JOIN specification

M37 completes the initial outer-join family:

```sql
RIGHT [OUTER] JOIN ... ON ...
FULL [OUTER] JOIN ... ON ...
```

RIGHT JOIN preserves every row of the right input and NULL-extends all columns
of the accumulated left input when no match exists. FULL OUTER JOIN preserves
unmatched rows from both sides.

The nested-loop executor records which right rows matched and emits their
unmatched complement after processing the left input. It handles empty inputs
and multi-join left widths. RIGHT/FULL execution deliberately bypasses the
current single-sided index shortcut because that shortcut cannot enumerate the
unmatched complement safely.

Logical plans, physical plans, cardinality estimates and EXPLAIN identify Right
Outer Join and Full Outer Join explicitly. Hash-join execution remains a later
performance optimization.
