BEGIN;

CREATE SCHEMA IF NOT EXISTS tpcc;
-- Tabla: warehouse (raiz del particionamiento)
CREATE TABLE IF NOT EXISTS tpcc.warehouse (
  w_id   INT PRIMARY KEY,
  w_name TEXT NOT NULL,
  w_city TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tpcc.district (
  d_w_id INT NOT NULL,
  d_id   INT NOT NULL,
  d_name TEXT NOT NULL,
  d_city TEXT NOT NULL,
  PRIMARY KEY (d_w_id, d_id)
);

CREATE TABLE IF NOT EXISTS tpcc.customer (
  c_w_id   INT NOT NULL,
  c_d_id   INT NOT NULL,
  c_id     INT NOT NULL,
  c_first  TEXT NOT NULL,
  c_last   TEXT NOT NULL,
  c_city   TEXT NOT NULL,
  PRIMARY KEY (c_w_id, c_d_id, c_id)
);

CREATE TABLE IF NOT EXISTS tpcc.orders (
  o_w_id    INT NOT NULL,
  o_d_id    INT NOT NULL,
  o_id      INT NOT NULL,
  o_c_id    INT NOT NULL,
  o_entry_d TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (o_w_id, o_d_id, o_id)
);
CREATE TABLE IF NOT EXISTS tpcc.order_line (
  ol_w_id     INT NOT NULL,
  ol_d_id     INT NOT NULL,
  ol_o_id     INT NOT NULL,
  ol_number   INT NOT NULL,
  ol_i_id     INT NOT NULL,
  ol_quantity INT NOT NULL,
  ol_amount   NUMERIC(12,2) NOT NULL,
  PRIMARY KEY (ol_w_id, ol_d_id, ol_o_id, ol_number)
);

CREATE TABLE IF NOT EXISTS tpcc.new_order (
  no_w_id INT NOT NULL,
  no_d_id INT NOT NULL,
  no_o_id INT NOT NULL,
  PRIMARY KEY (no_w_id, no_d_id, no_o_id)
);

CREATE TABLE IF NOT EXISTS tpcc.stock (
  s_w_id     INT NOT NULL,
  s_i_id     INT NOT NULL,
  s_quantity INT NOT NULL,
  PRIMARY KEY (s_w_id, s_i_id)
);

COMMIT;
