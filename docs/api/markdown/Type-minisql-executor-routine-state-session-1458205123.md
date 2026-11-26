# `minisql.executor.routine_state.Session`

[Home](README.md) · [Source file](File-src-minisql-executor-routine-state-ml-1687727431.md)

<a id="struct-struct-minisql-executor-routine-state-session-struct-session-src-minisql-executor-routine-state-ml-1564081189"></a>
## Session

```ml
struct Session
```

Session state is never shared between authenticated engines.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L111)

## Members

<a id="field-field-minisql-executor-routine-state-session-automaticspprivileges-automaticspprivileges-src-minisql-executor-routine-state-ml-857335791"></a>
### automaticSpPrivileges

```ml
automaticSpPrivileges
```

Controls automatic EXECUTE/ALTER ROUTINE grants to a routine creator.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L149)

<a id="field-field-minisql-executor-routine-state-session-callstarted-callstarted-src-minisql-executor-routine-state-ml-1792600755"></a>
### callStarted

```ml
callStarted
```

A CALL has begun evaluation, so automatic whole-statement retries are unsafe.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L167)

<a id="field-field-minisql-executor-routine-state-session-charactersetclient-charactersetclient-src-minisql-executor-routine-state-ml-601935747"></a>
### characterSetClient

```ml
characterSetClient
```

Connection character set recorded in stored routine metadata.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L143)

<a id="field-field-minisql-executor-routine-state-session-collationconnection-collationconnection-src-minisql-executor-routine-state-ml-906622555"></a>
### collationConnection

```ml
collationConnection
```

Supported binary comparison collation recorded at creation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L145)

<a id="field-field-minisql-executor-routine-state-session-databasecollation-databasecollation-src-minisql-executor-routine-state-ml-1565920667"></a>
### databaseCollation

```ml
databaseCollation
```

Database default used for unqualified routine character declarations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L147)

<a id="field-field-minisql-executor-routine-state-session-definitioncache-definitioncache-src-minisql-executor-routine-state-ml-2079782511"></a>
### definitionCache

```ml
definitionCache
```

Bounded cache of parsed routine definitions; entries own no invocation state.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L151)

<a id="field-field-minisql-executor-routine-state-session-definitionparses-definitionparses-src-minisql-executor-routine-state-ml-1759159333"></a>
### definitionParses

```ml
definitionParses
```

Counts actual stored-definition parses for cache observability and tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L153)

<a id="field-field-minisql-executor-routine-state-session-diagnostic-diagnostic-src-minisql-executor-routine-state-ml-1504679561"></a>
### diagnostic

```ml
diagnostic
```

Current diagnostics area.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L117)

<a id="field-field-minisql-executor-routine-state-session-errorcount-errorcount-src-minisql-executor-routine-state-ml-350060253"></a>
### errorCount

```ml
errorCount
```

Total error-class conditions in the last public statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L137)

<a id="field-field-minisql-executor-routine-state-session-failedresults-failedresults-src-minisql-executor-routine-state-ml-185808683"></a>
### failedResults

```ml
failedResults
```

Results completed before an unhandled error, retained for ordered network delivery.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L131)

<a id="field-field-minisql-executor-routine-state-session-frames-frames-src-minisql-executor-routine-state-ml-84879179"></a>
### frames

```ml
frames
```

Active calls, with caller frames hidden from callee lexical lookup.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L115)

<a id="field-field-minisql-executor-routine-state-session-maxerrorcount-maxerrorcount-src-minisql-executor-routine-state-ml-920060999"></a>
### maxErrorCount

```ml
maxErrorCount
```

Maximum retained condition records; totals remain exact when zero.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L139)

<a id="field-field-minisql-executor-routine-state-session-maxrecursiondepth-maxrecursiondepth-src-minisql-executor-routine-state-ml-1755836431"></a>
### maxRecursionDepth

```ml
maxRecursionDepth
```

MySQL-style recursion limit; zero disables recursive procedure calls.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L123)

<a id="field-field-minisql-executor-routine-state-session-nextscopeid-nextscopeid-src-minisql-executor-routine-state-ml-993554715"></a>
### nextScopeId

```ml
nextScopeId
```

Allocator for lexical scope identities.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L125)

<a id="field-field-minisql-executor-routine-state-session-outgoingsignal-outgoingsignal-src-minisql-executor-routine-state-ml-1243209055"></a>
### outgoingSignal

```ml
outgoingSignal
```

The last failed public statement deliberately raised its numeric error code.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L129)

<a id="field-field-minisql-executor-routine-state-session-outputparameters-outputparameters-src-minisql-executor-routine-state-ml-1743377061"></a>
### outputParameters

```ml
outputParameters
```

Successful outer CALL output snapshots [ordinal, name, SqlValue].


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L161)

<a id="field-field-minisql-executor-routine-state-session-pending-pending-src-minisql-executor-routine-state-ml-789544283"></a>
### pending

```ml
pending
```

Marks an explicitly raised condition awaiting interception.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L121)

<a id="field-field-minisql-executor-routine-state-session-publicerrorrecorded-publicerrorrecorded-src-minisql-executor-routine-state-ml-2122910811"></a>
### publicErrorRecorded

```ml
publicErrorRecorded
```

Prevents executor and wire decoration from counting the same terminal error twice.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L169)

<a id="field-field-minisql-executor-routine-state-session-readonlyexecution-readonlyexecution-src-minisql-executor-routine-state-ml-147383267"></a>
### readOnlyExecution

```ml
readOnlyExecution
```

True while a statically verified read-only CALL owns the shared gate.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L163)

<a id="field-field-minisql-executor-routine-state-session-sink-sink-src-minisql-executor-routine-state-ml-1988197985"></a>
### sink

```ml
sink
```

Synchronous result consumer installed only for the current public statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L155)

<a id="field-field-minisql-executor-routine-state-session-sinkcontext-sinkcontext-src-minisql-executor-routine-state-ml-688374707"></a>
### sinkContext

```ml
sinkContext
```

Opaque caller-owned context passed to the streaming consumer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L157)

<a id="field-field-minisql-executor-routine-state-session-sqlmode-sqlmode-src-minisql-executor-routine-state-ml-1223381815"></a>
### sqlMode

```ml
sqlMode
```

SQL mode captured by CREATE and temporarily restored for each invocation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L141)

<a id="field-field-minisql-executor-routine-state-session-stacked-stacked-src-minisql-executor-routine-state-ml-85145995"></a>
### stacked

```ml
stacked
```

Diagnostics saved by active handlers, oldest first.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L119)

<a id="field-field-minisql-executor-routine-state-session-steps-steps-src-minisql-executor-routine-state-ml-838844431"></a>
### steps

```ml
steps
```

Cooperative instruction count used for deadline polling.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L127)

<a id="field-field-minisql-executor-routine-state-session-streamfailure-streamfailure-src-minisql-executor-routine-state-ml-1128995075"></a>
### streamFailure

```ml
streamFailure
```

A failed transport consumer cannot be caught by a SQL condition handler.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L159)

<a id="field-field-minisql-executor-routine-state-session-triggertables-triggertables-src-minisql-executor-routine-state-ml-1179512479"></a>
### triggerTables

```ml
triggerTables
```

Active triggering table identities, used to reject self-modification.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L165)

<a id="field-field-minisql-executor-routine-state-session-variables-variables-src-minisql-executor-routine-state-ml-517847167"></a>
### variables

```ml
variables
```

User variables persist until the engine closes.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L113)

<a id="field-field-minisql-executor-routine-state-session-warningcount-warningcount-src-minisql-executor-routine-state-ml-1738880165"></a>
### warningCount

```ml
warningCount
```

Total conditions, including those beyond maxErrorCount.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L135)

<a id="field-field-minisql-executor-routine-state-session-warnings-warnings-src-minisql-executor-routine-state-ml-722042221"></a>
### warnings

```ml
warnings
```

Bounded conditions from the last public statement, in encounter order.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/executor/routine_state.ml#L133)
