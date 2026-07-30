# 12. Glossary

- **LSN**: monotonically ordered log sequence number.
- **WAL**: write-ahead log that is made durable before dependent data pages.
- **page LSN**: newest WAL position reflected by a page image.
- **superblock**: redundant critical database metadata record.
- **slotted page**: page with a stable slot directory and movable row payloads.
- **NO-STEAL**: uncommitted changes are not written to base data files.
- **NO-FORCE**: commit does not require every data page to be written immediately.
- **binder**: resolves names, scopes and types after parsing.
- **logical plan**: relational operators independent of concrete algorithms.
- **physical plan**: selected scan/join/sort/aggregate algorithms.
- **format identity**: persisted values that define how a file is interpreted.
