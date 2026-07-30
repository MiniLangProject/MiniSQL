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
