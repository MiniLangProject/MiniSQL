# ADR-0016: one-page bootstrap catalog

Status: accepted for M8.

M8 uses protected one-page database and catalog payloads to bootstrap identity, format
settings and initial object metadata. The size limit is explicit. Later transactional
system relations will replace the catalog payload while preserving the bootstrap header.
