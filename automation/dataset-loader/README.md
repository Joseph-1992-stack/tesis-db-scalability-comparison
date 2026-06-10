# Dataset Loader

## DescripciÃ³n

Esta carpeta contiene los scripts encargados de generar y cargar los conjuntos de datos utilizados durante los experimentos de benchmarking desarrollados en la investigaciÃ³n.

Los datasets son utilizados para construir los escenarios experimentales definidos en la tesis:

* DS100k
* DS500k
* DS1M

Cada escenario representa un volumen diferente de datos y permite evaluar el comportamiento de las arquitecturas distribuidas bajo distintos niveles de carga.

---

## Estructura

```text 
dataset-loader
â”‚
â””â”€â”€ postgres_load_tpcc.ps1
```

---

## Script disponible

### postgres_load_tpcc.ps1

Script encargado de generar y cargar los datos experimentales para PostgreSQL.

Sus principales funciones son:

* Limpiar datos previamente cargados.
* Generar registros sintÃ©ticos de forma reproducible.
* Poblar las tablas del esquema experimental.
* Construir los datasets DS100k, DS500k y DS1M.
* Verificar la cantidad de registros cargados.

---

## Tablas involucradas

El script genera informaciÃ³n para las siguientes tablas:

* warehouse
* district
* customer
* stock
* item

Estas tablas forman parte de una versiÃ³n reducida del esquema TPC-C utilizada en la investigaciÃ³n.

---

## RelaciÃ³n con el workload experimental

Aunque el benchmark utiliza principalmente las tablas:

* customer
* stock
* item

las tablas:

* warehouse
* district

se mantienen dentro del esquema para conservar la coherencia estructural del modelo de datos derivado de TPC-C.

Las transacciones ejecutadas por BenchBase son:

### ReadJoinItem

Realiza un JOIN entre:

* customer
* item

simulando acceso distribuido y acceso federado.

### UpdateStock

Realiza operaciones de actualizaciÃ³n sobre:

* stock

simulando actividad transaccional concurrente.

---

## Escalas experimentales

El script permite generar tres tamaÃ±os de dataset:

| Escala | DescripciÃ³n        |
| ------ | ------------------ |
| DS100k | Dataset pequeÃ±o    |
| DS500k | Dataset intermedio |
| DS1M   | Dataset grande     |

Estas escalas permiten analizar el comportamiento de las arquitecturas distribuidas conforme aumenta el volumen de datos.

---

## ConsideraciÃ³n sobre MariaDB

Actualmente la generaciÃ³n explÃ­cita de datasets se encuentra implementada mediante el script `postgres_load_tpcc.ps1`.

Para MariaDB, la preparaciÃ³n de la arquitectura distribuida y la creaciÃ³n de las estructuras necesarias se realizan mediante los scripts SQL ubicados en:

```text
orchestrator/mariadb/init
```

Por esta razÃ³n no existe actualmente un cargador independiente equivalente para MariaDB dentro de esta carpeta.

---

## Objetivo

Garantizar que todos los escenarios experimentales inicien desde conjuntos de datos controlados, reproducibles y consistentes, permitiendo realizar comparaciones vÃ¡lidas entre PostgreSQL y MariaDB.
