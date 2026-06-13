# ============================================================
# TEST â€“ Verificar correcciÃ³n "Invalid" en queries.xml
# BenchBase desde cÃ³digo local (Maven + Temurin)
# ============================================================

$ErrorActionPreference = "Stop"

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ResultDir = "C:\tesis-db\results\benchbase\postgres\test_invalid_fix\run_$Timestamp"
New-Item -ItemType Directory -Force -Path $ResultDir | Out-Null

$BenchBaseDir = "C:\tesis-db\benchbase"
$CfgRoot      = "C:\tesis-db\benchbase-config\postgres\templated"
$Net          = "postgres_tesisnet"

Write-Host "======================================="
Write-Host "BenchBase local Maven TEST"
Write-Host "BenchBaseDir: $BenchBaseDir"
Write-Host "CfgRoot     : $CfgRoot"
Write-Host "Network     : $Net"
Write-Host "ResultDir   : $ResultDir"
Write-Host "======================================="

if (-not (Test-Path $BenchBaseDir)) { throw "No existe BenchBaseDir: $BenchBaseDir" }
if (-not (Test-Path $CfgRoot))      { throw "No existe CfgRoot: $CfgRoot" }

# Autodetectar config.xml mÃ¡s reciente
$configs = Get-ChildItem -Path $CfgRoot -Recurse -Filter "config.xml" -File |
           Sort-Object LastWriteTime -Descending
if ($configs.Count -eq 0) { throw "No se encontrÃ³ ningÃºn config.xml dentro de: $CfgRoot" }

$LocalConfig = $configs[0].FullName
$RelativeConfig = $LocalConfig.Substring($CfgRoot.Length).TrimStart('\') -replace '\\','/'
$ConfigInside   = "/cfg/$RelativeConfig"

Write-Host ""
Write-Host "Usando config.xml mÃ¡s reciente:" -ForegroundColor Cyan
Write-Host "  Local : $LocalConfig"
Write-Host "  Inside: $ConfigInside"
Write-Host ""

# Montajes (usar ${} para evitar bug con :)
$VolBB      = "${BenchBaseDir}:/bb"
$VolCfg     = "${CfgRoot}:/cfg"
$VolResults = "${ResultDir}:/results"

$ConsoleLog = Join-Path $ResultDir "console_output.log"

# Comando robusto en una sola lÃ­nea
$Cmd = "cd /bb && mvn -q -DskipTests package && java -jar target/benchbase.jar -b templated -c `"$ConfigInside`" --create=false --load=false --execute=true -s 10 -t 20"

Write-Host "Compilando y ejecutando prueba corta (warmup 10s, time 20s)..." -ForegroundColor Cyan

docker run --rm `
  --network $Net `
  -v $VolBB `
  -v $VolCfg `
  -v $VolResults `
  maven:3.9-eclipse-temurin-21 `
  bash -lc "$Cmd" `
  *> $ConsoleLog

Write-Host ""
Write-Host "======================================="
Write-Host "ValidaciÃ³n de error 'Procedure Invalid'"
Write-Host "======================================="

if (Select-String -Path $ConsoleLog -Pattern "Procedure Invalid" -Quiet) {
  Write-Host "âŒ AÃºn aparece 'Procedure Invalid':" -ForegroundColor Red
  Select-String -Path $ConsoleLog -Pattern "Procedure Invalid" -Context 2,6
} else {
  Write-Host "âœ… OK: No aparece 'Procedure Invalid'." -ForegroundColor Green
}

Write-Host ""
Write-Host "Log completo: $ConsoleLog"
Write-Host "======================================="
Write-Host "Prueba finalizada."
Write-Host "======================================="
