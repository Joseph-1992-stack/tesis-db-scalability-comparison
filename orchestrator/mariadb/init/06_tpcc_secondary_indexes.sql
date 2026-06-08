USE tesisdb;

CREATE INDEX IF NOT EXISTS idx_customer_last
ON customer (c_w_id,c_d_id,c_last);

CREATE INDEX IF NOT EXISTS idx_orders_by_customer
ON orders (o_w_id,o_d_id,o_c_id,o_id);

CREATE INDEX IF NOT EXISTS idx_new_order_wd
ON new_order (no_w_id,no_d_id,no_o_id);

CREATE INDEX IF NOT EXISTS idx_order_line_order
ON order_line (ol_w_id,ol_d_id,ol_o_id);

CREATE INDEX IF NOT EXISTS idx_stock_item
ON stock (s_i_id);