// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  return executor.executeSql(engine, sqlText)[0]
end function

// Runs the predicates fetch test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then print "MiniSQL M36 predicates and FETCH tests: FAIL args"; return 2 end if
  state = testkit.create()
  managed = database_manager.create(args[0], "m36_predicates", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE sample (id INTEGER PRIMARY KEY, label VARCHAR(20))")
  executeOne(engine, "INSERT INTO sample(id, label) VALUES (1, 'alpha'), (2, 'beta'), (3, NULL), (4, 'delta'), (5, 'echo')")

  inside = executeOne(engine, "SELECT id FROM sample WHERE id IN (1, 3, 5) ORDER BY id")
  testkit.equal(state, len(inside.rows), 3, "IN row count")
  testkit.equal(state, inside.rows[1][0].value, 3, "IN middle value")

  between = executeOne(engine, "SELECT id FROM sample WHERE id BETWEEN 2 AND 4 ORDER BY id")
  testkit.equal(state, len(between.rows), 3, "BETWEEN inclusive")
  notBetween = executeOne(engine, "SELECT id FROM sample WHERE id NOT BETWEEN 2 AND 4 ORDER BY id")
  testkit.equal(state, len(notBetween.rows), 2, "NOT BETWEEN")

  notLike = executeOne(engine, "SELECT id FROM sample WHERE label NOT LIKE '%a%' ORDER BY id")
  testkit.equal(state, len(notLike.rows), 1, "NOT LIKE excludes NULL and matches")
  testkit.equal(state, notLike.rows[0][0].value, 5, "NOT LIKE result")

  unknown = executeOne(engine, "SELECT id FROM sample WHERE (label = 'x') IS UNKNOWN")
  testkit.equal(state, len(unknown.rows), 1, "IS UNKNOWN")
  testkit.equal(state, unknown.rows[0][0].value, 3, "IS UNKNOWN identifies NULL comparison")
  truth = executeOne(engine, "SELECT TRUE IS TRUE AS t, FALSE IS NOT TRUE AS f, CAST(NULL AS BOOLEAN) IS UNKNOWN AS u")
  testkit.record(state, truth.rows[0][0].value, "IS TRUE")
  testkit.record(state, truth.rows[0][1].value, "IS NOT TRUE")
  testkit.record(state, truth.rows[0][2].value, "IS UNKNOWN on NULL boolean")

  nullIn = executeOne(engine, "SELECT 1 AS value WHERE 2 NOT IN (1, NULL)")
  testkit.equal(state, len(nullIn.rows), 0, "NOT IN with NULL yields UNKNOWN")

  fetched = executeOne(engine, "SELECT id FROM sample ORDER BY id OFFSET 1 ROWS FETCH NEXT 2 ROWS ONLY")
  testkit.equal(state, len(fetched.rows), 2, "OFFSET FETCH row count")
  testkit.equal(state, fetched.rows[0][0].value, 2, "OFFSET FETCH first")
  testkit.equal(state, fetched.rows[1][0].value, 3, "OFFSET FETCH second")
  first = executeOne(engine, "SELECT id FROM sample ORDER BY id FETCH FIRST 1 ROW ONLY")
  testkit.equal(state, len(first.rows), 1, "FETCH FIRST ROW")
  testkit.equal(state, first.rows[0][0].value, 1, "FETCH FIRST value")

  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT id FROM sample LIMIT 1 FETCH FIRST 1 ROW ONLY")), 9019, "LIMIT and FETCH combination rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M36 predicates and FETCH tests: SUCCESS", "MiniSQL M36 predicates and FETCH tests: FAIL")
end function
