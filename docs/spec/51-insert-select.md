# INSERT INTO ... SELECT

The SELECT result column count MUST equal the selected target-column count and
each source type MUST be assignable to its target type.

The executor MUST fully materialize the source result before the first target
write. This guarantees finite self-inserts, source/target isolation within the
statement and rollback without partial target visibility. The initial
correctness implementation MAY keep that materialized result in memory.
