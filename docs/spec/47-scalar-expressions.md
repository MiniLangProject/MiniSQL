# Scalar expression specification

M35 extends the expression grammar and binder with:

```sql
CASE WHEN condition THEN value [WHEN ...] [ELSE value] END
CASE operand WHEN value THEN result [WHEN ...] [ELSE result] END
CAST(value AS type)
COALESCE(value, ...)
NULLIF(left, right)
```

## Type rules

CASE and COALESCE derive one common result type. Compatible numeric types are
promoted, text types converge to TEXT and binary types converge to BLOB.
Incompatible branches are rejected during binding. CASE without ELSE is
nullable.

NULLIF requires comparable operands and returns the first operand type with
nullable result semantics.

CAST is explicit and therefore broader than assignment conversion, while still
rejecting overflow, malformed numbers, lossy unsupported conversions and text
length violations. The initial implementation supports text/numeric/boolean
conversions and conversions already accepted by the strict type converter.

All new expressions are valid around aggregate expressions and participate in
GROUP BY safety checks. SQL NULL remains distinct from MiniLang `void`.
