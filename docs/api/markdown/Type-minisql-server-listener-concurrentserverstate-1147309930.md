# `minisql.server.listener.ConcurrentServerState`

[Home](README.md) · [Source file](File-src-minisql-server-listener-ml-548170303.md)

<a id="struct-struct-minisql-server-listener-concurrentserverstate-struct-concurrentserverstate-src-minisql-server-listener-ml-383192507"></a>
## ConcurrentServerState

```ml
struct ConcurrentServerState
```

Native-threaded server state. All fields are protected by guard; snapshots let the acceptor and workers make decisions without retaining the mutex. Shares listener accounting between the acceptor and all worker jobs. Every field is read or written only while `guard` is held; callers use a snapshot so they never retain the mutex while doing socket or SQL work.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L285)

## Members

<a id="field-field-minisql-server-listener-concurrentserverstate-activeclients-activeclients-src-minisql-server-listener-ml-1284184948"></a>
### activeClients

```ml
activeClients
```

Number of live connection-owning worker jobs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L295)

<a id="field-field-minisql-server-listener-concurrentserverstate-failure-failure-src-minisql-server-listener-ml-1421371900"></a>
### failure

```ml
failure
```

First fatal listener/worker error; later errors never overwrite it.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L297)

<a id="field-field-minisql-server-listener-concurrentserverstate-guard-guard-src-minisql-server-listener-ml-1927065416"></a>
### guard

```ml
guard
```

Mutex protecting all following fields.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L287)

<a id="field-field-minisql-server-listener-concurrentserverstate-handled-handled-src-minisql-server-listener-ml-317334740"></a>
### handled

```ml
handled
```

Count of requests whose responses were sent successfully.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L291)

<a id="field-field-minisql-server-listener-concurrentserverstate-inflight-inflight-src-minisql-server-listener-ml-952569982"></a>
### inFlight

```ml
inFlight
```

Reservations claimed by workers but not yet completed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L293)

<a id="field-field-minisql-server-listener-concurrentserverstate-lastprogress-lastprogress-src-minisql-server-listener-ml-1900142934"></a>
### lastProgress

```ml
lastProgress
```

Monotonic timestamp of the latest accepted/completed client activity.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L299)

<a id="field-field-minisql-server-listener-concurrentserverstate-maximumrequests-maximumrequests-src-minisql-server-listener-ml-914508600"></a>
### maximumRequests

```ml
maximumRequests
```

Global successful-request limit; zero means unlimited.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L289)

<a id="field-field-minisql-server-listener-concurrentserverstate-stopping-stopping-src-minisql-server-listener-ml-309675664"></a>
### stopping

```ml
stopping
```

Requests cooperative shutdown of the acceptor and all workers.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/listener.ml#L301)
