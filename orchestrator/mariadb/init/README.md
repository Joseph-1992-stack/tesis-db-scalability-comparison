# MariaDB Initialization Scripts

## Descripción

Esta carpeta contiene los scripts SQL utilizados para inicializar la arquitectura distribuida basada en MariaDB y Spider Storage Engine.

Los scripts deben ejecutarse en el orden definido para garantizar la correcta construcción de la arquitectura experimental.

---

## Estructura

```text
init
│
├── 01_create_remote_item.sql
├── 02_create_databases_nodes.sql
├── 03_install_spider.sql
├── 04_create_spider_servers.sql
├── 05_create_tpcc_spider.sql
└── 06_tpcc_secondary_indexes.sql
```

---

## Orden de ejecución

### 01_create_remote_item.sql

Crea la base de datos remota utilizada para almacenar físicamente la tabla:

```text
item
```

Además inserta datos mínimos de prueba para validar la conectividad remota.

---

### 02_create_databases_nodes.sql

Crea las tablas físicas del esquema TPCC reducido en los nodos distribuidos.

Incluye:

* warehouse
* district
* customer
* orders
* order_line
* new_order
* stock

---

### 03_install_spider.sql

Instala y verifica la disponibilidad de Spider Storage Engine.

---

### 04_create_spider_servers.sql

Define los servidores remotos utilizados por Spider:

* node1_srv
* node2_srv
* item_srv

Estos servidores permiten acceder a los nodos distribuidos y a la base remota.

---

### 05_create_tpcc_spider.sql

Crea las tablas lógicas Spider dentro de la base de datos:

```text
tesisdb
```

Las tablas actúan como interfaces distribuidas hacia las tablas físicas ubicadas en los nodos remotos.

---

### 06_tpcc_secondary_indexes.sql

Crea los índices secundarios utilizados por las consultas del workload experimental.

---

## Objetivo

Inicializar completamente la arquitectura distribuida MariaDB utilizada durante los experimentos de benchmarking.
