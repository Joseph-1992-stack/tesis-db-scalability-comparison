# Automation

## Descripción

Esta carpeta contiene los scripts PowerShell utilizados para automatizar la ejecución de los experimentos desarrollados en la investigación.

Su objetivo es garantizar la reproducibilidad de los escenarios experimentales, minimizando la intervención manual durante el despliegue, carga de datos, ejecución de BenchBase y validación de resultados.

La automatización fue diseñada para permitir la ejecución homogénea de las arquitecturas:

* PostgreSQL + Citus + postgres_fdw
* MariaDB + Spider Storage Engine

---

## Estructura de la carpeta

```text
automation
│
├── mariadb
│   └── master_mariadb.ps1
│
├── postgres
│   └── master_postgres.ps1
│
├── pg
│   └── pg_load_tpcc.ps1
│
└── run_benchbase_templated.ps1
```

---

## Scripts principales

### master_postgres.ps1

Script maestro encargado de automatizar completamente el entorno experimental de PostgreSQL.

Funciones principales:

* Levantar contenedores Docker.
* Verificar estado HEALTHY de los nodos.
* Ejecutar scripts SQL de inicialización.
* Configurar Citus y postgres_fdw.
* Cargar datasets experimentales.
* Ejecutar BenchBase.
* Lanzar procesos de análisis posteriores.

Este script constituye el punto de entrada principal para los experimentos sobre PostgreSQL.

---

### master_mariadb.ps1

Script maestro encargado de automatizar completamente el entorno experimental de MariaDB.

Funciones principales:

* Levantar contenedores Docker.
* Verificar estado HEALTHY de los nodos.
* Instalar y validar Spider Storage Engine.
* Configurar servidores Spider.
* Crear tablas distribuidas.
* Cargar datasets experimentales.
* Ejecutar BenchBase.
* Lanzar procesos de análisis posteriores.

Este script constituye el punto de entrada principal para los experimentos sobre MariaDB.

---

### pg_load_tpcc.ps1

Script encargado de generar y cargar los datasets experimentales para PostgreSQL.

Permite construir los conjuntos de datos:

* DS100k
* DS500k
* DS1M

Mediante la inserción controlada de registros en las tablas:

* warehouse
* district
* customer
* stock
* item

Su función es garantizar que cada escenario experimental inicie desde una configuración consistente y reproducible.

---

### run_benchbase_templated.ps1

Script genérico utilizado para ejecutar BenchBase sobre cualquiera de los gestores de bases de datos evaluados.

Características:

* Compatible con PostgreSQL y MariaDB.
* Ejecuta escenarios individuales o grupos completos.
* Gestiona múltiples repeticiones experimentales.
* Almacena automáticamente los resultados.
* Conserva archivos de salida y registros de ejecución.

Este script constituye el núcleo de la automatización de benchmarking del proyecto.

---

## Flujo experimental general

La secuencia típica de ejecución es:

1. Despliegue del clúster distribuido.
2. Configuración de la arquitectura correspondiente.
3. Carga del dataset experimental.
4. Ejecución de BenchBase.
5. Recolección de resultados.
6. Análisis de métricas.

Todo el proceso puede ejecutarse de forma automatizada mediante los scripts maestros incluidos en esta carpeta.

---

## Observación

Los scripts fueron desarrollados específicamente para los escenarios definidos en la tesis y utilizan rutas locales configuradas para el entorno experimental descrito en la investigación.
