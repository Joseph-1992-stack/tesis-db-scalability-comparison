param(
  [ValidateSet("ds100k","ds500k","ds1m")]
  [string]$Scale = "ds100k"
)

switch ($Scale) {
  "ds100k" { return @{ Warehouses = 1; DistrictsPerWarehouse = 10; CustomersPerDistrict = 3000; Items = 100000 } }
  "ds500k" { return @{ Warehouses = 5; DistrictsPerWarehouse = 10; CustomersPerDistrict = 3000; Items = 100000 } }
  "ds1m"   { return @{ Warehouses = 10; DistrictsPerWarehouse = 10; CustomersPerDistrict = 3000; Items = 100000 } }
}
