# Audit and revoke dependencies

Audit records contain sequence, Windows file-time timestamp, event type,
outcome, session/principal IDs, previous digest, detail length and keyed
HMAC-SHA-256 digest. The audit key is a 32-byte protected database file and is
included in verified backup. Rotation appends a rotation event, moves the
current segment to `audit.previous`, publishes its final digest as the new
anchor and starts an empty current segment.

A complete segment is numbered from sequence 1. Validation of a newly encoded
append suffix additionally receives the preceding sequence and hash. The suffix
is validated before it is published, so complete-segment validation remains
strict without rejecting valid second and later records.

Role memberships and object grants retain their grantor. REVOKE RESTRICT fails
while a direct or transitive dependent grant exists. REVOKE CASCADE removes the
selected grant and all grants whose authority depends on it. PUBLIC and owner
semantics remain unchanged.
