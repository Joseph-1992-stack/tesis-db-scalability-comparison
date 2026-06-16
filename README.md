# Comparación de Escalabilidad entre MariaDB Spider y PostgreSQL Citus + FDW

## Descripción

Este repositorio contiene el prototipo experimental desarrollado para la tesis:

**"Comparación de las técnicas de escalabilidad de las bases de datos entre MariaDB y PostgreSQL"**

La investigación evalúa experimentalmente dos arquitecturas distribuidas para bases de datos relacionales:

* MariaDB 11.4 + Spider Storage Engine
* PostgreSQL 17 + Citus + postgres_fdw

La comparación se realiza mediante escenarios controlados de carga utilizando **BenchBase** como herramienta de benchmarking.

---

## Objetivo

Comparar el comportamiento de ambas arquitecturas distribuidas mediante escenarios experimentales reproducibles, evaluando métricas de rendimiento y escalabilidad bajo diferentes volúmenes de datos y niveles de concurrencia.

---

## Tecnologías utilizadas

* Docker Compose
* MariaDB 11.4
* PostgreSQL 17
* Citus
* Spider Storage Engine
* postgres_fdw
* BenchBase
* PowerShell
* Git
* GitHub

---

## Métricas evaluadas

Las métricas principales analizadas durante los experimentos son:

* TPS (Transactions Per Second)
* Latencia promedio
* Desviación estándar de latencia
* Tiempo total de ejecución
* Throughput
* Goodput

---

## Escenarios experimentales

Se evaluaron tres tamaños de dataset y tres niveles de concurrencia:

| Dataset | Terminales |
|----------|------------|
| DS100k | T10, T50, T100 |
| DS500k | T10, T50, T100 |
| DS1M | T10, T50, T100 |

Donde:

* **DS** = tamaño del conjunto de datos.
* **T** = número de terminales concurrentes de BenchBase.

---

## Arquitecturas evaluadas

### PostgreSQL

Arquitectura distribuida basada en:

* PostgreSQL 17
* Citus (sharding distribuido)
* postgres_fdw (acceso federado)

### MariaDB

Arquitectura distribuida basada en:

* MariaDB 11.4
* Spider Storage Engine (federación y distribución de tablas)

---

## Estructura general del repositorio

El repositorio se encuentra organizado en cuatro directorios principales.

### automation/

Contiene los scripts PowerShell encargados de automatizar el despliegue, preparación y ejecución de los experimentos.

Principales componentes:

* master_postgres.ps1
* master_mariadb.ps1
* run_benchbase_templated.ps1
* parse_benchbase.ps1
* dataset-loader/postgres_load_tpcc.ps1
* dataset-loader/mariadb_load_tpcc.ps1

Estos scripts permiten reproducir completamente los escenarios experimentales.

---

### orchestrator/

Contiene toda la infraestructura necesaria para desplegar los entornos distribuidos mediante Docker Compose.

Incluye:

* docker-compose.yml
* archivos de configuración de PostgreSQL
* archivos de configuración de MariaDB
* scripts SQL de inicialización
* definición de nodos coordinadores y trabajadores

Su propósito es construir automáticamente los clústeres utilizados durante los experimentos.

---

### benchbase-config/

Contiene la configuración de las cargas de trabajo ejecutadas por BenchBase.

Incluye:

* queries.xml
* escenarios experimentales
* archivos config.xml
* parámetros de ejecución

Aquí se definen las transacciones utilizadas para medir el rendimiento de los gestores de bases de datos.

---

### databases/

Contiene scripts auxiliares relacionados con la parametrización de datasets y la carga de información experimental.

Incluye:

* parametrización de escalas experimentales
* definición de tamaños de dataset
* scripts de soporte para generación de datos

Estos archivos permiten construir los conjuntos de datos utilizados durante las pruebas.

---

## Reproducibilidad

Todos los experimentos fueron diseñados para ser reproducibles mediante Docker Compose y scripts automatizados.

La ejecución completa de un escenario experimental sigue la siguiente secuencia:

1. Despliegue del clúster distribuido.
2. Configuración de la arquitectura correspondiente.
3. Generación y carga del dataset.
4. Ejecución del workload mediante BenchBase.
5. Recolección de métricas.
6. Procesamiento y análisis de resultados.

---

## Dependencias y entorno de validación

Los experimentos fueron desarrollados y validados utilizando el siguiente entorno tecnológico:

* Windows 10
* Docker Desktop
* Docker Engine (Linux Containers)
* PowerShell 5.1
* Eclipse Temurin JDK 23
* BenchBase
* PostgreSQL 17 + Citus
* MariaDB 11.4 + Spider Storage Engine

La utilización de estas versiones permite reproducir las arquitecturas experimentales y los resultados obtenidos durante la investigación.

## Autor

**José Luis Quizhpe Paqui**
Universidad Técnica Particular de Loja (UTPL)
