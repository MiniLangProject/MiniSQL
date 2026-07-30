# ADR-0019: forwarding records for growing updates

Status: accepted for M9.

When an updated row no longer fits, MiniSQL writes a moved copy first and then publishes
a forwarding record at the stable RowId. This preserves address stability and chooses an
unreachable leak over visible data loss if a crash occurs between those operations.
