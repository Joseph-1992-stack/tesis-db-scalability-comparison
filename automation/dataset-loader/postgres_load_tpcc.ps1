#requires -Version 5.1
param(
  [ValidateSet("ds100k","ds500k","ds1m")]
  [string]$Scale = "ds100k"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = "C:\tesis-db"
$paramsPath = Join-Path $root "databases\postgres\loader\tpcc_params.ps1"
if (!(Test-Path $paramsPath)) { throw "No existe: $paramsPath" }

$p = & $paramsPath -Scale $Scale

$W  = [int]$p.Warehouses
$D  = [int]$p.DistrictsPerWarehouse
$C  = [int]$p.CustomersPerDistrict
$IT = [int]$p.Items

Write-Host "== [PG LOAD] scale=$Scale W=$W D=$D C=$C IT=$IT =="

function ExecPsql([string]$container, [string]$db, [string]$sql) {
  docker exec -i $container psql -U postgres -d $db -P pager=off -v ON_ERROR_STOP=1 -c $sql
}

$coord = "postgresql-coord"
$remote = "postgresql-item"

# 0) Sanity
Write-Host "== [0] Sanity: verificar tablas base =="
ExecPsql $coord "tesisdb" "SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema='tpcc' ORDER BY 1,2;" | Out-Host

# 1) TRUNCATE (tesisdb)
Write-Host "== [1] TRUNCATE tesisdb.tpcc (tablas que cargamos) =="
ExecPsql $coord "tesisdb" @"
TRUNCATE TABLE
  tpcc.stock,
  tpcc.customer,
  tpcc.district,
  tpcc.warehouse
;
"@ | Out-Host

# 2) TRUNCATE item físico en remotedb
Write-Host "== [2] TRUNCATE remotedb.tpcc.item (FDW target) =="
ExecPsql $remote "remotedb" "TRUNCATE TABLE tpcc.item;" | Out-Host

# 3) warehouse
Write-Host "== [3] INSERT warehouse =="
ExecPsql $coord "tesisdb" @"
INSERT INTO tpcc.warehouse (w_id, w_name, w_city)
SELECT gs AS w_id,
       'W-'||gs AS w_name,
       'City-'||gs AS w_city
FROM generate_series(1,$W) gs;
"@ | Out-Host

# 4) district
Write-Host "== [4] INSERT district =="
ExecPsql $coord "tesisdb" @"
INSERT INTO tpcc.district (d_w_id, d_id, d_name, d_city)
SELECT w AS d_w_id,
       d AS d_id,
       'D-'||w||'-'||d AS d_name,
       'City-'||w      AS d_city
FROM generate_series(1,$W) w
CROSS JOIN generate_series(1,$D) d;
"@ | Out-Host

# 5) customer
Write-Host "== [5] INSERT customer =="
ExecPsql $coord "tesisdb" @"
INSERT INTO tpcc.customer (c_w_id, c_d_id, c_id, c_first, c_last, c_city)
SELECT w AS c_w_id,
       d AS c_d_id,
       c AS c_id,
       'First-'||c AS c_first,
       'Last-'||c  AS c_last,
       'City-'||w  AS c_city
FROM generate_series(1,$W) w
CROSS JOIN generate_series(1,$D) d
CROSS JOIN generate_series(1,$C) c;
"@ | Out-Host

# 6) stock (W * IT) => aquí vive el tamaño DS100k/500k/1M
Write-Host "== [6] INSERT stock (W*IT) =="
ExecPsql $coord "tesisdb" @"
INSERT INTO tpcc.stock (s_w_id, s_i_id, s_quantity)
SELECT w AS s_w_id,
       i AS s_i_id,
       ((i * 7 + w * 13) % 91) + 10 AS s_quantity
FROM generate_series(1,$W) w
CROSS JOIN generate_series(1,$IT) i;
"@ | Out-Host

# 7) item en remotedb (FDW target) — columnas correctas: (i_id, i_name, i_price)
Write-Host "== [7] INSERT item en remotedb (FDW target) =="
ExecPsql $remote "remotedb" @"
INSERT INTO tpcc.item (i_id, i_name, i_price)
SELECT i AS i_id,
       'Item-'||i AS i_name,
       ((i % 100) + 1)::numeric(12,2) AS i_price
FROM generate_series(1,$IT) i;
"@ | Out-Host

# 8) Checks (medibles)
Write-Host "== [8] Counts (medibles) =="
ExecPsql $coord  "tesisdb"  "SELECT COUNT(*) AS warehouse FROM tpcc.warehouse;" | Out-Host
ExecPsql $coord  "tesisdb"  "SELECT COUNT(*) AS district  FROM tpcc.district;"  | Out-Host
ExecPsql $coord  "tesisdb"  "SELECT COUNT(*) AS customer  FROM tpcc.customer;"  | Out-Host
ExecPsql $coord  "tesisdb"  "SELECT COUNT(*) AS stock     FROM tpcc.stock;"     | Out-Host
ExecPsql $remote "remotedb" "SELECT COUNT(*) AS item      FROM tpcc.item;"      | Out-Host

Write-Host "DONE LOAD (dataset=$Scale)."
