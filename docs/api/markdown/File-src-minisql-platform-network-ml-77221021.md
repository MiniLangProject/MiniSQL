# `src/minisql/platform/network.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.platform.network`](Package-minisql-platform-network-1505003583.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `std/time.ml` as `time_api` → `../MiniLangCompilerML/std/time.ml` — external dependency

## Declarations

<a id="global-global-minisql-platform-network-wsaready-wsaready-src-minisql-platform-network-ml-382545566"></a>
### _wsaReady

```ml
_wsaReady
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L135)

<a id="extern_function-extern-function-minisql-platform-network-accept-extern-function-accept-s-as-ptr-addr-as-ptr-addrlen-as-ptr-from-ws2-32-dll-returns-ptr-src-minisql-platform-network-ml-637482818"></a>
### accept

```ml
extern function accept(s as ptr, addr as ptr, addrlen as ptr) from "ws2_32.dll" returns ptr
```

Accepts one pending connection and returns its socket or INVALID_SOCKET.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `addr` | `ptr` | — |  |
| `addrlen` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L81)

<a id="function-function-minisql-platform-network-accepttcp-function-accepttcp-listener-src-minisql-platform-network-ml-631127028"></a>
### acceptTcp

```ml
function acceptTcp(listener)
```

Performs the accept tcp operation for this module. Inputs: `listener`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `listener` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L422)

<a id="constant-constant-minisql-platform-network-af-inet-const-af-inet-2-src-minisql-platform-network-ml-963954449"></a>
### AF_INET

```ml
const AF_INET = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L16)

<a id="extern_function-extern-function-minisql-platform-network-bind-extern-function-bind-s-as-ptr-addr-as-bytes-addrlen-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1191474847"></a>
### bind

```ml
extern function bind(s as ptr, addr as bytes, addrlen as i32) from "ws2_32.dll" returns i32
```

Binds socket `s` to the encoded local address and returns the raw status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `addr` | `bytes` | — |  |
| `addrlen` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L77)

<a id="function-function-minisql-platform-network-bytepointer-function-bytepointer-source-offset-count-operation-src-minisql-platform-network-ml-1574749322"></a>
### bytePointer

```ml
function bytePointer(source, offset, count, operation)
```

Performs the byte pointer operation for this module. Inputs: `source`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L462)

<a id="function-function-minisql-platform-network-cleanup-function-cleanup-src-minisql-platform-network-ml-149556102"></a>
### cleanup

```ml
function cleanup()
```

Performs the cleanup operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L188)

<a id="function-function-minisql-platform-network-close-function-close-handle-src-minisql-platform-network-ml-1253226388"></a>
### close

```ml
function close(handle)
```

Closes the requested value. Inputs: `handle`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L621)

<a id="extern_function-extern-function-minisql-platform-network-closesocket-extern-function-closesocket-s-as-ptr-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-249679793"></a>
### closesocket

```ml
extern function closesocket(s as ptr) from "ws2_32.dll" returns i32
```

Closes socket `s` and returns the raw WinSock status code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L73)

<a id="function-function-minisql-platform-network-componentname-function-componentname-src-minisql-platform-network-ml-728813206"></a>
### componentName

```ml
function componentName()
```

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L631)

<a id="extern_function-extern-function-minisql-platform-network-connect-extern-function-connect-s-as-ptr-addr-as-bytes-addrlen-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1523995553"></a>
### connect

```ml
extern function connect(s as ptr, addr as bytes, addrlen as i32) from "ws2_32.dll" returns i32
```

Connects socket `s` to the encoded address and returns the raw WinSock status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `addr` | `bytes` | — |  |
| `addrlen` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L75)

<a id="function-function-minisql-platform-network-connecttcp-function-connecttcp-host-port-src-minisql-platform-network-ml-373262585"></a>
### connectTcp

```ml
function connectTcp(host, port)
```

Performs the connect tcp operation for this module. Inputs: `host`, `port`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `host` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L234)

<a id="function-function-minisql-platform-network-copybyterange-function-copybyterange-source-offset-count-operation-src-minisql-platform-network-ml-2042291724"></a>
### copyByteRange

```ml
function copyByteRange(source, offset, count, operation)
```

Copies the byte range. Inputs: `source`, `offset`, `count`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L449)

<a id="function-function-minisql-platform-network-fail-function-fail-operation-message-src-minisql-platform-network-ml-759550238"></a>
### fail

```ml
function fail(operation, message)
```

Creates the module's structured error with operation context. Inputs: `operation`, `message`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L139)

<a id="constant-constant-minisql-platform-network-fionbio-const-fionbio-2147772030-src-minisql-platform-network-ml-666877702"></a>
### FIONBIO

```ml
const FIONBIO = 2147772030
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L35)

<a id="extern_function-extern-function-minisql-platform-network-getpeername-extern-function-getpeername-s-as-ptr-address-as-bytes-addresslength-as-bytes-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-669860397"></a>
### getpeername

```ml
extern function getpeername(s as ptr, address as bytes, addressLength as bytes) from "ws2_32.dll" returns i32
```

Reads the connected peer's socket address into a caller-owned sockaddr buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `address` | `bytes` | — |  |
| `addressLength` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L83)

<a id="extern_function-extern-function-minisql-platform-network-inet-addr-extern-function-inet-addr-address-as-cstr-from-ws2-32-dll-returns-u32-src-minisql-platform-network-ml-2072485030"></a>
### inet_addr

```ml
extern function inet_addr(address as cstr) from "ws2_32.dll" returns u32
```

Converts a dotted-decimal IPv4 C string to its network-order numeric address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `cstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L93)

<a id="function-function-minisql-platform-network-initialize-function-initialize-src-minisql-platform-network-ml-852932366"></a>
### initialize

```ml
function initialize()
```

Initializes the requested value. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L174)

<a id="constant-constant-minisql-platform-network-invalid-argument-const-invalid-argument-9001-src-minisql-platform-network-ml-686428619"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L15)

<a id="constant-constant-minisql-platform-network-invalid-socket-const-invalid-socket-1-src-minisql-platform-network-ml-1298464719"></a>
### INVALID_SOCKET

```ml
const INVALID_SOCKET = -1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L20)

<a id="extern_function-extern-function-minisql-platform-network-ioctlsocket-extern-function-ioctlsocket-s-as-ptr-command-as-u32-value-as-bytes-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1539112774"></a>
### ioctlsocket

```ml
extern function ioctlsocket(s as ptr, command as u32, value as bytes) from "ws2_32.dll" returns i32
```

Applies a socket control command using the mutable value buffer and returns raw status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `command` | `u32` | — |  |
| `value` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L95)

<a id="constant-constant-minisql-platform-network-ipproto-tcp-const-ipproto-tcp-6-src-minisql-platform-network-ml-950989053"></a>
### IPPROTO_TCP

```ml
const IPPROTO_TCP = 6
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L18)

<a id="function-function-minisql-platform-network-ishandle-function-ishandle-value-src-minisql-platform-network-ml-1798977803"></a>
### isHandle

```ml
function isHandle(value)
```

Evaluates whether the supplied input satisfies the handle predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L158)

<a id="function-function-minisql-platform-network-isimplemented-function-isimplemented-src-minisql-platform-network-ml-1704641518"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L643)

<a id="function-function-minisql-platform-network-isloopbackaddress-function-isloopbackaddress-address-src-minisql-platform-network-ml-190175454"></a>
### isLoopbackAddress

```ml
function isLoopbackAddress(address)
```

Evaluates whether the supplied input satisfies the loopback address predicate. Inputs: `address`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L257)

<a id="function-function-minisql-platform-network-issocketerrorresult-function-issocketerrorresult-value-src-minisql-platform-network-ml-1054173403"></a>
### isSocketErrorResult

```ml
function isSocketErrorResult(value)
```

WinSock C APIs return a signed 32-bit int. The native ABI writes EAX, so a declaration as a 64-bit MiniLang int can expose SOCKET_ERROR as 0xFFFFFFFF instead of -1. Correct i32 declarations are the primary contract; the dual sentinel check keeps the failure path closed even with an older compiler. Evaluates whether the supplied input satisfies the socket error result predicate. Inputs: `value`. Returns a boolean result; invalid input or delegated failures are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L168)

<a id="extern_function-extern-function-minisql-platform-network-listen-extern-function-listen-s-as-ptr-backlog-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1293482646"></a>
### listen

```ml
extern function listen(s as ptr, backlog as i32) from "ws2_32.dll" returns i32
```

Enables connection acceptance with the requested backlog and returns raw status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `backlog` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L79)

<a id="function-function-minisql-platform-network-listenaddress-function-listenaddress-addresstext-port-backlog-allowremote-src-minisql-platform-network-ml-1132975104"></a>
### listenAddress

```ml
function listenAddress(addressText, port, backlog, allowRemote)
```

Performs the listen address operation for this module. Inputs: `addressText`, `port`, `backlog`, `allowRemote`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `addressText` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `backlog` | `dynamic` | — |  |
| `allowRemote` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L263)

<a id="function-function-minisql-platform-network-listenloopback-function-listenloopback-port-backlog-src-minisql-platform-network-ml-69025742"></a>
### listenLoopback

```ml
function listenLoopback(port, backlog)
```

Performs the listen loopback operation for this module. Inputs: `port`, `backlog`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |
| `backlog` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L294)

<a id="constant-constant-minisql-platform-network-max-receive-bytes-const-max-receive-bytes-16777216-src-minisql-platform-network-ml-747062582"></a>
### MAX_RECEIVE_BYTES

```ml
const MAX_RECEIVE_BYTES = 16777216
```

Matches the protocol's exceptional-frame guard. Ordinary polling remains fixed at small chunks; only an already validated wide frame allocates more.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L28)

<a id="function-function-minisql-platform-network-nativeerror-function-nativeerror-src-minisql-platform-network-ml-1988482312"></a>
### nativeError

```ml
function nativeError()
```

Returns the current platform socket error using one stable MiniSQL call site.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L144)

<a id="constant-constant-minisql-platform-network-network-error-const-network-error-9026-src-minisql-platform-network-ml-1697521808"></a>
### NETWORK_ERROR

```ml
const NETWORK_ERROR = 9026
```

Native IPv4/TCP wrapper used by MiniSQL clients and servers. M27 adds bounded non-blocking polling, now owned by native per-connection workers. M29 adds a fail-closed binding policy: non-loopback listeners are accepted only by the authenticated secure-transport server path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L14)

<a id="function-function-minisql-platform-network-parseipv4-function-parseipv4-host-src-minisql-platform-network-ml-1693356196"></a>
### parseIPv4

```ml
function parseIPv4(host)
```

Parses the ipv4. Inputs: `host`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `host` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L223)

<a id="function-function-minisql-platform-network-peername-function-peername-handle-src-minisql-platform-network-ml-1957136116"></a>
### peerName

```ml
function peerName(handle)
```

Formats the connected IPv4 peer as `address:port` for operational logging. Inputs: `handle`. Returns the peer endpoint or `unknown` when WinSock cannot expose it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L436)

<a id="constant-constant-minisql-platform-network-pollnval-const-pollnval-4-src-minisql-platform-network-ml-1317257553"></a>
### POLLNVAL

```ml
const POLLNVAL = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L43)

<a id="constant-constant-minisql-platform-network-pollrdnorm-const-pollrdnorm-256-src-minisql-platform-network-ml-624099734"></a>
### POLLRDNORM

```ml
const POLLRDNORM = 256
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L41)

<a id="constant-constant-minisql-platform-network-pollwrnorm-const-pollwrnorm-16-src-minisql-platform-network-ml-2074260740"></a>
### POLLWRNORM

```ml
const POLLWRNORM = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L42)

<a id="function-function-minisql-platform-network-receive-function-receive-handle-maximum-src-minisql-platform-network-ml-784968890"></a>
### receive

```ml
function receive(handle, maximum)
```

Performs the receive operation for this module. Inputs: `handle`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `maximum` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L512)

<a id="function-function-minisql-platform-network-receiveavailable-function-receiveavailable-handle-maximum-src-minisql-platform-network-ml-1611641180"></a>
### receiveAvailable

```ml
function receiveAvailable(handle, maximum)
```

Performs the receive available operation for this module. Inputs: `handle`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `maximum` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L563)

<a id="function-function-minisql-platform-network-receiveavailableinto-function-receiveavailableinto-handle-target-offset-maximum-src-minisql-platform-network-ml-405529530"></a>
### receiveAvailableInto

```ml
function receiveAvailableInto(handle, target, offset, maximum)
```

Performs the receive available into operation for this module. Inputs: `handle`, `target`, `offset`, `maximum`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `maximum` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L542)

<a id="function-function-minisql-platform-network-receiveexact-function-receiveexact-handle-count-src-minisql-platform-network-ml-1381227991"></a>
### receiveExact

```ml
function receiveExact(handle, count)
```

Performs the receive exact operation for this module. Inputs: `handle`, `count`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L585)

<a id="extern_function-extern-function-minisql-platform-network-recv-extern-function-recv-s-as-ptr-buffer-as-ptr-count-as-i32-flags-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-318505027"></a>
### recv

```ml
extern function recv(s as ptr, buffer as ptr, count as i32, flags as i32) from "ws2_32.dll" returns i32
```

Receives up to `count` bytes into `buffer` and returns count, EOF, or error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `buffer` | `ptr` | — |  |
| `count` | `i32` | — |  |
| `flags` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L87)

<a id="constant-constant-minisql-platform-network-sd-both-const-sd-both-2-src-minisql-platform-network-ml-321700665"></a>
### SD_BOTH

```ml
const SD_BOTH = 2
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L23)

<a id="extern_function-extern-function-minisql-platform-network-send-extern-function-send-s-as-ptr-buffer-as-ptr-count-as-i32-flags-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-818922523"></a>
### send

```ml
extern function send(s as ptr, buffer as ptr, count as i32, flags as i32) from "ws2_32.dll" returns i32
```

Sends up to `count` bytes from `buffer` and returns the transferred count or error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `buffer` | `ptr` | — |  |
| `count` | `i32` | — |  |
| `flags` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L85)

<a id="function-function-minisql-platform-network-sendall-function-sendall-handle-data-src-minisql-platform-network-ml-1056111426"></a>
### sendAll

```ml
function sendAll(handle, data)
```

Performs the send all operation for this module. Inputs: `handle`, `data`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `data` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L475)

<a id="function-function-minisql-platform-network-setnodelay-function-setnodelay-handle-enabled-src-minisql-platform-network-ml-1732801609"></a>
### setNoDelay

```ml
function setNoDelay(handle, enabled)
```

Controls Nagle coalescing on an established TCP stream. MiniSQL exchanges request/response frames synchronously, so delaying a small TLS record until a later packet arrives can add an entire delayed-ACK interval to every query.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L320)

<a id="function-function-minisql-platform-network-setnonblocking-function-setnonblocking-handle-enabled-src-minisql-platform-network-ml-93833109"></a>
### setNonBlocking

```ml
function setNonBlocking(handle, enabled)
```

Updates the non blocking. Inputs: `handle`, `enabled`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `enabled` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L300)

<a id="extern_function-extern-function-minisql-platform-network-setsockopt-extern-function-setsockopt-s-as-ptr-level-as-i32-option-as-i32-value-as-bytes-count-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-2049212671"></a>
### setsockopt

```ml
extern function setsockopt(s as ptr, level as i32, option as i32, value as bytes, count as i32) from "ws2_32.dll" returns i32
```

Sets one socket option from the supplied byte representation and returns raw status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `level` | `i32` | — |  |
| `option` | `i32` | — |  |
| `value` | `bytes` | — |  |
| `count` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L91)

<a id="function-function-minisql-platform-network-settimeouts-function-settimeouts-handle-receivems-sendms-src-minisql-platform-network-ml-1592409255"></a>
### setTimeouts

```ml
function setTimeouts(handle, receiveMs, sendMs)
```

Updates the timeouts. Inputs: `handle`, `receiveMs`, `sendMs`. Returns the operation result and propagates validation, storage, or platform errors unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `receiveMs` | `dynamic` | — |  |
| `sendMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L333)

<a id="extern_function-extern-function-minisql-platform-network-shutdown-extern-function-shutdown-s-as-ptr-how-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1161336717"></a>
### shutdown

```ml
extern function shutdown(s as ptr, how as i32) from "ws2_32.dll" returns i32
```

Disables the selected socket direction and returns the raw WinSock status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `ptr` | — |  |
| `how` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L89)

<a id="function-function-minisql-platform-network-sleepmilliseconds-function-sleepmilliseconds-milliseconds-src-minisql-platform-network-ml-820819690"></a>
### sleepMilliseconds

```ml
function sleepMilliseconds(milliseconds)
```

Performs the sleep milliseconds operation for this module. Inputs: `milliseconds`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L577)

<a id="constant-constant-minisql-platform-network-so-rcvtimeo-const-so-rcvtimeo-4102-src-minisql-platform-network-ml-1950812196"></a>
### SO_RCVTIMEO

```ml
const SO_RCVTIMEO = 4102
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L36)

<a id="constant-constant-minisql-platform-network-so-reuseaddr-const-so-reuseaddr-4-src-minisql-platform-network-ml-1416813361"></a>
### SO_REUSEADDR

```ml
const SO_REUSEADDR = 4
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L31)

<a id="constant-constant-minisql-platform-network-so-sndtimeo-const-so-sndtimeo-4101-src-minisql-platform-network-ml-1443990633"></a>
### SO_SNDTIMEO

```ml
const SO_SNDTIMEO = 4101
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L37)

<a id="constant-constant-minisql-platform-network-sock-stream-const-sock-stream-1-src-minisql-platform-network-ml-1608291144"></a>
### SOCK_STREAM

```ml
const SOCK_STREAM = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L17)

<a id="function-function-minisql-platform-network-sockaddr-function-sockaddr-ip-port-src-minisql-platform-network-ml-2029227372"></a>
### sockaddr

```ml
function sockaddr(ip, port)
```

Performs the sockaddr operation for this module. Inputs: `ip`, `port`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ip` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L208)

<a id="constant-constant-minisql-platform-network-sockaddr-in-size-const-sockaddr-in-size-16-src-minisql-platform-network-ml-1884587934"></a>
### SOCKADDR_IN_SIZE

```ml
const SOCKADDR_IN_SIZE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L25)

<a id="extern_function-extern-function-minisql-platform-network-socket-extern-function-socket-af-as-int-type-as-int-protocol-as-int-from-ws2-32-dll-returns-ptr-src-minisql-platform-network-ml-953660002"></a>
### socket

```ml
extern function socket(af as int, type as int, protocol as int) from "ws2_32.dll" returns ptr
```

Creates a socket for the requested address family, type, and protocol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `af` | `int` | — |  |
| `type` | `int` | — |  |
| `protocol` | `int` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L71)

<a id="constant-constant-minisql-platform-network-socket-error-const-socket-error-1-src-minisql-platform-network-ml-1892669213"></a>
### SOCKET_ERROR

```ml
const SOCKET_ERROR = -1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L21)

<a id="constant-constant-minisql-platform-network-socket-error-u32-const-socket-error-u32-4294967295-src-minisql-platform-network-ml-271948714"></a>
### SOCKET_ERROR_U32

```ml
const SOCKET_ERROR_U32 = 4294967295
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L22)

<a id="constant-constant-minisql-platform-network-sol-socket-const-sol-socket-65535-src-minisql-platform-network-ml-147674257"></a>
### SOL_SOCKET

```ml
const SOL_SOCKET = 65535
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L30)

<a id="function-function-minisql-platform-network-targetmilestone-function-targetmilestone-src-minisql-platform-network-ml-1797955496"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L637)

<a id="constant-constant-minisql-platform-network-tcp-nodelay-const-tcp-nodelay-1-src-minisql-platform-network-ml-1632957908"></a>
### TCP_NODELAY

```ml
const TCP_NODELAY = 1
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L19)

<a id="function-function-minisql-platform-network-tryaccept-function-tryaccept-listener-src-minisql-platform-network-ml-1910530716"></a>
### tryAccept

```ml
function tryAccept(listener)
```

Performs the try accept operation for this module. Inputs: `listener`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `listener` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L365)

<a id="function-function-minisql-platform-network-validateport-function-validateport-port-operation-src-minisql-platform-network-ml-1701037488"></a>
### validatePort

```ml
function validatePort(port, operation)
```

Validates the port. Inputs: `port`, `operation`. Returns success after all invariants hold; violations are reported as structured errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L201)

<a id="function-function-minisql-platform-network-waitreadable-function-waitreadable-handle-timeoutms-src-minisql-platform-network-ml-1556400899"></a>
### waitReadable

```ml
function waitReadable(handle, timeoutMs)
```

Blocks for at most timeoutMs until recv or accept can make progress.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `timeoutMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L411)

<a id="function-function-minisql-platform-network-waitsocket-function-waitsocket-handle-events-timeoutms-operation-src-minisql-platform-network-ml-1410526323"></a>
### waitSocket

```ml
function waitSocket(handle, events, timeoutMs, operation)
```

Waits for one socket event using WinSock's readiness primitive. A timeout is reported as false; readiness, hangup, and socket errors are reported as true so the caller can perform the operation and receive its precise outcome.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `events` | `dynamic` | — |  |
| `timeoutMs` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L384)

<a id="function-function-minisql-platform-network-waitwritable-function-waitwritable-handle-timeoutms-src-minisql-platform-network-ml-1143434895"></a>
### waitWritable

```ml
function waitWritable(handle, timeoutMs)
```

Blocks for at most timeoutMs until send can make progress.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `timeoutMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L416)

<a id="constant-constant-minisql-platform-network-wsa-version-2-2-const-wsa-version-2-2-514-src-minisql-platform-network-ml-337835905"></a>
### WSA_VERSION_2_2

```ml
const WSA_VERSION_2_2 = 514
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L24)

<a id="extern_function-extern-function-minisql-platform-network-wsacleanup-extern-function-wsacleanup-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1994350772"></a>
### WSACleanup

```ml
extern function WSACleanup() from "ws2_32.dll" returns i32
```

Releases one process-wide WinSock initialization reference and returns its status.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L67)

<a id="constant-constant-minisql-platform-network-wsaeintr-const-wsaeintr-10004-src-minisql-platform-network-ml-1229319184"></a>
### WSAEINTR

```ml
const WSAEINTR = 10004
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L32)

<a id="constant-constant-minisql-platform-network-wsaetimedout-const-wsaetimedout-10060-src-minisql-platform-network-ml-1260522006"></a>
### WSAETIMEDOUT

```ml
const WSAETIMEDOUT = 10060
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L34)

<a id="constant-constant-minisql-platform-network-wsaewouldblock-const-wsaewouldblock-10035-src-minisql-platform-network-ml-1199707562"></a>
### WSAEWOULDBLOCK

```ml
const WSAEWOULDBLOCK = 10035
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L33)

<a id="extern_function-extern-function-minisql-platform-network-wsagetlasterror-extern-function-wsagetlasterror-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-756205770"></a>
### WSAGetLastError

```ml
extern function WSAGetLastError() from "ws2_32.dll" returns i32
```

Returns the calling thread's most recent WinSock error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L69)

<a id="extern_function-extern-function-minisql-platform-network-wsapoll-extern-function-wsapoll-descriptors-as-bytes-descriptorcount-as-u32-timeoutms-as-i32-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-1238941998"></a>
### WSAPoll

```ml
extern function WSAPoll(descriptors as bytes, descriptorCount as u32, timeoutMs as i32) from "ws2_32.dll" returns i32
```

Waits until one or more sockets become ready without relying on the Windows timer quantum.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `descriptors` | `bytes` | — |  |
| `descriptorCount` | `u32` | — |  |
| `timeoutMs` | `i32` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L97)

<a id="constant-constant-minisql-platform-network-wsapollfd-events-offset-const-wsapollfd-events-offset-8-src-minisql-platform-network-ml-346858639"></a>
### WSAPOLLFD_EVENTS_OFFSET

```ml
const WSAPOLLFD_EVENTS_OFFSET = 8
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L39)

<a id="constant-constant-minisql-platform-network-wsapollfd-revents-offset-const-wsapollfd-revents-offset-10-src-minisql-platform-network-ml-62449098"></a>
### WSAPOLLFD_REVENTS_OFFSET

```ml
const WSAPOLLFD_REVENTS_OFFSET = 10
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L40)

<a id="constant-constant-minisql-platform-network-wsapollfd-size-const-wsapollfd-size-16-src-minisql-platform-network-ml-187370156"></a>
### WSAPOLLFD_SIZE

```ml
const WSAPOLLFD_SIZE = 16
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L38)

<a id="extern_function-extern-function-minisql-platform-network-wsastartup-extern-function-wsastartup-version-as-int-wsadata-as-bytes-from-ws2-32-dll-returns-i32-src-minisql-platform-network-ml-201676613"></a>
### WSAStartup

```ml
extern function WSAStartup(version as int, wsaData as bytes) from "ws2_32.dll" returns i32
```

Initializes WinSock for `version`, filling `wsaData` and returning its status code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `version` | `int` | — |  |
| `wsaData` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/network.ml#L65)
