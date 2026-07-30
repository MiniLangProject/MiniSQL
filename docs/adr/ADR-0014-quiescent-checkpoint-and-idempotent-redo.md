# ADR-0014: quiescent checkpoint and idempotent redo

Status: accepted for M7.

The first checkpoint implementation requires a quiescent transaction boundary. Recovery
redoes only committed full page images and compares pageLSN before writing. This favors a
small, testable correctness surface before concurrent fuzzy checkpoints and WAL recycling.
