# Schema extensions v1

`catalog/schema.extensions` is a protected envelope with magic `MSEXT001`,
version 1 and kind 43. Its payload binds to the 16-byte database identity and
contains a generation followed by counts and records for views, sequences,
generated columns and triggers. Reserved fields and unknown flags MUST be zero.
The complete payload is limited to 1 MiB and is atomically replaced.
