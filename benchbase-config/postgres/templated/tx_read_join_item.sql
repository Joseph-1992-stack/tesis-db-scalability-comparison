SELECT s.s_quantity, i.i_price
FROM tpcc.stock s
JOIN tpcc.item i ON i.i_id = s.s_i_id
WHERE s.s_w_id = ? AND s.s_i_id = ?;
