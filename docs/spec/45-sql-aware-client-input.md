# SQL-aware client input and script specification

## Scope

M33 replaces the temporary one-statement-per-line client rule with a bounded,
SQL-aware statement scanner used by both scripts and the interactive shell.
This is client framing only; the authoritative SQL grammar remains the server
lexer/parser.

## Statement boundaries

A semicolon terminates a statement only while the scanner is outside:

- single-quoted string literals, including doubled `''` escapes;
- double-quoted identifiers, including doubled `""` escapes;
- `--` line comments;
- `/* ... */` block comments;
- client-side `#` comment lines.

Scripts may contain multiple statements per line and statements spanning
multiple lines. A final non-empty statement may omit its semicolon at end of
file. Unterminated strings, quoted identifiers and block comments are rejected
when the input is finalized.

The scanner is bounded by the existing 1 MiB script-file limit. It returns a
list of complete statements and, for interactive use, an incomplete suffix.

## Interactive shell

The shell keeps one network session and one input buffer. It accepts:

```text
\g                 execute the current buffer
\reset             discard the current buffer
\source <file>     execute a SQL-aware script in the current session
\tables            execute SHOW TABLES
\describe <table>  execute DESCRIBE
\indexes <table>   execute SHOW INDEXES
\ping              protocol ping
\q / \quit         close the session
```

Meta-command table names are restricted to simple SQL identifiers so local
command expansion cannot inject an additional statement.

## Procedure scripts and DELIMITER

The console, `--file` scripts, and GUI worksheet accept the client command
`DELIMITER token`. It changes statement framing only; it is not submitted to
the SQL server. Delimiters contain one to 32 bytes and cannot contain whitespace,
quotes, NUL, or backslashes. Directives are case-insensitive and must start a
line while no SQL statement is pending.

```sql
DELIMITER $$
CREATE PROCEDURE report_values()
BEGIN
  SELECT 1 AS first_value;
  SELECT 2 AS second_value;
END$$
DELIMITER ;
CALL report_values();
```

String literals, quoted identifiers (including backticks), and comments shield
any delimiter text they contain. Custom terminators are removed before sending
SQL; semicolons inside a compound body remain intact. The interactive shell
retains the selected delimiter across input lines. A script or independent GUI
execution starts with `;`. `BEGIN; ... COMMIT;` transaction scripts therefore
keep their existing framing behavior.

`scanSqlBatchWithDelimiter(text, finalInput, delimiter)` exposes incremental
framing. Its returned `SqlBatch` carries `statements`, `remainder`, and the final
`delimiter`; callers must retain both latter fields for the next input chunk.
The existing `scanSqlBatch` helper starts with `;` for standalone scripts.

Stored procedures may return several results. Console output prints each in
order; the GUI keeps each SELECT available in its own result tab when a batch
contains multiple result sets. The final CALL command contains the affected-row
count. Identical column names in consecutive SELECTs remain separate results.
