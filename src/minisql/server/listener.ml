package minisql.server.listener

import minisql.platform.file as file_api
import minisql.platform.network as network
import minisql.platform.clock as clock
import minisql.protocol.connection as connection
import minisql.protocol.constants as constants
import minisql.protocol.messages as messages
import minisql.server.session as session
import minisql.server.database_manager as database_manager

const INVALID_ARGUMENT = 9001

function fail(operation, message)
  return error(INVALID_ARGUMENT, "server.listener." + operation + ": " + message)
end function

function validateArguments(databasePath, maximumRequests, operation)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(operation, "databasePath must be non-empty") end if
  if typeof(maximumRequests) != "int" or maximumRequests < 0 or maximumRequests > 1000000 then return fail(operation, "maximumRequests is invalid; zero means unlimited") end if
  return true
end function

function serveListenerMode(databasePath, listener, maximumRequests, secure)
  socketHandle = try(network.acceptTcp(listener))
  if typeof(socketHandle) == "error" then network.close(listener); return socketHandle end if
  ignoredTimeout = try(network.setTimeouts(socketHandle, 60000, 60000))
  client = connection.create(socketHandle)
  active = void
  if secure then
    active = try(session.openSecure(databasePath))
  else
    active = try(session.open(databasePath))
  end if
  if typeof(active) == "error" then connection.close(client); network.close(listener); return active end if
  handled = 0
  failure = void
  while (maximumRequests == 0 or handled < maximumRequests) and not active.closeRequested
    request = try(connection.receiveMessage(client))
    if typeof(request) == "error" then failure = request; break end if
    response = try(session.handle(active, request))
    if typeof(response) == "error" then failure = response; break end if
    sent = try(connection.sendMessage(client, response))
    if typeof(sent) == "error" then failure = sent; break end if
    if session.transportReady(active) then session.activateTransport(active, client) end if
    handled = handled + 1
  end while
  closeSession = try(session.close(active))
  closeClient = try(connection.close(client))
  closeListener = try(network.close(listener))
  if failure is not void then return failure end if
  if typeof(closeSession) == "error" then return closeSession end if
  if typeof(closeClient) == "error" then return closeClient end if
  if typeof(closeListener) == "error" then return closeListener end if
  return handled
end function

function serveListener(databasePath, listener, maximumRequests)
  return serveListenerMode(databasePath, listener, maximumRequests, false)
end function

function serveSecureListener(databasePath, listener, maximumRequests)
  return serveListenerMode(databasePath, listener, maximumRequests, true)
end function

function serveOne(databasePath, port, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveOne")
  listener = network.listenLoopback(port, 8)
  return serveListener(databasePath, listener, maximumRequests)
end function

function serveAuthenticatedOne(databasePath, port, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedOne")
  listener = network.listenLoopback(port, 8)
  return serveSecureListener(databasePath, listener, maximumRequests)
end function

function publishReady(listener, readyPath, operation)
  if typeof(readyPath) != "string" or len(readyPath) == 0 then return fail(operation, "readyPath must be non-empty") end if
  ready = try(file_api.createNewDurable(readyPath))
  if typeof(ready) == "error" then network.close(listener); return ready end if
  flushed = try(file_api.flush(ready))
  closed = try(file_api.close(ready))
  if typeof(flushed) == "error" then network.close(listener); return flushed end if
  if typeof(closed) == "error" then network.close(listener); return closed end if
  return true
end function

function serveOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveOneWithReadyFile")
  // Bind before publishing readiness so an independent client cannot race the
  // listener startup. The marker is test-only and is created durably.
  listener = network.listenLoopback(port, 8)
  published = try(publishReady(listener, readyPath, "serveOneWithReadyFile"))
  if typeof(published) == "error" then return published end if
  return serveListener(databasePath, listener, maximumRequests)
end function

function serveAuthenticatedOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedOneWithReadyFile")
  listener = network.listenLoopback(port, 8)
  published = try(publishReady(listener, readyPath, "serveAuthenticatedOneWithReadyFile"))
  if typeof(published) == "error" then return published end if
  return serveSecureListener(databasePath, listener, maximumRequests)
end function


struct ClientSlot
  client
  activeSession
  handled
  closed
  pendingRequest
  waitStarted
  lastActivity
end struct

function closeSlot(slot)
  if slot is not ClientSlot or slot.closed then return true end if
  if slot.activeSession is not void then
    session.abortForConcurrency(slot.activeSession)
    ignoredSession = try(session.close(slot.activeSession))
  end if
  if slot.client is not void then ignoredClient = try(connection.close(slot.client)) end if
  slot.pendingRequest = void
  slot.closed = true
  return true
end function

function activeSlotCount(slots)
  count = 0
  for each slot in slots
    if not slot.closed then count = count + 1 end if
  end for
  return count
end function

function responseErrorCode(response)
  if response.messageType != constants.TYPE_ERROR then return 0 end if
  decoded = try(messages.decodeResponse(response.payload))
  if typeof(decoded) == "error" then return 0 end if
  return decoded.errorCode
end function

function errorMessageFor(request, code, text)
  payload = messages.encodeResponse(messages.errorResponse(code, text))
  return messages.create(constants.TYPE_ERROR, 0, request.requestId, payload)
end function

function processRequest(slot, request, lockWaitMs)
  response = try(session.handle(slot.activeSession, request))
  if typeof(response) == "error" then return response end if
  code = responseErrorCode(response)
  if code == 9007 then
    now = clock.monotonicMilliseconds()
    if slot.pendingRequest is void then
      slot.pendingRequest = request
      slot.waitStarted = now
    end if
    if now - slot.waitStarted < lockWaitMs then return void end if
    session.abortForConcurrency(slot.activeSession)
    slot.pendingRequest = void
    return errorMessageFor(request, 9032, "lock wait timeout; transaction rolled back")
  end if
  if code == 9031 then session.abortForConcurrency(slot.activeSession) end if
  slot.pendingRequest = void
  return response
end function

function serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, secure, idleLimitMs, standby)
  if typeof(maximumClients) != "int" or maximumClients < 1 or maximumClients > 128 then network.close(listener); return fail("serveConcurrent", "maximumClients is invalid") end if
  if typeof(idleLimitMs) != "int" or idleLimitMs < 0 or idleLimitMs > 600000 or (idleLimitMs > 0 and idleLimitMs < 100) then network.close(listener); return fail("serveConcurrent", "idleLimitMs is invalid; zero means unlimited") end if
  shared = void
  if standby then
    shared = try(database_manager.openStandby(databasePath))
  else
    shared = try(database_manager.open(databasePath))
  end if
  if typeof(shared) == "error" then network.close(listener); return shared end if
  nonBlocking = try(network.setNonBlocking(listener, true))
  if typeof(nonBlocking) == "error" then database_manager.close(shared); network.close(listener); return nonBlocking end if
  slots = []
  accepted = 0
  handled = 0
  failure = void
  lastProgress = clock.monotonicMilliseconds()
  lockWaitMs = 5000
  sessionIdleMs = session.idleTimeoutMilliseconds()

  while (maximumRequests == 0 or handled < maximumRequests) and (idleLimitMs == 0 or clock.monotonicMilliseconds() - lastProgress < idleLimitMs)
    progressed = false
    while activeSlotCount(slots) < maximumClients and (maximumRequests == 0 or handled < maximumRequests)
      socketHandle = try(network.tryAccept(listener))
      if typeof(socketHandle) == "error" then failure = socketHandle; break end if
      if socketHandle is void then break end if
      client = connection.create(socketHandle)
      connection.makeNonBlocking(client)
      active = void
      if secure then active = try(session.openSecureAttached(shared)) else active = try(session.openAttached(shared)) end if
      if typeof(active) == "error" then connection.close(client); failure = active; break end if
      now = clock.monotonicMilliseconds()
      slots = slots + [ClientSlot(client, active, 0, false, void, 0, now)]
      accepted = accepted + 1
      progressed = true
    end while
    if failure is not void then break end if

    now = clock.monotonicMilliseconds()
    for each slot in slots
      if not slot.closed and (maximumRequests == 0 or handled < maximumRequests) then
        request = slot.pendingRequest
        if request is void then
          polled = try(connection.pollMessage(slot.client))
          if typeof(polled) == "error" then
            closeSlot(slot)
            progressed = true
          else if polled is not void then
            if polled.closed then
              closeSlot(slot)
              progressed = true
            else
              request = polled.message
              slot.lastActivity = now
            end if
          end if
        end if

        if request is not void and not slot.closed then
          response = try(processRequest(slot, request, lockWaitMs))
          if typeof(response) == "error" then closeSlot(slot); failure = response; break end if
          if response is not void then
            sent = try(connection.sendMessage(slot.client, response))
            if typeof(sent) == "error" then
              closeSlot(slot)
            else
              if session.transportReady(slot.activeSession) then session.activateTransport(slot.activeSession, slot.client) end if
              slot.handled = slot.handled + 1
              handled = handled + 1
              slot.lastActivity = now
              progressed = true
              if slot.activeSession.closeRequested then closeSlot(slot) end if
            end if
          end if
        end if

        if not slot.closed and slot.pendingRequest is void and (now - slot.lastActivity >= sessionIdleMs or session.isExpired(slot.activeSession)) then
          closeSlot(slot)
          progressed = true
        end if
      end if
    end for
    if failure is not void then break end if
    if progressed then lastProgress = clock.monotonicMilliseconds() else network.sleepMilliseconds(1) end if
  end while

  for each slot in slots
    closeSlot(slot)
  end for
  closedDatabase = try(database_manager.close(shared))
  closedListener = try(network.close(listener))
  if failure is not void then return failure end if
  if typeof(closedDatabase) == "error" then return closedDatabase end if
  if typeof(closedListener) == "error" then return closedListener end if
  if maximumRequests > 0 and handled < maximumRequests then return fail("serveConcurrent", "scheduler idle timeout before request budget was reached") end if
  return handled
end function

function serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveConcurrentLoopback")
  listener = network.listenLoopback(port, maximumClients)
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, false, idleLimit, false)
end function

function serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentLoopback")
  listener = network.listenLoopback(port, maximumClients)
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, true, idleLimit, false)
end function

function serveConcurrentWithReadyFile(databasePath, port, maximumClients, maximumRequests, readyPath, secure)
  validateArguments(databasePath, maximumRequests, "serveConcurrentWithReadyFile")
  listener = network.listenLoopback(port, maximumClients)
  published = try(publishReady(listener, readyPath, "serveConcurrentWithReadyFile"))
  if typeof(published) == "error" then return published end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, secure, idleLimit, false)
end function

function serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveStandbyConcurrentLoopback")
  listener = network.listenLoopback(port, maximumClients)
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, false, idleLimit, true)
end function

function serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddress")
  listener = network.listenAddress(address, port, maximumClients, true)
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, true, idleLimit, false)
end function

function serveAuthenticatedConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, readyPath)
  validateArguments(databasePath, maximumRequests, "serveAuthenticatedConcurrentAddressWithReadyFile")
  listener = network.listenAddress(address, port, maximumClients, true)
  published = try(publishReady(listener, readyPath, "serveAuthenticatedConcurrentAddressWithReadyFile"))
  if typeof(published) == "error" then return published end if
  idleLimit = 60000
  if maximumRequests == 0 then idleLimit = 0 end if
  return serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, true, idleLimit, false)
end function

function componentName()
  return "server.listener"
end function

function targetMilestone()
  return "M18"
end function

function isImplemented()
  return true
end function
