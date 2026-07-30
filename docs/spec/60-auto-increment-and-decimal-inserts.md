# AUTO_INCREMENT and decimal INSERT input

## AUTO_INCREMENT compatibility syntax

MiniSQL accepts both compatibility spellings:

```sql
CREATE TABLE measurement (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    value DECIMAL(10,2) NOT NULL
);
```

```sql
CREATE TABLE measurement (
    id INTEGER AUTOINCREMENT PRIMARY KEY,
    value REAL
);
```

Both forms are aliases for:

```sql
GENERATED ALWAYS AS IDENTITY
```

They do not introduce MySQL- or SQLite-specific storage semantics. The existing
MiniSQL identity rules remain authoritative:

- the column type MUST be `SMALLINT`, `INTEGER`, or `BIGINT`;
- a table may contain at most one identity/auto-increment column;
- the column is implicitly `NOT NULL`;
- it MUST NOT also declare `DEFAULT` or a generated-column expression;
- explicit values for the column are rejected;
- generated values survive close/reopen and participate in transaction,
  rollback, recovery, backup, restore, migration, and `TRUNCATE ... RESTART
  IDENTITY` behavior already specified for identity columns.

## Decimal-point literals in INSERT

Numeric SQL literals with a decimal point or exponent are accepted in `VALUES`
for approximate and exact numeric targets:

```sql
INSERT INTO measurement(value) VALUES (3.3);
INSERT INTO measurement(value) VALUES (-4.75);
INSERT INTO measurement(value) VALUES (1.25e2);
```

For `REAL` and `DOUBLE PRECISION`, MiniSQL performs target-directed approximate
numeric conversion. Ordinary integer/decimal spellings use the native numeric
conversion path. An optional `e`/`E` exponent is parsed explicitly, including an
optional sign, so both positive and negative scientific notation are accepted:

```sql
REAL             <- 3.3
DOUBLE PRECISION <- 1.25e2
DOUBLE PRECISION <- 1.25e-2
```

The approximate result must remain finite. Malformed exponents and values
outside the supported finite DOUBLE exponent range are rejected. The same
parser is used by text-to-REAL/DOUBLE `CAST`.

For `DECIMAL(p,s)`, MiniSQL parses the original SQL spelling directly into its
signed scaled-integer representation. Binary floating point is not used as an
intermediate representation. Therefore:

```sql
DECIMAL(10,2) <- 3.3    -- stored scaled value 330
DECIMAL(10,2) <- 3      -- stored scaled value 300
DECIMAL(10,2) <- 1.25e2 -- stored scaled value 12500
```

MiniSQL does not silently change exact values:

```sql
DECIMAL(10,2) <- 3.333       -- rejected: requires rounding/truncation
DECIMAL(10,2) <- 123456789.01 -- rejected: precision overflow
```

The same target-directed literal binding is used after prepared-statement
parameter substitution. This specification covers input and storage semantics;
formatting a DECIMAL result with a fixed number of trailing fractional digits is
separate presentation behavior.
