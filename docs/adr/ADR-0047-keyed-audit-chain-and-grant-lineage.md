# ADR-0047: keyed audit chain and grant lineage

Decision: audit integrity uses an HMAC-SHA-256 chain with a per-database key.
Role and privilege records preserve grantor lineage so RESTRICT can identify
dependencies and CASCADE can remove the authority subtree deterministically.

Append validation distinguishes a complete segment from a later suffix. The
detailed sequence-origin rule is recorded in ADR-0049.
