// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import minisql.sql.values as values
import tests.support.testkit as testkit

/// Executes one SQL statement without hiding errors or result-set boundaries.
function executeOne(engine, sql)
  return executor.executeSql(engine, sql)[0]
end function

/// Fetches a single scalar while retaining its SQL NULL/type representation.
function scalar(engine, sql)
  return executeOne(engine, sql).rows[0][0]
end function

/// Asserts a numeric scalar through the SQL value conversion contract.
function numberEquals(state, engine, sql, expected, label)
  testkit.equal(state, values.asNumber(scalar(engine, sql)), expected, label)
end function

/// Keeps later independent semantic groups visible after an unexpected error.
function groupOutcome(state, engine, outcome, label)
  testkit.record(state, typeof(outcome) != "error", label + " completes")
  if typeof(outcome) == "error" then
    print "GROUP ERROR " + label + ": code=" + outcome.code + " " + outcome.message
    ignored = try(executeOne(engine, "ROLLBACK"))
  end if
end function

/// Verifies parameter directions, typed NULL initialization and atomic output copying.
function testParameters(state, engine)
  executeOne(engine, "CREATE PROCEDURE param_modes(IN input_value INT, OUT result_value INT, INOUT accumulator INT) BEGIN SET @initial_out = result_value; SET result_value = input_value * 2, accumulator = accumulator + input_value, input_value = 999; END")
  executeOne(engine, "SET @input = 3, @result = 777, @accumulator = 5")
  executeOne(engine, "CALL param_modes(@input, @result, @accumulator)")
  testkit.record(state, scalar(engine, "SELECT @initial_out").isNull, "OUT begins NULL regardless of destination value")
  numberEquals(state, engine, "SELECT @input", 3, "IN is copied and cannot mutate caller")
  numberEquals(state, engine, "SELECT @result", 6, "OUT copied on success")
  numberEquals(state, engine, "SELECT @accumulator", 8, "INOUT copied both directions")
  executeOne(engine, "CREATE PROCEDURE null_input(IN input_value INT, OUT result_value INT) SET result_value = COALESCE(input_value, 42)")
  executeOne(engine, "CALL null_input(NULL, @null_result)")
  numberEquals(state, engine, "SELECT @null_result", 42, "NULL input retains SQL semantics")
  executeOne(engine, "CREATE PROCEDURE failed_output(OUT output_value INT, INOUT other_value INT) BEGIN SET output_value = 900, other_value = 901; SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 6001, MESSAGE_TEXT = 'intentional failure'; END")
  executeOne(engine, "SET @failed_output = 17, @failed_other = 18")
  testkit.errorCode(state, try(executeOne(engine, "CALL failed_output(@failed_output, @failed_other)")), 6001, "unhandled signal propagates exact errno")
  numberEquals(state, engine, "SELECT @failed_output", 17, "failed CALL does not copy OUT")
  numberEquals(state, engine, "SELECT @failed_other", 18, "failed CALL does not copy INOUT")
  testkit.errorCode(state, try(executeOne(engine, "CALL param_modes(1, 2, @accumulator)")), 1414, "OUT requires writable variable")
  testkit.errorCode(state, try(executeOne(engine, "CALL param_modes(1, @result)")), 1318, "argument arity validated")
  executeOne(engine, "CREATE PROCEDURE handled_output(OUT output_value INT) BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET output_value = 45; SIGNAL SQLSTATE '45000'; END")
  executeOne(engine, "CALL handled_output(@handled_output)")
  numberEquals(state, engine, "SELECT @handled_output", 45, "handled error still copies OUT")
  testkit.equal(state, len(engine.routineSession.frames), 0, "CALL frames restored after success and failure")
  return true
end function

/// Exercises lexical lifetime, local-over-parameter precedence, and every loop form.
function testScopesAndLoops(state, engine)
  executeOne(engine, "CREATE PROCEDURE scope_values(IN x INT, OUT result_value INT) b: BEGIN DECLARE x INT DEFAULT 2; BEGIN DECLARE x INT DEFAULT 10; SET @inner_x = x; SET b.x = b.x + 3; END; SET result_value = x; END")
  executeOne(engine, "CALL scope_values(99, @scope_result)")
  numberEquals(state, engine, "SELECT @inner_x", 10, "inner local shadows outer and parameter")
  numberEquals(state, engine, "SELECT @scope_result", 5, "qualified block assignment resolves outer local")
  executeOne(engine, "CREATE PROCEDURE flow_values(OUT result_value INT) BEGIN DECLARE i INT DEFAULT 0; DECLARE total INT DEFAULT 0; lp: LOOP SET i = i + 1; IF i = 3 THEN ITERATE lp; END IF; IF i > 5 THEN LEAVE lp; END IF; SET total = total + i; END LOOP; WHILE i > 0 DO SET i = i - 1; END WHILE; REPEAT SET i = i + 1; UNTIL i = 2 END REPEAT; skip_block: BEGIN SET total = total + 10; LEAVE skip_block; SET total = 999; END; SET result_value = total + i; END")
  executeOne(engine, "CALL flow_values(@flow_result)")
  numberEquals(state, engine, "SELECT @flow_result", 24, "LOOP ITERATE LEAVE WHILE REPEAT and block exit")
  executeOne(engine, "CREATE PROCEDURE local_default(OUT result_value INT) BEGIN DECLARE a INT DEFAULT 4; DECLARE b INT DEFAULT a + 2; DECLARE uninitialized INT; SET @uninitialized = uninitialized; SET result_value = b; END")
  executeOne(engine, "CALL local_default(@default_result)")
  numberEquals(state, engine, "SELECT @default_result", 6, "default expression sees preceding local")
  testkit.record(state, scalar(engine, "SELECT @uninitialized").isNull, "undeclared-default local initializes NULL")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE bad_label() BEGIN LEAVE missing_label; END")), 1308, "missing LEAVE label rejected at creation")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE bad_iterate() b: BEGIN ITERATE b; END")), 1308, "ITERATE requires loop label")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE duplicate_local() BEGIN DECLARE x INT; DECLARE x INT; END")), 1331, "same-scope duplicate variable rejected")
  return true
end function

/// Distinguishes simple/searched CASE, missing branches and SQL NULL predicates.
function testCase(state, engine)
  executeOne(engine, "CREATE PROCEDURE choose_value(IN selector INT, OUT result_value INT) BEGIN CASE selector WHEN 1 THEN SET result_value = 11; WHEN 2 THEN SET result_value = 22; ELSE SET result_value = 33; END CASE; CASE WHEN selector < 0 THEN SET result_value = 44; ELSE SET result_value = result_value + 1; END CASE; END")
  executeOne(engine, "CALL choose_value(2, @choice)")
  numberEquals(state, engine, "SELECT @choice", 23, "simple CASE chooses matching scalar")
  executeOne(engine, "CALL choose_value(-1, @choice)")
  numberEquals(state, engine, "SELECT @choice", 44, "searched CASE chooses predicate")
  executeOne(engine, "CALL choose_value(NULL, @choice)")
  numberEquals(state, engine, "SELECT @choice", 34, "NULL CASE selector does not match")
  executeOne(engine, "CREATE PROCEDURE case_missing() BEGIN CASE 2 WHEN 1 THEN SET @missing = 0; END CASE; END")
  testkit.errorCode(state, try(executeOne(engine, "CALL case_missing()")), 1339, "CASE without matching branch raises condition")
  executeOne(engine, "CREATE PROCEDURE case_handled() BEGIN DECLARE CONTINUE HANDLER FOR 1339 SET @missing = 1; CASE 2 WHEN 1 THEN SET @missing = 0; END CASE; SET @after_case = 1; END")
  executeOne(engine, "CALL case_handled()")
  numberEquals(state, engine, "SELECT @missing", 1, "CASE condition can be handled")
  numberEquals(state, engine, "SELECT @after_case", 1, "CONTINUE resumes after CASE")
  return true
end function

/// Preserves all nested SELECT results and a terminal CALL command status.
function testResultSets(state, engine)
  executeOne(engine, "CREATE PROCEDURE child_results() BEGIN SELECT 20 AS second; SELECT 30 AS third; END")
  executeOne(engine, "CREATE PROCEDURE all_results() BEGIN SELECT 10 AS first_result; CALL child_results(); SELECT 40 AS fourth; END")
  result = executeOne(engine, "CALL all_results()")
  testkit.equal(state, result.kind, executor.RESULT_MULTIPLE, "CALL exposes multiple-result type")
  testkit.equal(state, len(result.rows), 5, "four row sets and terminal status retained")
  testkit.equal(state, result.rows[4].kind, executor.RESULT_COMMAND, "CALL terminal result is command status")
  testkit.equal(state, result.rows[4].command, "CALL", "terminal status identifies CALL")
  for index = 0 to 3
    testkit.equal(state, result.rows[index].kind, executor.RESULT_ROWS, "nested result-set kind")
    testkit.equal(state, values.asNumber(result.rows[index].rows[0][0]), (index + 1) * 10, "nested result order")
  end for
  executeOne(engine, "CREATE PROCEDURE empty_body() BEGIN END")
  empty = executeOne(engine, "CALL empty_body()")
  testkit.equal(state, empty.kind, executor.RESULT_COMMAND, "no-result CALL returns command")
  return true
end function

/// Checks SELECT INTO cardinality, unchanged destinations, precedence and LIMIT locals.
function testSelectInto(state, engine)
  executeOne(engine, "CREATE TABLE routine_items(id INT PRIMARY KEY, value INT)")
  executeOne(engine, "INSERT INTO routine_items(id, value) VALUES (1, 10), (2, 20), (3, 30)")
  executeOne(engine, "CREATE PROCEDURE select_cases(OUT result_value INT) BEGIN DECLARE v INT DEFAULT 77; DECLARE no_row INT DEFAULT 0; DECLARE many_rows INT DEFAULT 0; DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_row = 1; DECLARE CONTINUE HANDLER FOR 1172 SET many_rows = 1; SELECT value INTO v FROM routine_items WHERE id = 999; SET @empty_value = v; SELECT value INTO v FROM routine_items; SET @many_value = v; SELECT value INTO v FROM routine_items WHERE id = 2; SET result_value = v + no_row + many_rows; END")
  executeOne(engine, "CALL select_cases(@selection)")
  numberEquals(state, engine, "SELECT @empty_value", 77, "zero-row SELECT INTO preserves value")
  numberEquals(state, engine, "SELECT @many_value", 77, "multirow SELECT INTO preserves value")
  numberEquals(state, engine, "SELECT @selection", 22, "both cardinality conditions handled")
  executeOne(engine, "CREATE PROCEDURE name_priority(OUT result_value INT) BEGIN DECLARE id INT DEFAULT 99; SELECT id INTO result_value FROM routine_items WHERE routine_items.id = 1; END")
  executeOne(engine, "CALL name_priority(@priority)")
  numberEquals(state, engine, "SELECT @priority", 99, "local variable wins over unqualified table column")
  executeOne(engine, "CREATE PROCEDURE select_limit(IN n INT, IN skip_rows INT, OUT result_value INT) BEGIN SELECT value INTO result_value FROM routine_items ORDER BY id LIMIT n OFFSET skip_rows; END")
  executeOne(engine, "CALL select_limit(1, 1, @limited)")
  numberEquals(state, engine, "SELECT @limited", 20, "local LIMIT and OFFSET evaluate per invocation")
  executeOne(engine, "SET @direct_into = 12")
  executeOne(engine, "SELECT value INTO @direct_into FROM routine_items WHERE id = 3")
  numberEquals(state, engine, "SELECT @direct_into", 30, "session SELECT INTO supported")
  executeOne(engine, "CREATE PROCEDURE nested_queries(IN n INT, OUT result_value INT) BEGIN SELECT (SELECT value FROM routine_items WHERE id = n) INTO result_value; WITH local_cte AS (SELECT n AS local_id) SELECT local_id INTO @cte_local FROM local_cte; END")
  executeOne(engine, "CALL nested_queries(2, @subquery_result)")
  numberEquals(state, engine, "SELECT @subquery_result", 20, "locals substitute recursively inside scalar subqueries")
  numberEquals(state, engine, "SELECT @cte_local", 2, "locals substitute inside CTE queries")
  executeOne(engine, "CREATE PROCEDURE no_row_continue(OUT result_value INT) BEGIN SET result_value = 5; SELECT value INTO result_value FROM routine_items WHERE id = 999; SET result_value = result_value + 1; END")
  executeOne(engine, "CALL no_row_continue(@no_row_result)")
  numberEquals(state, engine, "SELECT @no_row_result", 6, "unhandled natural NOT FOUND continues")
  executeOne(engine, "CREATE PROCEDURE explicit_not_found() SIGNAL SQLSTATE '02000'")
  testkit.errorCode(state, try(executeOne(engine, "CALL explicit_not_found()")), 1643, "explicit unhandled NOT FOUND exits")
  return true
end function

/// Exercises read-only forward cursors, EOF handlers, lifetime and reopen semantics.
function testCursors(state, engine)
  executeOne(engine, "CREATE PROCEDURE cursor_sum(OUT result_value INT) BEGIN DECLARE done BOOLEAN DEFAULT FALSE; DECLARE item INT; DECLARE total INT DEFAULT 0; DECLARE c CURSOR FOR SELECT id FROM routine_items ORDER BY id; DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; OPEN c; read_rows: LOOP FETCH c INTO item; IF done THEN LEAVE read_rows; END IF; SET total = total + item; END LOOP; CLOSE c; OPEN c; FETCH c INTO item; CLOSE c; SET result_value = total; SET @reopened_first = item; END")
  executeOne(engine, "CALL cursor_sum(@cursor_total)")
  numberEquals(state, engine, "SELECT @cursor_total", 6, "cursor consumes ordered rows once")
  numberEquals(state, engine, "SELECT @reopened_first", 1, "reopening cursor resets position")
  executeOne(engine, "CREATE PROCEDURE cursor_errors() BEGIN DECLARE x INT; DECLARE c CURSOR FOR SELECT 1; DECLARE CONTINUE HANDLER FOR 1325 SET @already_open = 1; DECLARE CONTINUE HANDLER FOR 1326 SET @not_open = COALESCE(@not_open, 0) + 1; SET @not_open = 0; FETCH c INTO x; OPEN c; OPEN c; CLOSE c; CLOSE c; END")
  executeOne(engine, "CALL cursor_errors()")
  numberEquals(state, engine, "SELECT @already_open", 1, "double OPEN is catchable")
  numberEquals(state, engine, "SELECT @not_open", 2, "FETCH/CLOSE require open cursor")
  executeOne(engine, "CREATE PROCEDURE cursor_shadow(OUT result_value INT) BEGIN DECLARE x INT; DECLARE c CURSOR FOR SELECT 11; OPEN c; BEGIN DECLARE c CURSOR FOR SELECT 22; OPEN c; FETCH c INTO x; SET @inner_cursor = x; END; FETCH c INTO x; CLOSE c; SET result_value = x; END")
  executeOne(engine, "CALL cursor_shadow(@outer_cursor)")
  numberEquals(state, engine, "SELECT @inner_cursor", 22, "inner cursor shadows outer cursor")
  numberEquals(state, engine, "SELECT @outer_cursor", 11, "outer cursor remains independently open")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE missing_cursor() BEGIN OPEN c; END")), 1324, "undefined cursor rejected at creation")
  return true
end function

/// Covers handler specificity, lexical precedence, EXIT and handler error propagation.
function testHandlers(state, engine)
  executeOne(engine, "CREATE PROCEDURE handler_priority() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @handler = 1; DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET @handler = 2; DECLARE CONTINUE HANDLER FOR 6002 SET @handler = 3; SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 6002; END")
  executeOne(engine, "CALL handler_priority()")
  numberEquals(state, engine, "SELECT @handler", 3, "errno handler outranks SQLSTATE and class")
  executeOne(engine, "CREATE PROCEDURE handler_scope() BEGIN DECLARE CONTINUE HANDLER FOR 6002 SET @handler = 9; BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @handler = 4; SIGNAL SQLSTATE '45000' SET MYSQL_ERRNO = 6002; END; END")
  executeOne(engine, "CALL handler_scope()")
  numberEquals(state, engine, "SELECT @handler", 4, "inner generic handler outranks outer exact handler")
  executeOne(engine, "CREATE PROCEDURE exit_scope() BEGIN SET @exit_marker = 0; BEGIN DECLARE EXIT HANDLER FOR SQLSTATE '45000' SET @exit_marker = 1; SIGNAL SQLSTATE '45000'; SET @exit_marker = 99; END; SET @exit_marker = @exit_marker + 1; END")
  executeOne(engine, "CALL exit_scope()")
  numberEquals(state, engine, "SELECT @exit_marker", 2, "EXIT skips rest of declaring block only")
  executeOne(engine, "CREATE PROCEDURE sibling_handlers() BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45001' SET @sibling_marker = 8; BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SIGNAL SQLSTATE '45001'; DECLARE CONTINUE HANDLER FOR SQLSTATE '45001' SET @sibling_marker = 99; SIGNAL SQLSTATE '45000'; END; SET @sibling_after = 1; END")
  executeOne(engine, "CALL sibling_handlers()")
  numberEquals(state, engine, "SELECT @sibling_marker", 8, "handler error bypasses sibling handler")
  numberEquals(state, engine, "SELECT @sibling_after", 1, "outer CONTINUE resumes after handled block")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE duplicate_handler() BEGIN DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET @a = 1; DECLARE EXIT HANDLER FOR SQLEXCEPTION SET @a = 2; END")), 1413, "duplicate condition handler rejected")
  testkit.errorCode(state, try(executeOne(engine, "CREATE PROCEDURE undefined_condition() BEGIN DECLARE CONTINUE HANDLER FOR missing SET @a = 1; END")), 1319, "undefined named condition rejected")
  return true
end function

/// Verifies stable stacked diagnostics and RESIGNAL condition enrichment.
function testDiagnostics(state, engine)
  executeOne(engine, "CREATE PROCEDURE diagnostic_capture() BEGIN DECLARE app_error CONDITION FOR SQLSTATE '45002'; DECLARE CONTINUE HANDLER FOR app_error BEGIN GET STACKED DIAGNOSTICS CONDITION 1 @diagnostic_state = RETURNED_SQLSTATE, @diagnostic_errno = MYSQL_ERRNO, @diagnostic_message = MESSAGE_TEXT; SET @diagnostic_work = 1; GET STACKED DIAGNOSTICS CONDITION 1 @diagnostic_preserved = MESSAGE_TEXT; END; SIGNAL app_error SET MYSQL_ERRNO = 6003, MESSAGE_TEXT = 'precise message'; END")
  executeOne(engine, "CALL diagnostic_capture()")
  testkit.equal(state, scalar(engine, "SELECT @diagnostic_state").value, "45002", "stacked SQLSTATE preserved")
  numberEquals(state, engine, "SELECT @diagnostic_errno", 6003, "stacked errno preserved")
  testkit.equal(state, scalar(engine, "SELECT @diagnostic_message").value, "precise message", "stacked message captured")
  testkit.equal(state, scalar(engine, "SELECT @diagnostic_preserved").value, "precise message", "handler statements do not overwrite stacked diagnostics")
  executeOne(engine, "CREATE PROCEDURE resignal_capture() BEGIN DECLARE CONTINUE HANDLER FOR SQLSTATE '45003' BEGIN GET STACKED DIAGNOSTICS CONDITION 1 @resignal_message = MESSAGE_TEXT, @resignal_errno = MYSQL_ERRNO; END; BEGIN DECLARE EXIT HANDLER FOR SQLSTATE '45003' RESIGNAL SET MESSAGE_TEXT = 'enriched'; SIGNAL SQLSTATE '45003' SET MYSQL_ERRNO = 6004, MESSAGE_TEXT = 'original'; END; END")
  executeOne(engine, "CALL resignal_capture()")
  testkit.equal(state, scalar(engine, "SELECT @resignal_message").value, "enriched", "RESIGNAL enriches message")
  numberEquals(state, engine, "SELECT @resignal_errno", 6004, "bare RESIGNAL retains errno")
  executeOne(engine, "CREATE PROCEDURE warning_capture() BEGIN SIGNAL SQLSTATE '01000' SET MYSQL_ERRNO = 6005, MESSAGE_TEXT = 'warning'; GET CURRENT DIAGNOSTICS CONDITION 1 @warning_state = RETURNED_SQLSTATE, @warning_errno = MYSQL_ERRNO; SET @warning_after = 1; END")
  executeOne(engine, "CALL warning_capture()")
  testkit.equal(state, scalar(engine, "SELECT @warning_state").value, "01000", "warning diagnostic remains readable")
  numberEquals(state, engine, "SELECT @warning_errno", 6005, "warning errno retained")
  numberEquals(state, engine, "SELECT @warning_after", 1, "unhandled SQLWARNING continues")
  testkit.errorCode(state, try(executeOne(engine, "RESIGNAL")), 1645, "RESIGNAL requires active handler")
  return true
end function

/// Ensures recursive limits, session-scoped dynamic SQL and recoverable transactions.
function testCallsDynamicAndTransactions(state, engine)
  executeOne(engine, "CREATE PROCEDURE factorial(IN n INT, OUT result_value INT) BEGIN DECLARE partial INT; IF n <= 1 THEN SET result_value = 1; ELSE CALL factorial(n - 1, partial); SET result_value = n * partial; END IF; END")
  testkit.errorCode(state, try(executeOne(engine, "CALL factorial(3, @factorial)")), 1456, "recursive CALL disabled by default")
  executeOne(engine, "SET SESSION max_sp_recursion_depth = 8")
  executeOne(engine, "CALL factorial(5, @factorial)")
  numberEquals(state, engine, "SELECT @factorial", 120, "recursive frames isolate parameters and outputs")
  numberEquals(state, engine, "SELECT @@max_sp_recursion_depth", 8, "session recursion setting readable")
  executeOne(engine, "SET max_sp_recursion_depth = 0")
  executeOne(engine, "CREATE PROCEDURE prepare_dynamic() BEGIN SET @dynamic_sql = 'SELECT ? + 1 AS dynamic_result'; PREPARE dynamic_stmt FROM @dynamic_sql; EXECUTE dynamic_stmt USING @dynamic_arg; END")
  executeOne(engine, "SET @dynamic_arg = 8")
  dynamic = executeOne(engine, "CALL prepare_dynamic()")
  testkit.equal(state, values.asNumber(dynamic.rows[0].rows[0][0]), 9, "dynamic EXECUTE emits result inside CALL")
  executeOne(engine, "SET @dynamic_arg = 19")
  numberEquals(state, engine, "EXECUTE dynamic_stmt USING @dynamic_arg", 20, "prepared statement survives procedure return")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_stmt")
  executeOne(engine, "PREPARE dynamic_into FROM 'SELECT ? INTO @prepared_select'")
  executeOne(engine, "EXECUTE dynamic_into USING @dynamic_arg")
  numberEquals(state, engine, "SELECT @prepared_select", 19, "prepared SELECT INTO assigns session variable")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_into")
  executeOne(engine, "PREPARE dynamic_call FROM 'CALL null_input(?, ?)'")
  executeOne(engine, "SET @prepared_out = 666")
  executeOne(engine, "EXECUTE dynamic_call USING @dynamic_arg, @prepared_out")
  numberEquals(state, engine, "SELECT @prepared_out", 19, "prepared CALL supports input and OUT parameter markers")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_call")
  executeOne(engine, "PREPARE dynamic_modes FROM 'CALL param_modes(?, ?, ?)'")
  executeOne(engine, "SET @mode_input = 3, @mode_output = 0, @mode_accumulator = 5")
  executeOne(engine, "EXECUTE dynamic_modes USING @mode_input, @mode_output, @mode_accumulator")
  numberEquals(state, engine, "SELECT @mode_output", 6, "prepared CALL OUT marker copies back")
  numberEquals(state, engine, "SELECT @mode_accumulator", 8, "prepared CALL INOUT marker copies both ways")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_modes")
  executeOne(engine, "PREPARE dynamic_set FROM 'SET @prepared_set = ? + 3'")
  executeOne(engine, "EXECUTE dynamic_set USING @dynamic_arg")
  numberEquals(state, engine, "SELECT @prepared_set", 22, "prepared SET parameter assignment")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_set")
  executeOne(engine, "PREPARE dynamic_limit FROM 'SELECT value FROM routine_items ORDER BY id LIMIT ? OFFSET ?'")
  executeOne(engine, "SET @dynamic_count = 1, @dynamic_skip = 1")
  numberEquals(state, engine, "EXECUTE dynamic_limit USING @dynamic_count, @dynamic_skip", 20, "prepared LIMIT/OFFSET markers substitute before binding")
  executeOne(engine, "DEALLOCATE PREPARE dynamic_limit")
  executeOne(engine, "CREATE PROCEDURE prepared_ddl() BEGIN PREPARE dynamic_ddl FROM 'CREATE TABLE routine_prepared_table(id INT)'; EXECUTE dynamic_ddl; DEALLOCATE PREPARE dynamic_ddl; END")
  executeOne(engine, "CALL prepared_ddl()")
  testkit.record(state, catalog.findTable(engine.database.catalogHandle, "routine_prepared_table") is not void, "dynamic table DDL executes inside procedure")
  executeOne(engine, "DROP TABLE routine_prepared_table")
  executeOne(engine, "CREATE PROCEDURE dynamic_scope() BEGIN DECLARE hidden_local INT DEFAULT 123; PREPARE scoped_stmt FROM 'SELECT hidden_local'; EXECUTE scoped_stmt; END")
  inaccessible = try(executeOne(engine, "CALL dynamic_scope()"))
  testkit.record(state, typeof(inaccessible) == "error", "prepared SQL cannot access procedure local variables")
  executeOne(engine, "CREATE TABLE routine_tx(id INT PRIMARY KEY, value INT)")
  executeOne(engine, "CREATE PROCEDURE handled_transaction() BEGIN DECLARE CONTINUE HANDLER FOR 1062 SET @duplicate_handled = 1; START TRANSACTION; INSERT INTO routine_tx VALUES(1, 10); INSERT INTO routine_tx VALUES(1, 99); INSERT INTO routine_tx VALUES(2, 20); COMMIT; END")
  executeOne(engine, "CALL handled_transaction()")
  numberEquals(state, engine, "SELECT @duplicate_handled", 1, "native uniqueness maps to MySQL handler errno")
  numberEquals(state, engine, "SELECT COUNT(*) FROM routine_tx", 2, "handled failed statement does not poison transaction")
  numberEquals(state, engine, "SELECT SUM(value) FROM routine_tx", 30, "statement rollback preserves earlier successful writes")
  executeOne(engine, "CREATE PROCEDURE rollback_transaction() BEGIN START TRANSACTION; INSERT INTO routine_tx VALUES(3, 30); ROLLBACK; END")
  executeOne(engine, "CALL rollback_transaction()")
  numberEquals(state, engine, "SELECT COUNT(*) FROM routine_tx", 2, "ROLLBACK inside procedure works")
  return true
end function

/// Checks routine metadata, idempotent DDL, characteristics and ordinary DDL bodies.
function testMetadata(state, engine)
  executeOne(engine, "CREATE PROCEDURE metadata_proc(IN amount DECIMAL(12,2), OUT result_value INT) DETERMINISTIC READS SQL DATA SQL SECURITY INVOKER COMMENT 'metadata comment' SET result_value = 71")
  executeOne(engine, "CREATE PROCEDURE IF NOT EXISTS metadata_proc() SELECT 999")
  meta = executeOne(engine, "SELECT routine_name, security_type, is_deterministic, sql_data_access, routine_comment FROM information_schema.routines WHERE routine_name = 'metadata_proc'")
  testkit.equal(state, len(meta.rows), 1, "routine exposed exactly once")
  testkit.equal(state, meta.rows[0][1].value, "INVOKER", "SQL SECURITY persisted")
  testkit.equal(state, meta.rows[0][2].value, "YES", "deterministic flag persisted")
  testkit.equal(state, meta.rows[0][3].value, "READS SQL DATA", "data-access characteristic persisted")
  testkit.equal(state, meta.rows[0][4].value, "metadata comment", "routine comment persisted")
  parameters = executeOne(engine, "SELECT parameter_name, parameter_mode, data_type, numeric_precision, numeric_scale FROM information_schema.parameters WHERE specific_name = 'metadata_proc' ORDER BY ordinal_position")
  testkit.equal(state, len(parameters.rows), 2, "ordered parameters exposed")
  testkit.equal(state, parameters.rows[0][1].value, "IN", "input mode in metadata")
  testkit.equal(state, parameters.rows[1][1].value, "OUT", "output mode in metadata")
  testkit.equal(state, values.asNumber(parameters.rows[0][3]), 12, "decimal precision in metadata")
  testkit.equal(state, values.asNumber(parameters.rows[0][4]), 2, "decimal scale in metadata")
  show = executeOne(engine, "SHOW CREATE PROCEDURE metadata_proc")
  testkit.equal(state, len(show.rows), 1, "SHOW CREATE emits one definition")
  executeOne(engine, "ALTER PROCEDURE metadata_proc SQL SECURITY DEFINER COMMENT 'changed'")
  testkit.equal(state, scalar(engine, "SELECT routine_comment FROM information_schema.routines WHERE routine_name = 'metadata_proc'").value, "changed", "ALTER updates comment")
  statuses = executeOne(engine, "SHOW PROCEDURE STATUS LIKE 'metadata_%'")
  testkit.equal(state, len(statuses.rows), 1, "SHOW status filters LIKE")
  filtered = executeOne(engine, "SHOW PROCEDURE STATUS WHERE name = 'metadata_proc'")
  testkit.equal(state, len(filtered.rows), 1, "SHOW status evaluates WHERE predicate")
  executeOne(engine, "CREATE PROCEDURE table_ddl() BEGIN CREATE TABLE routine_ddl_table(id INT PRIMARY KEY); INSERT INTO routine_ddl_table VALUES(1); DROP TABLE routine_ddl_table; END")
  executeOne(engine, "CALL table_ddl()")
  testkit.record(state, catalog.findTable(engine.database.catalogHandle, "routine_ddl_table") is void, "ordinary table DDL works in procedure")
  executeOne(engine, "CREATE PROCEDURE durable_sum(IN a INT, OUT result_value INT) BEGIN DECLARE b INT DEFAULT 7; SET result_value = a + b; END")
  return true
end function

/// Definer authority is bounded by EXECUTE and restored after every call path.
function testSecurity(state, engine, managed)
  executeOne(engine, "CREATE TABLE routine_secret(id INT PRIMARY KEY, value INT)")
  executeOne(engine, "INSERT INTO routine_secret VALUES(1, 73)")
  executeOne(engine, "CREATE USER routine_caller WITH PASSWORD 'Routine-Caller-Password-2026!'")
  executeOne(engine, "GRANT CONNECT ON DATABASE TO routine_caller")
  executeOne(engine, "CREATE PROCEDURE secret_definer(OUT result_value INT) SQL SECURITY DEFINER SELECT value INTO result_value FROM routine_secret WHERE id = 1")
  executeOne(engine, "CREATE PROCEDURE secret_invoker(OUT result_value INT) SQL SECURITY INVOKER SELECT value INTO result_value FROM routine_secret WHERE id = 1")
  executeOne(engine, "GRANT EXECUTE ON PROCEDURE secret_definer TO routine_caller")
  executeOne(engine, "GRANT EXECUTE ON PROCEDURE secret_invoker TO routine_caller")
  principal = catalog.findPrincipal(managed.catalogHandle, "routine_caller")
  caller = executor.attach(managed)
  executor.setPrincipal(caller, principal.principalId)
  denied = try(executeOne(caller, "SELECT value FROM routine_secret"))
  testkit.errorCode(state, denied, 9029, "caller cannot directly read protected table")
  succeeded = try(executeOne(caller, "CALL secret_definer(@secret)"))
  testkit.record(state, typeof(succeeded) != "error", "EXECUTE permits authorized definer operation")
  if typeof(succeeded) != "error" then numberEquals(state, caller, "SELECT @secret", 73, "definer result copied to caller") end if
  testkit.errorCode(state, try(executeOne(caller, "CALL secret_invoker(@secret)")), 9029, "invoker routine respects caller table privileges")
  testkit.equal(state, caller.principalId, principal.principalId, "caller identity restored after denied CALL")
  testkit.record(state, not caller.trusted, "CALL cannot grant trusted engine status")
  executeOne(engine, "REVOKE EXECUTE ON PROCEDURE secret_definer FROM routine_caller")
  testkit.errorCode(state, try(executeOne(caller, "CALL secret_definer(@secret)")), 9029, "EXECUTE revoke takes effect")
  testkit.errorCode(state, try(executeOne(caller, "ALTER PROCEDURE secret_invoker COMMENT 'forbidden'")), 9029, "EXECUTE does not imply ALTER ROUTINE")
  executor.close(caller)
  return true
end function

/// Runs independent semantic groups against a native engine and verifies reopen.
function main(args)
  if len(args) != 1 then print "MiniSQL stored procedure runtime tests: FAIL (missing data root)"; return 1 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "stored_procedure_runtime", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  groupOutcome(state, engine, try(testParameters(state, engine)), "parameters")
  groupOutcome(state, engine, try(testScopesAndLoops(state, engine)), "scopes and loops")
  groupOutcome(state, engine, try(testCase(state, engine)), "CASE")
  groupOutcome(state, engine, try(testResultSets(state, engine)), "result sets")
  groupOutcome(state, engine, try(testSelectInto(state, engine)), "SELECT INTO")
  groupOutcome(state, engine, try(testCursors(state, engine)), "cursors")
  groupOutcome(state, engine, try(testHandlers(state, engine)), "handlers")
  groupOutcome(state, engine, try(testDiagnostics(state, engine)), "diagnostics")
  groupOutcome(state, engine, try(testCallsDynamicAndTransactions(state, engine)), "calls, dynamic SQL and transactions")
  groupOutcome(state, engine, try(testMetadata(state, engine)), "metadata and DDL")
  groupOutcome(state, engine, try(testSecurity(state, engine, managed)), "security")
  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  persisted = try(executeOne(reopened, "CALL durable_sum(5, @durable_result)"))
  testkit.record(state, typeof(persisted) != "error", "compound procedure survives close and reopen")
  if typeof(persisted) != "error" then numberEquals(state, reopened, "SELECT @durable_result", 12, "reopened procedure executes persisted body") end if
  testkit.record(state, scalar(reopened, "SELECT @input").isNull, "user variables do not leak into new session")
  executor.close(reopened)
  print "Stored procedure runtime assertions: " + state.checks
  return testkit.finish(state, "MiniSQL stored procedure runtime tests: SUCCESS", "MiniSQL stored procedure runtime tests: FAIL")
end function
