# ADR-0005: Durable acknowledgement only after WAL flush

Status: accepted in M0.

The default `durability=full` mode acknowledges a commit only after the commit record
and all required preceding WAL records are durably flushed. M0 defines no asynchronous
commit mode.
