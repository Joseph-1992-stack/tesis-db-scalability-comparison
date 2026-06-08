UPDATE tpcc.stock
SET s_quantity = s_quantity - 1
WHERE s_w_id = ? AND s_i_id = ?;
