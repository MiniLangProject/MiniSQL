# Reference and differential fixtures

`m1_endian_vectors.json` is the independent machine-readable fixture for the
fixed-width codec. Its envelope records the native MiniLang scalar model and
uses four explicit value kinds:

- `unsigned` for scalar U8/U16/U32 fields;
- `signed` for scalar I8/I16/I32 fields;
- `u64words` for a complete U64 bit pattern;
- `i64words` for a complete I64 two's-complement bit pattern.

The Python test runner recomputes every vector with Python's integer byte
encoder before the MiniLang tests are compiled. The fixture therefore does not
merely repeat values trusted from the implementation under test.

The remaining JSON files freeze persisted layouts, supported SQL surfaces, and
compatibility contracts introduced across M4-M50. They are retained as stable
MiniSQL 1.0.0 regression inputs.

Future SQL differential cases whose semantics overlap a selected reference
database should be stored here with explicit dialect differences and expected
results.
