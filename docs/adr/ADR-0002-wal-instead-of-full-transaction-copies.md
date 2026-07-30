# ADR-0002: WAL instead of full table copies per transaction

Status: accepted in M0.

Transactions use private changed-page images and a database-wide write-ahead log.
Full parallel copies of every touched table would make small commits proportional to
table size and complicate atomic multi-table merge. Shadow files remain appropriate
for offline rebuild/migration operations.
