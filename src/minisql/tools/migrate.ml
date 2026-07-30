package minisql.tools.migrate

import minisql.catalog.catalog as catalog
import minisql.catalog.metadata as metadata
import minisql.catalog.schema_history as schema_history
import minisql.common.uuid as uuid
import minisql.common.version as version
import minisql.config.model as config_model
import minisql.executor.dml as dml
import minisql.executor.scan as scan
import minisql.platform.file as file_api
import minisql.server.database_manager as database_manager
import minisql.tools.check as check

// M20 migration planner. Format-affecting changes are never performed in place.
// This milestone validates and reports the required rewrite, and refuses a page-
// size change before touching source files. The full row/index rewrite engine is
// intentionally a later, separately crash-tested migration milestone.

const INVALID_ARGUMENT = 9001
const UNSUPPORTED_FORMAT = 9003

struct MigrationPlan
  databasePath
  currentPageSize
  targetPageSize
  rewriteRequired
  supported
  message
end struct

struct MigrationReport
  plan
  changed
end struct

function fail(code, operation, message)
  return error(code, "tools.migrate." + operation + ": " + message)
end function

function isMigrationPlan(value)
  return value is MigrationPlan
end function

function isMigrationReport(value)
  return value is MigrationReport
end function

function validPageSize(value)
  return value == 4096 or value == 8192 or value == 16384 or value == 32768
end function

function plan(databasePath, targetPageSize)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail(INVALID_ARGUMENT, "plan", "databasePath must be non-empty") end if
  if typeof(targetPageSize) != "int" or not validPageSize(targetPageSize) then return fail(INVALID_ARGUMENT, "plan", "targetPageSize must be 4096, 8192, 16384, or 32768") end if
  database = try(database_manager.open(databasePath))
  if typeof(database) == "error" then return database end if
  current = database.catalogHandle.metadata.pageSize
  closeResult = try(database_manager.close(database))
  if typeof(closeResult) == "error" then return closeResult end if
  if current == targetPageSize then return MigrationPlan(databasePath, current, targetPageSize, false, true, "database already uses the requested page size") end if
  return MigrationPlan(databasePath, current, targetPageSize, true, false, "page-size migration requires an offline copy-and-rewrite of every table and index")
end function

function run(databasePath, targetPageSize)
  migrationPlan = plan(databasePath, targetPageSize)
  if migrationPlan.rewriteRequired then return fail(UNSUPPORTED_FORMAT, "run", migrationPlan.message + "; source database was not modified") end if
  return MigrationReport(migrationPlan, false)
end function


struct RewriteMigrationReport
  sourcePath
  targetPath
  sourcePageSize
  targetPageSize
  tableCount
  rowCount
  indexCount
  verified
end struct

function isRewriteMigrationReport(value)
  return value is RewriteMigrationReport
end function

function copyDatabaseState(source, target, targetName, targetPageSize)
  sourceHandle = source.catalogHandle
  targetHandle = target.catalogHandle
  targetId = bytes(targetHandle.metadata.databaseId)

  nextMetadata = metadata.decodeDatabase(metadata.encodeDatabase(sourceHandle.metadata))
  nextMetadata.name = targetName
  nextMetadata.databaseId = targetId
  nextMetadata.pageSize = targetPageSize
  nextMetadata.checkpointLsn = 0
  nextCatalog = metadata.decodeCatalog(metadata.encodeCatalog(sourceHandle.catalog))
  nextCatalog.databaseId = targetId
  nextCatalog.nextObjectId = nextMetadata.nextObjectId

  sourceState = schema_history.loadOrCreate(source.path, sourceHandle.metadata.databaseId)
  // Clone schema.history together with schema.extensions.
  targetState = schema_history.cloneState(sourceState)
  targetState.databaseId = targetId

  rowCount = 0
  for each table in sourceHandle.catalog.tables
    rows = scan.scanTable(source.path, table, void)
    rowCount = rowCount + dml.writeRowsToHeap(
      catalog.tableFilePath(target.path, table.tableId),
      targetPageSize,
      targetId,
      table,
      rows
    )
  end for

  targetHandle.metadata = nextMetadata
  targetHandle.catalog = nextCatalog
  catalog.persistMetadata(targetHandle)
  schema_history.save(target.path, targetState)

  security = catalog.cloneSecurityState(sourceHandle.security)
  security.databaseId = targetId
  catalog.commitSecurityState(targetHandle, security)

  indexCount = dml.rebuildAllIndexes(target)
  return [rowCount, indexCount]
end function

function rewrite(sourcePath, targetRoot, targetName, targetPageSize)
  if typeof(sourcePath) != "string" or len(sourcePath) == 0 then return fail(INVALID_ARGUMENT, "rewrite", "sourcePath must be non-empty") end if
  if typeof(targetRoot) != "string" or len(targetRoot) == 0 then return fail(INVALID_ARGUMENT, "rewrite", "targetRoot must be non-empty") end if
  if typeof(targetName) != "string" or len(targetName) == 0 then return fail(INVALID_ARGUMENT, "rewrite", "targetName must be non-empty") end if
  if typeof(targetPageSize) != "int" or not validPageSize(targetPageSize) then return fail(INVALID_ARGUMENT, "rewrite", "targetPageSize must be 4096, 8192, 16384, or 32768") end if

  source = try(database_manager.open(sourcePath))
  if typeof(source) == "error" then return source end if
  sourcePageSize = source.catalogHandle.metadata.pageSize
  defaults = config_model.defaultDatabaseSettings(targetPageSize)
  defaults.walSegmentBytes = source.catalogHandle.metadata.walSegmentBytes
  defaults.databaseFormatVersion = source.catalogHandle.metadata.databaseFormatVersion
  defaults.tableFileFormatVersion = source.catalogHandle.metadata.tableFileFormatVersion
  defaults.indexFileFormatVersion = source.catalogHandle.metadata.indexFileFormatVersion
  defaults.walFormatVersion = source.catalogHandle.metadata.walFormatVersion
  defaults.rowFormatVersion = source.catalogHandle.metadata.rowFormatVersion

  file_api.createDirectory(targetRoot)
  stagingRoot = catalog.joinPath(targetRoot, ".minisql-migrate-" + uuid.toHex(uuid.create()))
  file_api.createDirectory(stagingRoot)
  target = try(database_manager.create(stagingRoot, targetName, defaults))
  if typeof(target) == "error" then database_manager.close(source); return target end if
  stagingPath = target.path
  targetId = bytes(target.catalogHandle.metadata.databaseId)

  copied = try(copyDatabaseState(source, target, targetName, targetPageSize))
  targetClose = try(database_manager.close(target))
  sourceClose = try(database_manager.close(source))
  if typeof(copied) == "error" then return copied end if
  if typeof(targetClose) == "error" then return targetClose end if
  if typeof(sourceClose) == "error" then return sourceClose end if

  verifiedReport = try(check.run(stagingPath))
  if typeof(verifiedReport) == "error" then return verifiedReport end if
  finalPath = catalog.joinPath(targetRoot, "db_" + uuid.toHex(targetId))
  if file_api.pathExists(finalPath) then return fail(INVALID_ARGUMENT, "rewrite", "generated target path already exists") end if
  file_api.movePath(stagingPath, finalPath, false)
  ignoredRemove = try(file_api.removeDirectory(stagingRoot))
  return RewriteMigrationReport(sourcePath, finalPath, sourcePageSize, targetPageSize, verifiedReport.tableCount, copied[0], copied[1], true)
end function

function m0SelfTestLine()
  return "MiniSQL migrate tool M0 self-test: SUCCESS"
end function

function versionLine()
  return version.versionLine("migrate")
end function

function componentName()
  return "tools.migrate"
end function

function targetMilestone()
  return "M20"
end function

function isImplemented()
  return true
end function
