# DDL journal format v1

`catalog/ddl.pending` is a CRC-32C protected envelope with magic `MSDDL001` and version 1.
It contains status PREPARED or COMMITTED, whether a prior schema-history file existed,
complete before-images of `db.meta`, bootstrap catalog and schema history, plus arrays of
temporary paths, final paths, backup originals and backup paths.

PREPARED is an undo record and must be durable before any target file move. COMMITTED is
a cleanup record written only after metadata and schema publication. Arrays are length
prefixed, reserved words are zero and all decoded lengths are checked before allocation.
