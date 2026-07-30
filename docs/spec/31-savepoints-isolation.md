# Savepoints and isolation leases (M19)

SAVEPOINT records a deep snapshot of transaction-private page changes. Names are case-normalized by the SQL parser and duplicate names shadow earlier instances. ROLLBACK TO restores the named snapshot, discards later savepoints and changes, retains the named savepoint, and returns a failed transaction to ACTIVE. RELEASE removes the named savepoint and its nested scope. Commit and full rollback clear all savepoints. READ COMMITTED read leases end after the statement; SERIALIZABLE read leases remain until transaction completion.
