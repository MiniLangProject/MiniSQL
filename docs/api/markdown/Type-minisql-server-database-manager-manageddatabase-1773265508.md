# `minisql.server.database_manager.ManagedDatabase`

[Home](README.md) · [Source file](File-src-minisql-server-database-manager-ml-965836460.md)

<a id="struct-struct-minisql-server-database-manager-manageddatabase-struct-manageddatabase-src-minisql-server-database-manager-ml-1913460779"></a>
## ManagedDatabase

```ml
struct ManagedDatabase
```

Groups the managed database state and preserves the field relationships documented below.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L103)

## Members

<a id="field-field-minisql-server-database-manager-manageddatabase-auditlog-auditlog-src-minisql-server-database-manager-ml-249711031"></a>
### auditLog

```ml
auditLog
```

Stores the audit log associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L127)

<a id="field-field-minisql-server-database-manager-manageddatabase-cancelledstatements-cancelledstatements-src-minisql-server-database-manager-ml-852884233"></a>
### cancelledStatements

```ml
cancelledStatements
```

Statements terminated by an administrative cancellation token.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L183)

<a id="field-field-minisql-server-database-manager-manageddatabase-cataloghandle-cataloghandle-src-minisql-server-database-manager-ml-459384977"></a>
### catalogHandle

```ml
catalogHandle
```

Stores the catalog handle associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L107)

<a id="field-field-minisql-server-database-manager-manageddatabase-checkpointfile-checkpointfile-src-minisql-server-database-manager-ml-456944821"></a>
### checkpointFile

```ml
checkpointFile
```

Stores the filesystem checkpoint file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L119)

<a id="field-field-minisql-server-database-manager-manageddatabase-checkpointresets-checkpointresets-src-minisql-server-database-manager-ml-550478449"></a>
### checkpointResets

```ml
checkpointResets
```

Counts successful automatic WAL resets for diagnostics and tests.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L137)

<a id="field-field-minisql-server-database-manager-manageddatabase-checkpointwalbytes-checkpointwalbytes-src-minisql-server-database-manager-ml-784064543"></a>
### checkpointWalBytes

```ml
checkpointWalBytes
```

Maximum current-WAL size before a statement boundary performs a reset.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L133)

<a id="field-field-minisql-server-database-manager-manageddatabase-closed-closed-src-minisql-server-database-manager-ml-1413475737"></a>
### closed

```ml
closed
```

Indicates whether the closed condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L211)

<a id="field-field-minisql-server-database-manager-manageddatabase-executiongate-executiongate-src-minisql-server-database-manager-ml-1781585181"></a>
### executionGate

```ml
executionGate
```

Stores the execution gate associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L131)

<a id="field-field-minisql-server-database-manager-manageddatabase-failedstatements-failedstatements-src-minisql-server-database-manager-ml-1318066531"></a>
### failedStatements

```ml
failedStatements
```

Counts logical SQL statements ending in an error.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L157)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingclockskewms-fencingclockskewms-src-minisql-server-database-manager-ml-1313720697"></a>
### fencingClockSkewMs

```ml
fencingClockSkewMs
```

Clock-error allowance subtracted from the externally supplied expiry.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L207)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingenabled-fencingenabled-src-minisql-server-database-manager-ml-457676419"></a>
### fencingEnabled

```ml
fencingEnabled
```

Enables fail-closed validation of a controller-owned leader lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L199)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingepoch-fencingepoch-src-minisql-server-database-manager-ml-1661390887"></a>
### fencingEpoch

```ml
fencingEpoch
```

Immutable leadership term assigned when this server process starts.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L203)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingleasepath-fencingleasepath-src-minisql-server-database-manager-ml-1788908179"></a>
### fencingLeasePath

```ml
fencingLeasePath
```

Shared, atomically replaced lease record consulted before every write.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L201)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingnodeid-fencingnodeid-src-minisql-server-database-manager-ml-1642606713"></a>
### fencingNodeId

```ml
fencingNodeId
```

Immutable numeric identity of the node owning this server process.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L205)

<a id="field-field-minisql-server-database-manager-manageddatabase-fencingrejections-fencingrejections-src-minisql-server-database-manager-ml-269021937"></a>
### fencingRejections

```ml
fencingRejections
```

Counts write attempts rejected after a missing, stale, or foreign lease.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L209)

<a id="field-field-minisql-server-database-manager-manageddatabase-idletimeoutms-idletimeoutms-src-minisql-server-database-manager-ml-390413841"></a>
### idleTimeoutMs

```ml
idleTimeoutMs
```

Maximum inactive lifetime for one network session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L169)

<a id="field-field-minisql-server-database-manager-manageddatabase-indexesready-indexesready-src-minisql-server-database-manager-ml-791483299"></a>
### indexesReady

```ml
indexesReady
```

Indicates that process-local index readiness checks or repair completed.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L143)

<a id="field-field-minisql-server-database-manager-manageddatabase-lastrecovery-lastrecovery-src-minisql-server-database-manager-ml-2041599271"></a>
### lastRecovery

```ml
lastRecovery
```

Stores the last recovery associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L121)

<a id="field-field-minisql-server-database-manager-manageddatabase-lockfile-lockfile-src-minisql-server-database-manager-ml-357267635"></a>
### lockFile

```ml
lockFile
```

Stores the filesystem lock file.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L113)

<a id="field-field-minisql-server-database-manager-manageddatabase-lockmanager-lockmanager-src-minisql-server-database-manager-ml-672481665"></a>
### lockManager

```ml
lockManager
```

Synchronizes access through the lock manager.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L123)

<a id="field-field-minisql-server-database-manager-manageddatabase-locktoken-locktoken-src-minisql-server-database-manager-ml-1517009769"></a>
### lockToken

```ml
lockToken
```

Synchronizes access through the lock token.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L115)

<a id="field-field-minisql-server-database-manager-manageddatabase-maxframebytes-maxframebytes-src-minisql-server-database-manager-ml-575026969"></a>
### maxFrameBytes

```ml
maxFrameBytes
```

Maximum encoded response payload accepted by the configured server.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L165)

<a id="field-field-minisql-server-database-manager-manageddatabase-maximumexecutionms-maximumexecutionms-src-minisql-server-database-manager-ml-1018643037"></a>
### maximumExecutionMs

```ml
maximumExecutionMs
```

Greatest completed statement execution duration in milliseconds.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L191)

<a id="field-field-minisql-server-database-manager-manageddatabase-maxresultbytes-maxresultbytes-src-minisql-server-database-manager-ml-862036297"></a>
### maxResultBytes

```ml
maxResultBytes
```

Aggregate encoded response byte ceiling for one statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L173)

<a id="field-field-minisql-server-database-manager-manageddatabase-maxresultrows-maxresultrows-src-minisql-server-database-manager-ml-1070808345"></a>
### maxResultRows

```ml
maxResultRows
```

Maximum number of rows produced by one network statement.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L167)

<a id="field-field-minisql-server-database-manager-manageddatabase-maxstatementbytes-maxstatementbytes-src-minisql-server-database-manager-ml-955528297"></a>
### maxStatementBytes

```ml
maxStatementBytes
```

Hard protocol and result limits inherited by attached sessions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L163)

<a id="field-field-minisql-server-database-manager-manageddatabase-nextsessionid-nextsessionid-src-minisql-server-database-manager-ml-1248922873"></a>
### nextSessionId

```ml
nextSessionId
```

Tracks the next session identifier numeric value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L125)

<a id="field-field-minisql-server-database-manager-manageddatabase-path-path-src-minisql-server-database-manager-ml-1995858547"></a>
### path

```ml
path
```

Stores the filesystem path.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L105)

<a id="field-field-minisql-server-database-manager-manageddatabase-planningepoch-planningepoch-src-minisql-server-database-manager-ml-508113113"></a>
### planningEpoch

```ml
planningEpoch
```

Process-local generation invalidating optimizer metadata across sessions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L145)

<a id="field-field-minisql-server-database-manager-manageddatabase-processmemorybytes-processmemorybytes-src-minisql-server-database-manager-ml-154334095"></a>
### processMemoryBytes

```ml
processMemoryBytes
```

Managed-heap admission ceiling shared by all sessions.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L175)

<a id="field-field-minisql-server-database-manager-manageddatabase-querymemorybytes-querymemorybytes-src-minisql-server-database-manager-ml-1284208585"></a>
### queryMemoryBytes

```ml
queryMemoryBytes
```

Soft per-query memory budget inherited by every attached session.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L147)

<a id="field-field-minisql-server-database-manager-manageddatabase-querytimeoutms-querytimeoutms-src-minisql-server-database-manager-ml-201786623"></a>
### queryTimeoutMs

```ml
queryTimeoutMs
```

Maximum execution time for a statement, excluding response delivery.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L171)

<a id="field-field-minisql-server-database-manager-manageddatabase-readcache-readcache-src-minisql-server-database-manager-ml-851745865"></a>
### readCache

```ml
readCache
```

Database-owned concurrent cache for committed table pages.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L139)

<a id="field-field-minisql-server-database-manager-manageddatabase-readhandles-readhandles-src-minisql-server-database-manager-ml-1651036437"></a>
### readHandles

```ml
readHandles
```

Database-owned persistent read handles for hot table and index paths.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L141)

<a id="field-field-minisql-server-database-manager-manageddatabase-resourcerejectedstatements-resourcerejectedstatements-src-minisql-server-database-manager-ml-1123257745"></a>
### resourceRejectedStatements

```ml
resourceRejectedStatements
```

Statements rejected by a managed resource policy.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L187)

<a id="field-field-minisql-server-database-manager-manageddatabase-resultbytesreturned-resultbytesreturned-src-minisql-server-database-manager-ml-163027621"></a>
### resultBytesReturned

```ml
resultBytesReturned
```

Complete encoded response bytes returned by completed statements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L197)

<a id="field-field-minisql-server-database-manager-manageddatabase-rowsreturned-rowsreturned-src-minisql-server-database-manager-ml-1073852969"></a>
### rowsReturned

```ml
rowsReturned
```

Counts result rows produced by completed statements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L159)

<a id="field-field-minisql-server-database-manager-manageddatabase-schemastate-schemastate-src-minisql-server-database-manager-ml-474153621"></a>
### schemaState

```ml
schemaState
```

Immutable process-local snapshot of the durable schema sidecar. DDL publishes a replacement snapshot after commit, allowing ordinary reads to avoid reopening and checksumming schema.history for every row operation.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L111)

<a id="field-field-minisql-server-database-manager-manageddatabase-sessions-sessions-src-minisql-server-database-manager-ml-511070743"></a>
### sessions

```ml
sessions
```

Process-local operational registry and cumulative counters.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L149)

<a id="field-field-minisql-server-database-manager-manageddatabase-shutdownrequested-shutdownrequested-src-minisql-server-database-manager-ml-923635793"></a>
### shutdownRequested

```ml
shutdownRequested
```

Records a cooperative administrative listener-stop request.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L161)

<a id="field-field-minisql-server-database-manager-manageddatabase-slowquerycount-slowquerycount-src-minisql-server-database-manager-ml-2141017"></a>
### slowQueryCount

```ml
slowQueryCount
```

Statements whose duration met the configured slow-query threshold.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L193)

<a id="field-field-minisql-server-database-manager-manageddatabase-slowqueryms-slowqueryms-src-minisql-server-database-manager-ml-1407683557"></a>
### slowQueryMs

```ml
slowQueryMs
```

Millisecond threshold used for slow-query warnings and accounting.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L195)

<a id="field-field-minisql-server-database-manager-manageddatabase-standby-standby-src-minisql-server-database-manager-ml-1437881973"></a>
### standby

```ml
standby
```

Indicates whether the standby condition is active.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L129)

<a id="field-field-minisql-server-database-manager-manageddatabase-startedat-startedat-src-minisql-server-database-manager-ml-31254169"></a>
### startedAt

```ml
startedAt
```

Monotonic timestamp captured after successful database open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L151)

<a id="field-field-minisql-server-database-manager-manageddatabase-temporarypeakbytes-temporarypeakbytes-src-minisql-server-database-manager-ml-1947147571"></a>
### temporaryPeakBytes

```ml
temporaryPeakBytes
```

Greatest concurrent spill reservation observed since database open.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L181)

<a id="field-field-minisql-server-database-manager-manageddatabase-temporaryreservedbytes-temporaryreservedbytes-src-minisql-server-database-manager-ml-1636020505"></a>
### temporaryReservedBytes

```ml
temporaryReservedBytes
```

Bytes currently reserved by all query spill runs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L179)

<a id="field-field-minisql-server-database-manager-manageddatabase-temporarystoragebytes-temporarystoragebytes-src-minisql-server-database-manager-ml-1512458517"></a>
### temporaryStorageBytes

```ml
temporaryStorageBytes
```

Spill byte reservations shared by all concurrent statements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L177)

<a id="field-field-minisql-server-database-manager-manageddatabase-timedoutstatements-timedoutstatements-src-minisql-server-database-manager-ml-1827163127"></a>
### timedOutStatements

```ml
timedOutStatements
```

Statements terminated after their absolute execution deadline.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L185)

<a id="field-field-minisql-server-database-manager-manageddatabase-totalconnections-totalconnections-src-minisql-server-database-manager-ml-342762903"></a>
### totalConnections

```ml
totalConnections
```

Counts all engines attached since this database opened.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L153)

<a id="field-field-minisql-server-database-manager-manageddatabase-totalexecutionms-totalexecutionms-src-minisql-server-database-manager-ml-1132910745"></a>
### totalExecutionMs

```ml
totalExecutionMs
```

Sum of completed statement execution durations in milliseconds.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L189)

<a id="field-field-minisql-server-database-manager-manageddatabase-totalstatements-totalstatements-src-minisql-server-database-manager-ml-1942294537"></a>
### totalStatements

```ml
totalStatements
```

Counts completed logical SQL statements.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L155)

<a id="field-field-minisql-server-database-manager-manageddatabase-walepoch-walepoch-src-minisql-server-database-manager-ml-278379843"></a>
### walEpoch

```ml
walEpoch
```

True after the database has entered bounded-WAL epoch replay mode.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L135)

<a id="field-field-minisql-server-database-manager-manageddatabase-walwriter-walwriter-src-minisql-server-database-manager-ml-922370785"></a>
### walWriter

```ml
walWriter
```

Stores the WAL writer associated with this value.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/server/database_manager.ml#L117)
