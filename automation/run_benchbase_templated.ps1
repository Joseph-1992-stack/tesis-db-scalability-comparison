#requires -Version 5.1
param(
  [ValidateSet("postgres","mariadb")]
  [string]$Db = "postgres",

  [int]$Runs = 5,

  [string[]]$OnlyScenarios = @(),

  [string]$DockerNet = "",

  [string]$Root = "C:\tesis-db"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DockerNet)) {
  $DockerNet = switch ($Db) {
    "postgres" { "postgres_tesisnet" }
    "mariadb"  { "mariadb_tesisnet" }
  }
}

$ScenariosRoot = Join-Path $Root "benchbase-config\$Db\templated\scenarios"
$Queries       = Join-Path $Root "benchbase-config\$Db\templated\queries.xml"
$BBRuntime     = Join-Path $Root "benchbase\runtime\benchbase-$Db"
$ResultsRoot   = Join-Path $Root "results\benchbase\$Db\templated"

function Run-OneScenario {
  param(
    [string]$ScenarioName,
    [string]$ConfigPath
  )

  $scenarioDir = Join-Path $ResultsRoot $ScenarioName
  New-Item -ItemType Directory -Force -Path $scenarioDir | Out-Null

  for ($i = 1; $i -le $Runs; $i++) {
    $runName = ("run_{0:D3}" -f $i)
    $runDir  = Join-Path $scenarioDir $runName

    New-Item -ItemType Directory -Force -Path $runDir | Out-Null

    Write-Host "==> $Db | $ScenarioName | $runName | out=$runDir" -ForegroundColor Cyan

    docker run --rm -t `
      --network $DockerNet `
      -v "${BBRuntime}:/bb" `
      -v "${ConfigPath}:/cfg/config.xml" `
      -v "${Queries}:/cfg/queries.xml" `
      -v "${runDir}:/out" `
      -w "/bb" `
      eclipse-temurin:23-jdk `
      sh -lc 'java -cp "benchbase.jar:lib/*" com.oltpbenchmark.DBWorkload -b templated -c /cfg/config.xml --execute=true -d /out 2>&1 | tee /out/benchbase.log'

    $hasSummary = Get-ChildItem -Path $runDir -Filter "*.summary.json" -ErrorAction SilentlyContinue

    if (-not $hasSummary) {
      Write-Warning "No se generó *.summary.json en $runDir. Revisar benchbase.log"
    }
  }
}

if (!(Test-Path $ScenariosRoot)) {
  throw "No existe ScenariosRoot: $ScenariosRoot"
}

if (!(Test-Path $Queries)) {
  throw "No existe Queries: $Queries"
}

if (!(Test-Path $BBRuntime)) {
  throw "No existe BBRuntime: $BBRuntime"
}

New-Item -ItemType Directory -Force -Path $ResultsRoot | Out-Null

$scenarioDirs = New-Object System.Collections.Generic.List[object]

Get-ChildItem $ScenariosRoot -Directory |
  Sort-Object Name |
  ForEach-Object {
    if ($OnlyScenarios.Count -eq 0 -or $OnlyScenarios -contains $_.Name) {
      [void]$scenarioDirs.Add($_)
    }
  }

if ($scenarioDirs.Count -eq 0) {
  throw "No se encontraron escenarios para ejecutar."
}

foreach ($sd in $scenarioDirs) {
  $scenarioName = $sd.Name
  $configPath = Join-Path $sd.FullName "config.xml"

  if (!(Test-Path $configPath)) {
    throw "Falta config.xml en: $($sd.FullName)"
  }

  Run-OneScenario -ScenarioName $scenarioName -ConfigPath $configPath
}

Write-Host "`nDONE. Resultados en: $ResultsRoot" -ForegroundColor Green
