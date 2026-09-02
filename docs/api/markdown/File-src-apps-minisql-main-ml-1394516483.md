# `src/apps/minisql/main.ml`

[Home](README.md) · [Files](Files.md)

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **no**

## Imports

- `minisql/client/client.ml` as `client` → [src/minisql/client/client.ml](File-src-minisql-client-client-ml-193935498.md)
- `minisql/client/console.ml` as `console` → [src/minisql/client/console.ml](File-src-minisql-client-console-ml-931665780.md)
- `minisql/client/formatter.ml` as `formatter` → [src/minisql/client/formatter.ml](File-src-minisql-client-formatter-ml-1949327393.md)

## Declarations

<a id="function-function-closeafter-function-closeafter-active-result-src-apps-minisql-main-ml-714838171"></a>
### closeAfter

```ml
function closeAfter(active, result)
```

Closes a client after an operation and converts either error to a process status. Returns zero only when both the operation and close completed successfully.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — |  |
| `result` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L50)

<a id="function-function-main-function-main-args-src-apps-minisql-main-ml-1783362773"></a>
### main

```ml
function main(args)
```

Dispatches the public CLI modes after validating arity and numeric ports. Returns zero on success, one on operational failure, or two for usage errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L121)

<a id="function-function-openprompt-function-openprompt-address-port-username-src-apps-minisql-main-ml-1190581541"></a>
### openPrompt

```ml
function openPrompt(address, port, username)
```

Prompts for credentials and opens an authenticated connection to the address.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L105)

<a id="function-function-opentlspinnedprompt-function-opentlspinnedprompt-address-port-servername-pintext-username-src-apps-minisql-main-ml-221611095"></a>
### openTlsPinnedPrompt

```ml
function openTlsPinnedPrompt(address, port, serverName, pinText, username)
```

Prompts for credentials and opens native TLS with exact leaf-certificate pinning.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `pinText` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L115)

<a id="function-function-opentlsprompt-function-opentlsprompt-address-port-servername-username-src-apps-minisql-main-ml-2101358207"></a>
### openTlsPrompt

```ml
function openTlsPrompt(address, port, serverName, username)
```

Prompts for credentials and opens native TLS with Windows certificate trust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `address` | `dynamic` | — |  |
| `port` | `dynamic` | — |  |
| `serverName` | `dynamic` | — |  |
| `username` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L110)

<a id="function-function-opentrusted-function-opentrusted-port-src-apps-minisql-main-ml-869273841"></a>
### openTrusted

```ml
function openTrusted(port)
```

Opens an unauthenticated loopback client for the supplied port.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L100)

<a id="function-function-printclienterror-function-printclienterror-value-src-apps-minisql-main-ml-992645459"></a>
### printClientError

```ml
function printClientError(value)
```

Prints a structured client error and returns the conventional failure status.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L43)

<a id="function-function-printusage-function-printusage-src-apps-minisql-main-ml-2054191928"></a>
### printUsage

```ml
function printUsage()
```

Prints command-line syntax for trusted, authenticated, and encrypted client modes. Writes only to standard output and returns void.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L11)

<a id="function-function-runping-function-runping-active-src-apps-minisql-main-ml-709186944"></a>
### runPing

```ml
function runPing(active)
```

Sends PING, closes the connection, and prints PONG on success. Returns zero on success and one for protocol, close, or negative-ping failures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L59)

<a id="function-function-runquery-function-runquery-active-sqltext-src-apps-minisql-main-ml-317192527"></a>
### runQuery

```ml
function runQuery(active, sqlText)
```

Executes and formats one SQL query before closing the connection. Returns one for protocol ERROR responses or client/formatting failures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — |  |
| `sqlText` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L71)

<a id="function-function-runscript-function-runscript-active-path-src-apps-minisql-main-ml-1468383825"></a>
### runScript

```ml
function runScript(active, path)
```

Executes a SQL script, closes the client, and reports the statement count. Returns a nonzero status for script or cleanup errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L91)

<a id="function-function-runshell-function-runshell-active-src-apps-minisql-main-ml-1465027554"></a>
### runShell

```ml
function runShell(active)
```

Runs the interactive shell and always closes its client afterward.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql/main.ml#L84)
