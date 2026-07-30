# ADR-0022: Avoid unqualified MiniLang builtin-name collisions

## Status

Accepted for M6-M10R2; extended and reconfirmed for M16-M20R1.

## Context

MiniLang builtins participate in direct-call code generation. A package may legally export
a function with the same source name when callers qualify it through an import alias. Inside
the package, however, an unqualified direct call can bind to the builtin.

Two Windows acceptance failures demonstrated the same class of defect:

1. the M6 WAL scanner called `decode(encoded)` and received the builtin UTF-8 decoder
   result instead of a `WalRecord`;
2. the M17 statistics loader called `decode(readWhole(filePath))` and received a string
   instead of a `StatisticsCatalog`.

## Decision

Stable public package APIs may keep names that overlap a builtin when callers use a
qualified alias. Internal calls use uniquely named implementation helpers:

```text
public:   wal.decode(source)
internal: decodeRecord(source)

public:   statistics.decode(source)
internal: decodeCatalog(source)
```

The cumulative static gate requires the helpers and rejects the known ambiguous internal
call forms.

## Consequences

- external test and engine callers do not need an API change;
- generated call targets are deterministic;
- persisted formats are unaffected;
- future internal functions must avoid unqualified names such as `decode`, `len`, `bytes`,
  `slice`, `error`, or other compiler-recognized builtins when a distinct package function
  is intended;
- any new package API that intentionally overlaps a builtin must provide and use a uniquely
  named internal implementation helper from its first revision.
