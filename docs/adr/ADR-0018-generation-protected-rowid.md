# ADR-0018: generation-protected RowId without wraparound

Status: accepted for M9.

A RowId contains page, slot and generation. Deletion advances the generation. Generation
65535 is saturated and that deleted slot is retired permanently instead of wrapping,
preventing an old identifier from aliasing a newly inserted row.
