import minisql.catalog.metadata as metadata
import minisql.common.endian as endian
import minisql.sql.ast as ast
import minisql.sql.binder as binder
import minisql.sql.expressions as expressions
import minisql.sql.parser as parser
import minisql.sql.types as types
import minisql.sql.values as values
import tests.support.testkit as testkit

function main(args)
  state = testkit.create()

  minimum = values.literalInteger("-9223372036854775808")
  maximum = values.literalInteger("9223372036854775807")
  testkit.equal(state, minimum.typeKind, types.SqlTypeKind.BigInt, "minimum literal is BIGINT")
  testkit.equal(state, maximum.typeKind, types.SqlTypeKind.BigInt, "maximum literal is BIGINT")
  testkit.record(state, endian.isInt64Words(minimum.value), "minimum uses Int64Words")
  testkit.record(state, endian.isInt64Words(maximum.value), "maximum uses Int64Words")
  testkit.record(state, values.int64Compare(minimum.value, maximum.value) < 0, "signed BIGINT comparison")
  boundMinimum = binder.bindExpression(parser.parseExpressionText("-9223372036854775808"), void, void)
  minimumResult = expressions.evaluate(boundMinimum, expressions.rowContext([]))
  testkit.equal(state, values.int64Compare(values.asInt64(minimumResult), values.asInt64(minimum)), 0, "SQL minimum BIGINT literal binds without positive overflow")
  testkit.errorCode(state, try(values.literalInteger("9223372036854775808")), values.BINDING_ERROR, "BIGINT overflow rejected")

  sqlNull = values.nullValue(types.SqlTypeKind.Boolean)
  testkit.record(state, values.isNull(sqlNull), "SQL NULL is explicit")
  testkit.record(state, sqlNull.value is void, "NULL payload is void but wrapped")
  testkit.errorCode(state, try(values.of(types.SqlTypeKind.Integer, void)), values.INVALID_ARGUMENT, "bare MiniLang void rejected")
  testkit.equal(state, values.truth(values.logicalAnd(values.boolean(false), sqlNull)), 0, "FALSE AND UNKNOWN is FALSE")
  testkit.equal(state, values.truth(values.logicalAnd(values.boolean(true), sqlNull)), -1, "TRUE AND UNKNOWN is UNKNOWN")
  testkit.equal(state, values.truth(values.logicalOr(values.boolean(true), sqlNull)), 1, "TRUE OR UNKNOWN is TRUE")
  testkit.equal(state, values.truth(values.logicalOr(values.boolean(false), sqlNull)), -1, "FALSE OR UNKNOWN is UNKNOWN")
  testkit.equal(state, values.truth(values.logicalNot(sqlNull)), -1, "NOT UNKNOWN is UNKNOWN")

  decimalType = types.fromTypeName(ast.typeName("DECIMAL", 0, 18, 2), false)
  varcharType = types.fromTypeName(ast.typeName("VARCHAR", 40, 0, 0), true)
  testkit.equal(state, decimalType.kind, types.SqlTypeKind.Decimal, "DECIMAL binding")
  testkit.equal(state, decimalType.scale, 2, "DECIMAL scale binding")
  testkit.equal(state, varcharType.length, 40, "VARCHAR binding")
  testkit.errorCode(state, try(types.fromTypeName(ast.typeName("VARCHAR", 0, 0, 0), true)), types.BINDING_ERROR, "unbounded VARCHAR rejected")
  testkit.errorCode(state, try(types.create(types.SqlTypeKind.Decimal, 0, 19, 2, false)), types.INVALID_ARGUMENT, "DECIMAL precision limit")

  table = metadata.createTable(10, "customer", 1, [
    metadata.createColumn(11, "id", types.SqlTypeKind.Integer, false, 0, 0, 0),
    metadata.createColumn(12, "name", types.SqlTypeKind.VarChar, false, 20, 0, 0),
    metadata.createColumn(13, "active", types.SqlTypeKind.Boolean, true, 0, 0, 0)
  ])
  bound = binder.bindExpression(parser.parseExpressionText("id + 2 >= 5 AND active IS NOT NULL"), table, void)
  testkit.record(state, expressions.isBoundExpression(bound), "expression bound")
  testkit.equal(state, bound.typeInfo.kind, types.SqlTypeKind.Boolean, "predicate type")
  row = expressions.rowContext([values.integer(3), values.of(types.SqlTypeKind.VarChar, "Ada"), values.boolean(true)])
  evaluated = expressions.evaluate(bound, row)
  testkit.equal(state, values.truth(evaluated), 1, "bound expression evaluates TRUE")
  rowUnknown = expressions.rowContext([values.integer(3), values.of(types.SqlTypeKind.VarChar, "Ada"), values.nullValue(types.SqlTypeKind.Boolean)])
  testkit.equal(state, values.truth(expressions.evaluate(bound, rowUnknown)), 0, "IS NOT NULL evaluates FALSE")

  likeBound = binder.bindExpression(parser.parseExpressionText("name LIKE 'A%'"), table, void)
  testkit.equal(state, values.truth(expressions.evaluate(likeBound, row)), 1, "LIKE evaluation")
  checkBound = binder.bindExpression(parser.parseExpressionText("active = TRUE"), table, void)
  testkit.record(state, expressions.checkPasses(checkBound, rowUnknown), "CHECK accepts UNKNOWN")
  testkit.errorCode(state, try(binder.bindExpression(parser.parseExpressionText("missing = 1"), table, void)), binder.OBJECT_NOT_FOUND, "unknown column rejected")
  testkit.errorCode(state, try(binder.bindExpression(parser.parseExpressionText("name + 1"), table, void)), binder.TYPE_MISMATCH, "invalid operator types rejected")

  return testkit.finish(state, "MiniSQL M13 binding/value tests: SUCCESS", "MiniSQL M13 binding/value tests: FAIL")
end function
