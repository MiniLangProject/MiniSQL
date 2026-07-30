# Concurrent sessions and scheduling

A server process owns one `ManagedDatabase` and creates one logical SQL session
per connection. A cooperative nonblocking scheduler polls bounded client slots.
The lock manager supports multiple readers and one writer. Wait edges are
recorded as waiter→blocker relationships; insertion that closes a cycle fails
with error 9031 and selects the requester as victim. Error 9007 is retryable by
the scheduler until the bounded wait expires, after which error 9032 is returned
and the transaction is rolled back. READ COMMITTED read leases end with the
statement; SERIALIZABLE leases end with the transaction. Closing or losing a
connection releases all locks and prepared/session state.
