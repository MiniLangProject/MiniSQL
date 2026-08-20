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
Builds, packages and verifies the deterministic MiniSQL Windows-x64 release.
.PARAMETER Compiler
Path to the MiniLang Python compiler; build-time discovery is used when omitted.
.PARAMETER Python
Python executable used for compilation and deterministic archive generation.
.PARAMETER Output
Optional release archive path; defaults to build/release for version 1.0.0.
#>
param(
  [string]$Compiler = $env:MINILANG_COMPILER,
  [string]$Python = "python",
  [string]$Output = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$BuildScript = Join-Path $Root "build.ps1"
$BinDir = Join-Path $Root "build\bin"
$ReleaseDir = Join-Path $Root "build\release"

if (-not $Output) {
  $Output = Join-Path $ReleaseDir "MiniSQL-1.0.0-windows-x64.zip"
}

& $BuildScript -Compiler $Compiler -Python $Python -Clean -AppsOnly
if ($LASTEXITCODE -ne 0) {
  throw "MiniSQL application build failed with exit code $LASTEXITCODE."
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Output) | Out-Null
& $Python (Join-Path $Root "tools\release\build_release.py") build `
  --project $Root `
  --bin-dir $BinDir `
  --output $Output
if ($LASTEXITCODE -ne 0) {
  throw "MiniSQL release packaging failed with exit code $LASTEXITCODE."
}

Write-Host "MiniSQL 1.0.0 release: SUCCESS"
Write-Host "Archive: $Output"
Write-Host "Checksum: $Output.sha256"
