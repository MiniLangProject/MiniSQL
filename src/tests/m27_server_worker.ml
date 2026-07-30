import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.server.listener as listener

function main(args)
  if len(args) != 5 then print "MiniSQL M27 concurrent server worker: FAIL args"; return 2 end if
  root = args[0]
  port = toNumber(args[1])
  readyPath = args[2]
  maximumClients = toNumber(args[3])
  maximumRequests = toNumber(args[4])
  if typeof(port) != "int" or typeof(maximumClients) != "int" or typeof(maximumRequests) != "int" then return 2 end if
  file_api.createDirectory(root)
  managed = database_manager.create(root, "m27_server", config_model.defaultDatabaseSettings(4096))
  path = managed.path
  engine = executor.attach(managed)
  executor.executeSql(engine, "CREATE TABLE shared_item (id INTEGER PRIMARY KEY, value VARCHAR(40) NOT NULL)")
  executor.close(engine)
  database_manager.close(managed)
  handled = try(listener.serveConcurrentWithReadyFile(path, port, maximumClients, maximumRequests, readyPath, false))
  if typeof(handled) == "error" then print "ERROR " + handled.code + ": " + handled.message; return 1 end if
  if handled != maximumRequests then print "MiniSQL M27 concurrent server worker: FAIL handled=" + handled; return 1 end if
  print "MiniSQL M27 concurrent server worker: SUCCESS requests=" + handled
  return 0
end function
