# Relational execution (M16)

MiniSQL lowers bound SELECT statements to relational operators. M16 supports scan, selection, projection, nested-loop INNER/LEFT/CROSS joins, grouping, HAVING, COUNT/SUM/AVG/MIN/MAX, DISTINCT, stable in-memory sort, LIMIT/OFFSET and UNION/INTERSECT/EXCEPT with ALL where applicable. SQL NULL and three-valued predicates are preserved. A LEFT JOIN emits typed NULL values for the unmatched right side. Compound queries require compatible column counts/types. The baseline algorithms prioritize correctness; M17 may choose alternatives using statistics.
