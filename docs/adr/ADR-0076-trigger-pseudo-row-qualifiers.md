# ADR-0076: `OLD` and `NEW` are qualified trigger pseudo-row references

## Status

Accepted in MiniSQL 1.0.0.

## Context

`OLD` and `NEW` are lexer keywords because they identify the before-image and after-image
of a row in trigger bodies. The M45 execution layer already replaces qualified
`old.column` and `new.column` AST nodes with typed literals before binding. The SQL parser,
however, rejected the keyword token at expression start and never produced those AST nodes.

Adding `OLD` and `NEW` to the general non-reserved identifier list would make bare forms
and unrelated object names legal everywhere. That would weaken the dialect and obscure the
special trigger semantics.

## Decision

The expression parser has a dedicated rule for a keyword token `OLD` or `NEW` immediately
followed by a dot and a valid column identifier. It produces a normal qualified
`ColumnExpression` with canonical qualifier `old` or `new`.

The words are not added to the general contextual-identifier list. Bare `OLD` and `NEW`
remain syntax errors. Availability of the selected pseudo-row is checked at trigger
execution: `OLD` is unavailable for INSERT and `NEW` is unavailable for DELETE.

## Consequences

- row-trigger bodies can use `OLD.column` and `NEW.column` as specified;
- the existing typed-literal replacement path is used without a new AST or storage format;
- ordinary SQL cannot silently reinterpret bare `OLD` or `NEW` as column names;
- parser and executor responsibilities remain separated;
- no persisted or network format changes.
