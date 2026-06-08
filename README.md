# Comparación de Escalabilidad entre MariaDB Spider y PostgreSQL Citus + FDW

## Descripción

El siguiente repositorio contiene el prototipo experimental desarrollado para la tesis:

"Comparación de las técnicas de escalabilidad de las bases de datos entre MariaDB y PostgreSQL"

La investigación evalúa dos arquitecturas distribuidas:

- MariaDB + Spider Storage Engine
- PostgreSQL + Citus + postgres_fdw
  mediante escenarios controlados de carga utilizando BenchBase como herramienta de benchmarking

## Objetivo

Comparar el comportamiento de ambas arquitecturas distribuidas mediante escenarios experimental reproducibles, evaluando métricas de rendimiento y escalabilidad bajo diferentes volúmenes de datos y niveles de concurrencia.

## Tecnologías utilizadas

- Docker Compose
- MariaDB 11.4
- PostgreSQL 17 + Citus
- Spider Storage Engine
- postgres_fdw
- BenchBase
- PowerShell
- Git y GitHub

## Métricas evaluadas

- TPS (Transactions Per Second)
- Latencia promedio
- Desviación estándar
- Tiempo total de ejecución

## Escenarios experimentales

DS100k:
- T10
- T50
- T100

DS500k:
- T10
- T50
- T100

DS1M:
- T10
- T50
- T100

Donde: 
DS = tamaño del conjunto de datos
T  = número de terminales concurrentes de BenchBase

## Estructura general del repositorio 
El repositorio se encuentra organizada en cuatro directorios principales

## automation/
Contiene los scripts PowerShell encargados de automatizar el despliegue, preparación y ejecuciónb de los experimentos.
Principales componentes:

- master_postgres.ps1
- master_mariadb.ps1
- run_benchbase_templated.ps1
- pg_load_tpcc.ps1

Estos scripts permiten reproducir completamente los escenarios experimentales.

## orchestrator/
Contiene toda la infraestructura necesaria para desplegar los entornos distribuidos mediante Docker Compose.

Incluye:

- docker-compose.yml
- archivos de configuración de PostgreSQL
- archivos de configuración de MariaDB
- scripts SQL de inicialización
- definición de nodos coordinadores y trabajadores

Su propósito es construir automáticamente los clústeres utilizados durante los experimentos.

## benchbase-config/
Contiene la configuración de las cargas de trabajo ejecutadas por BenchBase.

Incluye:

- queries.xml
- escenarios experimentales
- archivos config.xml
- parámetros de ejecución

Aquí se definen las transacciones utilizadas para medir el rendimiento de los gestores de bases de datos.

## automation/
Contiene scripts auxiliares relacionados con la preparación de datasets y carga de información.

Incluye:

- generación de datasets
- parametrización de escalas experimentales
- scripts de carga para PostgreSQL

Estos archivos permiten construir los datasets utilizados durante las pruebas.

## Reproducibilidad 
Todos los experimentos fueron diseñados para ser reproducibles mediante Docker Compose y scripts automatizados.

La ejecución completa de un escenario experimental requiere:

Despliegue del clúster correspondiente.
Carga del dataset.
Ejecución de BenchBase.
Recolección de métricas.
Análisis de resultados.

## Autor

José Luis Quizhpe Paqui
Universidad Técnica Particular de Loja

