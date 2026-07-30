# ADR-0060: UPSERT uses target plus synthetic EXCLUDED sources

Status: accepted for M41 candidate.

The binder creates two row sources: the current target row and a synthetic
metadata clone named `excluded`. The clone has a distinct base name so qualified
target references cannot become ambiguous. Evaluation concatenates target then
excluded values in those bound offsets.
