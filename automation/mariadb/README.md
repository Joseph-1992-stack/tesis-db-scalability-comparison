# MariaDB Automation

## Descripción

Esta carpeta contiene el script maestro utilizado para automatizar el entorno experimental de MariaDB.

La automatización fue diseñada para reproducir de forma controlada la arquitectura distribuida evaluada en la investigación:

* MariaDB 11.4
* Spider Storage Engine

utilizando contenedores Docker, scripts SQL de inicialización y scripts PowerShell.

---

## Estructura

```text
mariadb
│
├── master_mariadb.ps1
└── README.md
```

---

## Script principal

### master_mariadb.ps1

Script encargado de orquestar el ciclo experimental para MariaDB.

Permite ejecutar de forma automatizada:

* Despliegue del clúster MariaDB.
* Verificación de salud de los contenedores.
* Instalación y validación de Spider.
* Configuración de servidores Spider.
* Creación de tablas distribuidas.
* Carga de datasets experimentales.
* Ejecución de BenchBase.
* Procesamiento y consolidación automática de resultados mediante parse_benchbase.ps1.
  
---

## Arquitectura desplegada

El script trabaja sobre la arquitectura definida en:

```text
orchestrator/mariadb
```

La topología experimental está compuesta por:

* MariaDB Coordinator
* MariaDB Node 1
* MariaDB Node 2
* MariaDB Item

El coordinador recibe las conexiones de BenchBase y accede a las tablas distribuidas mediante Spider.

---

## Flujo de ejecución

1. Recreación opcional del entorno.
2. Levantamiento de contenedores Docker.
3. Validación del estado healthy.
4. Verificación de versión y motor Spider.
5. Ejecución de scripts SQL de inicialización.
6. Validación de tablas distribuidas.
7. Carga de dataset mediante `mariadb_load_tpcc.ps1`.
8. Ejecución de BenchBase mediante `run_benchbase_templated.ps1`.

---

## Parámetros principales

| Parametro | Función                                                 |
| --------- | ------------------------------------------------------- |
| Scale     | Selecciona DS100k, DS500k o DS1M                        |
| Runs      | Número de repeticiones                                  |
| Recreate  | Reconstruye completamente el entorno                    |
| RunLoad   | Ejecuta la carga de datos                               |
| RunBench  | Ejecuta BenchBase                                       |
| RunParse  | Procesa resultados, si existe el script correspondiente |

---

## Objetivo

Garantizar que los experimentos realizados sobre MariaDB sean reproducibles, controlados y comparables con la arquitectura PostgreSQL evaluada en la investigación.
