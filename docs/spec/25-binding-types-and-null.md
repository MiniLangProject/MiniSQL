# 25. Binding, SQL types and NULL

The binder resolves table/column names against the catalog, expands `*`, validates
aliases and target columns, and converts syntax expressions into typed bound expression
trees. ORDER BY may reference an unqualified select-list alias; duplicate aliases are
ambiguous and rejected.

The type codes match the row codec: BOOLEAN, SMALLINT, INTEGER, BIGINT, REAL, DOUBLE,
DECIMAL, CHAR, VARCHAR, TEXT, BINARY, VARBINARY, BLOB, DATE, TIME and TIMESTAMP. DECIMAL
precision is 1..18; temporal precision is 0..6. Assignments are strict: no implicit
text-to-number conversion, no silent truncation and no overflow wrapping.

SQL NULL is represented by `SqlValue(isNull=true)` and is never inferred from a bare
MiniLang `void`. Boolean evaluation is three-valued. WHERE keeps only TRUE; CHECK rejects
FALSE but accepts TRUE and UNKNOWN. Full signed 64-bit values use `Int64Words`, avoiding
the smaller native tagged MiniLang integer domain.
