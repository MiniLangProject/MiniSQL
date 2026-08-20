// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

import minisql.common.version as m00_common_version
import minisql.common.errors as m01_common_errors
import minisql.common.limits as m02_common_limits
import minisql.common.endian as m03_common_endian
import minisql.common.varint as m04_common_varint
import minisql.common.crc32c as m05_common_crc32c
import minisql.common.uuid as m06_common_uuid
import minisql.common.diagnostics as m07_common_diagnostics
import minisql.config.model as m08_config_model
import minisql.config.loader as m09_config_loader
import minisql.config.validation as m10_config_validation
import minisql.platform.file as m11_platform_file
import minisql.platform.file_win32 as m12_platform_file_win32
import minisql.platform.lock as m13_platform_lock
import minisql.platform.clock as m14_platform_clock
import minisql.platform.network as m15_platform_network
import minisql.storage.page as m16_storage_page
import minisql.storage.superblock as m17_storage_superblock
import minisql.storage.paged_file as m18_storage_paged_file
import minisql.storage.buffer_pool as m19_storage_buffer_pool
import minisql.storage.slotted_page as m20_storage_slotted_page
import minisql.storage.row_codec as m21_storage_row_codec
import minisql.storage.heap_file as m22_storage_heap_file
import minisql.storage.overflow as m23_storage_overflow
import minisql.storage.btree as m24_storage_btree
import minisql.storage.checksum as m25_storage_checksum
import minisql.transaction.transaction as m26_transaction_transaction
import minisql.transaction.wal as m27_transaction_wal
import minisql.transaction.checkpoint as m28_transaction_checkpoint
import minisql.transaction.recovery as m29_transaction_recovery
import minisql.transaction.lock_manager as m30_transaction_lock_manager
import minisql.catalog.catalog as m31_catalog_catalog
import minisql.catalog.metadata as m32_catalog_metadata
import minisql.catalog.statistics as m33_catalog_statistics
import minisql.catalog.schema_history as m34_catalog_schema_history
import minisql.sql.token as m35_sql_token
import minisql.sql.lexer as m36_sql_lexer
import minisql.sql.ast as m37_sql_ast
import minisql.sql.parser as m38_sql_parser
import minisql.sql.binder as m39_sql_binder
import minisql.sql.types as m40_sql_types
import minisql.sql.values as m41_sql_values
import minisql.sql.expressions as m42_sql_expressions
import minisql.sql.dialect as m43_sql_dialect
import minisql.planner.logical_plan as m44_planner_logical_plan
import minisql.planner.rewrites as m45_planner_rewrites
import minisql.planner.cost as m46_planner_cost
import minisql.planner.physical_plan as m47_planner_physical_plan
import minisql.planner.optimizer as m48_planner_optimizer
import minisql.executor.executor as m49_executor_executor
import minisql.executor.scan as m50_executor_scan
import minisql.executor.filter as m51_executor_filter
import minisql.executor.projection as m52_executor_projection
import minisql.executor.join as m53_executor_join
import minisql.executor.aggregate as m54_executor_aggregate
import minisql.executor.sort as m55_executor_sort
import minisql.executor.dml as m56_executor_dml
import minisql.protocol.constants as m57_protocol_constants
import minisql.protocol.messages as m58_protocol_messages
import minisql.protocol.codec as m59_protocol_codec
import minisql.protocol.connection as m60_protocol_connection
import minisql.server.server as m61_server_server
import minisql.server.session as m62_server_session
import minisql.server.database_manager as m63_server_database_manager
import minisql.server.listener as m64_server_listener
import minisql.client.client as m65_client_client
import minisql.client.console as m66_client_console
import minisql.client.formatter as m67_client_formatter
import minisql.tools.check as m68_tools_check
import minisql.tools.backup as m69_tools_backup
import minisql.tools.migrate as m70_tools_migrate

// Records a labeled scalar comparison and returns one when the values differ so the caller can accumulate failures.
function check(actual, expected, label)
  if actual != expected then
    print "M10 module smoke mismatch: " + label + " expected=" + expected + " actual=" + actual
    return 1
  end if
  return 0
end function

// Records a labeled Boolean invariant and returns one when it is not satisfied.
function checkBool(actual, expected, label)
  if actual != expected then
    print "M10 module smoke mismatch: " + label
    return 1
  end if
  return 0
end function

// Runs the module linkage and exported component identity test scenario. It returns zero only after all required invariants pass; invalid arguments, setup failures, or failed assertions produce a non-zero status.
function main(args)
  failures = 0
  failures = failures + check(m00_common_version.componentName(), "common.version", "common.version component")
  failures = failures + check(m00_common_version.targetMilestone(), "M0", "common.version target")
  failures = failures + checkBool(m00_common_version.isImplemented(), true, "common.version implementation")
  failures = failures + check(m01_common_errors.componentName(), "common.errors", "common.errors component")
  failures = failures + check(m01_common_errors.targetMilestone(), "M0", "common.errors target")
  failures = failures + checkBool(m01_common_errors.isImplemented(), true, "common.errors implementation")
  failures = failures + check(m02_common_limits.componentName(), "common.limits", "common.limits component")
  failures = failures + check(m02_common_limits.targetMilestone(), "M0", "common.limits target")
  failures = failures + checkBool(m02_common_limits.isImplemented(), true, "common.limits implementation")
  failures = failures + check(m03_common_endian.componentName(), "common.endian", "common.endian component")
  failures = failures + check(m03_common_endian.targetMilestone(), "M1", "common.endian target")
  failures = failures + checkBool(m03_common_endian.isImplemented(), true, "common.endian implementation")
  failures = failures + check(m04_common_varint.componentName(), "common.varint", "common.varint component")
  failures = failures + check(m04_common_varint.targetMilestone(), "M2", "common.varint target")
  failures = failures + checkBool(m04_common_varint.isImplemented(), true, "common.varint implementation")
  failures = failures + check(m05_common_crc32c.componentName(), "common.crc32c", "common.crc32c component")
  failures = failures + check(m05_common_crc32c.targetMilestone(), "M2", "common.crc32c target")
  failures = failures + checkBool(m05_common_crc32c.isImplemented(), true, "common.crc32c implementation")
  failures = failures + check(m06_common_uuid.componentName(), "common.uuid", "common.uuid component")
  failures = failures + check(m06_common_uuid.targetMilestone(), "M8", "common.uuid target")
  failures = failures + checkBool(m06_common_uuid.isImplemented(), true, "common.uuid implementation")
  failures = failures + check(m07_common_diagnostics.componentName(), "common.diagnostics", "common.diagnostics component")
  failures = failures + check(m07_common_diagnostics.targetMilestone(), "M0", "common.diagnostics target")
  failures = failures + checkBool(m07_common_diagnostics.isImplemented(), true, "common.diagnostics implementation")
  failures = failures + check(m08_config_model.componentName(), "config.model", "config.model component")
  failures = failures + check(m08_config_model.targetMilestone(), "M0", "config.model target")
  failures = failures + checkBool(m08_config_model.isImplemented(), true, "config.model implementation")
  failures = failures + check(m09_config_loader.componentName(), "config.loader", "config.loader component")
  failures = failures + check(m09_config_loader.targetMilestone(), "M8", "config.loader target")
  failures = failures + checkBool(m09_config_loader.isImplemented(), true, "config.loader implementation")
  failures = failures + check(m10_config_validation.componentName(), "config.validation", "config.validation component")
  failures = failures + check(m10_config_validation.targetMilestone(), "M8", "config.validation target")
  failures = failures + checkBool(m10_config_validation.isImplemented(), true, "config.validation implementation")
  failures = failures + check(m11_platform_file.componentName(), "platform.file", "platform.file component")
  failures = failures + check(m11_platform_file.targetMilestone(), "M3", "platform.file target")
  failures = failures + checkBool(m11_platform_file.isImplemented(), true, "platform.file implementation")
  failures = failures + check(m12_platform_file_win32.componentName(), "platform.file_win32", "platform.file_win32 component")
  failures = failures + check(m12_platform_file_win32.targetMilestone(), "M3", "platform.file_win32 target")
  failures = failures + checkBool(m12_platform_file_win32.isImplemented(), true, "platform.file_win32 implementation")
  failures = failures + check(m13_platform_lock.componentName(), "platform.lock", "platform.lock component")
  failures = failures + check(m13_platform_lock.targetMilestone(), "M3", "platform.lock target")
  failures = failures + checkBool(m13_platform_lock.isImplemented(), true, "platform.lock implementation")
  failures = failures + check(m14_platform_clock.componentName(), "platform.clock", "platform.clock component")
  failures = failures + check(m14_platform_clock.targetMilestone(), "M3", "platform.clock target")
  failures = failures + checkBool(m14_platform_clock.isImplemented(), true, "platform.clock implementation")
  failures = failures + check(m15_platform_network.componentName(), "platform.network", "platform.network component")
  failures = failures + check(m15_platform_network.targetMilestone(), "M18", "platform.network target")
  failures = failures + check(m16_storage_page.componentName(), "storage.page", "storage.page component")
  failures = failures + check(m16_storage_page.targetMilestone(), "M4", "storage.page target")
  failures = failures + checkBool(m16_storage_page.isImplemented(), true, "storage.page implementation")
  failures = failures + check(m17_storage_superblock.componentName(), "storage.superblock", "storage.superblock component")
  failures = failures + check(m17_storage_superblock.targetMilestone(), "M4", "storage.superblock target")
  failures = failures + checkBool(m17_storage_superblock.isImplemented(), true, "storage.superblock implementation")
  failures = failures + check(m18_storage_paged_file.componentName(), "storage.paged_file", "storage.paged_file component")
  failures = failures + check(m18_storage_paged_file.targetMilestone(), "M4", "storage.paged_file target")
  failures = failures + checkBool(m18_storage_paged_file.isImplemented(), true, "storage.paged_file implementation")
  failures = failures + check(m19_storage_buffer_pool.componentName(), "storage.buffer_pool", "storage.buffer_pool component")
  failures = failures + check(m19_storage_buffer_pool.targetMilestone(), "M5", "storage.buffer_pool target")
  failures = failures + checkBool(m19_storage_buffer_pool.isImplemented(), true, "storage.buffer_pool implementation")
  failures = failures + check(m20_storage_slotted_page.componentName(), "storage.slotted_page", "storage.slotted_page component")
  failures = failures + check(m20_storage_slotted_page.targetMilestone(), "M9", "storage.slotted_page target")
  failures = failures + checkBool(m20_storage_slotted_page.isImplemented(), true, "storage.slotted_page implementation")
  failures = failures + check(m21_storage_row_codec.componentName(), "storage.row_codec", "storage.row_codec component")
  failures = failures + check(m21_storage_row_codec.targetMilestone(), "M9", "storage.row_codec target")
  failures = failures + checkBool(m21_storage_row_codec.isImplemented(), true, "storage.row_codec implementation")
  failures = failures + check(m22_storage_heap_file.componentName(), "storage.heap_file", "storage.heap_file component")
  failures = failures + check(m22_storage_heap_file.targetMilestone(), "M9", "storage.heap_file target")
  failures = failures + checkBool(m22_storage_heap_file.isImplemented(), true, "storage.heap_file implementation")
  failures = failures + check(m23_storage_overflow.componentName(), "storage.overflow", "storage.overflow component")
  failures = failures + check(m23_storage_overflow.targetMilestone(), "M10", "storage.overflow target")
  failures = failures + checkBool(m23_storage_overflow.isImplemented(), true, "storage.overflow implementation")
  failures = failures + check(m24_storage_btree.componentName(), "storage.btree", "storage.btree component")
  failures = failures + check(m24_storage_btree.targetMilestone(), "M11", "storage.btree target")
  failures = failures + check(m25_storage_checksum.componentName(), "storage.checksum", "storage.checksum component")
  failures = failures + check(m25_storage_checksum.targetMilestone(), "M2", "storage.checksum target")
  failures = failures + checkBool(m25_storage_checksum.isImplemented(), true, "storage.checksum implementation")
  failures = failures + check(m26_transaction_transaction.componentName(), "transaction.transaction", "transaction.transaction component")
  failures = failures + check(m26_transaction_transaction.targetMilestone(), "M6", "transaction.transaction target")
  failures = failures + checkBool(m26_transaction_transaction.isImplemented(), true, "transaction.transaction implementation")
  failures = failures + check(m27_transaction_wal.componentName(), "transaction.wal", "transaction.wal component")
  failures = failures + check(m27_transaction_wal.targetMilestone(), "M6", "transaction.wal target")
  failures = failures + checkBool(m27_transaction_wal.isImplemented(), true, "transaction.wal implementation")
  failures = failures + check(m28_transaction_checkpoint.componentName(), "transaction.checkpoint", "transaction.checkpoint component")
  failures = failures + check(m28_transaction_checkpoint.targetMilestone(), "M7", "transaction.checkpoint target")
  failures = failures + checkBool(m28_transaction_checkpoint.isImplemented(), true, "transaction.checkpoint implementation")
  failures = failures + check(m29_transaction_recovery.componentName(), "transaction.recovery", "transaction.recovery component")
  failures = failures + check(m29_transaction_recovery.targetMilestone(), "M7", "transaction.recovery target")
  failures = failures + checkBool(m29_transaction_recovery.isImplemented(), true, "transaction.recovery implementation")
  failures = failures + check(m30_transaction_lock_manager.componentName(), "transaction.lock_manager", "transaction.lock_manager component")
  failures = failures + check(m30_transaction_lock_manager.targetMilestone(), "M6", "transaction.lock_manager target")
  failures = failures + checkBool(m30_transaction_lock_manager.isImplemented(), true, "transaction.lock_manager implementation")
  failures = failures + check(m31_catalog_catalog.componentName(), "catalog.catalog", "catalog.catalog component")
  failures = failures + check(m31_catalog_catalog.targetMilestone(), "M8", "catalog.catalog target")
  failures = failures + checkBool(m31_catalog_catalog.isImplemented(), true, "catalog.catalog implementation")
  failures = failures + check(m32_catalog_metadata.componentName(), "catalog.metadata", "catalog.metadata component")
  failures = failures + check(m32_catalog_metadata.targetMilestone(), "M8", "catalog.metadata target")
  failures = failures + checkBool(m32_catalog_metadata.isImplemented(), true, "catalog.metadata implementation")
  failures = failures + check(m33_catalog_statistics.componentName(), "catalog.statistics", "catalog.statistics component")
  failures = failures + check(m33_catalog_statistics.targetMilestone(), "M17", "catalog.statistics target")
  failures = failures + check(m34_catalog_schema_history.componentName(), "catalog.schema_history", "catalog.schema_history component")
  failures = failures + check(m34_catalog_schema_history.targetMilestone(), "M14", "catalog.schema_history target")
  failures = failures + check(m35_sql_token.componentName(), "sql.token", "sql.token component")
  failures = failures + check(m35_sql_token.targetMilestone(), "M12", "sql.token target")
  failures = failures + check(m36_sql_lexer.componentName(), "sql.lexer", "sql.lexer component")
  failures = failures + check(m36_sql_lexer.targetMilestone(), "M12", "sql.lexer target")
  failures = failures + check(m37_sql_ast.componentName(), "sql.ast", "sql.ast component")
  failures = failures + check(m37_sql_ast.targetMilestone(), "M12", "sql.ast target")
  failures = failures + check(m38_sql_parser.componentName(), "sql.parser", "sql.parser component")
  failures = failures + check(m38_sql_parser.targetMilestone(), "M12", "sql.parser target")
  failures = failures + check(m39_sql_binder.componentName(), "sql.binder", "sql.binder component")
  failures = failures + check(m39_sql_binder.targetMilestone(), "M13", "sql.binder target")
  failures = failures + check(m40_sql_types.componentName(), "sql.types", "sql.types component")
  failures = failures + check(m40_sql_types.targetMilestone(), "M13", "sql.types target")
  failures = failures + check(m41_sql_values.componentName(), "sql.values", "sql.values component")
  failures = failures + check(m41_sql_values.targetMilestone(), "M13", "sql.values target")
  failures = failures + check(m42_sql_expressions.componentName(), "sql.expressions", "sql.expressions component")
  failures = failures + check(m42_sql_expressions.targetMilestone(), "M13", "sql.expressions target")
  failures = failures + check(m43_sql_dialect.componentName(), "sql.dialect", "sql.dialect component")
  failures = failures + check(m43_sql_dialect.targetMilestone(), "M12", "sql.dialect target")
  failures = failures + check(m44_planner_logical_plan.componentName(), "planner.logical_plan", "planner.logical_plan component")
  failures = failures + check(m44_planner_logical_plan.targetMilestone(), "M16", "planner.logical_plan target")
  failures = failures + check(m45_planner_rewrites.componentName(), "planner.rewrites", "planner.rewrites component")
  failures = failures + check(m45_planner_rewrites.targetMilestone(), "M17", "planner.rewrites target")
  failures = failures + check(m46_planner_cost.componentName(), "planner.cost", "planner.cost component")
  failures = failures + check(m46_planner_cost.targetMilestone(), "M17", "planner.cost target")
  failures = failures + check(m47_planner_physical_plan.componentName(), "planner.physical_plan", "planner.physical_plan component")
  failures = failures + check(m47_planner_physical_plan.targetMilestone(), "M16", "planner.physical_plan target")
  failures = failures + check(m48_planner_optimizer.componentName(), "planner.optimizer", "planner.optimizer component")
  failures = failures + check(m48_planner_optimizer.targetMilestone(), "M17", "planner.optimizer target")
  failures = failures + check(m49_executor_executor.componentName(), "executor.executor", "executor.executor component")
  failures = failures + check(m49_executor_executor.targetMilestone(), "M15", "executor.executor target")
  failures = failures + check(m50_executor_scan.componentName(), "executor.scan", "executor.scan component")
  failures = failures + check(m50_executor_scan.targetMilestone(), "M15", "executor.scan target")
  failures = failures + check(m51_executor_filter.componentName(), "executor.filter", "executor.filter component")
  failures = failures + check(m51_executor_filter.targetMilestone(), "M15", "executor.filter target")
  failures = failures + check(m52_executor_projection.componentName(), "executor.projection", "executor.projection component")
  failures = failures + check(m52_executor_projection.targetMilestone(), "M15", "executor.projection target")
  failures = failures + check(m53_executor_join.componentName(), "executor.join", "executor.join component")
  failures = failures + check(m53_executor_join.targetMilestone(), "M16", "executor.join target")
  failures = failures + check(m54_executor_aggregate.componentName(), "executor.aggregate", "executor.aggregate component")
  failures = failures + check(m54_executor_aggregate.targetMilestone(), "M16", "executor.aggregate target")
  failures = failures + check(m55_executor_sort.componentName(), "executor.sort", "executor.sort component")
  failures = failures + check(m55_executor_sort.targetMilestone(), "M16", "executor.sort target")
  failures = failures + check(m56_executor_dml.componentName(), "executor.dml", "executor.dml component")
  failures = failures + check(m56_executor_dml.targetMilestone(), "M15", "executor.dml target")
  failures = failures + check(m57_protocol_constants.componentName(), "protocol.constants", "protocol.constants component")
  failures = failures + check(m57_protocol_constants.targetMilestone(), "M18", "protocol.constants target")
  failures = failures + check(m58_protocol_messages.componentName(), "protocol.messages", "protocol.messages component")
  failures = failures + check(m58_protocol_messages.targetMilestone(), "M18", "protocol.messages target")
  failures = failures + check(m59_protocol_codec.componentName(), "protocol.codec", "protocol.codec component")
  failures = failures + check(m59_protocol_codec.targetMilestone(), "M18", "protocol.codec target")
  failures = failures + check(m60_protocol_connection.componentName(), "protocol.connection", "protocol.connection component")
  failures = failures + check(m60_protocol_connection.targetMilestone(), "M18", "protocol.connection target")
  failures = failures + check(m61_server_server.componentName(), "server.server", "server.server component")
  failures = failures + check(m61_server_server.targetMilestone(), "M0", "server.server target")
  failures = failures + checkBool(m61_server_server.isImplemented(), true, "server.server implementation")
  failures = failures + check(m62_server_session.componentName(), "server.session", "server.session component")
  failures = failures + check(m62_server_session.targetMilestone(), "M18", "server.session target")
  failures = failures + check(m63_server_database_manager.componentName(), "server.database_manager", "server.database_manager component")
  failures = failures + check(m63_server_database_manager.targetMilestone(), "M8", "server.database_manager target")
  failures = failures + checkBool(m63_server_database_manager.isImplemented(), true, "server.database_manager implementation")
  failures = failures + check(m64_server_listener.componentName(), "server.listener", "server.listener component")
  failures = failures + check(m64_server_listener.targetMilestone(), "M18", "server.listener target")
  failures = failures + check(m65_client_client.componentName(), "client.client", "client.client component")
  failures = failures + check(m65_client_client.targetMilestone(), "M0", "client.client target")
  failures = failures + checkBool(m65_client_client.isImplemented(), true, "client.client implementation")
  failures = failures + check(m66_client_console.componentName(), "client.console", "client.console component")
  failures = failures + check(m66_client_console.targetMilestone(), "M18", "client.console target")
  failures = failures + check(m67_client_formatter.componentName(), "client.formatter", "client.formatter component")
  failures = failures + check(m67_client_formatter.targetMilestone(), "M18", "client.formatter target")
  failures = failures + check(m68_tools_check.componentName(), "tools.check", "tools.check component")
  failures = failures + check(m68_tools_check.targetMilestone(), "M20", "tools.check target")
  failures = failures + check(m69_tools_backup.componentName(), "tools.backup", "tools.backup component")
  failures = failures + check(m69_tools_backup.targetMilestone(), "M20", "tools.backup target")
  failures = failures + check(m70_tools_migrate.componentName(), "tools.migrate", "tools.migrate component")
  failures = failures + check(m70_tools_migrate.targetMilestone(), "M20", "tools.migrate target")
  if failures != 0 then
    print "MiniSQL M10 module smoke test: FAIL (failures=" + failures + ")"
    return 1
  end if
  print "MiniSQL M10 module smoke test: SUCCESS (71 modules)"
  return 0
end function
