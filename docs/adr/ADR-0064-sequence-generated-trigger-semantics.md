# ADR-0064: Conservative sequence, generated-column and trigger semantics

Status: accepted for the M45 candidate.

Sequence advancement is durable and is not rolled back. Generated columns are
stored and may reference only earlier columns. Triggers are AFTER/ROW only, have
one DML body, and use typed OLD/NEW substitution with a recursion limit. This
small semantic surface is preferred to partially implementing broader SQL
features with ambiguous crash or ordering behavior.
