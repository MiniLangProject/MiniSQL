package minisql.platform.network
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.common.endian as endian
import std.time as time_api

// Native IPv4/TCP wrapper used by MiniSQL clients and servers. M27 adds bounded
// non-blocking polling, now owned by native per-connection workers. M29 adds a
// fail-closed binding policy: non-loopback listeners are accepted only by the
// authenticated secure-transport server path.

const NETWORK_ERROR = 9026
const INVALID_ARGUMENT = 9001
const AF_INET = 2
const SOCK_STREAM = 1
const IPPROTO_TCP = 6
const INVALID_SOCKET = -1
const SOCKET_ERROR = -1
const SOCKET_ERROR_U32 = 4294967295
const SD_BOTH = 2
const WSA_VERSION_2_2 = 0x0202
const SOCKADDR_IN_SIZE = 16
const MAX_RECEIVE_BYTES = 1048576
#if TARGET_OS == "windows"
const SOL_SOCKET = 0xFFFF
const SO_REUSEADDR = 4
const WSAEWOULDBLOCK = 10035
const WSAETIMEDOUT = 10060
const FIONBIO = 0x8004667E
const SO_RCVTIMEO = 0x1006
const SO_SNDTIMEO = 0x1005
const WSAPOLLFD_SIZE = 16
const WSAPOLLFD_EVENTS_OFFSET = 8
const WSAPOLLFD_REVENTS_OFFSET = 10
const POLLRDNORM = 0x0100
const POLLWRNORM = 0x0010
const POLLNVAL = 0x0004
#else
const SOL_SOCKET = 1
const SO_REUSEADDR = 2
const WSAEWOULDBLOCK = 11
const WSAETIMEDOUT = 110
const SO_RCVTIMEO = 20
const SO_SNDTIMEO = 21
const F_GETFL = 3
const F_SETFL = 4
const O_NONBLOCK = 2048
const WSAPOLLFD_SIZE = 8
const WSAPOLLFD_EVENTS_OFFSET = 4
const WSAPOLLFD_REVENTS_OFFSET = 6
const POLLRDNORM = 0x0001
const POLLWRNORM = 0x0004
const POLLNVAL = 0x0020
#endif

#if TARGET_OS == "windows"
// Initializes WinSock for `version`, filling `wsaData` and returning its status code.
extern function WSAStartup(version as int, wsaData as bytes) from "ws2_32.dll" returns i32
// Releases one process-wide WinSock initialization reference and returns its status.
extern function WSACleanup() from "ws2_32.dll" returns i32
// Returns the calling thread's most recent WinSock error code.
extern function WSAGetLastError() from "ws2_32.dll" returns i32
// Creates a socket for the requested address family, type, and protocol.
extern function socket(af as int, type as int, protocol as int) from "ws2_32.dll" returns ptr
// Closes socket `s` and returns the raw WinSock status code.
extern function closesocket(s as ptr) from "ws2_32.dll" returns i32
// Connects socket `s` to the encoded address and returns the raw WinSock status.
extern function connect(s as ptr, addr as bytes, addrlen as i32) from "ws2_32.dll" returns i32
// Binds socket `s` to the encoded local address and returns the raw status.
extern function bind(s as ptr, addr as bytes, addrlen as i32) from "ws2_32.dll" returns i32
// Enables connection acceptance with the requested backlog and returns raw status.
extern function listen(s as ptr, backlog as i32) from "ws2_32.dll" returns i32
// Accepts one pending connection and returns its socket or INVALID_SOCKET.
extern function accept(s as ptr, addr as ptr, addrlen as ptr) from "ws2_32.dll" returns ptr
// Reads the connected peer's socket address into a caller-owned sockaddr buffer.
extern function getpeername(s as ptr, address as bytes, addressLength as bytes) from "ws2_32.dll" returns i32
// Sends up to `count` bytes from `buffer` and returns the transferred count or error.
extern function send(s as ptr, buffer as ptr, count as i32, flags as i32) from "ws2_32.dll" returns i32
// Receives up to `count` bytes into `buffer` and returns count, EOF, or error.
extern function recv(s as ptr, buffer as ptr, count as i32, flags as i32) from "ws2_32.dll" returns i32
// Disables the selected socket direction and returns the raw WinSock status.
extern function shutdown(s as ptr, how as i32) from "ws2_32.dll" returns i32
// Sets one socket option from the supplied byte representation and returns raw status.
extern function setsockopt(s as ptr, level as i32, option as i32, value as bytes, count as i32) from "ws2_32.dll" returns i32
// Converts a dotted-decimal IPv4 C string to its network-order numeric address.
extern function inet_addr(address as cstr) from "ws2_32.dll" returns u32
// Applies a socket control command using the mutable value buffer and returns raw status.
extern function ioctlsocket(s as ptr, command as u32, value as bytes) from "ws2_32.dll" returns i32
// Waits until one or more sockets become ready without relying on the Windows timer quantum.
extern function WSAPoll(descriptors as bytes, descriptorCount as u32, timeoutMs as i32) from "ws2_32.dll" returns i32
#else
// Linux uses the SysV socket ABI. The public MiniSQL API still accepts either
// integer or pointer-like handles so callers remain source-compatible.
// Creates a Linux socket descriptor for the requested address family and protocol.
extern function socket(af as int, type as int, protocol as int) from "libc.so.6" returns i32
// Closes one Linux socket descriptor.
extern function closesocket(s as int) from "libc.so.6" symbol "close" returns i32
// Connects a Linux socket to an encoded address.
extern function connect(s as int, addr as bytes, addrlen as u32) from "libc.so.6" returns i32
// Binds a Linux socket to an encoded local address.
extern function bind(s as int, addr as bytes, addrlen as u32) from "libc.so.6" returns i32
// Starts listening on a bound Linux socket.
extern function listen(s as int, backlog as i32) from "libc.so.6" returns i32
// Accepts one pending Linux connection.
extern function accept(s as int, addr as ptr, addrlen as ptr) from "libc.so.6" returns i32
// Reads the connected peer address for a Linux socket.
extern function getpeername(s as int, address as bytes, addressLength as bytes) from "libc.so.6" returns i32
// Sends a native byte range through a Linux socket.
extern function send(s as int, buffer as ptr, count as u64, flags as i32) from "libc.so.6" returns i64
// Receives a native byte range from a Linux socket.
extern function recv(s as int, buffer as ptr, count as u64, flags as i32) from "libc.so.6" returns i64
// Disables one or both directions of a Linux socket.
extern function shutdown(s as int, how as i32) from "libc.so.6" returns i32
// Applies one Linux socket option.
extern function setsockopt(s as int, level as i32, option as i32, value as bytes, count as u32) from "libc.so.6" returns i32
// Converts dotted-decimal IPv4 text to network byte order.
extern function inet_addr(address as cstr) from "libc.so.6" returns u32
// Reads or changes Linux descriptor flags.
extern function fcntl(s as int, command as i32, value as i32) from "libc.so.6" returns i32
// Polls Linux descriptors for bounded readiness.
extern function WSAPoll(descriptors as bytes, descriptorCount as u64, timeoutMs as i32) from "libc.so.6" symbol "poll" returns i32
// Returns the current thread's Linux errno address.
extern function _errnoLocation() from "libc.so.6" symbol "__errno_location" returns ptr
// Copies errno into a managed byte buffer without dereferencing raw memory in MiniLang.
extern function _copyErrno(destination as bytes, source as ptr, count as u64) from "libc.so.6" symbol "memcpy" returns ptr
#endif

_wsaReady = false

// Creates the module's structured error with operation context.
// Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.
function fail(operation, message)
  return error(NETWORK_ERROR, "platform.network." + operation + ": " + message)
end function

// Returns the current platform socket error using one stable MiniSQL call site.
function nativeError()
#if TARGET_OS == "windows"
  return WSAGetLastError()
#else
  location = _errnoLocation()
  if location == 0 then return 0 end if
  raw = bytes(4, 0)
  _copyErrno(raw, location, 4)
  return endian.readU32LE(raw, 0)
#endif
end function

// Evaluates whether the supplied input satisfies the handle predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isHandle(value)
  return typeof(value) == "int" or typeof(value) == "ptr"
end function

// WinSock C APIs return a signed 32-bit int. The native ABI writes EAX, so a
// declaration as a 64-bit MiniLang int can expose SOCKET_ERROR as 0xFFFFFFFF
// instead of -1. Correct i32 declarations are the primary contract; the dual
// sentinel check keeps the failure path closed even with an older compiler.
// Evaluates whether the supplied input satisfies the socket error result predicate.
// Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isSocketErrorResult(value)
  return value == SOCKET_ERROR or value == SOCKET_ERROR_U32
end function

// Initializes the requested value.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function initialize()
  global _wsaReady
  if _wsaReady then return true end if
#if TARGET_OS == "windows"
  data = bytes(512, 0)
  result = WSAStartup(WSA_VERSION_2_2, data)
  if result != 0 then return fail("initialize", "WSAStartup failed (" + result + ")") end if
#endif
  _wsaReady = true
  return true
end function

// Performs the cleanup operation for this module.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function cleanup()
  global _wsaReady
  if not _wsaReady then return true end if
#if TARGET_OS == "windows"
  result = WSACleanup()
  if result != 0 then return fail("cleanup", "WSACleanup failed (" + nativeError() + ")") end if
#endif
  _wsaReady = false
  return true
end function

// Validates the port.
// Inputs: `port`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.
function validatePort(port, operation)
  if typeof(port) != "int" or port < 1 or port > 65535 then return error(INVALID_ARGUMENT, "platform.network." + operation + ": port must be 1..65535") end if
  return true
end function

// Performs the sockaddr operation for this module.
// Inputs: `ip`, `port`. Returns the produced value or propagates a structured error from validation or delegated operations.
function sockaddr(ip, port)
  address = bytes(SOCKADDR_IN_SIZE, 0)
  address[0] = AF_INET
  address[1] = 0
  address[2] = (port >> 8) & 255
  address[3] = port & 255
  address[4] = ip & 255
  address[5] = (ip >> 8) & 255
  address[6] = (ip >> 16) & 255
  address[7] = (ip >> 24) & 255
  return address
end function

// Parses the ipv4.
// Inputs: `host`. Returns the produced value or propagates a structured error from validation or delegated operations.
function parseIPv4(host)
  if typeof(host) != "string" or len(host) == 0 then return error(INVALID_ARGUMENT, "platform.network.parseIPv4: host must be string") end if
  value = host
  if value == "localhost" then value = "127.0.0.1" end if
  ip = inet_addr(value)
  if ip == 0xFFFFFFFF and value != "255.255.255.255" then return fail("parseIPv4", "invalid IPv4 address") end if
  return ip
end function

// Performs the connect tcp operation for this module.
// Inputs: `host`, `port`. Returns the produced value or propagates a structured error from validation or delegated operations.
function connectTcp(host, port)
  initialize()
  validatePort(port, "connectTcp")
  ip = parseIPv4(host)
  handle = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
  if handle == INVALID_SOCKET then return fail("connectTcp", "socket failed (" + nativeError() + ")") end if
  address = sockaddr(ip, port)
  result = connect(handle, address, len(address))
  if result != 0 then
    code = nativeError()
    closesocket(handle)
    return fail("connectTcp", "connect failed (" + code + ")")
  end if
  return handle
end function

// Evaluates whether the supplied input satisfies the loopback address predicate.
// Inputs: `address`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isLoopbackAddress(address)
  return address == "127.0.0.1" or address == "localhost"
end function

// Performs the listen address operation for this module.
// Inputs: `addressText`, `port`, `backlog`, `allowRemote`. Returns the produced value or propagates a structured error from validation or delegated operations.
function listenAddress(addressText, port, backlog, allowRemote)
  initialize()
  validatePort(port, "listenAddress")
  if typeof(addressText) != "string" or len(addressText) == 0 then return error(INVALID_ARGUMENT, "platform.network.listenAddress: address must be non-empty") end if
  if typeof(allowRemote) != "bool" then return error(INVALID_ARGUMENT, "platform.network.listenAddress: allowRemote must be bool") end if
  if not allowRemote and not isLoopbackAddress(addressText) then return error(INVALID_ARGUMENT, "platform.network.listenAddress: remote binding requires secure transport") end if
  if typeof(backlog) != "int" or backlog < 1 or backlog > 128 then backlog = 16 end if
  ip = parseIPv4(addressText)
  handle = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
  if handle == INVALID_SOCKET then return fail("listenAddress", "socket failed (" + nativeError() + ")") end if
  option = bytes(4, 0)
  option[0] = 1
  ignored = setsockopt(handle, SOL_SOCKET, SO_REUSEADDR, option, 4)
  address = sockaddr(ip, port)
  result = bind(handle, address, len(address))
  if result != 0 then
    code = nativeError()
    closesocket(handle)
    return fail("listenAddress", "bind failed (" + code + ")")
  end if
  result = listen(handle, backlog)
  if result != 0 then
    code = nativeError()
    closesocket(handle)
    return fail("listenAddress", "listen failed (" + code + ")")
  end if
  return handle
end function

// Performs the listen loopback operation for this module.
// Inputs: `port`, `backlog`. Returns the produced value or propagates a structured error from validation or delegated operations.
function listenLoopback(port, backlog)
  return listenAddress("127.0.0.1", port, backlog, false)
end function

// Updates the non blocking.
// Inputs: `handle`, `enabled`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function setNonBlocking(handle, enabled)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.setNonBlocking: handle must be socket") end if
  if typeof(enabled) != "bool" then return error(INVALID_ARGUMENT, "platform.network.setNonBlocking: enabled must be bool") end if
#if TARGET_OS == "windows"
  mode = bytes(4, 0)
  if enabled then mode[0] = 1 end if
  result = ioctlsocket(handle, FIONBIO, mode)
  if result != 0 then return fail("setNonBlocking", "ioctlsocket failed (" + nativeError() + ")") end if
#else
  flags = fcntl(handle, F_GETFL, 0)
  if flags < 0 then return fail("setNonBlocking", "fcntl(F_GETFL) failed (" + nativeError() + ")") end if
  if enabled then flags = flags | O_NONBLOCK else flags = flags & ~O_NONBLOCK end if
  if fcntl(handle, F_SETFL, flags) != 0 then return fail("setNonBlocking", "fcntl(F_SETFL) failed (" + nativeError() + ")") end if
#endif
  return true
end function

// Updates the timeouts.
// Inputs: `handle`, `receiveMs`, `sendMs`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function setTimeouts(handle, receiveMs, sendMs)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.setTimeouts: handle must be socket") end if
  if typeof(receiveMs) != "int" or receiveMs < 0 or receiveMs > 3600000 then return error(INVALID_ARGUMENT, "platform.network.setTimeouts: receive timeout is invalid") end if
  if typeof(sendMs) != "int" or sendMs < 0 or sendMs > 3600000 then return error(INVALID_ARGUMENT, "platform.network.setTimeouts: send timeout is invalid") end if
  receiveValue = bytes(4, 0)
  sendValue = bytes(4, 0)
#if TARGET_OS == "windows"
  receiveValue[0] = receiveMs & 255
  receiveValue[1] = (receiveMs >> 8) & 255
  receiveValue[2] = (receiveMs >> 16) & 255
  receiveValue[3] = (receiveMs >> 24) & 255
  sendValue[0] = sendMs & 255
  sendValue[1] = (sendMs >> 8) & 255
  sendValue[2] = (sendMs >> 16) & 255
  sendValue[3] = (sendMs >> 24) & 255
#else
  receiveValue = bytes(16, 0)
  sendValue = bytes(16, 0)
  receiveSeconds = receiveMs / 1000
  sendSeconds = sendMs / 1000
  endian.writeU64LE(receiveValue, 0, endian.uint64FromInt(receiveSeconds))
  endian.writeU64LE(receiveValue, 8, endian.uint64FromInt((receiveMs % 1000) * 1000))
  endian.writeU64LE(sendValue, 0, endian.uint64FromInt(sendSeconds))
  endian.writeU64LE(sendValue, 8, endian.uint64FromInt((sendMs % 1000) * 1000))
#endif
  if setsockopt(handle, SOL_SOCKET, SO_RCVTIMEO, receiveValue, len(receiveValue)) != 0 then return fail("setTimeouts", "SO_RCVTIMEO failed (" + nativeError() + ")") end if
  if setsockopt(handle, SOL_SOCKET, SO_SNDTIMEO, sendValue, len(sendValue)) != 0 then return fail("setTimeouts", "SO_SNDTIMEO failed (" + nativeError() + ")") end if
  return true
end function

// Performs the try accept operation for this module.
// Inputs: `listener`. Returns the produced value or propagates a structured error from validation or delegated operations.
function tryAccept(listener)
  if not isHandle(listener) then return error(INVALID_ARGUMENT, "platform.network.tryAccept: listener must be socket handle") end if
  client = accept(listener, void, void)
  if client == INVALID_SOCKET then
    code = nativeError()
    if code == WSAEWOULDBLOCK then return void end if
    return fail("tryAccept", "accept failed (" + code + ")")
  end if
  return client
end function

// Waits for one socket event using WinSock's readiness primitive. A timeout is
// reported as false; readiness, hangup, and socket errors are reported as true
// so the caller can perform the operation and receive its precise outcome.
function waitSocket(handle, events, timeoutMs, operation)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network." + operation + ": handle must be socket") end if
  if typeof(events) != "int" or events <= 0 or events > 65535 then return error(INVALID_ARGUMENT, "platform.network." + operation + ": events are invalid") end if
  if typeof(timeoutMs) != "int" or timeoutMs < 0 or timeoutMs > 60000 then return error(INVALID_ARGUMENT, "platform.network." + operation + ": timeout is invalid") end if
  descriptor = bytes(WSAPOLLFD_SIZE, 0)
#if TARGET_OS == "windows"
  endian.writeU64LE(descriptor, 0, endian.uint64FromInt(handle))
#else
  endian.writeU32LE(descriptor, 0, handle)
#endif
  endian.writeU16LE(descriptor, WSAPOLLFD_EVENTS_OFFSET, events)
  result = WSAPoll(descriptor, 1, timeoutMs)
  if isSocketErrorResult(result) then return fail(operation, "poll failed (" + nativeError() + ")") end if
  if result == 0 then return false end if
  if result != 1 then return fail(operation, "WSAPoll returned invalid descriptor count " + result) end if
  returnedEvents = endian.readU16LE(descriptor, WSAPOLLFD_REVENTS_OFFSET)
  if (returnedEvents & POLLNVAL) != 0 then return fail(operation, "WSAPoll rejected the socket") end if
  return returnedEvents != 0
end function

// Blocks for at most timeoutMs until recv or accept can make progress.
function waitReadable(handle, timeoutMs)
  return waitSocket(handle, POLLRDNORM, timeoutMs, "waitReadable")
end function

// Blocks for at most timeoutMs until send can make progress.
function waitWritable(handle, timeoutMs)
  return waitSocket(handle, POLLWRNORM, timeoutMs, "waitWritable")
end function

// Performs the accept tcp operation for this module.
// Inputs: `listener`. Returns the produced value or propagates a structured error from validation or delegated operations.
function acceptTcp(listener)
  if not isHandle(listener) then return error(INVALID_ARGUMENT, "platform.network.acceptTcp: listener must be socket handle") end if
  client = accept(listener, void, void)
  if client == INVALID_SOCKET then return fail("acceptTcp", "accept failed (" + nativeError() + ")") end if
  return client
end function

// Formats the connected IPv4 peer as `address:port` for operational logging.
// Inputs: `handle`. Returns the peer endpoint or `unknown` when WinSock cannot expose it.
function peerName(handle)
  if not isHandle(handle) then return "unknown" end if
  address = bytes(SOCKADDR_IN_SIZE, 0)
  addressLength = bytes(4, 0)
  addressLength[0] = SOCKADDR_IN_SIZE
  if getpeername(handle, address, addressLength) != 0 then return "unknown" end if
  if address[0] != AF_INET or addressLength[0] < SOCKADDR_IN_SIZE then return "unknown" end if
  port = (address[2] << 8) | address[3]
  return "" + address[4] + "." + address[5] + "." + address[6] + "." + address[7] + ":" + port
end function

// Copies the byte range.
// Inputs: `source`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function copyByteRange(source, offset, count, operation)
  if typeof(source) != "bytes" then return error(INVALID_ARGUMENT, "platform.network." + operation + ": source must be bytes") end if
  if typeof(offset) != "int" or typeof(count) != "int" or offset < 0 or count < 0 or offset > len(source) - count then
    return error(INVALID_ARGUMENT, "platform.network." + operation + ": byte range is invalid")
  end if
  if offset == 0 and count == len(source) then return source end if
  output = bytes(count, 0)
  if count > 0 then copyBytes(output, 0, source, offset, count) end if
  return output
end function

// Performs the byte pointer operation for this module.
// Inputs: `source`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
function bytePointer(source, offset, count, operation)
  if typeof(source) != "bytes" then return error(INVALID_ARGUMENT, "platform.network." + operation + ": buffer must be bytes") end if
  if typeof(offset) != "int" or typeof(count) != "int" or offset < 0 or count < 0 or offset > len(source) - count then
    return error(INVALID_ARGUMENT, "platform.network." + operation + ": byte range is invalid")
  end if
  if count == 0 then return 0 end if
  pointer = nativeBytesPtr(source)
  if pointer == 0 then return fail(operation, "native byte pointer is unavailable") end if
  return pointer + offset
end function

// Performs the send all operation for this module.
// Inputs: `handle`, `data`. Returns the produced value or propagates a structured error from validation or delegated operations.
function sendAll(handle, data)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.sendAll: handle must be socket") end if
  if typeof(data) == "string" then data = bytes(data) end if
  if typeof(data) != "bytes" then return error(INVALID_ARGUMENT, "platform.network.sendAll: data must be bytes or string") end if
  dataLength = len(data)
  if dataLength == 0 then return 0 end if
  basePointer = try(bytePointer(data, 0, dataLength, "sendAll"))
  if typeof(basePointer) == "error" then return basePointer end if
  total = 0
  waits = 0
  while total < dataLength
    remaining = dataLength - total
    written = send(handle, basePointer + total, remaining, 0)
    if isSocketErrorResult(written) then
      code = nativeError()
      if code == WSAEWOULDBLOCK then
        writable = try(waitWritable(handle, 1000))
        if typeof(writable) == "error" then return writable end if
        if not writable then
          waits = waits + 1
          if waits >= 30 then return fail("sendAll", "send timed out") end if
        end if
        continue
      end if
      return fail("sendAll", "send failed (" + code + ")")
    end if
    if written <= 0 then return fail("sendAll", "connection closed during send") end if
    if written > remaining then return fail("sendAll", "send returned more bytes than requested") end if
    total = total + written
    waits = 0
  end while
  return total
end function

// Performs the receive operation for this module.
// Inputs: `handle`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.
function receive(handle, maximum)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.receive: handle must be socket") end if
  if typeof(maximum) != "int" or maximum < 0 or maximum > MAX_RECEIVE_BYTES then return error(INVALID_ARGUMENT, "platform.network.receive: invalid maximum") end if
  if maximum == 0 then return bytes(0) end if
  buffer = bytes(maximum, 0)
  pointer = try(bytePointer(buffer, 0, maximum, "receive"))
  if typeof(pointer) == "error" then return pointer end if
  count = recv(handle, pointer, maximum, 0)
  if count == 0 then return bytes(0) end if
  if isSocketErrorResult(count) then return fail("receive", "recv failed (" + nativeError() + ")") end if
  if count < 0 or count > maximum then return fail("receive", "recv returned invalid byte count " + count + " for maximum " + maximum) end if
  if count == maximum then return buffer end if
  return copyByteRange(buffer, 0, count, "receive")
end function

// Performs the receive available into operation for this module.
// Inputs: `handle`, `target`, `offset`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.
function receiveAvailableInto(handle, target, offset, maximum)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.receiveAvailableInto: handle must be socket") end if
  if typeof(target) != "bytes" then return error(INVALID_ARGUMENT, "platform.network.receiveAvailableInto: target must be bytes") end if
  if typeof(offset) != "int" or typeof(maximum) != "int" or offset < 0 or maximum < 1 or maximum > MAX_RECEIVE_BYTES or offset > len(target) - maximum then
    return error(INVALID_ARGUMENT, "platform.network.receiveAvailableInto: target range is invalid")
  end if
  pointer = try(bytePointer(target, offset, maximum, "receiveAvailableInto"))
  if typeof(pointer) == "error" then return pointer end if
  count = recv(handle, pointer, maximum, 0)
  if count == 0 then return 0 end if
  if isSocketErrorResult(count) then
    code = nativeError()
    if code == WSAEWOULDBLOCK then return void end if
    return fail("receiveAvailableInto", "recv failed (" + code + ")")
  end if
  if count < 0 or count > maximum then return fail("receiveAvailableInto", "recv returned invalid byte count " + count + " for maximum " + maximum) end if
  return count
end function

// Performs the receive available operation for this module.
// Inputs: `handle`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.
function receiveAvailable(handle, maximum)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.receiveAvailable: handle must be socket") end if
  if typeof(maximum) != "int" or maximum < 1 or maximum > MAX_RECEIVE_BYTES then return error(INVALID_ARGUMENT, "platform.network.receiveAvailable: invalid maximum") end if
  buffer = bytes(maximum, 0)
  count = try(receiveAvailableInto(handle, buffer, 0, maximum))
  if typeof(count) == "error" then return count end if
  if count is void then return void end if
  if count == 0 then return bytes(0) end if
  if count == maximum then return buffer end if
  return copyByteRange(buffer, 0, count, "receiveAvailable")
end function

// Performs the sleep milliseconds operation for this module.
// Inputs: `milliseconds`. Returns the produced value or propagates a structured error from validation or delegated operations.
function sleepMilliseconds(milliseconds)
  if typeof(milliseconds) != "int" or milliseconds < 0 or milliseconds > 60000 then return error(INVALID_ARGUMENT, "platform.network.sleepMilliseconds: invalid delay") end if
  time_api.sleep(milliseconds)
  return true
end function

// Performs the receive exact operation for this module.
// Inputs: `handle`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.
function receiveExact(handle, count)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.receiveExact: handle must be socket") end if
  if typeof(count) != "int" or count < 0 or count > MAX_RECEIVE_BYTES then return error(INVALID_ARGUMENT, "platform.network.receiveExact: invalid count") end if
  output = bytes(count, 0)
  if count == 0 then return output end if
  basePointer = try(bytePointer(output, 0, count, "receiveExact"))
  if typeof(basePointer) == "error" then return basePointer end if
  cursor = 0
  while cursor < count
    remaining = count - cursor
    received = recv(handle, basePointer + cursor, remaining, 0)
    if received == 0 then return fail("receiveExact", "connection closed before frame completed") end if
    if isSocketErrorResult(received) then return fail("receiveExact", "recv failed (" + nativeError() + ")") end if
    if received < 0 or received > remaining then return fail("receiveExact", "recv returned invalid byte count " + received + " for remaining " + remaining) end if
    cursor = cursor + received
  end while
  return output
end function

// Closes the requested value.
// Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.
function close(handle)
  if not isHandle(handle) then return error(INVALID_ARGUMENT, "platform.network.close: handle must be socket") end if
  ignored = shutdown(handle, SD_BOTH)
  result = closesocket(handle)
  if result != 0 then return fail("close", "closesocket failed (" + nativeError() + ")") end if
  return true
end function

// Returns the stable diagnostic name of this component.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "platform.network"
end function

// Returns the milestone in which this component became available.
// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M18"
end function

// Reports whether this component is implemented.
// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
