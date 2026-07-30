# ADR-0049: audit segment and suffix sequence validation

## Decision

MiniSQL keeps two explicit audit scan modes:

1. `scanAuditBytes` validates a complete segment and therefore requires the
   first record sequence to be 1.
2. `scanAuditBytesFromSequence` validates a suffix against a caller-supplied
   predecessor sequence and predecessor hash.

`appendAudit` validates its newly encoded one-record suffix with the second mode
before writing it to the durable log. The in-memory next sequence is derived
from the validated scan result rather than incremented independently.

## Rationale

A complete segment and a suffix have different sequence origins. Reusing a
complete-segment scanner for a later one-record suffix rejects every append after
sequence 1. If validation happens after publication, that software error can also
leave a valid but unacknowledged record in the file while the in-memory state
still points to its predecessor. Explicit predecessor sequence input preserves
strict first-record validation for full segments while making suffix validation
correct and deterministic.

## Compatibility

No byte layout, magic value, digest input, sequence encoding, rotation rule or
file path changes. Audit-log v1 remains binary compatible.
