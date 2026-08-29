# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.
[CmdletBinding()]
param([switch]$UnitOnly)
$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repositoryRoot = (Resolve-Path (Join-Path $projectRoot "..\..")).Path
$buildScript = Join-Path $projectRoot "build.ps1"
& $buildScript
$outputRoot = Join-Path $repositoryRoot "build\jdbc"
$classes = Join-Path $outputRoot "classes"
$testClasses = Join-Path $outputRoot "test-classes"
if (Test-Path -LiteralPath $testClasses) { Remove-Item -LiteralPath $testClasses -Recurse -Force }
New-Item -ItemType Directory -Force -Path $testClasses | Out-Null

$javac = Get-Command javac -ErrorAction SilentlyContinue
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $javac) { $javac = Get-Item "C:\Program Files\JetBrains\PyCharm 2025.3.3\jbr\bin\javac.exe" }
if (-not $java) { $java = Get-Item "C:\Program Files\JetBrains\PyCharm 2025.3.3\jbr\bin\java.exe" }
$javacPath = if ($javac.Source) { $javac.Source } else { $javac.FullName }
$javaPath = if ($java.Source) { $java.Source } else { $java.FullName }
$tests = Get-ChildItem (Join-Path $projectRoot "src\test\java") -Recurse -Filter *.java | ForEach-Object FullName
& $javacPath --release 11 -encoding UTF-8 -cp $classes -d $testClasses $tests
if ($LASTEXITCODE -ne 0) { throw "JDBC test compilation failed." }
$testClasspath = $classes + [IO.Path]::PathSeparator + $testClasses
& $javaPath -ea -cp $testClasspath org.minilang.minisql.jdbc.DriverTest
if ($LASTEXITCODE -ne 0) { throw "JDBC unit tests failed." }
if ($UnitOnly) { return }

$server = Join-Path $repositoryRoot "build\bin\minisqld.exe"
if (-not (Test-Path $server)) { throw "Build MiniSQL applications before running the JDBC integration test." }
$databaseName = "jdbc_integration_$([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())"
$initOutput = & $server --init $outputRoot $databaseName 4096
$initOutput | Out-Host
if ($LASTEXITCODE -ne 0) { throw "Could not initialize the JDBC integration database." }
$createdLine = $initOutput | Where-Object { $_ -like "MiniSQL database created:*" } | Select-Object -First 1
if (-not $createdLine) { throw "MiniSQL did not report the created database path." }
$databasePath = $createdLine.Substring("MiniSQL database created: ".Length).Trim()
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$listener.Start(); $port = ([Net.IPEndPoint]$listener.LocalEndpoint).Port; $listener.Stop()

# Waits until the disposable server accepts a loopback TCP connection.
function Wait-MiniSqlServer([int]$TargetPort) {
  $deadline = [DateTime]::UtcNow.AddSeconds(10)
  do {
    Start-Sleep -Milliseconds 100
    $probe = [Net.Sockets.TcpClient]::new()
    try { $probe.Connect("127.0.0.1", $TargetPort); $ready = $true } catch { $ready = $false } finally { $probe.Dispose() }
  } while (-not $ready -and [DateTime]::UtcNow -lt $deadline)
  if (-not $ready) { throw "MiniSQL integration server did not become ready." }
}

# Stops one disposable server and waits until Windows has released its process,
# database lock and listener before the same database and port are reused.
function Stop-MiniSqlServer([Diagnostics.Process]$ServerProcess) {
  if (-not $ServerProcess.HasExited) { Stop-Process -Id $ServerProcess.Id -Force }
  Wait-Process -Id $ServerProcess.Id -ErrorAction SilentlyContinue
}

$process = Start-Process -FilePath $server -ArgumentList @("--serve", $databasePath, "$port", "4") -PassThru -WindowStyle Hidden
try {
  Wait-MiniSqlServer $port
  & $javaPath -ea -cp $testClasspath org.minilang.minisql.jdbc.IntegrationTest "jdbc:minisql://127.0.0.1:$port/$databaseName" prepare-auth
  if ($LASTEXITCODE -ne 0) { throw "JDBC integration tests failed." }
} finally {
  Stop-MiniSqlServer $process
}

$process = Start-Process -FilePath $server -ArgumentList @("--serve-authenticated", $databasePath, "$port", "4") -PassThru -WindowStyle Hidden
try {
  Wait-MiniSqlServer $port
  & $javaPath -ea -cp $testClasspath org.minilang.minisql.jdbc.IntegrationTest "jdbc:minisql://127.0.0.1:$port/$databaseName`?user=admin&password=jdbc-test-password"
  if ($LASTEXITCODE -ne 0) { throw "JDBC authenticated integration tests failed." }
} finally {
  Stop-MiniSqlServer $process
}

# Build a disposable self-signed certificate and verify the JDBC TLS/pinning path.
$pfxPath = Join-Path $outputRoot "jdbc-tls-server.pfx"
$pfxPassword = "MiniSQL-JDBC-PFX-Test!"
$previousPfxPassword = $env:MINISQL_TLS_PFX_PASSWORD
$rsa = [Security.Cryptography.RSA]::Create(2048)
$subject = [Security.Cryptography.X509Certificates.X500DistinguishedName]::new("CN=localhost")
$request = [Security.Cryptography.X509Certificates.CertificateRequest]::new(
  $subject, $rsa, [Security.Cryptography.HashAlgorithmName]::SHA256,
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
  $tlsUrl = "jdbc:minisql://127.0.0.1:$port/$databaseName`?tls=true&serverName=localhost&trustServerCertificate=true&pinSha256=$pin&user=admin&password=jdbc-test-password"
  & $javaPath -ea -cp $testClasspath org.minilang.minisql.jdbc.IntegrationTest $tlsUrl
  if ($LASTEXITCODE -ne 0) { throw "JDBC TLS integration tests failed." }
} finally {
  Stop-MiniSqlServer $process
  $env:MINISQL_TLS_PFX_PASSWORD = $previousPfxPassword
  $certificate.Dispose(); $rsa.Dispose(); $sha256.Dispose()
}
