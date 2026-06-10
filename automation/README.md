# Automation

## DescripciÃ³n

Esta carpeta contiene los scripts PowerShell utilizados para automatizar la ejecuciÃ³n de los experimentos desarrollados en la investigaciÃ³n.

Su objetivo es garantizar la reproducibilidad de los escenarios experimentales, minimizando la intervenciÃ³n manual durante el despliegue, carga de datos, ejecuciÃ³n de BenchBase y validaciÃ³n de resultados.

La automatizaciÃ³n fue diseÃ±ada para permitir la ejecuciÃ³n homogÃ©nea de las arquitecturas:

* PostgreSQL + Citus + postgres_fdw
* MariaDB + Spider Storage Engine

---

## Estructura de la carpeta

```text
automation
â”‚
â”œâ”€â”€ mariadb
â”‚   â””â”€â”€ master_mariadb.ps1
â”‚
â”œâ”€â”€ postgres
â”‚   â””â”€â”€ master_postgres.ps1
â”‚
â”œâ”€â”€ dataset-loader
â”‚   â””â”€â”€ postgres_load_tpcc.ps1
â”‚
â””â”€â”€ run_benchbase_templated.ps1
```

---

## Scripts principales

### master_postgres.ps1

Script maestro encargado de automatizar completamente el entorno experimental de PostgreSQL.

Funciones principales:

* Levantar contenedores Docker.
* Verificar estado HEALTHY de los nodos.
* Ejecutar scripts SQL de inicializaciÃ³n.
* Configurar Citus y postgres_fdw.
* Cargar datasets experimentales.
* Ejecutar BenchBase.
* Lanzar procesos de anÃ¡lisis posteriores.

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
* Lanzar procesos de anÃ¡lisis posteriores.

Este script constituye el punto de entrada principal para los experimentos sobre MariaDB.

---

### postgres_load_tpcc.ps1

Script encargado de generar y cargar los datasets experimentales para PostgreSQL.

Permite construir los conjuntos de datos:

* DS100k
* DS500k
* DS1M

Mediante la inserciÃ³n controlada de registros en las tablas:

* warehouse
* district
* customer
* stock
* item

Su funciÃ³n es garantizar que cada escenario experimental inicie desde una configuraciÃ³n consistente y reproducible.

---

### run_benchbase_templated.ps1

Script genÃ©rico utilizado para ejecutar BenchBase sobre cualquiera de los gestores de bases de datos evaluados.

CaracterÃ­sticas:

* Compatible con PostgreSQL y MariaDB.
* Ejecuta escenarios individuales o grupos completos.
* Gestiona mÃºltiples repeticiones experimentales.
* Almacena automÃ¡ticamente los resultados.
* Conserva archivos de salida y registros de ejecuciÃ³n.

Este script constituye el nÃºcleo de la automatizaciÃ³n de benchmarking del proyecto.

---

## Flujo experimental general

La secuencia tÃ­pica de ejecuciÃ³n es:

1. Despliegue del clÃºster distribuido.
2. ConfiguraciÃ³n de la arquitectura correspondiente.
3. Carga del dataset experimental.
4. EjecuciÃ³n de BenchBase.
5. RecolecciÃ³n de resultados.
6. AnÃ¡lisis de mÃ©tricas.

Todo el proceso puede ejecutarse de forma automatizada mediante los scripts maestros incluidos en esta carpeta.

---

## ObservaciÃ³n

Los scripts fueron desarrollados especÃ­ficamente para los escenarios definidos en la tesis y utilizan rutas locales configuradas para el entorno experimental descrito en la investigaciÃ³n.
