# ADR-0020: two-phase LOB replacement

Status: accepted for M10.

A new overflow chain is written and validated before the owning row pointer changes. The
old chain is reclaimed only after the caller confirms durable pointer publication. Abort
reclaims the new chain. This prevents destructive in-place replacement of large values.
