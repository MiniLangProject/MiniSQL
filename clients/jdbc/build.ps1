# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
[CmdletBinding()]
param([string]$OutputRoot = "")
$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryRoot = (Resolve-Path (Join-Path $projectRoot "..\..")).Path
if (-not $OutputRoot) { $OutputRoot = Join-Path $repositoryRoot "build\jdbc" }
$classes = Join-Path $OutputRoot "classes"
$resolvedOutputRoot = [IO.Path]::GetFullPath($OutputRoot).TrimEnd([IO.Path]::DirectorySeparatorChar)
$resolvedClasses = [IO.Path]::GetFullPath($classes)
if (-not $resolvedClasses.StartsWith($resolvedOutputRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
  throw "Refusing to clean a classes directory outside the selected output root."
}
if (Test-Path -LiteralPath $resolvedClasses) { Remove-Item -LiteralPath $resolvedClasses -Recurse -Force }
New-Item -ItemType Directory -Force -Path $classes | Out-Null

$javac = Get-Command javac -ErrorAction SilentlyContinue
if (-not $javac -and $env:JAVA_HOME) { $javac = Get-Item (Join-Path $env:JAVA_HOME "bin\javac.exe") -ErrorAction SilentlyContinue }
if (-not $javac) { $javac = Get-Item "C:\Program Files\JetBrains\PyCharm 2025.3.3\jbr\bin\javac.exe" -ErrorAction SilentlyContinue }
if (-not $javac) { throw "Java 11 or newer is required (javac was not found)." }
$javacPath = if ($javac.Source) { $javac.Source } else { $javac.FullName }

$sources = Get-ChildItem (Join-Path $projectRoot "src\main\java") -Recurse -Filter *.java | ForEach-Object FullName
& $javacPath --release 11 -encoding UTF-8 -d $classes $sources
if ($LASTEXITCODE -ne 0) { throw "javac failed with exit code $LASTEXITCODE" }
Copy-Item (Join-Path $projectRoot "src\main\resources\*") $classes -Recurse -Force

$jar = Join-Path $OutputRoot "minisql-jdbc-1.0.0.jar"
$zip = Join-Path $OutputRoot "minisql-jdbc-1.0.0.zip"
Compress-Archive -Path (Join-Path $classes "*") -DestinationPath $zip -Force
Move-Item -LiteralPath $zip -Destination $jar -Force
Write-Host "MiniSQL JDBC driver: $jar"
