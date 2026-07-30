# ADR-0038: contextual SQL keywords remain legal identifiers

## Status

Accepted for M21R1.

## Context

MiniSQL's lexer emits a single `Keyword` token kind for grammar words, SQL type names and
aggregate function names. The original parser accepted only `Identifier` tokens in object
and column-name positions. Consequently an otherwise unambiguous statement such as
`CREATE TABLE t (text VARCHAR(80))` failed because `TEXT` was classified as a keyword.

A real SQL dialect needs a documented distinction between fully reserved words and words
that are contextual. Quoting every common type-like column name would be unnecessarily
restrictive and would make ordinary schemas less portable.

## Decision

The lexer continues to classify every known SQL keyword canonically. The dialect module
publishes an explicit list of non-reserved identifier keywords. For SQL 1.0 this list
contains the supported type names and aggregate function names.

Whenever the grammar expects an identifier, the parser accepts either:

1. an ordinary or quoted `Identifier` token, or
2. a `Keyword` token present in the non-reserved identifier-keyword list.

An accepted unquoted contextual keyword is canonicalized to lower case. Quoted identifiers
continue to preserve exact spelling. Fully reserved control and clause words such as
`SELECT`, `FROM`, `TABLE`, `WHERE` and `GRANT` remain illegal unquoted identifiers.

Function-call parsing remains contextual: an allowed identifier followed by `(` may be a
function name; otherwise it may be a column reference.

## Consequences

- `text`, `date`, `integer`, `count`, `sum` and the other documented contextual names can
  be used unquoted for tables, columns and aliases.
- the same tokens still parse as type names or aggregate functions where those constructs
  are expected;
- all accepted unquoted names use the existing lower-case catalog canonicalization;
- no on-disk or network format changes;
- adding another contextual keyword requires an explicit dialect-list and regression-test
  change rather than silently weakening every keyword.
