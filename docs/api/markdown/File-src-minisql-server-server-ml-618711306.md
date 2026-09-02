# `src/minisql/server/server.ml`

[Home](README.md) · [Files](Files.md)

Package: [`minisql.server.server`](Package-minisql-server-server-1695581772.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/version.ml` as `version` → [src/minisql/common/version.ml](File-src-minisql-common-version-ml-937202265.md)
- `minisql/server/listener.ml` as `listener` → [src/minisql/server/listener.ml](File-src-minisql-server-listener-ml-548170303.md)

## Declarations

<a id="function-function-minisql-server-server-componentname-function-componentname-src-minisql-server-server-ml-647459776"></a>
### componentName

```ml
function componentName()
```

Implements component name for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L161)

<a id="function-function-minisql-server-server-isimplemented-function-isimplemented-src-minisql-server-server-ml-885678152"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether the supplied value satisfies the implemented condition. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L175)

<a id="function-function-minisql-server-server-m0selftestline-function-m0selftestline-src-minisql-server-server-ml-364024336"></a>
### m0SelfTestLine

```ml
function m0SelfTestLine()
```

Implements m0 self test line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L13)

<a id="function-function-minisql-server-server-serveauthenticatedconcurrent-function-serveauthenticatedconcurrent-databasepath-port-maximumclients-maximumrequests-src-minisql-server-server-ml-2099642081"></a>
### serveAuthenticatedConcurrent

```ml
function serveAuthenticatedConcurrent(databasePath, port, maximumClients, maximumRequests)
```

Serves authenticated concurrent using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L68)

<a id="function-function-minisql-server-server-serveauthenticatedconcurrentwithlockwait-function-serveauthenticatedconcurrentwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-server-ml-1524485463"></a>
### serveAuthenticatedConcurrentWithLockWait

```ml
function serveAuthenticatedConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves authenticated loopback clients using the configured lock wait timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L73)

<a id="function-function-minisql-server-server-serveauthenticatedone-function-serveauthenticatedone-databasepath-port-maximumrequests-src-minisql-server-server-ml-164252839"></a>
### serveAuthenticatedOne

```ml
function serveAuthenticatedOne(databasePath, port, maximumRequests)
```

Serves authenticated one using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L34)

<a id="function-function-minisql-server-server-serveconcurrent-function-serveconcurrent-databasepath-port-maximumclients-maximumrequests-src-minisql-server-server-ml-1105527617"></a>
### serveConcurrent

```ml
function serveConcurrent(databasePath, port, maximumClients, maximumRequests)
```

Serves concurrent using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L41)

<a id="function-function-minisql-server-server-serveconcurrentfenced-function-serveconcurrentfenced-databasepath-port-maximumclients-maximumrequests-leasepath-epoch-nodeid-clockskewms-src-minisql-server-server-ml-126512136"></a>
### serveConcurrentFenced

```ml
function serveConcurrentFenced(databasePath, port, maximumClients, maximumRequests, leasePath, epoch, nodeId, clockSkewMs)
```

Serves a controller-fenced writable primary on loopback.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L46)

<a id="function-function-minisql-server-server-serveconcurrentwithlockwait-function-serveconcurrentwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-server-ml-760754635"></a>
### serveConcurrentWithLockWait

```ml
function serveConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves trusted clients using the configured logical-lock wait timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L51)

<a id="function-function-minisql-server-server-serveconcurrentwithoperationallimits-function-serveconcurrentwithoperationallimits-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-server-ml-1767030241"></a>
### serveConcurrentWithOperationalLimits

```ml
function serveConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves trusted clients with all production runtime and hard result limits.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L61)

<a id="function-function-minisql-server-server-serveconcurrentwithruntime-function-serveconcurrentwithruntime-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-server-ml-242394771"></a>
### serveConcurrentWithRuntime

```ml
function serveConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves trusted clients with all configured runtime durability thresholds.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L56)

<a id="function-function-minisql-server-server-serveone-function-serveone-databasepath-port-maximumrequests-src-minisql-server-server-ml-705977715"></a>
### serveOne

```ml
function serveOne(databasePath, port, maximumRequests)
```

Serves one using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L27)

<a id="function-function-minisql-server-server-servesecureaddress-function-servesecureaddress-databasepath-address-port-maximumclients-maximumrequests-src-minisql-server-server-ml-589042093"></a>
### serveSecureAddress

```ml
function serveSecureAddress(databasePath, address, port, maximumClients, maximumRequests)
```

Serves secure address using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L102)

<a id="function-function-minisql-server-server-servesecureaddresswithlockwait-function-servesecureaddresswithlockwait-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-server-ml-482128727"></a>
### serveSecureAddressWithLockWait

```ml
function serveSecureAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves authenticated address clients using the configured lock wait timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L107)

<a id="function-function-minisql-server-server-servesecureaddresswithoperationallimits-function-servesecureaddresswithoperationallimits-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-server-ml-21567565"></a>
### serveSecureAddressWithOperationalLimits

```ml
function serveSecureAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves authenticated clients with all production runtime and hard result limits.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L117)

<a id="function-function-minisql-server-server-servesecureaddresswithruntime-function-servesecureaddresswithruntime-databasepath-address-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-server-ml-1803056495"></a>
### serveSecureAddressWithRuntime

```ml
function serveSecureAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves authenticated clients with configured lock and WAL thresholds.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L112)

<a id="function-function-minisql-server-server-servestandbyconcurrent-function-servestandbyconcurrent-databasepath-port-maximumclients-maximumrequests-src-minisql-server-server-ml-1045097761"></a>
### serveStandbyConcurrent

```ml
function serveStandbyConcurrent(databasePath, port, maximumClients, maximumRequests)
```

Serves standby concurrent using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L80)

<a id="function-function-minisql-server-server-servestandbyconcurrentwithlockwait-function-servestandbyconcurrentwithlockwait-databasepath-port-maximumclients-maximumrequests-lockwaitms-src-minisql-server-server-ml-1104309879"></a>
### serveStandbyConcurrentWithLockWait

```ml
function serveStandbyConcurrentWithLockWait(databasePath, port, maximumClients, maximumRequests, lockWaitMs)
```

Serves standby clients using the configured logical-lock wait timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L85)

<a id="function-function-minisql-server-server-servestandbyconcurrentwithoperationallimits-function-servestandbyconcurrentwithoperationallimits-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-server-ml-1890646359"></a>
### serveStandbyConcurrentWithOperationalLimits

```ml
function serveStandbyConcurrentWithOperationalLimits(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves standby clients with all production runtime and hard result limits.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L95)

<a id="function-function-minisql-server-server-servestandbyconcurrentwithruntime-function-servestandbyconcurrentwithruntime-databasepath-port-maximumclients-maximumrequests-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-server-ml-281143113"></a>
### serveStandbyConcurrentWithRuntime

```ml
function serveStandbyConcurrentWithRuntime(databasePath, port, maximumClients, maximumRequests, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves standby clients with configured lock and WAL thresholds.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L90)

<a id="function-function-minisql-server-server-servetlsaddress-function-servetlsaddress-databasepath-address-port-maximumclients-maximumrequests-certificatereference-src-minisql-server-server-ml-389055453"></a>
### serveTlsAddress

```ml
function serveTlsAddress(databasePath, address, port, maximumClients, maximumRequests, certificateReference)
```

Serves authenticated MiniSQL over native TLS 1.3 using a store or PFX certificate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L122)

<a id="function-function-minisql-server-server-servetlsaddresswithlockwait-function-servetlsaddresswithlockwait-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-src-minisql-server-server-ml-1529767423"></a>
### serveTlsAddressWithLockWait

```ml
function serveTlsAddressWithLockWait(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs)
```

Serves native TLS clients using the configured logical-lock wait timeout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `lockWaitMs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L127)

<a id="function-function-minisql-server-server-servetlsaddresswithoperationallimits-function-servetlsaddresswithoperationallimits-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-maxstatementbytes-maxframebytes-maxresultrows-maxresultbytes-idletimeoutms-processmemorybytes-temporarystoragebytes-slowqueryms-src-minisql-server-server-ml-369425617"></a>
### serveTlsAddressWithOperationalLimits

```ml
function serveTlsAddressWithOperationalLimits(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes, maxStatementBytes, maxFrameBytes, maxResultRows, maxResultBytes, idleTimeoutMs, processMemoryBytes, temporaryStorageBytes, slowQueryMs)
```

Serves native TLS clients with all production runtime and hard result limits.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L137)

<a id="function-function-minisql-server-server-servetlsaddresswithpassword-function-servetlsaddresswithpassword-databasepath-address-port-maximumclients-maximumrequests-certificatereference-passwordbytes-src-minisql-server-server-ml-2039947545"></a>
### serveTlsAddressWithPassword

```ml
function serveTlsAddressWithPassword(databasePath, address, port, maximumClients, maximumRequests, certificateReference, passwordBytes)
```

Serves native TLS with an explicit in-memory PFX password for controlled callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `passwordBytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L142)

<a id="function-function-minisql-server-server-servetlsaddresswithreadyfile-function-servetlsaddresswithreadyfile-databasepath-address-port-maximumclients-maximumrequests-certificatereference-readypath-src-minisql-server-server-ml-1111512983"></a>
### serveTlsAddressWithReadyFile

```ml
function serveTlsAddressWithReadyFile(databasePath, address, port, maximumClients, maximumRequests, certificateReference, readyPath)
```

Serves bounded native TLS and publishes a readiness marker for integration tests.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — |  |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `maximumClients` | `dynamic` | — |  |
| `maximumRequests` | `dynamic` | — |  |
| `certificateReference` | `dynamic` | — |  |
| `readyPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L147)

<a id="function-function-minisql-server-server-servetlsaddresswithruntime-function-servetlsaddresswithruntime-databasepath-address-port-maximumclients-maximumrequests-certificatereference-lockwaitms-checkpointwalbytes-bufferpoolbytes-querymemorybytes-src-minisql-server-server-ml-118620071"></a>
### serveTlsAddressWithRuntime

```ml
function serveTlsAddressWithRuntime(databasePath, address, port, maximumClients, maximumRequests, certificateReference, lockWaitMs, checkpointWalBytes, bufferPoolBytes, queryMemoryBytes)
```

Serves native TLS clients with configured lock and WAL thresholds.

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


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L132)

<a id="function-function-minisql-server-server-start-function-start-configpath-src-minisql-server-server-ml-1768619457"></a>
### start

```ml
function start(configPath)
```

Implements start for this module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `configPath` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L154)

<a id="function-function-minisql-server-server-targetmilestone-function-targetmilestone-src-minisql-server-server-ml-569138310"></a>
### targetMilestone

```ml
function targetMilestone()
```

Implements target milestone for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L168)

<a id="function-function-minisql-server-server-versionline-function-versionline-src-minisql-server-server-ml-1383754408"></a>
### versionLine

```ml
function versionLine()
```

Implements version line for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/server.ml#L20)
