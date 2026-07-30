# ADR-0025: separate SQL parsing from binding

The parser produces a catalog-independent AST. A later binder resolves names and assigns
SQL types. This separation permits syntax fuzzing without opening storage, makes catalog
errors distinguishable from syntax errors, and allows future prepared statements and
plan caching to retain the source AST while rebinding against a schema version.
