#requires -Version 5.1
param(
  [string]$ProjectDir  = "C:\tesis-db\orchestrator\postgres",
  [string]$ComposeFile = "docker-compose.yml",
  [string]$DockerNet   = "postgres_tesisnet",

  # Carga de datos controlada por escala (consume pg_load_tpcc.ps1 + tpcc_params.ps1)
  [ValidateSet("ds100k","ds500k","ds1m")]
  [string]$Scale = "ds100k",

  # BenchBase
  [int]$Runs = 5,

  # switches para controlar etapas
  [switch]$Recreate,      # docker compose down -v antes de levantar
  [switch]$RunLoad,       # ejecuta pg_load_tpcc.ps1
  [switch]$RunBench,      # ejecuta run_benchbase_templated.ps1
  [switch]$RunParse       # ejecuta parse_bechbase.ps1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------
# Helpers: compose + health
# ---------------------------
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
    [int]$TimeoutSec = 180
  )
  $start = Get-Date
  while ($true) {
    $allOk = $true
    foreach ($c in $Containers) {
      $status = docker inspect $c --format "{{.State.Health.Status}}" 2>$null
      if ($status -ne "healthy") { $allOk = $false }
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

function Exec-PsqlFileOn {
  param(
    [string]$Container,
    [string]$Db,
    [string]$User,
    [string]$SqlPath
  )
  if (!(Test-Path $SqlPath)) { throw "No existe el SQL: $SqlPath" }

  Write-Host "`n==> Ejecutando en ${Container}/${Db} :: $SqlPath" -ForegroundColor Cyan

  $sqlText = Get-Content -Path $SqlPath -Raw
  $sqlText | docker exec -i $Container psql -U $User -d $Db -v ON_ERROR_STOP=1 -f /dev/stdin | Out-Host
}

function Exec-PsqlOn {
  param(
    [string]$Container,
    [string]$Db,
    [string]$User,
    [string]$Sql
  )
  docker exec -i $Container psql -U $User -d $Db -v ON_ERROR_STOP=1 -c $Sql
}

# ---------------------------
# Paths
# ---------------------------
$root = "C:\tesis-db"
$initDir = Join-Path $ProjectDir "init"

$loadScript  = Join-Path $root "automation\pg\pg_load_tpcc.ps1"
$benchScript = Join-Path $root "automation\run_benchbase_templated.ps1"
$parseScript = Join-Path $root "automation\parse_bechbase.ps1"

# ---------------------------
# 1) Recreate (opcional)
# ---------------------------
if ($Recreate) {
  Write-Host "Bajando stack (volúmenes incluidos)..." -ForegroundColor Yellow
  Invoke-Compose @("down","-v")
}

# ---------------------------
# 2) Up
# ---------------------------
Write-Host "Levantando stack PostgreSQL+Citus+FDW..." -ForegroundColor Green
Invoke-Compose @("up","-d")

# ---------------------------
# 3) Health
# ---------------------------
$containers = @("postgresql-worker1","postgresql-worker2","postgresql-item","postgresql-coord")
Write-Host "Esperando HEALTHY: $($containers -join ', ')" -ForegroundColor Green
Wait-Healthy -Containers $containers -TimeoutSec 240

# ---------------------------
# 4) Bitácora: versiones
# ---------------------------
Write-Host "`n==> Versiones detectadas (coordinator)" -ForegroundColor Green
Exec-PsqlOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -Sql "SELECT version();"
Exec-PsqlOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -Sql "SELECT extname, extversion FROM pg_extension WHERE extname IN ('citus','postgres_fdw') ORDER BY extname;"

# ---------------------------
# 5) SQL homogéneo: 01 en remotedb / 02..06 en coordinator
# ---------------------------

# 01 en remotedb
Exec-PsqlFileOn -Container "postgresql-item" -Db "remotedb" -User "postgres" `
  -SqlPath (Join-Path $initDir "01_populate_remotedb_item.sql")

# 02..06 en coordinator
Exec-PsqlFileOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" `
  -SqlPath (Join-Path $initDir "02_create_tpcc_schema.sql")
Exec-PsqlFileOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" `
  -SqlPath (Join-Path $initDir "03_citus_add_nodes.sql")
Exec-PsqlFileOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" `
  -SqlPath (Join-Path $initDir "04_setup_fdw.sql")
Exec-PsqlFileOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" `
  -SqlPath (Join-Path $initDir "05_tpcc_distribute.sql")

$idx = Join-Path $initDir "06_tpcc_secondary_indexes.sql"
if (Test-Path $idx) {
  Exec-PsqlFileOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -SqlPath $idx
} else {
  Write-Host "Aviso: no existe 06_tpcc_secondary_indexes.sql (omitiendo índices secundarios)." -ForegroundColor Yellow
}

# ---------------------------
# 6) Validaciones rápidas
# ---------------------------
Write-Host "`n==> Validaciones (rápidas)" -ForegroundColor Green
Exec-PsqlOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -Sql "SELECT * FROM citus_get_active_worker_nodes();"
Exec-PsqlOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -Sql "SELECT COUNT(*) AS shards FROM pg_dist_shard WHERE logicalrelid::text LIKE 'tpcc.%';"
Exec-PsqlOn -Container "postgresql-coord" -Db "tesisdb" -User "postgres" -Sql "SELECT COUNT(*) AS item_rows_fdw FROM tpcc.item;"

# ---------------------------
# 7) (Opcional) Carga real por escala
# ---------------------------
if ($RunLoad) {
  if (!(Test-Path $loadScript)) { throw "No existe loader: $loadScript" }
  Write-Host "`n==> CARGA DATASET (Scale=$Scale) usando pg_load_tpcc.ps1" -ForegroundColor Green
  & $loadScript -Scale $Scale
}

# ---------------------------
# 8) (Opcional) BenchBase por grupo de escenarios según Scale
# ---------------------------
if ($RunBench) {
  if (!(Test-Path $benchScript)) { throw "No existe bench script: $benchScript" }

  $scenarioGroup = switch ($Scale) {
    "ds100k" { @("E1_DS100k_T10","E2_DS100k_T50","E3_DS100k_T100") }
    "ds500k" { @("E4_DS500k_T10","E5_DS500k_T50","E6_DS500k_T100") }
    "ds1m"   { @("E7_DS1M_T10","E8_DS1M_T50","E9_DS1M_T100") }
  }

  Write-Host "`n==> EJECUTANDO BenchBase TEMPLATED (Runs=$Runs | Scale=$Scale)" -ForegroundColor Green
  Write-Host "Escenarios: $($scenarioGroup -join ', ')" -ForegroundColor Cyan

  & $benchScript -Runs $Runs -DockerNet $DockerNet -OnlyScenarios $scenarioGroup
}

# ---------------------------
# 9) (Opcional) Parse
# ---------------------------
if ($RunParse) {
  if (!(Test-Path $parseScript)) { throw "No existe parse script: $parseScript" }
  Write-Host "`n==> PARSE resultados BenchBase" -ForegroundColor Green
  & $parseScript -Db "postgres" -Workload "templated"
}

Write-Host "`n✅ MASTER PostgreSQL finalizado." -ForegroundColor Green