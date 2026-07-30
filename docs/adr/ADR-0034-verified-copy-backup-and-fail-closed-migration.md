# ADR-0034: Verified backup and fail-closed migration

Backups are copied under the database lock, checksummed and atomically published. Format changes are never in-place metadata edits. Unsupported page-size rewrites are explicitly refused before touching source data.
