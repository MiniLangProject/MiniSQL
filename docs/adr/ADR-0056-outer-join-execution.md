# ADR-0056: Complement-tracking nested-loop outer joins

## Status

Accepted for the M37 candidate.

## Decision

Extend the correct nested-loop baseline with a right-row match bitmap and a
persisted description of the accumulated left-side types. Emit unmatched right
rows only after all left rows have been evaluated.

## Consequences

RIGHT and FULL OUTER JOIN are correct for empty and multi-table inputs. The
current index shortcut is bypassed for these joins until an index operator can
also enumerate non-matches. This favors correctness over premature speed.
