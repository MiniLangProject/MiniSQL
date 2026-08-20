// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.version as m_common_version
import minisql.common.errors as m_common_errors
import minisql.common.limits as m_common_limits
import minisql.common.endian as m_common_endian
import minisql.common.varint as m_common_varint
import minisql.common.crc32c as m_common_crc32c
import minisql.common.uuid as m_common_uuid
import minisql.common.diagnostics as m_common_diagnostics
import minisql.config.model as m_config_model
import minisql.config.loader as m_config_loader
import minisql.config.validation as m_config_validation
import minisql.platform.file as m_platform_file
import minisql.platform.file_win32 as m_platform_file_win32
import minisql.platform.lock as m_platform_lock
import minisql.platform.clock as m_platform_clock
import minisql.platform.network as m_platform_network
import minisql.storage.page as m_storage_page
import minisql.storage.superblock as m_storage_superblock
import minisql.storage.paged_file as m_storage_paged_file
import minisql.storage.buffer_pool as m_storage_buffer_pool
import minisql.storage.slotted_page as m_storage_slotted_page
import minisql.storage.row_codec as m_storage_row_codec
import minisql.storage.heap_file as m_storage_heap_file
import minisql.storage.overflow as m_storage_overflow
import minisql.storage.btree as m_storage_btree
import minisql.storage.checksum as m_storage_checksum
import minisql.transaction.transaction as m_transaction_transaction
import minisql.transaction.wal as m_transaction_wal
import minisql.transaction.checkpoint as m_transaction_checkpoint
import minisql.transaction.recovery as m_transaction_recovery
import minisql.transaction.lock_manager as m_transaction_lock_manager
import minisql.catalog.catalog as m_catalog_catalog
import minisql.catalog.metadata as m_catalog_metadata
import minisql.catalog.statistics as m_catalog_statistics
import minisql.catalog.schema_history as m_catalog_schema_history
import minisql.sql.token as m_sql_token
import minisql.sql.lexer as m_sql_lexer
import minisql.sql.ast as m_sql_ast
import minisql.sql.parser as m_sql_parser
import minisql.sql.binder as m_sql_binder
import minisql.sql.types as m_sql_types
import minisql.sql.values as m_sql_values
import minisql.sql.expressions as m_sql_expressions
import minisql.sql.dialect as m_sql_dialect
import minisql.planner.logical_plan as m_planner_logical_plan
import minisql.planner.rewrites as m_planner_rewrites
import minisql.planner.cost as m_planner_cost
import minisql.planner.physical_plan as m_planner_physical_plan
import minisql.planner.optimizer as m_planner_optimizer
import minisql.executor.executor as m_executor_executor
import minisql.executor.scan as m_executor_scan
import minisql.executor.filter as m_executor_filter
import minisql.executor.projection as m_executor_projection
import minisql.executor.join as m_executor_join
import minisql.executor.aggregate as m_executor_aggregate
import minisql.executor.sort as m_executor_sort
import minisql.executor.dml as m_executor_dml
import minisql.protocol.constants as m_protocol_constants
import minisql.protocol.messages as m_protocol_messages
import minisql.protocol.codec as m_protocol_codec
import minisql.protocol.connection as m_protocol_connection
import minisql.server.server as m_server_server
import minisql.server.session as m_server_session
import minisql.server.database_manager as m_server_database_manager
import minisql.server.listener as m_server_listener
import minisql.client.client as m_client_client
import minisql.client.console as m_client_console
import minisql.client.formatter as m_client_formatter
import minisql.tools.check as m_tools_check
import minisql.tools.backup as m_tools_backup
import minisql.tools.migrate as m_tools_migrate

// Compares a module's exported component identity with the expected stable name and returns a failure contribution.
function checkComponent(actual, expected)
  if actual != expected then
    print "M5 module identity mismatch: expected=" + expected + " actual=" + actual
    return 1
  end if
  return 0
end function

// Checks that a module reports the expected implementation marker and returns a failure contribution.
function checkImplemented(value, expected, label)
  if value != expected then
    print "M5 implementation marker mismatch: " + label
    return 1
  end if
  return 0
end function

// Runs the module linkage and exported component identity test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  failures = 0
  failures = failures + checkComponent(m_common_version.componentName(), "common.version")
  failures = failures + checkComponent(m_common_errors.componentName(), "common.errors")
  failures = failures + checkComponent(m_common_limits.componentName(), "common.limits")
  failures = failures + checkComponent(m_common_endian.componentName(), "common.endian")
  failures = failures + checkComponent(m_common_varint.componentName(), "common.varint")
  failures = failures + checkComponent(m_common_crc32c.componentName(), "common.crc32c")
  failures = failures + checkComponent(m_common_uuid.componentName(), "common.uuid")
  failures = failures + checkComponent(m_common_diagnostics.componentName(), "common.diagnostics")
  failures = failures + checkComponent(m_config_model.componentName(), "config.model")
  failures = failures + checkComponent(m_config_loader.componentName(), "config.loader")
  failures = failures + checkComponent(m_config_validation.componentName(), "config.validation")
  failures = failures + checkComponent(m_platform_file.componentName(), "platform.file")
  failures = failures + checkComponent(m_platform_file_win32.componentName(), "platform.file_win32")
  failures = failures + checkComponent(m_platform_lock.componentName(), "platform.lock")
  failures = failures + checkComponent(m_platform_clock.componentName(), "platform.clock")
  failures = failures + checkComponent(m_platform_network.componentName(), "platform.network")
  failures = failures + checkComponent(m_storage_page.componentName(), "storage.page")
  failures = failures + checkComponent(m_storage_superblock.componentName(), "storage.superblock")
  failures = failures + checkComponent(m_storage_paged_file.componentName(), "storage.paged_file")
  failures = failures + checkComponent(m_storage_buffer_pool.componentName(), "storage.buffer_pool")
  failures = failures + checkComponent(m_storage_slotted_page.componentName(), "storage.slotted_page")
  failures = failures + checkComponent(m_storage_row_codec.componentName(), "storage.row_codec")
  failures = failures + checkComponent(m_storage_heap_file.componentName(), "storage.heap_file")
  failures = failures + checkComponent(m_storage_overflow.componentName(), "storage.overflow")
  failures = failures + checkComponent(m_storage_btree.componentName(), "storage.btree")
  failures = failures + checkComponent(m_storage_checksum.componentName(), "storage.checksum")
  failures = failures + checkComponent(m_transaction_transaction.componentName(), "transaction.transaction")
  failures = failures + checkComponent(m_transaction_wal.componentName(), "transaction.wal")
  failures = failures + checkComponent(m_transaction_checkpoint.componentName(), "transaction.checkpoint")
  failures = failures + checkComponent(m_transaction_recovery.componentName(), "transaction.recovery")
  failures = failures + checkComponent(m_transaction_lock_manager.componentName(), "transaction.lock_manager")
  failures = failures + checkComponent(m_catalog_catalog.componentName(), "catalog.catalog")
  failures = failures + checkComponent(m_catalog_metadata.componentName(), "catalog.metadata")
  failures = failures + checkComponent(m_catalog_statistics.componentName(), "catalog.statistics")
  failures = failures + checkComponent(m_catalog_schema_history.componentName(), "catalog.schema_history")
  failures = failures + checkComponent(m_sql_token.componentName(), "sql.token")
  failures = failures + checkComponent(m_sql_lexer.componentName(), "sql.lexer")
  failures = failures + checkComponent(m_sql_ast.componentName(), "sql.ast")
  failures = failures + checkComponent(m_sql_parser.componentName(), "sql.parser")
  failures = failures + checkComponent(m_sql_binder.componentName(), "sql.binder")
  failures = failures + checkComponent(m_sql_types.componentName(), "sql.types")
  failures = failures + checkComponent(m_sql_values.componentName(), "sql.values")
  failures = failures + checkComponent(m_sql_expressions.componentName(), "sql.expressions")
  failures = failures + checkComponent(m_sql_dialect.componentName(), "sql.dialect")
  failures = failures + checkComponent(m_planner_logical_plan.componentName(), "planner.logical_plan")
  failures = failures + checkComponent(m_planner_rewrites.componentName(), "planner.rewrites")
  failures = failures + checkComponent(m_planner_cost.componentName(), "planner.cost")
  failures = failures + checkComponent(m_planner_physical_plan.componentName(), "planner.physical_plan")
  failures = failures + checkComponent(m_planner_optimizer.componentName(), "planner.optimizer")
  failures = failures + checkComponent(m_executor_executor.componentName(), "executor.executor")
  failures = failures + checkComponent(m_executor_scan.componentName(), "executor.scan")
  failures = failures + checkComponent(m_executor_filter.componentName(), "executor.filter")
  failures = failures + checkComponent(m_executor_projection.componentName(), "executor.projection")
  failures = failures + checkComponent(m_executor_join.componentName(), "executor.join")
  failures = failures + checkComponent(m_executor_aggregate.componentName(), "executor.aggregate")
  failures = failures + checkComponent(m_executor_sort.componentName(), "executor.sort")
  failures = failures + checkComponent(m_executor_dml.componentName(), "executor.dml")
  failures = failures + checkComponent(m_protocol_constants.componentName(), "protocol.constants")
  failures = failures + checkComponent(m_protocol_messages.componentName(), "protocol.messages")
  failures = failures + checkComponent(m_protocol_codec.componentName(), "protocol.codec")
  failures = failures + checkComponent(m_protocol_connection.componentName(), "protocol.connection")
  failures = failures + checkComponent(m_server_server.componentName(), "server.server")
  failures = failures + checkComponent(m_server_session.componentName(), "server.session")
  failures = failures + checkComponent(m_server_database_manager.componentName(), "server.database_manager")
  failures = failures + checkComponent(m_server_listener.componentName(), "server.listener")
  failures = failures + checkComponent(m_client_client.componentName(), "client.client")
  failures = failures + checkComponent(m_client_console.componentName(), "client.console")
  failures = failures + checkComponent(m_client_formatter.componentName(), "client.formatter")
  failures = failures + checkComponent(m_tools_check.componentName(), "tools.check")
  failures = failures + checkComponent(m_tools_backup.componentName(), "tools.backup")
  failures = failures + checkComponent(m_tools_migrate.componentName(), "tools.migrate")

  failures = failures + checkImplemented(m_common_endian.isImplemented(), true, "minisql.common.endian")
  failures = failures + checkImplemented(m_common_varint.isImplemented(), true, "minisql.common.varint")
  failures = failures + checkImplemented(m_common_crc32c.isImplemented(), true, "minisql.common.crc32c")
  failures = failures + checkImplemented(m_storage_checksum.isImplemented(), true, "minisql.storage.checksum")
  failures = failures + checkImplemented(m_platform_file.isImplemented(), true, "minisql.platform.file")
  failures = failures + checkImplemented(m_platform_file_win32.isImplemented(), true, "minisql.platform.file_win32")
  failures = failures + checkImplemented(m_platform_lock.isImplemented(), true, "minisql.platform.lock")
  failures = failures + checkImplemented(m_platform_clock.isImplemented(), true, "minisql.platform.clock")
  failures = failures + checkImplemented(m_storage_page.isImplemented(), true, "minisql.storage.page")
  failures = failures + checkImplemented(m_storage_superblock.isImplemented(), true, "minisql.storage.superblock")
  failures = failures + checkImplemented(m_storage_paged_file.isImplemented(), true, "minisql.storage.paged_file")
  failures = failures + checkImplemented(m_storage_buffer_pool.isImplemented(), true, "minisql.storage.buffer_pool")

  if failures != 0 then
    print "MiniSQL M5 module smoke test: FAIL (failures=" + failures + ")"
    return 1
  end if

  print "MiniSQL M5 module smoke test: SUCCESS (71 modules)"
  return 0
end function
