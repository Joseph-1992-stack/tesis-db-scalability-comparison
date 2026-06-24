# PostgreSQL Dataset Parameters

## Descripción

Esta carpeta contiene archivos auxiliares utilizados para parametrizar la generación de datasets experimentales.

Actualmente contiene la carpeta:

```text
loader
```
---

## Estructura

```text
postgres
│
└── loader
    └── tpcc_params.ps1
```
---

## tpcc_params.ps1

Este archivo define las escalas utilizadas durante la generación de datos experimentales:

* ds100k
* ds500k
* ds1m

Para cada escala se establecen los valores de:

* Warehouses
* DistrictsPerWarehouse
* CustomersPerDistrict
* Items

Estas variables son utilizadas durante la construcción de los datasets experimentales empleados en la investigación.

---

## Uso actual

Aunque el archivo se encuentra dentro de la carpeta `postgres`, actualmente es utilizado tanto por el loader de PostgreSQL como por el loader de MariaDB.

Los scripts que lo consumen son:

* `automation/dataset-loader/postgres_load_tpcc.ps1`
* `automation/dataset-loader/mariadb_load_tpcc.ps1`

De esta manera, ambas arquitecturas utilizan exactamente los mismos parámetros de generación de datos.

---

## Equivalencia experimental

La centralización de los parámetros de escala permite garantizar que los datasets utilizados por PostgreSQL y MariaDB sean equivalentes.

Esto contribuye a mantener la consistencia metodológica de los experimentos y facilita la comparación objetiva de los resultados obtenidos.

---

## Objetivo

Centralizar la definición de escalas experimentales para garantizar que los datasets cargados en PostgreSQL y MariaDB sean equivalentes y reproducibles.
