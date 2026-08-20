// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.sql.ast as ast
import minisql.sql.lexer as lexer
import minisql.sql.parser as parser
import minisql.sql.token as token
import tests.support.testkit as testkit

// Runs the sql frontend test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  state = testkit.create()

  tokens = lexer.tokenizeSql("-- heading\nSELECT \"Mixed Name\", 'O''Brien', 12, 3.5e2 FROM sample /* tail */;")
  testkit.record(state, token.isKeyword(tokens[0], "SELECT"), "SELECT keyword")
  testkit.record(state, token.isKind(tokens[1], token.TokenKind.Identifier), "quoted identifier token")
  testkit.equal(state, tokens[1].text, "Mixed Name", "quoted identifier preserves case and space")
  testkit.record(state, tokens[1].quoted, "quoted identifier flag")
  testkit.equal(state, tokens[3].value, "O'Brien", "escaped SQL string")
  testkit.record(state, token.isKind(tokens[5], token.TokenKind.IntegerLiteral), "integer token")
  testkit.record(state, token.isKind(tokens[7], token.TokenKind.FloatLiteral), "float token")
  testkit.record(state, token.isKind(tokens[len(tokens) - 1], token.TokenKind.EndOfInput), "EOF token")

  sql = "CREATE TABLE customer (" +
    "id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, " +
    "email VARCHAR(320) NOT NULL UNIQUE, " +
    "balance DECIMAL(18,2) NOT NULL DEFAULT 0 CHECK (balance >= 0), " +
    "parent_id BIGINT, " +
    "CONSTRAINT fk_parent FOREIGN KEY (parent_id) REFERENCES customer(id) ON DELETE RESTRICT" +
    "); " +
    "CREATE UNIQUE INDEX ux_customer_email ON customer(email); " +
    "INSERT INTO customer(email, balance) VALUES ('a@example.org', 10), ('b@example.org', 20); " +
    "UPDATE customer SET balance = balance + 5 WHERE email LIKE '%@example.org'; " +
    "DELETE FROM customer WHERE balance < 0; " +
    "SELECT DISTINCT id, email AS address FROM customer c WHERE balance >= 10 AND email IS NOT NULL ORDER BY email DESC NULLS LAST LIMIT 5 OFFSET 1; " +
    "BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED READ WRITE; COMMIT; ROLLBACK;"
  statements = parser.parseSql(sql)
  testkit.equal(state, len(statements), 9, "multi-statement parse count")
  create = statements[0]
  testkit.record(state, ast.isCreateTableStatement(create), "CREATE TABLE AST")
  testkit.equal(state, create.name, "customer", "canonical unquoted table name")
  testkit.equal(state, len(create.columns), 4, "CREATE TABLE column count")
  testkit.equal(state, create.columns[0].typeName.name, "BIGINT", "BIGINT type")
  testkit.record(state, create.columns[0].identity, "identity clause")
  testkit.record(state, create.columns[0].primaryKey, "column primary key")
  testkit.equal(state, create.columns[1].typeName.length, 320, "VARCHAR length")
  testkit.record(state, not create.columns[1].nullable, "NOT NULL")
  testkit.equal(state, create.columns[2].typeName.precision, 18, "DECIMAL precision")
  testkit.equal(state, create.columns[2].typeName.scale, 2, "DECIMAL scale")
  testkit.equal(state, len(create.constraints), 1, "table constraint count")
  testkit.equal(state, create.constraints[0].onDelete, "RESTRICT", "FK delete action")

  testkit.record(state, ast.isCreateIndexStatement(statements[1]), "CREATE INDEX AST")
  testkit.record(state, statements[1].unique, "unique index flag")
  testkit.record(state, ast.isInsertStatement(statements[2]), "INSERT AST")
  testkit.equal(state, len(statements[2].rows), 2, "multi-row INSERT")
  testkit.record(state, ast.isUpdateStatement(statements[3]), "UPDATE AST")
  testkit.equal(state, ast.formatExpression(statements[3].assignments[0].expression), "(balance + 5)", "expression formatting")
  testkit.record(state, ast.isDeleteStatement(statements[4]), "DELETE AST")
  select = statements[5]
  testkit.record(state, ast.isSelectStatement(select), "SELECT AST")
  testkit.record(state, select.distinct, "SELECT DISTINCT")
  testkit.equal(state, select.tableAlias, "c", "table alias")
  testkit.equal(state, select.items[1].alias, "address", "select alias")
  testkit.equal(state, len(select.orderBy), 1, "ORDER BY count")
  testkit.record(state, select.orderBy[0].descending, "ORDER BY DESC")
  testkit.record(state, select.orderBy[0].nullsSpecified, "NULLS placement specified")
  testkit.equal(state, select.limit, 5, "LIMIT")
  testkit.equal(state, select.offset, 1, "OFFSET")
  testkit.record(state, ast.isBeginStatement(statements[6]), "BEGIN AST")
  testkit.equal(state, statements[6].isolationLevel, "READ COMMITTED", "BEGIN isolation")
  testkit.record(state, not statements[6].readOnly, "BEGIN read-write")
  testkit.record(state, ast.isCommitStatement(statements[7]), "COMMIT AST")
  testkit.record(state, ast.isRollbackStatement(statements[8]), "ROLLBACK AST")

  expression = parser.parseExpressionText("NOT (a = 1 OR b IS NULL)")
  testkit.record(state, ast.isUnaryExpression(expression), "standalone expression parse")
  testkit.equal(state, ast.formatExpression(expression), "NOT (((a = 1) OR (b IS NULL)))", "expression precedence")

  contextual = parser.parseSql(
    "CREATE TABLE text (text VARCHAR(80), date DATE, count INTEGER, action VARCHAR(20)); " +
    "INSERT INTO text(text, date, count, action) VALUES ('ok', '2026-07-27', 1, 'INSERT'); " +
    "SELECT text, date, count, action FROM text; ANALYZE text;"
  )
  testkit.equal(state, len(contextual), 4, "contextual keyword identifier statement count")
  testkit.equal(state, contextual[0].name, "text", "type keyword accepted as table name")
  testkit.equal(state, contextual[0].columns[0].name, "text", "TEXT accepted as column name")
  testkit.equal(state, contextual[0].columns[1].name, "date", "DATE accepted as column name")
  testkit.equal(state, contextual[0].columns[2].name, "count", "aggregate name accepted as column name")
  testkit.equal(state, contextual[0].columns[3].name, "action", "ACTION accepted as contextual column name")
  testkit.equal(state, contextual[1].columns[0], "text", "contextual INSERT column canonicalized")
  testkit.equal(state, contextual[1].columns[3], "action", "ACTION INSERT column canonicalized")
  testkit.equal(state, contextual[2].items[0].expression.name, "text", "contextual SELECT column parsed")
  testkit.equal(state, contextual[2].items[3].expression.name, "action", "ACTION SELECT column parsed")
  testkit.equal(state, contextual[3].tableName, "text", "contextual ANALYZE table parsed")

  noAction = parser.parseSql(
    "CREATE TABLE action_parent (id INTEGER PRIMARY KEY); " +
    "CREATE TABLE action_child (id INTEGER PRIMARY KEY, parent_id INTEGER, " +
    "FOREIGN KEY (parent_id) REFERENCES action_parent(id) ON DELETE NO ACTION ON UPDATE NO ACTION);"
  )
  testkit.equal(state, noAction[1].constraints[0].onDelete, "NO ACTION", "ACTION remains referential-action grammar")
  testkit.equal(state, noAction[1].constraints[0].onUpdate, "NO ACTION", "ACTION remains update-action grammar")

  triggerRows = parser.parseSql(
    "CREATE TRIGGER audit_change AFTER UPDATE OF value ON source_event FOR EACH ROW " +
    "INSERT INTO audit_event(id, old_value, new_value) VALUES (NEW.id, OLD.value, NEW.value);"
  )
  testkit.equal(state, len(triggerRows), 1, "trigger pseudo-row statement count")
  testkit.record(state, ast.isCreateTriggerStatement(triggerRows[0]), "CREATE TRIGGER AST")
  triggerBody = triggerRows[0].body
  testkit.record(state, ast.isInsertStatement(triggerBody), "trigger body INSERT AST")
  testkit.equal(state, triggerBody.rows[0][0].qualifier, "new", "NEW pseudo-row qualifier canonicalized")
  testkit.equal(state, triggerBody.rows[0][0].name, "id", "NEW pseudo-row column parsed")
  testkit.equal(state, triggerBody.rows[0][1].qualifier, "old", "OLD pseudo-row qualifier canonicalized")
  testkit.equal(state, triggerBody.rows[0][1].name, "value", "OLD pseudo-row column parsed")
  testkit.equal(state, triggerBody.rows[0][2].qualifier, "new", "second NEW qualifier parsed")
  testkit.equal(state, ast.formatExpression(triggerBody.rows[0][1]), "old.value", "trigger pseudo-row expression formatting")
  testkit.errorCode(state, try(parser.parseExpressionText("NEW")), parser.SQL_SYNTAX, "NEW remains reserved outside qualified trigger reference")
  testkit.errorCode(state, try(parser.parseExpressionText("OLD")), parser.SQL_SYNTAX, "OLD remains reserved outside qualified trigger reference")

  testkit.errorCode(state, try(parser.parseSql("SELECT FROM")), parser.SQL_SYNTAX, "invalid SELECT rejected")
  testkit.errorCode(state, try(lexer.tokenizeSql("SELECT 'unterminated")), lexer.SQL_SYNTAX, "unterminated string rejected")
  testkit.errorCode(state, try(parser.parseSql("CREATE TABLE x ()")), parser.SQL_SYNTAX, "empty table rejected")

  return testkit.finish(state, "MiniSQL M12 SQL front-end tests: SUCCESS", "MiniSQL M12 SQL front-end tests: FAIL")
end function
