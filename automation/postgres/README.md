# PostgreSQL Automation

## DescripciÃ³n

Esta carpeta contiene el script maestro utilizado para automatizar completamente el entorno experimental de PostgreSQL.

La automatizaciÃ³n fue diseÃ±ada para reproducir de forma consistente la arquitectura distribuida evaluada en la investigaciÃ³n:

* PostgreSQL 17
* Citus
* postgres_fdw

utilizando contenedores Docker y scripts SQL de inicializaciÃ³n.

---

## Estructura

```text
postgres
â”‚
â”œâ”€â”€ master_postgres.ps1
â””â”€â”€ README.md
```

---

## Script principal

### master_postgres.ps1

Script encargado de orquestar todo el ciclo experimental para PostgreSQL.

Permite ejecutar de forma automatizada:

* Despliegue del clÃºster.
* ConfiguraciÃ³n de Citus.
* ConfiguraciÃ³n de postgres_fdw.
* InicializaciÃ³n del esquema experimental.
* Carga de datasets.
* EjecuciÃ³n de BenchBase.
* Procesamiento de resultados.

---

## Arquitectura desplegada

El script trabaja sobre la arquitectura definida en:

```text
orchestrator/postgres
```

La topologÃ­a experimental estÃ¡ compuesta por:

* Coordinator Node
* Worker Node 1
* Worker Node 2
* Remote Database (FDW)

El nodo coordinador recibe todas las conexiones de BenchBase y distribuye internamente las operaciones hacia los nodos correspondientes.

---

## Flujo de ejecuciÃ³n

El script sigue la siguiente secuencia:

### 1. RecreaciÃ³n del entorno (opcional)

Permite eliminar completamente los contenedores y volÃºmenes existentes.

```powershell
-Recreate
```

---

### 2. Despliegue del clÃºster

Levanta todos los contenedores definidos en Docker Compose.

---

### 3. ValidaciÃ³n de salud

Verifica que todos los nodos alcancen estado:

```text
healthy
```

antes de continuar.

---

### 4. ValidaciÃ³n de versiones

Registra:

* versiÃ³n de PostgreSQL
* versiÃ³n de Citus
* versiÃ³n de postgres_fdw

---

### 5. InicializaciÃ³n de la arquitectura

Ejecuta los scripts SQL responsables de:

* creaciÃ³n del esquema TPC-C reducido
* incorporaciÃ³n de nodos Citus
* configuraciÃ³n de FDW
* distribuciÃ³n de tablas
* creaciÃ³n de Ã­ndices

---

### 6. Verificaciones operativas

Comprueba:

* workers activos
* shards distribuidos
* acceso a tablas remotas

---

### 7. Carga de datasets (opcional)

Mediante:

```text
automation/dataset-loader/postgres_load_tpcc.ps1
```

Permite generar los datasets:

* DS100k
* DS500k
* DS1M

---

### 8. EjecuciÃ³n de BenchBase (opcional)

Ejecuta automÃ¡ticamente los escenarios experimentales correspondientes a la escala seleccionada.

Ejemplos:

```text
E1_DS100k_T10
E2_DS100k_T50
E3_DS100k_T100
```

---

### 9. Procesamiento de resultados (opcional)

Permite consolidar los resultados obtenidos para su posterior anÃ¡lisis estadÃ­stico.

---

## ParÃ¡metros principales

| ParÃ¡metro | FunciÃ³n                              |
| --------- | ------------------------------------ |
| Scale     | Selecciona DS100k, DS500k o DS1M     |
| Runs      | NÃºmero de repeticiones               |
| Recreate  | Reconstruye completamente el entorno |
| RunLoad   | Ejecuta la carga de datos            |
| RunBench  | Ejecuta BenchBase                    |
| RunParse  | Procesa resultados                   |

---

## Objetivo

Garantizar que todos los experimentos realizados sobre PostgreSQL sean reproducibles, controlados y consistentes, minimizando la intervenciÃ³n manual durante las fases de despliegue y ejecuciÃ³n.
