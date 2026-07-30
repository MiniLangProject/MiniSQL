# ADR-0031: Persisted statistics sidecar

Store optimizer statistics in a database-identified CRC-protected sidecar. Statistics are advisory for cost only; corruption fails EXPLAIN/ANALYZE rather than risking structural database damage.
