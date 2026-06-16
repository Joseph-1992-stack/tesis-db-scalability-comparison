# PostgreSQL Automation

## Descripción

Esta carpeta contiene el script maestro utilizado para automatizar completamente el entorno experimental de PostgreSQL.

La automatización fue diseñada para reproducir de forma consistente la arquitectura distribuida evaluada en la investigación:

* PostgreSQL 17
* Citus
* postgres_fdw

utilizando contenedores Docker y scripts SQL de inicialización.

---

## Estructura

```text
postgres
│
├── master_postgres.ps1
└── README.md
```
---

## Script principal

### master_postgres.ps1

Script encargado de orquestar todo el ciclo experimental para PostgreSQL.

Permite ejecutar de forma automatizada:

* Despliegue del clúster.
* Configuración de Citus.
* Configuración de postgres_fdw.
* Inicialización del esquema experimental.
* Carga de datasets.
* Ejecución de BenchBase.
* Procesamiento y consolidación automática de resultados mediante parse_benchbase.ps1.

---

## Arquitectura desplegada

El script trabaja sobre la arquitectura definida en:

```text
orchestrator/postgres
```

La topologí­a experimental está compuesta por:

* Coordinator Node
* Worker Node 1
* Worker Node 2
* Remote Database (FDW)

El nodo coordinador recibe todas las conexiones de BenchBase y distribuye internamente las operaciones hacia los nodos correspondientes.

---

## Flujo de ejecución

El script sigue la siguiente secuencia:

### 1. Recreación del entorno (opcional)

Permite eliminar completamente los contenedores y volúmenes existentes.

```powershell
-Recreate
```

---

### 2. Despliegue del clúster

Levanta todos los contenedores definidos en Docker Compose.

---

### 3. Validación de salud

Verifica que todos los nodos alcancen estado:

```text
healthy
```

antes de continuar.

---

### 4. Validación de versiones

Registra:

* versión de PostgreSQL
* versión de Citus
* versión de postgres_fdw

---

### 5. Inicialización de la arquitectura

Ejecuta los scripts SQL responsables de:

* creación del esquema TPC-C reducido
* incorporación de nodos Citus
* configuración de FDW
* distribución de tablas
* creación de í­ndices

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

### 8. Ejecución de BenchBase (opcional)

Ejecuta automáticamente los escenarios experimentales correspondientes a la escala seleccionada.

Ejemplos:

```text
E1_DS100k_T10
E2_DS100k_T50
E3_DS100k_T100
```

---

### 9. Procesamiento y consolidación automática de resultados mediante parse_benchbase.ps1.)

Permite consolidar los resultados obtenidos para su posterior análisis estadí­stico.

---

## Parámetros principales

| Parámetro | Función                              |
| --------- | ------------------------------------ |
| Scale     | Selecciona DS100k, DS500k o DS1M     |
| Runs      | Número de repeticiones               |
| Recreate  | Reconstruye completamente el entorno |
| RunLoad   | Ejecuta la carga de datos            |
| RunBench  | Ejecuta BenchBase                    |
| RunParse  | Procesa resultados                   |

---

## Objetivo

Garantizar que todos los experimentos realizados sobre PostgreSQL sean reproducibles, controlados y consistentes, minimizando la intervención manual durante las fases de despliegue y ejecución.
