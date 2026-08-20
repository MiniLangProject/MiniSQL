// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.catalog.schema_history as schema_history
import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
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
  first = executeOne(engine, "SELECT NEXTVAL('ticket_seq') AS n")
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

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  durable = executeOne(reopened, "SELECT NEXTVAL('ticket_seq') AS n")
  testkit.equal(state, int64(durable.rows[0][0]), 15, "sequence state survives reopen")
  generated = executeOne(reopened, "SELECT total FROM invoice WHERE id = 1")
  testkit.equal(state, generated.rows[0][0].value, 28, "generated definition survives reopen")
  executeOne(reopened, "DROP TRIGGER source_insert")
  executeOne(reopened, "DROP SEQUENCE ticket_seq")
  executor.close(reopened)

  return testkit.finish(state, "MiniSQL M45 sequence generated trigger tests: SUCCESS", "MiniSQL M45 sequence generated trigger tests: FAIL")
end function
