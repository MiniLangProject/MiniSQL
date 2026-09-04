# `src/minisql/server/session.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql server session facilities for this project.

Package: [`minisql.server.session`](Package-minisql-server-session-436024225.md)

Reachable from entry: **yes**

## Imports

- `minisql/catalog/catalog.ml` as `catalog` → [src/minisql/catalog/catalog.ml](File-src-minisql-catalog-catalog-ml-1154366378.md)
- `minisql/catalog/metadata.ml` as `metadata` → [src/minisql/catalog/metadata.ml](File-src-minisql-catalog-metadata-ml-2104219808.md)
- `minisql/client/formatter.ml` as `formatter` → [src/minisql/client/formatter.ml](File-src-minisql-client-formatter-ml-1949327393.md)
- `minisql/common/diagnostics.ml` as `diagnostics` → [src/minisql/common/diagnostics.ml](File-src-minisql-common-diagnostics-ml-1805539733.md)
- `minisql/common/logger.ml` as `logger` → [src/minisql/common/logger.ml](File-src-minisql-common-logger-ml-1571638233.md)
- `minisql/common/uuid.ml` as `uuid` → [src/minisql/common/uuid.ml](File-src-minisql-common-uuid-ml-1458519464.md)
- `minisql/executor/executor.ml` as `executor` → [src/minisql/executor/executor.ml](File-src-minisql-executor-executor-ml-1548110730.md)
- `minisql/platform/clock.ml` as `clock` → [src/minisql/platform/clock.ml](File-src-minisql-platform-clock-ml-2055787141.md)
- `minisql/protocol/connection.ml` as `protocol_connection` → [src/minisql/protocol/connection.ml](File-src-minisql-protocol-connection-ml-870021768.md)
- `minisql/protocol/constants.ml` as `constants` → [src/minisql/protocol/constants.ml](File-src-minisql-protocol-constants-ml-2117523449.md)
- `minisql/protocol/messages.ml` as `messages` → [src/minisql/protocol/messages.ml](File-src-minisql-protocol-messages-ml-1580707356.md)
- `minisql/server/database_manager.ml` as `database_manager` → [src/minisql/server/database_manager.ml](File-src-minisql-server-database-manager-ml-965836460.md)
- `minisql/sql/parser.ml` as `parser` → [src/minisql/sql/parser.ml](File-src-minisql-sql-parser-ml-2143788161.md)

## Declarations

<a id="function-function-minisql-server-session-abortforconcurrency-function-abortforconcurrency-session-src-minisql-server-session-ml-95288912"></a>
### abortForConcurrency

```ml
function abortForConcurrency(session)
```

Implements abort for concurrency for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L467)

<a id="function-function-minisql-server-session-abortforconcurrencytimeout-function-abortforconcurrencytimeout-session-src-minisql-server-session-ml-457748604"></a>
### abortForConcurrencyTimeout

```ml
function abortForConcurrencyTimeout(session)
```

Aborts a logical lock wait at the absolute statement deadline while keeping the wire-compatible lock-timeout response code in the listener.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L480)

<a id="function-function-minisql-server-session-abortforconcurrencyunlocked-function-abortforconcurrencyunlocked-session-src-minisql-server-session-ml-1891618318"></a>
### abortForConcurrencyUnlocked

```ml
function abortForConcurrencyUnlocked(session)
```

Aborts an ordinary lock conflict without assigning a terminal control code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L458)

<a id="function-function-minisql-server-session-abortforconcurrencyunlockedwithcode-function-abortforconcurrencyunlockedwithcode-session-errorcode-src-minisql-server-session-ml-1113907299"></a>
### abortForConcurrencyUnlockedWithCode

```ml
function abortForConcurrencyUnlockedWithCode(session, errorCode)
```

Implements abort for concurrency unlocked for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `errorCode` | `dynamic` | — | errorCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L449)

<a id="function-function-minisql-server-session-activatetransport-function-activatetransport-session-connection-src-minisql-server-session-ml-389783568"></a>
### activateTransport

```ml
function activateTransport(session, connection)
```

Implements activate transport for this module. Returns the computed value or operation status. May mutate supplied state and perform I/O through its dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L495)

<a id="constant-constant-minisql-server-session-auth-handshake-timeout-ms-const-auth-handshake-timeout-ms-30000-src-minisql-server-session-ml-2048339666"></a>
### AUTH_HANDSHAKE_TIMEOUT_MS

```ml
const AUTH_HANDSHAKE_TIMEOUT_MS = 30000
```

Defines the auth handshake timeout ms constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L36)

<a id="constant-constant-minisql-server-session-authentication-failed-const-authentication-failed-9027-src-minisql-server-session-ml-1911420055"></a>
### AUTHENTICATION_FAILED

```ml
const AUTHENTICATION_FAILED = 9027
```

Defines the authentication failed constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L30)

<a id="constant-constant-minisql-server-session-authentication-required-const-authentication-required-9028-src-minisql-server-session-ml-681956202"></a>
### AUTHENTICATION_REQUIRED

```ml
const AUTHENTICATION_REQUIRED = 9028
```

Defines the authentication required constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L34)

<a id="function-function-minisql-server-session-authenticationbackoff-function-authenticationbackoff-session-src-minisql-server-session-ml-1297544064"></a>
### authenticationBackoff

```ml
function authenticationBackoff(session)
```

Implements authentication backoff for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L311)

<a id="function-function-minisql-server-session-authenticationerror-function-authenticationerror-request-src-minisql-server-session-ml-299570499"></a>
### authenticationError

```ml
function authenticationError(request)
```

Implements authentication error for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L274)

<a id="function-function-minisql-server-session-begintrackedstatement-function-begintrackedstatement-session-sqltext-src-minisql-server-session-ml-2095483383"></a>
### beginTrackedStatement

```ml
function beginTrackedStatement(session, sqlText)
```

Begins metrics tracking exactly once across cooperative lock-wait retries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `sqlText` | `dynamic` | — | sqlText value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L191)

<a id="function-function-minisql-server-session-clearpending-function-clearpending-session-src-minisql-server-session-ml-317951976"></a>
### clearPending

```ml
function clearPending(session)
```

Implements clear pending for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L283)

<a id="function-function-minisql-server-session-close-function-close-session-src-minisql-server-session-ml-2020995104"></a>
### close

```ml
function close(session)
```

Closes close owned by the minisql server session module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L761)

<a id="constant-constant-minisql-server-session-closed-handle-const-closed-handle-9008-src-minisql-server-session-ml-282785756"></a>
### CLOSED_HANDLE

```ml
const CLOSED_HANDLE = 9008
```

Defines the closed handle constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L26)

<a id="function-function-minisql-server-session-closeunlocked-function-closeunlocked-session-src-minisql-server-session-ml-529605678"></a>
### closeUnlocked

```ml
function closeUnlocked(session)
```

Closes unlocked using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L740)

<a id="function-function-minisql-server-session-componentname-function-componentname-src-minisql-server-session-ml-741138814"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql server session module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L775)

<a id="function-function-minisql-server-session-createsession-function-createsession-engine-secure-authenticated-src-minisql-server-session-ml-1417614346"></a>
### createSession

```ml
function createSession(engine, secure, authenticated)
```

Creates session using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `engine` | `dynamic` | — | engine value consumed by this operation. |
| `secure` | `dynamic` | — | secure value consumed by this operation. |
| `authenticated` | `dynamic` | — | authenticated value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L106)

<a id="function-function-minisql-server-session-executeparsedquery-function-executeparsedquery-session-request-statement-src-minisql-server-session-ml-445262782"></a>
### executeParsedQuery

```ml
function executeParsedQuery(session, request, statement)
```

Executes an already parsed statement through the ordinary materializing API. Keeping this tail separate lets the network streaming path reuse parsing, authorization errors, and the exact fallback response contract.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |
| `statement` | `dynamic` | — | statement value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L548)

<a id="function-function-minisql-server-session-fail-function-fail-code-operation-message-src-minisql-server-session-ml-204771837"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql server session module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L88)

<a id="function-function-minisql-server-session-fakeauthenticationmaterial-function-fakeauthenticationmaterial-session-username-src-minisql-server-session-ml-423765460"></a>
### fakeAuthenticationMaterial

```ml
function fakeAuthenticationMaterial(session, username)
```

Implements fake authentication material for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `username` | `dynamic` | — | username value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L298)

<a id="function-function-minisql-server-session-finishtrackedstatement-function-finishtrackedstatement-session-success-rowcount-src-minisql-server-session-ml-1813534610"></a>
### finishTrackedStatement

```ml
function finishTrackedStatement(session, success, rowCount)
```

Compatibility helper for ordinary outcomes without a production-control code.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `success` | `dynamic` | — | success value consumed by this operation. |
| `rowCount` | `dynamic` | — | Number of row to process. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L225)

<a id="function-function-minisql-server-session-finishtrackedstatementwithcode-function-finishtrackedstatementwithcode-session-success-rowcount-errorcode-src-minisql-server-session-ml-1416617713"></a>
### finishTrackedStatementWithCode

```ml
function finishTrackedStatementWithCode(session, success, rowCount, errorCode)
```

Completes metrics, latency, budget and slow-query tracking.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `success` | `dynamic` | — | success value consumed by this operation. |
| `rowCount` | `dynamic` | — | Number of row to process. |
| `errorCode` | `dynamic` | — | errorCode value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L208)

<a id="function-function-minisql-server-session-handle-function-handle-session-request-src-minisql-server-session-ml-2109157213"></a>
### handle

```ml
function handle(session, request)
```

Handles handle using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L708)

<a id="function-function-minisql-server-session-handleauthbegin-function-handleauthbegin-session-request-src-minisql-server-session-ml-884902019"></a>
### handleAuthBegin

```ml
function handleAuthBegin(session, request)
```

Handles auth begin using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L324)

<a id="function-function-minisql-server-session-handleauthproof-function-handleauthproof-session-request-src-minisql-server-session-ml-1548115417"></a>
### handleAuthProof

```ml
function handleAuthProof(session, request)
```

Handles auth proof using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L366)

<a id="function-function-minisql-server-session-handlequery-function-handlequery-session-request-src-minisql-server-session-ml-1104137733"></a>
### handleQuery

```ml
function handleQuery(session, request)
```

Handles query using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L522)

<a id="function-function-minisql-server-session-handlequerystreaming-function-handlequerystreaming-session-request-connection-src-minisql-server-session-ml-1029757729"></a>
### handleQueryStreaming

```ml
function handleQueryStreaming(session, request, connection)
```

Streams an eligible non-blocking SELECT directly to one connection. One protocol frame plus one look-ahead frame are retained, so both server and cursor-aware client memory remain bounded while FLAG_MORE stays exact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L585)

<a id="function-function-minisql-server-session-handletoconnection-function-handletoconnection-session-request-connection-src-minisql-server-session-ml-938755029"></a>
### handleToConnection

```ml
function handleToConnection(session, request, connection)
```

Handles a request and, for eligible SELECTs, writes response batches directly to the supplied protocol connection. An empty array means delivery completed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |
| `connection` | `dynamic` | — | connection value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L656)

<a id="function-function-minisql-server-session-handleunlocked-function-handleunlocked-session-request-src-minisql-server-session-ml-377561681"></a>
### handleUnlocked

```ml
function handleUnlocked(session, request)
```

Handles unlocked using the supplied inputs. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `request` | `dynamic` | — | request value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L667)

<a id="function-function-minisql-server-session-idletimeoutmilliseconds-function-idletimeoutmilliseconds-src-minisql-server-session-ml-992711920"></a>
### idleTimeoutMilliseconds

```ml
function idleTimeoutMilliseconds()
```

Implements idle timeout milliseconds for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L184)

<a id="constant-constant-minisql-server-session-invalid-argument-const-invalid-argument-9001-src-minisql-server-session-ml-339201751"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L24)

<a id="constant-constant-minisql-server-session-io-failure-const-io-failure-9005-src-minisql-server-session-ml-898518839"></a>
### IO_FAILURE

```ml
const IO_FAILURE = 9005
```

Defines the io failure constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L32)

<a id="function-function-minisql-server-session-isexpired-function-isexpired-session-src-minisql-server-session-ml-890640254"></a>
### isExpired

```ml
function isExpired(session)
```

Returns whether the supplied value satisfies the expired condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L174)

<a id="function-function-minisql-server-session-isimplemented-function-isimplemented-src-minisql-server-session-ml-13960526"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql server session module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L789)

<a id="function-function-minisql-server-session-issession-function-issession-value-src-minisql-server-session-ml-231845499"></a>
### isSession

```ml
function isSession(value)
```

Returns whether the supplied value satisfies the session condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L96)

<a id="function-function-minisql-server-session-open-function-open-databasepath-src-minisql-server-session-ml-796287388"></a>
### open

```ml
function open(databasePath)
```

Opens open for the minisql server session module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L119)

<a id="function-function-minisql-server-session-openattached-function-openattached-database-src-minisql-server-session-ml-145125113"></a>
### openAttached

```ml
function openAttached(database)
```

Opens attached using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L136)

<a id="function-function-minisql-server-session-opensecure-function-opensecure-databasepath-src-minisql-server-session-ml-1470657552"></a>
### openSecure

```ml
function openSecure(databasePath)
```

Opens secure using the supplied inputs. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `databasePath` | `dynamic` | — | Path associated with database. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L127)

<a id="function-function-minisql-server-session-opensecureattached-function-opensecureattached-database-src-minisql-server-session-ml-175869969"></a>
### openSecureAttached

```ml
function openSecureAttached(database)
```

Opens secure attached using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L154)

<a id="function-function-minisql-server-session-prepareattacheddatabase-function-prepareattacheddatabase-database-src-minisql-server-session-ml-949997861"></a>
### prepareAttachedDatabase

```ml
function prepareAttachedDatabase(database)
```

Completes process-local database preparation before the listener advertises readiness, so the first client's HELLO does not pay the full index audit cost.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `database` | `dynamic` | — | database value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L145)

<a id="function-function-minisql-server-session-responsemessage-function-responsemessage-request-response-src-minisql-server-session-ml-687556610"></a>
### responseMessage

```ml
function responseMessage(request, response)
```

Implements response message for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `request` | `dynamic` | — | request value consumed by this operation. |
| `response` | `dynamic` | — | response value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L246)

<a id="function-function-minisql-server-session-responsemessages-function-responsemessages-request-responses-src-minisql-server-session-ml-1323401663"></a>
### responseMessages

```ml
function responseMessages(request, responses)
```

Encodes bounded result batches and marks every non-final frame for the client.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `request` | `dynamic` | — | request value consumed by this operation. |
| `responses` | `dynamic` | — | responses value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L256)

- [minisql.server.session.Session](Type-minisql-server-session-session-1392138063.md) — struct
<a id="constant-constant-minisql-server-session-session-idle-timeout-ms-const-session-idle-timeout-ms-300000-src-minisql-server-session-ml-610933758"></a>
### SESSION_IDLE_TIMEOUT_MS

```ml
const SESSION_IDLE_TIMEOUT_MS = 300000
```

Legacy public default retained for embedded callers and compatibility tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L38)

<a id="function-function-minisql-server-session-sessionidentifier-function-sessionidentifier-session-src-minisql-server-session-ml-509023954"></a>
### sessionIdentifier

```ml
function sessionIdentifier(session)
```

Implements session identifier for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L439)

<a id="constant-constant-minisql-server-session-stream-result-rows-const-stream-result-rows-64-src-minisql-server-session-ml-1585799353"></a>
### STREAM_RESULT_ROWS

```ml
const STREAM_RESULT_ROWS = 64
```

A server cursor retains at most this many arbitrarily wide SQL rows before


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L40)

<a id="function-function-minisql-server-session-targetmilestone-function-targetmilestone-src-minisql-server-session-ml-9333716"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql server session module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L782)

<a id="function-function-minisql-server-session-touch-function-touch-session-src-minisql-server-session-ml-205469174"></a>
### touch

```ml
function touch(session)
```

Implements touch for this module. Returns the computed value or operation status. May mutate supplied state as documented by the operation name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L164)

<a id="function-function-minisql-server-session-transportready-function-transportready-session-src-minisql-server-session-ml-1451047244"></a>
### transportReady

```ml
function transportReady(session)
```

Implements transport ready for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L430)

<a id="constant-constant-minisql-server-session-unsupported-sql-const-unsupported-sql-9025-src-minisql-server-session-ml-2134370741"></a>
### UNSUPPORTED_SQL

```ml
const UNSUPPORTED_SQL = 9025
```

Defines the unsupported sql constant used by the minisql server session module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L28)

<a id="function-function-minisql-server-session-validateopen-function-validateopen-session-operation-src-minisql-server-session-ml-604557585"></a>
### validateOpen

```ml
function validateOpen(session, operation)
```

Validates open for the minisql server session workflow. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L235)

<a id="function-function-minisql-server-session-waitingforconcurrency-function-waitingforconcurrency-session-src-minisql-server-session-ml-1804305174"></a>
### waitingForConcurrency

```ml
function waitingForConcurrency(session)
```

Returns whether this session still has a logical lock blocker. The check is side-effect free and lets the listener suspend a request without executing it repeatedly while another explicit transaction owns the writer lock.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `session` | `dynamic` | — | session value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/session.ml#L511)
