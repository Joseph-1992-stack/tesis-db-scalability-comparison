#requires -Version 5.1
param(
[ValidateSet("ds100k","ds500k","ds1m")]
[string]$Scale = "ds100k"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = "C:\tesis-db"
$paramsPath = Join-Path $root "databases\postgres\loader\tpcc_params.ps1"

if (!(Test-Path $paramsPath)) {
throw "No existe archivo de parámetros: $paramsPath"
}

$p = & $paramsPath -Scale $Scale

$W  = [int]$p.Warehouses
$D  = [int]$p.DistrictsPerWarehouse
$C  = [int]$p.CustomersPerDistrict
$IT = [int]$p.Items

Write-Host "== [MARIADB LOAD] scale=$Scale W=$W D=$D C=$C IT=$IT ==" -ForegroundColor Green

$coord = "mariadb-coord"
$db    = "tesisdb"
$user  = "root"
$pass  = "rootpass"

function ExecMariaSql {
param(
[string]$Container,
[string]$Database,
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
"--database=$Database"
)

$Sql | docker @dockerArgs

if ($LASTEXITCODE -ne 0) {
throw "Falló SQL en $Container/$Database"
}
}

function New-NumberSource {
param(
[int]$Max
)

if ($Max -le 0) {
throw "Max debe ser mayor que cero."
}

return @"
(
SELECT
(d0.n + d1.n*10 + d2.n*100 + d3.n*1000 + d4.n*10000 + d5.n*100000 + 1) AS n
FROM
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d0
CROSS JOIN
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d1
CROSS JOIN
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d2
CROSS JOIN
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d3
CROSS JOIN
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d4
CROSS JOIN
(SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d5
WHERE
(d0.n + d1.n*10 + d2.n*100 + d3.n*1000 + d4.n*10000 + d5.n*100000) < $Max
)
"@
}

$seqW  = New-NumberSource $W
$seqD  = New-NumberSource $D
$seqC  = New-NumberSource $C
$seqIT = New-NumberSource $IT

Write-Host "== [0] Sanity: verificar tablas base ==" -ForegroundColor Cyan
ExecMariaSql $coord $db "SHOW TABLES;" $user $pass

Write-Host "== [1] TRUNCATE tablas lógicas Spider ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE order_line;
TRUNCATE TABLE new_order;
TRUNCATE TABLE orders;
TRUNCATE TABLE stock;
TRUNCATE TABLE customer;
TRUNCATE TABLE district;
TRUNCATE TABLE warehouse;
TRUNCATE TABLE item;
SET FOREIGN_KEY_CHECKS=1;
"@ $user $pass

Write-Host "== [2] INSERT warehouse ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
INSERT INTO warehouse (w_id, w_name, w_city)
SELECT
w.n AS w_id,
CONCAT('W-', w.n) AS w_name,
CONCAT('City-', w.n) AS w_city
FROM $seqW w;
"@ $user $pass

Write-Host "== [3] INSERT district ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
INSERT INTO district (d_w_id, d_id, d_name, d_city)
SELECT
w.n AS d_w_id,
d.n AS d_id,
CONCAT('D-', w.n, '-', d.n) AS d_name,
CONCAT('City-', w.n) AS d_city
FROM $seqW w
CROSS JOIN $seqD d;
"@ $user $pass

Write-Host "== [4] INSERT customer ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
INSERT INTO customer (c_w_id, c_d_id, c_id, c_first, c_last, c_city)
SELECT
w.n AS c_w_id,
d.n AS c_d_id,
c.n AS c_id,
CONCAT('First-', c.n) AS c_first,
CONCAT('Last-', c.n) AS c_last,
CONCAT('City-', w.n) AS c_city
FROM $seqW w
CROSS JOIN $seqD d
CROSS JOIN $seqC c;
"@ $user $pass

Write-Host "== [5] INSERT stock ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
INSERT INTO stock (s_w_id, s_i_id, s_quantity)
SELECT
w.n AS s_w_id,
i.n AS s_i_id,
((i.n * 7 + w.n * 13) MOD 91) + 10 AS s_quantity
FROM $seqW w
CROSS JOIN $seqIT i;
"@ $user $pass

Write-Host "== [6] INSERT item ==" -ForegroundColor Cyan
ExecMariaSql $coord $db @"
INSERT INTO item (i_id, i_name, i_price)
SELECT
i.n AS i_id,
CONCAT('Item-', i.n) AS i_name,
CAST(((i.n MOD 100) + 1) AS DECIMAL(12,2)) AS i_price
FROM $seqIT i;
"@ $user $pass

Write-Host "== [7] Counts (medibles) ==" -ForegroundColor Cyan
ExecMariaSql $coord $db "SELECT COUNT(*) AS warehouse FROM warehouse;" $user $pass
ExecMariaSql $coord $db "SELECT COUNT(*) AS district  FROM district;"  $user $pass
ExecMariaSql $coord $db "SELECT COUNT(*) AS customer  FROM customer;"  $user $pass
ExecMariaSql $coord $db "SELECT COUNT(*) AS stock     FROM stock;"     $user $pass
ExecMariaSql $coord $db "SELECT COUNT(*) AS item      FROM item;"      $user $pass

Write-Host "DONE LOAD MariaDB (dataset=$Scale)." -ForegroundColor Green
