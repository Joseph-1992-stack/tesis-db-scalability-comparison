# Automation

## Descripción

Esta carpeta contiene los scripts PowerShell utilizados para automatizar la ejecución de los experimentos desarrollados en la investigación.

Su objetivo es garantizar la reproducibilidad de los escenarios experimentales, minimizando la intervención manual durante las etapas de despliegue, configuración, carga de datos, ejecución de BenchBase y procesamiento de resultados.

La automatización fue diseñada para permitir una ejecución homogénea de las arquitecturas evaluadas:

* PostgreSQL 17 + Citus + postgres_fdw
* MariaDB 11.4 + Spider Storage Engine

---

## Estructura de la carpeta

```text
automation
│
├── dataset-loader
│   ├── postgres_load_tpcc.ps1
│   ├── mariadb_load_tpcc.ps1
│   └── README.md
│
├── mariadb
│   └── master_mariadb.ps1
│
├── postgres
│   ├── master_postgres.ps1
│   └── README.md
│
├── run_benchbase_templated.ps1
│
└── README.md
```

---

## Componentes principales

### dataset-loader

Contiene los scripts responsables de generar y cargar los conjuntos de datos utilizados durante los experimentos.

#### postgres_load_tpcc.ps1

Genera y carga los datasets experimentales sobre PostgreSQL mediante inserciones controladas en las tablas del esquema experimental.

Permite construir las escalas:

* DS100k
* DS500k
* DS1M

#### mariadb_load_tpcc.ps1

Genera y carga los datasets experimentales sobre MariaDB utilizando la arquitectura distribuida basada en Spider.

Permite construir las mismas escalas experimentales:

* DS100k
* DS500k
* DS1M

El objetivo de ambos scripts es garantizar que los escenarios experimentales comiencen desde configuraciones equivalentes y reproducibles.

---

### postgres

Contiene el script maestro de automatización para PostgreSQL.

#### master_postgres.ps1

Automatiza completamente el ciclo experimental sobre PostgreSQL:

* Levantamiento del clúster distribuido.
* Verificación de salud de los nodos.
* Configuración de Citus.
* Configuración de postgres_fdw.
* Inicialización del esquema experimental.
* Distribución de tablas.
* Carga de datasets.
* Ejecución de BenchBase.
* Procesamiento de resultados.

Constituye el punto de entrada principal para los experimentos realizados sobre PostgreSQL.

---

### mariadb

Contiene el script maestro de automatización para MariaDB.

#### master_mariadb.ps1

Automatiza completamente el ciclo experimental sobre MariaDB:

* Levantamiento del clúster distribuido.
* Verificación de salud de los nodos.
* Instalación y validación de Spider.
* Configuración de servidores Spider.
* Creación de tablas distribuidas.
* Carga de datasets.
* Ejecución de BenchBase.
* Procesamiento de resultados.

Constituye el punto de entrada principal para los experimentos realizados sobre MariaDB.

---

### run_benchbase_templated.ps1

Script genérico encargado de ejecutar BenchBase sobre cualquiera de las arquitecturas evaluadas.

Características principales:

* Compatible con PostgreSQL y MariaDB.
* Ejecuta escenarios individuales o grupos completos de escenarios.
* Permite múltiples repeticiones experimentales.
* Almacena automáticamente resultados y registros de ejecución.
* Organiza la salida de BenchBase de forma estructurada para su posterior análisis.

Este script constituye el núcleo del proceso de benchmarking de la investigación.

---

## Flujo experimental general

La secuencia típica de ejecución es:

1. Despliegue del clúster distribuido.
2. Configuración de la arquitectura correspondiente.
3. Generación y carga del dataset experimental.
4. Ejecución del workload mediante BenchBase.
5. Recolección de resultados.
6. Procesamiento y análisis de métricas.

Todo el proceso puede ejecutarse de forma automatizada mediante los scripts incluidos en esta carpeta.

---

## Objetivo

Garantizar que todos los experimentos realizados durante la investigación sean reproducibles, controlados y consistentes, permitiendo comparar de manera objetiva las estrategias de escalabilidad implementadas en PostgreSQL y MariaDB.
