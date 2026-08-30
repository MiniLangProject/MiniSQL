# Recovery tests

Crash injection, torn-write simulation, WAL replay, checkpoint fallback and
power-loss boundary tests live here beginning with the durability milestones.

`../fault/production_fault_drill.py` composes these primitives into an isolated
operational exercise with network aborts, a hard server kill under concurrent
writes, restart, offline checking, and middle-record WAL corruption in a clone.
