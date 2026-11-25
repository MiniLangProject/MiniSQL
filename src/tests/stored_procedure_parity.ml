// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values
import std.threading as threading
import tests.support.testkit as testkit

/// Executes one SQL statement with native errors and ordered results preserved.
function executeOne(engine, sql)
  return executor.executeSql(engine, sql)[0]
end function

/// Reads a scalar without conflating SQL NULL with the text value NULL.
function scalar(engine, sql)
  return executeOne(engine, sql).rows[0][0]
end function

/// Continues independent acceptance groups after reporting a concrete failure.
function outcome(state, engine, result, name)
  testkit.record(state, typeof(result) != "error", name + " completes")
  if typeof(result) == "error" then
    print "GROUP ERROR " + name + ": " + result.code + " " + result.message
    ignored = try(executeOne(engine, "ROLLBACK"))
  end if
end function

/// Checks warning order, bounded retention, count inspection and precise SQLSTATEs.
function warnings(state, engine)
  executeOne(engine, "CREATE PROCEDURE warning_chain() BEGIN SIGNAL SQLSTATE '01000' SET MYSQL_ERRNO=6101, MESSAGE_TEXT='first'; SIGNAL SQLSTATE '01000' SET MYSQL_ERRNO=6102, MESSAGE_TEXT='second'; SET @after_warnings=1; END")
  executeOne(engine, "CALL warning_chain")
  testkit.equal(state, len(executor.statementWarnings(engine)), 2, "both nonfatal conditions reach connectors")
  shown = executeOne(engine, "SHOW WARNINGS")
  testkit.equal(state, len(shown.rows), 2, "SHOW WARNINGS retains both conditions after SET")
  testkit.equal(state, values.asNumber(shown.rows[0][1]), 6101, "warning order starts with first signal")
  testkit.equal(state, values.asNumber(shown.rows[1][1]), 6102, "warning order ends with second signal")
  testkit.equal(state, values.asNumber(scalar(engine, "SHOW COUNT(*) WARNINGS")), 2, "COUNT warnings is observational")
  limited = executeOne(engine, "SHOW WARNINGS LIMIT 1 OFFSET 1")
  testkit.equal(state, len(limited.rows), 1, "warning LIMIT applies after filtering")
  testkit.equal(state, limited.rows[0][2].value, "second", "warning offset selects expected condition")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT @@warning_count")), 2, "system warning count is observable")
  testkit.equal(state, len(executeOne(engine, "SHOW WARNINGS").rows), 0, "SELECT count clears old warnings after reading them")
  executeOne(engine, "SET max_error_count=1")
  executeOne(engine, "CALL warning_chain()")
  testkit.equal(state, len(executeOne(engine, "SHOW WARNINGS").rows), 1, "warning storage obeys configured bound")
  testkit.equal(state, values.asNumber(scalar(engine, "SHOW COUNT(*) WARNINGS")), 2, "warning totals survive truncation")
  executeOne(engine, "SET max_error_count=0")
  executeOne(engine, "CALL warning_chain()")
  testkit.equal(state, len(executeOne(engine, "SHOW WARNINGS").rows), 0, "zero retention emits no condition records")
  testkit.equal(state, values.asNumber(scalar(engine, "SHOW COUNT(*) WARNINGS")), 2, "zero retention still counts warnings")
  executeOne(engine, "SET max_error_count=64")
  failed = try(executeOne(engine, "SIGNAL SQLSTATE '45002' SET MYSQL_ERRNO=6199, MESSAGE_TEXT='application error'"))
  testkit.errorCode(state, failed, 6199, "application error keeps exact native observable code")
  diagnostic = executor.statementDiagnostic(engine, failed)
  testkit.equal(state, diagnostic.sqlstate, "45002", "structured diagnostics retain explicit SQLSTATE")
  testkit.equal(state, diagnostic.rowCount, -1, "error diagnostics have ROW_COUNT minus one")
  testkit.equal(state, len(executeOne(engine, "SHOW ERRORS").rows), 1, "SHOW ERRORS retains final error")
  testkit.equal(state, values.asNumber(scalar(engine, "SHOW COUNT(*) ERRORS")), 1, "error count remains exact")
  missing = try(executeOne(engine, "SELECT missing FROM parity_rows"))
  testkit.equal(state, executor.statementDiagnostic(engine, missing).sqlstate, "42S22", "native binding error exposes precise SQLSTATE")
  missing = try(executeOne(engine, "SELECT parity_rows.missing FROM parity_rows"))
  testkit.equal(state, executor.statementDiagnostic(engine, missing).sqlstate, "42S22", "qualified missing column retains column SQLSTATE")
  invalid = try(executeOne(engine, "SELECT FROM"))
  testkit.errorCode(state, invalid, 9019, "invalid SQL retains native syntax code")
  testkit.equal(state, values.asNumber(scalar(engine, "SHOW COUNT(*) ERRORS")), 1, "parse error replaces the previous condition area")
  shown = executeOne(engine, "SHOW ERRORS")
  testkit.equal(state, values.asNumber(shown.rows[0][1]), 1064, "SHOW ERRORS maps native parser error to SQL diagnostics")
  return true
end function

/// Verifies captured SQL mode, Unicode character limits and context restoration.
function contexts(state, engine)
  executeOne(engine, "SET sql_mode=''")
  executeOne(engine, "CREATE PROCEDURE relaxed_text(OUT result_value VARCHAR(3)) BEGIN SET result_value='äöüß'; END")
  executeOne(engine, "SET sql_mode='STRICT_ALL_TABLES'")
  executeOne(engine, "CALL relaxed_text(@relaxed)")
  testkit.equal(state, len(executor.statementWarnings(engine)), 1, "stored nonstrict mode emits truncation warning")
  testkit.equal(state, scalar(engine, "SELECT @relaxed").value, "äöü", "VARCHAR routine length counts Unicode characters")
  testkit.equal(state, scalar(engine, "SELECT @@sql_mode").value, "STRICT_ALL_TABLES", "caller mode restored after success")
  executeOne(engine, "CREATE PROCEDURE strict_text(OUT result_value VARCHAR(3)) SET result_value='äöüß'")
  executeOne(engine, "SET sql_mode=''")
  testkit.errorCode(state, try(executeOne(engine, "CALL strict_text(@strict)")), 1406, "stored strict mode rejects truncation")
  testkit.equal(state, scalar(engine, "SELECT @@sql_mode").value, "", "caller mode restored after failure")
  executeOne(engine, "CREATE PROCEDURE unicode_signal() SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT='äöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüßäöüß'")
  executeOne(engine, "CALL unicode_signal()")
  testkit.equal(state, len(executor.statementWarnings(engine)), 1, "MESSAGE_TEXT permits more than 128 UTF-8 bytes below 128 characters")
  executeOne(engine, "CREATE PROCEDURE utf8_input(IN x VARCHAR(4) CHARACTER SET utf8 COLLATE utf8_bin) SET @utf8_value=x")
  testkit.errorCode(state, try(executeOne(engine, "CALL utf8_input('😀')")), 1366, "utf8 three-byte declarations reject supplementary characters")
  badCollation = try(executeOne(engine, "CREATE PROCEDURE bad_collation(IN x VARCHAR(4) COLLATE unknown_ci) SET @bad=x"))
  testkit.errorCode(state, badCollation, 1273, "unsupported collation is rejected before persistence")
  testkit.equal(state, executor.statementDiagnostic(engine, badCollation).sqlstate, "HY000", "unknown collation keeps its documented SQLSTATE")
  badCharset = try(executeOne(engine, "CREATE PROCEDURE bad_charset(IN x VARCHAR(4) CHARACTER SET unknown_charset) SET @bad=x"))
  testkit.errorCode(state, badCharset, 1115, "unsupported charset is rejected before persistence")
  testkit.equal(state, executor.statementDiagnostic(engine, badCharset).sqlstate, "42000", "unknown character set exposes syntax SQLSTATE")
  badPair = try(executeOne(engine, "CREATE PROCEDURE bad_pair(IN x VARCHAR(4) CHARACTER SET utf8 COLLATE utf8mb4_bin) SET @bad=x"))
  testkit.errorCode(state, badPair, 1253, "incompatible character attributes are rejected before persistence")
  testkit.equal(state, executor.statementDiagnostic(engine, badPair).sqlstate, "42000", "charset and collation mismatch exposes syntax SQLSTATE")
  executeOne(engine, "CREATE PROCEDURE two_assignment_warnings() BEGIN DECLARE a VARCHAR(1); DECLARE b VARCHAR(1); SET a='aa',b='bb'; END")
  executeOne(engine, "CALL two_assignment_warnings()")
  testkit.equal(state, len(executor.statementWarnings(engine)), 2, "one assignment statement retains every truncation condition")
  executeOne(engine, "CREATE PROCEDURE short_input(IN x VARCHAR(1)) SET @short_input=x")
  executeOne(engine, "CALL short_input('ää')")
  testkit.equal(state, len(executor.statementWarnings(engine)), 1, "CALL input-conversion warning survives body execution")
  testkit.equal(state, scalar(engine, "SELECT @short_input").value, "ä", "CALL input conversion uses caller mode and character length")
  executeOne(engine, "CREATE PROCEDURE binary_output(OUT x VARCHAR(1) CHARACTER SET binary, OUT y CHAR(3) CHARACTER SET binary, OUT z TEXT CHARACTER SET binary) BEGIN SET x='ä', y='a', z='ä'; END")
  executeOne(engine, "CALL binary_output(@binary_x,@binary_y,@binary_z)")
  testkit.equal(state, len(executor.statementWarnings(engine)), 1, "binary truncation retains a warning without decoding partial UTF-8")
  binaryOutputs = executor.routineOutputParameters(engine)
  testkit.equal(state, binaryOutputs[0][2].typeKind, types.SqlTypeKind.VarBinary, "binary VARCHAR output has byte-string type")
  testkit.equal(state, hex(binaryOutputs[0][2].value), "c3", "binary truncation retains the exact byte prefix")
  testkit.equal(state, binaryOutputs[1][2].typeKind, types.SqlTypeKind.Binary, "binary CHAR output has fixed binary type")
  testkit.equal(state, hex(binaryOutputs[1][2].value), "610000", "fixed binary assignment pads with zero bytes")
  testkit.equal(state, binaryOutputs[2][2].typeKind, types.SqlTypeKind.Blob, "binary TEXT output has blob type")
  testkit.equal(state, hex(binaryOutputs[2][2].value), "c3a4", "binary TEXT retains original UTF-8 bytes")
  executeOne(engine, "SET sql_mode='STRICT_TRANS_TABLES'")
  executeOne(engine, "CREATE PROCEDURE strict_binary(OUT x VARBINARY(1)) SET x='ä'")
  testkit.errorCode(state, try(executeOne(engine, "CALL strict_binary(@strict_binary)")), 1406, "strict binary assignment rejects byte overflow")
  return true
end function

/// Confirms CALL status uses the final statement and errors roll back only failing DML.
function transactionBehavior(state, engine)
  executeOne(engine, "CREATE PROCEDURE affected_last() BEGIN UPDATE parity_rows SET value=value+1; UPDATE parity_rows SET value=value+1 WHERE id=1; END")
  testkit.equal(state, executeOne(engine, "CALL affected_last").affectedRows, 1, "CALL affected rows is last DML count")
  executeOne(engine, "CREATE PROCEDURE affected_select() BEGIN UPDATE parity_rows SET value=value+1; SELECT id FROM parity_rows; END")
  testkit.equal(state, executeOne(engine, "CALL affected_select()").affectedRows, 0, "final SELECT normalizes CALL affected rows to zero")
  executeOne(engine, "CREATE PROCEDURE partial_error() BEGIN INSERT INTO parity_rows VALUES(11,11); INSERT INTO parity_rows VALUES(12,12),(1,999); END")
  executeOne(engine, "BEGIN")
  executeOne(engine, "INSERT INTO parity_rows VALUES(10,10)")
  testkit.errorCode(state, try(executeOne(engine, "CALL partial_error()")), 9022, "duplicate key stays a native structured error")
  testkit.record(state, engine.explicitTransaction and not engine.failed, "ordinary failed CALL leaves transaction usable")
  executeOne(engine, "INSERT INTO parity_rows VALUES(13,13)")
  executeOne(engine, "COMMIT")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM parity_rows WHERE id>=10")), 3, "prior and successful CALL statements survive; failing multirow statement is atomic")
  executeOne(engine, "CREATE PROCEDURE explicit_signal() BEGIN INSERT INTO parity_rows VALUES(14,14); SIGNAL SQLSTATE '45000'; END")
  executeOne(engine, "BEGIN")
  testkit.errorCode(state, try(executeOne(engine, "CALL explicit_signal()")), 1644, "SIGNAL stops procedure")
  testkit.record(state, not engine.failed, "application SIGNAL does not poison explicit transaction")
  executeOne(engine, "ROLLBACK")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM parity_rows WHERE id=14")), 0, "caller can roll back successful writes before SIGNAL")
  return true
end function

/// CALL from row triggers inherits restrictions and shares the outer statement's pages.
function triggerCalls(state, engine)
  executeOne(engine, "CREATE TABLE trigger_source(id INT PRIMARY KEY, value INT)")
  executeOne(engine, "CREATE TABLE trigger_audit(id INT PRIMARY KEY, value INT)")
  executeOne(engine, "CREATE PROCEDURE trigger_store(IN row_id INT, IN amount INT, OUT copied INT) BEGIN INSERT INTO trigger_audit VALUES(row_id,amount); SET copied=amount+1; END")
  executeOne(engine, "CREATE TRIGGER audit_insert AFTER INSERT ON trigger_source FOR EACH ROW BEGIN DECLARE copied INT; CALL trigger_store(NEW.id, NEW.value, copied); SET @trigger_copied=copied; END")
  executeOne(engine, "INSERT INTO trigger_source VALUES(1,40)")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT value FROM trigger_audit WHERE id=1")), 40, "trigger CALL sees NEW input and writes shared transaction")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT @trigger_copied")), 41, "trigger local receives OUT parameter")
  executeOne(engine, "BEGIN")
  executeOne(engine, "INSERT INTO trigger_source VALUES(2,50)")
  executeOne(engine, "ROLLBACK")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM trigger_audit WHERE id=2")), 0, "outer rollback also rolls back callee effects")
  executeOne(engine, "DROP TRIGGER audit_insert")
  executeOne(engine, "CREATE PROCEDURE forbidden_rows() SELECT 1")
  executeOne(engine, "CREATE TRIGGER reject_rows AFTER INSERT ON trigger_source FOR EACH ROW CALL forbidden_rows()")
  testkit.errorCode(state, try(executeOne(engine, "INSERT INTO trigger_source VALUES(3,60)")), 1415, "nested trigger procedure cannot return client results")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM trigger_source WHERE id=3")), 0, "prohibited CALL rolls back invoking statement")
  executeOne(engine, "DROP TRIGGER reject_rows")
  executeOne(engine, "CREATE PROCEDURE forbidden_dynamic() BEGIN PREPARE dynamic_trigger FROM 'SELECT 1'; END")
  executeOne(engine, "CREATE TRIGGER reject_dynamic AFTER INSERT ON trigger_source FOR EACH ROW CALL forbidden_dynamic()")
  testkit.errorCode(state, try(executeOne(engine, "INSERT INTO trigger_source VALUES(4,60)")), 1336, "dynamic SQL prohibition propagates through CALL")
  executeOne(engine, "DROP TRIGGER reject_dynamic")
  executeOne(engine, "CREATE PROCEDURE forbidden_commit() COMMIT")
  executeOne(engine, "CREATE TRIGGER reject_commit AFTER INSERT ON trigger_source FOR EACH ROW CALL forbidden_commit()")
  testkit.errorCode(state, try(executeOne(engine, "INSERT INTO trigger_source VALUES(5,60)")), 1422, "callee cannot commit the trigger's transaction")
  executeOne(engine, "DROP TRIGGER reject_commit")
  executeOne(engine, "CREATE PROCEDURE forbidden_self() UPDATE trigger_source SET value=99 WHERE id=1")
  executeOne(engine, "CREATE TRIGGER reject_self AFTER INSERT ON trigger_source FOR EACH ROW CALL forbidden_self()")
  testkit.errorCode(state, try(executeOne(engine, "INSERT INTO trigger_source VALUES(6,60)")), 1442, "callee cannot modify invoking table")
  executeOne(engine, "DROP TRIGGER reject_self")
  executeOne(engine, "CREATE PROCEDURE trigger_savepoints() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @outer_savepoint_hidden=1; ROLLBACK TO outer_point; SAVEPOINT local_point; INSERT INTO trigger_audit VALUES(90,90); ROLLBACK TO local_point; RELEASE SAVEPOINT local_point; UPDATE trigger_audit SET value=value+1 WHERE id=1; END")
  executeOne(engine, "CREATE TRIGGER isolated_savepoints AFTER INSERT ON trigger_source FOR EACH ROW CALL trigger_savepoints()")
  executeOne(engine, "BEGIN")
  executeOne(engine, "SAVEPOINT outer_point")
  executeOne(engine, "INSERT INTO trigger_source VALUES(7,70)")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT @outer_savepoint_hidden")), 1, "callee cannot reach outer savepoint")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM trigger_source WHERE id=7")), 1, "inaccessible outer savepoint cannot remove invoking row")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM trigger_audit WHERE id=90")), 0, "local trigger savepoint can roll back local work")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT value FROM trigger_audit WHERE id=1")), 41, "bare target columns are not shadowed by NEW fields")
  executeOne(engine, "ROLLBACK TO outer_point")
  testkit.equal(state, values.asNumber(scalar(engine, "SELECT COUNT(*) FROM trigger_source WHERE id=7")), 0, "outer savepoint survives trigger level restoration")
  executeOne(engine, "COMMIT")
  executeOne(engine, "DROP TRIGGER isolated_savepoints")
  testkit.equal(state, engine.triggerDepth, 0, "trigger depth restored on all failures")
  testkit.equal(state, len(engine.routineSession.frames), 0, "trigger frames restored on all failures")
  return true
end function

/// A sink records bounded batches without retaining row payloads.
struct SinkState
  /// Total rows observed across all logical result sets.
  rows
  /// Largest in-flight batch.
  maximumBatch
  /// Logical result starts, including empty sets.
  starts
  /// Successfully completed logical result sets.
  ends
  /// Nonzero makes the consumer fail at this batch index.
  failAt
  /// Number of nonempty callback invocations.
  batches
end struct

/// Consumes each batch exactly once and can simulate an irreversible transport failure.
function consume(context, result, resultStart)
  if result is void then context.ends=context.ends+1; return true end if
  context.batches=context.batches+1
  if context.failAt>0 and context.batches>=context.failAt then return error(9026,"simulated disconnected consumer") end if
  if resultStart then context.starts=context.starts+1 end if
  context.rows=context.rows+len(result.rows)
  if len(result.rows)>context.maximumBatch then context.maximumBatch=len(result.rows) end if
  return true
end function

/// Validates incremental delivery, cancellation cleanup and immutable cache invalidation.
function streamingAndCache(state, engine)
  executeOne(engine, "CREATE TABLE streaming_rows(id INT PRIMARY KEY)")
  executeOne(engine, "CREATE PROCEDURE fill_streaming() BEGIN DECLARE i INT DEFAULT 0; START TRANSACTION; WHILE i<300 DO INSERT INTO streaming_rows VALUES(i); SET i=i+1; END WHILE; COMMIT; END")
  executeOne(engine, "CALL fill_streaming()")
  executeOne(engine, "CREATE PROCEDURE stream_rows(OUT count_value INT) BEGIN SELECT id FROM streaming_rows; SELECT id FROM streaming_rows WHERE id<0; SET count_value=300; END")
  sink = SinkState(0,0,0,0,0,0)
  called = executor.executeStatementStreaming(engine,parser.parseSql("CALL stream_rows(@stream_count)")[0],consume,sink)
  testkit.equal(state, called.kind, executor.RESULT_COMMAND, "streaming returns final status without retaining result sets")
  testkit.equal(state,sink.rows,300,"streamed rows delivered exactly once")
  testkit.record(state,sink.maximumBatch<=executor.EXECUTION_BATCH_ROWS,"streamed batch residency is bounded")
  testkit.equal(state,sink.starts,2,"stream includes empty logical result")
  testkit.equal(state,sink.ends,2,"stream reports each successful result completion")
  testkit.equal(state,values.asNumber(executor.routineOutputParameters(engine)[0][2]),300,"final output snapshot available without followup SQL")
  parses=engine.routineSession.definitionParses
  executeOne(engine,"CALL stream_rows(@stream_count)")
  testkit.equal(state,engine.routineSession.definitionParses,parses,"repeated CALL reuses parsed definition")
  executeOne(engine,"ALTER PROCEDURE stream_rows COMMENT 'cache invalidation'")
  executeOne(engine,"CALL stream_rows(@stream_count)")
  testkit.equal(state,engine.routineSession.definitionParses,parses+1,"ALTER invalidates cached definition")
  executeOne(engine,"DROP PROCEDURE stream_rows")
  executeOne(engine,"CREATE PROCEDURE stream_rows(OUT count_value INT) SET count_value=301")
  executeOne(engine,"CALL stream_rows(@stream_count)")
  testkit.equal(state,values.asNumber(scalar(engine,"SELECT @stream_count")),301,"DROP/recreate cannot reuse old program")
  executeOne(engine,"CREATE PROCEDURE stream_failure() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @transport_caught=1; SELECT id FROM streaming_rows; SET @after_transport=1; END")
  rejected=try(executor.executeStatementStreaming(engine,parser.parseSql("CALL stream_failure()")[0],consume,SinkState(0,0,0,0,2,0)))
  testkit.errorCode(state,rejected,9026,"consumer transport failure aborts CALL")
  testkit.record(state,scalar(engine,"SELECT @after_transport").isNull,"transport failure prevents later side effects")
  testkit.record(state,scalar(engine,"SELECT @transport_caught").isNull,"SQL handler cannot swallow transport failure")
  testkit.equal(state,database_manager.activeConcurrentReaders(engine.database),0,"streaming failure releases all shared readers")
  testkit.record(state,engine.routineSession.sink is void,"streaming sink restored after failure")
  executeOne(engine,"CREATE SEQUENCE stream_sequence START WITH 1 INCREMENT BY 1")
  executeOne(engine,"CREATE PROCEDURE sequence_result() SELECT NEXTVAL('stream_sequence')")
  sequenceSink=SinkState(0,0,0,0,0,0)
  executor.executeStatementStreaming(engine,parser.parseSql("CALL sequence_result()")[0],consume,sequenceSink)
  testkit.equal(state,values.asNumber(scalar(engine,"SELECT CURRVAL('stream_sequence')")),1,"fallback cursor probe never consumes sequence twice")
  executeOne(engine,"CREATE VIEW sequence_view AS SELECT 2 AS n")
  executeOne(engine,"CREATE PROCEDURE sequence_case() BEGIN CASE (SELECT n FROM sequence_view) WHEN 2 THEN SET @sequence_case=2; ELSE SET @sequence_case=0; END CASE; END")
  testkit.record(state,not executor.routineReadOnlyNode(engine,parser.parseSql("CALL sequence_case()")[0],"public",[]),"CASE selector cannot hide a view sequence mutation")
  executeOne(engine,"CREATE PROCEDURE sequence_limit() SELECT id FROM streaming_rows LIMIT (SELECT n FROM sequence_view)")
  testkit.record(state,not executor.routineReadOnlyNode(engine,parser.parseSql("CALL sequence_limit()")[0],"public",[]),"LIMIT subquery cannot hide a view sequence mutation")
  executeOne(engine,"CREATE PROCEDURE sequence_offset() SELECT id FROM streaming_rows LIMIT 1 OFFSET (SELECT n FROM sequence_view)")
  testkit.record(state,not executor.routineReadOnlyNode(engine,parser.parseSql("CALL sequence_offset()")[0],"public",[]),"OFFSET subquery cannot hide a view sequence mutation")
  return true
end function

/// State for two independent streaming CALLs deliberately held inside their shared gates.
struct ParallelTask
  /// Session owned by one worker.
  engine
  /// Both workers report first-result arrival.
  arrived
  /// The orchestrator releases both workers after observing overlap.
  release
  /// Failure outcome retained separately from native thread status.
  failed
end struct

/// Holds the first batch until both read-only procedures are executing together.
function parallelSink(context,result,resultStart)
  if result is not void and resultStart then
    context.arrived.release()
    if not context.release.waitFor(5000) then return error(9100,"parallel CALL release timeout") end if
  end if
  return true
end function

/// Executes one real read-only CALL per worker with an observable shared-gate barrier.
function parallelCall(context)
  result=try(executor.executeStatementStreaming(context.engine,parser.parseSql("CALL parallel_rows()")[0],parallelSink,context))
  context.failed=typeof(result)=="error"
  return result
end function

/// Proves actual CALL overlap and checks conservative fallback for dynamic/writing bodies.
function parallelReads(state,engine,managed)
  executeOne(engine,"CREATE PROCEDURE parallel_rows() READS SQL DATA SELECT id FROM streaming_rows")
  first=executor.attach(managed)
  second=executor.attach(managed)
  arrived=threading.Semaphore.new(0,2)
  release=threading.Event.new(true,false)
  one=ParallelTask(first,arrived,release,false)
  two=ParallelTask(second,arrived,release,false)
  workerOne=Thread(parallelCall,"routine-reader-one")
  workerTwo=Thread(parallelCall,"routine-reader-two")
  workerOne.Start(one)
  workerTwo.Start(two)
  overlapping=arrived.acquireFor(5000) and arrived.acquireFor(5000)
  testkit.record(state,overlapping,"two real read-only CALLs reach result sinks simultaneously")
  if overlapping then testkit.equal(state,database_manager.activeConcurrentReaders(managed),2,"each CALL owns one shared gate") end if
  release.set()
  testkit.record(state,workerOne.Join(5000) and workerTwo.Join(5000),"parallel CALL workers release their resources")
  testkit.record(state,not one.failed and not two.failed,"parallel CALLs both succeed")
  workerOne.Close(); workerTwo.Close(); arrived.close(); release.close()
  executor.close(first); executor.close(second)
  executeOne(engine,"CREATE PROCEDURE deceptive_read() READS SQL DATA UPDATE parity_rows SET value=value+1 WHERE id=1")
  testkit.record(state,not executor.routineReadOnlyNode(engine,parser.parseSql("CALL deceptive_read()")[0],"public",[]),"READS SQL DATA does not override body analysis")
  testkit.record(state,not executor.routineReadOnlyNode(engine,parser.parseSql("CALL forbidden_dynamic()")[0],"public",[]),"dynamic SQL conservatively requires writer execution")
  return true
end function

/// A late native lock wait cannot replay a CALL that already changed session state.
function retrySafety(state, engine, managed)
  executeOne(engine,"CREATE PROCEDURE lock_after_set() BEGIN SET @attempts=COALESCE(@attempts,0)+1; SELECT id FROM parity_rows; END")
  waiting=executor.attach(managed)
  executeOne(engine,"BEGIN")
  executeOne(engine,"INSERT INTO parity_rows VALUES(99,99)")
  locked=try(executeOne(waiting,"CALL lock_after_set()"))
  testkit.errorCode(state,locked,9007,"late native lock conflict remains identifiable")
  testkit.record(state,executor.routineStarted(waiting),"server knows CALL has already begun and must not replay it")
  testkit.record(state,not executor.isApplicationError(waiting,9007),"native conflict is not mislabeled as application SIGNAL")
  database_manager.cancelLockWait(managed,executor.sessionIdentifier(waiting))
  executeOne(engine,"ROLLBACK")
  testkit.equal(state,values.asNumber(scalar(waiting,"SELECT @attempts")),1,"session side effect occurred once before the conflict")
  executor.close(waiting)
  return true
end function

/// Runs the new parity acceptance groups on one isolated native database.
function main(args)
  if len(args)!=1 then print "MiniSQL stored procedure parity tests: FAIL args"; return 2 end if
  state=testkit.create()
  managed=database_manager.create(args[0],"stored_procedure_parity",config_model.defaultDatabaseSettings(4096))
  engine=executor.attach(managed)
  executeOne(engine,"CREATE TABLE parity_rows(id INT PRIMARY KEY,value INT)")
  executeOne(engine,"INSERT INTO parity_rows VALUES(1,1),(2,2),(3,3)")
  outcome(state,engine,try(warnings(state,engine)),"warning diagnostics")
  outcome(state,engine,try(contexts(state,engine)),"captured context")
  outcome(state,engine,try(transactionBehavior(state,engine)),"transaction behavior")
  outcome(state,engine,try(triggerCalls(state,engine)),"trigger CALL")
  outcome(state,engine,try(streamingAndCache(state,engine)),"streaming and cache")
  outcome(state,engine,try(parallelReads(state,engine,managed)),"parallel readers")
  outcome(state,engine,try(retrySafety(state,engine,managed)),"late lock retry safety")
  executor.close(engine); database_manager.close(managed)
  print "Stored procedure parity assertions: "+state.checks
  return testkit.finish(state,"MiniSQL stored procedure parity tests: SUCCESS","MiniSQL stored procedure parity tests: FAIL")
end function
