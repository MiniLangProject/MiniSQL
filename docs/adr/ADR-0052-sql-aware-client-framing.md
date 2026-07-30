# ADR-0052: SQL-aware framing belongs in the client

## Status

Accepted for the M33 candidate.

## Decision

Use a small lexical state machine in `client.console` to identify statement
boundaries for shell and script input. Do not split on lines or raw semicolons,
and do not duplicate the complete SQL parser in the client.

## Consequences

Multiline transactions and semicolons inside literals/comments work over one
session. The server remains authoritative for syntax and semantics. The scanner
is deliberately limited to quoting/comment state and does not attempt error
recovery beyond an incomplete suffix.
