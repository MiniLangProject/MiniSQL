// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.sql.ast as ast
import minisql.sql.parser as parser
import tests.support.testkit as testkit

/// Requires persistence formatting to produce stable, reparsable SQL.
function roundTrip(state, sql, label)
  parsed = parser.parseSql(sql)
  testkit.equal(state, len(parsed), 1, label + " parses one definition")
  formatted = ast.formatStatement(parsed[0])
  reparsed = parser.parseSql(formatted)
  testkit.equal(state, ast.formatStatement(reparsed[0]), formatted, label + " survives persistence")
  return parsed[0]
end function

/// Exercises compound routine parsing, grammar failures and durable formatting.
function main(args)
  state = testkit.create()
  procedure = roundTrip(state,
    "CREATE DEFINER = 'owner' PROCEDURE p(IN p_id INT, OUT answer INT, INOUT total DECIMAL(12,2)) " +
    "LANGUAGE SQL NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER COMMENT 'O''Brien routine' " +
    "main_block: BEGIN " +
    "DECLARE done BOOLEAN DEFAULT FALSE; DECLARE a, b INT DEFAULT 0; " +
    "DECLARE app_error CONDITION FOR SQLSTATE '45000'; DECLARE duplicate_id CONDITION FOR 1062; " +
    "DECLARE cur CURSOR FOR SELECT id FROM sample ORDER BY id; " +
    "DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; " +
    "DECLARE EXIT HANDLER FOR app_error, 1062 BEGIN GET STACKED DIAGNOSTICS CONDITION 1 @message = MESSAGE_TEXT, @state = RETURNED_SQLSTATE; RESIGNAL SET MESSAGE_TEXT = 'failed'; END; " +
    "SET answer = 0, @done := FALSE; OPEN cur; " +
    "read_loop: LOOP FETCH NEXT FROM cur INTO a; IF done THEN LEAVE read_loop; ELSEIF a = 0 THEN ITERATE read_loop; ELSE SET total = total + a; END IF; END LOOP read_loop; CLOSE cur; " +
    "counter_loop: WHILE b < 3 DO SET b = b + 1; END WHILE counter_loop; " +
    "REPEAT SET b = b - 1; UNTIL b = 0 END REPEAT; " +
    "CASE a WHEN 1 THEN SET answer = 10; WHEN 2 THEN SET answer = 20; ELSE SET answer = 30; END CASE; " +
    "CASE WHEN a < 0 THEN SIGNAL app_error SET MESSAGE_TEXT = 'negative', MYSQL_ERRNO = 20000; ELSE SET answer = a; END CASE; " +
    "SELECT COUNT(*) INTO answer FROM sample; SELECT id FROM sample WHERE id = p_id LIMIT 1 INTO b; " +
    "CALL nested(p_id, answer); SET @sql = 'SELECT ?'; PREPARE stmt FROM @sql; EXECUTE stmt USING @done; DEALLOCATE PREPARE stmt; " +
    "START TRANSACTION; SAVEPOINT sp; ROLLBACK TO SAVEPOINT sp; RELEASE SAVEPOINT sp; COMMIT; " +
    "GET CURRENT DIAGNOSTICS @number = NUMBER, @rows = ROW_COUNT; SELECT answer, total; END main_block", "compound procedure")
  testkit.equal(state, len(procedure.parameters), 3, "three parameter modes")
  testkit.equal(state, procedure.parameters[0].mode, "IN", "IN parameter")
  testkit.equal(state, procedure.parameters[1].mode, "OUT", "OUT parameter")
  testkit.equal(state, procedure.parameters[2].mode, "INOUT", "INOUT parameter")
  testkit.equal(state, procedure.body.kind, "BLOCK", "compound block AST")
  testkit.equal(state, procedure.body.name, "main_block", "block label")
  testkit.equal(state, procedure.body.body[2].kind, "CONDITION", "condition declaration")
  testkit.equal(state, procedure.body.body[4].kind, "CURSOR", "cursor declaration")
  testkit.equal(state, procedure.body.body[5].kind, "HANDLER", "handler declaration")
  roundTrip(state, "CREATE PROCEDURE IF NOT EXISTS once() SELECT 1", "single SELECT body")
  legacy = roundTrip(state, "CREATE PROCEDURE old_style(p INT) AS INSERT INTO sample(id) VALUES(p)", "legacy AS body")
  testkit.equal(state, legacy.characteristics[0][1], "INVOKER", "legacy security defaults preserved")
  roundTrip(state, "CREATE OR REPLACE DEFINER = CURRENT_USER PROCEDURE p() BEGIN SELECT 1; END", "replace with definer")
  roundTrip(state, "ALTER PROCEDURE p SQL SECURITY INVOKER COMMENT 'new'", "ALTER characteristics")
  roundTrip(state, "SHOW CREATE PROCEDURE p", "SHOW CREATE")
  roundTrip(state, "SHOW PROCEDURE STATUS LIKE 'p%'", "SHOW STATUS LIKE")
  roundTrip(state, "SHOW PROCEDURE STATUS WHERE name = 'p'", "SHOW STATUS WHERE")
  roundTrip(state, "CREATE PROCEDURE ddl() BEGIN CREATE TABLE sample(id INT PRIMARY KEY, value VARCHAR(20) NOT NULL DEFAULT 'x', CHECK(id > 0)); CREATE INDEX ix ON sample(value) INCLUDE(id); ALTER TABLE sample ADD COLUMN other INT; DROP INDEX ix; DROP TABLE sample; END", "table DDL persistence")
  roundTrip(state, "CREATE PROCEDURE dcl() BEGIN GRANT EXECUTE, ALTER ROUTINE ON PROCEDURE p TO caller; REVOKE EXECUTE ON PROCEDURE p FROM caller; GRANT CREATE ROUTINE ON DATABASE TO caller; END", "routine privilege persistence")
  roundTrip(state, "CREATE PROCEDURE dml() BEGIN INSERT INTO sample(id) VALUES(1) ON CONFLICT(id) DO UPDATE SET id = 2 WHERE id = 1 RETURNING id; UPDATE sample SET id = 3 RETURNING id; DELETE FROM sample WHERE id = 3 RETURNING id; END", "DML suffix persistence")
  roundTrip(state, "CREATE PROCEDURE limits(IN n INT, IN start_at INT) BEGIN SELECT id FROM sample LIMIT n OFFSET start_at; SELECT id FROM sample LIMIT start_at,n; END", "parameter LIMIT/OFFSET")
  roundTrip(state, "SELECT 1 INTO @x", "top-level SELECT INTO")
  roundTrip(state, "WITH one AS (SELECT 1 AS id) SELECT id INTO @x FROM one", "CTE SELECT INTO")
  testkit.equal(state, parser.parseExpressionText("@answer").name, "@answer", "session-variable expression")
  testkit.equal(state, parser.parseExpressionText("@@session.max_sp_recursion_depth").name, "@@session.max_sp_recursion_depth", "system-variable expression")
  testkit.equal(state, parser.parseSql("SET SESSION max_sp_recursion_depth = 4")[0].names[0], "@@session.max_sp_recursion_depth", "SET SESSION target")
  testkit.equal(state, parser.parseSql("SELECT `MiXeD` FROM `sample`")[0].items[0].expression.name, "MiXeD", "MySQL quoted identifier")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() BEGIN SET @x = 1; DECLARE y INT; END")), parser.SQL_SYNTAX, "late DECLARE rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() BEGIN DECLARE c CURSOR FOR SELECT 1; DECLARE y INT; END")), parser.SQL_SYNTAX, "declaration order enforced")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() BEGIN DECLARE CONTINUE HANDLER FOR NOT FOUND SET @x = 1; DECLARE c CURSOR FOR SELECT 1; END")), parser.SQL_SYNTAX, "cursor after handler rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p(IN x INT, OUT x INT) SET @x = 1")), parser.SQL_SYNTAX, "duplicate parameters rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() b: BEGIN SELECT 1; END c")), parser.SQL_SYNTAX, "closing label mismatch rejected")
  testkit.errorCode(state, try(parser.parseSql("SIGNAL SQLSTATE '00000'")), parser.SQL_SYNTAX, "success SQLSTATE rejected")
  testkit.errorCode(state, try(parser.parseSql("SIGNAL SQLSTATE '4500'")), parser.SQL_SYNTAX, "short SQLSTATE rejected")
  testkit.errorCode(state, try(parser.parseSql("SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='a', MESSAGE_TEXT='b'")), parser.SQL_SYNTAX, "duplicate condition items rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() COMMENT 'a' COMMENT 'b' SET @x=1")), parser.SQL_SYNTAX, "duplicate characteristics rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() BEGIN SELECT 1 END")), parser.SQL_SYNTAX, "inner semicolon required")
  testkit.errorCode(state, try(parser.parseSql("SIGNAL SQLSTATE '45000' SET BOGUS='a'")), parser.SQL_SYNTAX, "unknown SIGNAL information item rejected")
  testkit.errorCode(state, try(parser.parseSql("GET DIAGNOSTICS @n = MESSAGE_TEXT")), parser.SQL_SYNTAX, "condition item requires CONDITION selector")
  testkit.errorCode(state, try(parser.parseSql("GET DIAGNOSTICS CONDITION 1 @n = ROW_COUNT")), parser.SQL_SYNTAX, "statement item cannot select condition")
  roundTrip(state, "PREPARE ddl AS CREATE TABLE dynamic_test(id INT)", "dynamic DDL preparation")
  roundTrip(state, "PREPARE query_into AS SELECT ? INTO @x", "dynamic SELECT INTO preparation")
  roundTrip(state, "PREPARE routine_call AS CALL p(?, @x)", "dynamic CALL preparation")
  testkit.errorCode(state, try(parser.parseSql("PREPARE nested AS PREPARE x AS SELECT 1")), parser.SQL_SYNTAX, "nested PREPARE rejected")
  testkit.errorCode(state, try(parser.parseSql("SHOW PROCEDURE STATUS LIKE 'p%' WHERE name = 'p'")), parser.SQL_SYNTAX, "SHOW LIKE and WHERE cannot silently override one another")
  testkit.errorCode(state, try(parser.parseSql("SELECT 1 LIMIT -1")), parser.SQL_SYNTAX, "explicit negative LIMIT is not absent LIMIT")
  testkit.errorCode(state, try(parser.parseSql("SELECT 1 FETCH FIRST -1 ROWS ONLY")), parser.SQL_SYNTAX, "negative FETCH count rejected")
  testkit.errorCode(state, try(parser.parseSql("SELECT 1 LIMIT 1, 2 OFFSET 3")), parser.SQL_SYNTAX, "duplicate OFFSET spellings rejected")
  omittedCall = roundTrip(state, "CALL public.empty_routine", "zero-argument CALL without parentheses")
  testkit.equal(state, len(omittedCall.arguments), 0, "omitted CALL parentheses create no arguments")
  roundTrip(state, "CREATE PROCEDURE calls() BEGIN CALL first_routine; CALL \"MiXeD\"; END", "nested omitted CALL parentheses")
  testkit.errorCode(state, try(parser.parseSql("CALL p 1")), parser.SQL_SYNTAX, "arguments require parentheses")
  testkit.errorCode(state, try(parser.parseSql("CALL p(,)")), parser.SQL_SYNTAX, "empty argument positions rejected")
  diagnostics = roundTrip(state, "SHOW WARNINGS LIMIT 2, 3", "warning offset and count")
  testkit.equal(state, diagnostics.kind, "SHOW_WARNINGS", "warning diagnostic kind")
  testkit.equal(state, diagnostics.options[0], 2, "warning diagnostic offset")
  testkit.equal(state, diagnostics.options[1], 3, "warning diagnostic count")
  diagnostics = roundTrip(state, "SHOW ERRORS LIMIT 0", "zero error row count")
  testkit.equal(state, diagnostics.options[1], 0, "zero LIMIT retained")
  diagnostics = roundTrip(state, "SHOW WARNINGS", "unlimited warnings")
  testkit.equal(state, diagnostics.options[1], -1, "absent warning LIMIT retained")
  roundTrip(state, "SHOW COUNT(*) WARNINGS", "warning count")
  diagnostics = roundTrip(state, "SHOW COUNT(*) ERRORS", "error count")
  testkit.equal(state, diagnostics.name, "COUNT", "error count mode")
  testkit.errorCode(state, try(parser.parseSql("SHOW WARNINGS LIMIT -1")), parser.SQL_SYNTAX, "negative diagnostic limit rejected")
  testkit.errorCode(state, try(parser.parseSql("SHOW ERRORS LIMIT -1, 2")), parser.SQL_SYNTAX, "negative diagnostic offset rejected")
  testkit.errorCode(state, try(parser.parseSql("SHOW ERRORS LIMIT 1, -2")), parser.SQL_SYNTAX, "negative second diagnostic limit rejected")
  testkit.errorCode(state, try(parser.parseSql("SHOW WARNINGS LIMIT 1.5")), parser.SQL_SYNTAX, "fractional diagnostic limit rejected")
  testkit.errorCode(state, try(parser.parseSql("SHOW COUNT(*) WARNINGS LIMIT 1")), parser.SQL_SYNTAX, "count diagnostics cannot take LIMIT")
  testkit.errorCode(state, try(parser.parseSql("SHOW COUNT(id) ERRORS")), parser.SQL_SYNTAX, "diagnostic count requires star")
  diagnostics = roundTrip(state, "SHOW WARNINGS LIMIT 1 OFFSET 2", "diagnostic OFFSET spelling")
  testkit.equal(state, diagnostics.options[0], 2, "explicit diagnostic OFFSET retained")
  testkit.equal(state, diagnostics.options[1], 1, "explicit diagnostic LIMIT retained")
  testkit.errorCode(state, try(parser.parseSql("SHOW WARNINGS LIMIT 1, 2 OFFSET 3")), parser.SQL_SYNTAX, "diagnostic OFFSET cannot be repeated")
  typed = roundTrip(state, "CREATE PROCEDURE char_types(IN p VARCHAR(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin, OUT result TEXT COLLATE utf8_bin) BEGIN DECLARE local_value CHAR(3) CHARACTER SET binary; SET result = p; END", "routine character attributes")
  testkit.equal(state, typed.parameters[0].typeName.characterSet, "utf8mb4", "parameter charset retained")
  testkit.equal(state, typed.parameters[0].typeName.collation, "utf8mb4_bin", "parameter collation retained")
  testkit.equal(state, typed.parameters[1].typeName.characterSet, "", "unspecified charset stays implicit")
  testkit.equal(state, typed.body.body[0].options[0].characterSet, "binary", "local charset retained")
  testkit.equal(state, ast.typeName("INTEGER", 0, 0, 0).collation, "", "legacy type factory defaults remain compatible")
  roundTrip(state, "CREATE PROCEDURE collate_first(IN p TEXT COLLATE utf8_bin CHARACTER SET utf8) SELECT p", "character attributes normalize order")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p(IN x INT CHARACTER SET utf8) SELECT x")), parser.SQL_SYNTAX, "numeric charset rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p(IN x TEXT CHARACTER SET utf8 CHARACTER SET utf8mb4) SELECT x")), parser.SQL_SYNTAX, "duplicate charset rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p() BEGIN DECLARE x TEXT COLLATE utf8_bin COLLATE binary; END")), parser.SQL_SYNTAX, "duplicate local collation rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p(IN x TEXT CHARACTER utf8) SELECT x")), parser.SQL_SYNTAX, "charset SET keyword required")
  testkit.errorCode(state, try(parser.parseSql("CREATE PROCEDURE p(IN x TEXT COLLATE) SELECT x")), parser.SQL_SYNTAX, "collation name required")
  trigger = roundTrip(state, "CREATE TRIGGER callback AFTER INSERT ON sample FOR EACH ROW CALL record_item(NEW.id)", "trigger CALL body")
  testkit.record(state, ast.isCallStatement(trigger.body), "trigger preserves CALL AST")
  roundTrip(state, "CREATE TRIGGER no_arguments AFTER DELETE ON sample FOR EACH ROW CALL summarize", "trigger zero-argument CALL")
  trigger = roundTrip(state, "CREATE TRIGGER compound_callback AFTER UPDATE ON sample FOR EACH ROW BEGIN DECLARE result INT; DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET @handled = 1; IF NEW.id <> OLD.id THEN CALL record_item(NEW.id, result); END IF; INSERT INTO audit_log(id) VALUES(OLD.id); END", "compound trigger body")
  testkit.equal(state, trigger.body.kind, "BLOCK", "trigger preserves compound AST")
  testkit.errorCode(state, try(parser.parseSql("CREATE TRIGGER t AFTER INSERT ON sample FOR EACH ROW BEGIN CALL p END")), parser.SQL_SYNTAX, "trigger compound statements require terminators")
  testkit.errorCode(state, try(parser.parseSql("CREATE TRIGGER t BEFORE INSERT ON sample FOR EACH ROW SET NEW.id = 1")), parser.SQL_SYNTAX, "writable NEW remains unsupported")
  roundTrip(state, "GRANT SHOW_ROUTINE, SET_ANY_DEFINER ON DATABASE TO routine_admin WITH GRANT OPTION", "routine context privileges")
  roundTrip(state, "REVOKE SHOW_ROUTINE, SET_ANY_DEFINER ON DATABASE FROM routine_admin", "routine context privilege revoke")
  testkit.equal(state, parser.parseExpressionText("@@warning_count").name, "@@warning_count", "warning count system variable")
  testkit.equal(state, parser.parseExpressionText("@@session.error_count").name, "@@session.error_count", "qualified error count system variable")
  testkit.equal(state, parser.parseExpressionText("@@session.character_set_client").name, "@@session.character_set_client", "creation charset system variable")
  roundTrip(state, "SET SESSION sql_mode = 'STRICT_TRANS_TABLES', max_error_count = 16", "creation context system assignments")
  return testkit.finish(state, "MiniSQL stored procedure parser tests: SUCCESS", "MiniSQL stored procedure parser tests: FAIL")
end function
