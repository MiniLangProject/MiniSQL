// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.server.database_manager as database_manager
import tests.support.testkit as testkit

// Executes SQL and returns the first statement result; parse, bind, execution, and indexing failures remain observable to the test.
function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

// Extracts the host integer from the SQL 64-bit wrapper used in result assertions.
function int64Value(value)
  return endian.int64ToInt(value.value)
end function

// Runs the relational engine test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  if len(args) != 1 then
    print "MiniSQL M16 relational execution tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  managed = database_manager.create(args[0], "m16_relational", config_model.defaultDatabaseSettings(4096))
  engine = executor.attach(managed)

  executeOne(engine, "CREATE TABLE department (id INTEGER PRIMARY KEY, name VARCHAR(40) NOT NULL UNIQUE)")
  executeOne(engine, "CREATE TABLE employee (id INTEGER PRIMARY KEY, department_id INTEGER, name VARCHAR(40) NOT NULL, salary INTEGER NOT NULL)")
  executeOne(engine, "INSERT INTO department(id, name) VALUES (1, 'Engineering'), (2, 'Sales'), (3, 'Research')")
  executeOne(engine, "INSERT INTO employee(id, department_id, name, salary) VALUES (10, 1, 'Ada', 100), (11, 1, 'Bob', 120), (12, 2, 'Cara', 90)")

  joined = executeOne(engine, "SELECT e.name, d.name AS department FROM employee e INNER JOIN department d ON e.department_id = d.id ORDER BY e.id")
  testkit.equal(state, len(joined.rows), 3, "inner join row count")
  testkit.equal(state, joined.rows[0][0].value, "Ada", "inner join first employee")
  testkit.equal(state, joined.rows[0][1].value, "Engineering", "inner join first department")
  testkit.equal(state, joined.rows[2][1].value, "Sales", "inner join third department")

  cross = executeOne(engine, "SELECT e.id, d.id FROM employee e CROSS JOIN department d")
  testkit.equal(state, len(cross.rows), 9, "cross join cardinality")

  grouped = executeOne(engine, "SELECT d.name, COUNT(e.id) AS employees, SUM(e.salary) AS payroll, AVG(e.salary) AS average_salary, MIN(e.salary) AS minimum_salary, MAX(e.salary) AS maximum_salary FROM department d LEFT JOIN employee e ON e.department_id = d.id GROUP BY d.name ORDER BY d.name")
  testkit.equal(state, len(grouped.rows), 3, "left join group count")
  testkit.equal(state, grouped.rows[0][0].value, "Engineering", "grouped first name")
  testkit.equal(state, int64Value(grouped.rows[0][1]), 2, "COUNT for engineering")
  testkit.equal(state, int64Value(grouped.rows[0][2]), 220, "SUM for engineering")
  testkit.equal(state, grouped.rows[0][3].value, 110.0, "AVG for engineering")
  testkit.equal(state, grouped.rows[0][4].value, 100, "MIN for engineering")
  testkit.equal(state, grouped.rows[0][5].value, 120, "MAX for engineering")
  testkit.equal(state, grouped.rows[1][0].value, "Research", "left join empty group name")
  testkit.equal(state, int64Value(grouped.rows[1][1]), 0, "COUNT ignores NULL in empty group")
  testkit.record(state, grouped.rows[1][2].isNull, "SUM over empty group is NULL")

  having = executeOne(engine, "SELECT d.name, COUNT(e.id) AS employees FROM department d LEFT JOIN employee e ON e.department_id = d.id GROUP BY d.name HAVING COUNT(e.id) >= 1 ORDER BY employees DESC, d.name")
  testkit.equal(state, len(having.rows), 2, "HAVING filters empty group")
  testkit.equal(state, having.rows[0][0].value, "Engineering", "HAVING order first")
  testkit.equal(state, having.rows[1][0].value, "Sales", "HAVING order second")

  aggregateNoFrom = executeOne(engine, "SELECT COUNT(*) AS rows_seen")
  testkit.equal(state, int64Value(aggregateNoFrom.rows[0][0]), 1, "COUNT star without FROM")

  unionDistinct = executeOne(engine, "SELECT department_id FROM employee UNION SELECT id FROM department ORDER BY department_id")
  testkit.equal(state, len(unionDistinct.rows), 3, "UNION removes duplicates")
  testkit.equal(state, unionDistinct.rows[0][0].value, 1, "UNION first value")
  testkit.equal(state, unionDistinct.rows[2][0].value, 3, "UNION last value")

  unionAll = executeOne(engine, "SELECT department_id FROM employee UNION ALL SELECT id FROM department")
  testkit.equal(state, len(unionAll.rows), 6, "UNION ALL retains duplicates")

  intersected = executeOne(engine, "SELECT department_id FROM employee INTERSECT SELECT id FROM department ORDER BY department_id")
  testkit.equal(state, len(intersected.rows), 2, "INTERSECT result count")
  testkit.equal(state, intersected.rows[1][0].value, 2, "INTERSECT second value")

  excepted = executeOne(engine, "SELECT id FROM department EXCEPT SELECT department_id FROM employee ORDER BY id")
  testkit.equal(state, len(excepted.rows), 1, "EXCEPT result count")
  testkit.equal(state, excepted.rows[0][0].value, 3, "EXCEPT value")

  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT id FROM department d JOIN employee e ON d.id = e.department_id")), 9020, "ambiguous joined column rejected")
  testkit.errorCode(state, try(executor.executeSql(engine, "SELECT d.name, e.name FROM department d JOIN employee e ON d.id = e.department_id GROUP BY d.name")), 9020, "ungrouped select expression rejected")

  executor.close(engine)
  database_manager.close(managed)
  return testkit.finish(state, "MiniSQL M16 relational execution tests: SUCCESS", "MiniSQL M16 relational execution tests: FAIL")
end function
