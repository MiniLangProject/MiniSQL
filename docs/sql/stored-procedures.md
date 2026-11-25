# Stored procedures

MiniSQL procedures are persistent SQL programs with typed parameters, lexical
variables, control flow, cursors, condition handlers, dynamic SQL, and result
sets. The procedural language follows MySQL 8.4 conventions. Statements inside
a procedure still use MiniSQL's SQL dialect, types, transaction implementation,
and account model; this feature does not turn MiniSQL into a MySQL server.

## Create and call a procedure

```sql
CREATE TABLE procedure_items (
  id INTEGER PRIMARY KEY,
  amount INTEGER NOT NULL
);

DELIMITER $$
CREATE PROCEDURE add_item(IN p_id INTEGER, IN p_amount INTEGER,
                          OUT p_rows INTEGER)
SQL SECURITY INVOKER
MODIFIES SQL DATA
COMMENT 'Add an item and report one inserted row'
BEGIN
  IF p_amount < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'amount must be nonnegative';
  END IF;
  INSERT INTO procedure_items(id, amount) VALUES (p_id, p_amount);
  SET p_rows = 1;
END$$
DELIMITER ;

CALL add_item(1, 25, @inserted);
SELECT @inserted;
```

`DELIMITER` is a console/script-reader command. It keeps semicolons inside a
definition together. An application sending a complete SQL string directly to
the server sends `CREATE PROCEDURE ... BEGIN ... END` without delimiter commands.
For a procedure with no parameters, `CALL name` and `CALL name()` are equivalent.

```sql
CREATE [OR REPLACE] [DEFINER = account]
PROCEDURE [IF NOT EXISTS] [schema.]name (
  [IN | OUT | INOUT] parameter_name data_type [, ...]
)
[characteristic ...]
routine_statement;

CALL [schema.]name(argument [, ...]);
ALTER PROCEDURE [schema.]name characteristic ...;
DROP PROCEDURE [IF EXISTS] [schema.]name;
```

`routine_statement` is one supported SQL statement or a compound block.
`OR REPLACE` is a MiniSQL extension and cannot be combined with `IF NOT EXISTS`.
`ALTER PROCEDURE` changes characteristics; replace the definition to change
parameters or the body. Procedure definitions survive closing and reopening
the database and are included with schema metadata in backups.

Supported characteristics are:

| Characteristic | Meaning |
|---|---|
| `LANGUAGE SQL` | Identifies the SQL implementation language. |
| `[NOT] DETERMINISTIC` | Describes whether equal inputs give equal results. |
| `CONTAINS SQL`, `NO SQL`, `READS SQL DATA`, `MODIFIES SQL DATA` | Describes intended SQL/data access. |
| `SQL SECURITY DEFINER` | Execute the body with the persisted definer's privileges. Default for new MySQL-style definitions. |
| `SQL SECURITY INVOKER` | Execute the body with the caller's effective privileges. |
| `COMMENT 'text'` | Stores an administrative description. |

Determinism and data-access characteristics are descriptive metadata. They are
not a proof of purity, a read-only transaction, or an authorization grant.
MiniSQL retains its earlier `CREATE PROCEDURE ... AS statement` spelling;
without an explicit security characteristic this compatibility form uses
`INVOKER`, preserving the previous authorization model.

## Parameters and session variables

| Mode | Initial value inside the procedure | Caller-visible change |
|---|---|---|
| `IN` (default) | Evaluated input argument, converted to the declared type | None; changing the parameter changes only the local copy. |
| `OUT` | `NULL` | The final value is copied to the caller's destination. |
| `INOUT` | The caller's current value, converted to the declared type | The final value is copied back. |

Pass an `@session_variable` for an output argument from ordinary SQL. Inside
another routine, a declared local variable or a parameter can also be an output
destination. A literal or arithmetic expression is not a writable output
destination. Argument count and type compatibility are checked.

```sql
CREATE PROCEDURE add_to(IN p_delta INTEGER, INOUT p_value INTEGER)
SET p_value = p_value + p_delta;

SET @total = 10;
CALL add_to(5, @total);
SELECT @total;
```

Output values are published only after successful completion. An unhandled
exception, including a rethrown error, does not copy modified `OUT`/`INOUT`
parameters back. Session variables belong to the connection, not the database;
their lifetime is different from the persisted procedure definition.

A streamed `CALL` may expose earlier result sets before a later statement
fails. The client receives the error when it reaches that point in the result
stream. Consuming an earlier result is not evidence that the whole procedure
completed or that output parameters were published.

The final `CALL` status reports the affected-row count of the last executed
statement, including the final statement in a nested call. It does not sum all
mutations. A final result-producing SELECT has diagnostics `ROW_COUNT = -1` and
normalizes the nonnegative protocol affected-row count to zero. For example,
an UPDATE affecting ten rows followed by an UPDATE affecting three reports
three; a final SET reports zero. `ROW_COUNT()` and `GET DIAGNOSTICS ... ROW_COUNT`
retain the SQL diagnostic value.

### Captured execution context and character declarations

CREATE records the supported `sql_mode`, `character_set_client`,
`collation_connection` and database collation. CALL evaluates and converts input
arguments in the caller's SQL mode, installs the routine's saved context for
its body, then restores the caller on success and failure. Parameter character
declarations are bound to their creation-time defaults. ALTER refreshes the SQL
mode without changing the original character context.

```sql
SET sql_mode = 'STRICT_TRANS_TABLES';
CREATE PROCEDURE echo_text(IN p_text VARCHAR(40)
                          CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
                          OUT p_result VARCHAR(40))
BEGIN
  DECLARE v_text VARCHAR(40) CHARACTER SET utf8mb4;
  SET v_text = p_text, p_result = v_text;
END;
```

The supported mode values are the empty mode, `STRICT_TRANS_TABLES`,
`STRICT_ALL_TABLES`, or their combination. Routine character assignments count
Unicode characters; strict mode rejects truncation, while the empty mode
truncates at a character boundary and emits a warning. Numeric/storage
conversion continues to use MiniSQL's checked SQL type rules. This is not an
implementation of every MySQL mode or of MySQL's table-conversion rules.

Supported character attributes are `utf8mb4`/`utf8mb4_bin`,
`utf8`/`utf8_bin` and `binary`/`binary`. The utf8 declaration rejects characters
requiring a four-byte encoding. Comparison remains binary; unsupported
collations and incompatible charset/collation pairs are rejected when the
definition is created. Arbitrary linguistic collations are not silently treated
as binary. `CHAR`, `VARCHAR` and `TEXT` with `CHARACTER SET binary` become
`BINARY`, `VARBINARY` and `BLOB`: lengths and truncation use raw bytes, fixed
`BINARY` values receive zero padding, and no partial UTF-8 prefix is decoded as
text. `@@sql_mode`, `@@character_set_client` and `@@collation_connection`
expose the active context; `@@database_collation` is read-only.

## Blocks, local variables, and control flow

```sql
BEGIN
  DECLARE v_count INTEGER DEFAULT 0;
  DECLARE v_a, v_b INTEGER;
  SET v_count = v_count + 1, v_a = 2;
  BEGIN
    DECLARE v_count INTEGER DEFAULT 10;
    SET v_count = v_count + 1;
  END;
END
```

Locals without `DEFAULT` start as `NULL`. Defaults are expressions evaluated on
entering the block. Inner declarations shadow outer names, and the outer values
become visible again when the inner block exits. Unqualified local and parameter
names take precedence over column names. Prefix variables with `v_` or `p_` and
qualify table columns when a name would otherwise be ambiguous.

Declarations must precede executable statements in their block, in this order:
variables and named conditions, then cursors, then handlers. A later declaration
is a definition error, even when its branch would not execute.

| Construct | Form |
|---|---|
| Conditional | `IF condition THEN ... ELSEIF condition THEN ... ELSE ... END IF` |
| Value case | `CASE expression WHEN value THEN ... ELSE ... END CASE` |
| Searched case | `CASE WHEN condition THEN ... ELSE ... END CASE` |
| Precondition loop | `WHILE condition DO ... END WHILE` |
| Postcondition loop | `REPEAT ... UNTIL condition END REPEAT` |
| Unconditional loop | `LOOP ... END LOOP` |
| Leave a block/loop | `LEAVE label` |
| Start the next loop iteration | `ITERATE label` |

Compound blocks and loops can have an opening `label:` and matching optional
closing label. `ITERATE` requires a loop label. Use a labeled outer block and
`LEAVE` for an early procedure exit; `RETURN expression` belongs to stored
functions, which this procedure implementation does not introduce.

```sql
DELIMITER $$
CREATE PROCEDURE sum_to(IN p_limit INTEGER, OUT p_sum INTEGER)
BEGIN
  DECLARE v_n INTEGER DEFAULT 0;
  SET p_sum = 0;
  counting: WHILE v_n < p_limit DO
    SET v_n = v_n + 1;
    SET p_sum = p_sum + v_n;
  END WHILE counting;
END$$
DELIMITER ;
CALL sum_to(5, @sum);
SELECT @sum;
```

The result is 15. Statement `CASE` raises a condition when no branch matches
and no `ELSE` exists. This differs from a scalar `CASE` expression's implicit
`NULL` result. To deliberately do nothing in a branch, use `BEGIN END`.

## Querying into variables and returning result sets

```sql
SELECT amount INTO v_amount FROM procedure_items WHERE id = p_id;
SELECT amount FROM procedure_items WHERE id = p_id INTO v_amount;
```

`SELECT ... INTO` assigns a single row to locals, parameters, or session
variables. The number of destinations must equal the number of result columns.
No row raises a `NOT FOUND` condition and leaves destinations unchanged; more
than one row is an error. Use an explicit query predicate or `LIMIT 1` when the
application requires at most one row.

An ordinary `SELECT` without `INTO` produces a result set for the caller. Several
such statements return several result sets, in execution order, including
results from nested procedure calls. Clients must consume all results before
reusing the connection. SQL `CALL` is available through the normal execution
API; it does not imply that every connector implements every vendor-specific
stored-procedure convenience API.

## Cursors

```sql
DELIMITER $$
CREATE PROCEDURE total_items(OUT p_total INTEGER)
READS SQL DATA
BEGIN
  DECLARE v_done INTEGER DEFAULT 0;
  DECLARE v_amount INTEGER;
  DECLARE items CURSOR FOR SELECT amount FROM procedure_items ORDER BY id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

  SET p_total = 0;
  OPEN items;
  reading: LOOP
    FETCH items INTO v_amount;
    IF v_done = 1 THEN LEAVE reading; END IF;
    SET p_total = p_total + v_amount;
  END LOOP reading;
  CLOSE items;
END$$
DELIMITER ;
```

Cursors are local to their declaration block, read-only, and forward-only.
`FETCH [NEXT FROM] name INTO ...` advances one row. Exhaustion raises SQLSTATE
`02000`, commonly handled by the `v_done` pattern above. Declare variables and
conditions before cursors and handlers afterward. `SELECT INTO` can raise the
same condition; use a nested block with its own handler when those operations
need different handling.

## Conditions, handlers, and diagnostics

```sql
DECLARE invalid_amount CONDITION FOR SQLSTATE '45000';
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  GET STACKED DIAGNOSTICS CONDITION 1
    @last_state = RETURNED_SQLSTATE, @last_message = MESSAGE_TEXT;
  RESIGNAL;
END;
```

Handlers can match a numeric error code, a five-character `SQLSTATE`, a named
condition, `SQLWARNING`, `NOT FOUND`, or `SQLEXCEPTION`. `CONTINUE` resumes after
the failing statement. `EXIT` leaves the block in which the handler was
declared. It does not itself mean `ROLLBACK`.

The nearest block containing a matching handler wins. Within that scope an
exact numeric error has precedence over SQLSTATE, which has precedence over a
condition class. Errors inside a handler cannot be caught by that same handler
or by sibling handlers in its declaring block. Outer handlers can handle them.

```sql
SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'amount is invalid', MYSQL_ERRNO = 30001;
RESIGNAL;
RESIGNAL SET MESSAGE_TEXT = 'item operation failed';
GET DIAGNOSTICS v_count = NUMBER, v_rows = ROW_COUNT;
GET CURRENT DIAGNOSTICS CONDITION 1
  v_state = RETURNED_SQLSTATE, v_message = MESSAGE_TEXT;
```

SQLSTATE class `00` represents success and cannot be signaled. The usual
application-exception state is `45000`. A signal can also refer to a named
SQLSTATE condition. `MYSQL_ERRNO` must be an integer from 1 through 65535;
`MESSAGE_TEXT` accepts at most 128 Unicode characters. The other textual
condition items accept at most 64 characters. Information items cannot be
`NULL`. Error diagnostics have `ROW_COUNT = -1`; warning/not-found signals have
zero. Standard/user-defined class origins are distinguished in diagnostic items.

`RESIGNAL` requires an active handler. Bare `RESIGNAL` and `RESIGNAL SET ...`
preserve the original condition values except for explicitly replaced items.
`RESIGNAL SQLSTATE ...` starts error number and message defaults for the new
SQLSTATE class, applies any explicit information items, and appends the new
condition to the diagnostics area.

`GET DIAGNOSTICS` reads statement information or one numbered condition.
`CURRENT` is the default. `STACKED` reads the condition that activated the
current handler even after other statements have changed its current
diagnostics. Condition information includes `RETURNED_SQLSTATE`, `MYSQL_ERRNO`,
`MESSAGE_TEXT`, origin fields, and constraint/catalog/schema/table/column/cursor
names. Unpopulated descriptive fields are empty.

Uncaught exceptions leave the procedure. Ordinary warnings continue. A normal
no-data condition continues when no handler exists; an explicitly signaled
no-data condition exits. MiniSQL maps its own engine errors into routine
conditions; this does not promise every MySQL server error number or message.

### Warning chains and client diagnostics

```sql
CALL procedure_with_warnings();
SHOW WARNINGS;
SHOW WARNINGS LIMIT 10 OFFSET 5;
SHOW COUNT(*) WARNINGS;
SHOW ERRORS;
SHOW COUNT(*) ERRORS;
```

Nonfatal routine warnings are retained in encounter order for the public CALL,
including warnings before a later successful statement. SHOW commands and GET
DIAGNOSTICS are observational. `SELECT @@warning_count` or `@@error_count`
returns the previous total and, as an ordinary SELECT, replaces the old list
after reading it. The next nondiagnostic statement starts a new list. Syntax
errors and native execution errors are included in SHOW ERRORS.

`max_error_count` bounds retained condition records (default 64, range
0..65535). Warning/error totals continue counting when the retained list is
full or the limit is zero; LIMIT controls display only. These settings are
connection-local in MiniSQL.

The optional `results-v2` protocol capability carries SQLSTATE separately from
the message, a warning chain, exact NULL information and output parameter
snapshots. JDBC exposes SQLWarning chains and Python exposes condition records
and exception SQLSTATE. Legacy native numeric error codes remain stable;
routine `MYSQL_ERRNO` diagnostics provide the mapped SQL condition number.
An application-supplied MYSQL_ERRNO never becomes an internal retry or
transaction-abort instruction merely because the numbers coincide.

## Dynamic SQL and recursion

```sql
SET @query = 'SELECT amount FROM procedure_items WHERE id = ?';
PREPARE item_lookup FROM @query;
SET @item_id = 1;
EXECUTE item_lookup USING @item_id;
DEALLOCATE PREPARE item_lookup;
```

The `FROM` form accepts a string literal or a session variable containing one
SQL statement. Parameters represent values, not identifiers. Dynamic statements
are session-scoped: they may outlive the procedure that prepared them and cannot
capture its local variables or parameters. Use `@session_variables` or bound
`?` values. MiniSQL's original `PREPARE name AS statement` form remains available.
Always release dynamically prepared statements when no longer needed.

PREPARE accepts supported ordinary SQL, including session-variable `SET` and
`SELECT INTO` with `@variable` destinations. Procedure definitions, compound
program blocks, and nested PREPARE/EXECUTE/DEALLOCATE commands cannot themselves
be prepared.

Nested calls use separate local frames. Recursive procedure calls are disabled
by default. Enable a bounded number of recursive invocations per session:

```sql
SET @@session.max_sp_recursion_depth = 16;
-- Equivalent MiniSQL spelling:
SET max_sp_recursion_depth = 16;
```

The allowed range is 0 through 255. Increasing it does not make a nonterminating
procedure correct; loops and recursion must still have a termination condition.
The engine also limits all simultaneously active procedure frames to 256,
including a chain of distinct procedures without recursion.

## Transactions, namespaces, and privileges

Procedures use the caller's transaction context. They may execute
`START TRANSACTION`, `COMMIT`, `ROLLBACK`, and supported savepoint statements.
Within a routine, `BEGIN` starts a lexical block, not a transaction. A call is
not automatically one all-or-nothing transaction, and an `EXIT` handler is not
an automatic rollback. Make the intended transaction boundary explicit.
CREATE/ALTER/DROP PROCEDURE perform an implicit commit before the definition
change once authorization has succeeded. Consequently, an authorized DDL
statement that later fails definition validation can still have committed
preceding work. A denied DDL operation does not commit it. Security DCL retains
its autocommit-only requirement.

Inside an explicit transaction, each procedure DML statement has its own
rollback checkpoint. A duplicate-key or ordinary SQL condition rolls back that
statement's partial changes; previously successful statements remain available
for the caller to commit or roll back, and the failed CALL does not itself
poison the transaction. A native deadlock victim aborts the complete
transaction. Storage/transport failures retain the conservative failed
transaction policy. Autocommit procedures can already have durable side effects
when a later statement fails.

Once argument/body evaluation has begun, a native lock conflict is returned
without automatically replaying the whole CALL. This prevents duplicated
session changes or committed operations. Admission failures before execution
remain eligible for the server's normal lock-wait policy.

Unqualified object names are resolved in the procedure's schema while it runs;
the caller's context is restored afterward. `USE` inside a procedure is not
supported. Names use MiniSQL's two-part schema/object form, not cross-database
catalog routing.

```sql
GRANT CREATE ROUTINE ON DATABASE TO procedure_author;
GRANT EXECUTE ON PROCEDURE public.total_items TO report_reader;
GRANT ALTER ROUTINE ON PROCEDURE public.total_items TO procedure_author;
GRANT EXECUTE ON DATABASE TO batch_runner;
REVOKE EXECUTE ON PROCEDURE public.total_items FROM report_reader;
```

`EXECUTE` and `ALTER ROUTINE` can apply to an individual procedure or every
procedure in the current database. `CREATE ROUTINE` is database-scoped and is
required for procedure creation; the older generic `CREATE` permission no
longer suffices. Migrate existing author roles with `GRANT CREATE ROUTINE ON
DATABASE TO role_name`.

Creation normally grants the author EXECUTE and ALTER ROUTINE, without GRANT
OPTION. An administrator can disable these automatic grants for subsequent
creations in its session using `SET automatic_sp_privileges = 0`. This does not
revoke existing grants. Permission to execute a procedure is distinct from
permission to perform its body operations. A definer routine requires EXECUTE
for both its caller and its persisted definer, and uses the definer's body
permissions. An invoker routine uses the caller's permissions.

`SET_ANY_DEFINER ON DATABASE` permits an author to select another existing
ordinary user as definer. Selecting a superuser requires administration, and
missing or disabled accounts remain errors. Roles and WITH GRANT OPTION use the
ordinary MiniSQL security catalog. The current database is the grant boundary;
this does not introduce MySQL's server-global account namespace or role
activation settings.

`SHOW_ROUTINE ON DATABASE` permits reading routine definitions without granting
CALL or table access. Database SELECT permits reading both routine definitions
and all tables in that database. EXECUTE, ALTER ROUTINE and CREATE ROUTINE
permit scoped metadata inspection but leave the definition column NULL unless
the user independently has definition-reading authority or is the durable
definer. These rules apply equally to SHOW CREATE and INFORMATION_SCHEMA.

Procedure grants use durable object identifiers, not names. Dropping and then
creating a same-named procedure allocates a new identifier; old grants do not
silently authorize the replacement. Altering an existing procedure preserves
its identity. Review definer routines as privilege-bearing programs, including
their dynamic SQL and the grants on routines they call.

## Inspect definitions and parameters

```sql
SHOW CREATE PROCEDURE public.total_items;
SHOW PROCEDURE STATUS;

SELECT routine_schema, routine_name, security_type, definer,
       is_deterministic, sql_data_access, routine_comment
FROM information_schema.routines;

SELECT specific_schema, specific_name, ordinal_position,
       parameter_mode, parameter_name, data_type,
       character_maximum_length, numeric_precision, numeric_scale
FROM information_schema.parameters
ORDER BY specific_schema, specific_name, ordinal_position;
```

ROUTINES and PARAMETERS expose all 31 and 16 MySQL column names respectively,
in MySQL column order. Routine return-type fields are empty or NULL because
procedures do not have a function return type. Parameter ordinals start at one.
SHOW CREATE has six fields, including SQL mode and creation-time character
settings. SHOW STATUS has eleven fields, including Created and Modified.

New definitions persist their actual UTC creation/modification times and the
supported SQL mode, client character set, connection collation and database
collation. ALTER retains the original creation time and character settings,
updates the modification time and captures its current SQL mode. Unknown
historical values in older definitions remain SQL NULL. ROUTINES timestamps
have MiniSQL's TIMESTAMP type and epoch-microsecond value representation; SHOW
renders readable UTC calendar timestamps with six fractional digits.

Parameter metadata is derived from the concrete MiniSQL type. An INTEGER has
numeric precision 10 and scale 0 even without explicit type arguments; a
VARCHAR has character lengths and NULL numeric precision/scale. For supported
character sets, octet length reflects the maximum bytes per character.
DATETIME_PRECISION describes TIME/TIMESTAMP fractional precision.
DTD_IDENTIFIER describes the complete base type, including declared length or
precision. CHAR, VARCHAR and TEXT declared with CHARACTER SET binary have the
effective BINARY, VARBINARY and BLOB types in both DATA_TYPE and DTD_IDENTIFIER;
their length is measured in bytes and character-set/collation fields are NULL.
Unbounded MiniSQL TEXT/BLOB declarations have NULL maximum lengths;
BOOLEAN remains MiniSQL's native Boolean type, not a MySQL TINYINT alias.

Other metadata relations retain their own visibility policies; routine source
protection is not a general object-name secrecy guarantee. The full column
layouts and persisted context representation are described in
[`schema-extensions-v1.md`](../formats/schema-extensions-v1.md).

## Calling procedures from triggers

Triggers can contain CALL or compound procedural blocks with declarations,
control flow and handlers. OLD/NEW expressions are visible in the trigger
frame, so they can be passed as input arguments. Trigger locals and session
variables can receive OUT/INOUT values.

```sql
CREATE TRIGGER audit_item AFTER INSERT ON procedure_items
FOR EACH ROW
BEGIN
  DECLARE v_written INTEGER;
  CALL write_item_audit(NEW.id, NEW.amount, v_written);
  SET @last_audit_rows = v_written;
END;
```

The entire callee chain participates in the invoking statement's private page
transaction. A failure rolls back the invoking autocommit statement together
with its trigger writes, and an explicit outer rollback also removes those
writes. The trigger context prohibits client result sets, dynamic SQL, explicit
or implicit transaction boundaries, and modification of a table already used
by the invoking trigger chain. Restrictions are checked before each prohibited
operation, including operations in nested procedures. SELECT INTO and cursor
queries do not expose result sets and remain permitted.

Trigger entry creates an isolated savepoint level. Savepoints created by the
caller are inaccessible to the trigger and its callees; trigger-local savepoints
are discarded when the trigger exits, restoring the caller's original level.
A native deadlock aborts the owning transaction and cannot be caught to continue
trigger execution against a detached transaction.

OLD/NEW remain read-only under MiniSQL's existing row-trigger implementation;
this work does not add writable BEFORE-trigger NEW fields. Existing DML trigger
syntax and its supported forms are retained.

## Streaming, parsed-program reuse and concurrent readers

The network executor emits eligible simple SELECTs from a CALL in bounded
128-row batches as they execute. It does not retain earlier completed result
sets. Empty sets, successive sets with the same columns, nested calls and a
final CALL completion remain distinct. A failed batch is a fetch failure;
an error in a later routine statement is the next logical result. A broken
consumer aborts further evaluation, closes its scan/read lease, and cannot be
swallowed by a SQL condition handler.

Blocking/unsupported query shapes retain the engine's normal materializing
operator path. The embedded `executeSql` API intentionally still returns a
complete in-memory QueryResult. Native streaming callers can use
`executeStatementStreaming(engine, statement, sink, context)`; the sink receives
`(context, QueryResult, resultStart)` and a `(context, void, false)` end marker.

Python callproc and JDBC CallableStatement must consume completion to return
OUT values immediately. They use bounded temporary-file spooling to retain
earlier results for nextset/getMoreResults, and read OUT snapshots from the
negotiated terminal frame. Direct execute/CALL consumers can read incrementally.
Legacy peers use the documented compatibility output-parameter path.

Each engine keeps at most 64 immutable parsed routine definitions. The key
includes durable object identity, canonical source and persisted context;
ALTER, replacement and drop/recreate cannot reuse stale programs. Cache hits
never cache permission decisions, argument values, lexical frames or definer
identity checks. Revocation is effective immediately.

The executor proves read-only bodies before admitting CALL through its shared
reader gate. It recursively inspects called procedures and expressions and
rejects sequence mutation, dynamic SQL and unknown dependencies from that
proof. Descriptive READS SQL DATA/NO SQL characteristics do not override the
body. Unproved cases, including expanded-view/subquery dependencies, use the
exclusive path. Independently authenticated read-only CALLs can overlap;
mutations retain the single-writer database contract.

## Compatibility boundaries and sources

This implementation covers stored **procedures**. It does not add SQL stored
functions, package routines, routine overloading, default/named arguments,
`UNDO` handlers, cursor output parameters, or a MySQL Event Scheduler. MySQL
8.4 itself does not provide several of those extensions. General MySQL SQL
syntax, all MySQL data types/collations, host-qualified account matching,
binary-log replication, the complete server-wide SQL-mode/charset system and
MySQL wire-protocol compatibility remain separate concerns. The supported
routine context and warning settings are defined above; unimplemented modes
and collations are rejected explicitly.

Implementation: `src/minisql/sql/{parser,ast,binder}.ml`,
`src/minisql/executor/{executor,routine_state}.ml`,
`src/minisql/catalog/{metadata,catalog,schema_history}.ml`, and the
client/protocol/session modules. The native parser, runtime, edge, parity, client,
security, and legacy regression gate runs through `test.ps1 -Routines`.
Its internal runner also accepts `--compiler`, `--target`, and `--compile-only`
when used by CI.

The semantic reference is the official MySQL 8.4 manual:

- [Routine creation and characteristics](https://dev.mysql.com/doc/refman/8.4/en/create-procedure.html)
- [Compound statements](https://dev.mysql.com/doc/refman/8.4/en/sql-compound-statements.html)
- [Handler selection](https://dev.mysql.com/doc/refman/8.4/en/handler-scope.html)
- [Cursors](https://dev.mysql.com/doc/refman/8.4/en/cursors.html)
- [SELECT INTO](https://dev.mysql.com/doc/refman/8.4/en/select-into.html)
- [Diagnostics](https://dev.mysql.com/doc/refman/8.4/en/diagnostics-area.html)
- [SHOW WARNINGS](https://dev.mysql.com/doc/refman/8.4/en/show-warnings.html)
- [CALL status](https://dev.mysql.com/doc/refman/8.4/en/call.html)
- [Trigger restrictions](https://dev.mysql.com/doc/refman/8.4/en/trigger-syntax.html)
- [InnoDB error handling](https://dev.mysql.com/doc/refman/8.4/en/innodb-error-handling.html)
- [Stored-program restrictions](https://dev.mysql.com/doc/refman/8.4/en/stored-program-restrictions.html)
