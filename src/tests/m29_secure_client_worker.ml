import minisql.client.client as client
import minisql.common.uuid as uuid
import minisql.protocol.constants as constants

function main(args)
  if len(args) != 2 then print "MiniSQL M29 secure concurrent client worker: FAIL args"; return 2 end if
  port = toNumber(args[0])
  clientId = toNumber(args[1])
  if typeof(port) != "int" or typeof(clientId) != "int" then return 2 end if

  password = bytes("Network-M29-Password!")
  active = try(client.openAuthenticatedLoopbackBytes(port, "netuser", password))
  uuid.wipeSecret(password)
  if typeof(active) == "error" then print "ERROR " + active.code + ": " + active.message; return 1 end if
  if not active.authenticated or not active.connection.secure then ignored = try(client.close(active)); print "MiniSQL M29 secure concurrent client worker: FAIL transport"; return 1 end if

  selected = try(client.query(active, "SELECT id, body FROM secure_item WHERE id = 1"))
  if typeof(selected) == "error" then ignored = try(client.close(active)); return 1 end if
  if selected.status != constants.STATUS_ROWS or len(selected.rows) != 1 or selected.rows[0][1] != "encrypted-response" then ignored = try(client.close(active)); print "MiniSQL M29 secure concurrent client worker: FAIL row"; return 1 end if
  pong = try(client.ping(active))
  closed = try(client.close(active))
  if typeof(pong) == "error" or not pong or typeof(closed) == "error" then return 1 end if
  print "MiniSQL M29 secure concurrent client worker: SUCCESS id=" + clientId
  return 0
end function
