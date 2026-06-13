#requires -Version 5.1
param(
  [string]$ProjectDir  = "C:\tesis-db\orchestrator\mariadb",
  [string]$ComposeFile = "docker-compose.yml",
  [string]$DockerNet   = "mariadb_tesisnet",

  [ValidateSet("ds100k","ds500k","ds1m")]
  [string]$Scale = "ds100k",

  [int]$Runs = 5,

  [switch]$Recreate,
  [switch]$RunLoad,
  [switch]$RunBench,
  [switch]$RunParse
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Compose {
  param([string[]]$ComposeArgs)

  Push-Location $ProjectDir
  try {
    docker compose -f (Join-Path $ProjectDir $ComposeFile) @ComposeArgs
  } finally {
    Pop-Location
  }
}

function Wait-Healthy {
  param(
    [string[]]$Containers,
    [int]$TimeoutSec = 240
  )

  $start = Get-Date

  while ($true) {
    $allOk = $true

    foreach ($c in $Containers) {
      $status = docker inspect $c --format "{{.State.Health.Status}}" 2>$null
      if ($status -ne "healthy") {
        $allOk = $false
      }
    }

    if ($allOk) { return }

    if ((Get-Date) - $start -gt (New-TimeSpan -Seconds $TimeoutSec)) {
      foreach ($c in $Containers) {
        Write-Host "`n--- Logs: $c (last 120) ---" -ForegroundColor Yellow
        docker logs $c --tail 120
      }

      throw "Timeout esperando HEALTHY en: $($Containers -join ', ')"
    }

    Start-Sleep -Seconds 2
  }
}

function Exec-MariaDbFileOn {
  param(
    [string]$Container,
    [string]$SqlPath,
    [string]$DbUser = "root",
    [string]$DbPassword = "rootpass"
  )

  if (!(Test-Path $SqlPath)) {
    throw "No existe el SQL: $SqlPath"
  }

  Write-Host "`n==> Ejecutando en ${Container} :: $SqlPath" -ForegroundColor Cyan

  $dockerArgs = @(
    "exec",
    "-i",
    $Container,
    "mariadb",
    "-u$DbUser",
    "-p$DbPassword"
  )

  Get-Content -Path $SqlPath -Raw | docker @dockerArgs

  if ($LASTEXITCODE -ne 0) {
    throw "FallÃ³ la ejecuciÃ³n SQL en $Container :: $SqlPath"
  }
}

function Exec-MariaDbOn {
  param(
    [string]$Container,
    [string]$Sql,
    [string]$DbUser = "root",
    [string]$DbPassword = "rootpass"
  )

  $dockerArgs = @(
    "exec",
    "-i",
    $Container,
    "mariadb",
    "-u$DbUser",
    "-p$DbPassword",
    "-e",
    $Sql
  )

  docker @dockerArgs

  if ($LASTEXITCODE -ne 0) {
    throw "FallÃ³ la consulta en $Container :: $Sql"
  }
}

$root = "C:\tesis-db"
$initDir = Join-Path $ProjectDir "init"

# Loader MariaDB para carga controlada de datasets experimentales
$loadScript  = Join-Path $root "automation\dataset-loader\mariadb_load_tpcc.ps1"
$benchScript = Join-Path $root "automation\run_benchbase_templated.ps1"
$parseScript = Join-Path $root "automation\parse_bechbase.ps1"

if ($Recreate) {
  Write-Host "Bajando stack MariaDB (volÃºmenes incluidos)..." -ForegroundColor Yellow
  Invoke-Compose @("down","-v")
}

Write-Host "Levantando stack MariaDB 11.4 + Spider..." -ForegroundColor Green
Invoke-Compose @("up","-d")

$containers = @("mariadb-node1","mariadb-node2","mariadb-item","mariadb-coord")
Write-Host "Esperando HEALTHY: $($containers -join ', ')" -ForegroundColor Green
Wait-Healthy -Containers $containers -TimeoutSec 240

Write-Host "`n==> Versiones detectadas" -ForegroundColor Green
Exec-MariaDbOn -Container "mariadb-coord" -Sql "SELECT VERSION();"
Exec-MariaDbOn -Container "mariadb-coord" -Sql "SHOW ENGINES;"

Write-Host "`n==> Ejecutando SQL MariaDB + Spider" -ForegroundColor Green

Exec-MariaDbFileOn -Container "mariadb-item"  -SqlPath (Join-Path $initDir "01_create_remote_item.sql")
Exec-MariaDbFileOn -Container "mariadb-node1" -SqlPath (Join-Path $initDir "02_create_databases_nodes.sql")
Exec-MariaDbFileOn -Container "mariadb-node2" -SqlPath (Join-Path $initDir "02_create_databases_nodes.sql")

Exec-MariaDbFileOn -Container "mariadb-coord" -SqlPath (Join-Path $initDir "03_install_spider.sql")
Exec-MariaDbFileOn -Container "mariadb-coord" -SqlPath (Join-Path $initDir "04_create_spider_servers.sql")
Exec-MariaDbFileOn -Container "mariadb-coord" -SqlPath (Join-Path $initDir "05_create_tpcc_spider_tables.sql")

$idx = Join-Path $initDir "06_tpcc_secondary_indexes.sql"
if (Test-Path $idx) {
  Exec-MariaDbFileOn -Container "mariadb-coord" -SqlPath $idx
} else {
  Write-Host "Aviso: no existe 06_tpcc_secondary_indexes.sql (omitiendo Ã­ndices secundarios)." -ForegroundColor Yellow
}

Write-Host "`n==> Validaciones rÃ¡pidas MariaDB + Spider" -ForegroundColor Green

Exec-MariaDbOn -Container "mariadb-coord" -Sql "USE tesisdb; SHOW TABLES;"
Exec-MariaDbOn -Container "mariadb-coord" -Sql "USE tesisdb; SELECT COUNT(*) AS item_rows_spider FROM item;"
Exec-MariaDbOn -Container "mariadb-coord" -Sql "USE tesisdb; SELECT COUNT(*) AS warehouse_rows_spider FROM warehouse;"
Exec-MariaDbOn -Container "mariadb-coord" -Sql "USE tesisdb; SHOW CREATE TABLE item\G"

if ($RunLoad) {
  if (!(Test-Path $loadScript)) {
    throw "No existe loader MariaDB: $loadScript"
  }

  Write-Host "`n==> CARGA DATASET MariaDB (Scale=$Scale)" -ForegroundColor Green
  & $loadScript -Scale $Scale
}

if ($RunBench) {
  if (!(Test-Path $benchScript)) {
    throw "No existe bench script MariaDB: $benchScript"
  }

  $scenarioGroup = switch ($Scale) {
    "ds100k" { @("E1_DS100k_T10","E2_DS100k_T50","E3_DS100k_T100") }
    "ds500k" { @("E4_DS500k_T10","E5_DS500k_T50","E6_DS500k_T100") }
    "ds1m"   { @("E7_DS1M_T10","E8_DS1M_T50","E9_DS1M_T100") }
  }

  Write-Host "`n==> EJECUTANDO BenchBase MariaDB TEMPLATED (Runs=$Runs | Scale=$Scale)" -ForegroundColor Green
  Write-Host "Escenarios: $($scenarioGroup -join ', ')" -ForegroundColor Cyan

  & $benchScript -Runs $Runs -DockerNet $DockerNet -OnlyScenarios $scenarioGroup
}

if ($RunParse) {
  if (!(Test-Path $parseScript)) {
    throw "No existe parse script: $parseScript"
  }

  Write-Host "`n==> PARSE resultados BenchBase MariaDB" -ForegroundColor Green

  & $parseScript `
    -Db "mariadb" `
    -Workload "templated" `
    -ScenarioConfigRoot "C:\tesis-db\benchbase-config\mariadb\templated\scenarios"
}

Write-Host "`nâœ… MASTER MariaDB finalizado." -ForegroundColor Green
