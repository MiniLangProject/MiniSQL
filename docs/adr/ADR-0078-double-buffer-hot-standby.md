# ADR-0078: Double-buffer hot standby

**Decision:** materialize an inactive standby slot completely, start its
read-only server, and only then switch new loopback proxy connections to it.
Existing sessions may finish on the old generation.

This avoids mutating files held open by read clients and ensures that a failed
refresh never replaces a working standby generation.
