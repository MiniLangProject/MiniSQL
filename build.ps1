# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.
# Software distributed under the License is provided on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

<#
.SYNOPSIS
Compiles MiniSQL applications and, unless requested otherwise, every native test.
.PARAMETER Compiler
Path to the Python or native self-hosted MiniLang compiler; discovery is used
when omitted.
.PARAMETER Python
Python executable used when the selected compiler is a Python script.
.PARAMETER Clean
Removes the existing binary output directory before compilation.
.PARAMETER AppsOnly
Limits compilation to the public application entry points available on the
selected target. The native Workbench remains Windows-only.
.PARAMETER Target
Selects the native MiniLang target: windows-x64 or linux-x64.
#>
param(
  [string]$Compiler = $env:MINILANG_COMPILER,
  [string]$Python = "python",
  [ValidateSet("windows-x64", "linux-x64")]
  [string]$Target = "windows-x64",
  [switch]$Clean,
  [switch]$AppsOnly
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceRoot = Join-Path $Root "src"
$NativeTarget = $Target
$BinDirectoryName = "bin"
if ($NativeTarget -eq "linux-x64") { $BinDirectoryName = "bin-linux" }
$BinDir = Join-Path $Root ("build\" + $BinDirectoryName)

# Resolves an explicit or conventional compiler path and fails with actionable
# setup guidance when no compiler exists. The returned path is absolute.
function Resolve-MiniLangCompiler([string]$Requested) {
  $Candidates = @()
  if ($Requested) { $Candidates += $Requested }
  if ($env:MINILANG_COMPILER) { $Candidates += $env:MINILANG_COMPILER }
  $Candidates += @(
    (Join-Path $Root "mlc_win64.py"),
    (Join-Path $Root "tools\minilang\mlc_win64.py"),
    (Join-Path $Root "..\MiniLangCompilerPy\mlc_win64.py"),
    (Join-Path $Root "..\MiniLang\mlc_win64.py"),
    (Join-Path $Root "..\mlc_win64.py")
  )

  foreach ($Candidate in $Candidates) {
    if ($Candidate -and (Test-Path -LiteralPath $Candidate -PathType Leaf)) {
      return (Resolve-Path -LiteralPath $Candidate).Path
    }
  }
  throw "MiniLang compiler not found. Pass -Compiler C:\path\to\mlc_win64.py or mlc_win64.exe, or set MINILANG_COMPILER."
}

# Finds the compiler package root whether the selected entry point lives at
# repository root (Python) or in the conventional build directory (native).
function Resolve-MiniLangLibraryRoot([string]$CompilerPath) {
  $Candidate = Split-Path -Parent $CompilerPath
  for ($Depth = 0; $Depth -lt 4 -and -not [string]::IsNullOrWhiteSpace($Candidate); $Depth++) {
    if (Test-Path -LiteralPath (Join-Path $Candidate "std") -PathType Container) {
      return $Candidate
    }
    $Parent = Split-Path -Parent $Candidate
    if ($Parent -eq $Candidate) { break }
    $Candidate = $Parent
  }
  return ""
}

# Compiles one MiniLang entry point, adds the project and compiler standard-library
# include roots, and verifies both the process result and expected output file.
function Invoke-Compile([string]$CompilerPath, [string]$InputPath, [string]$OutputPath, [string]$NativeTarget) {
  Write-Host "Compiling $InputPath -> $OutputPath"
  $CompilerRoot = Resolve-MiniLangLibraryRoot $CompilerPath
  $CompilerArguments = @($InputPath, $OutputPath, "-I", $SourceRoot)
  if (-not [string]::IsNullOrWhiteSpace($CompilerRoot)) {
    $CompilerArguments += @("-I", $CompilerRoot)
  }
  # Large MiniSQL programs exceed the practical monolithic working set of the
  # self-hosted compiler. Its canonical object pipeline is byte-identical and
  # bounds the live code-generation graph once module analysis is complete.
  if ([System.IO.Path]::GetExtension($CompilerPath) -ine ".py") {
    $CompilerArguments += "--object-pipeline"
  }
  $CompilerArguments += @("--target", $NativeTarget, "--keep-going", "--max-errors", "100")
  if ([System.IO.Path]::GetExtension($CompilerPath) -ieq ".py") {
    & $Python $CompilerPath @CompilerArguments
  } else {
    & $CompilerPath @CompilerArguments
  }
  if ($LASTEXITCODE -ne 0) {
    throw "Compilation failed for $InputPath (exit code $LASTEXITCODE)."
  }
  if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
    throw "Compiler reported success but did not create $OutputPath."
  }
}

if ($Clean -and (Test-Path -LiteralPath $BinDir)) {
  Remove-Item -Recurse -Force -LiteralPath $BinDir
}
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$CompilerPath = Resolve-MiniLangCompiler $Compiler
Write-Host "MiniLang compiler: $CompilerPath"

$Targets = @(
  @{ Input = "src\apps\minisqld\main.ml"; Output = "minisqld.exe" },
  @{ Input = "src\apps\minisql\main.ml"; Output = "minisql.exe" },
  @{ Input = "src\apps\minisql_check\main.ml"; Output = "minisql-check.exe" },
  @{ Input = "src\apps\minisql_backup\main.ml"; Output = "minisql-backup.exe" },
  @{ Input = "src\apps\minisql_migrate\main.ml"; Output = "minisql-migrate.exe" },
  @{ Input = "src\apps\minisql_admin\main.ml"; Output = "minisql-admin.exe" },
  @{ Input = "src\tests\m0_all_modules.ml"; Output = "minisql-m0-modules.exe" },
  @{ Input = "src\tests\m1_int64_model.ml"; Output = "minisql-m1r1-int64-model.exe" },
  @{ Input = "src\tests\m1_endian_golden.ml"; Output = "minisql-m1r1-endian-golden.exe" },
  @{ Input = "src\tests\m1_endian_errors.ml"; Output = "minisql-m1r1-endian-errors.exe" },
  @{ Input = "src\tests\m1_endian_roundtrip.ml"; Output = "minisql-m1r1-endian-roundtrip.exe" },
  @{ Input = "src\tests\m2_varint.ml"; Output = "minisql-m2-varint.exe" },
  @{ Input = "src\tests\m2_crc_envelope.ml"; Output = "minisql-m2-crc-envelope.exe" },
  @{ Input = "src\tests\m3_file.ml"; Output = "minisql-m3-file.exe" },
  @{ Input = "src\tests\m3_durable_writer.ml"; Output = "minisql-m3-durable-writer.exe" },
  @{ Input = "src\tests\m3_durable_reader.ml"; Output = "minisql-m3-durable-reader.exe" },
  @{ Input = "src\tests\m3_lock_worker.ml"; Output = "minisql-m3-lock-worker.exe" },
  @{ Input = "src\tests\m4_page_superblock.ml"; Output = "minisql-m4-page-superblock.exe" },
  @{ Input = "src\tests\m4_paged_file.ml"; Output = "minisql-m4-paged-file.exe" },
  @{ Input = "src\tests\m5_buffer_pool.ml"; Output = "minisql-m5-buffer-pool.exe" },
  @{ Input = "src\tests\m5_buffer_pool_stress.ml"; Output = "minisql-m5-buffer-pool-stress.exe" },
  @{ Input = "src\tests\m5_all_modules.ml"; Output = "minisql-m5-modules.exe" },
  @{ Input = "src\tests\m6_wal.ml"; Output = "minisql-m6-wal.exe" },
  @{ Input = "src\tests\m6_transaction.ml"; Output = "minisql-m6-transaction.exe" },
  @{ Input = "src\tests\m7_checkpoint.ml"; Output = "minisql-m7-checkpoint.exe" },
  @{ Input = "src\tests\m7_recovery.ml"; Output = "minisql-m7-recovery.exe" },
  @{ Input = "src\tests\m7_crash_worker.ml"; Output = "minisql-m7-crash-worker.exe" },
  @{ Input = "src\tests\m8_config.ml"; Output = "minisql-m8-config.exe" },
  @{ Input = "src\tests\m8_catalog.ml"; Output = "minisql-m8-catalog.exe" },
  @{ Input = "src\tests\m9_row_codec.ml"; Output = "minisql-m9-row-codec.exe" },
  @{ Input = "src\tests\m9_heap_file.ml"; Output = "minisql-m9-heap-file.exe" },
  @{ Input = "src\tests\m10_overflow.ml"; Output = "minisql-m10-overflow.exe" },
  @{ Input = "src\tests\m10_all_modules.ml"; Output = "minisql-m10-modules.exe" },
  @{ Input = "src\tests\m11_btree.ml"; Output = "minisql-m11-btree.exe" },
  @{ Input = "src\tests\m12_sql_frontend.ml"; Output = "minisql-m12-sql-front-end.exe" },
  @{ Input = "src\tests\m13_binding_values.ml"; Output = "minisql-m13-binding-values.exe" },
  @{ Input = "src\tests\m14_transactional_ddl.ml"; Output = "minisql-m14-transactional-ddl.exe" },
  @{ Input = "src\tests\m15_sql_engine.ml"; Output = "minisql-m15-sql-engine.exe" },
  @{ Input = "src\tests\m15_all_modules.ml"; Output = "minisql-m15-modules.exe" },
  @{ Input = "src\tests\m16_relational_engine.ml"; Output = "minisql-m16-relational.exe" },
  @{ Input = "src\tests\m17_statistics_optimizer.ml"; Output = "minisql-m17-statistics.exe" },
  @{ Input = "src\tests\m18_protocol.ml"; Output = "minisql-m18-protocol.exe" },
  @{ Input = "src\tests\m18_server_worker.ml"; Output = "minisql-m18-server-worker.exe" },
  @{ Input = "src\tests\m18_client_worker.ml"; Output = "minisql-m18-client-worker.exe" },
  @{ Input = "src\tests\m19_savepoints.ml"; Output = "minisql-m19-savepoints.exe" },
  @{ Input = "src\tests\m19_sql_savepoints.ml"; Output = "minisql-m19-sql-savepoints.exe" },
  @{ Input = "src\tests\m20_tools.ml"; Output = "minisql-m20-tools.exe" },
  @{ Input = "src\tests\m20_performance_smoke.ml"; Output = "minisql-m20-workload.exe" },
  @{ Input = "src\tests\m20_all_modules.ml"; Output = "minisql-m20-modules.exe" },
  @{ Input = "src\tests\m21_security_catalog.ml"; Output = "minisql-m21-security-catalog.exe" },
  @{ Input = "src\tests\m21_dcl_authorization.ml"; Output = "minisql-m21-dcl-authorization.exe" },
  @{ Input = "src\tests\m21_auth_protocol.ml"; Output = "minisql-m21-auth-protocol.exe" },
  @{ Input = "src\tests\m21_auth_server_worker.ml"; Output = "minisql-m21-auth-server-worker.exe" },
  @{ Input = "src\tests\m21_auth_client_worker.ml"; Output = "minisql-m21-auth-client-worker.exe" },
  @{ Input = "src\tests\m21_security_tools.ml"; Output = "minisql-m21-security-tools.exe" },
  @{ Input = "src\tests\m21_all_modules.ml"; Output = "minisql-m21-modules.exe" },
  @{ Input = "src\tests\m22_prepared_statements.ml"; Output = "minisql-m22-prepared.exe" },
  @{ Input = "src\tests\m23_index_integration.ml"; Output = "minisql-m23-index-integration.exe" },
  @{ Input = "src\tests\m24_schema_evolution.ml"; Output = "minisql-m24-schema-evolution.exe" },
  @{ Input = "src\tests\m25_maintenance.ml"; Output = "minisql-m25-maintenance.exe" },
  @{ Input = "src\tests\m26_offline_migration.ml"; Output = "minisql-m26-migration.exe" },
  @{ Input = "src\tests\m26_all_modules.ml"; Output = "minisql-m26-modules.exe" },
  @{ Input = "src\tests\m27_scheduler_locks.ml"; Output = "minisql-m27-locks.exe" },
  @{ Input = "src\tests\m27_server_worker.ml"; Output = "minisql-m27-server-worker.exe" },
  @{ Input = "src\tests\m27_client_worker.ml"; Output = "minisql-m27-client-worker.exe" },
  @{ Input = "src\tests\m28_secret_handling.ml"; Output = "minisql-m28-secrets.exe" },
  @{ Input = "src\tests\m29_secure_transport.ml"; Output = "minisql-m29-secure-transport.exe" },
  @{ Input = "src\tests\m29_secure_server_worker.ml"; Output = "minisql-m29-secure-server-worker.exe" },
  @{ Input = "src\tests\m29_secure_client_worker.ml"; Output = "minisql-m29-secure-client-worker.exe" },
  @{ Input = "src\tests\m30_audit_grants.ml"; Output = "minisql-m30-audit-grants.exe" },
  @{ Input = "src\tests\m31_archive_pitr.ml"; Output = "minisql-m31-archive-pitr.exe" },
  @{ Input = "src\tests\m31_all_modules.ml"; Output = "minisql-m31-modules.exe" },
  @{ Input = "src\tests\m32_operational_cli.ml"; Output = "minisql-m32-operational.exe" },
  @{ Input = "src\tests\m33_sql_batch.ml"; Output = "minisql-m33-sql-batch.exe" },
  @{ Input = "src\tests\m34_catalog_introspection.ml"; Output = "minisql-m34-catalog-introspection.exe" },
  @{ Input = "src\tests\m35_scalar_expressions.ml"; Output = "minisql-m35-scalar-expressions.exe" },
  @{ Input = "src\tests\m36_predicates_fetch.ml"; Output = "minisql-m36-predicates-fetch.exe" },
  @{ Input = "src\tests\m37_outer_joins.ml"; Output = "minisql-m37-outer-joins.exe" },
  @{ Input = "src\tests\m37_all_modules.ml"; Output = "minisql-m37-modules.exe" },
  @{ Input = "src\tests\m38_returning.ml"; Output = "minisql-m38-returning.exe" },
  @{ Input = "src\tests\m39_insert_select.ml"; Output = "minisql-m39-insert-select.exe" },
  @{ Input = "src\tests\m40_conflict_nothing.ml"; Output = "minisql-m40-conflict-nothing.exe" },
  @{ Input = "src\tests\m41_upsert.ml"; Output = "minisql-m41-upsert.exe" },
  @{ Input = "src\tests\m42_truncate.ml"; Output = "minisql-m42-truncate.exe" },
  @{ Input = "src\tests\m42_all_modules.ml"; Output = "minisql-m42-modules.exe" },
  @{ Input = "src\tests\m43_auto_increment_decimal.ml"; Output = "minisql-m43-auto-increment-decimal.exe" },
  @{ Input = "src\tests\m43_views_subqueries.ml"; Output = "minisql-m43-views.exe" },
  @{ Input = "src\tests\m44_cte_windows.ml"; Output = "minisql-m44-cte-windows.exe" },
  @{ Input = "src\tests\m45_sequences_generated_triggers.ml"; Output = "minisql-m45-schema-extensions.exe" },
  @{ Input = "src\tests\m46_optimizer_executor_v2.ml"; Output = "minisql-m46-optimizer-v2.exe" },
  @{ Input = "src\tests\m47_all_modules.ml"; Output = "minisql-m47-modules.exe" },
  @{ Input = "src\tests\m48_hot_replication.ml"; Output = "minisql-m48-hot-replication.exe" },
  @{ Input = "src\tests\m49_hardening.ml"; Output = "minisql-m49-hardening.exe" },
  @{ Input = "src\tests\m50_release_contract.ml"; Output = "minisql-m50-release-contract.exe" },
  @{ Input = "src\tests\m51_capacity_worker.ml"; Output = "minisql-capacity-worker.exe" },
  @{ Input = "src\tests\m50_all_modules.ml"; Output = "minisql-m50-modules.exe" },
  @{ Input = "src\tests\m73_tls_policy.ml"; Output = "minisql-m73-tls-policy.exe" },
  @{ Input = "src\tests\m73_schannel_abi.ml"; Output = "minisql-m73-schannel-abi.exe" },
  @{ Input = "src\tests\m73_tls_server_worker.ml"; Output = "minisql-m73-tls-server-worker.exe" },
  @{ Input = "src\tests\m73_tls_client_worker.ml"; Output = "minisql-m73-tls-client-worker.exe" },
  @{ Input = "src\tests\m74_workbench.ml"; Output = "minisql-m74-workbench.exe" },
  @{ Input = "src\tests\m74_workbench_network_worker.ml"; Output = "minisql-m74-workbench-network-worker.exe" }
)

if ($AppsOnly) {
  $Targets = @($Targets | Select-Object -First 6)
}

if ($NativeTarget -eq "linux-x64") {
  # Win32 GUI, direct Schannel ABI probes, raw Win32 file aggregation, and the
  # ExitProcess crash helper intentionally remain Windows-only. All database,
  # CLI, storage, protocol, concurrency, security, and portable TLS targets are
  # still compiled for Linux.
  $WindowsOnlyOutputs = @(
    "minisql-admin.exe",
    "minisql-m0-modules.exe", "minisql-m5-modules.exe", "minisql-m10-modules.exe",
    "minisql-m15-modules.exe", "minisql-m20-modules.exe", "minisql-m21-modules.exe",
    "minisql-m26-modules.exe", "minisql-m31-modules.exe", "minisql-m37-modules.exe",
    "minisql-m42-modules.exe", "minisql-m47-modules.exe", "minisql-m50-modules.exe",
    "minisql-m7-crash-worker.exe", "minisql-m28-secrets.exe",
    "minisql-m73-schannel-abi.exe", "minisql-m74-workbench.exe",
    "minisql-m74-workbench-network-worker.exe"
  )
  $Targets = @($Targets | Where-Object { $WindowsOnlyOutputs -notcontains $_.Output })
}

foreach ($BuildTarget in $Targets) {
  $OutputName = $BuildTarget.Output
  if ($NativeTarget -eq "linux-x64") { $OutputName = $OutputName -replace '\.exe$', '' }
  Invoke-Compile $CompilerPath (Join-Path $Root $BuildTarget.Input) (Join-Path $BinDir $OutputName) $NativeTarget
}

if ($AppsOnly) {
  Write-Host "MiniSQL 1.0.0 application build: SUCCESS"
} else {
  Write-Host "MiniSQL 1.0.0 full build: SUCCESS"
}
