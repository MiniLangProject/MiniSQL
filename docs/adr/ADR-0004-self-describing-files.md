# ADR-0004: Self-describing and cross-validated files

Status: accepted in M0.

`db.meta`, table files, index files and WAL segments all contain magic, version,
database identity, relevant object identity, physical format fields and checksums.
Opening cross-validates these sources and fails closed on disagreement.
