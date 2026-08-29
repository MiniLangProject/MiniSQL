# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see LICENSE for details.

<#
.SYNOPSIS
Profiles the native concurrent indexed-read workload on Windows.
.DESCRIPTION
Starts an isolated MiniSQL server, runs the native MiniLang load generator, and
records server CPU, process I/O, host context switches, TCP segments, protocol
bytes, memory, handles, and throughput for each requested concurrency level.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Server,
  [Parameter(Mandatory = $true)][string]$Benchmark,
  [Parameter(Mandatory = $true)][string]$Database,
  [Parameter(Mandatory = $true)][string]$Config,
  [int]$Port = 7551,
  [string]$Clients = "8,16,32",
  [int]$Operations = 1000,
  [int]$Trials = 3,
  [Parameter(Mandatory = $true)][string]$Output
)

$ErrorActionPreference = "Stop"

# Captures cumulative raw counters immediately around one benchmark process.
function Get-ProfileSnapshot([Diagnostics.Process]$Process) {
  $Process.Refresh()
  $raw = Get-CimInstance Win32_PerfRawData_PerfProc_Process |
    Where-Object { [int]$_.IDProcess -eq $Process.Id } |
    Select-Object -First 1
  if (-not $raw) { throw "MiniSQL performance counter instance disappeared." }
  $system = Get-CimInstance Win32_PerfRawData_PerfOS_System
  $tcp = Get-CimInstance Win32_PerfRawData_Tcpip_TCPv4
  return [pscustomobject]@{
    CpuMs = $Process.TotalProcessorTime.TotalMilliseconds
    IoReadBytes = [uint64]$raw.IOReadBytesPersec
    IoReadOperations = [uint64]$raw.IOReadOperationsPersec
    IoWriteBytes = [uint64]$raw.IOWriteBytesPersec
    IoWriteOperations = [uint64]$raw.IOWriteOperationsPersec
    IoOtherBytes = [uint64]$raw.IOOtherBytesPersec
    ContextSwitches = [uint64]$system.ContextSwitchesPersec
    TcpSent = [uint64]$tcp.SegmentsSentPersec
    TcpReceived = [uint64]$tcp.SegmentsReceivedPersec
  }
}

# Subtracts monotonically increasing Windows raw counters.
function Get-CounterDelta([uint64]$After, [uint64]$Before) {
  if ($After -lt $Before) { return [uint64]0 }
  return $After - $Before
}

# Runs one native trial while sampling peak process resources.
function Invoke-ProfileTrial(
  [Diagnostics.Process]$ServerProcess,
  [string]$BenchmarkPath,
  [int]$BenchmarkPort,
  [int]$ClientCount,
  [int]$OperationCount,
  [int]$TrialIndex
) {
  $before = Get-ProfileSnapshot $ServerProcess
  $startInfo = [Diagnostics.ProcessStartInfo]::new()
  $startInfo.FileName = $BenchmarkPath
  $startInfo.ArgumentList.Add([string]$BenchmarkPort)
  $startInfo.ArgumentList.Add([string]$ClientCount)
  $startInfo.ArgumentList.Add([string]$OperationCount)
  $startInfo.ArgumentList.Add("1")
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.RedirectStandardError = $true
  $client = [Diagnostics.Process]::Start($startInfo)
  $peakWorkingSet = 0L
  $peakPrivate = 0L
  $peakHandles = 0
  while (-not $client.HasExited) {
    $ServerProcess.Refresh()
    if ($ServerProcess.WorkingSet64 -gt $peakWorkingSet) { $peakWorkingSet = $ServerProcess.WorkingSet64 }
    if ($ServerProcess.PrivateMemorySize64 -gt $peakPrivate) { $peakPrivate = $ServerProcess.PrivateMemorySize64 }
    if ($ServerProcess.HandleCount -gt $peakHandles) { $peakHandles = $ServerProcess.HandleCount }
    Start-Sleep -Milliseconds 10
    $client.Refresh()
  }
  $stdout = $client.StandardOutput.ReadToEnd()
  $stderr = $client.StandardError.ReadToEnd()
  $client.WaitForExit()
  if ($client.ExitCode -ne 0) { throw "Native benchmark failed: $stdout $stderr" }
  $after = Get-ProfileSnapshot $ServerProcess
  $match = [regex]::Match(
    $stdout,
    "elapsedMs=(?<elapsed>[0-9.]+) requestsPerSecond=(?<rate>[0-9.]+) protocolSentBytes=(?<sent>[0-9]+) protocolReceivedBytes=(?<received>[0-9]+)"
  )
  if (-not $match.Success) { throw "Native benchmark output was not recognized: $stdout" }
  $culture = [Globalization.CultureInfo]::InvariantCulture
  $elapsedMs = [double]::Parse($match.Groups["elapsed"].Value, $culture)
  $cpuMs = $after.CpuMs - $before.CpuMs
  return [pscustomobject]@{
    Clients = $ClientCount
    Trial = $TrialIndex
    OperationsPerClient = $OperationCount
    ElapsedMs = $elapsedMs
    RequestsPerSecond = [double]::Parse($match.Groups["rate"].Value, $culture)
    ServerCpuMs = $cpuMs
    ServerCpuCores = if ($elapsedMs -gt 0) { $cpuMs / $elapsedMs } else { 0 }
    HostContextSwitches = Get-CounterDelta $after.ContextSwitches $before.ContextSwitches
    StorageReadBytes = Get-CounterDelta $after.IoReadBytes $before.IoReadBytes
    StorageReadOperations = Get-CounterDelta $after.IoReadOperations $before.IoReadOperations
    StorageWriteBytes = Get-CounterDelta $after.IoWriteBytes $before.IoWriteBytes
    StorageWriteOperations = Get-CounterDelta $after.IoWriteOperations $before.IoWriteOperations
    OtherIoBytes = Get-CounterDelta $after.IoOtherBytes $before.IoOtherBytes
    TcpSegmentsSent = Get-CounterDelta $after.TcpSent $before.TcpSent
    TcpSegmentsReceived = Get-CounterDelta $after.TcpReceived $before.TcpReceived
    ProtocolSentBytes = [uint64]$match.Groups["sent"].Value
    ProtocolReceivedBytes = [uint64]$match.Groups["received"].Value
    PeakWorkingSetMiB = [math]::Round($peakWorkingSet / 1MB, 3)
    PeakPrivateMiB = [math]::Round($peakPrivate / 1MB, 3)
    PeakHandles = $peakHandles
  }
}

$levels = @($Clients.Split(",") | ForEach-Object { [int]$_.Trim() })
if ($levels.Count -eq 0 -or $levels.Where({ $_ -lt 1 -or $_ -gt 64 }).Count -ne 0) {
  throw "Clients must contain comma-separated values between 1 and 64."
}
if ($Operations -lt 1 -or $Trials -lt 1) { throw "Operations and Trials must be positive." }

$resolvedServer = (Resolve-Path -LiteralPath $Server).Path
$resolvedBenchmark = (Resolve-Path -LiteralPath $Benchmark).Path
$resolvedDatabase = (Resolve-Path -LiteralPath $Database).Path
$resolvedConfig = (Resolve-Path -LiteralPath $Config).Path
$configDocument = Get-Content -LiteralPath $resolvedConfig -Raw | ConvertFrom-Json
if ([int]$configDocument.server.port -ne $Port) {
  throw "Profiler port $Port does not match server config port $($configDocument.server.port)."
}
$maximumClients = ($levels | Measure-Object -Maximum).Maximum
if ([int]$configDocument.server.maxConnections -lt $maximumClients) {
  throw "Server maxConnections=$($configDocument.server.maxConnections) is below requested clients=$maximumClients."
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Output) | Out-Null
$results = [Collections.Generic.List[object]]::new()
# A fresh server per trial prevents completed connection jobs from one level
# influencing the next level's scheduler and handle state.
foreach ($level in $levels) {
  for ($trial = 0; $trial -lt $Trials; $trial++) {
    $suffix = "{0}-{1}" -f $level, $trial
    $stdoutPath = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $Output) "profile-server-$suffix.stdout.log"))
    $stderrPath = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $Output) "profile-server-$suffix.stderr.log"))
    $serverProcess = Start-Process -FilePath $resolvedServer `
      -ArgumentList @("--serve-config", $resolvedDatabase, $resolvedConfig) `
      -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath `
      -WindowStyle Hidden -PassThru
    try {
      Start-Sleep -Milliseconds 900
      if ($serverProcess.HasExited) {
        throw "MiniSQL server exited during startup: $([IO.File]::ReadAllText($stdoutPath)) $([IO.File]::ReadAllText($stderrPath))"
      }
      # Prime WMI providers and load the index/table pages outside measurement.
      $null = Get-ProfileSnapshot $serverProcess
      & $resolvedBenchmark $Port 1 100 1 | Out-Null
      if ($LASTEXITCODE -ne 0) { throw "Native benchmark warmup failed." }
      $result = Invoke-ProfileTrial $serverProcess $resolvedBenchmark $Port $level $Operations $trial
      $results.Add($result)
      Write-Host ("clients={0} trial={1} rate={2:N1}/s cpuCores={3:N2} contextSwitches={4}" -f `
        $result.Clients, $result.Trial, $result.RequestsPerSecond, $result.ServerCpuCores, $result.HostContextSwitches)
    } finally {
      if (-not $serverProcess.HasExited) { Stop-Process -Id $serverProcess.Id }
      $serverProcess.WaitForExit()
    }
  }
}
$document = [ordered]@{
  CapturedUtc = [DateTime]::UtcNow.ToString("o")
  Computer = $env:COMPUTERNAME
  OperatingSystem = (Get-CimInstance Win32_OperatingSystem).Caption
  Processor = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim()
  LogicalProcessors = [Environment]::ProcessorCount
  Server = $resolvedServer
  Benchmark = $resolvedBenchmark
  Database = $resolvedDatabase
  Config = $resolvedConfig
  Port = $Port
  OperationsPerClient = $Operations
  TrialsPerLevel = $Trials
  Results = $results
}
[IO.File]::WriteAllText([IO.Path]::GetFullPath($Output), ($document | ConvertTo-Json -Depth 5) + "`n", [Text.UTF8Encoding]::new($false))
