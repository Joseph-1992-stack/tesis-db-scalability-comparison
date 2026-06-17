# MariaDB BenchBase Configuration

## Descripción

Esta carpeta contiene la configuración específica de BenchBase utilizada para ejecutar los experimentos sobre la arquitectura basada en MariaDB.

La configuración fue desarrollada para evaluar la arquitectura distribuida compuesta por:

* MariaDB 11.4
* Spider Storage Engine

---

## Estructura

```text
mariadb
│
└── templated
    ├── queries.xml
    └── scenarios
``` 

## Workload

La definición completa del workload y de los escenarios experimentales se encuentra documentada en:

`benchbase-config/README.md`

Se utiliza el workload personalizado `templated`, implementado mediante las transacciones:

* ReadJoinItem
* UpdateStock

## Particularidades de MariaDB

Las consultas definidas en `queries.xml` utilizan sintaxis compatible con MariaDB.

La transacción ReadJoinItem accede a la tabla `item` mediante Spider Storage Engine, permitiendo evaluar el comportamiento de acceso remoto dentro de la arquitectura distribuida.

## Escenarios

Se incluyen los nueve escenarios experimentales definidos para la investigación:

* E1_DS100k_T10
* E2_DS100k_T50
* E3_DS100k_T100
* E4_DS500k_T10
* E5_DS500k_T50
* E6_DS500k_T100
* E7_DS1M_T10
* E8_DS1M_T50
* E9_DS1M_T100

## Objetivo

Proporcionar la configuración BenchBase necesaria para ejecutar de forma reproducible los experimentos sobre MariaDB, manteniendo equivalencia metodológica con la configuración utilizada para PostgreSQL.
