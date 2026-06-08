README – Despliegue PostgreSQL Citus + FDW remoto
Este entorno define un clúster PostgreSQL distribuido con Citus y una base remota accesible vía postgres_fdw, usando Docker Compose. Se utiliza para ejecutar TPC‑C reducido con una tabla item federada.

1. Topología de contenedores
postgresql-coord

Imagen: citusdata/citus:12.1

Rol: coordinator Citus, base principal tesisdb.

Recursos: 2 CPU, 2 GB RAM.

Configuración: postgresql-coord.conf.

Expone el puerto 5432 al host.

postgresql-worker1, postgresql-worker2

Imagen: citusdata/citus:12.1

Rol: workers Citus, almacenan shards de las tablas distribuidas.

Recursos: 1 CPU, 1 GB RAM cada uno.

Configuración: postgresql-worker.conf.

postgresql-item (remotedb)

Imagen: postgres:12

Rol: base remota física para la tabla tpcc.item, objetivo del FDW.

Recursos: 1 CPU, 1 GB RAM.

Configuración: postgresql-remotedb.conf.

Script de inicialización: 01_populate_remotedb_item.sql montado en /docker-entrypoint-initdb.d/.

Todos los contenedores comparten la red Docker tesisnet (driver bridge).

2. Configuración interna de PostgreSQL
2.1 Coordinator – postgresql-coord.conf
Memoria:

shared_buffers = 512MB

work_mem = 32MB

maintenance_work_mem = 128MB

Conexiones:

max_connections = 100

Paralelismo:

max_parallel_workers = 2

max_parallel_workers_per_gather = 1

Citus:

citus.enable_repartition_joins = on

citus.use_secondary_nodes = on

Pensado para planificación, coordinación Citus y acceso FDW.

2.2 Workers – postgresql-worker.conf
Memoria:

shared_buffers = 384MB

work_mem = 16MB

maintenance_work_mem = 64MB

Conexiones:

max_connections = 50

Paralelismo:

max_parallel_workers = 2

max_parallel_workers_per_gather = 1

Citus:

citus.enable_repartition_joins = on

citus.use_secondary_nodes = on

Optimizado para ejecución de shards dentro de 1 GB de RAM.

2.3 Remotedb – postgresql-remotedb.conf
Memoria:

shared_buffers = 256MB

work_mem = 8MB

maintenance_work_mem = 64MB

Conexiones:

max_connections = 50

Paralelismo:

max_parallel_workers = 1

max_parallel_workers_per_gather = 0

Configuración conservadora para una BD remota usada como catálogo (tpcc.item).

3. Scripts SQL y orden de ejecución
Script 01 – Población de base remota (FDW target)

Archivo: 01_populate_remotedb_item.sql

Contenedor: postgresql-item

Base: remotedb

Crea esquema tpcc y tabla física tpcc.item (i_id, i_name, i_price NUMERIC(12,2)).

Script 02 – Definición del esquema TPCC lógico

Archivo: 02_create_tpcc_schema.sql

Contenedor: postgresql-coord

Base: tesisdb

Crea esquema tpcc y tablas:

warehouse, district, customer, orders, order_line, new_order, stock.

No define item.

Script 03 – Configuración FDW y foreign table item

Archivo: 03_setup_fdw.sql

Contenedor: postgresql-coord

Base: tesisdb

Acciones:

Crea extensión postgres_fdw.

Elimina cualquier definición previa de tpcc.item.

Crea SERVER remotedb_srv apuntando a postgresql-item:5432/remotedb.

Define USER MAPPING para postgres.

Crea FOREIGN TABLE tpcc.item que apunta a remotedb.tpcc.item.

Script 04 – Distribución Citus

Archivo: tpcc_distribute.sql

Contenedor: postgresql-coord

Base: tesisdb

Acciones:

Crea extensión citus si no existe.

Declara tpcc.warehouse como tabla distribuida por w_id.

Co‑localiza district, customer, orders, order_line, new_order, stock con warehouse usando la columna *_w_id.

4. Resumen del uso en la tesis
La base tesisdb en el coordinator almacena las tablas TPC‑C distribuidas con Citus.

La tabla tpcc.item vive físicamente en la base remota remotedb (contenedor postgresql-item) y se accede desde tesisdb vía postgres_fdw.

Esta arquitectura permite evaluar:

Escalabilidad horizontal de Citus sobre TPC‑C reducido.

Impacto de integrar una tabla federada remota (item) dentro de un sistema ya distribuido.