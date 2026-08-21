# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.
# Software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

param(
  [Parameter(Mandatory = $true)][string]$ServerWorker,
  [Parameter(Mandatory = $true)][string]$ClientWorker,
  [Parameter(Mandatory = $true)][string]$DatabasePath,
  [Parameter(Mandatory = $true)][string]$WorkDirectory
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path $WorkDirectory | Out-Null
$readyPath = Join-Path $WorkDirectory "native-tls.ready"
$pfxPath = Join-Path $WorkDirectory "native-tls-server.pfx"
$serverOut = Join-Path $WorkDirectory "native-tls-server.stdout.log"
$serverErr = Join-Path $WorkDirectory "native-tls-server.stderr.log"
$pfxPassword = "MiniSQL-M73-PFX-Test!"
$previousPfxPassword = $env:MINISQL_TLS_PFX_PASSWORD
$serverProcess = $null

try {
  $rsa = [System.Security.Cryptography.RSA]::Create(2048)
  $subject = [System.Security.Cryptography.X509Certificates.X500DistinguishedName]::new("CN=localhost")
  $request = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
    $subject,
    $rsa,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256,
    [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
  )
  $san = [System.Security.Cryptography.X509Certificates.SubjectAlternativeNameBuilder]::new()
  $san.AddDnsName("localhost")
  $san.AddIpAddress([System.Net.IPAddress]::Loopback)
  $request.CertificateExtensions.Add($san.Build())
  $oids = [System.Security.Cryptography.OidCollection]::new()
  [void]$oids.Add([System.Security.Cryptography.Oid]::new("1.3.6.1.5.5.7.3.1"))
  $request.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]::new($oids, $false))
  $request.CertificateExtensions.Add([System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new([System.Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature, $false))
  $certificate = $request.CreateSelfSigned([DateTimeOffset]::UtcNow.AddMinutes(-5), [DateTimeOffset]::UtcNow.AddDays(2))
  [System.IO.File]::WriteAllBytes($pfxPath, $certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $pfxPassword))
  $sha256 = [System.Security.Cryptography.SHA256]::Create()
  $pin = ([BitConverter]::ToString($sha256.ComputeHash($certificate.RawData))).Replace("-", "").ToLowerInvariant()
  $wrongPin = "00" + $pin.Substring(2)
  if ($wrongPin -eq $pin) { $wrongPin = "01" + $pin.Substring(2) }

  $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
  $probe.Start()
  $port = ([System.Net.IPEndPoint]$probe.LocalEndpoint).Port
  $probe.Stop()

  $env:MINISQL_TLS_PFX_PASSWORD = $pfxPassword
  $serverProcess = Start-Process -FilePath $ServerWorker -ArgumentList @(
    $DatabasePath, "127.0.0.1", $port, $readyPath, ("pfx:" + $pfxPath), 5
  ) -RedirectStandardOutput $serverOut -RedirectStandardError $serverErr -WindowStyle Hidden -PassThru

  $deadline = [DateTime]::UtcNow.AddSeconds(30)
  while (-not (Test-Path -LiteralPath $readyPath) -and -not $serverProcess.HasExited -and [DateTime]::UtcNow -lt $deadline) {
    Start-Sleep -Milliseconds 50
    $serverProcess.Refresh()
  }
  if (-not (Test-Path -LiteralPath $readyPath)) { throw "native TLS server did not publish readiness" }

  $systemOutput = & $ClientWorker "127.0.0.1" $port "localhost" $pin "system-reject"
  if ($LASTEXITCODE -ne 0 -or $systemOutput -notcontains "MiniSQL M73 TLS client worker: SUCCESS rejected=system-reject") { throw "self-signed certificate unexpectedly passed system trust: $systemOutput" }
  $wrongOutput = & $ClientWorker "127.0.0.1" $port "localhost" $wrongPin "pin-reject"
  if ($LASTEXITCODE -ne 0 -or $wrongOutput -notcontains "MiniSQL M73 TLS client worker: SUCCESS rejected=pin-reject") { throw "wrong certificate pin was not rejected: $wrongOutput" }
  $hostnameOutput = & $ClientWorker "127.0.0.1" $port "wrong.invalid" $pin "hostname-reject"
  if ($LASTEXITCODE -ne 0 -or $hostnameOutput -notcontains "MiniSQL M73 TLS client worker: SUCCESS rejected=hostname-reject") { throw "pinned certificate with wrong hostname was not rejected: $hostnameOutput" }
  $goodOutput = & $ClientWorker "127.0.0.1" $port "localhost" $pin "pin"
  if ($LASTEXITCODE -ne 0 -or $goodOutput -notcontains "MiniSQL M73 TLS client worker: SUCCESS pinned") { throw "valid pinned TLS session failed: $goodOutput" }

  if (-not $serverProcess.WaitForExit(30000)) { throw "native TLS server did not drain its request budget" }
  # Complete asynchronous redirection and populate ExitCode on Windows PowerShell.
  $serverProcess.WaitForExit()
  $serverProcess.Refresh()
  $serverLog = Get-Content -Raw -LiteralPath $serverOut
  $serverError = Get-Content -Raw -LiteralPath $serverErr
  if ($null -ne $serverProcess.ExitCode -and $serverProcess.ExitCode -ne 0) { throw "native TLS server failed with exit code $($serverProcess.ExitCode): $serverLog $serverError" }
  if ($serverLog -notmatch "MiniSQL M73 TLS server worker: SUCCESS requests=5" -or -not [string]::IsNullOrWhiteSpace($serverError)) { throw "native TLS server did not complete cleanly: $serverLog $serverError" }
  if ($serverLog -notmatch "cipher=TLS_AES_256_GCM_SHA384 group=X25519") { throw "native TLS negotiation log did not prove the required profile" }
  Write-Output "MiniSQL M73 native TLS integration: SUCCESS"
} finally {
  if ($null -ne $serverProcess -and -not $serverProcess.HasExited) {
    Stop-Process -Id $serverProcess.Id -Force
    $serverProcess.WaitForExit()
  }
  $env:MINISQL_TLS_PFX_PASSWORD = $previousPfxPassword
}
