# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
[CmdletBinding()]
param([string]$Python = "python", [switch]$UnitOnly)
$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryRoot = (Resolve-Path (Join-Path $projectRoot "..\..")).Path
$outputRoot = Join-Path $repositoryRoot "build\python-connector"
$virtualEnvironment = Join-Path $outputRoot "venv"
$pythonExe = Join-Path $virtualEnvironment "Scripts\python.exe"
if (-not (Test-Path -LiteralPath $pythonExe)) {
  New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
  & $Python -m venv $virtualEnvironment
  if ($LASTEXITCODE -ne 0) { throw "Could not create the Python connector test environment." }
}
& $pythonExe -B -m pip install --disable-pip-version-check --quiet "cryptography>=41"
if ($LASTEXITCODE -ne 0) { throw "Could not install the Python connector security dependency." }

# Runs Python with the source package on sys.path without creating editable-install metadata.
function Invoke-ConnectorPython([string[]]$Arguments) {
  $previousPythonPath = $env:PYTHONPATH
  $env:PYTHONPATH = $projectRoot
  try {
    & $pythonExe -B @Arguments | Out-Host
    $pythonExitCode = $LASTEXITCODE
  }
  finally { $env:PYTHONPATH = $previousPythonPath }
  return $pythonExitCode
}

$unitExit = Invoke-ConnectorPython @("-m", "unittest", "discover", "-s", (Join-Path $projectRoot "tests"), "-p", "test_*.py", "-v")
if ($unitExit -ne 0) { throw "Python connector unit tests failed." }
if ($UnitOnly) { return }

$server = Join-Path $repositoryRoot "build\bin\minisqld.exe"
if (-not (Test-Path -LiteralPath $server)) { throw "Build MiniSQL applications before running live Python tests." }
$databaseName = "python_integration_$([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())"
$initOutput = & $server --init $outputRoot $databaseName 4096
$initOutput | Out-Host
if ($LASTEXITCODE -ne 0) { throw "Could not initialize the Python integration database." }
$createdLine = $initOutput | Where-Object { $_ -like "MiniSQL database created:*" } | Select-Object -First 1
if (-not $createdLine) { throw "MiniSQL did not report the created database path." }
$databasePath = $createdLine.Substring("MiniSQL database created: ".Length).Trim()
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start(); $port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port; $listener.Stop()

# Waits until the disposable MiniSQL server accepts a loopback TCP connection.
function Wait-MiniSqlServer([int]$TargetPort) {
  $deadline = [DateTime]::UtcNow.AddSeconds(10)
  do {
    Start-Sleep -Milliseconds 100
    $probe = [Net.Sockets.TcpClient]::new()
    try { $probe.Connect("127.0.0.1", $TargetPort); $ready = $true } catch { $ready = $false } finally { $probe.Dispose() }
  } while (-not $ready -and [DateTime]::UtcNow -lt $deadline)
  if (-not $ready) { throw "MiniSQL Python integration server did not become ready." }
}

$integration = Join-Path $projectRoot "tests\integration.py"
$process = Start-Process -FilePath $server -ArgumentList @("--serve", $databasePath, "$port", "4") -PassThru -WindowStyle Hidden
try {
  Wait-MiniSqlServer $port
  $trustedExit = Invoke-ConnectorPython @($integration, "minisql://127.0.0.1:$port/$databaseName", "prepare-auth")
  if ($trustedExit -ne 0) { throw "Trusted Python connector integration tests failed." }
} finally { if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force } }

$process = Start-Process -FilePath $server -ArgumentList @("--serve-authenticated", $databasePath, "$port", "4") -PassThru -WindowStyle Hidden
try {
  Wait-MiniSqlServer $port
  $authExit = Invoke-ConnectorPython @($integration, "minisql://admin:python-test-password@127.0.0.1:$port/$databaseName")
  if ($authExit -ne 0) { throw "Authenticated Python connector integration tests failed." }
} finally { if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force } }

$pfxPath = Join-Path $outputRoot "python-tls-server.pfx"
$pfxPassword = "MiniSQL-Python-PFX-Test!"
$previousPfxPassword = $env:MINISQL_TLS_PFX_PASSWORD
$rsa = [Security.Cryptography.RSA]::Create(2048)
$request = [Security.Cryptography.X509Certificates.CertificateRequest]::new(
  "CN=localhost", $rsa, [Security.Cryptography.HashAlgorithmName]::SHA256,
  [Security.Cryptography.RSASignaturePadding]::Pkcs1)
$san = [Security.Cryptography.X509Certificates.SubjectAlternativeNameBuilder]::new()
$san.AddDnsName("localhost"); $san.AddIpAddress([Net.IPAddress]::Loopback)
$request.CertificateExtensions.Add($san.Build())
$certificate = $request.CreateSelfSigned([DateTimeOffset]::UtcNow.AddMinutes(-5), [DateTimeOffset]::UtcNow.AddDays(1))
[IO.File]::WriteAllBytes($pfxPath, $certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $pfxPassword))
$sha256 = [Security.Cryptography.SHA256]::Create()
$pin = ([BitConverter]::ToString($sha256.ComputeHash($certificate.RawData))).Replace("-", "").ToLowerInvariant()
$env:MINISQL_TLS_PFX_PASSWORD = $pfxPassword
$process = Start-Process -FilePath $server -ArgumentList @("--serve-tls", $databasePath, "127.0.0.1", "$port", "4", "pfx:$pfxPath") -PassThru -WindowStyle Hidden
try {
  Wait-MiniSqlServer $port
  $tlsDsn = "minisql://admin:python-test-password@127.0.0.1:$port/$databaseName`?tls=true&server_name=localhost&trust_server_certificate=true&pin_sha256=$pin"
  $tlsExit = Invoke-ConnectorPython @($integration, $tlsDsn)
  if ($tlsExit -ne 0) { throw "TLS Python connector integration tests failed." }
} finally {
  if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force }
  $env:MINISQL_TLS_PFX_PASSWORD = $previousPfxPassword
  $certificate.Dispose(); $rsa.Dispose(); $sha256.Dispose()
}
