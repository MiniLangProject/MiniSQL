# ADR-0030: Relational operator pipeline

Use explicit bound, logical and physical plans instead of executing parser AST nodes directly. This keeps SQL semantics separate from algorithm selection and allows M17 statistics to influence plans without changing query meaning.
