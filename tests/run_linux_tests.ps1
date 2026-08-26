# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0; see the LICENSE file for details.

<#
.SYNOPSIS
Builds and runs the portable MiniSQL acceptance smoke suite on Linux x64.
.DESCRIPTION
The script cross-compiles public applications and representative storage,
network, security, scheduler, workload, and release-contract tests, then runs
the ELF images through WSL. Test databases live only below a process-specific
directory in /tmp.
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$Compiler,
  [string]$Python = "python",
  [switch]$KeepArtifacts
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SourceRoot = Join-Path $Root "src"
$BuildScript = Join-Path $Root "build.ps1"
$CompilerPath = (Resolve-Path -LiteralPath $Compiler).Path
$BinDir = Join-Path $Root "build\linux-acceptance"
$LinuxDataRoot = "/tmp/minisql-linux-acceptance-$PID"

if ($null -eq (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  throw "Linux acceptance requires WSL. Run this script on Linux directly or install WSL."
}

# Finds std/ beside a Python compiler or above a native build/ compiler.
function Resolve-MiniLangLibraryRoot([string]$CompilerPath) {
  $candidate = Split-Path -Parent $CompilerPath
  for ($depth = 0; $depth -lt 4 -and -not [string]::IsNullOrWhiteSpace($candidate); $depth++) {
    if (Test-Path -LiteralPath (Join-Path $candidate "std") -PathType Container) { return $candidate }
    $parent = Split-Path -Parent $candidate
    if ($parent -eq $candidate) { break }
    $candidate = $parent
  }
  return ""
}

$CompilerRoot = Resolve-MiniLangLibraryRoot $CompilerPath

# Compiles one MiniLang source into a Linux ELF using either compiler frontend.
function Invoke-Compiler([string]$SourcePath, [string]$OutputPath) {
  $arguments = @($SourcePath, $OutputPath, "-I", $SourceRoot)
  if (-not [string]::IsNullOrWhiteSpace($CompilerRoot)) {
    $arguments += @("-I", $CompilerRoot)
  }
  if ([System.IO.Path]::GetExtension($CompilerPath) -ine ".py") {
    $arguments += "--object-pipeline"
  }
  $arguments += @("--target", "linux-x64", "--keep-going", "--max-errors", "100")
  if ([System.IO.Path]::GetExtension($CompilerPath) -ieq ".py") {
    & $Python $CompilerPath @arguments
  } else {
    & $CompilerPath @arguments
  }
  if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
    throw "Linux compilation failed for $SourcePath."
  }
}

# Converts a host path to the absolute path understood by WSL.
function Convert-ToWslPath([string]$Path) {
  $converted = @(& wsl.exe wslpath -a -u ($Path.Replace('\', '/')) 2>&1)
  if ($LASTEXITCODE -ne 0 -or $converted.Count -eq 0) {
    throw "Could not convert path for WSL: $Path"
  }
  return [string]$converted[0]
}

# Executes one ELF with a bounded timeout and requires a zero exit status.
function Invoke-LinuxCase([string]$Name, [string]$Image, [string[]]$Arguments) {
  $linuxImage = Convert-ToWslPath $Image
  & wsl.exe chmod +x $linuxImage
  if ($LASTEXITCODE -ne 0) { throw "Could not mark $Name executable." }
  Write-Host "Running $Name"
  & wsl.exe timeout 180s $linuxImage @Arguments
  if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE." }
}

# Requires one exact success marker from a Linux client worker invocation.
function Invoke-LinuxClientCase([string]$Name, [string]$Image, [string[]]$Arguments, [string]$Marker) {
  $linuxImage = Convert-ToWslPath $Image
  $output = @(& wsl.exe -- $linuxImage @Arguments 2>&1)
  if ($LASTEXITCODE -ne 0 -or $output -notcontains $Marker) {
    throw "$Name failed: $($output -join [Environment]::NewLine)"
  }
}

# Runs two waves of four simultaneous plain-protocol clients. The second wave
# is essential: it verifies that completed connection jobs are reaped and that
# their pthread-backed workers remain able to accept and execute later jobs.
function Invoke-LinuxConcurrentIntegration([string]$ServerWorker, [string]$ClientWorker) {
  $networkRoot = "$LinuxDataRoot/m27-network"
  $readyPath = "$networkRoot/server.ready"
  $port = 17434
  $serverOut = Join-Path $BinDir "m27-server.stdout.log"
  $serverErr = Join-Path $BinDir "m27-server.stderr.log"
  $serverLinux = Convert-ToWslPath $ServerWorker
  $clientLinux = Convert-ToWslPath $ClientWorker

  & wsl.exe mkdir -p -- $LinuxDataRoot
  if ($LASTEXITCODE -ne 0) { throw "Could not restore the Linux concurrent test root." }
  $serverProcess = Start-Process -FilePath "wsl.exe" -ArgumentList @(
    "--", $serverLinux, $networkRoot, $port, $readyPath, 4, 32
  ) -RedirectStandardOutput $serverOut -RedirectStandardError $serverErr -WindowStyle Hidden -PassThru
  try {
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    $ready = $false
    while (-not $serverProcess.HasExited -and [DateTime]::UtcNow -lt $deadline) {
      & wsl.exe test -f $readyPath
      if ($LASTEXITCODE -eq 0) { $ready = $true; break }
      Start-Sleep -Milliseconds 50
      $serverProcess.Refresh()
    }
    if (-not $ready) { throw "Linux concurrent server did not publish readiness." }

    foreach ($wave in @(@(3, 4, 5, 6), @(7, 8, 9, 10))) {
      $clients = @()
      foreach ($clientId in $wave) {
        $stdout = Join-Path $BinDir ("m27-client-" + $clientId + ".stdout.log")
        $stderr = Join-Path $BinDir ("m27-client-" + $clientId + ".stderr.log")
        $process = Start-Process -FilePath "wsl.exe" -ArgumentList @(
          "--", $clientLinux, $port, $clientId
        ) -RedirectStandardOutput $stdout -RedirectStandardError $stderr -WindowStyle Hidden -PassThru
        $clients += [pscustomobject]@{ Id = $clientId; Process = $process; Stdout = $stdout; Stderr = $stderr }
      }
      foreach ($client in $clients) {
        if (-not $client.Process.WaitForExit(30000)) {
          Stop-Process -Id $client.Process.Id -Force
          throw "Linux concurrent client $($client.Id) timed out."
        }
        $client.Process.WaitForExit()
        $stdout = (Get-Content -Raw -LiteralPath $client.Stdout).Trim()
        $stderr = Get-Content -Raw -LiteralPath $client.Stderr
        $expected = "MiniSQL M27 concurrent client worker: SUCCESS id=$($client.Id)"
        if ($client.Process.ExitCode -ne 0 -or $stdout -ne $expected -or -not [string]::IsNullOrWhiteSpace($stderr)) {
          throw "Linux concurrent client $($client.Id) failed: $stdout $stderr"
        }
      }
    }

    if (-not $serverProcess.WaitForExit(30000)) { throw "Linux concurrent server did not drain both client waves." }
    $serverProcess.WaitForExit()
    $serverLog = Get-Content -Raw -LiteralPath $serverOut
    $serverError = Get-Content -Raw -LiteralPath $serverErr
    if ($serverProcess.ExitCode -ne 0 -or $serverLog -notmatch "MiniSQL M27 concurrent server worker: SUCCESS requests=32" -or -not [string]::IsNullOrWhiteSpace($serverError)) {
      throw "Linux concurrent server failed: $serverLog $serverError"
    }
    Write-Host "MiniSQL M27 Linux concurrent two-wave integration: SUCCESS"
  } finally {
    if (-not $serverProcess.HasExited) {
      Stop-Process -Id $serverProcess.Id -Force
      $serverProcess.WaitForExit()
    }
  }
}

# Generates a localhost PEM identity and validates trust, pin, hostname, and
# authenticated MiniSQL traffic through the Linux OpenSSL provider.
function Invoke-LinuxTlsIntegration([string]$ServerApplication, [string]$ServerWorker, [string]$ClientWorker) {
  $tlsRoot = "$LinuxDataRoot/m73"
  $readyPath = "$tlsRoot/native-tls.ready"
  $certificatePath = "$tlsRoot/server.crt"
  $privateKeyPath = "$tlsRoot/server.key"
  $port = 17433
  $serverOut = Join-Path $BinDir "m73-server.stdout.log"
  $serverErr = Join-Path $BinDir "m73-server.stderr.log"

  # Both TLS workers are compiled immediately before this function. Restore
  # the volatile WSL /tmp parent after those potentially long host compiles.
  & wsl.exe mkdir -p -- $LinuxDataRoot
  if ($LASTEXITCODE -ne 0) { throw "Could not restore the Linux TLS test root: $LinuxDataRoot" }
  Invoke-LinuxCase "M73 database initialization" $ServerApplication @("--init", $tlsRoot, "tls_transport", "4096")
  $databasePaths = @(& wsl.exe find $tlsRoot -maxdepth 1 -type d -name "db_*" 2>&1)
  if ($LASTEXITCODE -ne 0 -or $databasePaths.Count -ne 1) { throw "M73 database path discovery failed." }
  $databasePath = [string]$databasePaths[0]

  & wsl.exe -- openssl req -x509 -newkey rsa:2048 -sha256 -nodes -keyout $privateKeyPath -out $certificatePath -days 1 -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" -addext "extendedKeyUsage=serverAuth" 2>$null
  if ($LASTEXITCODE -ne 0) { throw "OpenSSL could not create the M73 test identity." }
  $fingerprintOutput = @(& wsl.exe -- openssl x509 -in $certificatePath -noout -fingerprint -sha256 2>&1)
  if ($LASTEXITCODE -ne 0 -or $fingerprintOutput.Count -ne 1 -or $fingerprintOutput[0] -notmatch '=') { throw "OpenSSL fingerprint calculation failed." }
  $pin = (($fingerprintOutput[0] -split '=', 2)[1]).Replace(':', '').ToLowerInvariant()
  $wrongPin = "00" + $pin.Substring(2)
  if ($wrongPin -eq $pin) { $wrongPin = "01" + $pin.Substring(2) }

  $serverLinux = Convert-ToWslPath $ServerWorker
  # Start-Process flattens ArgumentList into a Windows command line. Preserve
  # the documented pipe separator as one quoted WSL argument instead of
  # allowing WSL's command-line bridge to interpret it as a shell pipeline.
  $identityArgument = '"pem:' + $certificatePath + '|' + $privateKeyPath + '"'
  $serverProcess = Start-Process -FilePath "wsl.exe" -ArgumentList @(
    "--", $serverLinux, $databasePath, "127.0.0.1", $port, $readyPath,
    $identityArgument, 5
  ) -RedirectStandardOutput $serverOut -RedirectStandardError $serverErr -WindowStyle Hidden -PassThru
  try {
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    $ready = $false
    while (-not $serverProcess.HasExited -and [DateTime]::UtcNow -lt $deadline) {
      & wsl.exe test -f $readyPath
      if ($LASTEXITCODE -eq 0) { $ready = $true; break }
      Start-Sleep -Milliseconds 50
      $serverProcess.Refresh()
    }
    if (-not $ready) { throw "Linux TLS server did not publish readiness." }

    Invoke-LinuxClientCase "M73 system trust rejection" $ClientWorker @("127.0.0.1", "$port", "localhost", $pin, "system-reject") "MiniSQL M73 TLS client worker: SUCCESS rejected=system-reject"
    Invoke-LinuxClientCase "M73 pin rejection" $ClientWorker @("127.0.0.1", "$port", "localhost", $wrongPin, "pin-reject") "MiniSQL M73 TLS client worker: SUCCESS rejected=pin-reject"
    Invoke-LinuxClientCase "M73 hostname rejection" $ClientWorker @("127.0.0.1", "$port", "wrong.invalid", $pin, "hostname-reject") "MiniSQL M73 TLS client worker: SUCCESS rejected=hostname-reject"
    Invoke-LinuxClientCase "M73 pinned TLS session" $ClientWorker @("127.0.0.1", "$port", "localhost", $pin, "pin") "MiniSQL M73 TLS client worker: SUCCESS pinned"

    if (-not $serverProcess.WaitForExit(30000)) { throw "Linux TLS server did not drain its request budget." }
    $serverProcess.WaitForExit()
    $serverLog = Get-Content -Raw -LiteralPath $serverOut
    $serverError = Get-Content -Raw -LiteralPath $serverErr
    if ($serverProcess.ExitCode -ne 0 -or $serverLog -notmatch "MiniSQL M73 TLS server worker: SUCCESS requests=5" -or -not [string]::IsNullOrWhiteSpace($serverError)) {
      throw "Linux TLS server failed: $serverLog $serverError"
    }
    Write-Host "MiniSQL M73 Linux native TLS integration: SUCCESS"
  } finally {
    if (-not $serverProcess.HasExited) {
      Stop-Process -Id $serverProcess.Id -Force
      $serverProcess.WaitForExit()
    }
  }
}

if (Test-Path -LiteralPath $BinDir) {
  Remove-Item -Recurse -Force -LiteralPath $BinDir
}
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# Public CLI coverage uses the same supported build entry point as operators.
& $BuildScript -Compiler $CompilerPath -Python $Python -Target linux-x64 -AppsOnly -Clean
if ($LASTEXITCODE -ne 0) { throw "Linux application build failed." }

$Cases = @(
  [pscustomobject]@{ Name = "M3 random-access files"; Source = "m3_file.ml"; Output = "m3-file"; Args = @("$LinuxDataRoot/m3-file.bin") },
  [pscustomobject]@{ Name = "M18 loopback protocol"; Source = "m18_protocol.ml"; Output = "m18-protocol"; Args = @("17432") },
  [pscustomobject]@{ Name = "M20 deterministic workload"; Source = "m20_performance_smoke.ml"; Output = "m20-workload"; Args = @("$LinuxDataRoot/m20") },
  [pscustomobject]@{ Name = "M21 authentication"; Source = "m21_auth_protocol.ml"; Output = "m21-auth"; Args = @("$LinuxDataRoot/m21") },
  [pscustomobject]@{ Name = "M27 parallel scheduler"; Source = "m27_scheduler_locks.ml"; Output = "m27-scheduler"; Args = @("$LinuxDataRoot/m27") },
  [pscustomobject]@{ Name = "M29 secure transport"; Source = "m29_secure_transport.ml"; Output = "m29-secure"; Args = @() },
  [pscustomobject]@{ Name = "M50 release contract"; Source = "m50_release_contract.ml"; Output = "m50-release"; Args = @("$LinuxDataRoot/m50") }
)

try {
  & wsl.exe rm -rf -- $LinuxDataRoot
  if ($LASTEXITCODE -ne 0) { throw "Could not prepare the Linux test directory." }
  & wsl.exe mkdir -p -- $LinuxDataRoot
  if ($LASTEXITCODE -ne 0) { throw "Could not create the Linux test directory." }

  $ApplicationDir = Join-Path $Root "build\bin-linux"
  foreach ($application in @("minisqld", "minisql", "minisql-check", "minisql-backup", "minisql-migrate")) {
    Invoke-LinuxCase "$application --version" (Join-Path $ApplicationDir $application) @("--version")
  }

  foreach ($case in $Cases) {
    $source = Join-Path $SourceRoot ("tests\" + $case.Source)
    $image = Join-Path $BinDir $case.Output
    Invoke-Compiler $source $image
    # WSL may shut its utility VM down while the Windows-hosted compiler is
    # busy. Because /tmp is volatile across that shutdown, recreate the owned
    # acceptance root immediately before starting each ELF image.
    & wsl.exe mkdir -p -- $LinuxDataRoot
    if ($LASTEXITCODE -ne 0) { throw "Could not restore the Linux test root before $($case.Name): $LinuxDataRoot" }
    Invoke-LinuxCase $case.Name $image $case.Args
  }

  $concurrentServerWorker = Join-Path $BinDir "m27-server"
  $concurrentClientWorker = Join-Path $BinDir "m27-client"
  Invoke-Compiler (Join-Path $SourceRoot "tests\m27_server_worker.ml") $concurrentServerWorker
  Invoke-Compiler (Join-Path $SourceRoot "tests\m27_client_worker.ml") $concurrentClientWorker
  Invoke-LinuxConcurrentIntegration $concurrentServerWorker $concurrentClientWorker

  $tlsServerWorker = Join-Path $BinDir "m73-tls-server"
  $tlsClientWorker = Join-Path $BinDir "m73-tls-client"
  Invoke-Compiler (Join-Path $SourceRoot "tests\m73_tls_server_worker.ml") $tlsServerWorker
  Invoke-Compiler (Join-Path $SourceRoot "tests\m73_tls_client_worker.ml") $tlsClientWorker
  Invoke-LinuxTlsIntegration (Join-Path $ApplicationDir "minisqld") $tlsServerWorker $tlsClientWorker

  Write-Host "MiniSQL 1.0.0 Linux x64 acceptance: SUCCESS"
} finally {
  if (-not $KeepArtifacts) {
    & wsl.exe rm -rf -- $LinuxDataRoot
  }
}
