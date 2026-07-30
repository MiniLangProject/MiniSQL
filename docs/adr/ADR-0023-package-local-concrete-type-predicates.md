# ADR-0023: Package-local predicates for concrete MiniLang struct types

Status: Accepted for M6-M10R3.

## Context

MiniSQL modules exchange concrete struct values across package boundaries. A caller cannot
safely validate such a value by comparing `typeName(value)` with an unqualified short string:
the concrete runtime name may include the package. This caused the R2 recovery gate to reject
a valid `minisql.transaction.wal.WalScan` as not being `WalScan`.

The package that defines the struct already has an unambiguous local type symbol.

## Decision

For a concrete struct that must be validated by another package, the defining package exposes
a narrow predicate:

```ml
function isWalScan(value)
  return value is WalScan
end function
```

Callers invoke the predicate through the import alias:

```ml
if not wal.isWalScan(value) then ... end if
```

The same pattern is used for configuration model sections, catalog metadata, full-domain
64-bit word structs and external row values.

The cumulative static gate rejects direct comparisons of `typeName(...)` against an
unqualified concrete-type string in MiniSQL engine and test sources.

## Consequences

- Concrete type identity is checked by compiler-assigned type IDs rather than string spelling.
- Package renames cannot silently invalidate short-name comparisons.
- Callers remain decoupled from the defining struct's internal qualified name.
- Each exported predicate becomes a small stable API surface covered by cumulative tests.
- Persisted file formats and wire formats are unaffected.
