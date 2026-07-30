# ADR-0070: A successfully dropped relation resolves as object-not-found

Status: accepted for the M43-M47R4 candidate.

## Context

MiniSQL distinguishes a missing catalog object (`9014`, `ObjectNotFound`) from
a semantic binding failure on an object that exists (`9020`, `BindingError`).
The first M43 view test incorrectly expected `BindingError` after successfully
executing `DROP VIEW`.

## Decision

After a successful `DROP VIEW` or `DROP TABLE`, a later reference to that name
MUST return `ObjectNotFound` (`9014`) unless a different object with the same
name has subsequently been created. `BindingError` remains reserved for
semantic errors while binding an existing query/object definition.

`DROP ... IF EXISTS` remains successful for an absent object; this does not
change the behavior of a later query that references the absent name.

## Consequences

- table and view lookup expose one consistent missing-relation contract;
- tests assert the public error category rather than an implementation detail
  of the binder;
- no persisted format, SQL syntax, or wire protocol changes.
