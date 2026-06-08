BEGIN;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Limpieza (idempotente)
DROP FOREIGN TABLE IF EXISTS tpcc.item;
DROP TABLE IF EXISTS tpcc.item CASCADE;

DROP SERVER IF EXISTS remotedb_srv CASCADE;

CREATE SERVER remotedb_srv
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (
    host 'postgresql-item',
    port '5432',
    dbname 'remotedb'
  );

CREATE USER MAPPING IF NOT EXISTS FOR postgres
  SERVER remotedb_srv
  OPTIONS (
    user 'postgres',
    password 'postgres'
  );

CREATE FOREIGN TABLE tpcc.item (
  i_id    INT,
  i_name  TEXT,
  i_price NUMERIC(12,2)
)
SERVER remotedb_srv
OPTIONS (
  schema_name 'tpcc',
  table_name 'item'
);

COMMIT;
