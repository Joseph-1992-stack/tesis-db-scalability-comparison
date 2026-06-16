param(
  [string]$BaseDir = "C:\tesis-db\results\benchbase",
  [string]$Db = "postgres",
  [string]$Workload = "templated",
  [string]$ScenarioConfigRoot = "C:\tesis-db\benchbase-config\postgres\templated\scenarios",
  [switch]$IncludeErrors
)

$ErrorActionPreference = "Stop"

function Get-AnyProp {
  param(
    $Obj,
    [string[]]$Names
  )
  if ($null -eq $Obj) { return $null }

  foreach ($n in $Names) {
    if ($Obj.PSObject.Properties.Name -contains $n) {
      return $Obj.$n
    }
  }
  return $null
}

function To-DoubleOrNull {
  param($Value)
  if ($null -eq $Value) { return $null }
  try {
    return [double]$Value
  } catch {
    return $null
  }
}

function Convert-ToMs {
  param($Microseconds)
  $v = To-DoubleOrNull $Microseconds
  if ($null -eq $v) { return $null }
  if ($v -lt 0) { return $null }
  return [math]::Round($v / 1000.0, 6)
}

function Convert-ToSeconds {
  param(
    $Value,
    [string]$Unit
  )

  $v = To-DoubleOrNull $Value
  if ($null -eq $v) { return $null }
  if ($v -lt 0) { return $null }

  switch ($Unit) {
    "ns" { return [math]::Round($v / 1e9, 6) }
    "us" { return [math]::Round($v / 1e6, 6) }
    "ms" { return [math]::Round($v / 1e3, 6) }
    "s"  { return [math]::Round($v, 6) }
    default { return $null }
  }
}

function Get-StdDev {
  param([double[]]$Values)

  if ($null -eq $Values) { return $null }
  if ($Values.Count -lt 2) { return 0.0 }

  $mean = ($Values | Measure-Object -Average).Average
  $sumSq = 0.0

  foreach ($x in $Values) {
    $sumSq += [math]::Pow(($x - $mean), 2)
  }

  # desviación estándar muestral
  return [math]::Round([math]::Sqrt($sumSq / ($Values.Count - 1)), 6)
}

function Parse-ScenarioName {
  param([string]$ScenarioName)

  # Esperado: E1_DS100k_T10, E6_DS500k_T100, E9_DS1M_T100
  if ($ScenarioName -match '^(E\d+)_DS(100k|500k|1M)_T(\d+)$') {
    $scenarioId = $matches[1]
    $scaleRaw   = $matches[2]
    $terminals  = [int]$matches[3]

    $scale = switch ($scaleRaw.ToUpper()) {
      "100K" { "ds100k" }
      "500K" { "ds500k" }
      "1M"   { "ds1m" }
      default { $scaleRaw.ToLower() }
    }

    return [pscustomobject]@{
      scenario_id = $scenarioId
      scale       = $scale
      scale_label = $scaleRaw
      terminals   = $terminals
    }
  }

  return [pscustomobject]@{
    scenario_id = $null
    scale       = $null
    scale_label = $null
    terminals   = $null
  }
}

function Read-ScenarioConfig {
  param(
    [string]$ScenarioConfigRoot,
    [string]$ScenarioName
  )

  $cfgPath = Join-Path (Join-Path $ScenarioConfigRoot $ScenarioName) "config.xml"
  if (!(Test-Path $cfgPath)) {
    return [pscustomobject]@{
      config_path            = $null
      warmup_sec             = $null
      benchmark_time_sec     = $null
      total_configured_sec   = $null
      config_terminals       = $null
    }
  }

  try {
    [xml]$xml = Get-Content $cfgPath -Raw

    $terminals = $xml.parameters.terminals
    $warmup    = $xml.parameters.works.work.warmup
    $time      = $xml.parameters.works.work.time

    $terminalsNum = if ($terminals) { [int]$terminals } else { $null }
    $warmupNum    = if ($warmup)    { [int]$warmup }    else { $null }
    $timeNum      = if ($time)      { [int]$time }      else { $null }

    $totalConfigured = $null
    if ($null -ne $warmupNum -and $null -ne $timeNum) {
      $totalConfigured = $warmupNum + $timeNum
    }

    return [pscustomobject]@{
      config_path            = $cfgPath
      warmup_sec             = $warmupNum
      benchmark_time_sec     = $timeNum
      total_configured_sec   = $totalConfigured
      config_terminals       = $terminalsNum
    }
  } catch {
    return [pscustomobject]@{
      config_path            = $cfgPath
      warmup_sec             = $null
      benchmark_time_sec     = $null
      total_configured_sec   = $null
      config_terminals       = $null
    }
  }
}

function Extract-FromSummary {
  param([string]$SummaryPath)

  $j = Get-Content $SummaryPath -Raw | ConvertFrom-Json

  $finalState = Get-AnyProp $j @("Final State")

  $measured = Get-AnyProp $j @(
    "Measured Requests",
    "Measured Transactions"
  )

  $throughput = Get-AnyProp $j @(
    "Throughput (requests/second)",
    "Throughput (txns/s)",
    "Throughput (transactions/second)"
  )

  $latDist = Get-AnyProp $j @("Latency Distribution")

  $latAvgUs = if ($latDist) {
    Get-AnyProp $latDist @(
      "Average Latency (microseconds)",
      "Average Latency (us)"
    )
  } else { $null }

  $latStddevUs = if ($latDist) {
    Get-AnyProp $latDist @(
      "Standard Deviation Latency (microseconds)",
      "StdDev Latency (microseconds)",
      "Standard Deviation (microseconds)",
      "Latency Standard Deviation (microseconds)"
    )
  } else { $null }

  $latP95Us = if ($latDist) {
    Get-AnyProp $latDist @(
      "95th Percentile Latency (microseconds)",
      "95th Percentile (microseconds)"
    )
  } else { $null }

  $latMaxUs = if ($latDist) {
    Get-AnyProp $latDist @(
      "Maximum Latency (microseconds)",
      "Max Latency (microseconds)"
    )
  } else { $null }

  # Tiempo total real de ejecución (si BenchBase lo reporta)
  $elapsedNs = Get-AnyProp $j @("Elapsed Time (nanoseconds)")
  $elapsedMs = Get-AnyProp $j @("Elapsed Time (milliseconds)")
  $elapsedS  = Get-AnyProp $j @("Elapsed Time (seconds)")

  $elapsedSec = $null
  if ($null -ne $elapsedNs) {
    $elapsedSec = Convert-ToSeconds -Value $elapsedNs -Unit "ns"
  } elseif ($null -ne $elapsedMs) {
    $elapsedSec = Convert-ToSeconds -Value $elapsedMs -Unit "ms"
  } elseif ($null -ne $elapsedS) {
    $elapsedSec = Convert-ToSeconds -Value $elapsedS -Unit "s"
  }

  return [pscustomobject]@{
    final_state             = $finalState
    measured_requests       = To-DoubleOrNull $measured
    tps                     = To-DoubleOrNull $throughput
    latency_avg_ms          = Convert-ToMs $latAvgUs
    latency_stddev_ms       = Convert-ToMs $latStddevUs
    latency_p95_ms          = Convert-ToMs $latP95Us
    latency_max_ms          = Convert-ToMs $latMaxUs
    elapsed_measured_sec    = $elapsedSec
  }
}

# ------------------------------------------------------------
# Inicio
# ------------------------------------------------------------
$root = Join-Path (Join-Path $BaseDir $Db) $Workload
if (!(Test-Path $root)) { throw "No existe: $root" }

$rowsOk = @()
$rowsErr = @()

# Ahora el root contiene carpetas por escenario (E1..., E2..., etc.)
$scenarioDirs = Get-ChildItem -Path $root -Directory | Sort-Object Name

foreach ($sd in $scenarioDirs) {
  $scenarioName = $sd.Name
  $scenarioMeta = Parse-ScenarioName $scenarioName
  $scenarioCfg  = Read-ScenarioConfig -ScenarioConfigRoot $ScenarioConfigRoot -ScenarioName $scenarioName

  $runDirs = Get-ChildItem -Path $sd.FullName -Directory -Filter "run_*" -ErrorAction SilentlyContinue | Sort-Object Name

  foreach ($rd in $runDirs) {
    $summaryFiles = Get-ChildItem -Path $rd.FullName -File -Filter "*.summary.json" -ErrorAction SilentlyContinue

    foreach ($sf in $summaryFiles) {
      $m = Extract-FromSummary $sf.FullName

      $row = [pscustomobject]@{
        db                    = $Db
        workload              = $Workload
        scenario              = $scenarioName
        scenario_id           = $scenarioMeta.scenario_id
        scale                 = $scenarioMeta.scale
        scale_label           = $scenarioMeta.scale_label
        terminals             = $scenarioMeta.terminals
        config_terminals      = $scenarioCfg.config_terminals
        warmup_sec            = $scenarioCfg.warmup_sec
        benchmark_time_sec    = $scenarioCfg.benchmark_time_sec
        total_configured_sec  = $scenarioCfg.total_configured_sec
        run                   = $rd.Name
        file                  = $sf.FullName
        final_state           = $m.final_state
        measured_requests     = $m.measured_requests
        tps                   = $m.tps
        latency_avg_ms        = $m.latency_avg_ms
        latency_stddev_ms     = $m.latency_stddev_ms
        latency_p95_ms        = $m.latency_p95_ms
        latency_max_ms        = $m.latency_max_ms
        elapsed_measured_sec  = $m.elapsed_measured_sec
      }

      $successStates = @("COMPLETED","EXIT")

      if (($successStates -contains $m.final_state) -and ($null -ne $m.measured_requests) -and ([double]$m.measured_requests -gt 0)) {
        $rowsOk += $row
      } else {
        $rowsErr += $row
        if ($IncludeErrors) { $rowsOk += $row }
      }
    }
  }
}

# ------------------------------------------------------------
# Export 1: corridas válidas
# ------------------------------------------------------------
$outDir = Join-Path $BaseDir $Db
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$outRuns = Join-Path $outDir "$Workload.by_run.csv"
$outErr  = Join-Path $outDir "$Workload.errors.csv"

$rowsOkUnique  = $rowsOk  | Sort-Object scenario, run, file -Unique
$rowsErrUnique = $rowsErr | Sort-Object scenario, run, file -Unique

$rowsOkUnique  | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outRuns
$rowsErrUnique | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outErr

Write-Host "OK: $outRuns"
Write-Host "OK: $outErr"

# ------------------------------------------------------------
# Export 2: agregación por escenario
# ------------------------------------------------------------
$scenarioSummary = @()

$groupedScenarios = $rowsOkUnique | Group-Object scenario | Sort-Object Name

foreach ($g in $groupedScenarios) {
  $items = $g.Group

  $tpsVals          = @($items | Where-Object { $null -ne $_.tps }                  | ForEach-Object { [double]$_.tps })
  $latAvgVals       = @($items | Where-Object { $null -ne $_.latency_avg_ms }       | ForEach-Object { [double]$_.latency_avg_ms })
  $latStdVals       = @($items | Where-Object { $null -ne $_.latency_stddev_ms }    | ForEach-Object { [double]$_.latency_stddev_ms })
  $latP95Vals       = @($items | Where-Object { $null -ne $_.latency_p95_ms }       | ForEach-Object { [double]$_.latency_p95_ms })
  $latMaxVals       = @($items | Where-Object { $null -ne $_.latency_max_ms }       | ForEach-Object { [double]$_.latency_max_ms })
  $elapsedVals      = @($items | Where-Object { $null -ne $_.elapsed_measured_sec } | ForEach-Object { [double]$_.elapsed_measured_sec })
  $reqVals          = @($items | Where-Object { $null -ne $_.measured_requests }    | ForEach-Object { [double]$_.measured_requests })

  $first = $items[0]

  $scenarioSummary += [pscustomobject]@{
    db                         = $first.db
    workload                   = $first.workload
    scenario                   = $first.scenario
    scenario_id                = $first.scenario_id
    scale                      = $first.scale
    scale_label                = $first.scale_label
    terminals                  = $first.terminals
    warmup_sec                 = $first.warmup_sec
    benchmark_time_sec         = $first.benchmark_time_sec
    total_configured_sec       = $first.total_configured_sec
    valid_runs                 = $items.Count

    tps_mean                   = if ($tpsVals.Count     -gt 0) { [math]::Round(($tpsVals     | Measure-Object -Average).Average, 6) } else { $null }
    tps_stddev                 = if ($tpsVals.Count     -gt 0) { Get-StdDev $tpsVals } else { $null }

    latency_avg_ms_mean        = if ($latAvgVals.Count  -gt 0) { [math]::Round(($latAvgVals  | Measure-Object -Average).Average, 6) } else { $null }
    latency_avg_ms_stddev      = if ($latAvgVals.Count  -gt 0) { Get-StdDev $latAvgVals } else { $null }

    latency_stddev_ms_mean     = if ($latStdVals.Count  -gt 0) { [math]::Round(($latStdVals  | Measure-Object -Average).Average, 6) } else { $null }
    latency_p95_ms_mean        = if ($latP95Vals.Count  -gt 0) { [math]::Round(($latP95Vals  | Measure-Object -Average).Average, 6) } else { $null }
    latency_max_ms_mean        = if ($latMaxVals.Count  -gt 0) { [math]::Round(($latMaxVals  | Measure-Object -Average).Average, 6) } else { $null }

    measured_requests_mean     = if ($reqVals.Count     -gt 0) { [math]::Round(($reqVals     | Measure-Object -Average).Average, 6) } else { $null }
    elapsed_measured_sec_mean  = if ($elapsedVals.Count -gt 0) { [math]::Round(($elapsedVals | Measure-Object -Average).Average, 6) } else { $null }
  }
}

$outScenario = Join-Path $outDir "$Workload.by_scenario.csv"
$scenarioSummary | Sort-Object scenario_id | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outScenario
Write-Host "OK: $outScenario"

# ------------------------------------------------------------
# Export 3: agregación por escala
# ------------------------------------------------------------
$scaleSummary = @()

$groupedScales = $rowsOkUnique | Group-Object scale | Sort-Object Name

foreach ($g in $groupedScales) {
  $items = $g.Group

  $tpsVals     = @($items | Where-Object { $null -ne $_.tps }            | ForEach-Object { [double]$_.tps })
  $latAvgVals  = @($items | Where-Object { $null -ne $_.latency_avg_ms } | ForEach-Object { [double]$_.latency_avg_ms })
  $latP95Vals  = @($items | Where-Object { $null -ne $_.latency_p95_ms } | ForEach-Object { [double]$_.latency_p95_ms })
  $elapsedVals = @($items | Where-Object { $null -ne $_.elapsed_measured_sec } | ForEach-Object { [double]$_.elapsed_measured_sec })

  $scaleSummary += [pscustomobject]@{
    db                        = $Db
    workload                  = $Workload
    scale                     = $g.Name
    valid_runs                = $items.Count
    tps_mean                  = if ($tpsVals.Count     -gt 0) { [math]::Round(($tpsVals     | Measure-Object -Average).Average, 6) } else { $null }
    tps_stddev                = if ($tpsVals.Count     -gt 0) { Get-StdDev $tpsVals } else { $null }
    latency_avg_ms_mean       = if ($latAvgVals.Count  -gt 0) { [math]::Round(($latAvgVals  | Measure-Object -Average).Average, 6) } else { $null }
    latency_p95_ms_mean       = if ($latP95Vals.Count  -gt 0) { [math]::Round(($latP95Vals  | Measure-Object -Average).Average, 6) } else { $null }
    elapsed_measured_sec_mean = if ($elapsedVals.Count -gt 0) { [math]::Round(($elapsedVals | Measure-Object -Average).Average, 6) } else { $null }
  }
}

$outScale = Join-Path $outDir "$Workload.by_scale.csv"
$scaleSummary | Sort-Object scale | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outScale
Write-Host "OK: $outScale"

# ------------------------------------------------------------
# Export 4: archivos separados por escala (sin mezclar grupos)
# ------------------------------------------------------------
$scales = @("ds100k","ds500k","ds1m")
foreach ($s in $scales) {
  $subset = $rowsOkUnique | Where-Object { $_.scale -eq $s }
  if ($subset.Count -gt 0) {
    $outPerScale = Join-Path $outDir ("{0}.{1}.by_run.csv" -f $Workload, $s)
    $subset | Sort-Object scenario_id, run | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $outPerScale
    Write-Host "OK: $outPerScale"
  }
}
