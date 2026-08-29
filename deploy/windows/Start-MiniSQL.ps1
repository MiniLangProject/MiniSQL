# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0; see LICENSE for details.

param(
  [Parameter(Mandatory = $true)][string]$DatabasePath,
  [Parameter(Mandatory = $true)][string]$ConfigPath,
  [string]$BinaryDirectory = "$PSScriptRoot\..\..\build\bin"
)

$ErrorActionPreference = "Stop"
$server = (Resolve-Path -LiteralPath (Join-Path $BinaryDirectory "minisqld.exe")).Path
$database = (Resolve-Path -LiteralPath $DatabasePath).Path
$config = (Resolve-Path -LiteralPath $ConfigPath).Path
& $server --serve-config $database $config
exit $LASTEXITCODE
