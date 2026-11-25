// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.values as values
import tests.support.testkit as testkit

/// Executes one complete SQL statement while preserving structured failures.
function one(engine, sql)
  return executor.executeSql(engine, sql)[0]
end function

/// Reads one SQL number for lexical and control-flow assertions.
function number(engine, sql)
  return values.asNumber(one(engine, sql).rows[0][0])
end function

/// Keeps unrelated semantic checks visible if one procedure unexpectedly fails.
function report(state, outcome, label)
  testkit.record(state, typeof(outcome) != "error", label + " completes")
  if typeof(outcome) == "error" then print "EDGE ERROR " + label + " " + outcome.code + ": " + outcome.message end if
end function

/// ITERATE must bypass the UNTIL predicate and start the next REPEAT iteration.
function repeatIterate(state, engine)
  one(engine, "CREATE PROCEDURE edge_repeat() BEGIN DECLARE i INT DEFAULT 0; again: REPEAT SET i = i + 1; IF i < 3 THEN ITERATE again; END IF; UNTIL TRUE END REPEAT; SET @edge_repeat = i; END")
  one(engine, "CALL edge_repeat()")
  testkit.equal(state, number(engine, "SELECT @edge_repeat"), 3, "REPEAT ITERATE skips UNTIL until body completes")
  return true
end function

/// A cursor binds locals where declared but evaluates their current values at OPEN.
function cursorLexicalBinding(state, engine)
  one(engine, "CREATE PROCEDURE edge_cursor() BEGIN DECLARE item INT DEFAULT 1; DECLARE fetched INT; DECLARE c CURSOR FOR SELECT item; SET item = 4; BEGIN DECLARE item INT DEFAULT 2; OPEN c; FETCH c INTO fetched; CLOSE c; END; SET @edge_cursor = fetched; END")
  one(engine, "CALL edge_cursor()")
  testkit.equal(state, number(engine, "SELECT @edge_cursor"), 4, "outer cursor ignores inner local shadow at OPEN")
  return true
end function

/// Dynamic SQL retains its preparation schema while access checks remain invocation-based.
function prepareSchema(state, engine)
  one(engine, "CREATE TABLE edge_values(v INT)")
  one(engine, "INSERT INTO edge_values VALUES(100)")
  one(engine, "CREATE SCHEMA edge_schema")
  one(engine, "CREATE TABLE edge_schema.edge_values(v INT)")
  one(engine, "INSERT INTO edge_schema.edge_values VALUES(200)")
  one(engine, "CREATE PROCEDURE edge_schema.prepare_query() BEGIN PREPARE edge_plan FROM 'SELECT v FROM edge_values'; EXECUTE edge_plan; END")
  result = one(engine, "CALL edge_schema.prepare_query()")
  testkit.equal(state, values.asNumber(result.rows[0].rows[0][0]), 200, "dynamic SQL uses procedure schema during call")
  testkit.equal(state, number(engine, "EXECUTE edge_plan"), 200, "prepared schema persists after procedure returns")
  one(engine, "DEALLOCATE PREPARE edge_plan")
  return true
end function

/// Nested query rewriting must retain the CTE namespace of the enclosing SELECT.
function cteSchema(state, engine)
  one(engine, "CREATE PROCEDURE edge_schema.cte_query() WITH first_cte AS (SELECT 5 AS v), second_cte AS (SELECT v FROM first_cte) SELECT v FROM second_cte")
  result = one(engine, "CALL edge_schema.cte_query()")
  testkit.equal(state, values.asNumber(result.rows[0].rows[0][0]), 5, "chained CTE remains lexical in non-public schema")
  return true
end function

/// Successful handler exit restores the surrounding stored-program diagnostics area.
function handlerDiagnostics(state, engine)
  one(engine, "CREATE PROCEDURE edge_diagnostics() BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45010' SET @edge_handler_work = 1; SIGNAL SQLSTATE '45010' SET MYSQL_ERRNO = 6010, MESSAGE_TEXT = 'original condition'; GET CURRENT DIAGNOSTICS CONDITION 1 @edge_diagnostic_errno = MYSQL_ERRNO, @edge_diagnostic_state = RETURNED_SQLSTATE; END")
  one(engine, "CALL edge_diagnostics()")
  testkit.equal(state, number(engine, "SELECT @edge_diagnostic_errno"), 6010, "handler exit preserves original errno for subsequent diagnostics")
  testkit.equal(state, one(engine, "SELECT @edge_diagnostic_state").rows[0][0].value, "45010", "handler exit restores original SQLSTATE")
  return true
end function

/// RESIGNAL with a new SQLSTATE appends a condition without losing the original.
function resignalDiagnostics(state, engine)
  one(engine, "CREATE PROCEDURE edge_resignal() BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45012' BEGIN GET STACKED DIAGNOSTICS @edge_condition_count = NUMBER; GET STACKED DIAGNOSTICS CONDITION 1 @edge_original_state = RETURNED_SQLSTATE; GET STACKED DIAGNOSTICS CONDITION 2 @edge_resignal_state = RETURNED_SQLSTATE, @edge_resignal_errno = MYSQL_ERRNO; END; BEGIN DECLARE EXIT HANDLER FOR SQLSTATE '45011' RESIGNAL SQLSTATE '45012' SET MYSQL_ERRNO = 6012; SIGNAL SQLSTATE '45011' SET MYSQL_ERRNO = 6011; END; END")
  one(engine, "CALL edge_resignal()")
  testkit.equal(state, number(engine, "SELECT @edge_condition_count"), 2, "RESIGNAL new state exposes both conditions")
  testkit.equal(state, one(engine, "SELECT @edge_original_state").rows[0][0].value, "45011", "diagnostics condition one retains original state")
  testkit.equal(state, one(engine, "SELECT @edge_resignal_state").rows[0][0].value, "45012", "diagnostics condition two contains resignal state")
  testkit.equal(state, number(engine, "SELECT @edge_resignal_errno"), 6012, "resignal explicit errno is retained")
  return true
end function

/// A caught SELECT failure rolls back only that statement and keeps prior transactional writes.
function handledSelectTransaction(state, engine)
  one(engine, "CREATE TABLE edge_tx(id INT PRIMARY KEY)")
  one(engine, "CREATE PROCEDURE edge_tx_handler() BEGIN START TRANSACTION; INSERT INTO edge_tx VALUES(1); BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @edge_select_caught = 1; SELECT missing_column FROM edge_tx; END; INSERT INTO edge_tx VALUES(2); COMMIT; END")
  one(engine, "CALL edge_tx_handler()")
  testkit.equal(state, number(engine, "SELECT COUNT(*) FROM edge_tx"), 2, "handled SELECT failure preserves earlier write and permits later commit")
  testkit.equal(state, number(engine, "SELECT @edge_select_caught"), 1, "SELECT error invokes condition handler")
  testkit.record(state, not engine.explicitTransaction, "successful procedure COMMIT ends explicit transaction")
  return true
end function

/// Runs independent edge cases against a disposable native database.
function main(args)
  if len(args) != 1 then print "MiniSQL stored procedure edge tests: FAIL (missing data root)"; return 1 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "stored_procedure_edges", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)
  report(state, try(repeatIterate(state, engine)), "REPEAT ITERATE")
  report(state, try(cursorLexicalBinding(state, engine)), "cursor lexical scope")
  report(state, try(prepareSchema(state, engine)), "prepared schema")
  report(state, try(cteSchema(state, engine)), "CTE schema")
  report(state, try(handlerDiagnostics(state, engine)), "handler diagnostics")
  report(state, try(resignalDiagnostics(state, engine)), "resignal diagnostics")
  report(state, try(handledSelectTransaction(state, engine)), "handled SELECT transaction")
  executor.close(engine)
  database_manager.close(managed)
  print "Stored procedure edge assertions: " + state.checks
  return testkit.finish(state, "MiniSQL stored procedure edge tests: SUCCESS", "MiniSQL stored procedure edge tests: FAIL")
end function
