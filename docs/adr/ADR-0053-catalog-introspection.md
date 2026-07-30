# ADR-0053: Stable SQL metadata views before system-table exposure

## Status

Accepted for the M34 candidate.

## Decision

Expose a small, stable set of SHOW/DESCRIBE statements backed by the catalog and
schema history rather than exposing physical catalog files as ordinary SQL
tables.

## Consequences

Users and the public shell can inspect tables, columns and indexes without
binding themselves to internal file layouts. A future information-schema layer
can coexist with these commands.
