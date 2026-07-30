# ADR-0027: validate constraints by visible-row scans in M15

M15 enforces PRIMARY KEY, UNIQUE and FOREIGN KEY semantics through transaction-aware
visible-row scans even though physical B+ tree files already exist. This avoids treating
an incompletely maintained index as authoritative. Correctness therefore precedes speed.
M17 will update indexes transactionally and allow the optimizer to choose index-backed
validation and access paths while retaining scan-based differential tests.
