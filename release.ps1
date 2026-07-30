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
