# ADR-0065: Add hash paths with semantic fallbacks and durable sort runs

Status: accepted for the M46 candidate.

The optimizer may select hash joins only for supported INNER/LEFT equality
predicates and otherwise retains nested loops. Hash grouping performs equality
checks after hashing. Large sorts use validated temporary run files and pairwise
merge. The established operators remain available as correctness fallbacks.
