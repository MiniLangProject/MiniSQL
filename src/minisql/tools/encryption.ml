package minisql.tools.encryption
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

import minisql.catalog.catalog as catalog
import minisql.catalog.schema_history as schema_history
import minisql.platform.file as file_api
import minisql.platform.lock as file_lock
import minisql.security.key_provider as key_provider
import minisql.server.database_manager as database_manager
import minisql.storage.paged_file as paged_file
import minisql.common.uuid as uuid

const INVALID_ARGUMENT = 9001

// Creates a structured encryption-administration error.
function fail(operation, message)
  return error(INVALID_ARGUMENT, "tools.encryption." + operation + ": " + message)
end function

// Tests integer membership in a bounded metadata array.
function contains(values, wanted)
  for each value in values
    if value == wanted then return true end if
  end for
  return false
end function

// Collects unique physical index identifiers from schema constraints.
function indexIds(state)
  output = []
  for each table in state.tables
    for each constraint in table.constraints
      if constraint.indexId > 0 and not contains(output, constraint.indexId) then output = output + [constraint.indexId] end if
    end for
  end for
  return output
end function

// Adds one existing physical artifact to a migration plan.
function addIfExists(paths, path)
  if file_api.fileExists(path) then return paths + [path] end if
  return paths
end function

// Releases the migration's process-visible database lock and owning handle.
function releaseMigrationLock(lockToken, lockFile)
  released = try(file_lock.release(lockToken))
  closed = try(file_api.close(lockFile))
  if typeof(released) == "error" then return released end if
  return closed
end function

// Enables resumable TDE migration. Mixed plaintext/encrypted files are valid
// during conversion because every superblock carries its own feature bit.
// Enables or resumes offline TDE migration for one database.
function enable(databasePath, keyFilePath)
  if typeof(databasePath) != "string" or len(databasePath) == 0 then return fail("enable", "database path must be non-empty") end if
  provider = try(key_provider.fileProvider(keyFilePath))
  if typeof(provider) == "error" then return provider end if
  database = try(database_manager.open(databasePath))
  if typeof(database) == "error" then return database end if
  databaseId = bytes(database.catalogHandle.metadata.databaseId)
  tableIds = []
  for each table in database.catalogHandle.catalog.tables
    tableIds = tableIds + [table.tableId]
  end for
  state = try(schema_history.loadOrCreate(databasePath, databaseId))
  indexes = indexIds(state)
  closed = try(database_manager.close(database))
  if typeof(closed) == "error" then return closed end if
  // Reacquire the database lock before the first format change. If a server
  // wins the close/reacquire race, migration fails without modifying storage.
  lockFile = try(file_api.openReadWrite(file_api.joinPath(databasePath, "db.lock"), false))
  if typeof(lockFile) == "error" then return lockFile end if
  lockToken = try(file_lock.acquireExclusive(lockFile, true))
  if typeof(lockToken) == "error" then file_api.close(lockFile); return lockToken end if
  if not file_api.fileExists(key_provider.metadataPath(databasePath)) then
    created = try(key_provider.createEnvelope(databasePath, databaseId, provider))
    if typeof(created) == "error" then releaseMigrationLock(lockToken, lockFile); return created end if
  end if
  paths = []
  paths = addIfExists(paths, file_api.joinPath(databasePath, "db.meta"))
  paths = addIfExists(paths, file_api.joinPath(file_api.joinPath(databasePath, "catalog"), "catalog.tbl"))
  paths = addIfExists(paths, catalog.securityFilePath(databasePath))
  paths = addIfExists(paths, catalog.securityGenerationFilePath(databasePath, 0))
  paths = addIfExists(paths, catalog.securityGenerationFilePath(databasePath, 1))
  for each tableId in tableIds
    paths = addIfExists(paths, catalog.tableFilePath(databasePath, tableId))
  end for
  for each indexId in indexes
    paths = addIfExists(paths, schema_history.indexFilePath(databasePath, indexId))
  end for
  for each path in paths
    converted = try(paged_file.encryptExisting(path))
    if typeof(converted) == "error" then releaseMigrationLock(lockToken, lockFile); return converted end if
  end for
  released = try(releaseMigrationLock(lockToken, lockFile))
  if typeof(released) == "error" then return released end if
  return len(paths)
end function

// Rewraps the database DEK under a new external KEK.
function rotate(databasePath, newKeyFilePath)
  provider = try(key_provider.fileProvider(newKeyFilePath))
  if typeof(provider) == "error" then return provider end if
  return key_provider.rotateEnvelope(databasePath, provider)
end function

// Creates a durable new raw 256-bit provider key.
function generateKeyFile(path)
  if typeof(path) != "string" or len(path) == 0 or file_api.pathExists(path) then return fail("generateKeyFile", "destination must be a new path") end if
  key = try(uuid.randomBytes(32))
  if typeof(key) == "error" then return key end if
  handle = try(file_api.createNewDurable(path))
  if typeof(handle) == "error" then uuid.wipeSecret(key); return handle end if
  written = try(file_api.writeAt(handle, 0, key, 0, len(key)))
  uuid.wipeSecret(key)
  if typeof(written) == "error" then ignoredClose = try(file_api.close(handle)); return written end if
  flushed = try(file_api.flush(handle))
  closed = try(file_api.close(handle))
  if typeof(flushed) == "error" then return flushed end if
  return closed
end function

// Returns the stable component name.
function componentName()
  return "tools.encryption"
end function

// Returns the milestone introducing this component.
function targetMilestone()
  return "M79"
end function

// Reports that the component is implemented.
function isImplemented()
  return true
end function
