# ADR-0057: RETURNING uses normal QueryResult rows

Status: accepted for M38 candidate.

RETURNING is represented by bound scalar expressions and emitted as the normal
row-result shape. This keeps protocol and client formatting unchanged and lets
explicit transactions return staged rows without committing them.
