# ADR-0075: `ACTION` is a contextual SQL identifier keyword

## Status

Accepted for the M43-M47R9 candidate.

## Context

The lexer correctly classifies `ACTION` as a keyword because it participates in the
referential-action phrase `NO ACTION`. The M45 trigger regression also uses a normal audit
column named `action`. The parser previously accepted only ordinary identifiers and the
existing explicit contextual-keyword list in column-name positions, so the valid table
definition failed before any trigger behavior was exercised.

## Decision

`ACTION` remains a keyword token, but is added to the explicit non-reserved identifier
keyword list. Identifier positions canonicalize it to `action`; referential-action grammar
continues to consume it through `matchKeyword`/`expectKeyword`.

The M12 regression now proves both sides of the contract:

- `action` is legal as an unquoted table column in CREATE, INSERT and SELECT;
- `ON DELETE NO ACTION` and `ON UPDATE NO ACTION` still parse as referential actions.

## Consequences

- ordinary audit schemas do not need to quote the intuitive name `action`;
- fully reserved clause/control words remain unavailable as unquoted identifiers;
- extending contextual keywords remains an explicit dialect and test change;
- no persisted or network format changes.
