package minisql.server.server

import minisql.common.version as version
import minisql.server.listener as listener

function m0SelfTestLine()
  return "MiniSQL server M0 self-test: SUCCESS"
end function

function versionLine()
  return version.versionLine("server")
end function

function serveOne(databasePath, port, maximumRequests)
  return listener.serveOne(databasePath, port, maximumRequests)
end function

function serveAuthenticatedOne(databasePath, port, maximumRequests)
  return listener.serveAuthenticatedOne(databasePath, port, maximumRequests)
end function

function serveConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

function serveAuthenticatedConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

function serveStandbyConcurrent(databasePath, port, maximumClients, maximumRequests)
  return listener.serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
end function

function serveSecureAddress(databasePath, address, port, maximumClients, maximumRequests)
  return listener.serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
end function

function start(configPath)
  return error(9001, "server.start: use serveAuthenticatedConcurrent or serveSecureAddress")
end function

function componentName()
  return "server.server"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
