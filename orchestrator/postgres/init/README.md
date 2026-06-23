# PostgreSQL Initialization Scripts

## Descripción

Esta carpeta contiene los scripts SQL utilizados para inicializar la arquitectura distribuida basada en PostgreSQL, Citus y postgres_fdw.

Los scripts deben ejecutarse en el orden indicado para garantizar la correcta construcción del entorno experimental.

---

## Estructura

```text
init
│
├── 01_populate_remotedb_item.sql
├── 02_create_tpcc_schema.sql
├── 03_citus_add_nodes.sql
├── 04_setup_fdw.sql
├── 05_tpcc_distribute.sql
└── 06_tpcc_secondary_indexes.sql
```

---

## Orden de ejecución

### 01_populate_remotedb_item.sql

Crea la tabla física:

```text
tpcc.item
```

en la base remota utilizada por postgres_fdw.

---

### 02_create_tpcc_schema.sql

Crea el esquema TPCC reducido dentro de:

```text
tesisdb
```

Incluye las tablas distribuidas utilizadas por la investigación.

---

### 03_citus_add_nodes.sql

Registra los nodos workers dentro del clúster Citus.

---

### 04_setup_fdw.sql

Configura postgres_fdw y crea la tabla externa:

```text
tpcc.item
```

como FOREIGN TABLE.

---

### 05_tpcc_distribute.sql

Distribuye las tablas TPCC mediante Citus y establece la co-localización de shards.

---

### 06_tpcc_secondary_indexes.sql

Crea los índices secundarios utilizados por las consultas del workload experimental.

---

## Objetivo

Inicializar completamente la arquitectura PostgreSQL distribuida utilizada durante los experimentos de benchmarking.
