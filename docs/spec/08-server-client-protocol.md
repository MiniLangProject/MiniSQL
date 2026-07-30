# 8. Server, client and protocol

MiniSQL uses a length-prefixed binary protocol over TCP. Each frame contains magic,
protocol version, message type, flags, request ID, payload length, payload and a
checksum or integrity field as defined by the implemented protocol milestone.

Initial message families:

- HELLO / HELLO_OK
- CONNECT_DATABASE
- QUERY
- PREPARE / EXECUTE
- FETCH / CLOSE_RESULT
- BEGIN / COMMIT / ROLLBACK
- ROW_DESCRIPTION / ROW_BATCH
- COMMAND_COMPLETE
- ERROR
- PING / PONG

Rows are streamed in bounded batches. A query result MUST NOT require full result
materialization in server memory.

Before DCL, the listener MUST bind only to loopback. External binding without
authentication is a startup error.

The console client provides SQL input plus local commands such as `\\connect`,
`\\databases`, `\\tables`, `\\schema`, `\\timing` and `\\quit`.
