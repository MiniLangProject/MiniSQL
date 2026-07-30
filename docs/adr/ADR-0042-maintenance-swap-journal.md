# ADR-0042: Offline file replacement uses a two-state maintenance journal

**Status:** candidate design for M25.

VACUUM publishes a fully written replacement file with a PREPARED/COMMITTED
journal. Recovery chooses the old generation for PREPARED and the new generation
for COMMITTED. The design tolerates interruption at each file-move boundary and
never treats an incomplete replacement as committed.
