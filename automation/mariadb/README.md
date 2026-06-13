# MariaDB Automation

## DescripciÃ³n

Esta carpeta contiene el script maestro utilizado para automatizar el entorno experimental de MariaDB.

La automatizaciÃ³n fue diseÃ±ada para reproducir de forma controlada la arquitectura distribuida evaluada en la investigaciÃ³n:

* MariaDB 11.4
* Spider Storage Engine

utilizando contenedores Docker, scripts SQL de inicializaciÃ³n y scripts PowerShell.

---

## Estructura

```text
mariadb
â”‚
â”œâ”€â”€ master_mariadb.ps1
â””â”€â”€ README.md
```

---

## Script principal

### master_mariadb.ps1

Script encargado de orquestar el ciclo experimental para MariaDB.

Permite ejecutar de forma automatizada:

* Despliegue del clÃºster MariaDB.
* VerificaciÃ³n de salud de los contenedores.
* InstalaciÃ³n y validaciÃ³n de Spider.
* ConfiguraciÃ³n de servidores Spider.
* CreaciÃ³n de tablas distribuidas.
* Carga de datasets experimentales.
* EjecuciÃ³n de BenchBase.
* PreparaciÃ³n para procesamiento de resultados.

---

## Arquitectura desplegada

El script trabaja sobre la arquitectura definida en:

```text
orchestrator/mariadb
```

La topologÃ­a experimental estÃ¡ compuesta por:

* MariaDB Coordinator
* MariaDB Node 1
* MariaDB Node 2
* MariaDB Item

El coordinador recibe las conexiones de BenchBase y accede a las tablas distribuidas mediante Spider.

---

## Flujo de ejecuciÃ³n

1. RecreaciÃ³n opcional del entorno.
2. Levantamiento de contenedores Docker.
3. ValidaciÃ³n del estado healthy.
4. VerificaciÃ³n de versiÃ³n y motor Spider.
5. EjecuciÃ³n de scripts SQL de inicializaciÃ³n.
6. ValidaciÃ³n de tablas distribuidas.
7. Carga de dataset mediante `mariadb_load_tpcc.ps1`.
8. EjecuciÃ³n de BenchBase mediante `run_benchbase_templated.ps1`.

---

## ParÃ¡metros principales

| ParÃ¡metro | FunciÃ³n                                                 |
| --------- | ------------------------------------------------------- |
| Scale     | Selecciona DS100k, DS500k o DS1M                        |
| Runs      | NÃºmero de repeticiones                                  |
| Recreate  | Reconstruye completamente el entorno                    |
| RunLoad   | Ejecuta la carga de datos                               |
| RunBench  | Ejecuta BenchBase                                       |
| RunParse  | Procesa resultados, si existe el script correspondiente |

---

## Objetivo

Garantizar que los experimentos realizados sobre MariaDB sean reproducibles, controlados y comparables con la arquitectura PostgreSQL evaluada en la investigaciÃ³n.
