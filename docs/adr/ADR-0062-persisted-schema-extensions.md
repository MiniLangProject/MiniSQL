# ADR-0062: Persist new schema objects in a protected extension sidecar

Status: accepted for the M43-M45 candidate.

Views, sequences, generated-column definitions and triggers are stored in
`catalog/schema.extensions` rather than changing the already accepted bootstrap
catalog and schema-history formats. The sidecar is database-identity-bound,
versioned and CRC-protected, and is replaced atomically. These new DDL forms are
autocommit-only in this milestone.
