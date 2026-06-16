# Dataset Loader

## Descripción

Esta carpeta contiene los scripts encargados de generar y cargar los conjuntos de datos utilizados durante los experimentos de benchmarking desarrollados en la investigación.

Ambos scripts utilizan la misma parametrización centralizada definida en:

databases/postgres/loader/tpcc_params.ps1, con el fin de garantizar equivalencia metodológica entre PostgreSQL y MariaDB.

Los datasets son utilizados para construir los escenarios experimentales definidos en la tesis:

* DS100k
* DS500k
* DS1M

Cada escenario representa un volumen diferente de datos y permite evaluar el comportamiento de las arquitecturas distribuidas bajo distintos niveles de carga y concurrencia.

---

## Estructura

```text
dataset-loader
│
├── postgres_load_tpcc.ps1
├── mariadb_load_tpcc.ps1
│
└── README.md
```

---

## Scripts disponibles

### postgres_load_tpcc.ps1

Script encargado de generar y cargar los datos experimentales para la arquitectura basada en PostgreSQL, Citus y postgres_fdw.

Sus principales funciones son:

* Limpiar datos previamente cargados.
* Generar registros sintéticos de forma reproducible.
* Poblar las tablas del esquema experimental.
* Construir los datasets DS100k, DS500k y DS1M.
* Verificar la cantidad de registros cargados.

---

### mariadb_load_tpcc.ps1

Script encargado de generar y cargar los datos experimentales para la arquitectura basada en MariaDB y Spider Storage Engine.

Sus principales funciones son:

* Limpiar datos previamente cargados.
* Generar registros sintéticos equivalentes a los utilizados en PostgreSQL.
* Poblar las tablas distribuidas gestionadas por Spider.
* Construir los datasets DS100k, DS500k y DS1M.
* Verificar la cantidad de registros cargados.

Este script fue desarrollado para mantener la equivalencia metodológica entre ambas arquitecturas experimentales.

---

## Tablas involucradas

Los scripts generan información para las siguientes tablas:

* warehouse
* district
* customer
* stock
* item


La reducción del esquema TPC-C fue realizada para concentrar el análisis en operaciones representativas de lectura distribuida y actualización transaccional, manteniendo la comparabilidad entre ambas arquitecturas evaluadas.

---

## Relación con el workload experimental

Aunque el benchmark utiliza principalmente las tablas:

* customer
* stock
* item

las tablas:

* warehouse
* district

se mantienen dentro del esquema para preservar la coherencia estructural del modelo de datos derivado de TPC-C.

Las transacciones ejecutadas por BenchBase son:

### ReadJoinItem

Realiza un JOIN entre:

* customer
* item

simulando acceso distribuido y acceso federado.

### UpdateStock

Realiza operaciones de actualización sobre:

* stock

simulando actividad transaccional concurrente.

La distribución de la carga de trabajo utilizada durante los experimentos es:

| Transacción  | Participación |
| ------------ | ------------- |
| ReadJoinItem | 50 %          |
| UpdateStock  | 50 %          |

---

## Escalas experimentales

Los scripts permiten generar tres tamaños de dataset:

| Escala | Descripción        |
| ------ | ------------------ |
| DS100k | Dataset pequeño    |
| DS500k | Dataset intermedio |
| DS1M   | Dataset grande     |

Estas escalas permiten analizar el comportamiento de las arquitecturas distribuidas conforme aumenta el volumen de datos.

---

## Parametrización de escalas

La definición de los tamaños de dataset se encuentra centralizada en:

```text
databases/postgres/loader/tpcc_params.ps1
```

Este archivo establece la cantidad de warehouses, distritos, clientes e ítems utilizados para construir cada escala experimental.

---

## Objetivo

Garantizar que todos los escenarios experimentales inicien desde conjuntos de datos controlados, reproducibles y consistentes, permitiendo realizar comparaciones válidas entre PostgreSQL y MariaDB bajo condiciones equivalentes.
