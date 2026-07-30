param(
  [string]$Compiler = $env:MINILANG_COMPILER,
  [string]$Python = "python",
  [switch]$StaticOnly,
  [switch]$KeepArtifacts,
  [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

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
