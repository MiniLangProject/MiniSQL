# ADR-0028: single-table executor baseline

The first executable SQL engine uses an explicit but direct scan/filter/project/sort
pipeline. It supports useful DDL, DML and transactions without prematurely coupling SQL
semantics to a cost model. M16 introduces logical/physical plan nodes, joins and
aggregation; M17 adds statistics and cost-based choice. The M15 behavior remains the
reference implementation for differential testing.
