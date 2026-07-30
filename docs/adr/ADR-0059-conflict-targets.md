# ADR-0059: Conflict targets bind to persisted constraints

Status: accepted for M40 candidate.

Conflict inference is limited to exact ordered PRIMARY KEY/UNIQUE constraint
column lists. This is deterministic and avoids silently selecting a different
unique rule. Unique indexes not represented as constraints are not inferred in
this milestone.
