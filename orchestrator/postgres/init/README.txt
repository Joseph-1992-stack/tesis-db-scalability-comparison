Script 01 – Población de base remota física (FDW target)
01_populate_remotedb_item.sql en postgresql-item (BD remotedb).

Script 02 – Definición del esquema TPCC lógico en el coordinador
02_create_tpcc_schema.sql en postgresql-coord (BD tesisdb).

Script 03 – Configuración FDW (foreign table item hacia la base remota)
03_setup_fdw.sql en postgresql-coord (BD tesisdb).

Script 04 – Distribución de tablas TPCC con Citus
tpcc_distribute.sql en postgresql-coord (BD tesisdb).


Pendiente de actualización 