Script 01 â€“ PoblaciÃ³n de base remota fÃ­sica (FDW target)
01_populate_remotedb_item.sql en postgresql-item (BD remotedb).

Script 02 â€“ DefiniciÃ³n del esquema TPCC lÃ³gico en el coordinador
02_create_tpcc_schema.sql en postgresql-coord (BD tesisdb).

Script 03 â€“ ConfiguraciÃ³n FDW (foreign table item hacia la base remota)
03_setup_fdw.sql en postgresql-coord (BD tesisdb).

Script 04 â€“ DistribuciÃ³n de tablas TPCC con Citus
tpcc_distribute.sql en postgresql-coord (BD tesisdb).


Pendiente de actualizaciÃ³n 
