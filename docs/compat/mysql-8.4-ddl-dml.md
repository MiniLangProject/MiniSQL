# MiniSQL 1.1 MySQL 8.4 DDL/DML compatibility

MiniSQL 1.1 targets a `mysql84` SQL dialect for common MySQL 8.4 DDL and DML
syntax while preserving the MiniSQL 1.0 dialect. This matrix is intentionally
test driven: every `supported`, `parse-only`, `accepted-ignored`, or
`unsupported` row must have a parser, binder, executor, or static acceptance
test before it is marked complete.

Status values:

- `supported`: parsed, bound, executed, and covered by regression tests.
- `parse-only`: accepted into an AST but execution is rejected with a clear
  diagnostic.
- `accepted-ignored`: accepted for MySQL dump compatibility and intentionally
  ignored or stored as metadata.
- `unsupported`: rejected in `mysql84` mode with a MySQL-compatibility note.

## M51 Baseline Scope

| Area | MySQL syntax family | MiniSQL 1.1 target |
|---|---|---|
| Dialect | Backtick identifiers, `#` comments, MySQL single/double-quoted strings and string escapes | supported |
| SELECT | `LIMIT offset,row_count` | supported |
| SELECT | `FULL OUTER JOIN` | unsupported in `mysql84` |
| DDL | `CREATE TABLE` table options such as `ENGINE`, `CHARSET`, `COLLATE`, `COMMENT` | accepted-ignored |
| DDL | Inline `KEY` and `INDEX` definitions | supported |
| DML | `INSERT ... SET`, `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE` | supported |
| DML | `UPDATE ... ORDER BY ... LIMIT` | supported |
| DML | `DELETE ... ORDER BY ... LIMIT` | supported |
| Types | `TINYINT`, `MEDIUMINT`, `INT`, `INTEGER`, `BIGINT`, `UNSIGNED`, `DATETIME`, `YEAR` | supported or mapped |
| Types | `JSON`, `ENUM`, `SET`, text/blob size aliases | parse-only or mapped |

## Implemented 1.1 Milestones

| Milestone | Coverage |
|---|---|
| M51 | Separate `mysql84` lexer/parser entry points; MiniSQL 1.0 parsing remains strict. |
| M52 | MySQL DDL surface: backtick/double-quote behavior, table options, inline indexes, `DROP INDEX ... ON ...`, MySQL type aliases. |
| M53 | MySQL DML execution: `INSERT ... SET`, `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE`, `UPDATE/DELETE ORDER BY LIMIT`. |
| M54 | MySQL SELECT syntax: `JOIN ... USING`, `&&`, `||`, unary `!`, `IFNULL()`, `NOW()`. |
| M55 | MySQL ALTER TABLE compatibility for metadata-safe `ADD COLUMN ... AFTER`, `ADD INDEX`, and `DROP INDEX`; rewrite-heavy `MODIFY`, `CHANGE`, and `DROP COLUMN` are rejected clearly. |
| M56 | MySQL DML modifiers and aliases: `LOW_PRIORITY`, `HIGH_PRIORITY`, `DELAYED`, `QUICK`, `IGNORE`, and singular `VALUE`. |

## Execution Model

The public MiniSQL SQL path still uses `parser.parseSql` and `executor.executeSql`.
MySQL compatibility is opt-in through `parser.parseMySql` and
`executor.executeMySql`, so existing MiniSQL 1.0 applications do not silently
change dialect semantics.

## Deliberate 1.1 Exclusions

Stored routines, procedure bodies, events, MySQL trigger bodies, replication
administration, engine-specific partition execution, and administrative SQL are
outside the MiniSQL 1.1 DDL/DML compatibility goal.
