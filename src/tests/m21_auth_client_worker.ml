import minisql.client.client as client
import minisql.protocol.constants as constants
import tests.support.testkit as testkit

function main(args)
  if len(args) != 1 then
    print "MiniSQL M21 authenticated client tests: FAIL (expected port)"
    return 1
  end if
  port = toNumber(args[0])
  if typeof(port) != "int" then
    print "MiniSQL M21 authenticated client tests: FAIL (invalid port)"
    return 1
  end if

  state = testkit.create()
  connection = client.openAuthenticatedLoopback(port, "netuser", "Network-Password-21!")
  testkit.record(state, connection.authenticated, "client authentication succeeds")
  testkit.record(state, client.ping(connection), "authenticated PING/PONG")

  selected = client.query(connection, "SELECT id, body FROM message ORDER BY id")
  testkit.equal(state, selected.status, constants.STATUS_ROWS, "authorized SELECT status")
  testkit.equal(state, len(selected.rows), 1, "authorized SELECT row count")
  testkit.equal(state, selected.rows[0][1], "secure-server", "authorized SELECT value")

  denied = client.query(connection, "INSERT INTO message(id, body) VALUES (2, 'denied')")
  testkit.equal(state, denied.status, constants.STATUS_ERROR, "unauthorized INSERT status")
  testkit.equal(state, denied.errorCode, 9029, "unauthorized INSERT error code")

  testkit.record(state, client.close(connection), "authenticated CLOSE handshake")
  return testkit.finish(state, "MiniSQL M21 authenticated client tests: SUCCESS", "MiniSQL M21 authenticated client tests: FAIL")
end function
