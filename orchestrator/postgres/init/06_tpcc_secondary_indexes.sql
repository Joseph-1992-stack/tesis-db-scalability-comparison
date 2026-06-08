BEGIN;
CREATE SCHEMA IF NOT EXISTS tpcc;

-- CUSTOMER: búsquedas por apellido dentro de distrito/warehouse 
CREATE INDEX IF NOT EXISTS idx_customer_last
  ON tpcc.customer (c_w_id, c_d_id, c_last);

-- ORDERS: listar órdenes de un cliente 
CREATE INDEX IF NOT EXISTS idx_orders_by_customer
  ON tpcc.orders (o_w_id, o_d_id, o_c_id, o_id);

-- NEW_ORDER: suele consultarse por (w,d) para “la más antigua”
CREATE INDEX IF NOT EXISTS idx_new_order_wd
  ON tpcc.new_order (no_w_id, no_d_id, no_o_id);

-- ORDER_LINE: recuperar líneas de una orden
CREATE INDEX IF NOT EXISTS idx_order_line_order
  ON tpcc.order_line (ol_w_id, ol_d_id, ol_o_id);

-- STOCK: ya se tiene PK (s_w_id, s_i_id), pero a veces resulta interesante consultar por item (i_id)
-- Útil si hay queries por item global
CREATE INDEX IF NOT EXISTS idx_stock_item
  ON tpcc.stock (s_i_id);

COMMIT;