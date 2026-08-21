// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.schema_history as schema_history
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.transaction.transaction as transaction
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Extracts the host integer from the SQL 64-bit wrapper used in result assertions.
function int64(value)
  return endian.int64ToInt(value.value)
end function

// Runs the sequences generated triggers test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M45 sequence generated trigger tests: FAIL args"; return 2 end if
  state = testkit.create()

  // Exercise every schema.extensions record family as a pure codec roundtrip
  // before a database owner is opened. The test uses its own deterministic
  // identity and precomputes each call result so an allocation-heavy encode
  // cannot invalidate a later nested member access in the same expression.
  codecDatabaseId = bytes(16, 0)
  for codecIndex = 0 to 15
    codecDatabaseId[codecIndex] = codecIndex + 1
  end for
  codecState = schema_history.createState(codecDatabaseId)
  codecState.generation = 9

  codecView = schema_history.viewDefinition(1, "codec_view", "SELECT 1 AS n", ["n"])
  codecSequenceStart = endian.int64FromInt(10)
  codecSequenceIncrement = endian.int64FromInt(5)
  codecSequenceMinimum = endian.int64FromInt(10)
  codecSequenceMaximum = endian.int64FromInt(20)
  codecSequenceLast = endian.int64FromInt(15)
  codecSequence = schema_history.sequenceDefinition(2, "codec_seq", codecSequenceStart, codecSequenceIncrement, codecSequenceMinimum, codecSequenceMaximum, codecSequenceLast, true, true, 3, "id")
  codecGenerated = schema_history.generatedColumnDefinition(3, "total", "quantity * price", true)
  codecTrigger = schema_history.triggerDefinition(4, "codec_trigger", 3, 2, 1, "", "INSERT INTO audit_event(id) VALUES (NEW.id)", true)

  codecState.views = [codecView]
  codecState.sequences = [codecSequence]
  codecState.generatedColumns = [codecGenerated]
  codecState.triggers = [codecTrigger]
  codecEncoded = schema_history.encodeExtensions(codecState)

  // Recreate the expected identity immediately before decode. The original ID
  // was intentionally consumed only by createState before the allocation-heavy
  // record construction and encode path.
  codecDecodeDatabaseId = bytes(16, 0)
  for codecIndex = 0 to 15
    codecDecodeDatabaseId[codecIndex] = codecIndex + 1
  end for
  codecRoundtrip = schema_history.decodeExtensions(codecEncoded, codecDecodeDatabaseId)
  testkit.equal(state, hex(codecRoundtrip.databaseId), "0102030405060708090a0b0c0d0e0f10", "mixed extension database identity")
  testkit.equal(state, codecRoundtrip.generation, 9, "mixed extension generation roundtrip")
  testkit.equal(state, len(codecRoundtrip.views), 1, "mixed extension view count")
  testkit.equal(state, codecRoundtrip.views[0].name, "codec_view", "mixed extension view name")
  testkit.equal(state, len(codecRoundtrip.sequences), 1, "mixed extension sequence count")
  testkit.equal(state, endian.int64ToInt(codecRoundtrip.sequences[0].lastValue), 15, "mixed extension sequence value")
  testkit.equal(state, codecRoundtrip.sequences[0].ownedColumnName, "id", "mixed extension sequence owner")
  testkit.equal(state, len(codecRoundtrip.generatedColumns), 1, "mixed extension generated count")
  testkit.equal(state, codecRoundtrip.generatedColumns[0].expressionSql, "quantity * price", "mixed extension generated SQL")
  testkit.equal(state, len(codecRoundtrip.triggers), 1, "mixed extension trigger count")
  testkit.equal(state, codecRoundtrip.triggers[0].name, "codec_trigger", "mixed extension trigger name")

  managed = database_manager.create(args[0], "m45_extensions", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)

  executeOne(engine, "CREATE SEQUENCE ticket_seq START WITH 10 INCREMENT BY 5 MINVALUE 10 MAXVALUE 20 CYCLE")
  first = executeOne(engine, "SELECT NEXTVAL('public.ticket_seq') AS n")
  second = executeOne(engine, "SELECT NEXTVAL('ticket_seq') AS n, CURRVAL('ticket_seq') AS current_value")
  third = executeOne(engine, "SELECT NEXTVAL('ticket_seq') AS n")
  cycled = executeOne(engine, "SELECT NEXTVAL('ticket_seq') AS n")
  testkit.equal(state, int64(first.rows[0][0]), 10, "sequence start")
  testkit.equal(state, int64(second.rows[0][0]), 15, "sequence increment")
  testkit.equal(state, int64(second.rows[0][1]), 15, "sequence currval")
  testkit.equal(state, int64(third.rows[0][0]), 20, "sequence maximum")
  testkit.equal(state, int64(cycled.rows[0][0]), 10, "sequence cycle")

  executeOne(engine, "CREATE TABLE invoice (id INTEGER PRIMARY KEY, quantity INTEGER NOT NULL, price INTEGER NOT NULL, total INTEGER GENERATED ALWAYS AS (quantity * price) STORED)")
  inserted = executeOne(engine, "INSERT INTO invoice(id, quantity, price) VALUES (1, 3, 7) RETURNING total")
  testkit.equal(state, inserted.rows[0][0].value, 21, "generated column on insert")
  updated = executeOne(engine, "UPDATE invoice SET quantity = 4 WHERE id = 1 RETURNING total")
  testkit.equal(state, updated.rows[0][0].value, 28, "generated column on update")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO invoice(id, quantity, price, total) VALUES (2, 1, 1, 99)")), 9021, "explicit generated value rejected")

  executeOne(engine, "CREATE TABLE legacy_item (id INTEGER PRIMARY KEY, base_value INTEGER NOT NULL)")
  executeOne(engine, "INSERT INTO legacy_item(id, base_value) VALUES (1, 6)")
  executeOne(engine, "ALTER TABLE legacy_item ADD COLUMN doubled INTEGER GENERATED ALWAYS AS (base_value * 2) STORED")
  legacy = executeOne(engine, "SELECT doubled FROM legacy_item WHERE id = 1")
  testkit.equal(state, legacy.rows[0][0].value, 12, "generated column materializes old row")

  executeOne(engine, "CREATE TABLE merge_target (id INTEGER PRIMARY KEY, value INTEGER NOT NULL, label VARCHAR(20) NOT NULL)")
  executeOne(engine, "CREATE TABLE merge_source (id INTEGER PRIMARY KEY, value INTEGER NOT NULL, label VARCHAR(20) NOT NULL)")
  executeOne(engine, "INSERT INTO merge_target(id, value, label) VALUES (1, 10, 'old')")
  executeOne(engine, "INSERT INTO merge_source(id, value, label) VALUES (1, 20, 'updated'), (2, 30, 'inserted')")
  merged = executeOne(engine, "MERGE INTO merge_target t USING merge_source s ON t.id = s.id WHEN MATCHED THEN UPDATE SET value = s.value, label = s.label WHEN NOT MATCHED THEN INSERT (id, value, label) VALUES (s.id, s.value, s.label)")
  testkit.equal(state, merged.affectedRows, 2, "MERGE reports updated and inserted rows")
  mergeRows = executeOne(engine, "SELECT id, value, label FROM merge_target ORDER BY id")
  testkit.equal(state, len(mergeRows.rows), 2, "MERGE target row count")
  testkit.equal(state, mergeRows.rows[0][1].value, 20, "MERGE matched update")
  testkit.equal(state, mergeRows.rows[1][2].value, "inserted", "MERGE not-matched insert")
  executeOne(engine, "DELETE FROM merge_source WHERE id = 1")
  executeOne(engine, "MERGE INTO merge_target t USING merge_source s ON t.id = s.id WHEN MATCHED THEN DELETE")
  mergeAfterDelete = executeOne(engine, "SELECT id FROM merge_target ORDER BY id")
  testkit.equal(state, len(mergeAfterDelete.rows), 1, "MERGE matched delete")
  testkit.equal(state, mergeAfterDelete.rows[0][0].value, 1, "MERGE delete leaves unmatched target")
  executeOne(engine, "CREATE TABLE merge_guard (id INTEGER PRIMARY KEY)")
  executeOne(engine, "INSERT INTO merge_guard(id) VALUES (1)")
  testkit.errorCode(state, try(executor.executeSql(engine, "INSERT INTO merge_guard(id) VALUES (1)")), 9022, "merge guard primary key rejects duplicates")
  executeOne(engine, "CREATE TRIGGER merge_failure AFTER UPDATE ON merge_target FOR EACH ROW INSERT INTO merge_guard(id) VALUES (1)")
  testkit.errorCode(state, try(executor.executeSql(engine, "UPDATE merge_target SET value = 21 WHERE id = 1")), 9022, "ordinary UPDATE propagates trigger failure")
  updateRolledBack = executeOne(engine, "SELECT value FROM merge_target WHERE id = 1")
  testkit.equal(state, updateRolledBack.rows[0][0].value, 20, "failed trigger rolls back ordinary UPDATE")
  executeOne(engine, "INSERT INTO merge_source(id, value, label) VALUES (1, 99, 'must-rollback')")
  testkit.errorCode(state, try(executor.executeSql(engine, "MERGE INTO merge_target t USING merge_source s ON t.id = s.id WHEN MATCHED THEN UPDATE SET value = s.value, label = s.label")), 9022, "MERGE propagates trigger failure")
  mergeRolledBack = executeOne(engine, "SELECT value FROM merge_target WHERE id = 1")
  testkit.equal(state, mergeRolledBack.rows[0][0].value, 20, "failed implicit MERGE rolls back every staged action")
  executeOne(engine, "BEGIN")
  testkit.errorCode(state, try(executor.executeSql(engine, "MERGE INTO merge_target t USING merge_source s ON t.id = s.id WHEN MATCHED THEN UPDATE SET value = s.value, label = s.label")), 9022, "explicit MERGE propagates trigger failure")
  testkit.equal(state, transaction.stagedPageCount(engine.pageTransaction), 0, "failed explicit MERGE restores its pre-statement page set")
  executeOne(engine, "ROLLBACK")
  executeOne(engine, "DROP TRIGGER merge_failure")

  executeOne(engine, "CREATE TABLE source_event (id INTEGER PRIMARY KEY, value INTEGER NOT NULL)")
  executeOne(engine, "CREATE TABLE audit_event (id INTEGER, old_value INTEGER, new_value INTEGER, action VARCHAR(10))")
  executeOne(engine, "CREATE TRIGGER source_insert AFTER INSERT ON source_event FOR EACH ROW INSERT INTO audit_event(id, old_value, new_value, action) VALUES (NEW.id, NULL, NEW.value, 'INSERT')")
  executeOne(engine, "CREATE TRIGGER source_update AFTER UPDATE OF value ON source_event FOR EACH ROW INSERT INTO audit_event(id, old_value, new_value, action) VALUES (NEW.id, OLD.value, NEW.value, 'UPDATE')")
  executeOne(engine, "CREATE TRIGGER source_delete AFTER DELETE ON source_event FOR EACH ROW INSERT INTO audit_event(id, old_value, new_value, action) VALUES (OLD.id, OLD.value, NULL, 'DELETE')")
  executeOne(engine, "INSERT INTO source_event(id, value) VALUES (1, 10)")
  executeOne(engine, "UPDATE source_event SET value = 11 WHERE id = 1")
  executeOne(engine, "DELETE FROM source_event WHERE id = 1")
  audit = executeOne(engine, "SELECT action, old_value, new_value FROM audit_event ORDER BY action")
  testkit.equal(state, len(audit.rows), 3, "three row triggers fired")
  testkit.equal(state, audit.rows[0][0].value, "DELETE", "delete trigger action")
  testkit.equal(state, audit.rows[1][0].value, "INSERT", "insert trigger action")
  testkit.equal(state, audit.rows[2][0].value, "UPDATE", "update trigger action")
  testkit.equal(state, audit.rows[2][1].value, 10, "update trigger OLD value")
  testkit.equal(state, audit.rows[2][2].value, 11, "update trigger NEW value")

  executeOne(engine, "CREATE TABLE trigger_subject (id INTEGER PRIMARY KEY)")
  executeOne(engine, "CREATE TABLE trigger_trace (subject_id INTEGER, phase VARCHAR(10))")
  executeOne(engine, "CREATE TRIGGER subject_before BEFORE INSERT ON trigger_subject FOR EACH ROW INSERT INTO trigger_trace(subject_id, phase) VALUES (NEW.id, 'BEFORE')")
  executeOne(engine, "CREATE TRIGGER subject_after AFTER INSERT ON trigger_subject FOR EACH ROW INSERT INTO trigger_trace(subject_id, phase) VALUES (NEW.id, 'AFTER')")
  executeOne(engine, "INSERT INTO trigger_subject(id) VALUES (1)")
  bothTimings = executeOne(engine, "SELECT phase FROM trigger_trace WHERE subject_id = 1 ORDER BY phase")
  testkit.equal(state, len(bothTimings.rows), 2, "BEFORE and AFTER triggers both fire")
  executeOne(engine, "ALTER TRIGGER subject_before DISABLE")
  executeOne(engine, "INSERT INTO trigger_subject(id) VALUES (2)")
  disabledBefore = executeOne(engine, "SELECT phase FROM trigger_trace WHERE subject_id = 2")
  testkit.equal(state, len(disabledBefore.rows), 1, "disabled trigger is skipped")
  testkit.equal(state, disabledBefore.rows[0][0].value, "AFTER", "enabled trigger still fires")
  executeOne(engine, "ALTER TRIGGER subject_before ENABLE")
  executeOne(engine, "INSERT INTO trigger_subject(id) VALUES (3)")
  enabledAgain = executeOne(engine, "SELECT phase FROM trigger_trace WHERE subject_id = 3")
  testkit.equal(state, len(enabledAgain.rows), 2, "re-enabled trigger fires persistently")

  executeOne(engine, "CREATE TABLE procedure_item (id INTEGER PRIMARY KEY, name VARCHAR(40) NOT NULL)")
  executeOne(engine, "CREATE PROCEDURE add_procedure_item(p_id INTEGER, p_name VARCHAR(40)) AS INSERT INTO procedure_item(id, name) VALUES (p_id, p_name)")
  called = executeOne(engine, "CALL add_procedure_item(7, 'stored')")
  testkit.equal(state, called.command, "CALL", "CALL reports procedure command")
  testkit.equal(state, called.affectedRows, 1, "CALL returns body affected rows")
  procedureRow = executeOne(engine, "SELECT name FROM procedure_item WHERE id = 7")
  testkit.equal(state, procedureRow.rows[0][0].value, "stored", "procedure parameters feed stored DML")
  routines = executeOne(engine, "SELECT routine_name, routine_type FROM information_schema.routines WHERE routine_schema = 'public'")
  testkit.equal(state, routines.rows[0][0].value, "add_procedure_item", "INFORMATION_SCHEMA exposes procedure")
  testkit.equal(state, routines.rows[0][1].value, "PROCEDURE", "routine type is procedure")
  executeOne(engine, "CREATE OR REPLACE PROCEDURE add_procedure_item(p_id INTEGER, p_name VARCHAR(40)) AS UPDATE procedure_item SET name = p_name WHERE id = p_id")
  executeOne(engine, "CALL add_procedure_item(7, 'replaced')")
  replacedProcedure = executeOne(engine, "SELECT name FROM procedure_item WHERE id = 7")
  testkit.equal(state, replacedProcedure.rows[0][0].value, "replaced", "CREATE OR REPLACE PROCEDURE replaces body")
  testkit.errorCode(state, try(executor.executeSql(engine, "CALL add_procedure_item(7)")), 9020, "CALL validates argument count")
  testkit.errorCode(state, try(executor.executeSql(engine, "CALL add_procedure_item('not-an-integer', 'invalid')")), 9017, "CALL enforces durable parameter types")
  testkit.errorCode(state, try(executor.executeSql(engine, "CREATE PROCEDURE lossy_body(p_id INTEGER) AS INSERT INTO procedure_item(id, name) VALUES (p_id, 'x') RETURNING id")), 9025, "procedure persistence rejects unsupported clauses without losing semantics")

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT NEXTVAL('ticket_seq') AS n")
  testkit.equal(state, int64(durable.rows[0][0]), 15, "sequence state survives reopen")
  generated = executeOne(reopened, "SELECT total FROM invoice WHERE id = 1")
  testkit.equal(state, generated.rows[0][0].value, 28, "generated definition survives reopen")
  executeOne(reopened, "CALL add_procedure_item(7, 'durable-type')")
  durableProcedure = executeOne(reopened, "SELECT name FROM procedure_item WHERE id = 7")
  testkit.equal(state, durableProcedure.rows[0][0].value, "durable-type", "procedure types and body survive reopen")
  testkit.errorCode(state, try(executor.executeSql(reopened, "CALL add_procedure_item('bad', 'invalid')")), 9017, "reopened procedure retains parameter type enforcement")
  executeOne(reopened, "DROP TRIGGER source_insert")
  executeOne(reopened, "DROP PROCEDURE add_procedure_item")
  executeOne(reopened, "DROP SEQUENCE ticket_seq")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M45 sequence generated trigger tests: SUCCESS", "MiniSQL M45 sequence generated trigger tests: FAIL")
end function
