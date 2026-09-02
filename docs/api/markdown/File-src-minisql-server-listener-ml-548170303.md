# `src/minisql/server/listener.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.server.listener`](Package-minisql-server-listener-1745740567.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/logger.ml` as `logger` → [src/minisql/common/logger.ml](File-src-minisql-common-logger-ml-1571638233.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/platform/file.ml` as `file_api` → [src/minisql/platform/file.ml](File-src-minisql-platform-file-ml-1202576533.md)
- `minisql/platform/network.ml` as `network` → [src/minisql/platform/network.ml](File-src-minisql-platform-network-ml-77221021.md)
- `minisql/platform/tls_schannel.ml` as `tls_schannel` → [src/minisql/platform/tls_schannel.ml](File-src-minisql-platform-tls-schannel-ml-61867785.md)
- `minisql/protocol/connection.ml` as `connection` → [src/minisql/protocol/connection.ml](File-src-minisql-protocol-connection-ml-870021768.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/server/session.ml` as `session` → [src/minisql/server/session.ml](File-src-minisql-server-session-ml-1747510267.md)
- `std/concurrent/thread_pool.ml` as `thread_pool` → `../MiniLangCompilerML/std/concurrent/thread_pool.ml` — external dependency
- `std/threading.ml` as `threading` → `../MiniLangCompilerML/std/threading.ml` — external dependency

## Declarations

<a id="function-function-minisql-server-listener-acknowledgeshutdownclose-function-acknowledgeshutdownclose-slot-src-minisql-server-listener-ml-318197754"></a>
### acknowledgeShutdownClose

```ml
function acknowledgeShutdownClose(slot)
```

Gives the SHUTDOWN caller one bounded opportunity to perform the protocol CLOSE handshake before the listener drains all workers and closes sockets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L223)

- [minisql.server.listener.ClientSlot](Type-minisql-server-listener-clientslot-439851312.md) — struct
<a id="function-function-minisql-server-listener-closeslot-function-closeslot-slot-src-minisql-server-listener-ml-1548163610"></a>
### closeSlot

```ml
function closeSlot(slot)
```

Closes slot using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L183)

<a id="function-function-minisql-server-listener-componentname-function-componentname-src-minisql-server-listener-ml-1095946470"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L971)

<a id="function-function-minisql-server-listener-concurrentclientdone-function-concurrentclientdone-state-src-minisql-server-listener-ml-858711585"></a>
### concurrentClientDone

```ml
function concurrentClientDone(state)
```

Implements concurrent client done for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L356)

- [minisql.server.listener.ConcurrentClientTask](Type-minisql-server-listener-concurrentclienttask-1848172356.md) — struct
<a id="function-function-minisql-server-listener-concurrentfinishrequest-function-concurrentfinishrequest-state-successful-src-minisql-server-listener-ml-1596887873"></a>
### concurrentFinishRequest

```ml
function concurrentFinishRequest(state, successful)
```

Completes one reservation, optionally adding it to the successful count. Updates the progress clock and returns false only when the guard is unavailable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `successful` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L378)

<a id="function-function-minisql-server-listener-concurrentregisterclient-function-concurrentregisterclient-state-src-minisql-server-listener-ml-582389233"></a>
### concurrentRegisterClient

```ml
function concurrentRegisterClient(state)
```

Implements concurrent register client for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L345)

<a id="function-function-minisql-server-listener-concurrentrequeststop-function-concurrentrequeststop-state-src-minisql-server-listener-ml-287466629"></a>
### concurrentRequestStop

```ml
function concurrentRequestStop(state)
```

Implements concurrent request stop for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L404)

<a id="function-function-minisql-server-listener-concurrentreserverequest-function-concurrentreserverequest-state-src-minisql-server-listener-ml-1490817329"></a>
### concurrentReserveRequest

```ml
function concurrentReserveRequest(state)
```

Atomically reserves capacity under the global request limit. Returns false after shutdown/failure or when handled plus in-flight work has reached the limit; a true result must be paired with `concurrentFinishRequest`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L367)

- [minisql.server.listener.ConcurrentServerState](Type-minisql-server-listener-concurrentserverstate-1147309930.md) — struct
<a id="function-function-minisql-server-listener-concurrentsetfailure-function-concurrentsetfailure-state-failure-src-minisql-server-listener-ml-1303256127"></a>
### concurrentSetFailure

```ml
function concurrentSetFailure(state, failure)
```

Implements concurrent set failure for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `failure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L391)

<a id="function-function-minisql-server-listener-concurrentshouldstop-function-concurrentshouldstop-state-src-minisql-server-listener-ml-1099758081"></a>
### concurrentShouldStop

```ml
function concurrentShouldStop(state)
```

Implements concurrent should stop for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L336)

<a id="function-function-minisql-server-listener-concurrentstatesnapshot-function-concurrentstatesnapshot-state-src-minisql-server-listener-ml-415078553"></a>
### concurrentStateSnapshot

```ml
function concurrentStateSnapshot(state)
```

Copies all shared counters and stop state while holding `guard` briefly. Returns a positional snapshot; on lock failure, the failure slot contains an error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L325)

<a id="function-function-minisql-server-listener-createconcurrentserverstate-function-createconcurrentserverstate-maximumrequests-src-minisql-server-listener-ml-714943598"></a>
### createConcurrentServerState

```ml
function createConcurrentServerState(maximumRequests)
```

Creates concurrent server state using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L319)

<a id="function-function-minisql-server-listener-errormessagefor-function-errormessagefor-request-code-text-src-minisql-server-listener-ml-143550635"></a>
### errorMessageFor

```ml
function errorMessageFor(request, code, text)
```

Creates an error for message for using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `request` | `dynamic` | — |  |
| `code` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L240)

<a id="function-function-minisql-server-listener-fail-function-fail-operation-message-src-minisql-server-listener-ml-1300106574"></a>
### fail

```ml
function fail(operation, message)
```

Creates a structured error for fail using the supplied inputs. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `operation` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L29)

<a id="constant-constant-minisql-server-listener-invalid-argument-const-invalid-argument-9001-src-minisql-server-listener-ml-1802158173"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L24)

<a id="function-function-minisql-server-listener-isimplemented-function-isimplemented-src-minisql-server-listener-ml-2104579838"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L985)

<a id="function-function-minisql-server-listener-openprepareddatabase-function-openprepareddatabase-databasepath-standby-src-minisql-server-listener-ml-2006530887"></a>
### openPreparedDatabase

```ml
function openPreparedDatabase(databasePath, standby)
```

Preserves the legacy server API with the documented 64 MiB WAL threshold.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L574)

<a id="function-function-minisql-server-listener-openprepareddatabasewithcheckpoint-function-openprepareddatabasewithcheckpoint-databasepath-standby-checkpointwalbytes-src-minisql-server-listener-ml-1402623102"></a>
### openPreparedDatabaseWithCheckpoint

```ml
function openPreparedDatabaseWithCheckpoint(databasePath, standby, checkpointWalBytes)
```

Opens and completes recovery/index preparation before a TCP listener becomes visible, preventing early clients from timing out against a bound-but-unready port.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L542)

<a id="function-function-minisql-server-listener-openprepareddatabasewithoperationallimits-function-openprepareddatabasewithoperationallimits-databasepath-standby-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-querytimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-listener-ml-357069532"></a>
### openPreparedDatabaseWithOperationalLimits

```ml
function openPreparedDatabaseWithOperationalLimits(databasePath, standby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, queryTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Opens, prepares, and applies the hard per-connection operational limits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |
| `maxStatementBytes` | `dynamic` | — |  |
| `maxFrameBytes` | `dynamic` | — |  |
| `maxResultRows` | `dynamic` | — |  |
| `maxResultBytes` | `dynamic` | — |  |
| `idleTimeoutMs` | `dynamic` | — |  |
| `queryTimeoutMs` | `dynamic` | — |  |
| `processMemoryBytes` | `dynamic` | — |  |
| `temporaryStorageBytes` | `dynamic` | — |  |
| `slowQueryMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L563)

<a id="function-function-minisql-server-listener-openprepareddatabasewithruntime-function-openprepareddatabasewithruntime-databasepath-standby-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-1956214053"></a>
### openPreparedDatabaseWithRuntime

```ml
function openPreparedDatabaseWithRuntime(databasePath, standby, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Opens and prepares a shared database using storage and query-memory budgets.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L547)

<a id="function-function-minisql-server-listener-processrequest-function-processrequest-slot-request-lockwaitms-src-minisql-server-listener-ml-928178639"></a>
### processRequest

```ml
function processRequest(slot, request, lockWaitMs)
```

Executes or retries one request without blocking the worker on a logical lock. Returns a response, void while error 9007 remains retryable, or a propagated error. Exceeding `lockWaitMs` counts as a statement deadline while retaining wire-compatible logical-lock error 9032 and transaction rollback semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slot` | `dynamic` | — |  |
| `request` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L249)

<a id="function-function-minisql-server-listener-publishready-function-publishready-listener-readypath-operation-src-minisql-server-listener-ml-1503363331"></a>
### publishReady

```ml
function publishReady(listener, readyPath, operation)
```

Implements publish ready for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `listener` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L120)

<a id="function-function-minisql-server-listener-reapconcurrentjobs-function-reapconcurrentjobs-jobs-src-minisql-server-listener-ml-1355286390"></a>
### reapConcurrentJobs

```ml
function reapConcurrentJobs(jobs)
```

Disposes completed pool jobs and returns the still-running handles. The returned list is the sole ownership set retained by the accept loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `jobs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L413)

<a id="function-function-minisql-server-listener-responseerrorcode-function-responseerrorcode-response-src-minisql-server-listener-ml-32113225"></a>
### responseErrorCode

```ml
function responseErrorCode(response)
```

Implements response error code for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `response` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L200)

<a id="function-function-minisql-server-listener-sendresponse-function-sendresponse-client-response-src-minisql-server-listener-ml-1209454466"></a>
### sendResponse

```ml
function sendResponse(client, response)
```

Sends either an ordinary response or a bounded sequence of result frames.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `client` | `dynamic` | — |  |
| `response` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L212)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentaddress-function-serveauthenticatedconcurrentaddress-databasepath-address-port-maximumclients-maximumrequests-src-minisql-server-listener-ml-996198353"></a>
### serveAuthenticatedConcurrentAddress

```ml
function serveAuthenticatedConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests)
```

Serves authenticated concurrent address using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L837)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentaddresswithlockwait-function-serveauthenticatedconcurrentaddresswithlockwait-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-listener-ml-1363533411"></a>
### serveAuthenticatedConcurrentAddressWithLockWait

```ml
function serveAuthenticatedConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves authenticated address clients with a configured logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L849)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentaddresswithoperationallimits-function-serveauthenticatedconcurrentaddresswithoperationallimits-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-listener-ml-1195493277"></a>
### serveAuthenticatedConcurrentAddressWithOperationalLimits

```ml
function serveAuthenticatedConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves authenticated clients with the complete configured operational limit set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |
| `maxStatementBytes` | `dynamic` | — |  |
| `maxFrameBytes` | `dynamic` | — |  |
| `maxResultRows` | `dynamic` | — |  |
| `maxResultBytes` | `dynamic` | — |  |
| `idleTimeoutMs` | `dynamic` | — |  |
| `processMemoryBytes` | `dynamic` | — |  |
| `temporaryStorageBytes` | `dynamic` | — |  |
| `slowQueryMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L873)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentaddresswithreadyfile-function-serveauthenticatedconcurrentaddresswithreadyfile-databasepath-address-port-maximumclients-maximumrequests-readypath-src-minisql-server-listener-ml-1561631427"></a>
### serveAuthenticatedConcurrentAddressWithReadyFile

```ml
function serveAuthenticatedConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, readyPath)
```

Serves authenticated concurrent address with ready file using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L886)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentaddresswithruntime-function-serveauthenticatedconcurrentaddresswithruntime-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-1401893599"></a>
### serveAuthenticatedConcurrentAddressWithRuntime

```ml
function serveAuthenticatedConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves authenticated address clients with configured lock and WAL thresholds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L861)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentloopback-function-serveauthenticatedconcurrentloopback-databasepath-port-maximumclients-maximumrequests-src-minisql-server-listener-ml-153728181"></a>
### serveAuthenticatedConcurrentLoopback

```ml
function serveAuthenticatedConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
```

Serves authenticated concurrent loopback using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L746)

<a id="function-function-minisql-server-listener-serveauthenticatedconcurrentloopbackwithlockwait-function-serveauthenticatedconcurrentloopbackwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-listener-ml-979005055"></a>
### serveAuthenticatedConcurrentLoopbackWithLockWait

```ml
function serveAuthenticatedConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves authenticated loopback clients with a configured logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L758)

<a id="function-function-minisql-server-listener-serveauthenticatedone-function-serveauthenticatedone-databasepath-port-maximumrequests-src-minisql-server-listener-ml-1216111595"></a>
### serveAuthenticatedOne

```ml
function serveAuthenticatedOne(databasePath, port, maximumRequests)
```

Serves authenticated one using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L110)

<a id="function-function-minisql-server-listener-serveauthenticatedonewithreadyfile-function-serveauthenticatedonewithreadyfile-databasepath-port-maximumrequests-readypath-src-minisql-server-listener-ml-2138161131"></a>
### serveAuthenticatedOneWithReadyFile

```ml
function serveAuthenticatedOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
```

Serves authenticated one with ready file using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L149)

<a id="function-function-minisql-server-listener-serveconcurrentclient-function-serveconcurrentclient-task-src-minisql-server-listener-ml-886277037"></a>
### serveConcurrentClient

```ml
function serveConcurrentClient(task)
```

One long-lived pool job owns exactly one client connection. Slow or idle peers therefore never stall accepts or unrelated sessions. SQL engine calls enter the per-database reader/writer gate in executor.executor. Runs the nonblocking receive/execute/send loop for one connection-owning job. Request reservations make the global limit race-free; pending lock conflicts are retried cooperatively. Always closes the slot and unregisters the client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `task` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L427)

<a id="function-function-minisql-server-listener-serveconcurrentlistenermode-function-serveconcurrentlistenermode-databasepath-listener-maximumclients-maximumrequests-secure-idlelimitms-standby-tlscredential-lockwaitms-src-minisql-server-listener-ml-1506576995"></a>
### serveConcurrentListenerMode

```ml
function serveConcurrentListenerMode(databasePath, listener, maximumClients, maximumRequests, secure, idleLimitMs, standby, tlsCredential, lockWaitMs)
```

Preserves the lower-level API for callers that already created a listener. Public address/loopback entry points prepare before binding and should be preferred.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `listener` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `secure` | `dynamic` | — |  |
| `idleLimitMs` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |
| `tlsCredential` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L674)

<a id="function-function-minisql-server-listener-serveconcurrentloopback-function-serveconcurrentloopback-databasepath-port-maximumclients-maximumrequests-src-minisql-server-listener-ml-1799788139"></a>
### serveConcurrentLoopback

```ml
function serveConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
```

Serves concurrent loopback using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L683)

<a id="function-function-minisql-server-listener-serveconcurrentloopbackfenced-function-serveconcurrentloopbackfenced-databasepath-port-maximumclients-maximumrequests-leasepath-epoch-nodeid-clockskewms-src-minisql-server-listener-ml-1624226772"></a>
### serveConcurrentLoopbackFenced

```ml
function serveConcurrentLoopbackFenced(databasePath, port, maximumClients, maximumRequests, leasePath, epoch, nodeId, clockSkewMs)
```

Serves a writable loopback primary whose authority is continuously proven by the controller-owned lease and persistent database epoch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `leasePath` | `dynamic` | — |  |
| `epoch` | `dynamic` | — |  |
| `nodeId` | `dynamic` | — |  |
| `clockSkewMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L696)

<a id="function-function-minisql-server-listener-serveconcurrentloopbackwithlockwait-function-serveconcurrentloopbackwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-listener-ml-539832333"></a>
### serveConcurrentLoopbackWithLockWait

```ml
function serveConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves trusted loopback clients with a configured logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L710)

<a id="function-function-minisql-server-listener-serveconcurrentloopbackwithoperationallimits-function-serveconcurrentloopbackwithoperationallimits-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-listener-ml-1106365667"></a>
### serveConcurrentLoopbackWithOperationalLimits

```ml
function serveConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves trusted clients with storage, memory, protocol, result, and idle limits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |
| `maxStatementBytes` | `dynamic` | — |  |
| `maxFrameBytes` | `dynamic` | — |  |
| `maxResultRows` | `dynamic` | — |  |
| `maxResultBytes` | `dynamic` | — |  |
| `idleTimeoutMs` | `dynamic` | — |  |
| `processMemoryBytes` | `dynamic` | — |  |
| `temporaryStorageBytes` | `dynamic` | — |  |
| `slowQueryMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L734)

<a id="function-function-minisql-server-listener-serveconcurrentloopbackwithruntime-function-serveconcurrentloopbackwithruntime-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-1969342677"></a>
### serveConcurrentLoopbackWithRuntime

```ml
function serveConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves trusted loopback clients with configured lock and WAL thresholds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L722)

<a id="function-function-minisql-server-listener-serveconcurrentwithreadyfile-function-serveconcurrentwithreadyfile-databasepath-port-maximumclients-maximumrequests-readypath-secure-src-minisql-server-listener-ml-1858569812"></a>
### serveConcurrentWithReadyFile

```ml
function serveConcurrentWithReadyFile(databasePath, port, maximumClients, maximumRequests, readyPath, secure)
```

Serves concurrent with ready file using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |
| `secure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L773)

<a id="function-function-minisql-server-listener-servelistener-function-servelistener-databasepath-listener-maximumrequests-src-minisql-server-listener-ml-1440013588"></a>
### serveListener

```ml
function serveListener(databasePath, listener, maximumRequests)
```

Serves listener using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `listener` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L87)

<a id="function-function-minisql-server-listener-servelistenermode-function-servelistenermode-databasepath-listener-maximumrequests-secure-src-minisql-server-listener-ml-1394185959"></a>
### serveListenerMode

```ml
function serveListenerMode(databasePath, listener, maximumRequests, secure)
```

Serves listener mode using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `listener` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `secure` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L47)

<a id="function-function-minisql-server-listener-serveone-function-serveone-databasepath-port-maximumrequests-src-minisql-server-listener-ml-1672208043"></a>
### serveOne

```ml
function serveOne(databasePath, port, maximumRequests)
```

Serves one using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L101)

<a id="function-function-minisql-server-listener-serveonewithreadyfile-function-serveonewithreadyfile-databasepath-port-maximumrequests-readypath-src-minisql-server-listener-ml-1626392243"></a>
### serveOneWithReadyFile

```ml
function serveOneWithReadyFile(databasePath, port, maximumRequests, readyPath)
```

Serves one with ready file using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L135)

<a id="function-function-minisql-server-listener-servepreparedconcurrentlistenermode-function-servepreparedconcurrentlistenermode-databasepath-listener-shared-maximumclients-maximumrequests-secure-idlelimitms-standby-tlscredential-lockwaitms-src-minisql-server-listener-ml-1730038272"></a>
### servePreparedConcurrentListenerMode

```ml
function servePreparedConcurrentListenerMode(databasePath, listener, shared, maximumClients, maximumRequests, secure, idleLimitMs, standby, tlsCredential, lockWaitMs)
```

Accepts clients into a bounded native thread pool backed by one already prepared shared database. This function owns both database and listener.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `listener` | `dynamic` | — |  |
| `shared` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `secure` | `dynamic` | — |  |
| `idleLimitMs` | `dynamic` | — |  |
| `standby` | `dynamic` | — |  |
| `tlsCredential` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L580)

<a id="function-function-minisql-server-listener-servesecurelistener-function-servesecurelistener-databasepath-listener-maximumrequests-src-minisql-server-listener-ml-1164085490"></a>
### serveSecureListener

```ml
function serveSecureListener(databasePath, listener, maximumRequests)
```

Serves secure listener using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `listener` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L94)

<a id="function-function-minisql-server-listener-servestandbyconcurrentloopback-function-servestandbyconcurrentloopback-databasepath-port-maximumclients-maximumrequests-src-minisql-server-listener-ml-275762745"></a>
### serveStandbyConcurrentLoopback

```ml
function serveStandbyConcurrentLoopback(databasePath, port, maximumClients, maximumRequests)
```

Serves standby concurrent loopback using the supplied inputs. Returns the computed value or operation status. Performs I/O through its file, transport, or storage dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L789)

<a id="function-function-minisql-server-listener-servestandbyconcurrentloopbackwithlockwait-function-servestandbyconcurrentloopbackwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-listener-ml-857778835"></a>
### serveStandbyConcurrentLoopbackWithLockWait

```ml
function serveStandbyConcurrentLoopbackWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves a standby listener with a configured logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L801)

<a id="function-function-minisql-server-listener-servestandbyconcurrentloopbackwithoperationallimits-function-servestandbyconcurrentloopbackwithoperationallimits-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-listener-ml-1003432879"></a>
### serveStandbyConcurrentLoopbackWithOperationalLimits

```ml
function serveStandbyConcurrentLoopbackWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves a standby with the complete configured operational limit set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |
| `maxStatementBytes` | `dynamic` | — |  |
| `maxFrameBytes` | `dynamic` | — |  |
| `maxResultRows` | `dynamic` | — |  |
| `maxResultBytes` | `dynamic` | — |  |
| `idleTimeoutMs` | `dynamic` | — |  |
| `processMemoryBytes` | `dynamic` | — |  |
| `temporaryStorageBytes` | `dynamic` | — |  |
| `slowQueryMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L825)

<a id="function-function-minisql-server-listener-servestandbyconcurrentloopbackwithruntime-function-servestandbyconcurrentloopbackwithruntime-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-1937032829"></a>
### serveStandbyConcurrentLoopbackWithRuntime

```ml
function serveStandbyConcurrentLoopbackWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves a standby with configured lock and WAL thresholds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L813)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddress-function-servetlsconcurrentaddress-databasepath-address-port-maximumclients-maximumrequests-certificatereference-src-minisql-server-listener-ml-1139541889"></a>
### serveTlsConcurrentAddress

```ml
function serveTlsConcurrentAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
```

Serves native TLS using a store or PFX certificate and environment PFX secret.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L954)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithlockwait-function-servetlsconcurrentaddresswithlockwait-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-src-minisql-server-listener-ml-507981171"></a>
### serveTlsConcurrentAddressWithLockWait

```ml
function serveTlsConcurrentAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
```

Serves native TLS with a configured logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L959)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithoperationallimits-function-servetlsconcurrentaddresswithoperationallimits-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-listener-ml-1928671805"></a>
### serveTlsConcurrentAddressWithOperationalLimits

```ml
function serveTlsConcurrentAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves native TLS with the complete configured operational limit set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |
| `maxStatementBytes` | `dynamic` | — |  |
| `maxFrameBytes` | `dynamic` | — |  |
| `maxResultRows` | `dynamic` | — |  |
| `maxResultBytes` | `dynamic` | — |  |
| `idleTimeoutMs` | `dynamic` | — |  |
| `processMemoryBytes` | `dynamic` | — |  |
| `temporaryStorageBytes` | `dynamic` | — |  |
| `slowQueryMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L933)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithpassword-function-servetlsconcurrentaddresswithpassword-databasepath-address-port-maximumclients-maximumrequests-certificatereference-passwordbytes-readypath-src-minisql-server-listener-ml-2092201995"></a>
### serveTlsConcurrentAddressWithPassword

```ml
function serveTlsConcurrentAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath)
```

Serves TLS with the legacy five-second logical-lock timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L949)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithpasswordandlockwait-function-servetlsconcurrentaddresswithpasswordandlockwait-databasepath-address-port-maximumclients-maximumrequests-certificatereference-passwordbytes-readypath-lockwaitms-src-minisql-server-listener-ml-10653037"></a>
### serveTlsConcurrentAddressWithPasswordAndLockWait

```ml
function serveTlsConcurrentAddressWithPasswordAndLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, lockWaitMs)
```

Serves TLS with the legacy 64 MiB automatic checkpoint threshold.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L923)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithpasswordruntime-function-servetlsconcurrentaddresswithpasswordruntime-databasepath-address-port-maximumclients-maximumrequests-certificatereference-passwordbytes-readypath-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-871044935"></a>
### serveTlsConcurrentAddressWithPasswordRuntime

```ml
function serveTlsConcurrentAddressWithPasswordRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes, readyPath, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves concurrent authenticated sessions over native TLS 1.3 and Schannel.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L900)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithreadyfile-function-servetlsconcurrentaddresswithreadyfile-databasepath-address-port-maximumclients-maximumrequests-certificatereference-readypath-src-minisql-server-listener-ml-716711391"></a>
### serveTlsConcurrentAddressWithReadyFile

```ml
function serveTlsConcurrentAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
```

Publishes a readiness marker only after the native TLS credential and listener exist.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L964)

<a id="function-function-minisql-server-listener-servetlsconcurrentaddresswithruntime-function-servetlsconcurrentaddresswithruntime-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-listener-ml-38723683"></a>
### serveTlsConcurrentAddressWithRuntime

```ml
function serveTlsConcurrentAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves TLS with configured lock and WAL thresholds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |
| `checkpointWalBytes` | `dynamic` | — |  |
| `bufferPoolBytes` | `dynamic` | — |  |
| `queryMemoryBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L928)

<a id="function-function-minisql-server-listener-targetmilestone-function-targetmilestone-src-minisql-server-listener-ml-1020463664"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L978)

<a id="function-function-minisql-server-listener-validatearguments-function-validatearguments-databasepath-maximumrequests-operation-src-minisql-server-listener-ml-823693957"></a>
### validateArguments

```ml
function validateArguments(databasePath, maximumRequests, operation)
```

Validates arguments using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `operation` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L37)
