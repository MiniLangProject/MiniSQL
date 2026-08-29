# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0; see LICENSE for details.

param(
  [int]$Port = 7432,
  [string]$BinaryDirectory = "$PSScriptRoot\..\..\build\bin"
)

$ErrorActionPreference = "Stop"
$client = (Resolve-Path -LiteralPath (Join-Path $BinaryDirectory "minisql.exe")).Path
& $client --query $Port "SHUTDOWN"
exit $LASTEXITCODE
