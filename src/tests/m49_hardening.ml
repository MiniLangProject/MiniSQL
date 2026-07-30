import minisql.common.endian as endian
import minisql.config.model as config_model
import minisql.executor.executor as executor
import minisql.platform.clock as clock
import minisql.protocol.codec as protocol_codec
import minisql.protocol.messages as messages
import minisql.server.database_manager as database_manager
import minisql.sql.parser as parser
import minisql.transaction.wal as wal
import tests.support.testkit as testkit

function executeOne(engine, sqlText)
  results = executor.executeSql(engine, sqlText)
  return results[0]
end function

function parserCorpus()
  return [
    "SELECT 1", "SELECT 3.3", "SELECT 'semi;colon'", "SELECT CASE WHEN 1 = 1 THEN 2 ELSE 3 END",
    "SELECT * FROM", "SELECT (((", "INSERT INTO missing VALUES (1)", "CREATE TABLE t (id INTEGER PRIMARY KEY)",
    "CREATE TABLE q (action VARCHAR(10), text TEXT)", "WITH c AS (SELECT 1 AS x) SELECT x FROM c",
    "SELECT 1 IN (1, 2, NULL)", "SELECT 5 BETWEEN 1 AND 9", "SELECT CAST('1.25e2' AS DOUBLE PRECISION)",
    "SELECT NEW.id", "SELECT OLD.value", "DROP TABLE IF EXISTS t", "BEGIN; COMMIT", "/* unterminated",
    "SELECT 'unterminated", "SELECT 1 -- comment", "SELECT COUNT(*) OVER ()", "SELECT ROW_NUMBER() OVER (ORDER BY 1)",
    "CREATE VIEW v AS SELECT 1 AS x", "DROP VIEW v", "CREATE SEQUENCE s START WITH 1", "SELECT NEXTVAL('s')",
    "CREATE TRIGGER x AFTER INSERT ON t FOR EACH ROW INSERT INTO t VALUES (NEW.id)",
    "INSERT INTO t VALUES (1) ON CONFLICT DO NOTHING RETURNING *", "TRUNCATE TABLE t RESTART IDENTITY",
    "SELECT * FROM a FULL OUTER JOIN b ON a.id = b.id", "SELECT * FROM a RIGHT JOIN b ON a.id = b.id",
    "SELECT COALESCE(NULL, 1)", "SELECT NULLIF(1, 1)", "SELECT 1 IS NOT UNKNOWN", "SELECT 1 FETCH FIRST 1 ROWS ONLY",
    "PREPARE p AS SELECT ?", "EXECUTE p USING 1", "DEALLOCATE p", "SHOW TABLES", "DESCRIBE t",
    "SHOW INDEXES FROM t", "VACUUM t", "REINDEX t", "ANALYZE t", "EXPLAIN SELECT 1",
    "SELECT 1 / 0", "SELECT @", "CREATE TABLE", "GRANT SELECT ON TABLE t TO public", "REVOKE SELECT ON TABLE t FROM public"
  ]
end function

function main(args)
  if len(args) != 1 then
    print "MiniSQL M49 hardening tests: FAIL (missing data root)"
    return 1
  end if

  state = testkit.create()
  corpus = parserCorpus()
  for each sqlText in corpus
    parsed = try(parser.parseSql(sqlText))
    testkit.record(state, typeof(parsed) == "array" or typeof(parsed) == "error", "parser fuzz outcome is controlled")
  end for

  // Deterministically mutate every byte of a valid statement. Only printable
  // ASCII is emitted so the parser, rather than the UTF-8 decoder, owns the
  // resulting accept/reject decision.
  parserSeed = bytes("SELECT id FROM hard_item WHERE amount >= 3.3")
  for offset = 0 to len(parserSeed) - 1
    mutatedSql = bytes(parserSeed)
    replacement = (mutatedSql[offset] + 17 + offset) % 95
    mutatedSql[offset] = replacement + 32
    mutatedText = decode(mutatedSql)
    mutatedParsed = try(parser.parseSql(mutatedText))
    testkit.record(state, typeof(mutatedParsed) == "array" or typeof(mutatedParsed) == "error", "deterministic SQL mutation outcome is controlled")
  end for

  message = messages.query(77, "SELECT 49 AS milestone")
  frame = protocol_codec.encodeMessage(message)
  for offset = 0 to len(frame) - 1
    mutated = bytes(frame)
    mutated[offset] = mutated[offset] ^ 1
    decoded = try(protocol_codec.decodeMessage(mutated))
    testkit.record(state, typeof(decoded) == "error", "wire corruption rejected")
  end for

  walRecord = wal.createRecord(wal.RECORD_TX_BEGIN, 0, 4901, 0, 0, bytes())
  walEncoded = wal.encode(walRecord)
  for offset = 0 to len(walEncoded) - 1
    mutatedWal = bytes(walEncoded)
    mutatedWal[offset] = mutatedWal[offset] ^ 1
    decodedWal = try(wal.decode(mutatedWal))
    testkit.record(state, typeof(decodedWal) == "error", "WAL corruption rejected")
  end for

  managed = database_manager.create(args[0], "m49_hardening", config_model.defaultDatabaseSettings(4096))
  databasePath = managed.path
  engine = executor.attach(managed)
  executeOne(engine, "CREATE TABLE hard_item (id INTEGER AUTO_INCREMENT PRIMARY KEY, bucket INTEGER NOT NULL, amount DECIMAL(12,2) NOT NULL, note VARCHAR(80))")

  started = clock.monotonicMilliseconds()
  executeOne(engine, "BEGIN")
  for index = 1 to 256
    bucket = index % 16
    executeOne(engine, "INSERT INTO hard_item(bucket, amount, note) VALUES (" + bucket + ", 3.3, 'row-" + index + "')")
  end for
  executeOne(engine, "COMMIT")
  executeOne(engine, "UPDATE hard_item SET amount = amount + 1.25 WHERE id % 3 = 0")
  executeOne(engine, "DELETE FROM hard_item WHERE id % 5 = 0")
  executeOne(engine, "ANALYZE hard_item")
  grouped = executeOne(engine, "SELECT bucket, COUNT(*) AS c, SUM(amount) AS total FROM hard_item GROUP BY bucket ORDER BY bucket")
  testkit.equal(state, len(grouped.rows), 16, "hardening workload group count")
  durableCount = executeOne(engine, "SELECT COUNT(*) FROM hard_item")
  expected = 205
  testkit.equal(state, endian.int64ToInt(durableCount.rows[0][0].value), expected, "hardening workload visible row count")
  elapsed = clock.monotonicMilliseconds() - started
  testkit.record(state, elapsed >= 0 and elapsed < 600000, "hardening workload remains bounded")

  executor.close(engine)
  database_manager.close(managed)
  reopened = executor.open(databasePath)
  reopenedCount = executeOne(reopened, "SELECT COUNT(*) FROM hard_item")
  testkit.equal(state, endian.int64ToInt(reopenedCount.rows[0][0].value), expected, "hardening workload survives restart")
  executor.close(reopened)

  gc_collect()
  testkit.record(state, heap_count() >= 0, "heap live-object counter remains available")
  testkit.record(state, heap_bytes_committed() > 0, "heap committed-byte counter remains available")
  testkit.record(state, heap_bytes_reserved() >= heap_bytes_committed(), "heap reserve covers committed bytes")

  return testkit.finish(state, "MiniSQL M49 hardening tests: SUCCESS", "MiniSQL M49 hardening tests: FAIL")
end function
