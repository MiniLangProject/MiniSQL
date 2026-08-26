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
Runs the single supported MiniSQL cumulative acceptance entry point.
.PARAMETER Compiler
Path to the MiniLang Python compiler forwarded to the internal runner.
.PARAMETER Python
Python executable used to run the acceptance orchestrator.
.PARAMETER Target
Selects the existing complete Windows suite or the portable Linux x64 suite.
.PARAMETER StaticOnly
Runs repository and source-contract checks without compiling native targets.
.PARAMETER KeepArtifacts
Preserves intermediate acceptance files for diagnosis.
.PARAMETER VerboseOutput
Streams detailed compiler and test process output.
#>
param(
  [string]$Compiler = $env:MINILANG_COMPILER,
  [string]$Python = "python",
  [ValidateSet("windows-x64", "linux-x64")]
  [string]$Target = "windows-x64",
  [switch]$StaticOnly,
  [switch]$KeepArtifacts,
  [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($Target -eq "linux-x64" -and -not $StaticOnly) {
  if ([string]::IsNullOrWhiteSpace($Compiler)) {
    $Compiler = Join-Path $Root "..\MiniLangCompilerPy\mlc_win64.py"
  }
  $LinuxRunner = Join-Path $Root "tests\run_linux_tests.ps1"
  & $LinuxRunner -Compiler $Compiler -Python $Python -KeepArtifacts:$KeepArtifacts
  exit $LASTEXITCODE
}

# test.ps1 is the only user-facing test entry point. Once the user approves this
# launcher, remove the Windows download marker from the remaining project tree so
# no internal runner or generated executable causes another security prompt.
Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
  Unblock-File -ErrorAction SilentlyContinue

# Acceptance never depends on hidden placeholder files surviving ZIP extraction.
foreach ($Directory in @("build", "data", "logs", "tmp")) {
  New-Item -ItemType Directory -Force -Path (Join-Path $Root $Directory) | Out-Null
}

$Runner = Join-Path $Root "tests\run_all_tests.py"
if (-not (Test-Path -LiteralPath $Runner -PathType Leaf)) {
  throw "Internal MiniSQL acceptance runner is missing: $Runner"
}

$PythonArguments = @($Runner)
if (-not [string]::IsNullOrWhiteSpace($Compiler)) {
  $PythonArguments += @("--compiler", $Compiler)
}
if ($StaticOnly) { $PythonArguments += "--static-only" }
if ($KeepArtifacts) { $PythonArguments += "--keep-artifacts" }
if ($VerboseOutput) { $PythonArguments += "--verbose" }

& $Python @PythonArguments
exit $LASTEXITCODE
