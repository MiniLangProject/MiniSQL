# 3. Logical data types

MiniSQL uses strict declared types. SQL NULL is represented by a dedicated value
state and is not MiniLang `void`.

| SQL type | Logical semantics | Initial physical representation |
|---|---|---|
| BOOLEAN | TRUE/FALSE/NULL | one byte plus NULL bitmap |
| SMALLINT | signed 16-bit | 2 bytes |
| INTEGER / INT | signed 32-bit | 4 bytes |
| BIGINT | complete signed 64-bit domain | 8-byte two's-complement value; runtime `Int64Words` |
| REAL / DOUBLE PRECISION | IEEE-754 binary64 | 8 bytes |
| DECIMAL(p,s) | exact fixed decimal, 1<=p<=18 | scaled signed 64-bit; runtime representation specified with SQL values |
| CHAR(n) | exactly n Unicode characters | validated UTF-8 |
| VARCHAR(n) | at most n Unicode characters | validated UTF-8 |
| TEXT | unbounded-by-schema text within engine limits | inline or overflow pages |
| BINARY(n) | exactly n bytes | raw bytes |
| VARBINARY(n) | at most n bytes | raw bytes |
| BLOB | large uninterpreted bytes | inline or overflow pages |
| DATE | Gregorian date | signed 32-bit days since 1970-01-01 |
| TIME(p) | time without zone, 0<=p<=6 | unsigned microseconds since midnight |
| TIMESTAMP(p) | date/time without zone | signed 64-bit microseconds; runtime word-pair when required |

## Logical domain versus MiniLang scalar domain

SQL type ranges are independent of the native MiniLang immediate-integer range. The
native runtime reserves three tag bits, so a MiniLang scalar `int` carries a signed
61-bit payload (`-2^60..2^60-1`). MiniSQL MUST NOT narrow SQL `BIGINT` to that range.

The complete SQL `BIGINT` domain is represented internally by the two-word
`Int64Words(high, low)` type defined by the fixed-width codec specification. Values in
the native scalar subset may use explicit conversion helpers, but conversion outside
that subset MUST fail rather than wrap. Full-domain arithmetic, comparison and overflow
checking will be implemented over the word-pair representation in the SQL value layer.

`DECIMAL(p,s)` with `p<=18` has a coefficient magnitude below `10^18`, which fits the
native signed 61-bit scalar interval, but its persisted representation remains a defined
signed 64-bit field. Code MUST use the physical-value codec rather than assume that the
runtime representation and disk representation are identical.

## Rules

- Overflow MUST raise an error; silent integer wrapping is forbidden.
- Excess-length text/binary input MUST raise an error; silent truncation is forbidden.
- Stored text MUST be valid UTF-8.
- String-to-number conversion is explicit through `CAST`.
- SQL comparison and boolean expressions use three-valued logic.
- `TIMESTAMP WITH TIME ZONE`, arbitrary-precision decimal and locale collations are
  later extensions.
