# 24. SQL front end

MiniSQL SQL 1.0 is tokenized from UTF-8 text with byte offsets plus one-based line and
column positions. Line comments (`--`), block comments, quoted identifiers with doubled
quotes and strings with doubled apostrophes are supported. Unquoted identifiers are
canonicalized to lower case while keywords are canonical upper case.

M12 parses CREATE TABLE, CREATE [UNIQUE] INDEX with optional INCLUDE and WHERE
clauses, DROP TABLE, INSERT, UPDATE, DELETE,
SELECT, BEGIN, COMMIT and ROLLBACK. SELECT supports a single FROM relation, aliases,
DISTINCT, WHERE, ORDER BY with NULL placement, LIMIT and OFFSET. Expressions support
literals, columns, `*`, unary NOT/+/-; arithmetic, comparison, Boolean, concatenation and
LIKE operators; and IS [NOT] NULL.

The AST contains syntax only. It stores no open-file handles or catalog references.
Binding and type checking are a separate M13 operation. The parser consumes every token
of every statement; trailing junk and partial statements are syntax errors.

## Reserved and contextual keywords

MiniSQL keeps keyword tokenization independent from identifier admissibility. Clause and
control words such as `SELECT`, `FROM`, `TABLE`, `WHERE`, `GRANT` and `ROLLBACK` are fully
reserved and require double quotes when used as object names.

Supported SQL type names, aggregate function names and selected grammar words that are
unambiguous in identifier positions are contextual, non-reserved keywords. `ACTION` is
contextual: it remains grammar in `NO ACTION`, while `action` is a legal unquoted object
or column name. In an identifier position they may be used unquoted and are canonicalized to
lower case just like ordinary unquoted identifiers. For example, all of the following are
valid:

```sql
CREATE TABLE text (
  text VARCHAR(80),
  date DATE,
  count INTEGER,
  action VARCHAR(20)
);

SELECT text, date, count, action FROM text;
```

The parser uses the surrounding grammar to distinguish these identifiers from type and
function syntax. The lexer still reports them as canonical keyword tokens.

## Trigger pseudo-row qualifiers

`OLD` and `NEW` are reserved pseudo-row keywords rather than general contextual
identifiers. In expression position they are accepted only when immediately qualified by
a column name:

```sql
OLD.value
NEW.value
```

The parser canonicalizes these to qualified column expressions with qualifiers `old` and
`new`. Bare `OLD` or `NEW` remains a syntax error. Event-specific availability is checked
when the trigger executes: INSERT has only `NEW`, DELETE has only `OLD`, and UPDATE has
both.
