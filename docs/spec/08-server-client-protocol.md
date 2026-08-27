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

Eligible single-table rows are streamed from a storage cursor in bounded
batches. The server applies socket backpressure before asking the executor for
the next batch, and cursor-aware clients retain only the current frame. Blocking
or currently ineligible query shapes may still materialize before bounded wire
framing; this explicit implementation boundary is documented in the release
limitations.

Before DCL, the listener MUST bind only to loopback. External binding without
authentication is a startup error.

The console client provides SQL input plus local commands such as `\\connect`,
`\\databases`, `\\tables`, `\\schema`, `\\timing` and `\\quit`.
