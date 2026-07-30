# ADR-0069: Scientific approximate-number parsing

Status: accepted for the M43-M47R3 candidate.

## Context

SQL numeric literals permit exponent notation such as `1.25e2`. MiniSQL's exact
`DECIMAL(p,s)` binder already parses the original token directly. The REAL and
DOUBLE path delegated the complete spelling to MiniLang `toNumber`. The native
conversion accepts ordinary integer and decimal spellings, but not an `e`/`E`
exponent suffix, which caused the R2 compatibility phase to fail.

## Decision

Keep the native direct conversion for ordinary spellings. When it does not
produce a number, parse a single optional exponent explicitly:

1. trim ASCII surrounding whitespace;
2. split at one `e` or `E`;
3. parse the mantissa with the native conversion;
4. parse an optional exponent sign and decimal digits;
5. multiply or divide by ten for the bounded exponent magnitude;
6. reject malformed input and non-finite results.

Use the same helper for SQL approximate literals and text-to-REAL/DOUBLE CAST.
The exact DECIMAL path remains separate and unchanged.

## Consequences

- `3.3`, `1.25e2`, and `1.25e-2` are accepted for approximate targets;
- invalid or out-of-range exponents fail deterministically;
- exact DECIMAL input still avoids binary floating point;
- no persistent or wire format changes are required.
