BEGIN;

CREATE SCHEMA IF NOT EXISTS tpcc;

CREATE TABLE IF NOT EXISTS tpcc.item (
  i_id    INT PRIMARY KEY,
  i_name  TEXT NOT NULL,
  i_price NUMERIC(12,2) NOT NULL
);

-- Datos mínimos de prueba (idempotente)
INSERT INTO tpcc.item (i_id, i_name, i_price)
VALUES
  (1,'Item 1',10.00),
  (2,'Item 2',20.00),
  (3,'Item 3',30.00),
  (4,'Item 4',40.00),
  (5,'Item 5',50.00),
  (6,'Item 6',60.00),
  (7,'Item 7',70.00),
  (8,'Item 8',80.00),
  (9,'Item 9',90.00),
  (10,'Item 10',100.00)
ON CONFLICT (i_id) DO NOTHING;

COMMIT;
