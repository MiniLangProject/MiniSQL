# ADR-0080: MiniSQL 1.0 compatibility freeze

**Decision:** M50 publishes version 1.0.0 while retaining database format 1 and
wire protocol 1. Future incompatible changes require explicit migration or
protocol negotiation; configuration defaults never reinterpret existing files.
